import 'package:flutter/material.dart';

import '../models/game_result.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService();
  late Future<List<GameResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = _historyService.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: FutureBuilder<List<GameResult>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final results = snapshot.data!;
          if (results.isEmpty) {
            return const Center(
              child: Text('Aucune partie jouée pour le moment.'),
            );
          }
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final r = results[index];
              final winnerLabel = r.winner == null
                  ? 'Match nul'
                  : (r.winner == 0 ? r.player0Name : r.player1Name);
              return ListTile(
                title: Text(
                  '${r.player0Name} ${r.scorePlayer0} - ${r.scorePlayer1} '
                  '${r.player1Name}  •  $winnerLabel',
                ),
                subtitle: Text(
                  '${r.mode == GameMode.vsAi ? "Contre l'IA" : "Local"} · ${r.date.toLocal()}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
