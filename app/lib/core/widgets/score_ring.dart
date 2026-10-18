import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../theme/score_colors.dart';

class ScoreRing extends StatelessWidget {
  const ScoreRing({
    required this.score,
    this.size = AppDimens.scoreRingSize,
    this.label,
    this.animate = true,
    super.key,
  });

  final int? score;
  final double size;

  final String? label;

  final bool animate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = score;

    final semanticLabel = value == null
        ? 'No score yet'
        : '${label ?? 'Score'} $value out of 100, '
              '${ScoreColors.labelFor(value)}';

    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: (value ?? 0) / 100),
          duration: animate && value != null
              ? const Duration(milliseconds: 600)
              : Duration.zero,
          curve: Curves.easeOutCubic,
          builder: (context, fraction, _) {
            return CustomPaint(
              painter: _ScoreRingPainter(
                fraction: value == null ? 0 : fraction,
                track: theme.colorScheme.outline,
                arc: value == null
                    ? theme.colorScheme.outline
                    : context.scoreColors.forScore(value),
                stroke:
                    AppDimens.scoreRingStroke *
                    (size / AppDimens.scoreRingSize),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value?.toString() ?? '—',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (label != null)
                      Text(label!, style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({
    required this.fraction,
    required this.track,
    required this.arc,
    required this.stroke,
  });

  final double fraction;
  final Color track;
  final Color arc;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    if (fraction <= 0) return;

    final arcPaint = Paint()
      ..color = arc
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * fraction.clamp(0.0, 1.0),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.fraction != fraction ||
      old.arc != arc ||
      old.track != track ||
      old.stroke != stroke;
}
