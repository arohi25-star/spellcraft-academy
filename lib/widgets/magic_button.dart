import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

enum MagicButtonVariant {
  goldPrimary,
  arcaneOutline,
  danger,
}

/// A reusable fantasy-themed button with glowing accents, hover scaling,
/// and responsive feedback states.
class MagicButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final MagicButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const MagicButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = MagicButtonVariant.goldPrimary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 50,
  });

  @override
  State<MagicButton> createState() => _MagicButtonState();
}

class _MagicButtonState extends State<MagicButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    final BoxDecoration decoration = switch (widget.variant) {
      MagicButtonVariant.goldPrimary => BoxDecoration(
          gradient: isEnabled
              ? (_isHovered
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFF0C2), Color(0xFFE5B869)],
                    )
                  : AppColors.goldButtonGradient)
              : null,
          color: isEnabled ? null : AppColors.locked,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? (_isHovered ? const Color(0xFFFFF4D1) : AppColors.goldLight)
                : AppColors.lockedText,
            width: 1.2,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: _isHovered
                        ? const Color(0x66E5B869)
                        : const Color(0x33E5B869),
                    blurRadius: _isHovered ? 16 : 8,
                    spreadRadius: _isHovered ? 1 : 0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
      MagicButtonVariant.arcaneOutline => BoxDecoration(
          color: _isHovered ? const Color(0x2A7C4DFF) : const Color(0x147C4DFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? (_isHovered ? AppColors.violetGlow : AppColors.violetBorder)
                : AppColors.lockedText,
            width: 1.2,
          ),
          boxShadow: _isHovered && isEnabled
              ? const [
                  BoxShadow(
                    color: Color(0x33A370F7),
                    blurRadius: 14,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
      MagicButtonVariant.danger => BoxDecoration(
          color: _isHovered ? const Color(0x33FF6B6B) : const Color(0x1AFF6B6B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? AppColors.error : AppColors.lockedText,
            width: 1.2,
          ),
        ),
    };

    final TextStyle textStyle = switch (widget.variant) {
      MagicButtonVariant.goldPrimary => isEnabled
          ? AppTypography.button
          : AppTypography.button.copyWith(color: AppColors.lockedText),
      MagicButtonVariant.arcaneOutline => isEnabled
          ? AppTypography.buttonSecondary
          : AppTypography.buttonSecondary.copyWith(color: AppColors.lockedText),
      MagicButtonVariant.danger => AppTypography.buttonSecondary.copyWith(
          color: isEnabled ? AppColors.error : AppColors.lockedText,
        ),
    };

    final Color iconColor = switch (widget.variant) {
      MagicButtonVariant.goldPrimary =>
        isEnabled ? const Color(0xFF171306) : AppColors.lockedText,
      MagicButtonVariant.arcaneOutline =>
        isEnabled ? AppColors.violetGlow : AppColors.lockedText,
      MagicButtonVariant.danger =>
        isEnabled ? AppColors.error : AppColors.lockedText,
    };

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: widget.width,
        height: widget.height,
        curve: Curves.easeOut,
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isEnabled ? widget.onPressed : null,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.variant == MagicButtonVariant.goldPrimary
                              ? const Color(0xFF171306)
                              : AppColors.goldPrimary,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18, color: iconColor),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.label.toUpperCase(),
                              style: textStyle,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
