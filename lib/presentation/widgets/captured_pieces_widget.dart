import 'package:flutter/material.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
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
      return const SizedBox(height: 26);
    }

    // Sort pieces by standard point value
    final sortedPieces = List<Piece>.from(capturedPieces)
      ..sort((a, b) => a.value.compareTo(b.value));

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row of captured piece icons
          for (int i = 0; i < sortedPieces.length; i++)
            Transform.translate(
              offset: Offset(i * -5.0, 0),
              child: ChessPieceWidget(
                piece: sortedPieces[i],
                size: 20,
                style: pieceStyle,
              ),
            ),

          // Advantage Score Badge
          if (materialDifference > 0) ...[
            SizedBox(width: sortedPieces.isNotEmpty ? 8 : 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: AppColors.emeraldSuccess.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.emeraldSuccess.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                '+$materialDifference',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
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
