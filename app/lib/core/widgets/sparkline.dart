import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({
    required this.values,
    this.height = AppDimens.sparklineHeight,
    this.semanticLabel,
    super.key,
  });

  final List<int> values;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return SizedBox(height: height);

    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: semanticLabel ?? _describeTrend(),
      child: SizedBox(
        height: height,
        child: CustomPaint(
          painter: _SparklinePainter(
            values: values,
            line: scheme.primary,
            dot: scheme.primary,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  String _describeTrend() {
    final delta = values.last - values.first;
    final direction = switch (delta) {
      > 0 => 'up $delta points',
      < 0 => 'down ${delta.abs()} points',
      _ => 'unchanged',
    };
    return 'Score trend across ${values.length} sessions, $direction, '
        'currently ${values.last}';
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.values,
    required this.line,
    required this.dot,
  });

  final List<int> values;
  final Color line;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 2.0;
    const dotRadius = 2.5;

    const inset = dotRadius + strokeWidth / 2;
    final usableWidth = size.width - inset * 2;
    final usableHeight = size.height - inset * 2;
    if (usableWidth <= 0 || usableHeight <= 0) return;

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final span = maxValue - minValue;

    Offset pointAt(int index) {
      final x = inset + usableWidth * (index / (values.length - 1));

      final normalised = span == 0 ? 0.5 : (values[index] - minValue) / span;
      final y = inset + usableHeight * (1 - normalised);
      return Offset(x, y);
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      final p = pointAt(i);
      path.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(
      pointAt(values.length - 1),
      dotRadius,
      Paint()..color = dot,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.line != line || old.dot != dot || !listEquals(old.values, values);
}
