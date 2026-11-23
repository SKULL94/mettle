import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';

class CreditMeter extends StatelessWidget {
  const CreditMeter({
    required this.remaining,
    required this.total,
    this.mini = false,
    super.key,
  });

  final int remaining;
  final int total;
  final bool mini;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final used = (total - remaining).clamp(0, total);

    final segments = <Widget>[
      for (var index = 0; index < total; index++) ...[
        if (index > 0)
          SizedBox(width: mini ? MettleSpace.rPip : MettleSpace.pip),
        _Segment(
          filled: index >= used,
          color: index >= used ? colors.accent : colors.borderStrong,
          mini: mini,
        ),
      ],
    ];

    return Semantics(
      label: AppStrings.planCreditsSemantics(remaining, total),
      child: ExcludeSemantics(
        child: mini
            ? Row(mainAxisSize: MainAxisSize.min, children: segments)
            : Row(children: segments),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.filled,
    required this.color,
    required this.mini,
  });

  final bool filled;
  final Color color;
  final bool mini;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: mini ? 10 : null,
      height: mini ? 4 : MettleSpace.pip,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(mini ? 2 : MettleSpace.rPip),
      ),
    );

    return mini ? bar : Expanded(child: bar);
  }
}
