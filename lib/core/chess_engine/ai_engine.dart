import 'dart:math';
import 'game_evaluator.dart';
import 'models/game_state.dart';
import 'models/move.dart';
import 'models/piece.dart';
import 'move_generator.dart';
import 'rules_engine.dart';

enum AiDifficulty {
  beginner('Beginner', 600, 1),
  easy('Easy', 1000, 2),
  medium('Medium', 1400, 3),
  hard('Hard', 1800, 4),
  expert('Expert', 2200, 5),
  master('Master', 2500, 6);

  final String label;
  final int estimatedElo;
  final int searchDepth;

  const AiDifficulty(this.label, this.estimatedElo, this.searchDepth);
}

class AiEngine {
  static final _random = Random();

  /// Find the best move for the active player given a difficulty setting
  static Move? findBestMove(GameState state, AiDifficulty difficulty) {
    final legalMoves = MoveGenerator.generateLegalMoves(state);
    if (legalMoves.isEmpty) return null;
    if (legalMoves.length == 1) return legalMoves.first;

    // Check for immediate mate-in-1
    for (final move in legalMoves) {
      if (move.isCheckmate) return move;
    }

    switch (difficulty) {
      case AiDifficulty.beginner:
        // 35% chance to pick a random legal move, otherwise depth 1 best move
        if (_random.nextDouble() < 0.35) {
          return legalMoves[_random.nextInt(legalMoves.length)];
        }
        return _searchBestMove(state, legalMoves, depth: 1, useQuiescence: false);

      case AiDifficulty.easy:
        // 15% random variance, depth 2 search
        if (_random.nextDouble() < 0.15) {
          return legalMoves[_random.nextInt(legalMoves.length)];
        }
        return _searchBestMove(state, legalMoves, depth: 2, useQuiescence: false);

      case AiDifficulty.medium:
        return _searchBestMove(state, legalMoves, depth: 3, useQuiescence: false);

      case AiDifficulty.hard:
        return _searchBestMove(state, legalMoves, depth: 4, useQuiescence: true);

      case AiDifficulty.expert:
        return _searchBestMove(state, legalMoves, depth: 5, useQuiescence: true);

      case AiDifficulty.master:
        return _searchBestMove(state, legalMoves, depth: 6, useQuiescence: true);
    }
  }

  static Move _searchBestMove(
    GameState state,
    List<Move> legalMoves, {
    required int depth,
    required bool useQuiescence,
  }) {
    final isMaximizing = state.turn.isWhite;
    Move bestMove = legalMoves.first;
    int bestScore = isMaximizing ? -1000000 : 1000000;
    int alpha = -1000000;
    int beta = 1000000;

    final sortedMoves = _orderMoves(legalMoves);

    for (final move in sortedMoves) {
      final nextState = RulesEngine.applyMove(state, move);
      final score = _minimax(
        nextState,
        depth - 1,
        alpha,
        beta,
        !isMaximizing,
        useQuiescence,
      );

      if (isMaximizing) {
        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
        alpha = max(alpha, bestScore);
      } else {
        if (score < bestScore) {
          bestScore = score;
          bestMove = move;
        }
        beta = min(beta, bestScore);
      }

      if (beta <= alpha) {
        break; // Alpha-beta cutoff
      }
    }

    return bestMove;
  }

  static int _minimax(
    GameState state,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
    bool useQuiescence,
  ) {
    if (state.isGameOver) {
      if (state.result == GameResult.checkmate) {
        return state.winner == PieceColor.white ? 100000 + depth : -100000 - depth;
      }
      return 0; // Draw
    }

    if (depth <= 0) {
      if (useQuiescence) {
        return _quiescence(state, alpha, beta, isMaximizing, 2);
      }
      return GameEvaluator.evaluate(state);
    }

    final legalMoves = MoveGenerator.generateLegalMoves(state);
    if (legalMoves.isEmpty) {
      return GameEvaluator.evaluate(state);
    }

    final sortedMoves = _orderMoves(legalMoves);

    if (isMaximizing) {
      int maxEval = -1000000;
      for (final move in sortedMoves) {
        final nextState = RulesEngine.applyMove(state, move);
        final evaluation =
            _minimax(nextState, depth - 1, alpha, beta, false, useQuiescence);
        maxEval = max(maxEval, evaluation);
        alpha = max(alpha, evaluation);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 1000000;
      for (final move in sortedMoves) {
        final nextState = RulesEngine.applyMove(state, move);
        final evaluation =
            _minimax(nextState, depth - 1, alpha, beta, true, useQuiescence);
        minEval = min(minEval, evaluation);
        beta = min(beta, evaluation);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  /// Quiescence search to evaluate tactical sequences and avoid horizon effect
  static int _quiescence(
    GameState state,
    int alpha,
    int beta,
    bool isMaximizing,
    int qDepth,
  ) {
    final standPat = GameEvaluator.evaluate(state);

    if (qDepth <= 0 || state.isGameOver) {
      return standPat;
    }

    if (isMaximizing) {
      if (standPat >= beta) return beta;
      if (standPat > alpha) alpha = standPat;

      final captureMoves = MoveGenerator.generateLegalMoves(state)
          .where((m) => m.isCapture || m.promotion != null)
          .toList();
      final sortedCaptures = _orderMoves(captureMoves);

      for (final move in sortedCaptures) {
        final nextState = RulesEngine.applyMove(state, move);
        final score = _quiescence(nextState, alpha, beta, false, qDepth - 1);
        if (score >= beta) return beta;
        if (score > alpha) alpha = score;
      }
      return alpha;
    } else {
      if (standPat <= alpha) return alpha;
      if (standPat < beta) beta = standPat;

      final captureMoves = MoveGenerator.generateLegalMoves(state)
          .where((m) => m.isCapture || m.promotion != null)
          .toList();
      final sortedCaptures = _orderMoves(captureMoves);

      for (final move in sortedCaptures) {
        final nextState = RulesEngine.applyMove(state, move);
        final score = _quiescence(nextState, alpha, beta, true, qDepth - 1);
        if (score <= alpha) return alpha;
        if (score < beta) beta = score;
      }
      return beta;
    }
  }

  /// Order moves: MVV-LVA (Most Valuable Victim - Least Valuable Attacker) for captures, promotions, and checks
  static List<Move> _orderMoves(List<Move> moves) {
    final scoredMoves = moves.map((m) {
      int score = 0;
      if (m.isCapture) {
        final victimVal = m.capturedPiece?.value ?? 100;
        final attackerVal = m.piece.value;
        score += (victimVal * 10) - attackerVal + 10000;
      }
      if (m.promotion != null) {
        score += 8000;
      }
      if (m.isCheckmate) {
        score += 50000;
      } else if (m.isCheck) {
        score += 2000;
      }
      if (m.isCastling) {
        score += 500;
      }
      return MapEntry(m, score);
    }).toList();

    scoredMoves.sort((a, b) => b.value.compareTo(a.value));
    return scoredMoves.map((e) => e.key).toList();
  }
}
