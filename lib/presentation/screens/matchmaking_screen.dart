import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/time_control.dart';
import '../../domain/models/user_profile.dart';
import 'game_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  final UserProfile user;

  const MatchmakingScreen({super.key, required this.user});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen>
    with SingleTickerProviderStateMixin {
  TimeControl _selectedTime = TimeControl.rapid10_0;
  bool _isSearching = false;
  int _searchSeconds = 0;
  Timer? _searchTimer;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _startSearch() async {
    setState(() {
      _isSearching = true;
      _searchSeconds = 0;
    });

    _searchTimer?.cancel();
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _searchSeconds++);
      }
    });

    final matchData = await ServiceLocator.matchmakingRepository.startSearch(
      user: widget.user,
      timeControl: _selectedTime,
    );

    if (!mounted || matchData == null) return;

    _searchTimer?.cancel();

    // Navigate to live online game
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          mode: GameMode.onlineMultiplayer,
          timeControl: matchData.timeControl,
          playerColor: matchData.userPlaysWhite
              ? PieceColor.white
              : PieceColor.black,
          opponentName: matchData.opponentName,
          opponentRating: matchData.opponentRating,
          onlineGameId: matchData.gameId,
        ),
      ),
    );
  }

  void _cancelSearch() {
    _searchTimer?.cancel();
    ServiceLocator.matchmakingRepository.cancelSearch();
    setState(() => _isSearching = false);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Live Arena Matchmaking'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              if (!_isSearching) ...[
                // Time control selection
                Text(
                  'Choose Tournament Cadence',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Ranked competitive matchmaking adjusts your official Elo.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.35,
                    children: [
                      TimeControl.bullet1_0,
                      TimeControl.blitz3_0,
                      TimeControl.blitz5_3,
                      TimeControl.rapid10_0,
                      TimeControl.rapid15_10,
                      TimeControl.classical30_0,
                    ].map((tc) {
                      final isSelected = tc.id == _selectedTime.id;
                      return InkWell(
                        onTap: () => setState(() => _selectedTime = tc),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF262E40), Color(0xFF161E2E)],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.goldAccent
                                  : AppColors.darkBorder,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.goldAccent.withValues(alpha: 0.15),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tc.category.icon,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.goldAccent,
                                      size: 20,
                                    ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                tc.displayName,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? AppColors.goldLight : AppColors.textPrimaryDark,
                                ),
                              ),
                              Text(
                                tc.category.label,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startSearch,
                    icon: const Icon(Icons.search_rounded, size: 20),
                    label: const Text('Find Opponent'),
                  ),
                ),
              ] else ...[
                // Animated Radar Matchmaking State
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.35);
                    final opacity = (1.0 - _pulseController.value).clamp(0.0, 1.0);

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: scale * 1.8,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.goldAccent.withValues(alpha: opacity * 0.12),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldAccent.withValues(alpha: opacity * 0.8),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [AppColors.goldLight, AppColors.goldAccent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldAccent.withValues(alpha: 0.35),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.sports_esports_rounded,
                              color: Color(0xFF0D121C),
                              size: 44,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),

                Text(
                  'Finding Suitable Grandmaster...',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),

                Text(
                  'Target Range: ${widget.user.ratingRapid - 60} – ${widget.user.ratingRapid + 60} Elo',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Cadence: ${_selectedTime.displayName}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'Elapsed: ${_searchSeconds}s',
                  style: AppTypography.clockDigits.copyWith(
                    fontSize: 20,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _cancelSearch,
                    child: const Text('Cancel Search'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
