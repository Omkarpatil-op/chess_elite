class UserProfile {
  final String id;
  final String username;
  final String? email;
  final String? avatarUrl;
  final int ratingBullet;
  final int ratingBlitz;
  final int ratingRapid;
  final int ratingClassical;
  final int gamesPlayed;
  final int wins;
  final int losses;
  final int draws;
  final int winStreak;
  final int highestRating;
  final bool isGuest;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.username,
    this.email,
    this.avatarUrl,
    this.ratingBullet = 1200,
    this.ratingBlitz = 1200,
    this.ratingRapid = 1200,
    this.ratingClassical = 1200,
    this.gamesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.winStreak = 0,
    this.highestRating = 1200,
    this.isGuest = false,
    required this.createdAt,
  });

  double get winRate =>
      gamesPlayed > 0 ? (wins / gamesPlayed) * 100 : 0.0;

  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    int? ratingBullet,
    int? ratingBlitz,
    int? ratingRapid,
    int? ratingClassical,
    int? gamesPlayed,
    int? wins,
    int? losses,
    int? draws,
    int? winStreak,
    int? highestRating,
    bool? isGuest,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ratingBullet: ratingBullet ?? this.ratingBullet,
      ratingBlitz: ratingBlitz ?? this.ratingBlitz,
      ratingRapid: ratingRapid ?? this.ratingRapid,
      ratingClassical: ratingClassical ?? this.ratingClassical,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      winStreak: winStreak ?? this.winStreak,
      highestRating: highestRating ?? this.highestRating,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'avatarUrl': avatarUrl,
        'ratingBullet': ratingBullet,
        'ratingBlitz': ratingBlitz,
        'ratingRapid': ratingRapid,
        'ratingClassical': ratingClassical,
        'gamesPlayed': gamesPlayed,
        'wins': wins,
        'losses': losses,
        'draws': draws,
        'winStreak': winStreak,
        'highestRating': highestRating,
        'isGuest': isGuest,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      ratingBullet: json['ratingBullet'] as int? ?? 1200,
      ratingBlitz: json['ratingBlitz'] as int? ?? 1200,
      ratingRapid: json['ratingRapid'] as int? ?? 1200,
      ratingClassical: json['ratingClassical'] as int? ?? 1200,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      winStreak: json['winStreak'] as int? ?? 0,
      highestRating: json['highestRating'] as int? ?? 1200,
      isGuest: json['isGuest'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
