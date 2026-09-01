import 'package:flutter_test/flutter_test.dart';
import 'package:chess_elite/core/chess_engine/ai_engine.dart';
import 'package:chess_elite/core/chess_engine/ai_isolate.dart';
import 'package:chess_elite/core/chess_engine/board.dart';

void main() {
  group('AI Engine - Tactical Intelligence', () {
    test('Finds immediate mate in 1 (Scholar\'s mate finish)', () {
      // 1. e4 e5 2. Qh5 Nc6 3. Bc4 Nf6 -> Qxf7# is mate in 1
      const mateInOneFen = 'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4';
      final state = ChessBoard.fromFen(mateInOneFen);

      final bestMove = AiEngine.findBestMove(state, AiDifficulty.hard);
      expect(bestMove, isNotNull);
      expect(bestMove!.san, 'Qxf7#');
      expect(bestMove.isCheckmate, true);
    });

    test('Finds immediate mate in 1 for Black', () {
      // 1. f3 e5 2. g4 -> Qh4# is mate in 1 for Black
      const foolsMateFen = 'rnbqkbnr/pppp1ppp/8/4p3/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq - 0 2';
      final state = ChessBoard.fromFen(foolsMateFen);

      final bestMove = AiEngine.findBestMove(state, AiDifficulty.medium);
      expect(bestMove, isNotNull);
      expect(bestMove!.san, 'Qh4#');
      expect(bestMove.isCheckmate, true);
    });

    test('Captures hanging undefended Queen', () {
      // White bishop on c4 can capture hanging black queen on e6
      const hangingQueenFen = 'rnb1kbnr/pppp1ppp/4q3/8/2B5/8/PPPPPPPP/RNBQK1NR w KQkq - 0 1';
      final state = ChessBoard.fromFen(hangingQueenFen);

      final bestMove = AiEngine.findBestMove(state, AiDifficulty.medium);
      expect(bestMove, isNotNull);
      expect(bestMove!.to.name, 'e6');
    });

    test('AI Isolate Runner executes successfully', () async {
      const fen = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1';
      final state = ChessBoard.fromFen(fen);

      final move = await AiIsolateRunner.computeBestMoveAsync(state, AiDifficulty.easy);
      expect(move, isNotNull);
    });
  });
}
