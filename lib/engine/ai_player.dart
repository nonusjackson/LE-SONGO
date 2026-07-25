import 'dart:math';

import '../models/board.dart';
import 'songo_engine.dart';

class AiPlayer {
  final int depth;
  final double mistakeChance;
  final Random _random = Random();

  AiPlayer({this.depth = 4, this.mistakeChance = 0.0});

  int chooseMove(SongoBoard board) {
    final legal = SongoEngine.legalMoves(board);
    if (legal.isEmpty) {
      throw StateError("Aucun coup légal disponible pour l'IA");
    }
    if (legal.length == 1) return legal.first;

    if (mistakeChance > 0 && _random.nextDouble() < mistakeChance) {
      return legal[_random.nextInt(legal.length)];
    }

    final player = board.currentPlayer;
    int? bestMove;
    double bestScore = double.negativeInfinity;
    final shuffled = List<int>.from(legal)..shuffle(_random);

    for (final move in shuffled) {
      final outcome = SongoEngine.applyMove(board, move);
      final score = _minimax(
        outcome.board,
        depth - 1,
        double.negativeInfinity,
        double.infinity,
        player,
        outcome.status == GameStatus.finished,
      );
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove!;
  }

  double _minimax(
    SongoBoard board,
    int depth,
    double alpha,
    double beta,
    int aiPlayer,
    bool gameEnded,
  ) {
    if (gameEnded || depth == 0) {
      return _heuristic(board, aiPlayer);
    }

    final legal = SongoEngine.legalMoves(board);
    if (legal.isEmpty) {
      return _heuristic(board, aiPlayer);
    }

    final maximizing = board.currentPlayer == aiPlayer;
    double best = maximizing ? double.negativeInfinity : double.infinity;

    for (final move in legal) {
      final outcome = SongoEngine.applyMove(board, move);
      final score = _minimax(
        outcome.board,
        depth - 1,
        alpha,
        beta,
        aiPlayer,
        outcome.status == GameStatus.finished,
      );
      if (maximizing) {
        best = max(best, score);
        alpha = max(alpha, best);
      } else {
        best = min(best, score);
        beta = min(beta, best);
      }
      if (beta <= alpha) break;
    }
    return best;
  }

  double _heuristic(SongoBoard board, int aiPlayer) {
    final opponent = board.opponentOf(aiPlayer);
    final capturedDiff =
        (board.captured[aiPlayer] - board.captured[opponent]).toDouble();
    final seedsDiff =
        (board.seedsInRow(aiPlayer) - board.seedsInRow(opponent)) * 0.1;
    return capturedDiff + seedsDiff;
  }
}
