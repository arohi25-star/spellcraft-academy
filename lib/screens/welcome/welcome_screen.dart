import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/magic_background.dart';
import '../../widgets/magic_button.dart';
import '../login/login_screen.dart';

/// Screen 1 — Welcome Screen (PRD Section 7)
/// Introduces SpellCraft Academy with a deep fantasy atmosphere,
/// subtle entrance animations, an arcane academy emblem, and primary CTA.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _emblemFade;
  late final Animation<Offset> _emblemSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Staggered smooth entrance curves
    _emblemFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _emblemSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    ));

    _titleFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
    ));

    _subtitleFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
    ));

    _buttonFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _enterAcademy() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: MagicBackground(
        maxContentWidth: 720,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24.0 : 48.0,
                vertical: isSmallScreen ? 20.0 : 32.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(
                      0.0, constraints.maxHeight - (isSmallScreen ? 40.0 : 64.0)),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // 1. Arcane Academy Emblem / Seal
              SlideTransition(
                position: _emblemSlide,
                child: FadeTransition(
                  opacity: _emblemFade,
                  child: _AcademyEmblem(size: isSmallScreen ? 110 : 130),
                ),
              ),

              const SizedBox(height: 32),

              // 2. Large SPELLCRAFT ACADEMY Title
              SlideTransition(
                position: _titleSlide,
                child: FadeTransition(
                  opacity: _titleFade,
                  child: Column(
                    children: [
                      Text(
                        'SPELLCRAFT',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: isSmallScreen ? 34 : 48,
                          letterSpacing: 4.0,
                          color: AppColors.textGold,
                          shadows: const [
                            Shadow(
                              color: AppColors.goldGlow,
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ACADEMY',
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: isSmallScreen ? 24 : 32,
                          letterSpacing: 8.0,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Decorative Arcane Divider
              SlideTransition(
                position: _titleSlide,
                child: FadeTransition(
                  opacity: _titleFade,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: isSmallScreen ? 40 : 60,
                        height: 1,
                        color: AppColors.goldDark.withValues(alpha: 0.4),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                      Container(
                        width: isSmallScreen ? 40 : 60,
                        height: 1,
                        color: AppColors.goldDark.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 3. Subtitle: "Master the Arcane. Unlock Your Magic."
              SlideTransition(
                position: _subtitleSlide,
                child: FadeTransition(
                  opacity: _subtitleFade,
                  child: Column(
                    children: [
                      Text(
                        'Master the Arcane.',
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlock Your Magic.',
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: AppColors.violetGlow,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // 4. Primary CTA: "ENTER THE ACADEMY"
              SlideTransition(
                position: _buttonSlide,
                child: FadeTransition(
                  opacity: _buttonFade,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 320,
                      minWidth: 260,
                    ),
                    child: MagicButton(
                      label: 'ENTER THE ACADEMY',
                      icon: Icons.key_rounded,
                      height: 54,
                      onPressed: _enterAcademy,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Subtle lore footer
              SlideTransition(
                position: _buttonSlide,
                child: FadeTransition(
                  opacity: _buttonFade,
                  child: Text(
                    'Puzzles • Runes • Arcane Wisdom',
                    style: AppTypography.label.copyWith(
                      color: AppColors.textMuted.withValues(alpha: 0.7),
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  },
),
),
);
  }
}

/// A glowing circular arcane academy seal with layered concentric rings,
/// mystical stars, and a spellbook / wand core.
class _AcademyEmblem extends StatelessWidget {
  final double size;

  const _AcademyEmblem({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0x33A370F7),
            Color(0x11161B3B),
            Colors.transparent,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33E5B869),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative gold ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldLight.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
          ),
          // Inner dashed arcane orbit
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: size * 0.82,
              height: size * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.violetGlow.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
            ),
          ),
          // Inner core surface
          Container(
            width: size * 0.66,
            height: size * 0.66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardSurface.withValues(alpha: 0.9),
              border: Border.all(
                color: AppColors.goldPrimary,
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_stories_rounded,
                size: 38,
                color: AppColors.goldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
