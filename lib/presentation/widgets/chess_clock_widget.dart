import 'package:flutter/material.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ChessClockWidget extends StatelessWidget {
  final PieceColor playerColor;
  final int remainingMs;
  final bool isActive;
  final String playerName;
  final int? playerRating;
  final String? title;
  final bool isTop;

  const ChessClockWidget({
    super.key,
    required this.playerColor,
    required this.remainingMs,
    required this.isActive,
    required this.playerName,
    this.playerRating,
    this.title,
    this.isTop = false,
  });

  String _formatTime(int ms) {
    if (ms <= 0) return '0:00.0';
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    // Tenth-of-second precision when under 20 seconds
    if (totalSeconds < 20) {
      final tenths = (ms % 1000) ~/ 100;
      return '$minutes:${seconds.toString().padLeft(2, '0')}.$tenths';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isCriticalTime = remainingMs < 10000 && remainingMs > 0;
    final isLowTime = remainingMs < 20000 && remainingMs > 0;
    final isZero = remainingMs <= 0;

    // Visual State Colors
    Color clockBg;
    Color borderColor;
    Color textColor;

    if (isZero) {
      clockBg = AppColors.rubyError.withValues(alpha: 0.2);
      borderColor = AppColors.rubyError;
      textColor = AppColors.rubyError;
    } else if (isCriticalTime && isActive) {
      clockBg = AppColors.rubyError.withValues(alpha: 0.25);
      borderColor = AppColors.rubyError;
      textColor = AppColors.rubyError;
    } else if (isLowTime && isActive) {
      clockBg = AppColors.amberWarning.withValues(alpha: 0.2);
      borderColor = AppColors.amberWarning;
      textColor = AppColors.amberWarning;
    } else if (isActive) {
      clockBg = AppColors.goldAccent.withValues(alpha: 0.16);
      borderColor = AppColors.goldAccent;
      textColor = AppColors.goldLight;
    } else {
      clockBg = AppColors.darkSurfaceElevated;
      borderColor = AppColors.darkBorder;
      textColor = AppColors.textSecondaryDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? borderColor : AppColors.darkBorderSubtle,
          width: isActive ? 1.6 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player Identity
          Expanded(
            child: Row(
              children: [
                // Color disc
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: playerColor.isWhite ? Colors.white : const Color(0xFF1E2430),
                    border: Border.all(
                      color: playerColor.isWhite ? const Color(0xFFCBD5E1) : Colors.white24,
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Name & Rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          if (title != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.goldAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                title!,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0D121C),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              playerName,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleSmall.copyWith(
                                color: isActive ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (playerRating != null)
                        Text(
                          '$playerRating',
                          style: AppTypography.ratingDigits.copyWith(
                            fontSize: 12,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Digital Tournament Clock Numerals
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: clockBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor.withValues(alpha: isActive ? 0.9 : 0.4),
                width: 1.2,
              ),
            ),
            child: Text(
              _formatTime(remainingMs),
              style: AppTypography.clockDigits.copyWith(
                color: textColor,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
