import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';
import '../../core/chess_engine/ai_engine.dart';
import '../../core/chess_engine/ai_isolate.dart';
import '../../core/chess_engine/board.dart';
import '../../core/chess_engine/models/game_state.dart';
import '../../core/chess_engine/models/move.dart';
import '../../core/chess_engine/models/piece.dart';
import '../../core/chess_engine/pgn_processor.dart';
import '../../core/chess_engine/rules_engine.dart';
import '../../core/di/service_locator.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/services/mock_authoritative_game_server.dart';
import '../../data/services/realtime_game_client.dart';
import '../../domain/models/chess_match.dart';
import '../../domain/models/time_control.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/rating_calculator.dart';
import '../widgets/captured_pieces_widget.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/chess_clock_widget.dart';
import '../widgets/evaluation_bar_widget.dart';
import '../widgets/game_result_dialog.dart';
import '../widgets/move_history_widget.dart';
import '../widgets/promotion_dialog.dart';
import 'analysis_screen.dart';

enum GameMode {
  vsAi,
  passAndPlay,
  onlineMultiplayer,
}

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final TimeControl timeControl;
  final PieceColor playerColor;
  final AiDifficulty aiDifficulty;
  final String opponentName;
  final int opponentRating;
  final String? onlineGameId;

  const GameScreen({
    super.key,
    required this.mode,
    required this.timeControl,
    this.playerColor = PieceColor.white,
    this.aiDifficulty = AiDifficulty.medium,
    this.opponentName = 'Stockfish AI',
    this.opponentRating = 1500,
    this.onlineGameId,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  late int _whiteTimeMs;
  late int _blackTimeMs;
  Timer? _clockTimer;
  Move? _lastMove;
  bool _isFlipped = false;
  bool _isAiThinking = false;
  UserProfile? _currentUser;
  late final dynamic _settings;

  // Real-time server connection for online mode
  MockAuthoritativeGameServer? _realtimeServer;
  StreamSubscription? _serverSub;

  @override
  void initState() {
    super.initState();
    _settings = ServiceLocator.settingsRepository.getSettings();
    _gameState = ChessBoard.initial();
    _whiteTimeMs = widget.timeControl.initialSeconds * 1000;
    _blackTimeMs = widget.timeControl.initialSeconds * 1000;
    _isFlipped = widget.playerColor.isBlack;

    _loadUser();
    _initGameMode();
  }

  Future<void> _loadUser() async {
    _currentUser = await ServiceLocator.authRepository.getCurrentUser();
  }

  void _initGameMode() {
    SoundService.instance.play(ChessSound.gameStart);

    if (widget.mode == GameMode.onlineMultiplayer) {
      _initOnlineMode();
    } else {
      _startLocalClock();
      // If playing as Black against AI, trigger AI initial move
      if (widget.mode == GameMode.vsAi && widget.playerColor.isBlack) {
        _triggerAiMove();
      }
    }
  }

  void _initOnlineMode() {
    _realtimeServer = MockAuthoritativeGameServer();
    _serverSub = _realtimeServer!.eventStream.listen(_handleServerEvent);

    _realtimeServer!.connect(
      token: 'session_token',
      gameId: widget.onlineGameId ?? 'game_match_1',
      initialSeconds: widget.timeControl.initialSeconds,
      incrementSeconds: widget.timeControl.incrementSeconds,
      isAiOpponent: true,
      opponentDifficulty: widget.aiDifficulty,
    );
  }

  void _handleServerEvent(RealtimeMessage msg) {
    if (!mounted) return;

    switch (msg.type) {
      case RealtimeEventType.moveMade:
        final fen = msg.payload['fen'] as String;
        final wMs = msg.payload['whiteTimeMs'] as int;
        final bMs = msg.payload['blackTimeMs'] as int;

        setState(() {
          _whiteTimeMs = wMs;
          _blackTimeMs = bMs;
          _gameState = ChessBoard.fromFen(fen);
          _lastMove = _gameState.moveHistory.isNotEmpty
              ? _gameState.moveHistory.last
              : null;
        });

        _playMoveSound(_lastMove);
        break;

      case RealtimeEventType.clockSync:
        setState(() {
          _whiteTimeMs = msg.payload['whiteTimeMs'] as int;
          _blackTimeMs = msg.payload['blackTimeMs'] as int;
        });
        break;

      case RealtimeEventType.gameOver:
        final reason = msg.payload['reason'] as String?;
        final resStr = msg.payload['result'] as String;
        final winnerStr = msg.payload['winner'] as String?;

        final result = GameResult.values.firstWhere(
          (r) => r.name == resStr,
          orElse: () => GameResult.checkmate,
        );

        final winner = winnerStr != null
            ? PieceColor.values.firstWhere((c) => c.name == winnerStr)
            : null;

        setState(() {
          _gameState = _gameState.copyWith(
            result: result,
            winner: winner,
            terminationReason: reason,
          );
        });

        _onGameOver();
        break;

      case RealtimeEventType.drawOffered:
        _showDrawOfferedDialog();
        break;

      default:
        break;
    }
  }

  void _startLocalClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_gameState.isGameOver) {
        _clockTimer?.cancel();
        return;
      }

      setState(() {
        if (_gameState.turn.isWhite) {
          _whiteTimeMs -= 100;
          if (_whiteTimeMs <= 0) {
            _whiteTimeMs = 0;
            _handleLocalTimeout(PieceColor.white);
          }
        } else {
          _blackTimeMs -= 100;
          if (_blackTimeMs <= 0) {
            _blackTimeMs = 0;
            _handleLocalTimeout(PieceColor.black);
          }
        }
      });
    });
  }

  void _handleLocalTimeout(PieceColor timedOutColor) {
    _clockTimer?.cancel();
    final winner = timedOutColor.opponent;
    setState(() {
      _gameState = _gameState.copyWith(
        result: GameResult.timeout,
        winner: winner,
        terminationReason:
            'Time out: ${winner.name.toUpperCase()} wins on time!',
      );
    });
    _onGameOver();
  }

  void _onUserMove(Move move) {
    if (_gameState.isGameOver) return;

    if (widget.mode == GameMode.onlineMultiplayer) {
      // Send move to server
      _realtimeServer?.sendMove(
        uci: move.uci,
        moveSequence: _gameState.moveHistory.length + 1,
      );
    } else {
      // Apply move locally
      final nextState = RulesEngine.applyMove(_gameState, move);
      setState(() {
        _gameState = nextState;
        _lastMove = move;

        // Apply increment
        if (move.piece.isWhite) {
          _whiteTimeMs += widget.timeControl.incrementSeconds * 1000;
        } else {
          _blackTimeMs += widget.timeControl.incrementSeconds * 1000;
        }
      });

      _playMoveSound(move);

      if (_gameState.isGameOver) {
        _clockTimer?.cancel();
        _onGameOver();
      } else if (widget.mode == GameMode.vsAi &&
          _gameState.turn != widget.playerColor) {
        _triggerAiMove();
      }
    }
  }

  void _playMoveSound(Move? move) {
    if (move == null) return;
    if (_gameState.isGameOver) {
      SoundService.instance.play(ChessSound.gameEnd);
      HapticService.instance.onGameOver();
    } else if (move.isCheck) {
      SoundService.instance.play(ChessSound.check);
      HapticService.instance.onCheck();
    } else if (move.isCapture) {
      SoundService.instance.play(ChessSound.capture);
      HapticService.instance.onPieceCaptured();
    } else if (move.isCastling) {
      SoundService.instance.play(ChessSound.castle);
      HapticService.instance.onMoveMade();
    } else {
      SoundService.instance.play(ChessSound.move);
      HapticService.instance.onMoveMade();
    }
  }

  void _triggerAiMove() async {
    setState(() => _isAiThinking = true);

    // Run AI move computation asynchronously on background isolate
    final bestMove = await AiIsolateRunner.computeBestMoveAsync(
      _gameState,
      widget.aiDifficulty,
    );

    if (!mounted || _gameState.isGameOver || bestMove == null) {
      setState(() => _isAiThinking = false);
      return;
    }

    final nextState = RulesEngine.applyMove(_gameState, bestMove);
    setState(() {
      _gameState = nextState;
      _lastMove = bestMove;
      _isAiThinking = false;

      // Apply increment for AI
      if (bestMove.piece.isWhite) {
        _whiteTimeMs += widget.timeControl.incrementSeconds * 1000;
      } else {
        _blackTimeMs += widget.timeControl.incrementSeconds * 1000;
      }
    });

    _playMoveSound(bestMove);

    if (_gameState.isGameOver) {
      _clockTimer?.cancel();
      _onGameOver();
    }
  }

  Future<void> _onGameOver() async {
    SoundService.instance.play(ChessSound.gameEnd);
    HapticService.instance.onGameOver();

    // Calculate rating changes if rated game
    int? whiteRatingDelta;
    int? blackRatingDelta;

    if (_currentUser != null && widget.mode != GameMode.passAndPlay) {
      final isWhite = widget.playerColor.isWhite;
      final whiteRating =
          isWhite ? _currentUser!.ratingRapid : widget.opponentRating;
      final blackRating =
          isWhite ? widget.opponentRating : _currentUser!.ratingRapid;

      final whiteScore = _gameState.result.isDraw
          ? 0.5
          : (_gameState.winner == PieceColor.white ? 1.0 : 0.0);

      final ratingResult = RatingCalculator.calculateElo(
        whiteRating: whiteRating,
        blackRating: blackRating,
        whiteScore: whiteScore,
        whiteGamesPlayed: _currentUser!.gamesPlayed,
        blackGamesPlayed: 50,
      );

      whiteRatingDelta = ratingResult.whiteRatingDelta;
      blackRatingDelta = ratingResult.blackRatingDelta;

      // Update user stats in repository
      final userDelta = isWhite ? whiteRatingDelta : blackRatingDelta;
      final isWin = _gameState.winner == widget.playerColor;
      final isDraw = _gameState.result.isDraw;

      final updatedProfile = _currentUser!.copyWith(
        ratingRapid: (_currentUser!.ratingRapid + userDelta).clamp(100, 3500),
        gamesPlayed: _currentUser!.gamesPlayed + 1,
        wins: _currentUser!.wins + (isWin ? 1 : 0),
        losses: _currentUser!.losses + (!isWin && !isDraw ? 1 : 0),
        draws: _currentUser!.draws + (isDraw ? 1 : 0),
        winStreak: isWin ? _currentUser!.winStreak + 1 : 0,
      );

      await ServiceLocator.authRepository.updateProfile(updatedProfile);
    }

    // Save match to history
    final pgnString = PgnProcessor.exportPgn(
      state: _gameState,
      white: widget.playerColor.isWhite
          ? (_currentUser?.username ?? 'White')
          : widget.opponentName,
      black: widget.playerColor.isBlack
          ? (_currentUser?.username ?? 'Black')
          : widget.opponentName,
      whiteElo: widget.playerColor.isWhite
          ? _currentUser?.ratingRapid
          : widget.opponentRating,
      blackElo: widget.playerColor.isBlack
          ? _currentUser?.ratingRapid
          : widget.opponentRating,
      timeControl: widget.timeControl.name,
    );

    final matchRecord = ChessMatch(
      id: 'match_${DateTime.now().millisecondsSinceEpoch}',
      whitePlayerId: widget.playerColor.isWhite ? 'user' : 'opp',
      whitePlayerName: widget.playerColor.isWhite
          ? (_currentUser?.username ?? 'White')
          : widget.opponentName,
      whitePlayerRating: widget.playerColor.isWhite
          ? (_currentUser?.ratingRapid ?? 1200)
          : widget.opponentRating,
      blackPlayerId: widget.playerColor.isBlack ? 'user' : 'opp',
      blackPlayerName: widget.playerColor.isBlack
          ? (_currentUser?.username ?? 'Black')
          : widget.opponentName,
      blackPlayerRating: widget.playerColor.isBlack
          ? (_currentUser?.ratingRapid ?? 1200)
          : widget.opponentRating,
      timeControl: widget.timeControl,
      isRated: widget.mode != GameMode.passAndPlay,
      isOnline: widget.mode == GameMode.onlineMultiplayer,
      pgn: pgnString,
      fen: ChessBoard.toFen(_gameState),
      result: _gameState.result,
      winner: _gameState.winner,
      terminationReason: _gameState.terminationReason,
      whiteRatingDelta: whiteRatingDelta,
      blackRatingDelta: blackRatingDelta,
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      endedAt: DateTime.now(),
    );

    await ServiceLocator.gameRepository.saveMatch(matchRecord);

    if (!mounted) return;

    // Show Game Result Celebration Modal
    final userRatingDelta =
        widget.playerColor.isWhite ? whiteRatingDelta : blackRatingDelta;

    GameResultDialog.show(
      context,
      gameState: _gameState,
      playerColor: widget.playerColor,
      ratingDelta: userRatingDelta,
      onRematch: _resetGame,
      onAnalysis: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AnalysisScreen(match: matchRecord),
          ),
        );
      },
      onHome: () => Navigator.of(context).pop(),
    );
  }

  void _resetGame() {
    setState(() {
      _gameState = ChessBoard.initial();
      _whiteTimeMs = widget.timeControl.initialSeconds * 1000;
      _blackTimeMs = widget.timeControl.initialSeconds * 1000;
      _lastMove = null;
    });
    _initGameMode();
  }

  void _confirmResign() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Resign Game?'),
        content: const Text('Are you sure you want to forfeit this match?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rubyError),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (widget.mode == GameMode.onlineMultiplayer) {
                _realtimeServer?.resign();
              } else {
                setState(() {
                  _gameState = _gameState.copyWith(
                    result: GameResult.resignation,
                    winner: widget.playerColor.opponent,
                    terminationReason: 'Resigned by player.',
                  );
                });
                _onGameOver();
              }
            },
            child: const Text('Resign', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _offerDraw() {
    if (widget.mode == GameMode.onlineMultiplayer) {
      _realtimeServer?.offerDraw();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draw offer sent to opponent.')),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: const Text('Offer Draw?'),
          content: const Text('Do both players agree to a draw?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Decline'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _gameState = _gameState.copyWith(
                    result: GameResult.drawByAgreement,
                    winner: null,
                    terminationReason: 'Draw agreed by players.',
                  );
                });
                _onGameOver();
              },
              child: const Text('Accept Draw'),
            ),
          ],
        ),
      );
    }
  }

  void _showDrawOfferedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Draw Offered'),
        content: const Text('Your opponent has offered a draw. Accept?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _realtimeServer?.declineDraw();
            },
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _realtimeServer?.acceptDraw();
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _serverSub?.cancel();
    _realtimeServer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPlayerColor =
        _isFlipped ? PieceColor.white : PieceColor.black;
    final bottomPlayerColor =
        _isFlipped ? PieceColor.black : PieceColor.white;

    final topPlayerName = widget.playerColor == topPlayerColor
        ? (_currentUser?.username ?? 'You')
        : widget.opponentName;
    final topPlayerRating = widget.playerColor == topPlayerColor
        ? _currentUser?.ratingRapid
        : widget.opponentRating;

    final bottomPlayerName = widget.playerColor == bottomPlayerColor
        ? (_currentUser?.username ?? 'You')
        : widget.opponentName;
    final bottomPlayerRating = widget.playerColor == bottomPlayerColor
        ? _currentUser?.ratingRapid
        : widget.opponentRating;

    final topClockMs =
        topPlayerColor.isWhite ? _whiteTimeMs : _blackTimeMs;
    final bottomClockMs =
        bottomPlayerColor.isWhite ? _whiteTimeMs : _blackTimeMs;

    final isTopActive = _gameState.turn == topPlayerColor && !_gameState.isGameOver;
    final isBottomActive =
        _gameState.turn == bottomPlayerColor && !_gameState.isGameOver;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          widget.mode == GameMode.vsAi
              ? 'vs ${widget.aiDifficulty.label} AI'
              : (widget.mode == GameMode.onlineMultiplayer
                  ? 'Online Match'
                  : 'Pass & Play'),
          style: AppTypography.titleMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android_rounded),
            tooltip: 'Flip Board',
            onPressed: () => setState(() => _isFlipped = !_isFlipped),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              // Top Player Info & Clock
              ChessClockWidget(
                playerColor: topPlayerColor,
                remainingMs: topClockMs,
                isActive: isTopActive,
                playerName: topPlayerName,
                playerRating: topPlayerRating,
                title: widget.mode == GameMode.vsAi && topPlayerColor != widget.playerColor ? 'BOT' : null,
                isTop: true,
              ),
              const SizedBox(height: 6),

              // Top Captured Pieces
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CapturedPiecesWidget(
                    capturedPieces: topPlayerColor.isWhite
                        ? _gameState.capturedPiecesWhite
                        : _gameState.capturedPiecesBlack,
                    materialDifference: topPlayerColor.isWhite
                        ? _gameState.materialScore
                        : -_gameState.materialScore,
                    pieceStyle: _settings.pieceStyle,
                  ),
                  if (_isAiThinking)
                    Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Thinking...',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.goldAccent,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Chessboard with Evaluation Bar
              Expanded(
                child: Row(
                  children: [
                    // Evaluation Bar
                    EvaluationBarWidget(
                      scoreCentipawns: _gameState.materialScore * 10,
                      isFlipped: _isFlipped,
                    ),
                    const SizedBox(width: 8),

                    // Main 8x8 Board
                    Expanded(
                      child: ChessBoardWidget(
                        gameState: _gameState,
                        isFlipped: _isFlipped,
                        lastMove: _lastMove,
                        boardTheme: _settings.boardTheme,
                        pieceStyle: _settings.pieceStyle,
                        showCoordinates: _settings.showCoordinates,
                        showLegalMoves: _settings.showLegalMoves,
                        isInteractive: !_isAiThinking &&
                            (widget.mode == GameMode.passAndPlay ||
                                _gameState.turn == widget.playerColor),
                        onMove: _onUserMove,
                        onPromotionRequested: (from, to) =>
                            PromotionDialog.show(
                          context,
                          color: _gameState.turn,
                          pieceStyle: _settings.pieceStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Bottom Captured Pieces
              Align(
                alignment: Alignment.centerLeft,
                child: CapturedPiecesWidget(
                  capturedPieces: bottomPlayerColor.isWhite
                      ? _gameState.capturedPiecesWhite
                      : _gameState.capturedPiecesBlack,
                  materialDifference: bottomPlayerColor.isWhite
                      ? _gameState.materialScore
                      : -_gameState.materialScore,
                  pieceStyle: _settings.pieceStyle,
                ),
              ),
              const SizedBox(height: 6),

              // Bottom Player Info & Clock
              ChessClockWidget(
                playerColor: bottomPlayerColor,
                remainingMs: bottomClockMs,
                isActive: isBottomActive,
                playerName: bottomPlayerName,
                playerRating: bottomPlayerRating,
              ),
              const SizedBox(height: 8),

              // Move History Strip
              MoveHistoryWidget(
                moveHistory: _gameState.moveHistory,
                currentMoveIndex: _gameState.moveHistory.length - 1,
              ),
              const SizedBox(height: 8),

              // In-game Action Controls (Resign, Draw, Settings)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: _gameState.isGameOver ? null : _confirmResign,
                    icon: const Icon(Icons.flag_outlined, size: 16),
                    label: const Text('Resign'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _gameState.isGameOver ? null : _offerDraw,
                    icon: const Icon(Icons.handshake_outlined, size: 16),
                    label: const Text('Draw'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
