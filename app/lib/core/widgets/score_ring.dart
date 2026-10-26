import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../theme/score_colors.dart';
import 'status_dot.dart';

class ScoreRing extends StatelessWidget {
  const ScoreRing({
    required this.score,
    this.size = AppDimens.scoreRingSize,
    this.animate = true,
    super.key,
  });

  final int? score;
  final double size;

  final bool animate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = score;

    return Semantics(
      label: value == null
          ? AppStrings.noScoreYet
          : AppStrings.scoreSemantics(value, ScoreColors.labelFor(value)),
      child: ExcludeSemantics(
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
                child: _RingContent(score: value, size: size),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RingContent extends StatelessWidget {
  const _RingContent({required this.score, required this.size});

  final int? score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = score;

    final numberStyle = size >= AppDimens.scoreRingLarge
        ? theme.textTheme.displaySmall
        : theme.textTheme.headlineSmall;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value?.toString() ?? AppStrings.emptyValue,
            style: numberStyle?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (value != null) _BandLabel(score: value),
        ],
      ),
    );
  }
}

class _BandLabel extends StatelessWidget {
  const _BandLabel({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.scoreColors.forScore(score);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusDot(color: color),
        const SizedBox(width: AppDimens.xs),
        Flexible(
          child: Text(
            ScoreColors.labelFor(score).toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ),
      ],
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
