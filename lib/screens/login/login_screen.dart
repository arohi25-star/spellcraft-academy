import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/magic_background.dart';
import '../../widgets/magic_button.dart';

/// Screen 2 — Login Screen (PRD Section 8)
/// Handles Google OAuth sign-in via Supabase and provides apprentice greeting.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.signInWithGoogle();
      if (mounted) {
        // If still mounted on login screen, pop back to let AuthGate render Dashboard
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'The magical archives could not verify your seal. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MagicBackground(
        maxContentWidth: 460,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.goldLight),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back to Gates',
                ),
              ),
              const SizedBox(height: 16),
              GlassPanel(
                borderColor: AppColors.goldDark.withValues(alpha: 0.5),
                glowColor: AppColors.goldGlow,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.violetSoft.withValues(alpha: 0.6),
                        border: Border.all(color: AppColors.violetGlow, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33A370F7),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 32,
                          color: AppColors.goldLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome, Apprentice',
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 22,
                        color: AppColors.textGold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter SpellCraft Academy',
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Authenticate with your Google seal to awaken your spellbook and track arcane progress.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 16, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    MagicButton(
                      label: 'Continue with Google',
                      icon: Icons.login_rounded,
                      isLoading: _isLoading,
                      onPressed: _handleGoogleLogin,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
