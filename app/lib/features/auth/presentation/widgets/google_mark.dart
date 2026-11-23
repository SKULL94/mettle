import 'dart:math' as math;

import 'package:flutter/material.dart';

class GoogleMark extends StatelessWidget {
  const GoogleMark({this.size = 20.0, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: Size.square(size), painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * 0.26;
    final ring = rect.deflate(stroke / 2);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    void sweep(Color color, double startDeg, double sweepDeg) {
      canvas.drawArc(
        ring,
        startDeg * math.pi / 180,
        sweepDeg * math.pi / 180,
        false,
        arc..color = color,
      );
    }

    sweep(_red, 200, 110);
    sweep(_blue, 310, 75);
    sweep(_green, 25, 85);
    sweep(_yellow, 110, 90);

    canvas.drawRect(
      Rect.fromLTRB(
        size.width * 0.52,
        size.height * 0.5 - stroke / 2,
        size.width - stroke * 0.15,
        size.height * 0.5 + stroke / 2,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(_GooglePainter oldDelegate) => false;
}
