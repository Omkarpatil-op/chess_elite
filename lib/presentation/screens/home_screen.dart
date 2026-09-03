import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/chess_engine/ai_engine.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/chess_match.dart';
import '../../domain/models/time_control.dart';
import '../../domain/models/user_profile.dart';
import 'analysis_screen.dart';
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
        _recentMatches = matches.take(4).toList();
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // AI Difficulty
              Text('Difficulty Level', style: AppTypography.titleSmall),
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),

              // Play As Color
              Text('Play As Color', style: AppTypography.titleSmall),
              const SizedBox(height: 10),
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
                  const SizedBox(width: 10),
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
              const SizedBox(height: 20),

              // Time Control
              Text('Time Control', style: AppTypography.titleSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TimeControl.bullet1_0,
                  TimeControl.blitz3_0,
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
              const SizedBox(height: 28),

              // Start AI Match Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
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
                  icon: const Icon(Icons.psychology_rounded, size: 20),
                  label: const Text('Start Sparring Match'),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pass & Play (Local Table)', style: AppTypography.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Play on the same screen with dual active digital tournament clocks.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryDark),
              ),
              const SizedBox(height: 18),

              Text('Time Control', style: AppTypography.titleSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
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
                  icon: const Icon(Icons.people_alt_rounded, size: 20),
                  label: const Text('Start Local Game'),
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
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Shimmer.fromColors(
              baseColor: AppColors.darkSurface,
              highlightColor: AppColors.darkSurfaceElevated,
              child: Column(
                children: [
                  Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                  const SizedBox(height: 20),
                  Container(height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                  const SizedBox(height: 20),
                  Container(height: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                ],
              ),
            ),
          ),
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
        onDestinationSelected: (idx) => setState(() => _currentNavIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded),
            label: 'Arena',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard_rounded),
            label: 'Ranks',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Social',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Archive',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    final user = _currentUser;

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: AppColors.goldAccent,
      backgroundColor: AppColors.darkSurface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Bar / Profile Passport Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ).then((_) => _loadDashboard());
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.goldLight, AppColors.goldAccent],
                          ),
                          border: Border.all(color: AppColors.goldAccent, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            user != null && user.username.isNotEmpty ? user.username[0].toUpperCase() : 'G',
                            style: const TextStyle(
                              color: Color(0xFF0D121C),
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username ?? 'Grandmaster',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.emeraldSuccess,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Grandmaster Tier',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.goldLight,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        ).then((_) => _loadDashboard());
                      },
                      icon: const Icon(Icons.person_outline_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.darkSurfaceElevated,
                        foregroundColor: AppColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2. Hero ELO Rating Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.darkCardGradient,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.darkBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OFFICIAL RATING',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMutedDark,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldSuccess.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.emeraldSuccess.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.emeraldSuccess),
                            const SizedBox(width: 4),
                            Text(
                              '+24 this week',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.emeraldSuccess,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${user?.ratingRapid ?? 1482}',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: AppColors.goldLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'RAPID ELO',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mini Stats Ticker (Blitz, Bullet, Win Rate)
                  Row(
                    children: [
                      _buildMiniStat('⚡ Bullet', '${user?.ratingBullet ?? 1400}'),
                      const SizedBox(width: 12),
                      _buildMiniStat('🔥 Blitz', '${user?.ratingBlitz ?? 1450}'),
                      const SizedBox(width: 12),
                      _buildMiniStat('🏆 Win Rate', '${user?.winRate.toStringAsFixed(1) ?? "64.2"}%'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // 3. Play Chess Modes Section
            Text(
              'PLAY CHESS',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMutedDark,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),

            // Mode 1: Quick Rated Match
            _buildPlayCard(
              title: 'Quick Match',
              subtitle: 'Find an opponent in rated 10 min Rapid arena',
              badge: 'ONLINE',
              badgeColor: AppColors.emeraldSuccess,
              icon: Icons.bolt_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2838), Color(0xFF131A26)],
              ),
              onTap: () {
                if (user != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MatchmakingScreen(user: user),
                    ),
                  ).then((_) => _loadDashboard());
                }
              },
            ),
            const SizedBox(height: 12),

            // Mode 2: Play Computer (AI Sparring)
            _buildPlayCard(
              title: 'Play Computer',
              subtitle: 'Spar against intelligent chess engines & bot personalities',
              badge: 'AI ENGINE',
              badgeColor: AppColors.goldAccent,
              icon: Icons.psychology_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF24221A), Color(0xFF18150F)],
              ),
              onTap: _showPlayAiModal,
            ),
            const SizedBox(height: 12),

            // Mode 3: Pass & Play
            _buildPlayCard(
              title: 'Pass & Play Local',
              subtitle: 'Compete on the same device with dual chess clocks',
              badge: '2 PLAYER',
              badgeColor: AppColors.sapphireInfo,
              icon: Icons.people_alt_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF1A2234), Color(0xFF101622)],
              ),
              onTap: _showPassAndPlayModal,
            ),
            const SizedBox(height: 28),

            // 4. Recent Games Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT MATCHES',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMutedDark,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _currentNavIndex = 3),
                  child: Text(
                    'View All →',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.goldAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (_recentMatches.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkBorderSubtle),
                ),
                alignment: Alignment.center,
                child: Text(
                  'No games recorded yet. Start your first match above!',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedDark),
                ),
              )
            else
              Column(
                children: _recentMatches.map((m) => _buildRecentMatchRow(m)).toList(),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.ratingDigits.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
              ),
              child: Icon(icon, color: badgeColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMutedDark),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMatchRow(ChessMatch match) {
    final isWhite = match.whitePlayerId == 'user';
    final isWin = match.winner == (isWhite ? PieceColor.white : PieceColor.black);
    final isDraw = match.result.isDraw;

    final resultColor = isDraw
        ? AppColors.sapphireInfo
        : (isWin ? AppColors.emeraldSuccess : AppColors.rubyError);

    final resultText = isDraw ? 'Draw' : (isWin ? 'Win' : 'Loss');
    final opponentName = isWhite ? match.blackPlayerName : match.whitePlayerName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AnalysisScreen(match: match)),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: resultColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  resultText,
                  style: TextStyle(
                    color: resultColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opponentName,
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      match.timeControl.name,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedDark, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (match.whiteRatingDelta != null)
                Text(
                  (isWhite ? match.whiteRatingDelta! : match.blackRatingDelta!) >= 0
                      ? '+${isWhite ? match.whiteRatingDelta : match.blackRatingDelta}'
                      : '${isWhite ? match.whiteRatingDelta : match.blackRatingDelta}',
                  style: AppTypography.ratingDigits.copyWith(
                    color: resultColor,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMutedDark),
            ],
          ),
        ),
      ),
    );
  }
}
