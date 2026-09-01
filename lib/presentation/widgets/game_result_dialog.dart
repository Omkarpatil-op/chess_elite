import 'package:flutter/material.dart';
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
        ? 'Draw'
        : (isWin ? 'Victory!' : 'Defeat');

    final titleColor = isDraw
        ? AppColors.sapphireInfo
        : (isWin ? AppColors.goldAccent : AppColors.rubyError);

    final icon = isDraw
        ? Icons.handshake_outlined
        : (isWin ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded);

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: titleColor.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: titleColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: titleColor, size: 48),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: AppTypography.displayLarge.copyWith(
                color: titleColor,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle / Termination Reason
            Text(
              gameState.terminationReason ?? 'Game finished',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),

            // Rating Delta Badge
            if (ratingDelta != null) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: (ratingDelta! >= 0
                          ? AppColors.emeraldSuccess
                          : AppColors.rubyError)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (ratingDelta! >= 0
                            ? AppColors.emeraldSuccess
                            : AppColors.rubyError)
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  ratingDelta! >= 0 ? '+$ratingDelta Rating' : '$ratingDelta Rating',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ratingDelta! >= 0
                        ? AppColors.emeraldSuccess
                        : AppColors.rubyError,
                    fontSize: 14,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRematch();
                    },
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: const Text('Rematch'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAnalysis();
                    },
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: const Text('Review Game'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onHome();
                    },
                    icon: const Icon(Icons.home_outlined, size: 18),
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
