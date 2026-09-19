import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/spell.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/magic_background.dart';
import '../../widgets/magic_button.dart';

/// Screen 10 — Spell Detail Screen (PRD Section 17)
/// Displays complete grimoire record for an unlocked spell:
/// - Spell icon
/// - Spell name
/// - Lore Description
/// - Magical School
/// - Date Unlocked
/// - Mastery Level
/// - XP Earned
class SpellDetailScreen extends StatelessWidget {
  final Spell spell;

  const SpellDetailScreen({super.key, required this.spell});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Ancient Era';
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final Color schoolAccent = switch (spell.schoolName) {
      'Elemental Arts' => AppColors.elementalFlame,
      'Arcane Runes' => AppColors.arcaneRune,
      'Mystic Logic' => AppColors.mysticLogic,
      _ => AppColors.goldPrimary,
    };

    return Scaffold(
      body: MagicBackground(
        maxContentWidth: 640,
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
                  tooltip: 'Return to Spellbook',
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Spell Orb & Identity Card
                      GlassPanel(
                        padding: const EdgeInsets.all(28),
                        borderColor: schoolAccent.withValues(alpha: 0.5),
                        glowColor: schoolAccent.withValues(alpha: 0.15),
                        child: Column(
                          children: [
                            // Glowing Spell Orb
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.cardSurface,
                                border: Border.all(
                                  color: schoolAccent,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: schoolAccent.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  spell.icon,
                                  style: const TextStyle(fontSize: 46),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Spell Name
                            Text(
                              spell.name.toUpperCase(),
                              style: AppTypography.displayMedium.copyWith(
                                fontSize: 26,
                                color: AppColors.textPrimary,
                                letterSpacing: 2.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // School Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: schoolAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: schoolAccent.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                spell.schoolName.toUpperCase(),
                                style: AppTypography.label.copyWith(
                                  color: schoolAccent,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Lore Description
                            Text(
                              spell.description,
                              style: AppTypography.bodyMedium.copyWith(
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Grimoire Metadata Stats Card
                      GlassPanel(
                        padding: const EdgeInsets.all(22),
                        borderColor: AppColors.goldLight.withValues(alpha: 0.3),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              icon: Icons.military_tech_rounded,
                              iconColor: AppColors.goldLight,
                              label: 'Mastery',
                              value: spell.masteryLevel,
                              valueColor: AppColors.textGold,
                            ),
                            const Divider(
                              color: AppColors.surfaceGlassBorder,
                              height: 24,
                            ),
                            _buildDetailRow(
                              icon: Icons.auto_awesome,
                              iconColor: AppColors.cyanMagic,
                              label: 'XP Earned',
                              value: '+${spell.xpEarned} XP',
                              valueColor: AppColors.cyanMagic,
                            ),
                            const Divider(
                              color: AppColors.surfaceGlassBorder,
                              height: 24,
                            ),
                            _buildDetailRow(
                              icon: Icons.calendar_today_rounded,
                              iconColor: AppColors.violetGlow,
                              label: 'Unlocked',
                              value: _formatDate(spell.unlockedAt),
                              valueColor: AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              MagicButton(
                label: 'RETURN TO SPELLBOOK',
                icon: Icons.menu_book_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
