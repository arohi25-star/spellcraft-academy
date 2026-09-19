import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/data/seed_data.dart';
import '../models/lesson.dart';
import '../models/puzzle.dart';
import '../models/school.dart';
import '../models/spell.dart';

/// Service responsible for querying static Academy content (Schools, Lessons, Puzzles)
/// directly from the Supabase database, with offline seed fallbacks for resilience.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  bool get _isSupabaseReady {
    if (!AppConstants.isSupabaseConfigured) return false;
    try {
      // ignore: unnecessary_null_comparison
      return Supabase.instance != null;
    } catch (_) {
      return false;
    }
  }

  /// Retrieves all 3 magical schools from Supabase
  Future<List<School>> getSchools() async {
    if (_isSupabaseReady) {
      try {
        final response = await Supabase.instance.client
            .from('schools')
            .select()
            .order('sort_order', ascending: true);

        return (response as List<dynamic>)
            .map((json) => School.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error fetching schools from Supabase: $e');
      }
    }

    // Fallback to local seed content
    return SeedData.schools.map((json) => School.fromJson(json)).toList();
  }

  /// Retrieves the 3 lessons belonging to a specific school
  Future<List<Lesson>> getLessonsForSchool(String schoolId) async {
    if (_isSupabaseReady) {
      try {
        final response = await Supabase.instance.client
            .from('lessons')
            .select()
            .eq('school_id', schoolId)
            .order('lesson_order', ascending: true);

        return (response as List<dynamic>)
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error fetching lessons for school $schoolId: $e');
      }
    }

    // Fallback to local seed content
    return SeedData.lessons
        .where((l) => l['school_id'] == schoolId)
        .map((json) => Lesson.fromJson(json))
        .toList();
  }

  /// Retrieves all 9 lessons across all magical schools
  Future<List<Lesson>> getAllLessons() async {
    if (_isSupabaseReady) {
      try {
        final response = await Supabase.instance.client
            .from('lessons')
            .select()
            .order('created_at', ascending: true);

        return (response as List<dynamic>)
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error fetching all lessons from Supabase: $e');
      }
    }

    return SeedData.lessons.map((json) => Lesson.fromJson(json)).toList();
  }

  /// Retrieves the 3 puzzles for a specific lesson
  Future<List<Puzzle>> getPuzzlesForLesson(String lessonId) async {
    if (_isSupabaseReady) {
      try {
        final response = await Supabase.instance.client
            .from('puzzles')
            .select()
            .eq('lesson_id', lessonId)
            .order('sort_order', ascending: true);

        return (response as List<dynamic>)
            .map((json) => Puzzle.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error fetching puzzles for lesson $lessonId: $e');
      }
    }

    // Fallback to local seed content
    return SeedData.puzzles
        .where((p) => p['lesson_id'] == lessonId)
        .map((json) => Puzzle.fromJson(json))
        .toList();
  }

  /// Retrieves all 9 spells defined in the Academy curriculum
  Future<List<Spell>> getAllSpells() async {
    final schools = await getSchools();
    final lessons = await getAllLessons();

    final schoolNameMap = {for (var s in schools) s.id: s.name};

    return lessons.map((l) {
      return Spell(
        id: l.id,
        name: l.spellName,
        description: l.spellDescription,
        icon: l.spellIcon,
        schoolName: schoolNameMap[l.schoolId] ?? 'Academy Lore',
        schoolId: l.schoolId,
        lessonId: l.id,
        masteryLevel: 'Beginner',
        isUnlocked: false,
        xpEarned: 100,
      );
    }).toList();
  }
}
