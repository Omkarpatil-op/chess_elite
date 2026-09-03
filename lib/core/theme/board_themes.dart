import 'package:flutter/material.dart';

enum BoardThemeType {
  classicWood('Classic Walnut', 'Warm walnut veneer & maple wood tone'),
  emeraldTournament('Emerald Championship', 'Official tournament green & ivory porcelain'),
  midnightSlate('Midnight Obsidian', 'Dark titanium slate & cool silver alloy'),
  royalSapphire('Royal Azure', 'Deep navy sapphire & bone cream'),
  monochromeStudio('Monochrome Studio', 'High-contrast matte graphite & studio white'),
  champagneVelvet('Champagne Espresso', 'Warm espresso wood & velvet champagne');

  final String label;
  final String description;

  const BoardThemeType(this.label, this.description);
}

class BoardThemeColors {
  final BoardThemeType type;
  final Color lightSquare;
  final Color darkSquare;
  final Color selectedHighlight;
  final Color lastMoveHighlight;
  final Color checkHighlight;
  final Color legalDotColor;
  final Color coordinateColorLight;
  final Color coordinateColorDark;

  const BoardThemeColors({
    required this.type,
    required this.lightSquare,
    required this.darkSquare,
    required this.selectedHighlight,
    required this.lastMoveHighlight,
    required this.checkHighlight,
    required this.legalDotColor,
    required this.coordinateColorLight,
    required this.coordinateColorDark,
  });

  static BoardThemeColors get(BoardThemeType type) {
    switch (type) {
      case BoardThemeType.classicWood:
        return const BoardThemeColors(
          type: BoardThemeType.classicWood,
          lightSquare: Color(0xFFF0D9B5),
          darkSquare: Color(0xFFB58863),
          selectedHighlight: Color(0x9958A6FF),
          lastMoveHighlight: Color(0x66D4AF37),
          checkHighlight: Color(0xDDEF4444),
          legalDotColor: Color(0x775D4037),
          coordinateColorLight: Color(0xFFB58863),
          coordinateColorDark: Color(0xFFF0D9B5),
        );
      case BoardThemeType.emeraldTournament:
        return const BoardThemeColors(
          type: BoardThemeType.emeraldTournament,
          lightSquare: Color(0xFFFFFFDD),
          darkSquare: Color(0xFF709552),
          selectedHighlight: Color(0x9958A6FF),
          lastMoveHighlight: Color(0x77F59E0B),
          checkHighlight: Color(0xDDEF4444),
          legalDotColor: Color(0x773E5033),
          coordinateColorLight: Color(0xFF709552),
          coordinateColorDark: Color(0xFFFFFFDD),
        );
      case BoardThemeType.midnightSlate:
        return const BoardThemeColors(
          type: BoardThemeType.midnightSlate,
          lightSquare: Color(0xFFD6E0EA),
          darkSquare: Color(0xFF485E75),
          selectedHighlight: Color(0x9938BDF8),
          lastMoveHighlight: Color(0x6638BDF8),
          checkHighlight: Color(0xDDEF4444),
          legalDotColor: Color(0x77233242),
          coordinateColorLight: Color(0xFF485E75),
          coordinateColorDark: Color(0xFFD6E0EA),
        );
      case BoardThemeType.royalSapphire:
        return const BoardThemeColors(
          type: BoardThemeType.royalSapphire,
          lightSquare: Color(0xFFE2EDF8),
          darkSquare: Color(0xFF3B6790),
          selectedHighlight: Color(0x99D4AF37),
          lastMoveHighlight: Color(0x6660A5FA),
          checkHighlight: Color(0xDDEF4444),
          legalDotColor: Color(0x771B3852),
          coordinateColorLight: Color(0xFF3B6790),
          coordinateColorDark: Color(0xFFE2EDF8),
        );
      case BoardThemeType.monochromeStudio:
        return const BoardThemeColors(
          type: BoardThemeType.monochromeStudio,
          lightSquare: Color(0xFFE5E7EB),
          darkSquare: Color(0xFF4B5563),
          selectedHighlight: Color(0x99D4AF37),
          lastMoveHighlight: Color(0x669CA3AF),
          checkHighlight: Color(0xDDEF4444),
          legalDotColor: Color(0x771F2937),
          coordinateColorLight: Color(0xFF4B5563),
          coordinateColorDark: Color(0xFFE5E7EB),
        );
      case BoardThemeType.champagneVelvet:
        return const BoardThemeColors(
          type: BoardThemeType.champagneVelvet,
          lightSquare: Color(0xFFF5ECE1),
          darkSquare: Color(0xFF86634B),
          selectedHighlight: Color(0x9938BDF8),
          lastMoveHighlight: Color(0x66D4AF37),
          checkHighlight: Color(0xDDEF4444),
          legalDotColor: Color(0x77422E21),
          coordinateColorLight: Color(0xFF86634B),
          coordinateColorDark: Color(0xFFF5ECE1),
        );
    }
  }
}
