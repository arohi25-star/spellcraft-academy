import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Reusable magical background providing the dark navy/purple atmosphere,
/// subtle ambient glowing orbs, and gentle floating particle accents.
class MagicBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;
  final double? maxContentWidth;

  const MagicBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.maxContentWidth = 900,
  });

  @override
  State<MagicBackground> createState() => _MagicBackgroundState();
}

class _MagicBackgroundState extends State<MagicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _particleController;
  final List<_MagicalParticle> _particles = [];
  final math.Random _random = math.Random(42);

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // 16 gentle ambient particles for soft fantasy atmosphere without lag
    for (int i = 0; i < 16; i++) {
      _particles.add(
        _MagicalParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 2.8 + 1.2,
          speed: _random.nextDouble() * 0.4 + 0.15,
          color: i % 2 == 0
              ? AppColors.goldPrimary.withValues(alpha: 0.35)
              : AppColors.violetGlow.withValues(alpha: 0.3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F142D), // Deep arcane indigo
            Color(0xFF090C19), // Midnight abyss
            Color(0xFF060811),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Top subtle violet aura
          Positioned(
            top: -100,
            left: -80,
            child: IgnorePointer(
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.violetGlow.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom right subtle gold aura
          Positioned(
            bottom: -100,
            right: -80,
            child: IgnorePointer(
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.goldPrimary.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Subtle floating magical particles
          if (widget.showParticles)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ParticlePainter(
                        particles: _particles,
                        progress: _particleController.value,
                      ),
                    );
                  },
                ),
              ),
            ),

          // Responsive Centered Content Area
          SafeArea(
            child: Center(
              child: widget.maxContentWidth != null
                  ? ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: widget.maxContentWidth!),
                      child: widget.child,
                    )
                  : widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class _MagicalParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final Color color;

  _MagicalParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_MagicalParticle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final currentY = (p.y - (progress * p.speed)) % 1.0;
      final offset = Offset(p.x * size.width, currentY * size.height);
      paint.color = p.color;
      canvas.drawCircle(offset, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
