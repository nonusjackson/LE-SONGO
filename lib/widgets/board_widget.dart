import 'package:flutter/material.dart';

import '../models/board.dart';
import '../services/sound_service.dart';
import '../theme/songo_theme.dart';
import 'pit_widget.dart';

class BoardWidget extends StatefulWidget {
  final SongoBoard board;
  final List<int> playableIndices;
  final ValueChanged<int> onPitTap;
  final SoundService? sound;
  final int? hintPit;

  const BoardWidget({
    super.key,
    required this.board,
    required this.playableIndices,
    required this.onPitTap,
    this.sound,
    this.hintPit,
  });

  @override
  State<BoardWidget> createState() => BoardWidgetState();
}

class BoardWidgetState extends State<BoardWidget> {
  late List<int> _displayPits;
  final GlobalKey _stackKey = GlobalKey();
  final List<GlobalKey> _pitKeys = List.generate(14, (_) => GlobalKey());
  Offset? _markerPos;
  double _markerScale = 0;
  Set<int> _flashPits = {};
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _displayPits = List<int>.from(widget.board.pits);
  }

  @override
  void didUpdateWidget(covariant BoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_locked) {
      _displayPits = List<int>.from(widget.board.pits);
    }
  }

  Offset? _pitCenter(int index) {
    final ctx = _pitKeys[index].currentContext;
    final stackCtx = _stackKey.currentContext;
    if (ctx == null || stackCtx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    final stackBox = stackCtx.findRenderObject() as RenderBox?;
    if (box == null || stackBox == null) return null;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: stackBox);
    return topLeft + Offset(box.size.width / 2, box.size.height / 2);
  }

  /// Anime le semis graine par graine le long de [order], puis (si des
  /// cases ont été prises) fait clignoter [capturedPits] avant qu'elles se
  /// vident. Le plateau reste verrouillé (non jouable) tout le temps de
  /// l'animation.
  Future<void> animateMove(
    int startPit,
    List<int> order,
    List<int> capturedPits,
  ) async {
    setState(() {
      _locked = true;
      _displayPits[startPit] = 0;
      _markerScale = 1;
      _markerPos = _pitCenter(startPit);
    });
    await Future<void>.delayed(const Duration(milliseconds: 30));

    for (final target in order) {
      final targetPos = _pitCenter(target);
      if (targetPos != null && mounted) {
        setState(() => _markerPos = targetPos);
        await Future<void>.delayed(const Duration(milliseconds: 130));
      }
      if (!mounted) return;
      setState(() => _displayPits[target] += 1);
      widget.sound?.playSeedDrop();
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }

    if (!mounted) return;
    setState(() => _markerScale = 0);
    await Future<void>.delayed(const Duration(milliseconds: 120));

    if (capturedPits.isNotEmpty && mounted) {
      widget.sound?.playCapture();
      setState(() => _flashPits = capturedPits.toSet());
      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;
      setState(() {
        for (final p in capturedPits) {
          _displayPits[p] = 0;
        }
        _flashPits = {};
      });
    }

    if (!mounted) return;
    setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    // Rangée du joueur 1 (haut), inversée pour que sa case 1 reste du même
    // côté visuel que la case 1 du joueur 0, comme sur le tablier physique.
    final topRow = List.generate(7, (i) => 13 - i);
    final bottomRow = List.generate(7, (i) => i);

    final screenWidth = MediaQuery.of(context).size.width;
    final pitSize = ((screenWidth - 64) / 7).clamp(40.0, 64.0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SongoColors.woodMid, SongoColors.woodDark],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        key: _stackKey,
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRow(topRow, pitSize),
              const SizedBox(height: 20),
              _buildRow(bottomRow, pitSize),
            ],
          ),
          if (_markerPos != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 130),
              curve: Curves.easeInOut,
              left: _markerPos!.dx - pitSize * 0.11,
              top: _markerPos!.dy - pitSize * 0.11,
              child: AnimatedScale(
                scale: _markerScale,
                duration: const Duration(milliseconds: 120),
                child: _TravelingSeed(size: pitSize * 0.22),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(List<int> indices, double pitSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indices.map((i) {
        return Container(
          key: _pitKeys[i],
          child: PitWidget(
            seeds: _displayPits[i],
            enabled: !_locked && widget.playableIndices.contains(i),
            flashCapture: _flashPits.contains(i),
            isHint: widget.hintPit == i,
            onTap: () => widget.onPitTap(i),
            size: pitSize,
          ),
        );
      }).toList(),
    );
  }
}

class _TravelingSeed extends StatelessWidget {
  final double size;

  const _TravelingSeed({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [SongoColors.seedLight, SongoColors.seedDark],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
