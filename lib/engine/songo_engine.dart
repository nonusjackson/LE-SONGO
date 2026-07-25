import '../models/board.dart';

enum GameStatus { ongoing, finished }

class MoveOutcome {
  final SongoBoard board;
  final List<int> capturedPits;
  final int seedsCapturedThisMove;
  final GameStatus status;
  final int? winner; // défini quand status == finished (null = match nul)

  MoveOutcome({
    required this.board,
    required this.capturedPits,
    required this.seedsCapturedThisMove,
    required this.status,
    required this.winner,
  });
}

class SongoEngine {
  static const int pitCount = 14;
  static const int rowSize = 7;
  static const int winThreshold = 40;
  static const int endGameThreshold = 10; // partie finie si total plateau < ce seuil

  /// Graines qui atterriraient chez l'adversaire si [pitIndex] est joué,
  /// sans modifier [board]. Utilisé pour la règle de solidarité.
  static int _seedsToOpponent(SongoBoard board, int pitIndex) {
    final sim = _sow(board, pitIndex);
    final opponent = board.opponentOf(board.currentPlayer);
    final oppStart = board.rowStart(opponent);
    int delivered = 0;
    for (int i = 0; i < rowSize; i++) {
      final idx = oppStart + i;
      delivered += sim.pits[idx] - board.pits[idx];
    }
    return delivered;
  }

  static bool _isForbiddenCase7Move(SongoBoard board, int pitIndex) {
    final player = board.currentPlayer;
    final case7 = board.rowStart(player) + (rowSize - 1);
    if (pitIndex != case7) return false;
    final seeds = board.pits[pitIndex];
    return seeds == 1 || seeds == 2;
  }

  /// Cases jouables par le joueur courant, en appliquant la règle de
  /// solidarité et l'interdit de la case 7 (1 ou 2 graines).
  static List<int> legalMoves(SongoBoard board) {
    final player = board.currentPlayer;
    final opponent = board.opponentOf(player);
    final ownNonEmpty =
        board.rowIndices(player).where((i) => board.pits[i] > 0).toList();
    final normalCandidates =
        ownNonEmpty.where((i) => !_isForbiddenCase7Move(board, i)).toList();

    final solidarityActive = board.seedsInRow(opponent) == 0;

    if (!solidarityActive) {
      return normalCandidates.isNotEmpty ? normalCandidates : ownNonEmpty;
    }

    final candidates =
        normalCandidates.isNotEmpty ? normalCandidates : ownNonEmpty;
    if (candidates.isEmpty) return [];

    final delivered = {
      for (final i in candidates) i: _seedsToOpponent(board, i),
    };
    final atLeast7 = candidates.where((i) => delivered[i]! >= 7).toList();
    if (atLeast7.isNotEmpty) return atLeast7;

    final maxDelivered = delivered.values.reduce((a, b) => a > b ? a : b);
    if (maxDelivered == 0) return [];
    return candidates.where((i) => delivered[i] == maxDelivered).toList();
  }

  /// Distribue les graines de [pitIndex] autour du plateau (sans appliquer
  /// les prises), renvoie le nouveau plateau et l'indice de la dernière case
  /// remplie.
  static _SowResult _sow(SongoBoard board, int pitIndex) {
    final pits = List<int>.from(board.pits);
    final seeds = pits[pitIndex];
    pits[pitIndex] = 0;
    final order = <int>[];

    int lastPit = pitIndex;
    if (seeds <= pitCount - 1) {
      int idx = pitIndex;
      for (int i = 0; i < seeds; i++) {
        idx = (idx + 1) % pitCount;
        pits[idx]++;
        order.add(idx);
        lastPit = idx;
      }
    } else {
      // Tour complet (13 graines) en sautant la case de départ, puis
      // distribution exclusive dans le camp adverse (avec répétition).
      int idx = pitIndex;
      for (int i = 0; i < pitCount - 1; i++) {
        idx = (idx + 1) % pitCount;
        pits[idx]++;
        order.add(idx);
        lastPit = idx;
      }
      int remaining = seeds - (pitCount - 1);
      final opponent = board.opponentOf(board.currentPlayer);
      final oppStart = board.rowStart(opponent);
      int oppIdx = 0;
      while (remaining > 0) {
        final target = oppStart + (oppIdx % rowSize);
        pits[target]++;
        order.add(target);
        lastPit = target;
        oppIdx++;
        remaining--;
      }
    }
    return _SowResult(pits, lastPit, order);
  }

  /// Ordre exact, case par case, dans lequel les graines de [pitIndex] sont
  /// semées — utilisé côté UI pour animer le trajet des graines.
  static List<int> sowOrder(SongoBoard board, int pitIndex) {
    return _sow(board, pitIndex).order;
  }

  /// Joue [pitIndex] pour le joueur courant du plateau et renvoie le
  /// plateau résultant ainsi que les infos de prise / fin de partie.
  static MoveOutcome applyMove(SongoBoard board, int pitIndex) {
    final legal = legalMoves(board);
    if (!legal.contains(pitIndex)) {
      throw ArgumentError('Coup illégal: case $pitIndex');
    }

    final player = board.currentPlayer;
    final opponent = board.opponentOf(player);
    final oppStart = board.rowStart(opponent);
    final seedsPlayed = board.pits[pitIndex];

    final sown = _sow(board, pitIndex);
    var pits = sown.pits;
    final lastPit = sown.lastPit;
    final captured = List<int>.from(board.captured);
    var capturedPits = <int>[];
    var seedsCapturedThisMove = 0;

    final lastPitIsOpponentRow =
        lastPit >= oppStart && lastPit < oppStart + rowSize;
    if (lastPitIsOpponentRow) {
      final isCase1 = lastPit == oppStart;
      if (isCase1) {
        if (seedsPlayed >= pitCount) {
          // Exception: au moins un tour complet, on termine sur la case 1
          // adverse -> seule la toute dernière graine est capturée.
          pits[lastPit] -= 1;
          seedsCapturedThisMove = 1;
          capturedPits = [lastPit];
        }
        // sinon: aucune prise.
      } else {
        final count = pits[lastPit];
        if (count >= 2 && count <= 4) {
          final chain = <int>[];
          int idx = lastPit;
          while (idx >= oppStart) {
            final c = pits[idx];
            if (c >= 2 && c <= 4) {
              chain.add(idx);
              idx--;
            } else {
              break;
            }
          }
          // Interdit: vider complètement le camp adverse.
          final remainingAfterCapture = board
              .rowIndices(opponent)
              .where((i) => !chain.contains(i))
              .fold(0, (sum, i) => sum + pits[i]);
          if (remainingAfterCapture > 0) {
            for (final i in chain) {
              seedsCapturedThisMove += pits[i];
              pits[i] = 0;
            }
            capturedPits = chain;
          }
        }
      }
    }

    captured[player] += seedsCapturedThisMove;

    final newBoard = board.copyWith(
      pits: pits,
      captured: captured,
      currentPlayer: opponent,
    );

    final ending = _checkEndOfGame(newBoard);
    if (ending != null) {
      return MoveOutcome(
        board: ending.board,
        capturedPits: capturedPits,
        seedsCapturedThisMove: seedsCapturedThisMove,
        status: GameStatus.finished,
        winner: ending.winner,
      );
    }

    return MoveOutcome(
      board: newBoard,
      capturedPits: capturedPits,
      seedsCapturedThisMove: seedsCapturedThisMove,
      status: GameStatus.ongoing,
      winner: null,
    );
  }

  static _EndCheck? _checkEndOfGame(SongoBoard board) {
    if (board.captured[0] >= winThreshold) {
      return _EndCheck(board, 0);
    }
    if (board.captured[1] >= winThreshold) {
      return _EndCheck(board, 1);
    }

    final boardEmptying = board.totalSeedsOnBoard() < endGameThreshold;
    final solidarityImpossible = !boardEmptying && legalMoves(board).isEmpty;

    if (boardEmptying || solidarityImpossible) {
      final captured = List<int>.from(board.captured);
      captured[0] += board.seedsInRow(0);
      captured[1] += board.seedsInRow(1);
      final finalBoard = board.copyWith(
        pits: List.filled(pitCount, 0),
        captured: captured,
      );
      return _EndCheck(finalBoard, _winnerFrom(captured));
    }

    return null;
  }

  static int? _winnerFrom(List<int> captured) {
    if (captured[0] >= winThreshold) return 0;
    if (captured[1] >= winThreshold) return 1;
    return null;
  }
}

class _SowResult {
  final List<int> pits;
  final int lastPit;
  final List<int> order;
  _SowResult(this.pits, this.lastPit, this.order);
}

class _EndCheck {
  final SongoBoard board;
  final int? winner;
  _EndCheck(this.board, this.winner);
}
