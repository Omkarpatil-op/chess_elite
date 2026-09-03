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
        await _executeMoveFromSelection(_selectedSquare!, square, matchingMoves);
      } else {
        _clearSelection();
      }
    }
  }

  Future<void> _executeMoveFromSelection(
    Square from,
    Square to,
    List<Move> matchingMoves,
  ) async {
    // Check if pawn promotion is needed
    if (matchingMoves.any((m) => m.promotion != null)) {
      final selectedPromo = widget.onPromotionRequested != null
          ? await widget.onPromotionRequested!(from, to)
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
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = BoardThemeColors.get(widget.boardTheme);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final boardSize = (maxSide).clamp(240.0, 600.0);
        final squareSize = boardSize / 8.0;

        return Center(
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF263248).withValues(alpha: 0.8),
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
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

    final isCaptureTarget = legalMoveToThis &&
        (piece != null ||
            (widget.gameState.enPassantTarget == square &&
                widget.gameState.pieceAt(_selectedSquare!)?.type ==
                    PieceType.pawn));

    // Determine square background color
    Color squareBg = isLight ? themeColors.lightSquare : themeColors.darkSquare;
    if (isSelected) {
      squareBg = Color.alphaBlend(themeColors.selectedHighlight, squareBg);
    } else if (isLastMoveOrigin || isLastMoveTarget) {
      squareBg = Color.alphaBlend(themeColors.lastMoveHighlight, squareBg);
    }

    // Accessibility description
    final semanticsLabel = '${square.name}, '
        '${piece != null ? "${piece.color.name} ${piece.type.name}" : "empty square"}'
        '${legalMoveToThis ? ", legal move target" : ""}';

    final squareContent = Container(
      color: squareBg,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Check Danger Glow Aura on King
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

          // Legal Move Indicators
          if (legalMoveToThis)
            if (isCaptureTarget)
              Container(
                width: squareSize * 0.88,
                height: squareSize * 0.88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeColors.legalDotColor,
                    width: squareSize * 0.09,
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

          // Render Piece
          if (piece != null)
            _buildDraggablePiece(square, piece, isSelected, squareSize),
        ],
      ),
    );

    // Wrap in DragTarget for Drag & Drop support
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: DragTarget<Square>(
        onWillAcceptWithDetails: (details) {
          if (!widget.isInteractive || widget.gameState.isGameOver) return false;
          final fromSquare = details.data;
          final legalMoves = MoveGenerator.generateLegalMoves(widget.gameState);
          return legalMoves.any((m) => m.from == fromSquare && m.to == square);
        },
        onAcceptWithDetails: (details) async {
          final fromSquare = details.data;
          final legalMoves = MoveGenerator.generateLegalMoves(widget.gameState);
          final matchingMoves = legalMoves
              .where((m) => m.from == fromSquare && m.to == square)
              .toList();
          if (matchingMoves.isNotEmpty) {
            await _executeMoveFromSelection(fromSquare, square, matchingMoves);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () => _onSquareTapped(square),
            child: squareContent,
          );
        },
      ),
    );
  }

  Widget _buildDraggablePiece(
    Square square,
    Piece piece,
    bool isSelected,
    double squareSize,
  ) {
    final isPlayerTurnPiece =
        widget.isInteractive && piece.color == widget.gameState.turn;

    final pieceWidget = AnimatedScale(
      scale: isSelected ? 1.14 : 1.0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutBack,
      child: ChessPieceWidget(
        piece: piece,
        size: squareSize * 0.88,
        style: widget.pieceStyle,
      ),
    );

    if (!isPlayerTurnPiece) {
      return pieceWidget;
    }

    return Draggable<Square>(
      data: square,
      onDragStarted: () {
        HapticService.instance.onPieceSelected();
        final allLegalMoves =
            MoveGenerator.generateLegalMoves(widget.gameState);
        final pieceMoves =
            allLegalMoves.where((m) => m.from == square).toList();

        setState(() {
          _selectedSquare = square;
          _legalMovesFromSelected = pieceMoves;
        });
      },
      feedback: Transform.translate(
        offset: Offset(-squareSize * 0.5, -squareSize * 0.5),
        child: Material(
          type: MaterialType.transparency,
          child: ChessPieceWidget(
            piece: piece,
            size: squareSize * 1.15,
            style: widget.pieceStyle,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: pieceWidget,
      ),
      child: pieceWidget,
    );
  }

  Widget _buildCoordinates(BoardThemeColors themeColors, double squareSize) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Rank Numbers (1..8) on left edge
          for (int r = 0; r < 8; r++)
            Positioned(
              left: 4,
              top: r * squareSize + 3,
              child: Text(
                widget.isFlipped ? '${r + 1}' : '${8 - r}',
                style: TextStyle(
                  fontSize: squareSize * 0.20,
                  fontWeight: FontWeight.w800,
                  color: (r % 2 == (widget.isFlipped ? 1 : 0))
                      ? themeColors.coordinateColorDark
                      : themeColors.coordinateColorLight,
                ),
              ),
            ),

          // File Letters (a..h) on bottom edge
          for (int f = 0; f < 8; f++)
            Positioned(
              right: (7 - f) * squareSize + 4,
              bottom: 2,
              child: Text(
                widget.isFlipped
                    ? String.fromCharCode('h'.codeUnitAt(0) - f)
                    : String.fromCharCode('a'.codeUnitAt(0) + f),
                style: TextStyle(
                  fontSize: squareSize * 0.20,
                  fontWeight: FontWeight.w800,
                  color: (f % 2 == (widget.isFlipped ? 0 : 1))
                      ? themeColors.coordinateColorDark
                      : themeColors.coordinateColorLight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
