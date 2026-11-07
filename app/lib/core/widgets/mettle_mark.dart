import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

class MettleMark extends StatelessWidget {
  const MettleMark({this.size = 96.0, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Semantics(
      label: AppStrings.appName,
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(size * 0.27),
          border: isLight
              ? Border.all(color: scheme.outlineVariant, width: 1)
              : null,
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: const [0.0, 0.45, 1.0],
            colors: [
              scheme.primary.withValues(alpha: 0.18),
              scheme.surfaceContainer,
              scheme.surfaceContainerHigh,
            ],
          ),
        ),
        child: Center(
          child: CustomPaint(
            size: Size.square(size * 0.5),
            painter: _ChevronPainter(
              upper: scheme.primary,
              lower: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.upper, required this.lower});

  final Color upper;
  final Color lower;

  static const _reference = 48.0;
  static const _strokeWidth = 4.5;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _reference;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void chevron(double left, double bottom, double apexX, double apexY) {
      canvas.drawPath(
        Path()
          ..moveTo(left * scale, bottom * scale)
          ..lineTo(apexX * scale, apexY * scale)
          ..lineTo((2 * apexX - left) * scale, bottom * scale),
        paint,
      );
    }

    paint.color = upper;
    chevron(12, 33, 24, 19);

    paint.color = lower;
    chevron(18, 37, 24, 30);
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) =>
      oldDelegate.upper != upper || oldDelegate.lower != lower;
}

class MettleWordmark extends StatelessWidget {
  const MettleWordmark({this.style, super.key});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = style ?? theme.textTheme.displaySmall;
    final dotSize = (resolved?.fontSize ?? 32) * 0.25;

    return Semantics(
      label: AppStrings.appName,
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            text: AppStrings.appName,
            style: resolved,
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Padding(
                  padding: EdgeInsets.only(left: dotSize * 0.45),
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
