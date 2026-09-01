class CastlingRights {
  final bool whiteKingside;
  final bool whiteQueenside;
  final bool blackKingside;
  final bool blackQueenside;

  const CastlingRights({
    required this.whiteKingside,
    required this.whiteQueenside,
    required this.blackKingside,
    required this.blackQueenside,
  });

  const CastlingRights.initial()
      : whiteKingside = true,
        whiteQueenside = true,
        blackKingside = true,
        blackQueenside = true;

  const CastlingRights.none()
      : whiteKingside = false,
        whiteQueenside = false,
        blackKingside = false,
        blackQueenside = false;

  CastlingRights copyWith({
    bool? whiteKingside,
    bool? whiteQueenside,
    bool? blackKingside,
    bool? blackQueenside,
  }) {
    return CastlingRights(
      whiteKingside: whiteKingside ?? this.whiteKingside,
      whiteQueenside: whiteQueenside ?? this.whiteQueenside,
      blackKingside: blackKingside ?? this.blackKingside,
      blackQueenside: blackQueenside ?? this.blackQueenside,
    );
  }

  /// Format as FEN string (e.g. 'KQkq', 'Kq', '-')
  String toFen() {
    final buffer = StringBuffer();
    if (whiteKingside) buffer.write('K');
    if (whiteQueenside) buffer.write('Q');
    if (blackKingside) buffer.write('k');
    if (blackQueenside) buffer.write('q');
    return buffer.isEmpty ? '-' : buffer.toString();
  }

  /// Parse from FEN string
  factory CastlingRights.fromFen(String fen) {
    if (fen == '-') {
      return const CastlingRights.none();
    }
    return CastlingRights(
      whiteKingside: fen.contains('K'),
      whiteQueenside: fen.contains('Q'),
      blackKingside: fen.contains('k'),
      blackQueenside: fen.contains('q'),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CastlingRights &&
          runtimeType == other.runtimeType &&
          whiteKingside == other.whiteKingside &&
          whiteQueenside == other.whiteQueenside &&
          blackKingside == other.blackKingside &&
          blackQueenside == other.blackQueenside;

  @override
  int get hashCode => Object.hash(
        whiteKingside,
        whiteQueenside,
        blackKingside,
        blackQueenside,
      );

  @override
  String toString() => toFen();
}
