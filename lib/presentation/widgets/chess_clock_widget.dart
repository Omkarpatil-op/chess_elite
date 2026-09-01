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
    if (ms <= 0) return '0:00';
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    // Millisecond display when under 20 seconds
    if (totalSeconds < 20) {
      final tenths = (ms % 1000) ~/ 100;
      return '$minutes:${seconds.toString().padLeft(2, '0')}.$tenths';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isLowTime = remainingMs < 15000 && remainingMs > 0;
    final isZero = remainingMs <= 0;

    final clockBgColor = isActive
        ? (isLowTime
            ? AppColors.rubyError.withValues(alpha: 0.2)
            : AppColors.goldAccent.withValues(alpha: 0.15))
        : AppColors.darkSurface;

    final borderColor = isActive
        ? (isLowTime ? AppColors.rubyError : AppColors.goldAccent)
        : AppColors.darkBorder;

    final textColor = isZero
        ? AppColors.rubyError
        : (isLowTime
            ? AppColors.rubyError
            : (isActive ? AppColors.goldAccent : AppColors.textPrimaryDark));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isActive ? 1.5 : 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player Info
          Row(
            children: [
              // Color indicator icon
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: playerColor.isWhite ? Colors.white : Colors.black,
                  border: Border.all(
                    color: playerColor.isWhite ? Colors.grey : Colors.white38,
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (title != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            title!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        playerName,
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 15,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (playerRating != null)
                    Text(
                      '$playerRating',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Digital Countdown Clock
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: clockBgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor.withValues(alpha: isActive ? 0.8 : 0.4),
                width: 1,
              ),
            ),
            child: Text(
              _formatTime(remainingMs),
              style: AppTypography.clockDigits.copyWith(
                color: textColor,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
