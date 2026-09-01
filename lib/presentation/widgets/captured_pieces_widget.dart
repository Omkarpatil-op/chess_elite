import 'package:flutter/material.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/piece_themes.dart';
import 'piece_painter.dart';

class CapturedPiecesWidget extends StatelessWidget {
  final List<Piece> capturedPieces;
  final int materialDifference; // > 0 if this player has advantage
  final PieceStyle pieceStyle;

  const CapturedPiecesWidget({
    super.key,
    required this.capturedPieces,
    this.materialDifference = 0,
    this.pieceStyle = PieceStyle.stauntonClassic,
  });

  @override
  Widget build(BuildContext context) {
    if (capturedPieces.isEmpty && materialDifference <= 0) {
      return const SizedBox(height: 24);
    }

    // Sort pieces by value (pawn -> knight/bishop -> rook -> queen)
    final sortedPieces = List<Piece>.from(capturedPieces)
      ..sort((a, b) => a.value.compareTo(b.value));

    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row of captured piece icons overlapping slightly
          for (int i = 0; i < sortedPieces.length; i++)
            Transform.translate(
              offset: Offset(i * -4.0, 0),
              child: ChessPieceWidget(
                piece: sortedPieces[i],
                size: 20,
                style: pieceStyle,
              ),
            ),

          // Advantage badge
          if (materialDifference > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.emeraldSuccess.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.emeraldSuccess.withValues(alpha: 0.4)),
              ),
              child: Text(
                '+$materialDifference',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.emeraldSuccess,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
