import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/score_delta.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    required this.averageScore,
    required this.delta,
    required this.sessionCount,
    this.onTap,
    this.animate = true,
    super.key,
  });

  final int? averageScore;
  final ScoreDelta? delta;
  final int sessionCount;
  final VoidCallback? onTap;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final measure = delta;

    final content = Padding(
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _CardLabel(),
              const Spacer(),
              if (measure != null) ...[
                const SizedBox(width: AppDimens.sm),
                Flexible(child: _Delta(delta: measure)),
              ],
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          const Divider(height: AppDimens.hairline),
          const SizedBox(height: AppDimens.md),
          _Average(
            score: averageScore,
            sessionCount: sessionCount,
            animate: animate,
          ),
        ],
      ),
    );

    if (onTap == null) return Card(child: content);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          button: true,
          label: AppStrings.viewProgress,
          child: content,
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
          Icons.analytics_rounded,
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

    return Column(
      children: [
        ScoreRing(
          score: score,
          size: AppDimens.scoreRingLarge,
          animate: animate,
        ),
        const SizedBox(height: AppDimens.md),
        Text(
          sessionCount > 0
              ? AppStrings.averageAcross(sessionCount)
              : AppStrings.averageScore,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Delta extends StatelessWidget {
  const _Delta({required this.delta});

  final ScoreDelta delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scores = context.scoreColors;

    final color = switch (delta) {
      ScoreDelta(isUp: true) => scores.strong,
      ScoreDelta(isFlat: true) => theme.colorScheme.onSurfaceVariant,
      _ => scores.developing,
    };

    final icon = switch (delta) {
      ScoreDelta(isUp: true) => Icons.trending_up_rounded,
      ScoreDelta(isFlat: true) => Icons.trending_flat_rounded,
      _ => Icons.trending_down_rounded,
    };

    return Semantics(
      label: AppStrings.deltaSemantics(delta.points),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppDimens.iconSm, color: color),
            const SizedBox(width: AppDimens.xs),
            Flexible(
              child: Text(
                AppStrings.deltaSummary(delta.points),
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SkeletonBox.text(width: 110),
                Spacer(),
                SkeletonBox.text(width: 120),
              ],
            ),
            SizedBox(height: AppDimens.sm),
            Divider(height: AppDimens.hairline),
            SizedBox(height: AppDimens.md),
            Center(
              child: SkeletonBox.circle(size: AppDimens.scoreRingLarge),
            ),
            SizedBox(height: AppDimens.md),
            Center(child: SkeletonBox.text(width: 180)),
          ],
        ),
      ),
    );
  }
}
