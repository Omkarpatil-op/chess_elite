import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/chess_engine/board.dart';
import '../../core/chess_engine/game_evaluator.dart';
import '../../core/chess_engine/models/game_state.dart';
import '../../core/chess_engine/models/move.dart';
import '../../core/chess_engine/move_generator.dart';
import '../../core/chess_engine/pgn_processor.dart';
import '../../core/chess_engine/rules_engine.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/chess_match.dart';
import '../widgets/captured_pieces_widget.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/evaluation_bar_widget.dart';
import '../widgets/move_history_widget.dart';

class AnalysisScreen extends StatefulWidget {
  final ChessMatch match;

  const AnalysisScreen({super.key, required this.match});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late final List<GameState> _states;
  late final List<Move> _moves;
  int _currentMoveIdx = 0;
  bool _isFlipped = false;
  late final dynamic _settings;

  @override
  void initState() {
    super.initState();
    _settings = ServiceLocator.settingsRepository.getSettings();
    _parseAndBuildHistory();
  }

  void _parseAndBuildHistory() {
    _states = [ChessBoard.initial()];
    _moves = [];

    // Parse PGN to replay moves
    final parsed = PgnProcessor.parsePgn(widget.match.pgn);
    var currentState = ChessBoard.initial();

    for (final san in parsed.sanMoves) {
      final legalMoves = MoveGenerator.generateLegalMoves(currentState);
      Move? matchedMove;

      final cleanSan =
          san.replaceAll('+', '').replaceAll('#', '').replaceAll('x', '');
      for (final m in legalMoves) {
        if (m.san == san ||
            m.san.replaceAll('+', '').replaceAll('#', '') == cleanSan) {
          matchedMove = m;
          break;
        }
      }

      if (matchedMove != null) {
        currentState = RulesEngine.applyMove(currentState, matchedMove);
        _states.add(currentState);
        _moves.add(matchedMove);
      }
    }

    _currentMoveIdx = _states.length - 1;
  }

  void _goToMove(int idx) {
    if (idx >= 0 && idx < _states.length) {
      setState(() => _currentMoveIdx = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentState = _states[_currentMoveIdx];
    final lastMove =
        _currentMoveIdx > 0 ? _moves[_currentMoveIdx - 1] : null;
    final evalScore = GameEvaluator.evaluate(currentState);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Game Review & Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy PGN',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.match.pgn));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PGN copied to clipboard!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android_rounded),
            tooltip: 'Flip Board',
            onPressed: () => setState(() => _isFlipped = !_isFlipped),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Match Title & Result Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.match.whitePlayerName} (${widget.match.whitePlayerRating}) vs ${widget.match.blackPlayerName} (${widget.match.blackPlayerRating})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.match.timeControl.name}  •  ${widget.match.result.name}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Move $_currentMoveIdx / ${_states.length - 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Board with Evaluation Bar
              Expanded(
                child: Row(
                  children: [
                    EvaluationBarWidget(
                      scoreCentipawns: evalScore,
                      isFlipped: _isFlipped,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChessBoardWidget(
                        gameState: currentState,
                        isFlipped: _isFlipped,
                        lastMove: lastMove,
                        boardTheme: _settings.boardTheme,
                        pieceStyle: _settings.pieceStyle,
                        showCoordinates: _settings.showCoordinates,
                        showLegalMoves: false,
                        isInteractive: false,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Captured pieces
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CapturedPiecesWidget(
                    capturedPieces: currentState.capturedPiecesWhite,
                    materialDifference: currentState.materialScore,
                    pieceStyle: _settings.pieceStyle,
                  ),
                  CapturedPiecesWidget(
                    capturedPieces: currentState.capturedPiecesBlack,
                    materialDifference: -currentState.materialScore,
                    pieceStyle: _settings.pieceStyle,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Move navigation controls (|<, <, >, >|)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: _currentMoveIdx > 0 ? () => _goToMove(0) : null,
                    icon: const Icon(Icons.first_page_rounded),
                    tooltip: 'Start of Game',
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: _currentMoveIdx > 0
                        ? () => _goToMove(_currentMoveIdx - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    tooltip: 'Previous Move',
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: _currentMoveIdx < _states.length - 1
                        ? () => _goToMove(_currentMoveIdx + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                    tooltip: 'Next Move',
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: _currentMoveIdx < _states.length - 1
                        ? () => _goToMove(_states.length - 1)
                        : null,
                    icon: const Icon(Icons.last_page_rounded),
                    tooltip: 'End of Game',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Move list table
              MoveHistoryWidget(
                moveHistory: _moves,
                currentMoveIndex: _currentMoveIdx - 1,
                onMoveSelected: (idx) => _goToMove(idx + 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
