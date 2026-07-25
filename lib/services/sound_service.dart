import 'package:audioplayers/audioplayers.dart';

/// Joue les effets sonores du jeu. Un player dédié par type de son pour
/// pouvoir en superposer plusieurs sans qu'ils se coupent (ex: plusieurs
/// graines qui tombent rapidement pendant un semis).
class SoundService {
  bool enabled = true;

  final AudioPlayer _seedPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _capturePlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _endPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  Future<void> playSeedDrop() async {
    if (!enabled) return;
    await _seedPlayer.play(AssetSource('sounds/pop.wav'), volume: 0.5);
  }

  Future<void> playCapture() async {
    if (!enabled) return;
    await _capturePlayer.play(AssetSource('sounds/capture.wav'), volume: 0.7);
  }

  Future<void> playVictory() async {
    if (!enabled) return;
    await _endPlayer.play(AssetSource('sounds/victory.wav'), volume: 0.8);
  }

  Future<void> playEndNeutral() async {
    if (!enabled) return;
    await _endPlayer.play(AssetSource('sounds/defeat.wav'), volume: 0.6);
  }

  void dispose() {
    _seedPlayer.dispose();
    _capturePlayer.dispose();
    _endPlayer.dispose();
  }
}
