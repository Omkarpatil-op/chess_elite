import 'models/game_state.dart';
import 'models/piece.dart';
import 'models/square.dart';

class GameEvaluator {
  static const int pawnValue = 100;
  static const int knightValue = 320;
  static const int bishopValue = 330;
  static const int rookValue = 500;
  static const int queenValue = 900;
  static const int checkmateScore = 100000;

  // Piece-Square Tables (from White's perspective, index 0 = a1, 63 = h8)
  static const List<int> _pawnPst = [
    0,   0,   0,   0,   0,   0,   0,   0,
    50,  50,  50,  50,  50,  50,  50,  50,
    10,  10,  20,  30,  30,  20,  10,  10,
    5,   5,  10,  25,  25,  10,   5,   5,
    0,   0,   0,  20,  20,   0,   0,   0,
    5,  -5, -10,   0,   0, -10,  -5,   5,
    5,  10,  10, -20, -20,  10,  10,   5,
    0,   0,   0,   0,   0,   0,   0,   0
  ];

  static const List<int> _knightPst = [
    -50, -40, -30, -30, -30, -30, -40, -50,
    -40, -20,   0,   0,   0,   0, -20, -40,
    -30,   0,  10,  15,  15,  10,   0, -30,
    -30,   5,  15,  20,  20,  15,   5, -30,
    -30,   0,  15,  20,  20,  15,   0, -30,
    -30,   5,  10,  15,  15,  10,   5, -30,
    -40, -20,   0,   5,   5,   0, -20, -40,
    -50, -40, -30, -30, -30, -30, -40, -50,
  ];

  static const List<int> _bishopPst = [
    -20, -10, -10, -10, -10, -10, -10, -20,
    -10,   0,   0,   0,   0,   0,   0, -10,
    -10,   0,   5,  10,  10,   5,   0, -10,
    -10,   5,   5,  10,  10,   5,   5, -10,
    -10,   0,  10,  10,  10,  10,   0, -10,
    -10,  10,  10,  10,  10,  10,  10, -10,
    -10,   5,   0,   0,   0,   0,   5, -10,
    -20, -10, -10, -10, -10, -10, -10, -20,
  ];

  static const List<int> _rookPst = [
    0,   0,   0,   0,   0,   0,   0,   0,
    5,  10,  10,  10,  10,  10,  10,   5,
    -5,   0,   0,   0,   0,   0,   0,  -5,
    -5,   0,   0,   0,   0,   0,   0,  -5,
    -5,   0,   0,   0,   0,   0,   0,  -5,
    -5,   0,   0,   0,   0,   0,   0,  -5,
    -5,   0,   0,   0,   0,   0,   0,  -5,
    0,   0,   0,   5,   5,   0,   0,   0
  ];

  static const List<int> _queenPst = [
    -20, -10, -10,  -5,  -5, -10, -10, -20,
    -10,   0,   0,   0,   0,   0,   0, -10,
    -10,   0,   5,   5,   5,   5,   0, -10,
    -5,   0,   5,   5,   5,   5,   0,  -5,
    0,   0,   5,   5,   5,   5,   0,  -5,
    -10,   5,   5,   5,   5,   5,   0, -10,
    -10,   0,   5,   0,   0,   0,   0, -10,
    -20, -10, -10,  -5,  -5, -10, -10, -20
  ];

  static const List<int> _kingMiddlePst = [
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -20, -30, -30, -40, -40, -30, -30, -20,
    -10, -20, -20, -20, -20, -20, -20, -10,
    20,  20,   0,   0,   0,   0,  20,  20,
    20,  30,  10,   0,   0,  10,  30,  20
  ];

  static const List<int> _kingEndPst = [
    -50, -40, -30, -20, -20, -30, -40, -50,
    -30, -20, -10,   0,   0, -10, -20, -30,
    -30, -10,  20,  30,  30,  20, -10, -30,
    -30, -10,  30,  40,  40,  30, -10, -30,
    -30, -10,  30,  40,  40,  30, -10, -30,
    -30, -10,  20,  30,  30,  20, -10, -30,
    -30, -30,   0,   0,   0,   0, -30, -30,
    -50, -30, -30, -30, -30, -30, -30, -50
  ];

  /// Evaluate the current position in centipawns (+ score favors White, - score favors Black)
  static int evaluate(GameState state) {
    if (state.result == GameResult.checkmate) {
      return state.winner == PieceColor.white ? checkmateScore : -checkmateScore;
    }
    if (state.result.isDraw) {
      return 0;
    }

    int whiteMaterial = 0;
    int blackMaterial = 0;
    int whitePositional = 0;
    int blackPositional = 0;
    int whiteBishops = 0;
    int blackBishops = 0;

    // Detect if we are in endgame (few non-pawn pieces)
    int majorMinorPiecesCount = 0;
    for (final piece in state.board) {
      if (piece != null &&
          piece.type != PieceType.pawn &&
          piece.type != PieceType.king) {
        majorMinorPiecesCount++;
      }
    }
    final isEndgame = majorMinorPiecesCount <= 4;

    for (int idx = 0; idx < 64; idx++) {
      final piece = state.board[idx];
      if (piece == null) continue;

      final square = Square.fromIndex(idx);
      // For black, flip rank to read PST symmetrically from black's perspective
      final pstRank = piece.isWhite ? 7 - square.rank : square.rank;
      final pstIndex = pstRank * 8 + square.file;

      int pieceVal = piece.value;
      int pstVal = 0;

      switch (piece.type) {
        case PieceType.pawn:
          pstVal = _pawnPst[pstIndex];
          break;
        case PieceType.knight:
          pstVal = _knightPst[pstIndex];
          break;
        case PieceType.bishop:
          pstVal = _bishopPst[pstIndex];
          if (piece.isWhite) whiteBishops++;
          if (piece.isBlack) blackBishops++;
          break;
        case PieceType.rook:
          pstVal = _rookPst[pstIndex];
          break;
        case PieceType.queen:
          pstVal = _queenPst[pstIndex];
          break;
        case PieceType.king:
          pstVal = isEndgame
              ? _kingEndPst[pstIndex]
              : _kingMiddlePst[pstIndex];
          break;
      }

      if (piece.isWhite) {
        whiteMaterial += pieceVal;
        whitePositional += pstVal;
      } else {
        blackMaterial += pieceVal;
        blackPositional += pstVal;
      }
    }

    // Bishop pair bonus (+30 cp)
    if (whiteBishops >= 2) whitePositional += 30;
    if (blackBishops >= 2) blackPositional += 30;

    final whiteTotal = whiteMaterial + whitePositional;
    final blackTotal = blackMaterial + blackPositional;

    return whiteTotal - blackTotal;
  }
}
