import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/sparkline.dart';

class TrendCard extends StatelessWidget {
  const TrendCard({required this.trend, super.key});

  final List<int> trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (trend.length < 2) return const SizedBox.shrink();

    final latest = trend.last;
    final first = trend.first;
    final colour = context.scoreColors.forScore(latest);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.sessionTrend(trend.length),
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: AppDimens.md),
            Sparkline(
              values: trend,
              height: AppDimens.chartHeight,
              dotColor: colour,
            ),
            const SizedBox(height: AppDimens.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.trendOldest(first),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                Text(AppStrings.latest, style: theme.textTheme.bodySmall),
                const SizedBox(width: AppDimens.xs),
                Text(
                  '$latest',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colour,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
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

class TrendCardSkeleton extends StatelessWidget {
  const TrendCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox.text(width: 120),
            SizedBox(height: AppDimens.md),
            SkeletonBox(height: AppDimens.chartHeight),
          ],
        ),
      ),
    );
  }
}
