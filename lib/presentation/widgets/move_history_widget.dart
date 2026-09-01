import 'package:flutter/material.dart';
import '../../core/chess_engine/models/move.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class MoveHistoryWidget extends StatelessWidget {
  final List<Move> moveHistory;
  final int currentMoveIndex;
  final void Function(int moveIndex)? onMoveSelected;

  const MoveHistoryWidget({
    super.key,
    required this.moveHistory,
    required this.currentMoveIndex,
    this.onMoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (moveHistory.isEmpty) {
      return Container(
        height: 48,
        alignment: Alignment.center,
        child: Text(
          'Game in progress...',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMutedDark,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final rowCount = (moveHistory.length + 1) ~/ 2;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: false,
        itemCount: rowCount,
        itemBuilder: (context, i) {
          final moveNum = i + 1;
          final whiteMoveIdx = i * 2;
          final blackMoveIdx = whiteMoveIdx + 1;

          final whiteMove = moveHistory[whiteMoveIdx];
          final blackMove = blackMoveIdx < moveHistory.length
              ? moveHistory[blackMoveIdx]
              : null;

          final isWhiteSelected = currentMoveIndex == whiteMoveIdx;
          final isBlackSelected = currentMoveIndex == blackMoveIdx;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Move Number
              Text(
                '$moveNum. ',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // White Move
              GestureDetector(
                onTap: () => onMoveSelected?.call(whiteMoveIdx),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: isWhiteSelected
                        ? AppColors.goldAccent.withValues(alpha: 0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    whiteMove.san,
                    style: TextStyle(
                      fontWeight: isWhiteSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isWhiteSelected
                          ? AppColors.goldAccent
                          : AppColors.textPrimaryDark,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              // Black Move (if exists)
              if (blackMove != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => onMoveSelected?.call(blackMoveIdx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBlackSelected
                          ? AppColors.goldAccent.withValues(alpha: 0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      blackMove.san,
                      style: TextStyle(
                        fontWeight: isBlackSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isBlackSelected
                            ? AppColors.goldAccent
                            : AppColors.textPrimaryDark,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 12),
            ],
          );
        },
      ),
    );
  }
}
