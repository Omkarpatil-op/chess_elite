import 'package:flutter/material.dart';
import '../../core/chess_engine/models/game_state.dart';
import '../../core/chess_engine/models/move.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/chess_engine/models/square.dart';
import '../../core/chess_engine/move_generator.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/board_themes.dart';
import '../../core/theme/piece_themes.dart';
import 'piece_painter.dart';

class ChessBoardWidget extends StatefulWidget {
  final GameState gameState;
  final bool isFlipped;
  final bool showCoordinates;
  final bool showLegalMoves;
  final BoardThemeType boardTheme;
  final PieceStyle pieceStyle;
  final Move? lastMove;
  final bool isInteractive;
  final void Function(Move move)? onMove;
  final Future<PieceType?> Function(Square from, Square to)? onPromotionRequested;

  const ChessBoardWidget({
    super.key,
    required this.gameState,
    this.isFlipped = false,
    this.showCoordinates = true,
    this.showLegalMoves = true,
    this.boardTheme = BoardThemeType.classicWood,
    this.pieceStyle = PieceStyle.stauntonClassic,
    this.lastMove,
    this.isInteractive = true,
    this.onMove,
    this.onPromotionRequested,
  });

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  Square? _selectedSquare;
  List<Move> _legalMovesFromSelected = [];

  @override
  void didUpdateWidget(covariant ChessBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameState != widget.gameState) {
      _clearSelection();
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedSquare = null;
      _legalMovesFromSelected = [];
    });
  }

  void _onSquareTapped(Square square) async {
    if (!widget.isInteractive || widget.gameState.isGameOver) return;

    final tappedPiece = widget.gameState.pieceAt(square);

    // 1. If clicking own piece of active turn, select it
    if (tappedPiece != null && tappedPiece.color == widget.gameState.turn) {
      HapticService.instance.onPieceSelected();
      final allLegalMoves = MoveGenerator.generateLegalMoves(widget.gameState);
      final pieceMoves = allLegalMoves.where((m) => m.from == square).toList();

      setState(() {
        _selectedSquare = square;
        _legalMovesFromSelected = pieceMoves;
      });
      return;
    }

    // 2. If a piece was selected, check if target square is a legal destination
    if (_selectedSquare != null) {
      final matchingMoves =
          _legalMovesFromSelected.where((m) => m.to == square).toList();

      if (matchingMoves.isNotEmpty) {
        // Check if promotion is needed
        if (matchingMoves.any((m) => m.promotion != null)) {
          final selectedPromo = widget.onPromotionRequested != null
              ? await widget.onPromotionRequested!(_selectedSquare!, square)
              : PieceType.queen;

          if (selectedPromo != null) {
            final promoMove = matchingMoves.firstWhere(
              (m) => m.promotion == selectedPromo,
              orElse: () => matchingMoves.first,
            );
            _clearSelection();
            widget.onMove?.call(promoMove);
          }
        } else {
          final move = matchingMoves.first;
          _clearSelection();
          widget.onMove?.call(move);
        }
      } else {
        _clearSelection();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = BoardThemeColors.get(widget.boardTheme);

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final squareSize = boardSize / 8.0;

        return Center(
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  // 1. 8x8 Chess Squares Grid
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 64,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemBuilder: (context, gridIndex) {
                      final square = _getSquareFromGridIndex(gridIndex);
                      return _buildSquare(square, themeColors, squareSize);
                    },
                  ),

                  // 2. Coordinate Labels (a-h and 1-8)
                  if (widget.showCoordinates)
                    _buildCoordinates(themeColors, squareSize),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Square _getSquareFromGridIndex(int gridIndex) {
    final row = gridIndex ~/ 8;
    final col = gridIndex % 8;

    final file = widget.isFlipped ? 7 - col : col;
    final rank = widget.isFlipped ? row : 7 - row;

    return Square(file: file, rank: rank);
  }

  Widget _buildSquare(
    Square square,
    BoardThemeColors themeColors,
    double squareSize,
  ) {
    final isLight = square.isLight;
    final isSelected = _selectedSquare == square;
    final isLastMoveOrigin = widget.lastMove?.from == square;
    final isLastMoveTarget = widget.lastMove?.to == square;
    final piece = widget.gameState.pieceAt(square);

    // Check if king on this square is in check
    final isKingInCheck = piece != null &&
        piece.type == PieceType.king &&
        piece.color == widget.gameState.turn &&
        widget.gameState.isCheck;

    // Check if this square is a legal destination for selected piece
    final legalMoveToThis = widget.showLegalMoves && _selectedSquare != null
        ? _legalMovesFromSelected.any((m) => m.to == square)
        : false;
    final isCaptureTarget = legalMoveToThis && (piece != null ||
        (widget.gameState.enPassantTarget == square &&
            widget.gameState.pieceAt(_selectedSquare!)?.type == PieceType.pawn));

    // Determine square background color
    Color squareBg = isLight ? themeColors.lightSquare : themeColors.darkSquare;
    if (isSelected) {
      squareBg = themeColors.selectedHighlight;
    } else if (isLastMoveOrigin || isLastMoveTarget) {
      squareBg = Color.alphaBlend(
        themeColors.lastMoveHighlight,
        squareBg,
      );
    }

    // Accessibility description
    final semanticsLabel = '${square.name}, '
        '${piece != null ? "${piece.color.name} ${piece.type.name}" : "empty square"}'
        '${legalMoveToThis ? ", legal move target" : ""}';

    return Semantics(
      label: semanticsLabel,
      button: true,
      child: GestureDetector(
        onTap: () => _onSquareTapped(square),
        child: Container(
          color: squareBg,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Check glow
              if (isKingInCheck)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        themeColors.checkHighlight,
                        themeColors.checkHighlight.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),

              // Legal move dot / capture indicator
              if (legalMoveToThis)
                if (isCaptureTarget)
                  Container(
                    width: squareSize * 0.88,
                    height: squareSize * 0.88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: themeColors.legalDotColor,
                        width: squareSize * 0.08,
                      ),
                    ),
                  )
                else
                  Container(
                    width: squareSize * 0.32,
                    height: squareSize * 0.32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeColors.legalDotColor,
                    ),
                  ),

              // Chess piece
              if (piece != null)
                AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutBack,
                  child: ChessPieceWidget(
                    piece: piece,
                    size: squareSize * 0.85,
                    style: widget.pieceStyle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinates(BoardThemeColors themeColors, double squareSize) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Rank Numbers (1..8) on left
          for (int r = 0; r < 8; r++)
            Positioned(
              left: 3,
              top: r * squareSize + 3,
              child: Text(
                widget.isFlipped ? '${r + 1}' : '${8 - r}',
                style: TextStyle(
                  fontSize: squareSize * 0.20,
                  fontWeight: FontWeight.bold,
                  color: (r % 2 == (widget.isFlipped ? 1 : 0))
                      ? themeColors.darkSquare
                      : themeColors.lightSquare,
                ),
              ),
            ),

          // File Letters (a..h) on bottom
          for (int f = 0; f < 8; f++)
            Positioned(
              right: (7 - f) * squareSize + 3,
              bottom: 2,
              child: Text(
                widget.isFlipped
                    ? String.fromCharCode('h'.codeUnitAt(0) - f)
                    : String.fromCharCode('a'.codeUnitAt(0) + f),
                style: TextStyle(
                  fontSize: squareSize * 0.20,
                  fontWeight: FontWeight.bold,
                  color: (f % 2 == (widget.isFlipped ? 0 : 1))
                      ? themeColors.darkSquare
                      : themeColors.lightSquare,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
