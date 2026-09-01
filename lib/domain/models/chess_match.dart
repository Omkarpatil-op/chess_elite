import '../../core/chess_engine/models/game_state.dart';
import '../../core/chess_engine/models/piece.dart';
import 'time_control.dart';

class ChessMatch {
  final String id;
  final String whitePlayerId;
  final String whitePlayerName;
  final int whitePlayerRating;
  final String blackPlayerId;
  final String blackPlayerName;
  final int blackPlayerRating;
  final TimeControl timeControl;
  final bool isRated;
  final bool isOnline;
  final String pgn;
  final String fen;
  final GameResult result;
  final PieceColor? winner;
  final String? terminationReason;
  final int? whiteRatingDelta;
  final int? blackRatingDelta;
  final DateTime startedAt;
  final DateTime? endedAt;

  const ChessMatch({
    required this.id,
    required this.whitePlayerId,
    required this.whitePlayerName,
    required this.whitePlayerRating,
    required this.blackPlayerId,
    required this.blackPlayerName,
    required this.blackPlayerRating,
    required this.timeControl,
    this.isRated = true,
    this.isOnline = true,
    required this.pgn,
    required this.fen,
    required this.result,
    this.winner,
    this.terminationReason,
    this.whiteRatingDelta,
    this.blackRatingDelta,
    required this.startedAt,
    this.endedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'whitePlayerId': whitePlayerId,
        'whitePlayerName': whitePlayerName,
        'whitePlayerRating': whitePlayerRating,
        'blackPlayerId': blackPlayerId,
        'blackPlayerName': blackPlayerName,
        'blackPlayerRating': blackPlayerRating,
        'timeControl': timeControl.toJson(),
        'isRated': isRated,
        'isOnline': isOnline,
        'pgn': pgn,
        'fen': fen,
        'result': result.name,
        'winner': winner?.name,
        'terminationReason': terminationReason,
        'whiteRatingDelta': whiteRatingDelta,
        'blackRatingDelta': blackRatingDelta,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
      };

  factory ChessMatch.fromJson(Map<String, dynamic> json) {
    return ChessMatch(
      id: json['id'] as String,
      whitePlayerId: json['whitePlayerId'] as String,
      whitePlayerName: json['whitePlayerName'] as String,
      whitePlayerRating: json['whitePlayerRating'] as int? ?? 1200,
      blackPlayerId: json['blackPlayerId'] as String,
      blackPlayerName: json['blackPlayerName'] as String,
      blackPlayerRating: json['blackPlayerRating'] as int? ?? 1200,
      timeControl: TimeControl.fromJson(json['timeControl'] as Map<String, dynamic>),
      isRated: json['isRated'] as bool? ?? true,
      isOnline: json['isOnline'] as bool? ?? true,
      pgn: json['pgn'] as String? ?? '',
      fen: json['fen'] as String,
      result: GameResult.values.firstWhere(
        (r) => r.name == json['result'],
        orElse: () => GameResult.ongoing,
      ),
      winner: json['winner'] != null
          ? PieceColor.values.firstWhere((c) => c.name == json['winner'])
          : null,
      terminationReason: json['terminationReason'] as String?,
      whiteRatingDelta: json['whiteRatingDelta'] as int?,
      blackRatingDelta: json['blackRatingDelta'] as int?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
    );
  }
}
