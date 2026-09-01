import 'dart:async';
import 'dart:isolate';
import 'ai_engine.dart';
import 'board.dart';
import 'models/game_state.dart';
import 'models/move.dart';
import 'move_generator.dart';

class AiIsolateParams {
  final String fen;
  final AiDifficulty difficulty;

  const AiIsolateParams({required this.fen, required this.difficulty});
}

class AiIsolateRunner {
  /// Compute best move asynchronously in background Isolate
  static Future<Move?> computeBestMoveAsync(
    GameState state,
    AiDifficulty difficulty,
  ) async {
    final fen = ChessBoard.toFen(state);
    final params = AiIsolateParams(fen: fen, difficulty: difficulty);

    try {
      // Use Isolate.run for efficient computation without blocking main UI thread
      final bestMoveJson = await Isolate.run(() => _isolateEntry(params));
      if (bestMoveJson == null) return null;

      final uci = bestMoveJson['uci'] as String?;
      if (uci == null) return null;

      final legalMoves = MoveGenerator.generateLegalMoves(state);
      for (final move in legalMoves) {
        if (move.uci == uci) {
          return move;
        }
      }
      return legalMoves.isNotEmpty ? legalMoves.first : null;
    } catch (_) {
      // Safe fallback to main thread computation if isolate fails
      return AiEngine.findBestMove(state, difficulty);
    }
  }

  static Map<String, dynamic>? _isolateEntry(AiIsolateParams params) {
    final state = ChessBoard.fromFen(params.fen);
    final bestMove = AiEngine.findBestMove(state, params.difficulty);
    return bestMove?.toJson();
  }
}
