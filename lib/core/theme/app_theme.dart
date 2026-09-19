import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Global application theme for SpellCraft Academy.
/// Establishes the dark fantasy academy atmosphere with warm gold highlights.
abstract final class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.goldPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.goldPrimary,
        onPrimary: Color(0xFF1B150A),
        secondary: AppColors.violetGlow,
        onSecondary: Colors.white,
        surface: AppColors.cardSurface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineMedium: AppTypography.displaySmall,
        titleLarge: AppTypography.displaySmall.copyWith(fontSize: 18),
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.button,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.displaySmall,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.surfaceGlassBorder,
            width: 1,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceGlassBorder,
        thickness: 1,
      ),
    );
  }
}
