import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/user_profile.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? user;

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    if (_user == null) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    final user = await ServiceLocator.authRepository.getCurrentUser();
    if (mounted) {
      setState(() => _user = user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Player Profile'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // 1. Avatar & Basic Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.goldAccent.withValues(alpha: 0.2),
                          child: const Icon(Icons.person, size: 48, color: AppColors.goldAccent),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.username,
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.isGuest ? 'Guest Account' : (user.email ?? 'Verified Player'),
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                        ),
                        const SizedBox(height: 12),
                        if (user.isGuest)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AuthScreen()),
                              ).then((_) => _loadProfile());
                            },
                            icon: const Icon(Icons.login_rounded, size: 18),
                            label: const Text('Create Permanent Account'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Ratings Grid (Rapid, Blitz, Bullet, Classical)
                  Row(
                    children: [
                      Expanded(child: _buildRatingCard('⚡ Bullet', user.ratingBullet, Icons.bolt_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildRatingCard('🔥 Blitz', user.ratingBlitz, Icons.local_fire_department_rounded)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildRatingCard('⏱️ Rapid', user.ratingRapid, Icons.timer_outlined)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildRatingCard('⏳ Classical', user.ratingClassical, Icons.hourglass_empty_rounded)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Overall Statistics Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Career Statistics', style: AppTypography.titleMedium),
                        const SizedBox(height: 16),
                        _buildStatRow('Total Games Played', '${user.gamesPlayed}'),
                        _buildStatRow('Wins', '${user.wins}', color: AppColors.emeraldSuccess),
                        _buildStatRow('Losses', '${user.losses}', color: AppColors.rubyError),
                        _buildStatRow('Draws', '${user.draws}', color: AppColors.sapphireInfo),
                        _buildStatRow('Win Rate', '${user.winRate.toStringAsFixed(1)}%'),
                        _buildStatRow('Current Win Streak', '${user.winStreak} 🔥'),
                        _buildStatRow('Highest Rating', '${user.highestRating} 🏆'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRatingCard(String title, int rating, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '$rating',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 26,
              color: AppColors.goldAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimaryDark,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
