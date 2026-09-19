import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// Reusable magical loading indicator featuring rotating arcane rings,
/// gentle pulse, and customizable academy lore status text.
class MagicLoadingIndicator extends StatefulWidget {
  final String message;
  final double size;

  const MagicLoadingIndicator({
    super.key,
    this.message = 'Opening the academy...',
    this.size = 56,
  });

  @override
  State<MagicLoadingIndicator> createState() => _MagicLoadingIndicatorState();
}

class _MagicLoadingIndicatorState extends State<MagicLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer subtle violet orbit
                  Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        value: 0.7,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.violetGlow,
                        ),
                      ),
                    ),
                  ),
                  // Inner reverse gold orbit
                  Transform.rotate(
                    angle: -_controller.value * 2 * math.pi,
                    child: SizedBox(
                      width: widget.size * 0.65,
                      height: widget.size * 0.65,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        value: 0.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.goldPrimary,
                        ),
                      ),
                    ),
                  ),
                  // Center glowing spark
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: AppColors.goldLight,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            widget.message,
            style: AppTypography.displaySmall.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
