import 'package:flutter/material.dart';

enum BoardThemeType {
  classicWood('Classic Wood', 'Traditional warm walnut & maple veneer'),
  emeraldForest('Emerald Forest', 'Tournament green & ivory contrast'),
  midnightSlate('Midnight Slate', 'Cool titanium & deep oceanic slate'),
  royalSapphire('Royal Sapphire', 'Refined navy blue & porcelain cream'),
  monochromeOnyx('Monochrome Onyx', 'High-contrast studio black & white');

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

  const BoardThemeColors({
    required this.type,
    required this.lightSquare,
    required this.darkSquare,
    required this.selectedHighlight,
    required this.lastMoveHighlight,
    required this.checkHighlight,
    required this.legalDotColor,
  });

  static BoardThemeColors get(BoardThemeType type) {
    switch (type) {
      case BoardThemeType.classicWood:
        return const BoardThemeColors(
          type: BoardThemeType.classicWood,
          lightSquare: Color(0xFFF0D9B5),
          darkSquare: Color(0xFFB58863),
          selectedHighlight: Color(0x9958A6FF),
          lastMoveHighlight: Color(0x66D29922),
          checkHighlight: Color(0xCCF85149),
          legalDotColor: Color(0x884A5568),
        );
      case BoardThemeType.emeraldForest:
        return const BoardThemeColors(
          type: BoardThemeType.emeraldForest,
          lightSquare: Color(0xFFEEEED2),
          darkSquare: Color(0xFF769656),
          selectedHighlight: Color(0x9958A6FF),
          lastMoveHighlight: Color(0x66F7C04A),
          checkHighlight: Color(0xCCF85149),
          legalDotColor: Color(0x883E4A3D),
        );
      case BoardThemeType.midnightSlate:
        return const BoardThemeColors(
          type: BoardThemeType.midnightSlate,
          lightSquare: Color(0xFFD6DFE8),
          darkSquare: Color(0xFF53687E),
          selectedHighlight: Color(0x9958A6FF),
          lastMoveHighlight: Color(0x6658A6FF),
          checkHighlight: Color(0xCCF85149),
          legalDotColor: Color(0x882A3848),
        );
      case BoardThemeType.royalSapphire:
        return const BoardThemeColors(
          type: BoardThemeType.royalSapphire,
          lightSquare: Color(0xFFE4EDF5),
          darkSquare: Color(0xFF4A7A96),
          selectedHighlight: Color(0x99D29922),
          lastMoveHighlight: Color(0x6658A6FF),
          checkHighlight: Color(0xCCF85149),
          legalDotColor: Color(0x881E3848),
        );
      case BoardThemeType.monochromeOnyx:
        return const BoardThemeColors(
          type: BoardThemeType.monochromeOnyx,
          lightSquare: Color(0xFFE2E2E2),
          darkSquare: Color(0xFF424242),
          selectedHighlight: Color(0x9958A6FF),
          lastMoveHighlight: Color(0x66D29922),
          checkHighlight: Color(0xCCF85149),
          legalDotColor: Color(0x88000000),
        );
    }
  }
}
