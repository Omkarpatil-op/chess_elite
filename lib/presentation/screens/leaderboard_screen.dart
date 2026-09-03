import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/leaderboard_entry.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;
  final String _selectedCategory = 'rapid';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    final data = await ServiceLocator.socialRepository
        .getLeaderboard(category: _selectedCategory);
    if (mounted) {
      setState(() {
        _entries = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Global Championship Ranks'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldAccent))
          : Column(
              children: [
                // Top 3 Podium
                if (_entries.length >= 3) _buildPodium(),
                const SizedBox(height: 12),

                // Ranking List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final item = _entries[idx];
                      return _buildLeaderboardTile(item);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPodium() {
    final first = _entries[0];
    final second = _entries[1];
    final third = _entries[2];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: const Border(bottom: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Silver)
          _buildPodiumSpot(second, 2, const Color(0xFFC0C0C0), 95),
          // 1st Place (Gold - Crown)
          _buildPodiumSpot(first, 1, AppColors.goldAccent, 125),
          // 3rd Place (Bronze)
          _buildPodiumSpot(third, 3, const Color(0xFFCD7F32), 80),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot(
    LeaderboardEntry entry,
    int rank,
    Color badgeColor,
    double height,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: rank == 1 ? 68 : 56,
              height: rank == 1 ? 68 : 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [badgeColor.withValues(alpha: 0.3), AppColors.darkSurfaceElevated],
                ),
                border: Border.all(color: badgeColor, width: rank == 1 ? 2.5 : 1.5),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.25),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  entry.username.isNotEmpty ? entry.username[0].toUpperCase() : 'G',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: rank == 1 ? 24 : 20,
                    color: badgeColor,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor,
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          entry.username,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        Text(
          '${entry.rating} Elo',
          style: AppTypography.ratingDigits.copyWith(
            color: badgeColor,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: entry.rank <= 3 ? AppColors.goldAccent : AppColors.textSecondaryDark,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Title badge (GM, IM)
          if (entry.title != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.goldAccent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entry.title!,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Username & Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${entry.gamesPlayed} matches  •  ${entry.winRate.toStringAsFixed(1)}% win rate',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Rating
          Text(
            '${entry.rating}',
            style: AppTypography.ratingDigits.copyWith(
              color: AppColors.goldLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
