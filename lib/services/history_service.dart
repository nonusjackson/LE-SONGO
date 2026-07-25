import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_result.dart';

class HistoryService {
  static const _key = 'songo_last_games';
  static const maxEntries = 3;

  Future<List<GameResult>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => GameResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addResult(GameResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();
    history.insert(0, result);
    final trimmed = history.take(maxEntries).toList();
    final raw = jsonEncode(trimmed.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
