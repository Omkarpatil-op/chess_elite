import 'package:flutter/material.dart';
import '../../core/chess_engine/ai_engine.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/chess_match.dart';
import '../../domain/models/time_control.dart';
import '../../domain/models/user_profile.dart';
import 'friends_screen.dart';
import 'game_screen.dart';
import 'history_screen.dart';
import 'leaderboard_screen.dart';
import 'matchmaking_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  UserProfile? _currentUser;
  List<ChessMatch> _recentMatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final user = await ServiceLocator.authRepository.getCurrentUser();
    final matches = await ServiceLocator.gameRepository.getMatchHistory();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _recentMatches = matches.take(5).toList();
        _isLoading = false;
      });
    }
  }

  void _showPlayAiModal() {
    AiDifficulty selectedDiff = AiDifficulty.medium;
    PieceColor selectedColor = PieceColor.white;
    TimeControl selectedTime = TimeControl.rapid10_0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Play vs Computer', style: AppTypography.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // AI Difficulty
              const Text('Difficulty Level', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AiDifficulty.values.map((diff) {
                  final isSelected = diff == selectedDiff;
                  return ChoiceChip(
                    label: Text('${diff.label} (~${diff.estimatedElo})'),
                    selected: isSelected,
                    selectedColor: AppColors.goldAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setModalState(() => selectedDiff = diff);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Play As Color
              const Text('Play As', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('White ⚪')),
                      selected: selectedColor == PieceColor.white,
                      selectedColor: AppColors.goldAccent,
                      labelStyle: TextStyle(
                        color: selectedColor == PieceColor.white ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setModalState(() => selectedColor = PieceColor.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Black ⚫')),
                      selected: selectedColor == PieceColor.black,
                      selectedColor: AppColors.goldAccent,
                      labelStyle: TextStyle(
                        color: selectedColor == PieceColor.black ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setModalState(() => selectedColor = PieceColor.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Start Game Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          mode: GameMode.vsAi,
                          timeControl: selectedTime,
                          playerColor: selectedColor,
                          aiDifficulty: selectedDiff,
                          opponentName: '${selectedDiff.label} Bot',
                          opponentRating: selectedDiff.estimatedElo,
                        ),
                      ),
                    ).then((_) => _loadDashboard());
                  },
                  child: const Text('Start AI Game'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPassAndPlayModal() {
    TimeControl selectedTime = TimeControl.rapid10_0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pass & Play (Local 2-Player)', style: AppTypography.titleLarge),
              const SizedBox(height: 8),
              const Text('Play on the same device with a friend and interactive chess clocks.'),
              const SizedBox(height: 16),

              const Text('Time Control', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  TimeControl.blitz3_2,
                  TimeControl.blitz5_0,
                  TimeControl.rapid10_0,
                  TimeControl.classical30_0,
                ].map((tc) {
                  final isSelected = tc.id == selectedTime.id;
                  return ChoiceChip(
                    label: Text(tc.displayName),
                    selected: isSelected,
                    selectedColor: AppColors.goldAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setModalState(() => selectedTime = tc);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          mode: GameMode.passAndPlay,
                          timeControl: selectedTime,
                          playerColor: PieceColor.white,
                          opponentName: 'Player 2',
                          opponentRating: 1200,
                        ),
                      ),
                    ).then((_) => _loadDashboard());
                  },
                  child: const Text('Start Local Game'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldAccent),
        ),
      );
    }

    final pages = [
      _buildDashboardView(),
      const LeaderboardScreen(),
      const FriendsScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(child: pages[_currentNavIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.goldAccent.withValues(alpha: 0.2),
        onDestinationSelected: (idx) => setState(() => _currentNavIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield, color: AppColors.goldAccent),
            label: 'Play',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard, color: AppColors.goldAccent),
            label: 'Leaderboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt, color: AppColors.goldAccent),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppColors.goldAccent),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.goldAccent),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    final user = _currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. User Header & Profile Card
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(user: user),
                ),
              ).then((_) => _loadDashboard());
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
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.goldAccent.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: AppColors.goldAccent, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user?.username ?? 'Guest Player',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user?.isGuest ?? true) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.sapphireInfo.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'GUEST',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.sapphireInfo),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: AppColors.goldAccent),
                            const SizedBox(width: 4),
                            Text(
                              'Rapid ${user?.ratingRapid ?? 1200}  •  Blitz ${user?.ratingBlitz ?? 1200}',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondaryDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMutedDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Play Online Quick Match Button
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MatchmakingScreen(user: user!),
                ),
              ).then((_) => _loadDashboard());
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD29922), Color(0xFF9E6A03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldAccent.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PLAY ONLINE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ranked Matchmaking (3 min / 10 min)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 36),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Secondary Play Modes (Play vs Computer, Pass & Play)
          Row(
            children: [
              Expanded(
                child: _buildModeCard(
                  icon: Icons.smart_toy_outlined,
                  title: 'Play vs AI',
                  subtitle: '6 Bot Tiers',
                  onTap: _showPlayAiModal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModeCard(
                  icon: Icons.people_outline,
                  title: 'Pass & Play',
                  subtitle: 'Same Device',
                  onTap: _showPassAndPlayModal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Recent Games Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Games', style: AppTypography.titleMedium),
              TextButton(
                onPressed: () => setState(() => _currentNavIndex = 3),
                child: const Text('View All', style: TextStyle(color: AppColors.goldAccent)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_recentMatches.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.sports_esports_outlined, size: 48, color: AppColors.textMutedDark.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text('No games played yet', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
                  const SizedBox(height: 4),
                  Text('Start your first match above!', style: AppTypography.labelSmall.copyWith(color: AppColors.textMutedDark)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentMatches.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final match = _recentMatches[idx];
                final isWhite = match.whitePlayerId == 'user';
                final isWin = match.winner == (isWhite ? PieceColor.white : PieceColor.black);
                final isDraw = match.result.isDraw;

                final resultColor = isDraw
                    ? AppColors.sapphireInfo
                    : (isWin ? AppColors.emeraldSuccess : AppColors.rubyError);

                final resultText = isDraw ? 'Draw' : (isWin ? 'Win' : 'Loss');

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: resultColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          resultText,
                          style: TextStyle(
                            color: resultColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isWhite ? match.blackPlayerName : match.whitePlayerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${match.timeControl.name}  •  ${match.terminationReason ?? ""}',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondaryDark),
                            ),
                          ],
                        ),
                      ),
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
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.goldAccent, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
    );
  }
}
