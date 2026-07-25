import 'package:flutter/material.dart';

import '../engine/ai_player.dart';
import '../engine/songo_engine.dart';
import '../models/ai_difficulty.dart';
import '../models/board.dart';
import '../models/game_result.dart';
import '../services/history_service.dart';
import '../services/sound_service.dart';
import '../theme/songo_theme.dart';
import '../widgets/board_widget.dart';
import 'rules_screen.dart';

class GameScreen extends StatefulWidget {
  final bool vsAi;
  final AiDifficulty difficulty;
  final String player0Name;
  final String player1Name;

  GameScreen({
    super.key,
    required this.vsAi,
    this.difficulty = AiDifficulty.moyen,
    this.player0Name = 'Joueur 1',
    String? player1Name,
  }) : player1Name = player1Name ?? (vsAi ? 'IA' : 'Joueur 2');

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SongoBoard _board;
  final _historyService = HistoryService();
  final _sound = SoundService();
  late final _ai = AiPlayer(
    depth: widget.difficulty.depth,
    mistakeChance: widget.difficulty.mistakeChance,
  );
  final _hintAi = AiPlayer(depth: 4);
  final _boardKey = GlobalKey<BoardWidgetState>();
  String? _message;
  int? _hintPit;
  bool _gameOver = false;
  bool _aiThinking = false;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _board = SongoBoard.initial();
  }

  @override
  void dispose() {
    _sound.dispose();
    super.dispose();
  }

  bool get _isAiTurn => widget.vsAi && _board.currentPlayer == 1;

  bool get _canRequestHint =>
      !_gameOver && !_isAiTurn && !_animating && !_aiThinking;

  List<int> get _playableIndices =>
      _gameOver || _isAiTurn || _animating ? [] : SongoEngine.legalMoves(_board);

  void _showHint() {
    if (!_canRequestHint) return;
    setState(() => _hintPit = _hintAi.chooseMove(_board));
  }

  void _playPit(int pitIndex) {
    if (_gameOver || _isAiTurn || _animating) return;
    _performMove(pitIndex);
  }

  Future<void> _performMove(int pitIndex) async {
    final order = SongoEngine.sowOrder(_board, pitIndex);
    final outcome = SongoEngine.applyMove(_board, pitIndex);

    setState(() {
      _animating = true;
      _hintPit = null;
    });
    await _boardKey.currentState?.animateMove(
      pitIndex,
      order,
      outcome.capturedPits,
    );
    if (!mounted) return;

    setState(() {
      _board = outcome.board;
      _animating = false;
      _message = outcome.seedsCapturedThisMove > 0
          ? '${outcome.seedsCapturedThisMove} graine(s) capturée(s)'
          : null;
    });

    if (outcome.status == GameStatus.finished) {
      await _endGame(outcome.winner);
      return;
    }

    if (_isAiTurn) {
      _playAiTurn();
    }
  }

  Future<void> _playAiTurn() async {
    setState(() => _aiThinking = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final move = _ai.chooseMove(_board);
    if (!mounted) return;
    setState(() => _aiThinking = false);
    await _performMove(move);
  }

  Future<void> _endGame(int? winner) async {
    setState(() => _gameOver = true);
    if (winner != null) {
      _sound.playVictory();
    } else {
      _sound.playEndNeutral();
    }
    final result = GameResult(
      date: DateTime.now(),
      player0Name: widget.player0Name,
      player1Name: widget.player1Name,
      scorePlayer0: _board.captured[0],
      scorePlayer1: _board.captured[1],
      winner: winner,
      mode: widget.vsAi ? GameMode.vsAi : GameMode.local,
    );
    await _historyService.addResult(result);
  }

  void _restart() {
    setState(() {
      _board = SongoBoard.initial();
      _gameOver = false;
      _animating = false;
      _message = null;
      _hintPit = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scoreText =
        '${widget.player0Name}: ${_board.captured[0]}   '
        '${widget.player1Name}: ${_board.captured[1]}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Songo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Indice',
            onPressed: _canRequestHint ? _showHint : null,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Règles du jeu',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RulesScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(scoreText, style: SongoTextStyles.score),
            const SizedBox(height: 8),
            if (_aiThinking)
              Text("L'IA réfléchit...", style: SongoTextStyles.labelMuted),
            if (_message != null)
              Text(
                _message!,
                style: SongoTextStyles.label.copyWith(
                  color: SongoColors.captureFlash,
                ),
              ),
            const SizedBox(height: 16),
            BoardWidget(
              key: _boardKey,
              board: _board,
              playableIndices: _playableIndices,
              onPitTap: _playPit,
              sound: _sound,
              hintPit: _hintPit,
            ),
            const SizedBox(height: 16),
            if (!_gameOver)
              Text(
                'Tour de ${_board.currentPlayer == 0 ? widget.player0Name : widget.player1Name}',
                style: SongoTextStyles.labelMuted,
              )
            else
              Text(
                _board.captured[0] == _board.captured[1]
                    ? 'Match nul'
                    : 'Victoire de ${_winnerLabel()}',
                style: SongoTextStyles.title,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _restart,
              child: const Text('Nouvelle partie'),
            ),
          ],
        ),
      ),
    );
  }

  String _winnerLabel() {
    return _board.captured[0] > _board.captured[1]
        ? widget.player0Name
        : widget.player1Name;
  }
}
