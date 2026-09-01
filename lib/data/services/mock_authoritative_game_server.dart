import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../core/chess_engine/ai_engine.dart';
import '../../core/chess_engine/ai_isolate.dart';
import '../../core/chess_engine/board.dart';
import '../../core/chess_engine/models/game_state.dart';
import '../../core/chess_engine/models/move.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/chess_engine/move_generator.dart';
import '../../core/chess_engine/rules_engine.dart';
import '../../core/logging/app_logger.dart';
import 'realtime_game_client.dart';

class MockAuthoritativeGameServer implements IRealtimeGameClient {
  static const _uuid = Uuid();

  final _eventController = StreamController<RealtimeMessage>.broadcast();
  final _stateController =
      StreamController<RealtimeConnectionState>.broadcast();

  RealtimeConnectionState _connectionState =
      RealtimeConnectionState.disconnected;
  @override
  Stream<RealtimeMessage> get eventStream => _eventController.stream;
  @override
  Stream<RealtimeConnectionState> get connectionStateStream =>
      _stateController.stream;
  @override
  RealtimeConnectionState get connectionState => _connectionState;

  String? _activeGameId;
  GameState? _serverGameState;
  int _sequenceNumber = 0;
  Timer? _serverClockTimer;
  int _whiteTimeMs = 300000;
  int _blackTimeMs = 300000;
  int _incrementMs = 0;
  bool _isOpponentAi = true;
  AiDifficulty _opponentDifficulty = AiDifficulty.hard;

  void _setConnectionState(RealtimeConnectionState state) {
    _connectionState = state;
    _stateController.add(state);
  }

  void _emit(RealtimeEventType type, Map<String, dynamic> payload) {
    _sequenceNumber++;
    final msg = RealtimeMessage(
      eventId: _uuid.v4(),
      gameId: _activeGameId ?? 'game_local',
      sequenceNumber: _sequenceNumber,
      type: type,
      payload: payload,
      timestamp: DateTime.now(),
    );
    _eventController.add(msg);
  }

  @override
  Future<void> connect({
    required String token,
    required String gameId,
    int initialSeconds = 300,
    int incrementSeconds = 0,
    bool isAiOpponent = true,
    AiDifficulty opponentDifficulty = AiDifficulty.hard,
  }) async {
    _setConnectionState(RealtimeConnectionState.connecting);
    await Future.delayed(const Duration(milliseconds: 300)); // Simulated connection handshake

    _activeGameId = gameId;
    _serverGameState = ChessBoard.initial();
    _whiteTimeMs = initialSeconds * 1000;
    _blackTimeMs = initialSeconds * 1000;
    _incrementMs = incrementSeconds * 1000;
    _isOpponentAi = isAiOpponent;
    _opponentDifficulty = opponentDifficulty;
    _sequenceNumber = 0;

    _setConnectionState(RealtimeConnectionState.connected);

    // Emit GAME_START
    _emit(RealtimeEventType.gameStart, {
      'gameId': gameId,
      'fen': ChessBoard.startingFen,
      'whiteTimeMs': _whiteTimeMs,
      'blackTimeMs': _blackTimeMs,
      'incrementMs': _incrementMs,
    });

    _startClockTimer();
  }

  void _startClockTimer() {
    _serverClockTimer?.cancel();
    _serverClockTimer =
        Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_serverGameState == null || _serverGameState!.isGameOver) {
        _serverClockTimer?.cancel();
        return;
      }

      if (_serverGameState!.turn.isWhite) {
        _whiteTimeMs -= 100;
        if (_whiteTimeMs <= 0) {
          _whiteTimeMs = 0;
          _handleTimeout(PieceColor.white);
        }
      } else {
        _blackTimeMs -= 100;
        if (_blackTimeMs <= 0) {
          _blackTimeMs = 0;
          _handleTimeout(PieceColor.black);
        }
      }

      // Sync clocks periodically
      if (_sequenceNumber % 10 == 0) {
        _emit(RealtimeEventType.clockSync, {
          'whiteTimeMs': _whiteTimeMs,
          'blackTimeMs': _blackTimeMs,
        });
      }
    });
  }

  void _handleTimeout(PieceColor timedOutColor) {
    _serverClockTimer?.cancel();
    final winnerColor = timedOutColor.opponent;
    _serverGameState = _serverGameState?.copyWith(
      result: GameResult.timeout,
      winner: winnerColor,
      terminationReason: 'Time out: ${winnerColor.name.toUpperCase()} wins on time!',
    );

    _emit(RealtimeEventType.gameOver, {
      'result': 'timeout',
      'winner': winnerColor.name,
      'reason': '${timedOutColor.name.toUpperCase()} ran out of time',
    });
  }

  @override
  void sendMove({required String uci, required int moveSequence}) {
    if (_serverGameState == null || _serverGameState!.isGameOver) return;

    // Server-side move validation!
    final legalMoves = MoveGenerator.generateLegalMoves(_serverGameState!);
    Move? matchedMove;
    for (final move in legalMoves) {
      if (move.uci == uci) {
        matchedMove = move;
        break;
      }
    }

    if (matchedMove == null) {
      AppLogger.warning('Server rejected illegal client move: $uci');
      return;
    }

    // Apply move authoritatively on server
    final movingColor = _serverGameState!.turn;
    _serverGameState = RulesEngine.applyMove(_serverGameState!, matchedMove);

    // Apply increment to player who just moved
    if (movingColor.isWhite) {
      _whiteTimeMs += _incrementMs;
    } else {
      _blackTimeMs += _incrementMs;
    }

    // Broadcast validated move
    _emit(RealtimeEventType.moveMade, {
      'move': matchedMove.toJson(),
      'fen': ChessBoard.toFen(_serverGameState!),
      'whiteTimeMs': _whiteTimeMs,
      'blackTimeMs': _blackTimeMs,
      'isCheck': _serverGameState!.isCheck,
      'isGameOver': _serverGameState!.isGameOver,
      'result': _serverGameState!.result.name,
      'winner': _serverGameState!.winner?.name,
    });

    if (_serverGameState!.isGameOver) {
      _serverClockTimer?.cancel();
      _emit(RealtimeEventType.gameOver, {
        'result': _serverGameState!.result.name,
        'winner': _serverGameState!.winner?.name,
        'reason': _serverGameState!.terminationReason,
      });
      return;
    }

    // If opponent is AI, schedule server-side opponent move
    if (_isOpponentAi && _serverGameState!.turn.isBlack) {
      _scheduleAiOpponentMove();
    }
  }

  void _scheduleAiOpponentMove() {
    Timer(const Duration(milliseconds: 600), () async {
      if (_serverGameState == null ||
          _serverGameState!.isGameOver ||
          !_serverGameState!.turn.isBlack) {
        return;
      }

      final aiMove = await AiIsolateRunner.computeBestMoveAsync(
        _serverGameState!,
        _opponentDifficulty,
      );

      if (aiMove != null) {
        sendMove(uci: aiMove.uci, moveSequence: _sequenceNumber + 1);
      }
    });
  }

  @override
  void offerDraw() {
    _emit(RealtimeEventType.drawOffered, {});
    // Auto-accept if position is drawn
    if (_isOpponentAi) {
      Timer(const Duration(milliseconds: 1000), () {
        acceptDraw();
      });
    }
  }

  @override
  void acceptDraw() {
    _serverClockTimer?.cancel();
    _serverGameState = _serverGameState?.copyWith(
      result: GameResult.drawByAgreement,
      winner: null,
      terminationReason: 'Draw agreed between players.',
    );
    _emit(RealtimeEventType.drawAccepted, {});
    _emit(RealtimeEventType.gameOver, {
      'result': 'drawByAgreement',
      'winner': null,
      'reason': 'Draw by agreement',
    });
  }

  @override
  void declineDraw() {
    _emit(RealtimeEventType.drawDeclined, {});
  }

  @override
  void resign() {
    _serverClockTimer?.cancel();
    final winner = _serverGameState?.turn.opponent ?? PieceColor.black;
    _serverGameState = _serverGameState?.copyWith(
      result: GameResult.resignation,
      winner: winner,
      terminationReason: 'Player resigned.',
    );
    _emit(RealtimeEventType.playerResigned, {'winner': winner.name});
    _emit(RealtimeEventType.gameOver, {
      'result': 'resignation',
      'winner': winner.name,
      'reason': 'Player resigned',
    });
  }

  @override
  void sendPing() {
    _emit(RealtimeEventType.pong, {'latencyMs': 45});
  }

  @override
  Future<void> disconnect() async {
    _serverClockTimer?.cancel();
    _setConnectionState(RealtimeConnectionState.disconnected);
  }

  void dispose() {
    _serverClockTimer?.cancel();
    _eventController.close();
    _stateController.close();
  }
}
