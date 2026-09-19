import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/app_user.dart';
import '../../models/lesson.dart';
import '../../models/school.dart';
import '../../services/database_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/lesson_card.dart';
import '../../widgets/magic_background.dart';
import '../../widgets/magic_button.dart';
import '../../widgets/magic_loading_indicator.dart';
import '../puzzle/puzzle_game_screen.dart';

/// Screen 5 — Lesson Selection Screen (PRD Section 11)
/// Displays the 3 curriculum lessons belonging to a chosen magical school,
/// evaluating sequential unlock conditions from Supabase user_progress.
class LessonSelectionScreen extends StatefulWidget {
  final School school;
  final AppUser user;

  const LessonSelectionScreen({
    super.key,
    required this.school,
    required this.user,
  });

  @override
  State<LessonSelectionScreen> createState() => _LessonSelectionScreenState();
}

class _LessonSelectionScreenState extends State<LessonSelectionScreen> {
  late Future<_LessonScreenData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_LessonScreenData> _loadData() async {
    final results = await Future.wait([
      DatabaseService.instance.getLessonsForSchool(widget.school.id),
      ProgressService.instance.getCompletedLessonIds(widget.user.id),
    ]);

    return _LessonScreenData(
      lessons: results[0] as List<Lesson>,
      completedIds: results[1] as Set<String>,
    );
  }

  void _onLessonTapped(Lesson lesson, bool isLocked) {
    if (isLocked) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: GlassPanel(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              borderColor: AppColors.goldLight,
              glowColor: AppColors.goldGlow,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lesson.spellIcon,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'LESSON 0${lesson.lessonOrder} — ${lesson.title.toUpperCase()}',
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 18,
                        color: AppColors.textGold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SPELL REWARD: ${lesson.spellName.toUpperCase()}',
                      style: AppTypography.label.copyWith(
                        color: AppColors.violetGlow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      lesson.description,
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    MagicButton(
                      label: 'BEGIN LESSON',
                      icon: Icons.auto_awesome,
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _startPuzzle(lesson);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        'CLOSE',
                        style: AppTypography.buttonSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _startPuzzle(Lesson lesson) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            PuzzleGameScreen(lesson: lesson, user: widget.user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    if (mounted) {
      setState(() {
        _dataFuture = _loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color schoolAccent = switch (widget.school.name) {
      'Elemental Arts' => AppColors.elementalFlame,
      'Arcane Runes' => AppColors.arcaneRune,
      'Mystic Logic' => AppColors.mysticLogic,
      _ => AppColors.goldPrimary,
    };

    return Scaffold(
      body: MagicBackground(
        maxContentWidth: 720,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Back Navigation
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.goldLight),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Return to Academy',
                ),
              ),
              const SizedBox(height: 8),

              // School Header Banner
              GlassPanel(
                borderColor: schoolAccent.withValues(alpha: 0.5),
                glowColor: schoolAccent.withValues(alpha: 0.15),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: schoolAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: schoolAccent.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.school.icon,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.school.name.toUpperCase(),
                            style: AppTypography.displaySmall.copyWith(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.school.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Lessons List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'CURRICULUM LESSONS',
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 15,
                        color: AppColors.textGold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sequential Unlock Required',
                    style: AppTypography.label.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Lessons List with Sequential Unlocking
              Expanded(
                child: FutureBuilder<_LessonScreenData>(
                  future: _dataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: MagicLoadingIndicator(
                          message: 'Consulting school archives...',
                        ),
                      );
                    }

                    final data = snapshot.data;
                    final lessons = data?.lessons ?? [];
                    final completedIds = data?.completedIds ?? {};

                    if (lessons.isEmpty) {
                      return Center(
                        child: Text(
                          'No lessons found in this school archive.',
                          style: AppTypography.bodyMedium,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: lessons.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        final bool isCompleted =
                            completedIds.contains(lesson.id);

                        // Sequential Unlock Rules (PRD Section 11):
                        // - Lesson 1 (index 0) is initially unlocked.
                        // - Lesson 2 unlocks after Lesson 1 is completed.
                        // - Lesson 3 unlocks after Lesson 2 is completed.
                        bool isLocked = false;
                        if (index == 1) {
                          isLocked = !completedIds.contains(lessons[0].id);
                        } else if (index == 2) {
                          isLocked = !completedIds.contains(lessons[1].id);
                        }

                        return LessonCard(
                          lessonOrder: lesson.lessonOrder,
                          title: lesson.title,
                          description: lesson.description,
                          spellName: lesson.spellName,
                          spellIcon: lesson.spellIcon,
                          spellDescription: lesson.spellDescription,
                          isCompleted: isCompleted,
                          isLocked: isLocked,
                          onTap: () => _onLessonTapped(lesson, isLocked),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonScreenData {
  final List<Lesson> lessons;
  final Set<String> completedIds;

  const _LessonScreenData({
    required this.lessons,
    required this.completedIds,
  });
}
