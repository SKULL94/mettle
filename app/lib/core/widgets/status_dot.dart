import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';

class StatusDot extends StatelessWidget {
  const StatusDot({required this.color, this.size = AppDimens.dot, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
