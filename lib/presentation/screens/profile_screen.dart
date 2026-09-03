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
        title: const Text('Player Passport'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // 1. Avatar & Grandmaster Identity Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppColors.darkCardGradient,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [AppColors.goldLight, AppColors.goldAccent],
                            ),
                            border: Border.all(color: AppColors.goldAccent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldAccent.withValues(alpha: 0.3),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.username.isNotEmpty ? user.username[0].toUpperCase() : 'G',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0D121C),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          user.username,
                          style: AppTypography.displayMedium.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.isGuest ? 'Guest Session' : (user.email ?? 'Verified Competitor'),
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryDark),
                        ),
                        if (user.isGuest) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AuthScreen()),
                              ).then((_) => _loadProfile());
                            },
                            icon: const Icon(Icons.login_rounded, size: 16),
                            label: const Text('Save Progress to Account'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

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
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Career Performance', style: AppTypography.titleMedium),
                        const SizedBox(height: 16),
                        _buildStatRow('Total Matches', '${user.gamesPlayed}'),
                        _buildStatRow('Victories', '${user.wins}', color: AppColors.emeraldSuccess),
                        _buildStatRow('Defeats', '${user.losses}', color: AppColors.rubyError),
                        _buildStatRow('Draws', '${user.draws}', color: AppColors.sapphireInfo),
                        _buildStatRow('Win Ratio', '${user.winRate.toStringAsFixed(1)}%'),
                        _buildStatRow('Current Win Streak', '${user.winStreak} 🔥'),
                        _buildStatRow('Peak Elo Achieved', '${user.highestRating} 🏆', color: AppColors.goldLight),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
          Text(title, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondaryDark)),
          const SizedBox(height: 6),
          Text(
            '$rating',
            style: AppTypography.ratingDigits.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.goldLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
          Text(
            value,
            style: AppTypography.ratingDigits.copyWith(
              color: color ?? AppColors.textPrimaryDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
