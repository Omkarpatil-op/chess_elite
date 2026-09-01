import 'package:flutter/material.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/piece_themes.dart';
import 'piece_painter.dart';

class PromotionDialog extends StatelessWidget {
  final PieceColor color;
  final PieceStyle pieceStyle;

  const PromotionDialog({
    super.key,
    required this.color,
    this.pieceStyle = PieceStyle.stauntonClassic,
  });

  static Future<PieceType?> show(
    BuildContext context, {
    required PieceColor color,
    PieceStyle pieceStyle = PieceStyle.stauntonClassic,
  }) {
    return showDialog<PieceType>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          PromotionDialog(color: color, pieceStyle: pieceStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pieces = [
      PieceType.queen,
      PieceType.knight,
      PieceType.rook,
      PieceType.bishop,
    ];

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.goldAccent, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Promote Pawn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: pieces.map((type) {
                final piece = Piece(type: type, color: color);
                return InkWell(
                  onTap: () => Navigator.of(context).pop(type),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: ChessPieceWidget(
                      piece: piece,
                      size: 48,
                      style: pieceStyle,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
