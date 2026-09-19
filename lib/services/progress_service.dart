import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/lesson.dart';
import '../models/spell.dart';
import '../models/user_stats.dart';
import 'database_service.dart';

/// Service responsible for managing and synchronizing user-specific progress,
/// XP stats, completed lessons, and unlocked spells with Supabase.
class ProgressService {
  ProgressService._internal();
  static final ProgressService instance = ProgressService._internal();

  bool get _isSupabaseReady {
    if (!AppConstants.isSupabaseConfigured) return false;
    try {
      // ignore: unnecessary_null_comparison
      return Supabase.instance != null;
    } catch (_) {
      return false;
    }
  }

  /// Fetches the user's statistics from the Supabase user_stats table,
  /// falling back to local storage cache if offline or in tests.
  Future<UserStats> getUserStats(String userId) async {
    // Check local cache first as baseline
    UserStats? localStats;
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('user_stats_$userId');
      if (statsJson != null) {
        localStats =
            UserStats.fromJson(jsonDecode(statsJson) as Map<String, dynamic>);
      }
    } catch (_) {}

    if (_isSupabaseReady) {
      try {
        final client = Supabase.instance.client;
        final response = await client
            .from('user_stats')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        if (response != null) {
          final stats = UserStats.fromJson(response);
          // Sync to local cache
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
                'user_stats_$userId', jsonEncode(stats.toJson()));
          } catch (_) {}
          return stats;
        }

        // New apprentice: initialize user_stats record in Supabase
        final initialStats = {
          'user_id': userId,
          'total_xp': 0,
          'current_level': 1,
          'lessons_completed': 0,
          'spells_unlocked': 0,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await client.from('user_stats').upsert(initialStats);
        final stats = UserStats.fromJson(initialStats);
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'user_stats_$userId', jsonEncode(stats.toJson()));
        } catch (_) {}
        return stats;
      } catch (e) {
        debugPrint('Error loading user_stats from Supabase: $e');
      }
    }

    return localStats ?? UserStats(userId: userId);
  }

  /// Retrieves all completed lesson IDs for this user from Supabase user_progress,
  /// falling back to local storage cache if offline or in tests.
  Future<Set<String>> getCompletedLessonIds(String userId) async {
    Set<String> localCached = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedList = prefs.getStringList('completed_lessons_$userId');
      if (cachedList != null) {
        localCached = cachedList.toSet();
      }
    } catch (_) {}

    if (_isSupabaseReady) {
      try {
        final client = Supabase.instance.client;
        final progressRes = await client
            .from('user_progress')
            .select('lesson_id')
            .eq('user_id', userId)
            .eq('completed', true);

        final remoteSet = (progressRes as List<dynamic>)
            .map((e) => e['lesson_id'] as String)
            .toSet();
        return {...localCached, ...remoteSet};
      } catch (e) {
        debugPrint('Error loading completed lesson IDs from Supabase: $e');
      }
    }
    return localCached;
  }

  /// Marks a lesson as completed according to PRD Section 20:
  /// - Base reward: 100 XP
  /// - Flawless bonus: +25 XP if completed without mistakes
  /// - Recalculates level: Level 1 = 0-199 XP, Level 2 = 200-399 XP, etc.
  /// - Creates/updates user_progress, user_spells, and user_stats.
  /// - Prevents duplicate XP and duplicate spell unlocks if revisiting a completed lesson.
  Future<LessonRewardResult> completeLesson({
    required String userId,
    required Lesson lesson,
    int mistakeCount = 0,
  }) async {
    final completedIds = await getCompletedLessonIds(userId);
    final bool isFirstCompletion = !completedIds.contains(lesson.id);

    final currentStats = await getUserStats(userId);

    if (!isFirstCompletion) {
      // Revisit / Practice mode: Do not award duplicate XP or increment stats
      return LessonRewardResult(
        isFirstCompletion: false,
        baseXp: 0,
        bonusXp: 0,
        totalXpEarned: 0,
        newTotalXp: currentStats.totalXp,
        newLevel: currentStats.currentLevel,
        leveledUp: false,
        mistakeCount: mistakeCount,
      );
    }

    // 1. Calculate XP according to PRD.md Section 20
    const int baseXp = 100;
    final int bonusXp = (mistakeCount == 0) ? 25 : 0;
    final int totalXpEarned = baseXp + bonusXp;

    // 2. Recalculate level: Level = (totalXp ~/ 200) + 1
    final int newTotalXp = currentStats.totalXp + totalXpEarned;
    final int newLevel = (newTotalXp ~/ 200) + 1;
    final bool leveledUp = newLevel > currentStats.currentLevel;
    final int newLessonsCompleted = currentStats.lessonsCompleted + 1;
    final int newSpellsUnlocked = currentStats.spellsUnlocked + 1;

    final updatedStats = UserStats(
      userId: userId,
      totalXp: newTotalXp,
      currentLevel: newLevel,
      lessonsCompleted: newLessonsCompleted,
      spellsUnlocked: newSpellsUnlocked,
      updatedAt: DateTime.now(),
    );

    // 3. Update local cache (SharedPreferences)
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'completed_lessons_$userId';
      final cached = prefs.getStringList(key) ?? [];
      if (!cached.contains(lesson.id)) {
        cached.add(lesson.id);
        await prefs.setStringList(key, cached);
      }
      await prefs.setString(
          'user_stats_$userId', jsonEncode(updatedStats.toJson()));

      // Cache user_spells entry
      final spellKey = 'user_spells_$userId';
      final rawSpellList = prefs.getStringList(spellKey) ?? [];
      final newSpellJson = jsonEncode({
        'user_id': userId,
        'lesson_id': lesson.id,
        'spell_name': lesson.spellName,
        'mastery_level': mistakeCount == 0 ? 'Flawless' : 'Mastered',
        'xp_earned': totalXpEarned,
        'unlocked_at': DateTime.now().toIso8601String(),
      });
      final updatedSpellList = rawSpellList
          .where((s) {
            try {
              final map = jsonDecode(s) as Map<String, dynamic>;
              return map['lesson_id'] != lesson.id;
            } catch (_) {
              return true;
            }
          })
          .toList()
        ..add(newSpellJson);
      await prefs.setStringList(spellKey, updatedSpellList);
    } catch (e) {
      debugPrint('Error updating local lesson cache: $e');
    }

    // 4. Update Supabase records
    if (_isSupabaseReady) {
      try {
        final client = Supabase.instance.client;
        final now = DateTime.now().toIso8601String();

        // 4a. Upsert user_progress
        await client.from('user_progress').upsert({
          'user_id': userId,
          'lesson_id': lesson.id,
          'completed': true,
          'score': totalXpEarned,
          'attempts': mistakeCount + 1,
          'completed_at': now,
          'updated_at': now,
        }, onConflict: 'user_id,lesson_id');

        // 4b. Upsert user_spells
        await client.from('user_spells').upsert({
          'user_id': userId,
          'lesson_id': lesson.id,
          'spell_name': lesson.spellName,
          'mastery_level': mistakeCount == 0 ? 'Flawless' : 'Mastered',
          'xp_earned': totalXpEarned,
          'unlocked_at': now,
        }, onConflict: 'user_id,lesson_id');

        // 4c. Upsert user_stats
        await client.from('user_stats').upsert({
          'user_id': userId,
          'total_xp': newTotalXp,
          'current_level': newLevel,
          'lessons_completed': newLessonsCompleted,
          'spells_unlocked': newSpellsUnlocked,
          'updated_at': now,
        });
      } catch (e) {
        debugPrint('Error synchronizing lesson completion with Supabase: $e');
      }
    }

    return LessonRewardResult(
      isFirstCompletion: true,
      baseXp: baseXp,
      bonusXp: bonusXp,
      totalXpEarned: totalXpEarned,
      newTotalXp: newTotalXp,
      newLevel: newLevel,
      leveledUp: leveledUp,
      mistakeCount: mistakeCount,
    );
  }

  /// Retrieves the count of completed lessons per magical school for this user
  Future<Map<String, int>> getCompletedLessonsBySchool(String userId) async {
    final Map<String, int> schoolProgress = {};

    if (_isSupabaseReady) {
      try {
        final client = Supabase.instance.client;
        final progressRes = await client
            .from('user_progress')
            .select('lesson_id')
            .eq('user_id', userId)
            .eq('completed', true);

        final completedLessonIds = (progressRes as List<dynamic>)
            .map((e) => e['lesson_id'] as String)
            .toSet();

        final allLessons = await DatabaseService.instance.getAllLessons();
        for (final lesson in allLessons) {
          if (completedLessonIds.contains(lesson.id)) {
            schoolProgress[lesson.schoolId] =
                (schoolProgress[lesson.schoolId] ?? 0) + 1;
          }
        }
        return schoolProgress;
      } catch (e) {
        debugPrint('Error loading user_progress from Supabase: $e');
      }
    }

    return schoolProgress;
  }

  /// Returns the next recommended lesson for the "Continue Learning" action
  Future<Lesson?> getContinueLearningLesson(String userId) async {
    final allLessons = await DatabaseService.instance.getAllLessons();
    if (allLessons.isEmpty) return null;

    if (_isSupabaseReady) {
      try {
        final client = Supabase.instance.client;
        final progressRes = await client
            .from('user_progress')
            .select('lesson_id')
            .eq('user_id', userId)
            .eq('completed', true);

        final completedIds = (progressRes as List<dynamic>)
            .map((e) => e['lesson_id'] as String)
            .toSet();

        for (final lesson in allLessons) {
          if (!completedIds.contains(lesson.id)) {
            return lesson;
          }
        }
      } catch (e) {
        debugPrint('Error finding continue learning lesson: $e');
      }
    }

    // Default to first lesson if not completed or on offline fallback
    return allLessons.first;
  }

  /// Retrieves all 9 spells in the Spellbook for the user,
  /// marking unlocked spells with their Supabase mastery data and
  /// locked spells with their required curriculum lesson.
  Future<List<Spell>> getSpellbookForUser(String userId) async {
    final schools = await DatabaseService.instance.getSchools();
    final allLessons = await DatabaseService.instance.getAllLessons();

    final schoolMap = {for (var s in schools) s.id: s};

    // 1. Fetch user unlocked spells from Supabase or local cache
    final Map<String, Map<String, dynamic>> userSpellMap = {};

    // Read local cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList('user_spells_$userId') ?? [];
      for (final raw in rawList) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final lessonId = map['lesson_id'] as String?;
        if (lessonId != null) {
          userSpellMap[lessonId] = map;
        }
      }
    } catch (_) {}

    // Check Supabase if available
    if (_isSupabaseReady) {
      try {
        final client = Supabase.instance.client;
        final response = await client
            .from('user_spells')
            .select()
            .eq('user_id', userId);

        for (final row in response as List<dynamic>) {
          final map = row as Map<String, dynamic>;
          final lessonId = map['lesson_id'] as String?;
          if (lessonId != null) {
            userSpellMap[lessonId] = map;
          }
        }
      } catch (e) {
        debugPrint('Error fetching user_spells from Supabase: $e');
      }
    }

    // 2. Map all lessons into Spell entries with lock/unlock status
    return allLessons.map((lesson) {
      final school = schoolMap[lesson.schoolId];
      final schoolName = school?.name ?? 'Academy Lore';
      final spellRecord = userSpellMap[lesson.id];
      final bool isUnlocked = spellRecord != null;

      DateTime? unlockedDate;
      if (spellRecord != null && spellRecord['unlocked_at'] != null) {
        unlockedDate = DateTime.tryParse(spellRecord['unlocked_at'] as String);
      }

      return Spell(
        id: lesson.id,
        name: lesson.spellName,
        description: lesson.spellDescription,
        icon: lesson.spellIcon,
        schoolName: schoolName,
        schoolId: lesson.schoolId,
        lessonId: lesson.id,
        lessonTitle: lesson.title,
        lessonOrder: lesson.lessonOrder,
        masteryLevel: spellRecord?['mastery_level'] as String? ?? 'Beginner',
        isUnlocked: isUnlocked,
        xpEarned: (spellRecord?['xp_earned'] as num?)?.toInt() ?? 100,
        unlockedAt: unlockedDate,
        unlockRequirement:
            'Complete $schoolName — Lesson 0${lesson.lessonOrder}: ${lesson.title}',
      );
    }).toList();
  }
}

/// Represents the calculated reward outcome after completing a lesson
class LessonRewardResult {
  final bool isFirstCompletion;
  final int baseXp;
  final int bonusXp;
  final int totalXpEarned;
  final int newTotalXp;
  final int newLevel;
  final bool leveledUp;
  final int mistakeCount;

  const LessonRewardResult({
    required this.isFirstCompletion,
    required this.baseXp,
    required this.bonusXp,
    required this.totalXpEarned,
    required this.newTotalXp,
    required this.newLevel,
    required this.leveledUp,
    required this.mistakeCount,
  });

  bool get isFlawless => mistakeCount == 0;
}

