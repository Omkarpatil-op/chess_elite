class FriendEntry {
  final String id;
  final String username;
  final int rating;
  final bool isOnline;
  final String? avatarUrl;
  final String? statusMessage;

  const FriendEntry({
    required this.id,
    required this.username,
    required this.rating,
    required this.isOnline,
    this.avatarUrl,
    this.statusMessage,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'rating': rating,
        'isOnline': isOnline,
        'avatarUrl': avatarUrl,
        'statusMessage': statusMessage,
      };

  factory FriendEntry.fromJson(Map<String, dynamic> json) {
    return FriendEntry(
      id: json['id'] as String,
      username: json['username'] as String,
      rating: json['rating'] as int? ?? 1200,
      isOnline: json['isOnline'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      statusMessage: json['statusMessage'] as String?,
    );
  }
}
