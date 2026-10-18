import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/turn_score.dart';

class RubricBars extends StatelessWidget {
  const RubricBars({required this.score, super.key});

  final TurnScore score;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RubricRow(label: AppStrings.correctness, value: score.correctness),
        _RubricRow(label: AppStrings.depth, value: score.depth),
        _RubricRow(label: AppStrings.clarity, value: score.clarity),
        _RubricRow(label: AppStrings.structure, value: score.structure),
      ],
    );
  }
}

class _RubricRow extends StatelessWidget {
  const _RubricRow({required this.label, required this.value});

  final String label;
  final int value;

  static const _maxBand = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asPercent = (value / _maxBand * 100).round();
    final colour = context.scoreColors.forScore(asPercent);

    return Semantics(
      label: '$label $value out of $_maxBand',
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.md),
        child: Row(
          children: [
            SizedBox(
              width: 92,
              child: Text(label, style: theme.textTheme.bodySmall),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                child: LinearProgressIndicator(
                  value: value / _maxBand,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.outline,
                  valueColor: AlwaysStoppedAnimation<Color>(colour),
                ),
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '$value',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall?.copyWith(
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
      child: Row(
        children: [
          SizedBox(width: 92, child: SkeletonBox.text(width: 70)),
          Expanded(child: SkeletonBox(height: 6, radius: AppDimens.radiusPill)),
          SizedBox(width: 32),
        ],
      ),
    );
  }
}
