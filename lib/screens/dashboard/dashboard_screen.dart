import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/app_user.dart';
import '../../models/lesson.dart';
import '../../models/school.dart';
import '../../models/user_stats.dart';
import '../../services/database_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/magic_background.dart';
import '../../widgets/magic_button.dart';
import '../../widgets/magic_loading_indicator.dart';
import '../../widgets/school_card.dart';
import '../../widgets/xp_progress_bar.dart';
import '../lessons/lesson_selection_screen.dart';
import '../profile/profile_screen.dart';
import '../schools/school_selection_screen.dart';
import '../spellbook/spellbook_screen.dart';

/// Screen 3 — Academy Dashboard (PRD Section 9)
/// Primary player hub displaying apprentice profile, dynamic stats from Supabase,
/// school pathways, continue learning action, and spellbook navigation.
class DashboardScreen extends StatefulWidget {
  final AppUser user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late Future<_DashboardData> _dashboardDataFuture;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _loadData();
  }

  void _loadData() {
    _dashboardDataFuture = _fetchDashboardData();
    _animController.forward(from: 0.0);
  }

  Future<_DashboardData> _fetchDashboardData() async {
    final userId = widget.user.id;
    final results = await Future.wait([
      ProgressService.instance.getUserStats(userId),
      ProgressService.instance.getCompletedLessonsBySchool(userId),
      DatabaseService.instance.getSchools(),
      ProgressService.instance.getContinueLearningLesson(userId),
    ]);

    return _DashboardData(
      stats: results[0] as UserStats,
      schoolProgress: results[1] as Map<String, int>,
      schools: results[2] as List<School>,
      nextLesson: results[3] as Lesson?,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openProfile(UserStats stats) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProfileScreen(user: widget.user, stats: stats),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openSpellbook() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            SpellbookScreen(user: widget.user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openSchoolSelection() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            SchoolSelectionScreen(user: widget.user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _onSchoolTapped(School school) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            LessonSelectionScreen(school: school, user: widget.user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _onContinueLearning(Lesson? lesson, List<School> schools) {
    if (lesson == null || schools.isEmpty) return;
    final matchingSchool = schools.firstWhere(
      (s) => s.id == lesson.schoolId,
      orElse: () => schools.first,
    );
    _onSchoolTapped(matchingSchool);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MagicBackground(
        maxContentWidth: 840,
        child: FutureBuilder<_DashboardData>(
          future: _dashboardDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: MagicLoadingIndicator(
                  message: 'Opening the Academy Dashboard...',
                ),
              );
            }

            final data = snapshot.data ??
                _DashboardData(
                  stats: UserStats(userId: widget.user.id),
                  schoolProgress: {},
                  schools: [],
                  nextLesson: null,
                );

            final stats = data.stats;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header: Greeting, Google Avatar, and Profile Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GOOD EVENING, APPRENTICE',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.textGold,
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.user.displayName.toUpperCase(),
                                style: AppTypography.displaySmall.copyWith(
                                  fontSize: 20,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Avatar button opening Profile
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => _openProfile(stats),
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.goldLight,
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.goldGlow,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.violetSoft,
                                backgroundImage: widget.user.avatarUrl != null
                                    ? NetworkImage(widget.user.avatarUrl!)
                                    : null,
                                child: widget.user.avatarUrl == null
                                    ? Text(
                                        widget.user.displayName.isNotEmpty
                                            ? widget.user.displayName[0]
                                                .toUpperCase()
                                            : 'A',
                                        style:
                                            AppTypography.displaySmall.copyWith(
                                          fontSize: 16,
                                          color: AppColors.goldLight,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 2. Apprentice Progress & Level Band Card
                    GlassPanel(
                      borderColor: AppColors.goldDark.withValues(alpha: 0.4),
                      glowColor: AppColors.goldGlow.withValues(alpha: 0.2),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'ARCANE MASTERY',
                                  style: AppTypography.label
                                      .copyWith(color: AppColors.textMuted),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TOTAL XP: ${stats.totalXp}',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.goldLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          XPProgressBar(
                            currentXp: stats.currentLevelXp,
                            maxXp: stats.nextLevelXp,
                            currentLevel: stats.currentLevel,
                            height: 12,
                          ),
                          const SizedBox(height: 16),
                          // Stats Tally Grid: Completed Lessons & Unlocked Spells
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundSecondary,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.surfaceGlassBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_stories_rounded,
                                        size: 18,
                                        color: AppColors.success,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${stats.lessonsCompleted} / 9',
                                              style: AppTypography.displaySmall
                                                  .copyWith(fontSize: 14),
                                            ),
                                            Text(
                                              'Lessons Completed',
                                              style: AppTypography.label
                                                  .copyWith(fontSize: 9),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundSecondary,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.surfaceGlassBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 18,
                                        color: AppColors.violetGlow,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${stats.spellsUnlocked} / 9',
                                              style: AppTypography.displaySmall
                                                  .copyWith(fontSize: 14),
                                            ),
                                            Text(
                                              'Spells Mastered',
                                              style: AppTypography.label
                                                  .copyWith(fontSize: 9),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Continue Learning CTA Action
                    if (data.nextLesson != null)
                      GlassPanel(
                        borderColor: AppColors.violetBorder,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.violetSoft,
                                border: Border.all(
                                    color: AppColors.violetGlow, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  data.nextLesson!.spellIcon,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CONTINUE LEARNING',
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.violetGlow,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Lesson: ${data.nextLesson!.title} • Spell: ${data.nextLesson!.spellName}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            MagicButton(
                              label: 'RESUME',
                              icon: Icons.play_arrow_rounded,
                              height: 38,
                              onPressed: () =>
                                  _onContinueLearning(data.nextLesson, data.schools),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 28),

                    // 4. Magical Schools Overview Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'CHOOSE YOUR PATH',
                            style: AppTypography.displaySmall.copyWith(
                              fontSize: 16,
                              color: AppColors.textGold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _openSchoolSelection,
                            child: Row(
                              children: [
                                Text(
                                  'All Schools',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.violetGlow,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    size: 11, color: AppColors.violetGlow),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Responsive Schools Grid / Column
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isWide = constraints.maxWidth > 680;

                        final schoolWidgets = data.schools.map((school) {
                          final completed =
                              data.schoolProgress[school.id] ?? 0;
                          final accentColor = switch (school.name) {
                            'Elemental Arts' => AppColors.elementalFlame,
                            'Arcane Runes' => AppColors.arcaneRune,
                            'Mystic Logic' => AppColors.mysticLogic,
                            _ => AppColors.goldPrimary,
                          };

                          return SchoolCard(
                            title: school.name,
                            description: school.description,
                            iconEmoji: school.icon,
                            completedLessons: completed,
                            totalLessons: 3,
                            accentColor: accentColor,
                            onTap: () => _onSchoolTapped(school),
                          );
                        }).toList();

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: schoolWidgets
                                .map((widget) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6),
                                        child: widget,
                                      ),
                                    ))
                                .toList(),
                          );
                        }

                        return Column(
                          children: schoolWidgets
                              .map((widget) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: widget,
                                  ))
                              .toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // 5. Navigation Action: Open Spellbook
                    MagicButton(
                      label: 'OPEN SPELLBOOK',
                      icon: Icons.menu_book_rounded,
                      variant: MagicButtonVariant.arcaneOutline,
                      height: 50,
                      onPressed: _openSpellbook,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardData {
  final UserStats stats;
  final Map<String, int> schoolProgress;
  final List<School> schools;
  final Lesson? nextLesson;

  const _DashboardData({
    required this.stats,
    required this.schoolProgress,
    required this.schools,
    required this.nextLesson,
  });
}
