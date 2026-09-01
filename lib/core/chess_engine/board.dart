import 'models/castling_rights.dart';
import 'models/game_state.dart';
import 'models/piece.dart';
import 'models/square.dart';

class ChessBoard {
  static const String startingFen =
      'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

  /// Create initial standard chess game state
  static GameState initial() {
    return fromFen(startingFen);
  }

  /// Parse GameState from FEN string
  static GameState fromFen(String fen) {
    final parts = fen.trim().split(RegExp(r'\s+'));
    if (parts.length < 4) {
      throw ArgumentError('Invalid FEN string (insufficient fields): $fen');
    }

    final piecePlacement = parts[0];
    final activeColorStr = parts[1];
    final castlingStr = parts[2];
    final enPassantStr = parts[3];
    final halfmoveStr = parts.length > 4 ? parts[4] : '0';
    final fullmoveStr = parts.length > 5 ? parts[5] : '1';

    // 1. Piece Placement
    final board = List<Piece?>.filled(64, null);
    final ranks = piecePlacement.split('/');
    if (ranks.length != 8) {
      throw ArgumentError('Invalid FEN piece placement ranks: $piecePlacement');
    }

    for (int rankIdx = 0; rankIdx < 8; rankIdx++) {
      // FEN starts from rank 8 (top, rankIdx 0 -> board rank 7) down to rank 1 (rankIdx 7 -> board rank 0)
      final boardRank = 7 - rankIdx;
      final rankStr = ranks[rankIdx];
      int file = 0;

      for (int i = 0; i < rankStr.length; i++) {
        final char = rankStr[i];
        final digit = int.tryParse(char);
        if (digit != null) {
          file += digit;
        } else {
          final piece = Piece.fromSymbol(char);
          if (piece != null && file < 8) {
            board[boardRank * 8 + file] = piece;
          }
          file++;
        }
      }
    }

    // 2. Active Color
    final turn = activeColorStr.toLowerCase() == 'w'
        ? PieceColor.white
        : PieceColor.black;

    // 3. Castling Rights
    final castlingRights = CastlingRights.fromFen(castlingStr);

    // 4. En Passant Target Square
    final enPassantTarget =
        enPassantStr != '-' ? Square.tryParse(enPassantStr) : null;

    // 5. Halfmove Clock & Fullmove Number
    final halfmoveClock = int.tryParse(halfmoveStr) ?? 0;
    final fullmoveNumber = int.tryParse(fullmoveStr) ?? 1;

    final state = GameState(
      board: board,
      turn: turn,
      castlingRights: castlingRights,
      enPassantTarget: enPassantTarget,
      halfmoveClock: halfmoveClock,
      fullmoveNumber: fullmoveNumber,
    );

    return state.copyWith(
      positionHistory: [positionHash(state)],
    );
  }

  /// Convert GameState to FEN string
  static String toFen(GameState state) {
    final buffer = StringBuffer();

    // 1. Piece Placement
    for (int rank = 7; rank >= 0; rank--) {
      int emptyCount = 0;
      for (int file = 0; file < 8; file++) {
        final piece = state.pieceAtCoords(file, rank);
        if (piece == null) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            buffer.write(emptyCount);
            emptyCount = 0;
          }
          buffer.write(piece.symbol);
        }
      }
      if (emptyCount > 0) {
        buffer.write(emptyCount);
      }
      if (rank > 0) {
        buffer.write('/');
      }
    }

    // 2. Turn
    buffer.write(' ');
    buffer.write(state.turn.isWhite ? 'w' : 'b');

    // 3. Castling
    buffer.write(' ');
    buffer.write(state.castlingRights.toFen());

    // 4. En Passant
    buffer.write(' ');
    buffer.write(state.enPassantTarget?.name ?? '-');

    // 5. Halfmove & Fullmove
    buffer.write(' ');
    buffer.write(state.halfmoveClock);
    buffer.write(' ');
    buffer.write(state.fullmoveNumber);

    return buffer.toString();
  }

  /// Canonical position hash for Threefold Repetition tracking
  /// Includes piece positions, active turn, castling rights, and valid en passant target
  static String positionHash(GameState state) {
    final buffer = StringBuffer();
    for (int i = 0; i < 64; i++) {
      final p = state.board[i];
      buffer.write(p == null ? '.' : p.symbol);
    }
    buffer.write(' ');
    buffer.write(state.turn.isWhite ? 'w' : 'b');
    buffer.write(' ');
    buffer.write(state.castlingRights.toFen());
    buffer.write(' ');
    buffer.write(state.enPassantTarget?.name ?? '-');
    return buffer.toString();
  }
}
