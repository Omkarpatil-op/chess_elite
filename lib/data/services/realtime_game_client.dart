import 'dart:async';

enum RealtimeConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

enum RealtimeEventType {
  gameStart('GAME_START'),
  moveMade('MOVE_MADE'),
  clockSync('CLOCK_SYNC'),
  drawOffered('DRAW_OFFERED'),
  drawAccepted('DRAW_ACCEPTED'),
  drawDeclined('DRAW_DECLINED'),
  playerResigned('PLAYER_RESIGNED'),
  playerDisconnected('PLAYER_DISCONNECTED'),
  playerReconnected('PLAYER_RECONNECTED'),
  gameOver('GAME_OVER'),
  matchFound('MATCH_FOUND'),
  ping('PING'),
  pong('PONG');

  final String name;
  const RealtimeEventType(this.name);

  static RealtimeEventType? fromString(String str) {
    for (final val in values) {
      if (val.name == str) return val;
    }
    return null;
  }
}

class RealtimeMessage {
  final String eventId;
  final String gameId;
  final int sequenceNumber;
  final RealtimeEventType type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  const RealtimeMessage({
    required this.eventId,
    required this.gameId,
    required this.sequenceNumber,
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'gameId': gameId,
        'sequenceNumber': sequenceNumber,
        'type': type.name,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
      };

  factory RealtimeMessage.fromJson(Map<String, dynamic> json) {
    return RealtimeMessage(
      eventId: json['eventId'] as String? ?? '',
      gameId: json['gameId'] as String? ?? '',
      sequenceNumber: json['sequenceNumber'] as int? ?? 0,
      type: RealtimeEventType.fromString(json['type'] as String) ??
          RealtimeEventType.ping,
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

abstract class IRealtimeGameClient {
  Stream<RealtimeMessage> get eventStream;
  Stream<RealtimeConnectionState> get connectionStateStream;
  RealtimeConnectionState get connectionState;

  Future<void> connect({required String token, required String gameId});
  Future<void> disconnect();
  void sendMove({required String uci, required int moveSequence});
  void offerDraw();
  void acceptDraw();
  void declineDraw();
  void resign();
  void sendPing();
}
