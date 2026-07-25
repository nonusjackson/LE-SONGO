import 'package:flutter_test/flutter_test.dart';
import 'package:songo_app/engine/songo_engine.dart';
import 'package:songo_app/models/board.dart';

SongoBoard boardFrom(
  List<int> pits, {
  int currentPlayer = 0,
  List<int>? captured,
}) {
  return SongoBoard(
    pits: pits,
    captured: captured ?? [0, 0],
    currentPlayer: currentPlayer,
  );
}

void main() {
  group('Semis', () {
    test('semis simple distribue une graine par case sans sauter', () {
      final pits = List.filled(14, 0);
      pits[0] = 5;
      pits[7] = 6; // camp adverse non vide + total plateau >=10
      final board = boardFrom(pits);
      final outcome = SongoEngine.applyMove(board, 0);
      expect(outcome.board.pits[1], 1);
      expect(outcome.board.pits[5], 1);
      expect(outcome.board.pits[6], 0);
      expect(outcome.board.pits[0], 0);
    });

    test(
        "semis >13 graines fait un tour complet sans remplir la case de "
        "départ, puis continue chez l'adversaire (avec répétition depuis "
        "la gauche si nécessaire)", () {
      final pits = List.filled(14, 0);
      pits[0] = 20; // tour complet (13) + 7 de plus = tout le camp adverse
      // reçoit une 2e graine chacun, en repartant de sa case 1.
      final board = boardFrom(pits);
      final outcome = SongoEngine.applyMove(board, 0);
      for (int i = 1; i <= 6; i++) {
        expect(outcome.board.pits[i], 1); // camp du joueur: 1 seul passage
      }
      for (int i = 7; i <= 13; i++) {
        expect(outcome.board.pits[i], 2); // camp adverse: 2 passages
      }
      expect(outcome.board.pits[0], 0); // case de départ jamais remplie
      // la prise (chaîne sur tout le camp adverse) est annulée car elle
      // viderait entièrement le camp adverse.
      expect(outcome.seedsCapturedThisMove, 0);
    });
  });

  group('Prises', () {
    test('prise simple (pas de chaîne) sur une case adverse à 1-3 graines',
        () {
      final pits = List.filled(14, 0);
      pits[5] = 3; // case6 joueur0
      pits[8] = 1; // case2 adverse
      pits[9] = 10; // graines adverses restantes (évite anti-vidage + total>=10)
      final board = boardFrom(pits);
      final outcome = SongoEngine.applyMove(board, 5);
      // 3 graines: idx6(+1, propre camp), idx7(+1, case1 adverse=1),
      // idx8(+1=2, dernière graine) -> prise de idx8 seul (idx7 a 1, hors 2-4)
      expect(outcome.seedsCapturedThisMove, 2);
      expect(outcome.board.pits[8], 0);
      expect(outcome.board.pits[7], 1);
    });

    test('prise à la chaîne incluant la case 1 adverse', () {
      final pits = List.filled(14, 0);
      pits[4] = 5; // case5 joueur0
      pits[7] = 1; // case1 adverse
      pits[8] = 1; // case2 adverse
      pits[9] = 1; // case3 adverse
      pits[10] = 5; // graines adverses restantes (évite la règle anti-vidage)
      final board = boardFrom(pits);
      final outcome = SongoEngine.applyMove(board, 4);
      // 5 graines: idx5,6 (propre camp), idx7,8,9 (adverse, chacune -> 2)
      // dernière graine en idx9 -> chaîne idx9,8,7 (case1 incluse car chaîne)
      expect(outcome.seedsCapturedThisMove, 6);
      expect(outcome.board.pits[7], 0);
      expect(outcome.board.pits[8], 0);
      expect(outcome.board.pits[9], 0);
    });

    test(
        "exception case 1 adverse après un tour complet: capture "
        "uniquement la dernière graine", () {
      final pits = List.filled(14, 0);
      pits[0] = 14; // tour complet exact, retombe sur la case1 adverse
      final board = boardFrom(pits);
      final outcome = SongoEngine.applyMove(board, 0);
      expect(outcome.seedsCapturedThisMove, 1);
    });

    test(
        'pas de prise si la distribution se termine en case 1 adverse '
        'sans tour complet', () {
      final pits = List.filled(14, 0);
      pits[5] = 2; // case6 joueur0
      final board = boardFrom(pits);
      final outcome = SongoEngine.applyMove(board, 5);
      expect(outcome.seedsCapturedThisMove, 0);
    });

    test('interdiction de vider complètement le camp adverse: aucune prise',
        () {
      final pits = List.filled(14, 0);
      pits[0] = 10; // graines côté joueur (non jouées ici, total plateau>=10)
      pits[6] = 3; // case7 joueur0
      pits[7] = 1; // case1 adverse
      pits[8] = 1; // case2 adverse
      pits[9] = 1; // case3 adverse
      // aucune autre graine adverse -> capturer toute la chaîne viderait
      // entièrement le camp adverse
      final board = boardFrom(pits);
      final outcome = SongoEngine.applyMove(board, 6);
      expect(outcome.seedsCapturedThisMove, 0);
      expect(outcome.board.seedsInRow(1), greaterThan(0));
    });
  });

  group('Interdits', () {
    test("interdit de semer 1 ou 2 graines chez l'adversaire depuis la case 7",
        () {
      final pits = List.filled(14, 0);
      pits[6] = 1; // case7 joueur0, 1 graine
      pits[0] = 5; // alternative légale
      pits[7] = 3; // camp adverse non vide (pas de règle de solidarité ici)
      final board = boardFrom(pits);
      final legal = SongoEngine.legalMoves(board);
      expect(legal.contains(6), isFalse);
      expect(legal.contains(0), isTrue);
    });

    test('coup case7 (1-2 graines) autorisé si aucune autre option', () {
      final pits = List.filled(14, 0);
      pits[6] = 1; // seule case non vide du joueur 0
      pits[7] = 3; // camp adverse non vide (pas de règle de solidarité ici)
      final board = boardFrom(pits);
      final legal = SongoEngine.legalMoves(board);
      expect(legal, [6]);
    });
  });

  group('Solidarité', () {
    test(
        'doit jouer un coup distribuant au moins 7 graines si le camp '
        'adverse est vide', () {
      final pits = List.filled(14, 0);
      pits[0] = 6; // n'atteint pas le camp adverse
      pits[3] = 10; // atteint le camp adverse avec 7 graines ou plus
      final board = boardFrom(pits);
      final legal = SongoEngine.legalMoves(board);
      expect(legal, [3]);
    });

    test(
        'si aucun coup ne peut apporter 7 graines, joue celui qui en '
        'apporte le plus', () {
      final pits = List.filled(14, 0);
      pits[0] = 3;
      pits[3] = 5; // apporte plus de graines chez l'adversaire que idx0
      final board = boardFrom(pits);
      final legal = SongoEngine.legalMoves(board);
      expect(legal, [3]);
    });
  });

  group('Fin de partie', () {
    test('victoire à 40 graines capturées', () {
      final pits = List.filled(14, 0);
      pits[6] = 2; // case7 joueur0
      pits[7] = 1; // case1 adverse
      pits[8] = 1; // case2 adverse
      pits[10] = 3; // évite la règle anti-vidage
      final board = boardFrom(pits, captured: [38, 0]);
      final outcome = SongoEngine.applyMove(board, 6);
      expect(outcome.status, GameStatus.finished);
      expect(outcome.winner, 0);
    });

    test('moins de 10 graines sur le plateau termine la partie', () {
      final pits = List.filled(14, 0);
      pits[0] = 3;
      pits[7] = 4;
      final board = boardFrom(pits, captured: [30, 33]);
      final outcome = SongoEngine.applyMove(board, 0);
      expect(outcome.status, GameStatus.finished);
    });

    test("match nul si personne n'atteint 40 graines", () {
      final pits = List.filled(14, 0);
      pits[0] = 3;
      pits[7] = 4;
      final board = boardFrom(pits, captured: [33, 30]);
      final outcome = SongoEngine.applyMove(board, 0);
      expect(outcome.status, GameStatus.finished);
      expect(outcome.winner, isNull);
    });
  });
}
