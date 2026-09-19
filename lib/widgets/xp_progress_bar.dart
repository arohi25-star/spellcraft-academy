import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// Reusable fantasy XP progress bar with level badge, gold glowing fill,
/// and smooth animation.
class XPProgressBar extends StatelessWidget {
  final int currentXp;
  final int maxXp;
  final int currentLevel;
  final bool showLevelBadge;
  final bool showValuesText;
  final double height;

  const XPProgressBar({
    super.key,
    required this.currentXp,
    required this.maxXp,
    this.currentLevel = 1,
    this.showLevelBadge = true,
    this.showValuesText = true,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = (maxXp > 0) ? (currentXp / maxXp).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLevelBadge || showValuesText)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showLevelBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldDark, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.goldPrimary),
                        const SizedBox(width: 4),
                        Text(
                          'LEVEL $currentLevel',
                          style: AppTypography.label.copyWith(
                            color: AppColors.goldLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (showValuesText)
                  Text(
                    '$currentXp / $maxXp XP',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: AppColors.surfaceGlassBorder, width: 1),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * ratio,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height / 2),
                      gradient: AppColors.goldButtonGradient,
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.goldGlow,
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
