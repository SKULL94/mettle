import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/score_colors.dart';
import '../../domain/entities/interview_turn.dart';
import 'rubric_bars.dart';

class TurnBreakdown extends StatelessWidget {
  const TurnBreakdown({required this.turn, required this.position, super.key});

  final InterviewTurn turn;
  final int position;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = turn.score;
    final answer = turn.answer ?? '';
    final overall = score?.overall;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.sm),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppDimens.md,
          0,
          AppDimens.md,
          AppDimens.md,
        ),
        title: Row(
          children: [
            if (turn.question.isFollowUp)
              Padding(
                padding: const EdgeInsets.only(right: AppDimens.xs),
                child: Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  size: AppDimens.md,
                  color: theme.colorScheme.primary,
                ),
              ),
            Expanded(
              child: Text(
                '$position. ${turn.question.text}',
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (overall != null)
              Padding(
                padding: const EdgeInsets.only(left: AppDimens.sm),
                child: Text(
                  '$overall',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.scoreColors.forScore(overall),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
          ],
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer.isEmpty ? AppStrings.skipped : AppStrings.yourAnswer,
              style: theme.textTheme.labelSmall,
            ),
          ),
          if (answer.isNotEmpty) ...[
            const SizedBox(height: AppDimens.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(answer, style: theme.textTheme.bodyMedium),
            ),
          ],
          if (score != null) ...[
            const SizedBox(height: AppDimens.lg),
            RubricBars(score: score),
          ],
          if (score != null && score.missing.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.whatWasMissing.toUpperCase(),
                style: theme.textTheme.labelSmall,
              ),
            ),
            const SizedBox(height: AppDimens.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: AppDimens.sm,
                runSpacing: AppDimens.sm,
                children: [
                  for (final item in score.missing) Chip(label: Text(item)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
