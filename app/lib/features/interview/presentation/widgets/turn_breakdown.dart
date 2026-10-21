import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/score_pill.dart';
import '../../domain/entities/interview_turn.dart';
import 'rubric_bars.dart';
import 'topic_label.dart';

class TurnBreakdown extends StatelessWidget {
  const TurnBreakdown({
    required this.turn,
    required this.position,
    required this.expanded,
    required this.onToggle,
    super.key,
  });

  final InterviewTurn turn;
  final int? position;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.sm),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.md),
              child: _Header(
                turn: turn,
                position: position,
                expanded: expanded,
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.md,
                0,
                AppDimens.md,
                AppDimens.md,
              ),
              child: _Details(turn: turn),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.turn,
    required this.position,
    required this.expanded,
  });

  final InterviewTurn turn;
  final int? position;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = turn.score;
    final index = position;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                index == null
                    ? AppStrings.followUp
                    : AppStrings.questionNumber(index),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: index == null ? theme.colorScheme.primary : null,
                ),
              ),
            ),
            if (score != null) ScorePill(score: score.overall),
            const SizedBox(width: AppDimens.xs),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                Icons.expand_more_rounded,
                size: AppDimens.iconMd,
                color: theme.textTheme.labelSmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.xs),
        Text(
          turn.question.text,
          maxLines: expanded ? null : 2,
          overflow: expanded ? null : TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.turn});

  final InterviewTurn turn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = turn.score;
    final answer = turn.answer ?? '';
    final reason = turn.question.reason;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (turn.question.isFollowUp && reason != null) ...[
          Text(
            followUpReasonLabel(reason).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppDimens.md),
        ],
        Text(AppStrings.yourAnswer, style: theme.textTheme.labelSmall),
        const SizedBox(height: AppDimens.sm),
        Text(
          answer.isEmpty ? AppStrings.skipped : answer,
          style: theme.textTheme.bodyMedium,
        ),
        if (score != null) ...[
          const SizedBox(height: AppDimens.lg),
          RubricBars(score: score),
        ],
        if (score != null && score.missing.isNotEmpty) ...[
          Text(AppStrings.whatWasMissing, style: theme.textTheme.labelSmall),
          const SizedBox(height: AppDimens.sm),
          Wrap(
            spacing: AppDimens.sm,
            runSpacing: AppDimens.sm,
            children: [
              for (final item in score.missing) Chip(label: Text(item)),
            ],
          ),
        ],
      ],
    );
  }
}
