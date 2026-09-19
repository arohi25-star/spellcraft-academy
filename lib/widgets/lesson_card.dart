import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'glass_panel.dart';

/// Reusable LessonCard widget displaying lesson details, unlockable spell preview,
/// and distinct states (Completed ✓, Unlocked / Current, or Locked 🔒).
class LessonCard extends StatefulWidget {
  final int lessonOrder;
  final String title;
  final String description;
  final String spellName;
  final String spellIcon;
  final String spellDescription;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.lessonOrder,
    required this.title,
    required this.description,
    required this.spellName,
    required this.spellIcon,
    required this.spellDescription,
    this.isCompleted = false,
    this.isLocked = false,
    this.onTap,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isPlayable = !widget.isLocked;

    final Color borderColor = widget.isLocked
        ? AppColors.locked
        : (widget.isCompleted
            ? AppColors.success.withValues(alpha: 0.5)
            : (_isHovered ? AppColors.goldLight : AppColors.goldDark));

    final Color? glowColor = widget.isLocked
        ? null
        : (widget.isCompleted
            ? AppColors.success.withValues(alpha: 0.15)
            : (_isHovered ? AppColors.goldGlow : null));

    return MouseRegion(
      cursor: isPlayable ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered && isPlayable ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: GlassPanel(
          onTap: isPlayable ? widget.onTap : null,
          borderColor: borderColor,
          glowColor: glowColor,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // State Icon / Badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isLocked
                          ? AppColors.backgroundSecondary
                          : (widget.isCompleted
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.violetSoft.withValues(alpha: 0.6)),
                      border: Border.all(
                        color: widget.isLocked
                            ? AppColors.locked
                            : (widget.isCompleted
                                ? AppColors.success
                                : AppColors.violetGlow),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: widget.isLocked
                          ? const Icon(Icons.lock_rounded,
                              size: 20, color: AppColors.lockedText)
                          : (widget.isCompleted
                              ? const Icon(Icons.check_rounded,
                                  size: 22, color: AppColors.success)
                              : Text(
                                  '0${widget.lessonOrder}',
                                  style: AppTypography.displaySmall.copyWith(
                                    fontSize: 16,
                                    color: AppColors.goldLight,
                                  ),
                                )),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Lesson Title & Order
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LESSON 0${widget.lessonOrder}',
                          style: AppTypography.label.copyWith(
                            color: widget.isLocked
                                ? AppColors.lockedText
                                : (widget.isCompleted
                                    ? AppColors.success
                                    : AppColors.goldLight),
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.title.toUpperCase(),
                          style: AppTypography.displaySmall.copyWith(
                            fontSize: 17,
                            color: widget.isLocked
                                ? AppColors.lockedText
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Trailing Status Tag
                  if (widget.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.success, width: 1),
                      ),
                      child: Text(
                        'MASTERED',
                        style: AppTypography.label.copyWith(
                          fontSize: 9,
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else if (widget.isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.locked.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.locked, width: 1),
                      ),
                      child: Text(
                        'LOCKED',
                        style: AppTypography.label.copyWith(
                          fontSize: 9,
                          color: AppColors.lockedText,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: AppColors.goldPrimary, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_arrow_rounded,
                              size: 14, color: AppColors.goldLight),
                          const SizedBox(width: 2),
                          Text(
                            'UNLOCKED',
                            style: AppTypography.label.copyWith(
                              fontSize: 9,
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                widget.description,
                style: AppTypography.bodySmall.copyWith(
                  color: widget.isLocked
                      ? AppColors.lockedText
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              // Spell Reward Box
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isLocked
                        ? AppColors.locked.withValues(alpha: 0.4)
                        : AppColors.surfaceGlassBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.spellIcon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Unlocks: ',
                            style: AppTypography.label.copyWith(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              widget.spellName,
                              style: AppTypography.label.copyWith(
                                fontSize: 11,
                                color: widget.isLocked
                                    ? AppColors.lockedText
                                    : AppColors.goldLight,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+100 XP',
                      style: AppTypography.label.copyWith(
                        fontSize: 10,
                        color: widget.isLocked
                            ? AppColors.lockedText
                            : AppColors.cyanMagic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
