import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/songo_theme.dart';

class PitWidget extends StatelessWidget {
  final int seeds;
  final bool enabled;
  final bool flashCapture;
  final bool isHint;
  final VoidCallback? onTap;
  final double size;

  const PitWidget({
    super.key,
    required this.seeds,
    this.enabled = false,
    this.flashCapture = false,
    this.isHint = false,
    this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final glowColor = flashCapture
        ? SongoColors.captureFlash
        : (isHint ? SongoColors.hintBlue : SongoColors.accentGold);
    final showGlow = enabled || flashCapture;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        margin: EdgeInsets.all(size * 0.08),
        decoration: showGlow
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: glowColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              )
            : null,
        child: CustomPaint(
          size: Size.square(size),
          painter: _PitPainter(seeds: seeds),
          child: Center(
            child: Text(
              '$seeds',
              style: SongoTextStyles.seedCount.copyWith(
                fontSize: size * 0.32,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Peint la case comme un vrai trou creusé dans le bois (dégradé radial
/// inversé + lumière au rebord) plutôt qu'un simple disque plat, et parsème
/// quelques graines décoratives pour donner du volume — le décompte exact
/// reste porté par le nombre affiché par-dessus (lisibilité prioritaire).
class _PitPainter extends CustomPainter {
  final int seeds;

  _PitPainter({required this.seeds});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final holeGradient = const RadialGradient(
      colors: [
        SongoColors.pitCenter,
        SongoColors.woodDark,
        SongoColors.woodMid,
      ],
      stops: [0.0, 0.65, 1.0],
    );
    final holePaint = Paint()
      ..shader = holeGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, holePaint);

    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.18),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: center.translate(-radius * 0.35, -radius * 0.4),
          radius: radius * 0.7,
        ),
      );
    canvas.drawCircle(center, radius, highlightPaint);

    final decorativeCount = min(seeds, 5);
    final rand = Random(seeds * 7 + 13);
    for (int i = 0; i < decorativeCount; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final dist = rand.nextDouble() * radius * 0.45;
      final seedCenter = center.translate(
        cos(angle) * dist,
        sin(angle) * dist,
      );
      _drawSeed(canvas, seedCenter, radius * 0.22);
    }
  }

  void _drawSeed(Canvas canvas, Offset seedCenter, double seedRadius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawOval(
      Rect.fromCenter(
        center: seedCenter.translate(0, seedRadius * 0.3),
        width: seedRadius * 2,
        height: seedRadius * 1.4,
      ),
      shadowPaint,
    );

    final seedPaint = Paint()
      ..shader = const RadialGradient(
        colors: [SongoColors.seedLight, SongoColors.seedDark],
        stops: [0.0, 1.0],
        center: Alignment.topLeft,
      ).createShader(Rect.fromCircle(center: seedCenter, radius: seedRadius));
    canvas.drawOval(
      Rect.fromCenter(
        center: seedCenter,
        width: seedRadius * 2,
        height: seedRadius * 1.5,
      ),
      seedPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PitPainter oldDelegate) =>
      oldDelegate.seeds != seeds;
}
