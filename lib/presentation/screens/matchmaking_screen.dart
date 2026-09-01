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
        title: const Text('Play Online'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              if (!_isSearching) ...[
                // Time control selection
                Text(
                  'Select Time Control',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rated matches will update your official ELO rating.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
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
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.goldAccent.withValues(alpha: 0.15)
                                : AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.goldAccent
                                  : AppColors.darkBorder,
                              width: isSelected ? 2.0 : 1.0,
                            ),
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
                                    style: const TextStyle(fontSize: 22),
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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                tc.category.label,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondaryDark,
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
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Find Opponent'),
                  ),
                ),
              ] else ...[
                // Animated Radar Matchmaking State
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.25);
                    final opacity = (1.0 - _pulseController.value).clamp(0.0, 1.0);

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: scale * 1.5,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.goldAccent.withValues(alpha: opacity * 0.2),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldAccent.withValues(alpha: opacity),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.goldAccent,
                          ),
                          child: const Icon(
                            Icons.sports_esports_rounded,
                            color: Colors.black,
                            size: 40,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 36),

                Text(
                  'Searching for Opponent...',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 8),

                Text(
                  'Rating Range: ${widget.user.ratingRapid - 50} - ${widget.user.ratingRapid + 50}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Time Control: ${_selectedTime.displayName}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.goldAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Elapsed: $_searchSeconds s',
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
