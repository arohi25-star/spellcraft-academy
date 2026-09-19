import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/app_user.dart';
import '../../models/school.dart';
import '../../services/database_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/magic_background.dart';
import '../../widgets/magic_loading_indicator.dart';
import '../../widgets/school_card.dart';
import '../lessons/lesson_selection_screen.dart';

/// Screen 4 — School Selection Screen (PRD Section 10)
/// Displays all 3 magical schools with real-time completion progress from Supabase.
/// Selecting a school navigates to its LessonSelectionScreen.
class SchoolSelectionScreen extends StatefulWidget {
  final AppUser user;

  const SchoolSelectionScreen({super.key, required this.user});

  @override
  State<SchoolSelectionScreen> createState() => _SchoolSelectionScreenState();
}

class _SchoolSelectionScreenState extends State<SchoolSelectionScreen> {
  late Future<_SchoolScreenData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_SchoolScreenData> _loadData() async {
    final results = await Future.wait([
      DatabaseService.instance.getSchools(),
      ProgressService.instance.getCompletedLessonsBySchool(widget.user.id),
    ]);

    return _SchoolScreenData(
      schools: results[0] as List<School>,
      schoolProgress: results[1] as Map<String, int>,
    );
  }

  void _openSchool(School school) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MagicBackground(
        maxContentWidth: 840,
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
                  tooltip: 'Return to Academy Hub',
                ),
              ),
              const SizedBox(height: 8),

              // Title & Atmosphere Header
              Text(
                'MAGICAL SCHOOLS',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 24,
                  color: AppColors.textGold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a discipline of magic to embark on curriculum lessons and unlock ancient spells.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Schools List / Grid
              Expanded(
                child: FutureBuilder<_SchoolScreenData>(
                  future: _dataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: MagicLoadingIndicator(
                          message: 'Opening Academy halls...',
                        ),
                      );
                    }

                    final data = snapshot.data;
                    final schools = data?.schools ?? [];
                    final progress = data?.schoolProgress ?? {};

                    if (schools.isEmpty) {
                      return Center(
                        child: Text(
                          'No schools found in the Academy archives.',
                          style: AppTypography.bodyMedium,
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final bool isWide = constraints.maxWidth > 680;

                          final cards = schools.map((school) {
                            final completed = progress[school.id] ?? 0;
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
                              onTap: () => _openSchool(school),
                            );
                          }).toList();

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: cards
                                  .map((card) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: card,
                                        ),
                                      ))
                                  .toList(),
                            );
                          }

                          return Column(
                            children: cards
                                .map((card) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: card,
                                    ))
                                .toList(),
                          );
                        },
                      ),
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

class _SchoolScreenData {
  final List<School> schools;
  final Map<String, int> schoolProgress;

  const _SchoolScreenData({
    required this.schools,
    required this.schoolProgress,
  });
}
