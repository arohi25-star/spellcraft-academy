import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'glass_panel.dart';

/// Reusable SpellCard representing a spell in the Academy's Spellbook.
/// Displays rune icon, spell name, mastery tier, or unlock requirement if locked.
class SpellCard extends StatefulWidget {
  final String spellName;
  final String schoolName;
  final String iconEmoji;
  final String masteryLevel;
  final bool isUnlocked;
  final String? unlockRequirement;
  final VoidCallback? onTap;

  const SpellCard({
    super.key,
    required this.spellName,
    required this.schoolName,
    required this.iconEmoji,
    this.masteryLevel = 'Beginner',
    this.isUnlocked = false,
    this.unlockRequirement,
    this.onTap,
  });

  @override
  State<SpellCard> createState() => _SpellCardState();
}

class _SpellCardState extends State<SpellCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? (widget.isUnlocked ? 1.02 : 1.01) : 1.0,
        duration: const Duration(milliseconds: 180),
        child: GlassPanel(
          onTap: widget.onTap,
          borderColor: widget.isUnlocked
              ? (_isHovered
                  ? AppColors.goldLight
                  : AppColors.goldDark.withValues(alpha: 0.4))
              : (_isHovered
                  ? AppColors.lockedText.withValues(alpha: 0.6)
                  : AppColors.locked),
          glowColor: _isHovered && widget.isUnlocked
              ? AppColors.goldGlow
              : null,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.isUnlocked
                      ? AppColors.goldPrimary.withValues(alpha: 0.12)
                      : AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isUnlocked
                        ? AppColors.goldPrimary.withValues(alpha: 0.4)
                        : AppColors.locked,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: widget.isUnlocked
                      ? Text(widget.iconEmoji,
                          style: const TextStyle(fontSize: 22))
                      : const Icon(Icons.lock_outline_rounded,
                          size: 20, color: AppColors.lockedText),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.spellName.toUpperCase(),
                            style: AppTypography.displaySmall.copyWith(
                              fontSize: 15,
                              color: widget.isUnlocked
                                  ? AppColors.textPrimary
                                  : AppColors.lockedText,
                            ),
                          ),
                        ),
                        if (widget.isUnlocked) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceGlassBorder,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.schoolName.toUpperCase(),
                              style: AppTypography.label.copyWith(
                                fontSize: 9,
                                color: AppColors.textGold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    if (widget.isUnlocked)
                      Row(
                        children: [
                          Text(
                            'Mastery: ',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            widget.masteryLevel,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        widget.unlockRequirement ?? 'Requires academy study',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.lockedText,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                widget.isUnlocked
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.lock_outline_rounded,
                size: 14,
                color: widget.isUnlocked
                    ? AppColors.goldLight
                    : AppColors.lockedText.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
