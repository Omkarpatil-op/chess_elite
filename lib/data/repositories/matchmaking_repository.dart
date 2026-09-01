import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../domain/models/time_control.dart';
import '../../domain/models/user_profile.dart';

enum MatchmakingStatus {
  idle,
  searching,
  matchFound,
  cancelled,
  error,
}

class MatchFoundData {
  final String gameId;
  final String opponentId;
  final String opponentName;
  final int opponentRating;
  final TimeControl timeControl;
  final bool userPlaysWhite;

  const MatchFoundData({
    required this.gameId,
    required this.opponentId,
    required this.opponentName,
    required this.opponentRating,
    required this.timeControl,
    required this.userPlaysWhite,
  });
}

abstract class IMatchmakingRepository {
  Stream<MatchmakingStatus> get statusStream;
  MatchmakingStatus get currentStatus;

  Future<MatchFoundData?> startSearch({
    required UserProfile user,
    required TimeControl timeControl,
    int ratingRange = 100,
  });

  void cancelSearch();
}

class MatchmakingRepository implements IMatchmakingRepository {
  static const _uuid = Uuid();
  final _statusController = StreamController<MatchmakingStatus>.broadcast();
  MatchmakingStatus _status = MatchmakingStatus.idle;
  Timer? _searchTimer;

  @override
  Stream<MatchmakingStatus> get statusStream => _statusController.stream;
  @override
  MatchmakingStatus get currentStatus => _status;

  void _setStatus(MatchmakingStatus status) {
    _status = status;
    _statusController.add(status);
  }

  @override
  Future<MatchFoundData?> startSearch({
    required UserProfile user,
    required TimeControl timeControl,
    int ratingRange = 100,
  }) async {
    _setStatus(MatchmakingStatus.searching);

    // Realistic matchmaking search time (1.5 - 2.5s)
    final completer = Completer<MatchFoundData?>();

    _searchTimer = Timer(const Duration(milliseconds: 2000), () {
      if (_status != MatchmakingStatus.searching) {
        completer.complete(null);
        return;
      }

      final oppRating = user.ratingRapid + (DateTime.now().millisecond % 80 - 40);
      final oppNames = [
        'Vishy_Fan',
        'MagnusClaw',
        'Tactical_Rook',
        'HyperModern',
        'EndgameMaster',
        'CheckmatePro',
      ];
      final oppName = oppNames[DateTime.now().second % oppNames.length];

      final matchData = MatchFoundData(
        gameId: 'match_${_uuid.v4().substring(0, 8)}',
        opponentId: 'opp_${_uuid.v4().substring(0, 6)}',
        opponentName: oppName,
        opponentRating: oppRating,
        timeControl: timeControl,
        userPlaysWhite: DateTime.now().millisecond % 2 == 0,
      );

      _setStatus(MatchmakingStatus.matchFound);
      completer.complete(matchData);
    });

    return completer.future;
  }

  @override
  void cancelSearch() {
    _searchTimer?.cancel();
    _setStatus(MatchmakingStatus.cancelled);
    Timer(const Duration(milliseconds: 300), () {
      _setStatus(MatchmakingStatus.idle);
    });
  }

  void dispose() {
    _searchTimer?.cancel();
    _statusController.close();
  }
}
