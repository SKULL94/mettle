import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/status_dot.dart';
import '../../domain/entities/turn_score.dart';

typedef RubricDimension = ({String label, String description, int value});

const maxBand = 5;

List<RubricDimension> rubricDimensions(TurnScore score) => [
  (
    label: AppStrings.correctness,
    description: AppStrings.correctnessRubric,
    value: score.correctness,
  ),
  (
    label: AppStrings.depth,
    description: AppStrings.depthRubric,
    value: score.depth,
  ),
  (
    label: AppStrings.clarity,
    description: AppStrings.clarityRubric,
    value: score.clarity,
  ),
  (
    label: AppStrings.structure,
    description: AppStrings.structureRubric,
    value: score.structure,
  ),
];

int bandPercent(int value) => (value / maxBand * 100).round();

class RubricBars extends StatelessWidget {
  const RubricBars({
    required this.score,
    this.showDescriptions = false,
    super.key,
  });

  final TurnScore score;
  final bool showDescriptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final dimension in rubricDimensions(score))
          _RubricRow(dimension: dimension, showDescription: showDescriptions),
      ],
    );
  }
}

class _RubricRow extends StatelessWidget {
  const _RubricRow({required this.dimension, required this.showDescription});

  final RubricDimension dimension;
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = bandPercent(dimension.value);
    final colour = context.scoreColors.forScore(percent);

    return Semantics(
      label: AppStrings.scoreSemantics(percent, ScoreColors.labelFor(percent)),
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dimension.label,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  StatusDot(color: colour),
                  const SizedBox(width: AppDimens.xs),
                  Text(
                    AppStrings.scoreOutOf(dimension.value, maxBand),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colour,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: AppDimens.xs),
                  Text(
                    ScoreColors.labelFor(percent).toUpperCase(),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                child: LinearProgressIndicator(
                  value: dimension.value / maxBand,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.outline,
                  valueColor: AlwaysStoppedAnimation<Color>(colour),
                ),
              ),
              if (showDescription) ...[
                const SizedBox(height: AppDimens.sm),
                Text(dimension.description, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class RubricBarsSkeleton extends StatelessWidget {
  const RubricBarsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _RubricRowSkeleton(),
        _RubricRowSkeleton(),
        _RubricRowSkeleton(),
        _RubricRowSkeleton(),
      ],
    );
  }
}

class _RubricRowSkeleton extends StatelessWidget {
  const _RubricRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox.text(width: 110),
          SizedBox(height: AppDimens.sm),
          SkeletonBox(height: 6, radius: AppDimens.radiusPill),
        ],
      ),
    );
  }
}
