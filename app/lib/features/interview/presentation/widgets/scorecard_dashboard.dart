import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/page_frame.dart';
import '../../domain/entities/scorecard.dart';
import 'overall_score_card.dart';
import 'question_audit.dart';
import 'rubric_bars.dart';
import 'topic_label.dart';

class ScorecardDashboard extends StatelessWidget {
  const ScorecardDashboard({
    required this.scorecard,
    required this.onPractice,
    super.key,
  });

  final Scorecard scorecard;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topic = topicLabel(scorecard.topic);

    return PageFrame(
      children: [
        PageHeader(
          eyebrow:
              '${AppStrings.scorecardEyebrow}${AppStrings.metaSeparator}'
              '$topic${AppStrings.metaSeparator}'
              '${AppStrings.questionCount(scorecard.questionCount)}',
          title: AppStrings.scorecard,
          subtitle: AppStrings.scorecardSubtitle,
          actions: [
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppDimens.controlHeight),
              ),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: AppDimens.iconMd,
              ),
              label: const Text(AppStrings.backToDashboard),
            ),
            FilledButton.icon(
              onPressed: onPractice,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppDimens.controlHeight),
              ),
              icon: const Icon(Icons.replay_rounded, size: AppDimens.iconMd),
              label: Text(AppStrings.practiceTopic(topic)),
            ),
          ],
        ),
        PaneRow(
          panes: [
            (
              flex: 4,
              child: OverallScoreCard(
                overall: scorecard.overall,
                dimensions: scorecard.dimensions,
              ),
            ),
            (
              flex: 8,
              child: WebCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CardHeading(
                      icon: Icons.rule_rounded,
                      title: AppStrings.rubricDimensions,
                    ),
                    const SizedBox(height: AppDimens.lg),
                    RubricBars(
                      score: scorecard.dimensions,
                      showDescriptions: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.xl),
        if (scorecard.followUpCount > 0) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.subdirectory_arrow_right_rounded,
                size: AppDimens.iconSm,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: Text(
                  AppStrings.followUpSummary(scorecard.followUpCount),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
        ],
        QuestionAudit(turns: scorecard.turns),
      ],
    );
  }
}
