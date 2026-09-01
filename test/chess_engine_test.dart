import 'package:flutter_test/flutter_test.dart';
import 'package:chess_elite/core/chess_engine/board.dart';
import 'package:chess_elite/core/chess_engine/models/game_state.dart';
import 'package:chess_elite/core/chess_engine/models/move.dart';
import 'package:chess_elite/core/chess_engine/models/piece.dart';
import 'package:chess_elite/core/chess_engine/models/square.dart';
import 'package:chess_elite/core/chess_engine/move_generator.dart';
import 'package:chess_elite/core/chess_engine/pgn_processor.dart';
import 'package:chess_elite/core/chess_engine/rules_engine.dart';

void main() {
  group('Chess Engine - Board & FEN', () {
    test('Initial board setup and FEN generation', () {
      final state = ChessBoard.initial();
      expect(state.turn, PieceColor.white);
      expect(state.board.where((p) => p != null).length, 32);
      expect(state.castlingRights.whiteKingside, true);
      expect(state.castlingRights.whiteQueenside, true);
      expect(state.castlingRights.blackKingside, true);
      expect(state.castlingRights.blackQueenside, true);
      expect(state.enPassantTarget, isNull);
      expect(ChessBoard.toFen(state), ChessBoard.startingFen);
    });

    test('Custom FEN parsing and serialization round-trip', () {
      const fen = 'r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4';
      final state = ChessBoard.fromFen(fen);
      expect(state.turn, PieceColor.white);
      expect(state.pieceAt(Square.fromName('c4'))?.type, PieceType.bishop);
      expect(state.pieceAt(Square.fromName('c6'))?.type, PieceType.knight);
      expect(ChessBoard.toFen(state), fen);
    });
  });

  group('Chess Engine - Pawn Rules & Special Moves', () {
    test('Initial pawn double push and single push', () {
      final state = ChessBoard.initial();
      final moves = MoveGenerator.generateLegalMoves(state);

      // e2 can move to e3 and e4
      final e2e4 = moves.firstWhere((m) => m.from.name == 'e2' && m.to.name == 'e4');
      expect(e2e4.san, 'e4');

      final nextState = RulesEngine.applyMove(state, e2e4);
      expect(nextState.turn, PieceColor.black);
      expect(nextState.enPassantTarget?.name, 'e3');
    });

    test('En passant capture (immediate vs expired)', () {
      // 1. e4 Nf6 2. e5 d5 -> White can capture exd6 e.p.
      var state = ChessBoard.initial();
      state = RulesEngine.applyMove(
        state,
        MoveGenerator.generateLegalMoves(state)
            .firstWhere((m) => m.from.name == 'e2' && m.to.name == 'e4'),
      );
      state = RulesEngine.applyMove(
        state,
        MoveGenerator.generateLegalMoves(state)
            .firstWhere((m) => m.from.name == 'g8' && m.to.name == 'f6'),
      );
      state = RulesEngine.applyMove(
        state,
        MoveGenerator.generateLegalMoves(state)
            .firstWhere((m) => m.from.name == 'e4' && m.to.name == 'e5'),
      );
      state = RulesEngine.applyMove(
        state,
        MoveGenerator.generateLegalMoves(state)
            .firstWhere((m) => m.from.name == 'd7' && m.to.name == 'd5'),
      );

      expect(state.enPassantTarget?.name, 'd6');
      final whiteMoves = MoveGenerator.generateLegalMoves(state);
      final enPassantMove = whiteMoves.firstWhere(
        (m) => m.from.name == 'e5' && m.to.name == 'd6',
      );
      expect(enPassantMove.isEnPassant, true);
      expect(enPassantMove.san, 'exd6');

      // Apply en passant move and check black pawn on d5 is removed
      final afterCapture = RulesEngine.applyMove(state, enPassantMove);
      expect(afterCapture.pieceAt(Square.fromName('d5')), isNull);
      expect(afterCapture.pieceAt(Square.fromName('d6'))?.type, PieceType.pawn);
      expect(afterCapture.pieceAt(Square.fromName('d6'))?.color, PieceColor.white);
    });

    test('Pawn Promotion (Queen, Rook, Bishop, Knight)', () {
      // White pawn on e7, black king on h8
      const promoFen = '7k/4P3/8/8/8/8/8/4K3 w - - 0 1';
      final state = ChessBoard.fromFen(promoFen);
      final moves = MoveGenerator.generateLegalMoves(state);

      final promoMoves = moves.where((m) => m.from.name == 'e7' && m.to.name == 'e8').toList();
      expect(promoMoves.length, 4);

      final queenPromo = promoMoves.firstWhere((m) => m.promotion == PieceType.queen);
      expect(queenPromo.san.startsWith('e8=Q'), true);

      final promotedState = RulesEngine.applyMove(state, queenPromo);
      expect(promotedState.pieceAt(Square.fromName('e8'))?.type, PieceType.queen);
      expect(promotedState.pieceAt(Square.fromName('e8'))?.color, PieceColor.white);
    });
  });

  group('Chess Engine - Castling Rules', () {
    test('Kingside and Queenside castling legality', () {
      // White can castle both kingside and queenside
      const castlingFen = 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1';
      final state = ChessBoard.fromFen(castlingFen);
      final moves = MoveGenerator.generateLegalMoves(state);

      final kingside = moves.firstWhere((m) => m.isKingsideCastling);
      expect(kingside.san, 'O-O');
      expect(kingside.to.name, 'g1');

      final queenside = moves.firstWhere((m) => m.isQueensideCastling);
      expect(queenside.san, 'O-O-O');
      expect(queenside.to.name, 'c1');

      // Execute kingside castling
      final castledState = RulesEngine.applyMove(state, kingside);
      expect(castledState.pieceAt(Square.fromName('g1'))?.type, PieceType.king);
      expect(castledState.pieceAt(Square.fromName('f1'))?.type, PieceType.rook);
      expect(castledState.pieceAt(Square.fromName('h1')), isNull);
      expect(castledState.castlingRights.whiteKingside, false);
      expect(castledState.castlingRights.whiteQueenside, false);
    });

    test('Castling prohibited when in check or passing through attacked square', () {
      // Black rook on e8 checks White king on e1
      const inCheckFen = '4r3/8/8/8/8/8/8/R3K2R w KQ - 0 1';
      final state = ChessBoard.fromFen(inCheckFen);
      final moves = MoveGenerator.generateLegalMoves(state);
      expect(moves.any((m) => m.isCastling), false);

      // Black rook on f8 attacks f1 (square king must pass through for O-O)
      const throughCheckFen = '5r2/8/8/8/8/8/8/R3K2R w KQ - 0 1';
      final state2 = ChessBoard.fromFen(throughCheckFen);
      final moves2 = MoveGenerator.generateLegalMoves(state2);
      expect(moves2.any((m) => m.isKingsideCastling), false);
      expect(moves2.any((m) => m.isQueensideCastling), true); // Queenside is not attacked
    });
  });

  group('Chess Engine - Check, Checkmate & Stalemate', () {
    test("Fool's Mate (Fastest Checkmate in 2 moves)", () {
      // 1. f3 e5 2. g4 Qh4#
      var state = ChessBoard.initial();
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'f2' && m.to.name == 'f3'));
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'e7' && m.to.name == 'e5'));
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'g2' && m.to.name == 'g4'));

      final blackMoves = MoveGenerator.generateLegalMoves(state);
      final qh4 = blackMoves.firstWhere((m) => m.from.name == 'd8' && m.to.name == 'h4');
      expect(qh4.isCheckmate, true);
      expect(qh4.san, 'Qh4#');

      final mateState = RulesEngine.applyMove(state, qh4);
      expect(mateState.result, GameResult.checkmate);
      expect(mateState.winner, PieceColor.black);
      expect(mateState.isGameOver, true);
    });

    test('Scholar\'s Mate (1. e4 e5 2. Qh5 Nc6 3. Bc4 Nf6 4. Qxf7#)', () {
      var state = ChessBoard.initial();
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'e2' && m.to.name == 'e4'));
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'e7' && m.to.name == 'e5'));
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'd1' && m.to.name == 'h5'));
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'b8' && m.to.name == 'c6'));
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'f1' && m.to.name == 'c4'));
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'g8' && m.to.name == 'f6'));

      final whiteMoves = MoveGenerator.generateLegalMoves(state);
      final qxf7 = whiteMoves.firstWhere((m) => m.from.name == 'h5' && m.to.name == 'f7');
      expect(qxf7.isCheckmate, true);
      expect(qxf7.san, 'Qxf7#');

      final finalState = RulesEngine.applyMove(state, qxf7);
      expect(finalState.result, GameResult.checkmate);
      expect(finalState.winner, PieceColor.white);
    });

    test('Stalemate Position Detection', () {
      // Known stalemate: Black King on a8, White Queen on c7, White King on c6, Black to move
      const stalemateFen = 'k7/2Q5/2K5/8/8/8/8/8 b - - 0 1';
      final state = ChessBoard.fromFen(stalemateFen);
      final legalMoves = MoveGenerator.generateLegalMoves(state);
      expect(legalMoves.isEmpty, true);

      // Verify applying state rules recognizes stalemate
      final evaluated = RulesEngine.applyMove(
        ChessBoard.fromFen('k7/8/2K5/8/8/8/8/1Q6 w - - 0 1'),
        Move(
          from: Square.fromName('b1'),
          to: Square.fromName('c7'),
          piece: Piece(type: PieceType.queen, color: PieceColor.white),
        ),
      );
      expect(evaluated.result, GameResult.stalemate);
      expect(evaluated.winner, isNull);
    });
  });

  group('Chess Engine - Draws', () {
    test('Insufficient Material (King vs King, King+Bishop vs King, King+Knight vs King)', () {
      // King vs King
      expect(RulesEngine.isInsufficientMaterial(ChessBoard.fromFen('8/8/8/4k3/8/8/4K3/8 w - - 0 1').board), true);

      // King + Knight vs King
      expect(RulesEngine.isInsufficientMaterial(ChessBoard.fromFen('8/8/8/4k3/8/5N2/4K3/8 w - - 0 1').board), true);

      // King + Bishop vs King
      expect(RulesEngine.isInsufficientMaterial(ChessBoard.fromFen('8/8/8/4k3/8/5B2/4K3/8 w - - 0 1').board), true);

      // King + Rook vs King (Sufficient to mate)
      expect(RulesEngine.isInsufficientMaterial(ChessBoard.fromFen('8/8/8/4k3/8/5R2/4K3/8 w - - 0 1').board), false);
    });

    test('Threefold Repetition', () {
      // Repeat Knights back and forth 3 times: 1. Nf3 Nf6 2. Ng1 Ng8 3. Nf3 Nf6 4. Ng1 Ng8
      var state = ChessBoard.initial();
      for (int i = 0; i < 2; i++) {
        state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'g1' && m.to.name == 'f3'));
        state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'g8' && m.to.name == 'f6'));
        state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'f3' && m.to.name == 'g1'));
        state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'f6' && m.to.name == 'g8'));
      }
      expect(state.result, GameResult.drawByRepetition);
    });
  });

  group('Chess Engine - PGN Processor', () {
    test('PGN Export and Parse round trip', () {
      var state = ChessBoard.initial();
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'e2' && m.to.name == 'e4'));
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'e7' && m.to.name == 'e5'));
      state = RulesEngine.applyMove(state, MoveGenerator.generateLegalMoves(state).firstWhere((m) => m.from.name == 'g1' && m.to.name == 'f3'));

      final pgn = PgnProcessor.exportPgn(
        state: state,
        white: 'Magnus Carlsen',
        black: 'Hikaru Nakamura',
        whiteElo: 2850,
        blackElo: 2820,
      );

      expect(pgn.contains('[White "Magnus Carlsen"]'), true);
      expect(pgn.contains('1. e4 e5 2. Nf3'), true);

      final parsed = PgnProcessor.parsePgn(pgn);
      expect(parsed.headers['White'], 'Magnus Carlsen');
      expect(parsed.headers['WhiteElo'], '2850');
      expect(parsed.sanMoves, ['e4', 'e5', 'Nf3']);
    });
  });
}
