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
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorderSubtle),
        ),
        child: Text(
          'Match in progress — make your first move',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMutedDark,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final rowCount = (moveHistory.length + 1) ~/ 2;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
                  color: AppColors.textMutedDark,
                  fontWeight: FontWeight.w700,
                ),
              ),

              // White Move
              GestureDetector(
                onTap: () => onMoveSelected?.call(whiteMoveIdx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: isWhiteSelected
                        ? AppColors.goldAccent.withValues(alpha: 0.22)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: isWhiteSelected
                        ? Border.all(color: AppColors.goldAccent.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Text(
                    whiteMove.san,
                    style: AppTypography.moveNotation.copyWith(
                      fontWeight: isWhiteSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isWhiteSelected
                          ? AppColors.goldLight
                          : AppColors.textPrimaryDark,
                    ),
                  ),
                ),
              ),

              // Black Move (if exists)
              if (blackMove != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => onMoveSelected?.call(blackMoveIdx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBlackSelected
                          ? AppColors.goldAccent.withValues(alpha: 0.22)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: isBlackSelected
                          ? Border.all(color: AppColors.goldAccent.withValues(alpha: 0.5))
                          : null,
                    ),
                    child: Text(
                      blackMove.san,
                      style: AppTypography.moveNotation.copyWith(
                        fontWeight: isBlackSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isBlackSelected
                            ? AppColors.goldLight
                            : AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 14),
            ],
          );
        },
      ),
    );
  }
}
