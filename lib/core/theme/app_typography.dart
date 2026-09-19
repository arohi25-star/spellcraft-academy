import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for SpellCraft Academy.
/// Follows PRD specifications:
/// - Display Font: Cinzel (Fantasy / Arcane display font)
/// - Body Font: Inter (Clean modern readable body font)
/// - Provides robust fallbacks for web & offline resilience
abstract final class AppTypography {
  static const List<String> _displayFallbacks = ['Georgia', 'Times New Roman', 'serif'];
  static const List<String> _bodyFallbacks = ['Segoe UI', 'Roboto', 'Helvetica Neue', 'sans-serif'];

  // Display Styles (Cinzel)
  static TextStyle displayLarge = GoogleFonts.cinzel(
    textStyle: const TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.0,
      color: AppColors.textPrimary,
      fontFamilyFallback: _displayFallbacks,
    ),
  );

  static TextStyle displayMedium = GoogleFonts.cinzel(
    textStyle: const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: AppColors.textPrimary,
      fontFamilyFallback: _displayFallbacks,
    ),
  );

  static TextStyle displaySmall = GoogleFonts.cinzel(
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: AppColors.textPrimary,
      fontFamilyFallback: _displayFallbacks,
    ),
  );

  static TextStyle displayGold = GoogleFonts.cinzel(
    textStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.8,
      color: AppColors.textGold,
      fontFamilyFallback: _displayFallbacks,
    ),
  );

  // Body Styles (Inter)
  static TextStyle bodyLarge = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textPrimary,
      fontFamilyFallback: _bodyFallbacks,
    ),
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.textSecondary,
      fontFamilyFallback: _bodyFallbacks,
    ),
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: AppColors.textMuted,
      fontFamilyFallback: _bodyFallbacks,
    ),
  );

  // Button & Interactive Labels
  static TextStyle button = GoogleFonts.cinzel(
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: Color(0xFF171306),
      fontFamilyFallback: _displayFallbacks,
    ),
  );

  static TextStyle buttonSecondary = GoogleFonts.cinzel(
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: AppColors.goldLight,
      fontFamilyFallback: _displayFallbacks,
    ),
  );

  // Stat / Rune Labels
  static TextStyle label = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
      color: AppColors.textMuted,
      fontFamilyFallback: _bodyFallbacks,
    ),
  );

  static TextStyle statNumber = GoogleFonts.cinzel(
    textStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textGold,
      fontFamilyFallback: _displayFallbacks,
    ),
  );
}
