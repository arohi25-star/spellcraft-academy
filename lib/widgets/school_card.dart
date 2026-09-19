import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'glass_panel.dart';

/// Reusable SchoolCard widget representing one of the Academy's magical schools.
/// Displays school icon, name, description, completion progress, and locked state.
class SchoolCard extends StatefulWidget {
  final String title;
  final String description;
  final String iconEmoji;
  final int completedLessons;
  final int totalLessons;
  final bool isLocked;
  final Color? accentColor;
  final VoidCallback? onTap;

  const SchoolCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.completedLessons = 0,
    this.totalLessons = 3,
    this.isLocked = false,
    this.accentColor,
    this.onTap,
  });

  @override
  State<SchoolCard> createState() => _SchoolCardState();
}

class _SchoolCardState extends State<SchoolCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color themeAccent = widget.accentColor ?? AppColors.goldPrimary;
    final bool isComplete = widget.completedLessons >= widget.totalLessons && widget.totalLessons > 0;
    final double progressRatio = widget.totalLessons > 0
        ? (widget.completedLessons / widget.totalLessons).clamp(0.0, 1.0)
        : 0.0;

    return MouseRegion(
      cursor: widget.isLocked
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered && !widget.isLocked ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: GlassPanel(
          onTap: widget.isLocked ? null : widget.onTap,
          borderColor: widget.isLocked
              ? AppColors.locked
              : (_isHovered ? themeAccent : AppColors.surfaceGlassBorder),
          glowColor: _isHovered && !widget.isLocked
              ? themeAccent.withValues(alpha: 0.25)
              : null,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.isLocked
                          ? AppColors.backgroundSecondary
                          : themeAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isLocked
                            ? AppColors.locked
                            : themeAccent.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: widget.isLocked
                          ? const Icon(Icons.lock_outline_rounded,
                              size: 22, color: AppColors.lockedText)
                          : Text(
                              widget.iconEmoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title.toUpperCase(),
                          style: AppTypography.displaySmall.copyWith(
                            fontSize: 16,
                            color: widget.isLocked
                                ? AppColors.lockedText
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isLocked
                              ? 'Locked Apprentice Path'
                              : '${widget.completedLessons} / ${widget.totalLessons} Lessons',
                          style: AppTypography.bodySmall.copyWith(
                            color: widget.isLocked
                                ? AppColors.lockedText
                                : (isComplete ? AppColors.success : AppColors.textGold),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isComplete && !widget.isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            'MASTERED',
                            style: AppTypography.label.copyWith(
                              fontSize: 10,
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: widget.isLocked
                      ? AppColors.lockedText
                      : AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Mini progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 6,
                  color: AppColors.backgroundSecondary,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressRatio,
                    child: Container(
                      color: widget.isLocked ? AppColors.locked : themeAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
