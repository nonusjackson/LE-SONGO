enum GameMode { local, vsAi }

class GameResult {
  final DateTime date;
  final String player0Name;
  final String player1Name;
  final int scorePlayer0;
  final int scorePlayer1;
  final int? winner; // 0, 1, ou null pour un match nul
  final GameMode mode;

  GameResult({
    required this.date,
    required this.player0Name,
    required this.player1Name,
    required this.scorePlayer0,
    required this.scorePlayer1,
    required this.winner,
    required this.mode,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'player0Name': player0Name,
        'player1Name': player1Name,
        'scorePlayer0': scorePlayer0,
        'scorePlayer1': scorePlayer1,
        'winner': winner,
        'mode': mode.name,
      };

  factory GameResult.fromJson(Map<String, dynamic> json) => GameResult(
        date: DateTime.parse(json['date'] as String),
        player0Name: json['player0Name'] as String? ?? 'Joueur 1',
        player1Name: json['player1Name'] as String? ?? 'Joueur 2',
        scorePlayer0: json['scorePlayer0'] as int,
        scorePlayer1: json['scorePlayer1'] as int,
        winner: json['winner'] as int?,
        mode: GameMode.values.firstWhere((m) => m.name == json['mode']),
      );
}
