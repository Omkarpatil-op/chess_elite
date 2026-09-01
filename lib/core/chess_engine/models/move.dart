import 'piece.dart';
import 'square.dart';

class Move {
  final Square from;
  final Square to;
  final Piece piece;
  final PieceType? promotion;
  final Piece? capturedPiece;
  final bool isEnPassant;
  final bool isKingsideCastling;
  final bool isQueensideCastling;
  final bool isCheck;
  final bool isCheckmate;
  final String? customSan;

  const Move({
    required this.from,
    required this.to,
    required this.piece,
    this.promotion,
    this.capturedPiece,
    this.isEnPassant = false,
    this.isKingsideCastling = false,
    this.isQueensideCastling = false,
    this.isCheck = false,
    this.isCheckmate = false,
    this.customSan,
  });

  bool get isCastling => isKingsideCastling || isQueensideCastling;
  bool get isCapture => capturedPiece != null || isEnPassant;

  /// Universal Chess Interface (UCI) notation (e.g. 'e2e4', 'e7e8q')
  String get uci {
    final promoStr = switch (promotion) {
      PieceType.queen => 'q',
      PieceType.rook => 'r',
      PieceType.bishop => 'b',
      PieceType.knight => 'n',
      _ => '',
    };
    return '${from.name}${to.name}$promoStr';
  }

  /// Standard Algebraic Notation (SAN) - e.g. 'e4', 'Nf3', 'exd5', 'O-O', 'Qh5#', 'Bxf7+'
  String get san {
    if (customSan != null && customSan!.isNotEmpty) {
      return customSan!;
    }
    if (isKingsideCastling) {
      return isCheckmate ? 'O-O#' : (isCheck ? 'O-O+' : 'O-O');
    }
    if (isQueensideCastling) {
      return isCheckmate ? 'O-O-O#' : (isCheck ? 'O-O-O+' : 'O-O-O');
    }

    final buffer = StringBuffer();
    buffer.write(piece.algebraicLetter);

    if (piece.type == PieceType.pawn && isCapture) {
      buffer.write(from.fileName);
      buffer.write('x');
    } else if (isCapture) {
      buffer.write('x');
    }

    buffer.write(to.name);

    if (promotion != null) {
      buffer.write('=');
      buffer.write(switch (promotion!) {
        PieceType.queen => 'Q',
        PieceType.rook => 'R',
        PieceType.bishop => 'B',
        PieceType.knight => 'N',
        _ => '',
      });
    }

    if (isCheckmate) {
      buffer.write('#');
    } else if (isCheck) {
      buffer.write('+');
    }

    return buffer.toString();
  }

  Move copyWith({
    Square? from,
    Square? to,
    Piece? piece,
    PieceType? promotion,
    Piece? capturedPiece,
    bool? isEnPassant,
    bool? isKingsideCastling,
    bool? isQueensideCastling,
    bool? isCheck,
    bool? isCheckmate,
    String? customSan,
  }) {
    return Move(
      from: from ?? this.from,
      to: to ?? this.to,
      piece: piece ?? this.piece,
      promotion: promotion ?? this.promotion,
      capturedPiece: capturedPiece ?? this.capturedPiece,
      isEnPassant: isEnPassant ?? this.isEnPassant,
      isKingsideCastling: isKingsideCastling ?? this.isKingsideCastling,
      isQueensideCastling: isQueensideCastling ?? this.isQueensideCastling,
      isCheck: isCheck ?? this.isCheck,
      isCheckmate: isCheckmate ?? this.isCheckmate,
      customSan: customSan ?? this.customSan,
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from.name,
        'to': to.name,
        'piece': piece.symbol,
        'promotion': promotion?.name,
        'capturedPiece': capturedPiece?.symbol,
        'isEnPassant': isEnPassant,
        'isKingsideCastling': isKingsideCastling,
        'isQueensideCastling': isQueensideCastling,
        'isCheck': isCheck,
        'isCheckmate': isCheckmate,
        'san': san,
        'uci': uci,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Move &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          piece == other.piece &&
          promotion == other.promotion &&
          capturedPiece == other.capturedPiece &&
          isEnPassant == other.isEnPassant &&
          isKingsideCastling == other.isKingsideCastling &&
          isQueensideCastling == other.isQueensideCastling;

  @override
  int get hashCode => Object.hash(
        from,
        to,
        piece,
        promotion,
        capturedPiece,
        isEnPassant,
        isKingsideCastling,
        isQueensideCastling,
      );

  @override
  String toString() => san;
}
