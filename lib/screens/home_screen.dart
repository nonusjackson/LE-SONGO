import 'package:flutter/material.dart';

import '../models/ai_difficulty.dart';
import '../theme/songo_theme.dart';
import 'game_screen.dart';
import 'history_screen.dart';
import 'rules_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _startLocal(BuildContext context) async {
    final names = await showDialog<(String, String)>(
      context: context,
      builder: (context) => const _LocalNamesDialog(),
    );
    if (names == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          vsAi: false,
          player0Name: names.$1,
          player1Name: names.$2,
        ),
      ),
    );
  }

  Future<void> _startVsAi(BuildContext context) async {
    final setup = await showDialog<(String, AiDifficulty)>(
      context: context,
      builder: (context) => const _VsAiSetupDialog(),
    );
    if (setup == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          vsAi: true,
          player0Name: setup.$1,
          difficulty: setup.$2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Songo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _startLocal(context),
              child: const Text('Local (2 joueurs)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _startVsAi(context),
              child: const Text("Contre l'IA"),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RulesScreen()),
              ),
              child: const Text('Règles du jeu'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
              child: const Text('Historique'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalNamesDialog extends StatefulWidget {
  const _LocalNamesDialog();

  @override
  State<_LocalNamesDialog> createState() => _LocalNamesDialogState();
}

class _LocalNamesDialogState extends State<_LocalNamesDialog> {
  final _p1Controller = TextEditingController();
  final _p2Controller = TextEditingController();

  @override
  void dispose() {
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  void _submit() {
    final p1 = _p1Controller.text.trim();
    final p2 = _p2Controller.text.trim();
    Navigator.of(context).pop((
      p1.isEmpty ? 'Joueur 1' : p1,
      p2.isEmpty ? 'Joueur 2' : p2,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Prénoms des joueurs'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _p1Controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Joueur 1'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _p2Controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Joueur 2'),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submit,
          child: const Text('Commencer'),
        ),
      ],
    );
  }
}

class _VsAiSetupDialog extends StatefulWidget {
  const _VsAiSetupDialog();

  @override
  State<_VsAiSetupDialog> createState() => _VsAiSetupDialogState();
}

class _VsAiSetupDialogState extends State<_VsAiSetupDialog> {
  final _nameController = TextEditingController();
  AiDifficulty _difficulty = AiDifficulty.moyen;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    Navigator.of(context).pop((name.isEmpty ? 'Joueur 1' : name, _difficulty));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Contre l'IA"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Ton prénom'),
          ),
          const SizedBox(height: 16),
          Text('Difficulté', style: SongoTextStyles.label),
          ...AiDifficulty.values.map((d) {
            return RadioListTile<AiDifficulty>(
              contentPadding: EdgeInsets.zero,
              value: d,
              groupValue: _difficulty,
              title: Text(d.label, style: SongoTextStyles.label),
              subtitle: Text(d.description, style: SongoTextStyles.labelMuted),
              onChanged: (value) => setState(() => _difficulty = value!),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submit,
          child: const Text('Commencer'),
        ),
      ],
    );
  }
}
