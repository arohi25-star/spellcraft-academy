import 'package:flutter/material.dart';

/// Fantasy color palette for SpellCraft Academy.
/// Follows PRD guidelines:
/// - Dark navy/purple atmosphere
/// - Warm gold accents
/// - Soft violet magical glow
/// - Subtle cyan magical glow
/// - Avoids excessive gradients and visual clutter
abstract final class AppColors {
  // Atmosphere & Backgrounds
  static const Color background = Color(0xFF090C19); // Deepest midnight navy
  static const Color backgroundSecondary = Color(0xFF0F142A); // Elevated navy surface
  static const Color cardSurface = Color(0xFF141936); // Base card surface
  static const Color surfaceGlass = Color(0xCC151B38); // Translucent glass backdrop
  static const Color surfaceGlassBorder = Color(0x33A370F7); // Subtle violet edge

  // Warm Gold Accents
  static const Color goldPrimary = Color(0xFFE5B869);
  static const Color goldLight = Color(0xFFF7DCA3);
  static const Color goldDark = Color(0xFF9E7736);
  static const Color goldGlow = Color(0x4DE5B869);

  // Magical Glows & Accents
  static const Color violetGlow = Color(0xFFA370F7);
  static const Color violetSoft = Color(0xFF2A204D);
  static const Color violetBorder = Color(0x40A370F7);
  static const Color cyanMagic = Color(0xFF56CCF2);
  static const Color cyanMagicSoft = Color(0x3356CCF2);

  // School Specific Thematic Tints
  static const Color elementalFlame = Color(0xFFFF6B6B);
  static const Color elementalWater = Color(0xFF4DABF7);
  static const Color arcaneRune = Color(0xFFB197FC);
  static const Color mysticLogic = Color(0xFF63E6BE);

  // Status & Feedback
  static const Color success = Color(0xFF51CF66);
  static const Color error = Color(0xFFFF6B6B);
  static const Color locked = Color(0xFF4B556F);
  static const Color lockedText = Color(0xFF7E87A4);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFF5F6FC);
  static const Color textSecondary = Color(0xFFB8BFD8);
  static const Color textMuted = Color(0xFF7B84A6);
  static const Color textGold = Color(0xFFF7DCA3);

  // Subtle Linear Gradients
  static const LinearGradient magicBackdropGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF121733),
      Color(0xFF090C19),
    ],
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF5D695),
      Color(0xFFD49E48),
    ],
  );

  static const LinearGradient arcaneCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x331C244D),
      Color(0x22131838),
    ],
  );
}
