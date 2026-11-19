import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/mettle_colors.dart';
import '../../theme/mettle_text.dart';
import '../../theme/size_class.dart';

class ScoreRing extends StatelessWidget {
  const ScoreRing({required this.score, this.bandLabel, super.key});

  final int? score;
  final String? bandLabel;

  static const emptySize = 96.0;
  static const scoreSize = 104.0;

  @override
  Widget build(BuildContext context) {
    final value = score;

    return Semantics(
      label: value == null
          ? AppStrings.readinessUnavailable
          : AppStrings.readinessSemantics(value, bandLabel ?? ''),
      child: ExcludeSemantics(
        child: value == null ? const _EmptyRing() : _ScoreRing(score: value),
      ),
    );
  }
}

class _EmptyRing extends StatelessWidget {
  const _EmptyRing();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: ScoreRing.emptySize,
      height: ScoreRing.emptySize,
      child: CustomPaint(
        painter: _DashedPainter(color: colors.borderDefault),
        child: Center(
          child: Text(
            AppStrings.emptyValue,
            style: context.text.monoPlaceholder,
          ),
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;
    final duration = context.motion(const Duration(milliseconds: 600));

    return SizedBox(
      width: ScoreRing.scoreSize,
      height: ScoreRing.scoreSize,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: score / 100),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, sweep, _) => CustomPaint(
          painter: _ArcPainter(
            sweep: sweep,
            track: colors.borderDefault,
            progress: colors.accent,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontFamily: MettleText.mono,
                    fontSize: 26,
                    height: 30 / 26,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(AppStrings.readinessOutOf, style: styles.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.sweep,
    required this.track,
    required this.progress,
  });

  final double sweep;
  final Color track;
  final Color progress;

  static const stroke = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (sweep <= 0) return;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * sweep.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = progress
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.sweep != sweep || old.track != track || old.progress != progress;
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter({required this.color});

  final Color color;

  static const stroke = 8.0;
  static const dashes = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    const segment = 2 * math.pi / (dashes * 2);
    for (var index = 0; index < dashes; index++) {
      canvas.drawArc(
        rect,
        -math.pi / 2 + index * segment * 2,
        segment,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) => old.color != color;
}
