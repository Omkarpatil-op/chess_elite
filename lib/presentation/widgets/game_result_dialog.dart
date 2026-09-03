import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/chess_engine/models/game_state.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class GameResultDialog extends StatelessWidget {
  final GameState gameState;
  final PieceColor playerColor;
  final int? ratingDelta;
  final VoidCallback onRematch;
  final VoidCallback onAnalysis;
  final VoidCallback onHome;

  const GameResultDialog({
    super.key,
    required this.gameState,
    required this.playerColor,
    this.ratingDelta,
    required this.onRematch,
    required this.onAnalysis,
    required this.onHome,
  });

  static Future<void> show(
    BuildContext context, {
    required GameState gameState,
    required PieceColor playerColor,
    int? ratingDelta,
    required VoidCallback onRematch,
    required VoidCallback onAnalysis,
    required VoidCallback onHome,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        gameState: gameState,
        playerColor: playerColor,
        ratingDelta: ratingDelta,
        onRematch: onRematch,
        onAnalysis: onAnalysis,
        onHome: onHome,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDraw = gameState.result.isDraw;
    final isWin = gameState.winner == playerColor;

    final title = isDraw
        ? 'Draw Match'
        : (isWin ? 'Victory' : 'Defeat');

    final titleColor = isDraw
        ? AppColors.sapphireInfo
        : (isWin ? AppColors.goldAccent : AppColors.rubyError);

    final icon = isDraw
        ? Icons.handshake_rounded
        : (isWin ? Icons.emoji_events_rounded : Icons.shield_outlined);

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: titleColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Emblem
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: titleColor.withValues(alpha: 0.15),
                border: Border.all(color: titleColor.withValues(alpha: 0.6), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: titleColor.withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: titleColor, size: 40),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 18),

            // Title
            Text(
              title.toUpperCase(),
              style: AppTypography.displayMedium.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle / Termination Reason
            Text(
              gameState.terminationReason ?? 'Game completed',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),

            // Rating Delta Badge
            if (ratingDelta != null) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (ratingDelta! >= 0
                          ? AppColors.emeraldSuccess
                          : AppColors.rubyError)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: (ratingDelta! >= 0
                            ? AppColors.emeraldSuccess
                            : AppColors.rubyError)
                        .withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ratingDelta! >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 16,
                      color: ratingDelta! >= 0
                          ? AppColors.emeraldSuccess
                          : AppColors.rubyError,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ratingDelta! >= 0 ? '+$ratingDelta ELO' : '$ratingDelta ELO',
                      style: AppTypography.ratingDigits.copyWith(
                        color: ratingDelta! >= 0
                            ? AppColors.emeraldSuccess
                            : AppColors.rubyError,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Rematch Action (Primary)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRematch();
                },
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('Rematch'),
              ),
            ),
            const SizedBox(height: 12),

            // Secondary Actions Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAnalysis();
                    },
                    icon: const Icon(Icons.analytics_outlined, size: 16),
                    label: const Text('Review'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onHome();
                    },
                    icon: const Icon(Icons.home_outlined, size: 16),
                    label: const Text('Home'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
