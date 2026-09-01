import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chess_elite/core/chess_engine/board.dart';
import 'package:chess_elite/core/chess_engine/models/move.dart';
import 'package:chess_elite/core/chess_engine/models/piece.dart';
import 'package:chess_elite/presentation/widgets/chess_board_widget.dart';
import 'package:chess_elite/presentation/widgets/chess_clock_widget.dart';

void main() {
  group('ChessBoardWidget - UI & Interaction', () {
    testWidgets('Board renders 64 squares and initial coordinates', (WidgetTester tester) async {
      final state = ChessBoard.initial();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChessBoardWidget(
              gameState: state,
              showCoordinates: true,
              showLegalMoves: true,
            ),
          ),
        ),
      );

      // Verify coordinate text widgets rendered
      expect(find.text('a'), findsOneWidget);
      expect(find.text('h'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('Tapping on white pawn highlights square and legal moves', (WidgetTester tester) async {
      final state = ChessBoard.initial();
      Move? executedMove;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChessBoardWidget(
              gameState: state,
              showCoordinates: true,
              showLegalMoves: true,
              onMove: (move) => executedMove = move,
            ),
          ),
        ),
      );

      // Find square by semantic label
      final e2Square = find.bySemanticsLabel(RegExp(r'e2, white pawn'));
      expect(e2Square, findsOneWidget);

      // Tap e2 square
      await tester.tap(e2Square);
      await tester.pump();

      // Tap e4 square to execute move
      final e4Square = find.bySemanticsLabel(RegExp(r'e4, empty square, legal move target'));
      expect(e4Square, findsOneWidget);

      await tester.tap(e4Square);
      await tester.pump();

      expect(executedMove, isNotNull);
      expect(executedMove!.san, 'e4');
    });
  });

  group('ChessClockWidget - UI', () {
    testWidgets('Clock displays minutes and seconds', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChessClockWidget(
              playerColor: PieceColor.white,
              remainingMs: 300000, // 5 min
              isActive: true,
              playerName: 'Magnus',
              playerRating: 2850,
            ),
          ),
        ),
      );

      expect(find.text('5:00'), findsOneWidget);
      expect(find.text('Magnus'), findsOneWidget);
      expect(find.text('2850'), findsOneWidget);
    });

    testWidgets('Low time clock displays tenths of seconds', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChessClockWidget(
              playerColor: PieceColor.black,
              remainingMs: 8400, // 8.4 seconds
              isActive: true,
              playerName: 'Opponent',
            ),
          ),
        ),
      );

      expect(find.text('0:08.4'), findsOneWidget);
    });
  });
}
