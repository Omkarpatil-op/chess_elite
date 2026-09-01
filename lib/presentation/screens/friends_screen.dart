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
        title: const Text('Add Friend'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter username',
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
                    SnackBar(content: Text('Friend request sent to $query!')),
                  );
                }
              }
            },
            child: const Text('Send Request'),
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
        title: const Text('Friends & Community'),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 64, color: AppColors.textMutedDark),
                      const SizedBox(height: 16),
                      Text('No friends added yet', style: AppTypography.titleMedium),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _showAddFriendDialog,
                        child: const Text('Find Players'),
                      ),
                    ],
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
                                backgroundColor: AppColors.goldAccent.withValues(alpha: 0.2),
                                child: Text(
                                  friend.username[0],
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldAccent),
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                            '${friend.rating}',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldAccent,
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
