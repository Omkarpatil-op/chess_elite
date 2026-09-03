import 'package:flutter/material.dart';

class AppColors {
  // --- Dark Luxury Palette ---
  static const Color darkBackground = Color(0xFF080B11);
  static const Color darkSurface = Color(0xFF111722);
  static const Color darkSurfaceElevated = Color(0xFF1A2232);
  static const Color darkSurfaceInteractive = Color(0xFF232D42);
  static const Color darkBorder = Color(0xFF253147);
  static const Color darkBorderSubtle = Color(0xFF182233);
  static const Color darkDivider = Color(0xFF1A2334);

  // --- Light Luxury Palette ---
  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFEEF2F8);
  static const Color lightSurfaceInteractive = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0xFFDCE2EE);
  static const Color lightBorderSubtle = Color(0xFFEAEFF8);
  static const Color lightDivider = Color(0xFFE5EAF3);

  // --- Brand Accents & Luxury Gold ---
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFDF7D);
  static const Color goldDark = Color(0xFF9E7D1A);
  static const Color goldGlow = Color(0xFFF59E0B);
  static const Color goldMuted = Color(0xFF786221);

  // --- Semantic Colors ---
  static const Color emeraldSuccess = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF047857);
  static const Color rubyError = Color(0xFFEF4444);
  static const Color rubyDark = Color(0xFFB91C1C);
  static const Color sapphireInfo = Color(0xFF3B82F6);
  static const Color sapphireDark = Color(0xFF1D4ED8);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color amethystPurple = Color(0xFF8B5CF6);

  // --- Chess Board Interactive Highlights ---
  static const Color selectedSquare = Color(0x803B82F6);
  static const Color lastMoveHighlight = Color(0x60F59E0B);
  static const Color legalMoveDot = Color(0x883B82F6);
  static const Color captureRing = Color(0xA0EF4444);
  static const Color checkGlow = Color(0xCCEF4444);
  static const Color checkmateGlow = Color(0xEE991B1B);

  // --- Typography Hierarchy ---
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // --- Gradients ---
  static const LinearGradient goldLuxuryGradient = LinearGradient(
    colors: [Color(0xFFFFE082), Color(0xFFD4AF37), Color(0xFFA67C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF141B28), Color(0xFF0D121B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldSurfaceGradient = LinearGradient(
    colors: [Color(0x2BD4AF37), Color(0x0DD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient podiumGoldGradient = LinearGradient(
    colors: [Color(0xFFFFE57F), Color(0xFFD4AF37)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient podiumSilverGradient = LinearGradient(
    colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient podiumBronzeGradient = LinearGradient(
    colors: [Color(0xFFE0A96D), Color(0xFFB87333)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
