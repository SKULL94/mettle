import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../domain/entities/turn_score.dart';
import 'rubric_bars.dart';

class OverallScoreCard extends StatelessWidget {
  const OverallScoreCard({
    required this.overall,
    required this.dimensions,
    super.key,
  });

  final int overall;
  final TurnScore dimensions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          children: [
            ScoreRing(score: overall, size: AppDimens.scoreRingHero),
            const SizedBox(height: AppDimens.lg),
            Text(
              _note(dimensions),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  static String _note(TurnScore dimensions) {
    final ranked = rubricDimensions(dimensions).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final strongest = ranked.first;
    final weakest = ranked.last;
    if (strongest.value == weakest.value) {
      return AppStrings.evaluatorNoteBalanced;
    }

    return AppStrings.evaluatorNote(
      strongest.label.toLowerCase(),
      weakest.label.toLowerCase(),
    );
  }
}
