import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/friend_entry.dart';
import '../../domain/models/time_control.dart';
import 'game_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<FriendEntry> _friends = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    final data = await ServiceLocator.socialRepository.getFriends();
    if (mounted) {
      setState(() {
        _friends = data;
        _isLoading = false;
      });
    }
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Add Competitor'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter username or player tag',
            prefixIcon: Icon(Icons.person_search_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final query = _searchController.text.trim();
              if (query.isNotEmpty) {
                Navigator.of(ctx).pop();
                await ServiceLocator.socialRepository.sendFriendRequest(query);
                _searchController.clear();
                _loadFriends();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Friend request dispatched to $query!')),
                  );
                }
              }
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  void _challengeFriend(FriendEntry friend) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          mode: GameMode.onlineMultiplayer,
          timeControl: TimeControl.rapid10_0,
          opponentName: friend.username,
          opponentRating: friend.rating,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Social & Competitors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Add Friend',
            onPressed: _showAddFriendDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldAccent))
          : _friends.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.darkSurfaceElevated,
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: const Icon(Icons.people_outline_rounded, size: 40, color: AppColors.goldAccent),
                        ),
                        const SizedBox(height: 20),
                        Text('No Friends Added', style: AppTypography.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          'Invite friends to challenge them to live matches anytime.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _showAddFriendDialog,
                          icon: const Icon(Icons.person_add_rounded, size: 18),
                          label: const Text('Find Players'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _friends.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final friend = _friends[idx];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.goldAccent.withValues(alpha: 0.15),
                                child: Text(
                                  friend.username.isNotEmpty ? friend.username[0].toUpperCase() : 'P',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.goldAccent,
                                  ),
                                ),
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: friend.isOnline ? AppColors.emeraldSuccess : AppColors.textMutedDark,
                                  border: Border.all(color: AppColors.darkSurface, width: 2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  friend.username,
                                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  friend.statusMessage ?? (friend.isOnline ? 'Online' : 'Offline'),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: friend.isOnline ? AppColors.emeraldSuccess : AppColors.textMutedDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${friend.rating} Elo',
                            style: AppTypography.ratingDigits.copyWith(
                              color: AppColors.goldLight,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.bolt_rounded, color: AppColors.goldAccent),
                            tooltip: 'Challenge to Game',
                            onPressed: () => _challengeFriend(friend),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
