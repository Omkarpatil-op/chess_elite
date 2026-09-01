import 'board.dart';
import 'models/game_state.dart';
import 'models/move.dart';
import 'models/piece.dart';
import 'models/square.dart';
import 'move_generator.dart';

class RulesEngine {
  /// Apply a legal move to the GameState and return the updated next GameState
  static GameState applyMove(GameState state, Move move) {
    if (state.isGameOver) {
      throw StateError('Cannot make a move in a finished game');
    }

    final newBoard = List<Piece?>.from(state.board);
    final movingPiece = move.piece;
    final movingColor = movingPiece.color;
    final opponentColor = movingColor.opponent;

    // 1. Move piece on board
    newBoard[move.from.index] = null;
    newBoard[move.to.index] = move.promotion != null
        ? Piece(type: move.promotion!, color: movingColor)
        : movingPiece;

    // 2. Handle En Passant capture
    if (move.isEnPassant) {
      final capturedPawnSquare =
          Square(file: move.to.file, rank: move.from.rank);
      newBoard[capturedPawnSquare.index] = null;
    }

    // 3. Handle Castling rook repositioning
    if (move.isKingsideCastling) {
      final rank = move.from.rank;
      newBoard[rank * 8 + 7] = null; // Clear h-file rook
      newBoard[rank * 8 + 5] =
          Piece(type: PieceType.rook, color: movingColor); // Place on f-file
    } else if (move.isQueensideCastling) {
      final rank = move.from.rank;
      newBoard[rank * 8 + 0] = null; // Clear a-file rook
      newBoard[rank * 8 + 3] =
          Piece(type: PieceType.rook, color: movingColor); // Place on d-file
    }

    // 4. Update Castling Rights
    var newCastling = state.castlingRights;

    // If king moves, lose all castling rights for that color
    if (movingPiece.type == PieceType.king) {
      if (movingColor.isWhite) {
        newCastling = newCastling.copyWith(
          whiteKingside: false,
          whiteQueenside: false,
        );
      } else {
        newCastling = newCastling.copyWith(
          blackKingside: false,
          blackQueenside: false,
        );
      }
    }

    // If rook moves from original square
    if (movingPiece.type == PieceType.rook) {
      if (movingColor.isWhite) {
        if (move.from.name == 'h1') {
          newCastling = newCastling.copyWith(whiteKingside: false);
        } else if (move.from.name == 'a1') {
          newCastling = newCastling.copyWith(whiteQueenside: false);
        }
      } else {
        if (move.from.name == 'h8') {
          newCastling = newCastling.copyWith(blackKingside: false);
        } else if (move.from.name == 'a8') {
          newCastling = newCastling.copyWith(blackQueenside: false);
        }
      }
    }

    // If rook is captured on its original square
    if (move.to.name == 'h1') {
      newCastling = newCastling.copyWith(whiteKingside: false);
    } else if (move.to.name == 'a1') {
      newCastling = newCastling.copyWith(whiteQueenside: false);
    } else if (move.to.name == 'h8') {
      newCastling = newCastling.copyWith(blackKingside: false);
    } else if (move.to.name == 'a8') {
      newCastling = newCastling.copyWith(blackQueenside: false);
    }

    // 5. Update En Passant Target
    Square? newEnPassantTarget;
    if (movingPiece.type == PieceType.pawn &&
        (move.to.rank - move.from.rank).abs() == 2) {
      newEnPassantTarget = Square(
        file: move.from.file,
        rank: (move.from.rank + move.to.rank) ~/ 2,
      );
    }

    // 6. Update Halfmove Clock (50-move rule)
    int newHalfmove = state.halfmoveClock + 1;
    if (movingPiece.type == PieceType.pawn || move.isCapture) {
      newHalfmove = 0;
    }

    // 7. Update Fullmove Number
    int newFullmove = state.fullmoveNumber;
    if (movingColor.isBlack) {
      newFullmove += 1;
    }

    // 8. Create intermediary next state for checking check/game result
    final nextTurn = opponentColor;
    final isOpponentInCheck =
        MoveGenerator.isKingInCheck(newBoard, opponentColor);

    final provisionalState = GameState(
      board: newBoard,
      turn: nextTurn,
      castlingRights: newCastling,
      enPassantTarget: newEnPassantTarget,
      halfmoveClock: newHalfmove,
      fullmoveNumber: newFullmove,
      moveHistory: [...state.moveHistory, move],
      positionHistory: state.positionHistory,
      isCheck: isOpponentInCheck,
    );

    // Compute canonical position hash
    final newHash = ChessBoard.positionHash(provisionalState);
    final newPositionHistory = [...state.positionHistory, newHash];

    // 9. Evaluate Game Termination Conditions
    final opponentLegalMoves =
        MoveGenerator.generateLegalMoves(provisionalState);

    GameResult finalResult = GameResult.ongoing;
    PieceColor? finalWinner;
    String? reason;

    if (opponentLegalMoves.isEmpty) {
      if (isOpponentInCheck) {
        finalResult = GameResult.checkmate;
        finalWinner = movingColor;
        reason = 'Checkmate: ${movingColor.name.toUpperCase()} wins!';
      } else {
        finalResult = GameResult.stalemate;
        finalWinner = null;
        reason = 'Draw by stalemate.';
      }
    } else if (newHalfmove >= 100) {
      finalResult = GameResult.drawByFiftyMoves;
      finalWinner = null;
      reason = 'Draw by 50-move rule (no pawn move or capture in 50 moves).';
    } else if (_isThreefoldRepetition(newPositionHistory, newHash)) {
      finalResult = GameResult.drawByRepetition;
      finalWinner = null;
      reason = 'Draw by threefold repetition.';
    } else if (isInsufficientMaterial(newBoard)) {
      finalResult = GameResult.drawByInsufficientMaterial;
      finalWinner = null;
      reason = 'Draw by insufficient material to force checkmate.';
    }

    return provisionalState.copyWith(
      positionHistory: newPositionHistory,
      result: finalResult,
      winner: finalWinner,
      terminationReason: reason,
      isCheck: isOpponentInCheck,
    );
  }

  /// Check if the current position has occurred 3 or more times
  static bool _isThreefoldRepetition(
    List<String> history,
    String currentHash,
  ) {
    int count = 0;
    for (final h in history) {
      if (h == currentHash) {
        count++;
      }
    }
    return count >= 3;
  }

  /// Detect FIDE standard Insufficient Material draw scenarios
  static bool isInsufficientMaterial(List<Piece?> board) {
    final whitePieces = <Piece>[];
    final blackPieces = <Piece>[];
    final whiteBishopSquares = <Square>[];
    final blackBishopSquares = <Square>[];

    for (int i = 0; i < 64; i++) {
      final piece = board[i];
      if (piece == null) continue;
      if (piece.isWhite) {
        whitePieces.add(piece);
        if (piece.type == PieceType.bishop) {
          whiteBishopSquares.add(Square.fromIndex(i));
        }
      } else {
        blackPieces.add(piece);
        if (piece.type == PieceType.bishop) {
          blackBishopSquares.add(Square.fromIndex(i));
        }
      }
    }

    // Any pawn, rook, or queen means sufficient material
    final allPieces = [...whitePieces, ...blackPieces];
    if (allPieces.any((p) =>
        p.type == PieceType.pawn ||
        p.type == PieceType.rook ||
        p.type == PieceType.queen)) {
      return false;
    }

    // 1. King vs King
    if (whitePieces.length == 1 && blackPieces.length == 1) {
      return true;
    }

    // 2. King + Bishop vs King or King + Knight vs King
    if ((whitePieces.length == 2 && blackPieces.length == 1) ||
        (whitePieces.length == 1 && blackPieces.length == 2)) {
      final minorPieceSet = whitePieces.length == 2 ? whitePieces : blackPieces;
      final minor = minorPieceSet.firstWhere((p) => p.type != PieceType.king);
      if (minor.type == PieceType.bishop || minor.type == PieceType.knight) {
        return true;
      }
    }

    // 3. King + Bishop vs King + Bishop where bishops are on same color squares
    if (whitePieces.length == 2 &&
        blackPieces.length == 2 &&
        whiteBishopSquares.length == 1 &&
        blackBishopSquares.length == 1) {
      final whiteBishopIsLight = whiteBishopSquares.first.isLight;
      final blackBishopIsLight = blackBishopSquares.first.isLight;
      if (whiteBishopIsLight == blackBishopIsLight) {
        return true;
      }
    }

    return false;
  }
}
