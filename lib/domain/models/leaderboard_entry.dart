class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final int rating;
  final double winRate;
  final int gamesPlayed;
  final String? avatarUrl;
  final String? title; // e.g. 'GM', 'IM', 'FM', 'CM'

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.rating,
    required this.winRate,
    required this.gamesPlayed,
    this.avatarUrl,
    this.title,
  });

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'userId': userId,
        'username': username,
        'rating': rating,
        'winRate': winRate,
        'gamesPlayed': gamesPlayed,
        'avatarUrl': avatarUrl,
        'title': title,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['userId'] as String,
      username: json['username'] as String,
      rating: json['rating'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      gamesPlayed: json['gamesPlayed'] as int,
      avatarUrl: json['avatarUrl'] as String?,
      title: json['title'] as String?,
    );
  }
}
