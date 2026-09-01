import 'board.dart';
import 'models/game_state.dart';
import 'models/move.dart';
import 'models/piece.dart';
import 'move_generator.dart';
import 'rules_engine.dart';

class PgnGame {
  final Map<String, String> headers;
  final List<String> sanMoves;
  final String result;

  const PgnGame({
    required this.headers,
    required this.sanMoves,
    required this.result,
  });
}

class PgnProcessor {
  /// Export a GameState and match metadata to a standard PGN string
  static String exportPgn({
    required GameState state,
    String event = 'Casual Game',
    String site = 'Chess Elite App',
    String? date,
    String round = '1',
    String white = 'White Player',
    String black = 'Black Player',
    int? whiteElo,
    int? blackElo,
    String? timeControl,
  }) {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final formattedDate = date ??
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    final resultStr = switch (state.result) {
      GameResult.checkmate =>
        state.winner == PieceColor.white ? '1-0' : '0-1',
      GameResult.resignation =>
        state.winner == PieceColor.white ? '1-0' : '0-1',
      GameResult.timeout =>
        state.winner == PieceColor.white ? '1-0' : '0-1',
      GameResult.stalemate ||
      GameResult.drawByRepetition ||
      GameResult.drawByFiftyMoves ||
      GameResult.drawByInsufficientMaterial ||
      GameResult.drawByAgreement =>
        '1/2-1/2',
      _ => '*',
    };

    // 1. Seven Tag Roster (Standard PGN Headers)
    buffer.writeln('[Event "$event"]');
    buffer.writeln('[Site "$site"]');
    buffer.writeln('[Date "$formattedDate"]');
    buffer.writeln('[Round "$round"]');
    buffer.writeln('[White "$white"]');
    buffer.writeln('[Black "$black"]');
    buffer.writeln('[Result "$resultStr"]');

    if (whiteElo != null) buffer.writeln('[WhiteElo "$whiteElo"]');
    if (blackElo != null) buffer.writeln('[BlackElo "$blackElo"]');
    if (timeControl != null) buffer.writeln('[TimeControl "$timeControl"]');
    buffer.writeln();

    // 2. Move Text
    final moveBuffer = StringBuffer();
    for (int i = 0; i < state.moveHistory.length; i++) {
      if (i % 2 == 0) {
        final moveNumber = (i ~/ 2) + 1;
        moveBuffer.write('$moveNumber. ');
      }
      moveBuffer.write('${state.moveHistory[i].san} ');
    }
    moveBuffer.write(resultStr);

    buffer.writeln(moveBuffer.toString());
    return buffer.toString();
  }

  /// Parse a PGN string into header tags and move list
  static PgnGame parsePgn(String pgn) {
    final headers = <String, String>{};
    final moveTokens = <String>[];
    String result = '*';

    final lines = pgn.split('\n');
    final moveLines = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        final match = RegExp(r'^\[(\w+)\s+"(.*)"\]$').firstMatch(trimmed);
        if (match != null) {
          headers[match.group(1)!] = match.group(2)!;
        }
      } else if (!trimmed.startsWith(';')) {
        moveLines.add(trimmed);
      }
    }

    if (headers.containsKey('Result')) {
      result = headers['Result']!;
    }

    final rawMoveText = moveLines.join(' ');
    // Remove comments { ... }
    final cleanText = rawMoveText.replaceAll(RegExp(r'\{[^}]*\}'), '');

    // Split by whitespace
    final tokens = cleanText.split(RegExp(r'\s+'));
    for (final token in tokens) {
      final t = token.trim();
      if (t.isEmpty) continue;
      // Skip move numbers like "1.", "12..."
      if (RegExp(r'^\d+\.+$').hasMatch(t)) continue;
      // If token starts with number (e.g. "1.e4"), strip the number
      final stripped = t.replaceFirst(RegExp(r'^\d+\.+'), '');
      if (stripped == '1-0' ||
          stripped == '0-1' ||
          stripped == '1/2-1/2' ||
          stripped == '*') {
        result = stripped;
        continue;
      }
      if (stripped.isNotEmpty) {
        moveTokens.add(stripped);
      }
    }

    return PgnGame(
      headers: headers,
      sanMoves: moveTokens,
      result: result,
    );
  }

  /// Replay a list of SAN moves from starting position
  static GameState replayMoves(List<String> sanMoves) {
    var state = ChessBoard.initial();

    for (final san in sanMoves) {
      final legalMoves = MoveGenerator.generateLegalMoves(state);
      Move? matchedMove;

      for (final move in legalMoves) {
        if (move.san == san ||
            move.san.replaceAll('+', '').replaceAll('#', '') ==
                san.replaceAll('+', '').replaceAll('#', '')) {
          matchedMove = move;
          break;
        }
      }

      if (matchedMove != null) {
        state = RulesEngine.applyMove(state, matchedMove);
      } else {
        break; // Unable to match move
      }
    }

    return state;
  }
}
