import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/sparkline.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    required this.averageScore,
    required this.trend,
    required this.sessionCount,
    this.animate = true,
    super.key,
  });

  final int? averageScore;
  final List<int> trend;
  final int sessionCount;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final hasTrend = trend.length > 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardLabel(),
            const SizedBox(height: AppDimens.md),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: hasTrend
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Average(
                    score: averageScore,
                    sessionCount: sessionCount,
                    animate: animate,
                  ),
                  if (hasTrend) ...[
                    const VerticalDivider(width: AppDimens.lg),
                    Expanded(child: _Trend(values: trend)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.bar_chart_rounded,
          size: AppDimens.iconSm,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppDimens.sm),
        Text(AppStrings.yourProgress, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _Average extends StatelessWidget {
  const _Average({
    required this.score,
    required this.sessionCount,
    required this.animate,
  });

  final int? score;
  final int sessionCount;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: AppDimens.scoreRingLarge,
      child: Column(
        children: [
          ScoreRing(
            score: score,
            size: AppDimens.scoreRingLarge,
            animate: animate,
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            AppStrings.averageScore,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          if (sessionCount > 0)
            Text(
              AppStrings.sessionCount(sessionCount),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
        ],
      ),
    );
  }
}

class _Trend extends StatelessWidget {
  const _Trend({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latest = values.last;
    final color = context.scoreColors.forScore(latest);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.sessionTrend(values.length),
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: AppDimens.sm),
        Sparkline(values: values, dotColor: color),
        const SizedBox(height: AppDimens.sm),
        Row(
          children: [
            Text(AppStrings.latest, style: theme.textTheme.bodySmall),
            const SizedBox(width: AppDimens.xs),
            Text(
              '$latest',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProgressCardSkeleton extends StatelessWidget {
  const ProgressCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox.text(width: 110),
            SizedBox(height: AppDimens.md),
            Row(
              children: [
                SkeletonBox.circle(size: AppDimens.scoreRingLarge),
                SizedBox(width: AppDimens.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox.text(width: 96),
                      SizedBox(height: AppDimens.sm),
                      SkeletonBox(height: AppDimens.sparklineHeight),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
