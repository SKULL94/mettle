import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/page_frame.dart';
import '../../domain/entities/home_overview.dart';

class CalibrationCard extends StatelessWidget {
  const CalibrationCard({required this.overview, super.key});

  final HomeOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final average = overview.averageScore;
    final latest = overview.lastSession?.overallScore;

    return WebCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeading(
            icon: Icons.equalizer_rounded,
            title: AppStrings.calibration,
            trailing: MetaTag(
              label: AppStrings.sessionCount(overview.sessionCount),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          _Readout(score: average, delta: overview.delta?.points),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  value: '${overview.sessionCount}',
                  label: AppStrings.statSessions,
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: _Stat(
                  value: '${overview.weakTopics.length}',
                  label: AppStrings.statWeakTopics,
                  colour: overview.weakTopics.isEmpty
                      ? null
                      : context.scoreColors.developing,
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: _Stat(
                  value: latest?.toString() ?? AppStrings.emptyValue,
                  label: AppStrings.statLatest,
                  colour: latest == null
                      ? null
                      : context.scoreColors.forScore(latest),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Divider(
            height: AppDimens.hairline,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            overview.sessionCount > 0
                ? AppStrings.averageAcross(overview.sessionCount)
                : AppStrings.averageScore,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({required this.score, required this.delta});

  final int? score;
  final int? delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = score;
    final points = delta;
    final colour = value == null
        ? theme.colorScheme.onSurface
        : context.scoreColors.forScore(value);

    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: AppDimens.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.readiness,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              if (value != null) MetaTag(label: ScoreColors.labelFor(value)),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value?.toString() ?? AppStrings.emptyValue,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 44,
                  height: 1.1,
                  color: colour,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Text(
                AppStrings.outOfHundred,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (points != null) ...[
            const SizedBox(height: AppDimens.xs),
            Row(
              children: [
                Icon(
                  switch (points) {
                    > 0 => Icons.trending_up_rounded,
                    < 0 => Icons.trending_down_rounded,
                    _ => Icons.trending_flat_rounded,
                  },
                  size: AppDimens.iconSm,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimens.xs),
                Expanded(
                  child: Text(
                    AppStrings.deltaSummary(points),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.colour});

  final String value;
  final String label;
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: AppDimens.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.code(context).copyWith(
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: colour ?? theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimens.xs),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
