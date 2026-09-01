import 'castling_rights.dart';
import 'move.dart';
import 'piece.dart';
import 'square.dart';

enum GameResult {
  ongoing,
  checkmate,
  stalemate,
  drawByRepetition,
  drawByFiftyMoves,
  drawByInsufficientMaterial,
  drawByAgreement,
  resignation,
  timeout,
  abandonment;

  bool get isGameOver => this != GameResult.ongoing;
  bool get isDraw =>
      this == GameResult.stalemate ||
      this == GameResult.drawByRepetition ||
      this == GameResult.drawByFiftyMoves ||
      this == GameResult.drawByInsufficientMaterial ||
      this == GameResult.drawByAgreement;
}

class GameState {
  final List<Piece?> board; // 64 squares, index = rank * 8 + file
  final PieceColor turn;
  final CastlingRights castlingRights;
  final Square? enPassantTarget;
  final int halfmoveClock;
  final int fullmoveNumber;
  final List<Move> moveHistory;
  final List<String> positionHistory;
  final GameResult result;
  final PieceColor? winner;
  final String? terminationReason;
  final bool isCheck;

  const GameState({
    required this.board,
    required this.turn,
    required this.castlingRights,
    this.enPassantTarget,
    this.halfmoveClock = 0,
    this.fullmoveNumber = 1,
    this.moveHistory = const [],
    this.positionHistory = const [],
    this.result = GameResult.ongoing,
    this.winner,
    this.terminationReason,
    this.isCheck = false,
  });

  bool get isGameOver => result.isGameOver;

  Piece? pieceAt(Square square) => board[square.index];
  Piece? pieceAtCoords(int file, int rank) => board[rank * 8 + file];

  /// Get all captured pieces for a given color
  List<Piece> get capturedPiecesWhite {
    final captured = <Piece>[];
    for (final move in moveHistory) {
      if (move.capturedPiece != null && move.capturedPiece!.isBlack) {
        captured.add(move.capturedPiece!);
      }
    }
    return captured;
  }

  List<Piece> get capturedPiecesBlack {
    final captured = <Piece>[];
    for (final move in moveHistory) {
      if (move.capturedPiece != null && move.capturedPiece!.isWhite) {
        captured.add(move.capturedPiece!);
      }
    }
    return captured;
  }

  /// Material difference (positive means White leads, negative means Black leads)
  int get materialScore {
    int whiteMaterial = 0;
    int blackMaterial = 0;
    for (final piece in board) {
      if (piece == null) continue;
      if (piece.type == PieceType.king) continue;
      if (piece.isWhite) {
        whiteMaterial += piece.value;
      } else {
        blackMaterial += piece.value;
      }
    }
    return whiteMaterial - blackMaterial;
  }

  GameState copyWith({
    List<Piece?>? board,
    PieceColor? turn,
    CastlingRights? castlingRights,
    Square? enPassantTarget,
    bool clearEnPassant = false,
    int? halfmoveClock,
    int? fullmoveNumber,
    List<Move>? moveHistory,
    List<String>? positionHistory,
    GameResult? result,
    PieceColor? winner,
    String? terminationReason,
    bool? isCheck,
  }) {
    return GameState(
      board: board ?? List<Piece?>.from(this.board),
      turn: turn ?? this.turn,
      castlingRights: castlingRights ?? this.castlingRights,
      enPassantTarget:
          clearEnPassant ? null : (enPassantTarget ?? this.enPassantTarget),
      halfmoveClock: halfmoveClock ?? this.halfmoveClock,
      fullmoveNumber: fullmoveNumber ?? this.fullmoveNumber,
      moveHistory: moveHistory ?? List<Move>.from(this.moveHistory),
      positionHistory:
          positionHistory ?? List<String>.from(this.positionHistory),
      result: result ?? this.result,
      winner: winner ?? this.winner,
      terminationReason: terminationReason ?? this.terminationReason,
      isCheck: isCheck ?? this.isCheck,
    );
  }
}
