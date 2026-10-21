import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/status_dot.dart';
import '../../../interview/domain/entities/interview_topic.dart';
import '../../../interview/presentation/widgets/topic_label.dart';
import '../../../sessions/domain/entities/topic_mastery.dart';
import '../../../../core/widgets/section_header.dart';

class WeakTopicChips extends StatelessWidget {
  const WeakTopicChips({
    required this.topics,
    required this.onSelected,
    super.key,
  });

  final List<TopicMastery> topics;
  final ValueChanged<InterviewTopic> onSelected;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();

    final weak = topics
        .map((m) => (topic: InterviewTopic.fromId(m.topic), score: m.score))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.weakTopics,
          trailing: _NeedsAttentionPill(count: weak.length),
        ),
        const SizedBox(height: AppDimens.md),
        Wrap(
          spacing: AppDimens.sm,
          runSpacing: AppDimens.sm,
          children: [
            for (final entry in weak)
              _WeakTopicChip(
                topic: entry.topic,
                score: entry.score,
                onTap: () => {},
              ),
          ],
        ),
      ],
    );
  }
}

class _WeakTopicChip extends StatelessWidget {
  const _WeakTopicChip({
    required this.topic,
    required this.score,
    required this.onTap,
  });

  final InterviewTopic topic;
  final int score;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.scoreColors.forScore(score);

    return Material(
      color: theme.colorScheme.surfaceContainer,
      shape: StadiumBorder(
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: AppDimens.hairline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimens.minTouchTarget,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusDot(color: color),
              const SizedBox(width: AppDimens.sm),
              Flexible(
                child: Text(
                  topicLabel(topic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Text(
                '$score',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeedsAttentionPill extends StatelessWidget {
  const _NeedsAttentionPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.scoreColors.developing;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sm,
        vertical: AppDimens.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: color, width: AppDimens.hairline),
      ),
      child: Text(
        AppStrings.needsAttention(count),
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
