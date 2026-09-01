class Square {
  final int file; // 0 (a) to 7 (h)
  final int rank; // 0 (1) to 7 (8)

  const Square({required this.file, required this.rank});

  /// Index from 0 (a1) to 63 (h8)
  int get index => rank * 8 + file;

  /// File name ('a'..'h')
  String get fileName => String.fromCharCode('a'.codeUnitAt(0) + file);

  /// Rank name ('1'..'8')
  String get rankName => '${rank + 1}';

  /// Standard algebraic notation for this square (e.g. 'e4')
  String get name => '$fileName$rankName';

  /// Whether this is a light square on the chessboard
  bool get isLight => (file + rank) % 2 != 0;

  /// Whether coordinates are within standard 8x8 boundaries
  bool get isValid => file >= 0 && file < 8 && rank >= 0 && rank < 8;

  /// Create square from 0..63 index (0 = a1, 63 = h8)
  factory Square.fromIndex(int index) {
    assert(index >= 0 && index < 64, 'Index must be between 0 and 63');
    return Square(file: index % 8, rank: index ~/ 8);
  }

  /// Create square from algebraic notation (e.g. 'e4', 'A1')
  factory Square.fromName(String name) {
    if (name.length != 2) {
      throw ArgumentError('Invalid square notation: $name');
    }
    final fileChar = name[0].toLowerCase();
    final rankChar = name[1];

    final file = fileChar.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.parse(rankChar) - 1;

    if (file < 0 || file > 7 || rank < 0 || rank > 7) {
      throw ArgumentError('Square out of bounds: $name');
    }

    return Square(file: file, rank: rank);
  }

  /// Try parse square, returning null if invalid
  static Square? tryParse(String? name) {
    if (name == null || name.length != 2) return null;
    try {
      return Square.fromName(name);
    } catch (_) {
      return null;
    }
  }

  /// Add offset to square coordinates
  Square? offset(int dFile, int dRank) {
    final newFile = file + dFile;
    final newRank = rank + dRank;
    if (newFile >= 0 && newFile < 8 && newRank >= 0 && newRank < 8) {
      return Square(file: newFile, rank: newRank);
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Square &&
          runtimeType == other.runtimeType &&
          file == other.file &&
          rank == other.rank;

  @override
  int get hashCode => Object.hash(file, rank);

  @override
  String toString() => name;
}
