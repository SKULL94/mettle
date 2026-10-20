import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/sparkline.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.averageScore,
    required this.trend,
    this.animate = true,
    super.key,
  });

  final int? averageScore;
  final List<int> trend;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Row(
          children: [
            ScoreRing(
              score: averageScore,
              label: AppStrings.avgScore,
              animate: animate,
            ),
            const SizedBox(width: AppDimens.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.trend.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Sparkline(values: trend),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.lg),
        child: Row(
          children: [
            SkeletonBox.circle(),
            SizedBox(width: AppDimens.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox.text(width: 48),
                  SizedBox(height: AppDimens.sm),
                  SkeletonBox(height: AppDimens.sparklineHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
