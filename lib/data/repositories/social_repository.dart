import '../../domain/models/friend_entry.dart';
import '../../domain/models/leaderboard_entry.dart';

abstract class ISocialRepository {
  Future<List<FriendEntry>> getFriends();
  Future<List<LeaderboardEntry>> getLeaderboard({String category = 'rapid'});
  Future<void> sendFriendRequest(String username);
  Future<void> removeFriend(String id);
}

class SocialRepository implements ISocialRepository {
  final List<FriendEntry> _mockFriends = [
    const FriendEntry(
      id: 'f1',
      username: 'AlexandraB',
      rating: 1840,
      isOnline: true,
      statusMessage: 'Ready for Blitz 3+2 ♟️',
    ),
    const FriendEntry(
      id: 'f2',
      username: 'GothamKnight',
      rating: 1950,
      isOnline: true,
      statusMessage: 'Playing Rapid...',
    ),
    const FriendEntry(
      id: 'f3',
      username: 'MagnusFan99',
      rating: 1620,
      isOnline: false,
      statusMessage: 'Last seen 2h ago',
    ),
    const FriendEntry(
      id: 'f4',
      username: 'VishyMaster',
      rating: 2100,
      isOnline: true,
      statusMessage: 'In analysis mode',
    ),
  ];

  final List<LeaderboardEntry> _mockLeaderboard = [
    const LeaderboardEntry(
      rank: 1,
      userId: 'gm1',
      username: 'Magnus C.',
      rating: 2882,
      winRate: 74.2,
      gamesPlayed: 1420,
      title: 'GM',
    ),
    const LeaderboardEntry(
      rank: 2,
      userId: 'gm2',
      username: 'Hikaru N.',
      rating: 2875,
      winRate: 72.8,
      gamesPlayed: 2310,
      title: 'GM',
    ),
    const LeaderboardEntry(
      rank: 3,
      userId: 'gm3',
      username: 'Gukesh D.',
      rating: 2805,
      winRate: 69.5,
      gamesPlayed: 980,
      title: 'GM',
    ),
    const LeaderboardEntry(
      rank: 4,
      userId: 'gm4',
      username: 'Arjun E.',
      rating: 2798,
      winRate: 68.0,
      gamesPlayed: 1120,
      title: 'GM',
    ),
    const LeaderboardEntry(
      rank: 5,
      userId: 'gm5',
      username: 'Pragg R.',
      rating: 2780,
      winRate: 66.4,
      gamesPlayed: 1040,
      title: 'GM',
    ),
    const LeaderboardEntry(
      rank: 6,
      userId: 'gm6',
      username: 'Alireza F.',
      rating: 2772,
      winRate: 65.9,
      gamesPlayed: 890,
      title: 'GM',
    ),
  ];

  @override
  Future<List<FriendEntry>> getFriends() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_mockFriends);
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({String category = 'rapid'}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_mockLeaderboard);
  }

  @override
  Future<void> sendFriendRequest(String username) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockFriends.add(FriendEntry(
      id: 'f_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      rating: 1300,
      isOnline: false,
      statusMessage: 'Request pending',
    ));
  }

  @override
  Future<void> removeFriend(String id) async {
    _mockFriends.removeWhere((f) => f.id == id);
  }
}
