class SongoBoard {
  final List<int> pits; // 14 pits, 0-6 = joueur 0, 7-13 = joueur 1
  final List<int> captured; // captured[0], captured[1]
  final int currentPlayer; // 0 ou 1

  const SongoBoard({
    required this.pits,
    required this.captured,
    required this.currentPlayer,
  });

  factory SongoBoard.initial() => SongoBoard(
        pits: List.filled(14, 5),
        captured: [0, 0],
        currentPlayer: 0,
      );

  SongoBoard copyWith({
    List<int>? pits,
    List<int>? captured,
    int? currentPlayer,
  }) {
    return SongoBoard(
      pits: pits ?? List<int>.from(this.pits),
      captured: captured ?? List<int>.from(this.captured),
      currentPlayer: currentPlayer ?? this.currentPlayer,
    );
  }

  int rowStart(int player) => player == 0 ? 0 : 7;

  int opponentOf(int player) => 1 - player;

  List<int> rowIndices(int player) {
    final start = rowStart(player);
    return List.generate(7, (i) => start + i);
  }

  int seedsInRow(int player) =>
      rowIndices(player).fold(0, (sum, i) => sum + pits[i]);

  int totalSeedsOnBoard() => pits.fold(0, (a, b) => a + b);
}
