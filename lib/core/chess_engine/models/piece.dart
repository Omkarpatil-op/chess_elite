enum PieceType {
  pawn,
  knight,
  bishop,
  rook,
  queen,
  king,
}

enum PieceColor {
  white,
  black;

  PieceColor get opponent => this == white ? black : white;
  bool get isWhite => this == white;
  bool get isBlack => this == black;
}

class Piece {
  final PieceType type;
  final PieceColor color;

  const Piece({required this.type, required this.color});

  bool get isWhite => color == PieceColor.white;
  bool get isBlack => color == PieceColor.black;

  /// Static material value in centipawns
  int get value {
    switch (type) {
      case PieceType.pawn:
        return 100;
      case PieceType.knight:
        return 320;
      case PieceType.bishop:
        return 330;
      case PieceType.rook:
        return 500;
      case PieceType.queen:
        return 900;
      case PieceType.king:
        return 20000;
    }
  }

  /// Single-letter notation (uppercase for White, lowercase for Black)
  String get symbol {
    final char = switch (type) {
      PieceType.pawn => 'P',
      PieceType.knight => 'N',
      PieceType.bishop => 'B',
      PieceType.rook => 'R',
      PieceType.queen => 'Q',
      PieceType.king => 'K',
    };
    return isWhite ? char : char.toLowerCase();
  }

  /// Standard algebraic piece letter for moves (e.g. 'N', 'B', 'R', 'Q', 'K', empty for Pawn)
  String get algebraicLetter {
    return switch (type) {
      PieceType.pawn => '',
      PieceType.knight => 'N',
      PieceType.bishop => 'B',
      PieceType.rook => 'R',
      PieceType.queen => 'Q',
      PieceType.king => 'K',
    };
  }

  /// Parse a piece from a FEN character
  static Piece? fromSymbol(String char) {
    if (char.length != 1) return null;
    final isWhite = char == char.toUpperCase();
    final lower = char.toLowerCase();
    final type = switch (lower) {
      'p' => PieceType.pawn,
      'n' => PieceType.knight,
      'b' => PieceType.bishop,
      'r' => PieceType.rook,
      'q' => PieceType.queen,
      'k' => PieceType.king,
      _ => null,
    };
    if (type == null) return null;
    return Piece(
      type: type,
      color: isWhite ? PieceColor.white : PieceColor.black,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Piece &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          color == other.color;

  @override
  int get hashCode => Object.hash(type, color);

  @override
  String toString() => symbol;
}
