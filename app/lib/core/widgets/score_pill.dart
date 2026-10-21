import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../theme/score_colors.dart';
import 'status_dot.dart';

class ScorePill extends StatelessWidget {
  const ScorePill({required this.score, super.key});

  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.scoreColors.forScore(score);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sm,
        vertical: AppDimens.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: AppDimens.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(color: color),
          const SizedBox(width: AppDimens.xs),
          Text(
            '$score',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: AppDimens.xs),
          Text(
            ScoreColors.labelFor(score).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
