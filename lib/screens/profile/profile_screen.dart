import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/app_user.dart';
import '../../models/user_stats.dart';
import '../../services/auth_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/magic_background.dart';
import '../../widgets/magic_button.dart';
import '../../widgets/magic_loading_indicator.dart';

/// Screen 11 — Profile Screen (PRD Section 18)
///
/// Displays:
/// - Google profile image (with fallback avatar and ornate gold ring)
/// - Apprentice Display Name
/// - Email Address
/// - Current Level
/// - Total XP
/// - Lessons Completed
/// - Spells Unlocked
/// - [ LOG OUT ] action utilizing AuthService
class ProfileScreen extends StatefulWidget {
  final AppUser user;
  final UserStats? stats;

  const ProfileScreen({
    super.key,
    required this.user,
    this.stats,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    if (widget.stats != null) {
      _statsFuture = Future.value(widget.stats);
    } else {
      _statsFuture = ProgressService.instance.getUserStats(widget.user.id);
    }
  }

  Future<void> _handleLogout() async {
    // Return to root route so AuthGate handles unauthenticated state cleanly
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    await AuthService.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MagicBackground(
        maxContentWidth: 600,
        child: FutureBuilder<UserStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                widget.stats == null) {
              return const Center(
                child: MagicLoadingIndicator(
                  message: 'Opening your grimoire archives...',
                ),
              );
            }

            final stats = snapshot.data ??
                widget.stats ??
                UserStats(
                  userId: widget.user.id,
                  totalXp: 0,
                  currentLevel: 1,
                  lessonsCompleted: 0,
                  spellsUnlocked: 0,
                );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top navigation / Return to Academy
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.goldLight,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Return to Academy',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Header Title
                  Center(
                    child: Text(
                      'APPRENTICE PROFILE',
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 18,
                        color: AppColors.goldLight,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Profile Card
                  GlassPanel(
                    borderColor: AppColors.goldDark.withValues(alpha: 0.5),
                    glowColor: AppColors.goldGlow,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Google Profile Avatar with Gold Halo Ring
                        Container(
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.goldLight,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldGlow.withValues(alpha: 0.5),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.violetSoft,
                            backgroundImage: (widget.user.avatarUrl != null &&
                                    widget.user.avatarUrl!.isNotEmpty)
                                ? NetworkImage(widget.user.avatarUrl!)
                                : null,
                            onBackgroundImageError:
                                (widget.user.avatarUrl != null &&
                                        widget.user.avatarUrl!.isNotEmpty)
                                    ? (_, _) {}
                                    : null,
                            child: (widget.user.avatarUrl == null ||
                                    widget.user.avatarUrl!.isEmpty)
                                ? Text(
                                    widget.user.displayName.isNotEmpty
                                        ? widget.user.displayName[0]
                                            .toUpperCase()
                                        : 'A',
                                    style: AppTypography.displayLarge.copyWith(
                                      color: AppColors.goldLight,
                                      fontSize: 34,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Display Name
                        Text(
                          widget.user.displayName.isNotEmpty
                              ? widget.user.displayName
                              : 'Apprentice Mage',
                          style: AppTypography.displaySmall.copyWith(
                            fontSize: 20,
                            color: AppColors.textGold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),

                        // Email
                        Text(
                          widget.user.email,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),

                        // Current Level Arcane Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.goldDark,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldGlow.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: AppColors.goldLight,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CURRENT LEVEL: ${stats.currentLevel}',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.goldLight,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Academy Stats Breakdown Grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'TOTAL XP',
                          value: '${stats.totalXp}',
                          icon: Icons.bolt_rounded,
                          accentColor: AppColors.goldPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'LESSONS COMPLETED',
                          value: '${stats.lessonsCompleted} / 9',
                          icon: Icons.check_circle_outline_rounded,
                          accentColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'SPELLS UNLOCKED',
                          value: '${stats.spellsUnlocked} / 9',
                          icon: Icons.menu_book_rounded,
                          accentColor: AppColors.violetGlow,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // [ LOG OUT ] Button
                  MagicButton(
                    label: 'LOG OUT',
                    icon: Icons.logout_rounded,
                    variant: MagicButtonVariant.danger,
                    height: 48,
                    onPressed: _handleLogout,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Column(
        children: [
          Icon(icon, size: 22, color: accentColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.statNumber.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.label.copyWith(
              fontSize: 9,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
