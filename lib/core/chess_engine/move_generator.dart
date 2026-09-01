import 'models/game_state.dart';
import 'models/move.dart';
import 'models/piece.dart';
import 'models/square.dart';

class MoveGenerator {
  /// Generate all legal moves for current player in the given GameState
  static List<Move> generateLegalMoves(GameState state) {
    final pseudoMoves = generatePseudoLegalMoves(state);
    final legalMoves = <Move>[];

    for (final move in pseudoMoves) {
      if (isMoveLegal(state, move)) {
        legalMoves.add(move);
      }
    }

    // Assign disambiguated SAN notations and check/checkmate flags
    return disambiguateSanAndAddCheckFlags(state, legalMoves);
  }

  /// Generate all pseudo-legal moves (without check filter)
  static List<Move> generatePseudoLegalMoves(GameState state) {
    final moves = <Move>[];
    final color = state.turn;

    for (int idx = 0; idx < 64; idx++) {
      final piece = state.board[idx];
      if (piece == null || piece.color != color) continue;

      final square = Square.fromIndex(idx);
      switch (piece.type) {
        case PieceType.pawn:
          _generatePawnMoves(state, square, piece, moves);
          break;
        case PieceType.knight:
          _generateKnightMoves(state, square, piece, moves);
          break;
        case PieceType.bishop:
          _generateRayMoves(state, square, piece, moves, _bishopDirections);
          break;
        case PieceType.rook:
          _generateRayMoves(state, square, piece, moves, _rookDirections);
          break;
        case PieceType.queen:
          _generateRayMoves(state, square, piece, moves, _queenDirections);
          break;
        case PieceType.king:
          _generateKingMoves(state, square, piece, moves);
          break;
      }
    }

    return moves;
  }

  static const _knightOffsets = [
    [-2, -1], [-2, 1], [-1, -2], [-1, 2],
    [1, -2], [1, 2], [2, -1], [2, 1]
  ];

  static const _kingOffsets = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1],           [0, 1],
    [1, -1],  [1, 0],  [1, 1]
  ];

  static const _bishopDirections = [
    [-1, -1], [-1, 1], [1, -1], [1, 1]
  ];

  static const _rookDirections = [
    [-1, 0], [1, 0], [0, -1], [0, 1]
  ];

  static const _queenDirections = [
    [-1, -1], [-1, 1], [1, -1], [1, 1],
    [-1, 0], [1, 0], [0, -1], [0, 1]
  ];

  static void _generatePawnMoves(
    GameState state,
    Square from,
    Piece piece,
    List<Move> moves,
  ) {
    final forwardDir = piece.isWhite ? 1 : -1;
    final startRank = piece.isWhite ? 1 : 6;
    final promoRank = piece.isWhite ? 7 : 0;

    // Single step forward
    final oneStepRank = from.rank + forwardDir;
    if (oneStepRank >= 0 && oneStepRank < 8) {
      final oneStep = Square(file: from.file, rank: oneStepRank);
      if (state.pieceAt(oneStep) == null) {
        if (oneStepRank == promoRank) {
          // Promotions
          for (final promo in const [
            PieceType.queen,
            PieceType.rook,
            PieceType.bishop,
            PieceType.knight,
          ]) {
            moves.add(Move(
              from: from,
              to: oneStep,
              piece: piece,
              promotion: promo,
            ));
          }
        } else {
          moves.add(Move(from: from, to: oneStep, piece: piece));

          // Double step forward from initial pawn rank
          if (from.rank == startRank) {
            final twoStepRank = from.rank + 2 * forwardDir;
            final twoStep = Square(file: from.file, rank: twoStepRank);
            if (state.pieceAt(twoStep) == null) {
              moves.add(Move(from: from, to: twoStep, piece: piece));
            }
          }
        }
      }
    }

    // Pawn diagonal captures & En Passant
    for (final dFile in const [-1, 1]) {
      final targetFile = from.file + dFile;
      final targetRank = from.rank + forwardDir;
      if (targetFile < 0 || targetFile > 7 || targetRank < 0 || targetRank > 7) {
        continue;
      }

      final targetSquare = Square(file: targetFile, rank: targetRank);
      final targetPiece = state.pieceAt(targetSquare);

      // Normal capture
      if (targetPiece != null && targetPiece.color != piece.color) {
        if (targetRank == promoRank) {
          for (final promo in const [
            PieceType.queen,
            PieceType.rook,
            PieceType.bishop,
            PieceType.knight,
          ]) {
            moves.add(Move(
              from: from,
              to: targetSquare,
              piece: piece,
              promotion: promo,
              capturedPiece: targetPiece,
            ));
          }
        } else {
          moves.add(Move(
            from: from,
            to: targetSquare,
            piece: piece,
            capturedPiece: targetPiece,
          ));
        }
      }
      // En Passant capture
      else if (targetPiece == null && state.enPassantTarget == targetSquare) {
        final capturedPawn = state.pieceAtCoords(targetFile, from.rank);
        if (capturedPawn != null &&
            capturedPawn.type == PieceType.pawn &&
            capturedPawn.color != piece.color) {
          moves.add(Move(
            from: from,
            to: targetSquare,
            piece: piece,
            capturedPiece: capturedPawn,
            isEnPassant: true,
          ));
        }
      }
    }
  }

  static void _generateKnightMoves(
    GameState state,
    Square from,
    Piece piece,
    List<Move> moves,
  ) {
    for (final offset in _knightOffsets) {
      final to = from.offset(offset[0], offset[1]);
      if (to == null) continue;

      final targetPiece = state.pieceAt(to);
      if (targetPiece == null) {
        moves.add(Move(from: from, to: to, piece: piece));
      } else if (targetPiece.color != piece.color) {
        moves.add(Move(
          from: from,
          to: to,
          piece: piece,
          capturedPiece: targetPiece,
        ));
      }
    }
  }

  static void _generateRayMoves(
    GameState state,
    Square from,
    Piece piece,
    List<Move> moves,
    List<List<int>> directions,
  ) {
    for (final dir in directions) {
      int step = 1;
      while (true) {
        final to = from.offset(dir[0] * step, dir[1] * step);
        if (to == null) break;

        final targetPiece = state.pieceAt(to);
        if (targetPiece == null) {
          moves.add(Move(from: from, to: to, piece: piece));
        } else {
          if (targetPiece.color != piece.color) {
            moves.add(Move(
              from: from,
              to: to,
              piece: piece,
              capturedPiece: targetPiece,
            ));
          }
          break; // Ray blocked by piece
        }
        step++;
      }
    }
  }

  static void _generateKingMoves(
    GameState state,
    Square from,
    Piece piece,
    List<Move> moves,
  ) {
    // 1. Regular 8 adjacent squares
    for (final offset in _kingOffsets) {
      final to = from.offset(offset[0], offset[1]);
      if (to == null) continue;

      final targetPiece = state.pieceAt(to);
      if (targetPiece == null) {
        moves.add(Move(from: from, to: to, piece: piece));
      } else if (targetPiece.color != piece.color) {
        moves.add(Move(
          from: from,
          to: to,
          piece: piece,
          capturedPiece: targetPiece,
        ));
      }
    }

    // 2. Castling Moves
    final opponentColor = piece.color.opponent;

    if (piece.isWhite && from.name == 'e1') {
      final inCheck = isSquareAttacked(state.board, from, opponentColor);
      if (!inCheck) {
        // White Kingside (e1 -> g1)
        if (state.castlingRights.whiteKingside) {
          final f1 = const Square(file: 5, rank: 0);
          final g1 = const Square(file: 6, rank: 0);
          final h1Piece = state.pieceAtCoords(7, 0);

          if (state.pieceAt(f1) == null &&
              state.pieceAt(g1) == null &&
              h1Piece != null &&
              h1Piece.type == PieceType.rook &&
              h1Piece.isWhite &&
              !isSquareAttacked(state.board, f1, opponentColor) &&
              !isSquareAttacked(state.board, g1, opponentColor)) {
            moves.add(Move(
              from: from,
              to: g1,
              piece: piece,
              isKingsideCastling: true,
            ));
          }
        }

        // White Queenside (e1 -> c1)
        if (state.castlingRights.whiteQueenside) {
          final d1 = const Square(file: 3, rank: 0);
          final c1 = const Square(file: 2, rank: 0);
          final b1 = const Square(file: 1, rank: 0);
          final a1Piece = state.pieceAtCoords(0, 0);

          if (state.pieceAt(d1) == null &&
              state.pieceAt(c1) == null &&
              state.pieceAt(b1) == null &&
              a1Piece != null &&
              a1Piece.type == PieceType.rook &&
              a1Piece.isWhite &&
              !isSquareAttacked(state.board, d1, opponentColor) &&
              !isSquareAttacked(state.board, c1, opponentColor)) {
            moves.add(Move(
              from: from,
              to: c1,
              piece: piece,
              isQueensideCastling: true,
            ));
          }
        }
      }
    } else if (piece.isBlack && from.name == 'e8') {
      final inCheck = isSquareAttacked(state.board, from, opponentColor);
      if (!inCheck) {
        // Black Kingside (e8 -> g8)
        if (state.castlingRights.blackKingside) {
          final f8 = const Square(file: 5, rank: 7);
          final g8 = const Square(file: 6, rank: 7);
          final h8Piece = state.pieceAtCoords(7, 7);

          if (state.pieceAt(f8) == null &&
              state.pieceAt(g8) == null &&
              h8Piece != null &&
              h8Piece.type == PieceType.rook &&
              h8Piece.isBlack &&
              !isSquareAttacked(state.board, f8, opponentColor) &&
              !isSquareAttacked(state.board, g8, opponentColor)) {
            moves.add(Move(
              from: from,
              to: g8,
              piece: piece,
              isKingsideCastling: true,
            ));
          }
        }

        // Black Queenside (e8 -> c8)
        if (state.castlingRights.blackQueenside) {
          final d8 = const Square(file: 3, rank: 7);
          final c8 = const Square(file: 2, rank: 7);
          final b8 = const Square(file: 1, rank: 7);
          final a8Piece = state.pieceAtCoords(0, 7);

          if (state.pieceAt(d8) == null &&
              state.pieceAt(c8) == null &&
              state.pieceAt(b8) == null &&
              a8Piece != null &&
              a8Piece.type == PieceType.rook &&
              a8Piece.isBlack &&
              !isSquareAttacked(state.board, d8, opponentColor) &&
              !isSquareAttacked(state.board, c8, opponentColor)) {
            moves.add(Move(
              from: from,
              to: c8,
              piece: piece,
              isQueensideCastling: true,
            ));
          }
        }
      }
    }
  }

  /// Whether a square is attacked by any piece of attackingColor
  static bool isSquareAttacked(
    List<Piece?> board,
    Square targetSquare,
    PieceColor attackingColor,
  ) {
    // 1. Pawn Attacks
    final pawnRankOffset = attackingColor.isWhite ? -1 : 1;
    final pawnRank = targetSquare.rank + pawnRankOffset;
    if (pawnRank >= 0 && pawnRank < 8) {
      for (final dFile in const [-1, 1]) {
        final pawnFile = targetSquare.file + dFile;
        if (pawnFile >= 0 && pawnFile < 8) {
          final p = board[pawnRank * 8 + pawnFile];
          if (p != null &&
              p.color == attackingColor &&
              p.type == PieceType.pawn) {
            return true;
          }
        }
      }
    }

    // 2. Knight Attacks
    for (final offset in _knightOffsets) {
      final file = targetSquare.file + offset[0];
      final rank = targetSquare.rank + offset[1];
      if (file >= 0 && file < 8 && rank >= 0 && rank < 8) {
        final p = board[rank * 8 + file];
        if (p != null &&
            p.color == attackingColor &&
            p.type == PieceType.knight) {
          return true;
        }
      }
    }

    // 3. Bishop / Diagonal Queen Attacks
    for (final dir in _bishopDirections) {
      int step = 1;
      while (true) {
        final file = targetSquare.file + dir[0] * step;
        final rank = targetSquare.rank + dir[1] * step;
        if (file < 0 || file > 7 || rank < 0 || rank > 7) break;

        final p = board[rank * 8 + file];
        if (p != null) {
          if (p.color == attackingColor &&
              (p.type == PieceType.bishop || p.type == PieceType.queen)) {
            return true;
          }
          break; // Obstacle reached
        }
        step++;
      }
    }

    // 4. Rook / Orthogonal Queen Attacks
    for (final dir in _rookDirections) {
      int step = 1;
      while (true) {
        final file = targetSquare.file + dir[0] * step;
        final rank = targetSquare.rank + dir[1] * step;
        if (file < 0 || file > 7 || rank < 0 || rank > 7) break;

        final p = board[rank * 8 + file];
        if (p != null) {
          if (p.color == attackingColor &&
              (p.type == PieceType.rook || p.type == PieceType.queen)) {
            return true;
          }
          break; // Obstacle reached
        }
        step++;
      }
    }

    // 5. King Attacks
    for (final offset in _kingOffsets) {
      final file = targetSquare.file + offset[0];
      final rank = targetSquare.rank + offset[1];
      if (file >= 0 && file < 8 && rank >= 0 && rank < 8) {
        final p = board[rank * 8 + file];
        if (p != null &&
            p.color == attackingColor &&
            p.type == PieceType.king) {
          return true;
        }
      }
    }

    return false;
  }

  /// Whether moving player's king is currently in check
  static bool isKingInCheck(List<Piece?> board, PieceColor color) {
    Square? kingSquare;
    for (int i = 0; i < 64; i++) {
      final p = board[i];
      if (p != null && p.color == color && p.type == PieceType.king) {
        kingSquare = Square.fromIndex(i);
        break;
      }
    }

    if (kingSquare == null) return false;
    return isSquareAttacked(board, kingSquare, color.opponent);
  }

  /// Test whether a candidate move leaves player's king in check (illegality test)
  static bool isMoveLegal(GameState state, Move move) {
    final tempBoard = List<Piece?>.from(state.board);

    // Apply move on temp board
    tempBoard[move.from.index] = null;
    tempBoard[move.to.index] = move.promotion != null
        ? Piece(type: move.promotion!, color: move.piece.color)
        : move.piece;

    // Handle En Passant pawn removal
    if (move.isEnPassant) {
      final capturedPawnSquare = Square(file: move.to.file, rank: move.from.rank);
      tempBoard[capturedPawnSquare.index] = null;
    }

    // Handle Castling rook repositioning
    if (move.isKingsideCastling) {
      final rank = move.from.rank;
      tempBoard[rank * 8 + 7] = null; // Remove rook from h-file
      tempBoard[rank * 8 + 5] = Piece(type: PieceType.rook, color: move.piece.color); // Place on f-file
    } else if (move.isQueensideCastling) {
      final rank = move.from.rank;
      tempBoard[rank * 8 + 0] = null; // Remove rook from a-file
      tempBoard[rank * 8 + 3] = Piece(type: PieceType.rook, color: move.piece.color); // Place on d-file
    }

    return !isKingInCheck(tempBoard, state.turn);
  }

  /// Format SAN notations with exact disambiguation and check/checkmate symbols
  static List<Move> disambiguateSanAndAddCheckFlags(
    GameState state,
    List<Move> legalMoves,
  ) {
    final resultMoves = <Move>[];

    for (final move in legalMoves) {
      // 1. Simulate move to determine if opponent gets placed in check/checkmate
      final tempBoard = List<Piece?>.from(state.board);
      tempBoard[move.from.index] = null;
      tempBoard[move.to.index] = move.promotion != null
          ? Piece(type: move.promotion!, color: move.piece.color)
          : move.piece;

      if (move.isEnPassant) {
        tempBoard[Square(file: move.to.file, rank: move.from.rank).index] = null;
      } else if (move.isKingsideCastling) {
        final rank = move.from.rank;
        tempBoard[rank * 8 + 7] = null;
        tempBoard[rank * 8 + 5] =
            Piece(type: PieceType.rook, color: move.piece.color);
      } else if (move.isQueensideCastling) {
        final rank = move.from.rank;
        tempBoard[rank * 8 + 0] = null;
        tempBoard[rank * 8 + 3] =
            Piece(type: PieceType.rook, color: move.piece.color);
      }

      final opponentColor = state.turn.opponent;
      final givesCheck = isKingInCheck(tempBoard, opponentColor);

      // Check if this check delivers checkmate
      bool givesMate = false;
      if (givesCheck) {
        // Construct temporary next state to see if opponent has any legal response
        final simulatedNextState = state.copyWith(
          board: tempBoard,
          turn: opponentColor,
          enPassantTarget: (move.piece.type == PieceType.pawn &&
                  (move.to.rank - move.from.rank).abs() == 2)
              ? Square(
                  file: move.from.file,
                  rank: (move.from.rank + move.to.rank) ~/ 2,
                )
              : null,
          clearEnPassant: (move.piece.type != PieceType.pawn ||
              (move.to.rank - move.from.rank).abs() != 2),
        );

        final opponentPseudoMoves = generatePseudoLegalMoves(simulatedNextState);
        bool hasLegalResponse = false;
        for (final oppMove in opponentPseudoMoves) {
          if (isMoveLegal(simulatedNextState, oppMove)) {
            hasLegalResponse = true;
            break;
          }
        }
        givesMate = !hasLegalResponse;
      }

      // 2. Disambiguate SAN if multiple pieces of same type can move to same target square
      String? customSan;
      if (move.isKingsideCastling) {
        customSan = givesMate ? 'O-O#' : (givesCheck ? 'O-O+' : 'O-O');
      } else if (move.isQueensideCastling) {
        customSan = givesMate ? 'O-O-O#' : (givesCheck ? 'O-O-O+' : 'O-O-O');
      } else if (move.piece.type == PieceType.pawn) {
        final buffer = StringBuffer();
        if (move.isCapture) {
          buffer.write(move.from.fileName);
          buffer.write('x');
        }
        buffer.write(move.to.name);
        if (move.promotion != null) {
          buffer.write('=');
          buffer.write(switch (move.promotion!) {
            PieceType.queen => 'Q',
            PieceType.rook => 'R',
            PieceType.bishop => 'B',
            PieceType.knight => 'N',
            _ => '',
          });
        }
        if (givesMate) {
          buffer.write('#');
        } else if (givesCheck) {
          buffer.write('+');
        }
        customSan = buffer.toString();
      } else {
        // Non-pawn piece move: check for other pieces of same type and color that can legally reach move.to
        final competingMoves = legalMoves
            .where((m) =>
                m.from != move.from &&
                m.to == move.to &&
                m.piece.type == move.piece.type &&
                m.piece.color == move.piece.color)
            .toList();

        final buffer = StringBuffer();
        buffer.write(move.piece.algebraicLetter);

        if (competingMoves.isNotEmpty) {
          final sameFile = competingMoves.any((m) => m.from.file == move.from.file);
          final sameRank = competingMoves.any((m) => m.from.rank == move.from.rank);

          if (!sameFile) {
            buffer.write(move.from.fileName);
          } else if (!sameRank) {
            buffer.write(move.from.rankName);
          } else {
            buffer.write(move.from.name);
          }
        }

        if (move.isCapture) {
          buffer.write('x');
        }
        buffer.write(move.to.name);

        if (givesMate) {
          buffer.write('#');
        } else if (givesCheck) {
          buffer.write('+');
        }
        customSan = buffer.toString();
      }

      resultMoves.add(move.copyWith(
        isCheck: givesCheck,
        isCheckmate: givesMate,
        customSan: customSan,
      ));
    }

    return resultMoves;
  }
}
