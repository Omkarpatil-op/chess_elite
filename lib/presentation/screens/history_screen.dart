import 'package:flutter/material.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/chess_match.dart';
import 'analysis_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ChessMatch> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final list = await ServiceLocator.gameRepository.getMatchHistory();
    if (mounted) {
      setState(() {
        _matches = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Game History & Archive'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldAccent))
          : _matches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_edu_outlined, size: 64, color: AppColors.textMutedDark),
                      const SizedBox(height: 16),
                      Text('No games recorded yet', style: AppTypography.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Matches you play will appear here with full PGN review.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _matches.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final match = _matches[idx];
                    final isWhite = match.whitePlayerId == 'user';
                    final isWin = match.winner == (isWhite ? PieceColor.white : PieceColor.black);
                    final isDraw = match.result.isDraw;

                    final resultColor = isDraw
                        ? AppColors.sapphireInfo
                        : (isWin ? AppColors.emeraldSuccess : AppColors.rubyError);

                    final resultText = isDraw ? 'Draw' : (isWin ? 'Win' : 'Loss');

                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AnalysisScreen(match: match),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: Row(
                          children: [
                            // Result badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: resultColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: resultColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                resultText,
                                style: TextStyle(
                                  color: resultColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Opponent and details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isWhite ? match.blackPlayerName : match.whitePlayerName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${match.timeControl.name}  •  ${match.terminationReason ?? ""}',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondaryDark),
                                  ),
                                ],
                              ),
                            ),

                            // Rating delta & Review icon
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (match.whiteRatingDelta != null) ...[
                                  Text(
                                    (isWhite ? match.whiteRatingDelta! : match.blackRatingDelta!) >= 0
                                        ? '+${isWhite ? match.whiteRatingDelta : match.blackRatingDelta}'
                                        : '${isWhite ? match.whiteRatingDelta : match.blackRatingDelta}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (isWhite ? match.whiteRatingDelta! : match.blackRatingDelta!) >= 0
                                          ? AppColors.emeraldSuccess
                                          : AppColors.rubyError,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMutedDark),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
