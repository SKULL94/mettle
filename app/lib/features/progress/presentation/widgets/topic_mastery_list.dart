import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/status_dot.dart';
import '../../../interview/domain/entities/interview_topic.dart';
import '../../../interview/presentation/widgets/topic_label.dart';
import '../../../sessions/domain/entities/topic_mastery.dart';

class TopicMasteryList extends StatelessWidget {
  const TopicMasteryList({required this.mastery, super.key});

  final List<TopicMastery> mastery;

  @override
  Widget build(BuildContext context) {
    if (mastery.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          children: [
            for (final (index, topic) in mastery.indexed) ...[
              if (index > 0) const SizedBox(height: AppDimens.md),
              _MasteryRow(mastery: topic),
            ],
          ],
        ),
      ),
    );
  }
}

class _MasteryRow extends StatelessWidget {
  const _MasteryRow({required this.mastery});

  final TopicMastery mastery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour = context.scoreColors.forScore(mastery.score);
    final band = ScoreColors.labelFor(mastery.score);

    return Semantics(
      label: AppStrings.masterySemantics(
        topicLabel(InterviewTopic.fromId(mastery.topic)),
        mastery.score,
        band,
      ),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    topicLabel(InterviewTopic.fromId(mastery.topic)),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                StatusDot(color: colour),
                const SizedBox(width: AppDimens.xs),
                Text(
                  '${mastery.score}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colour,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: AppDimens.xs),
                Text(band.toUpperCase(), style: theme.textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: AppDimens.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              child: LinearProgressIndicator(
                value: mastery.score / 100,
                minHeight: 6,
                backgroundColor: theme.colorScheme.outline,
                valueColor: AlwaysStoppedAnimation<Color>(colour),
              ),
            ),
            const SizedBox(height: AppDimens.xs),
            Text(
              AppStrings.sessionCount(mastery.sessionCount),
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class TopicMasteryListSkeleton extends StatelessWidget {
  const TopicMasteryListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox.text(width: 120),
            SizedBox(height: AppDimens.sm),
            SkeletonBox(height: 6, radius: AppDimens.radiusPill),
            SizedBox(height: AppDimens.md),
            SkeletonBox.text(width: 90),
            SizedBox(height: AppDimens.sm),
            SkeletonBox(height: 6, radius: AppDimens.radiusPill),
          ],
        ),
      ),
    );
  }
}
