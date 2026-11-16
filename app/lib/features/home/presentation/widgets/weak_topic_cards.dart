import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/page_frame.dart';
import '../../../interview/domain/entities/interview_topic.dart';
import '../../../interview/presentation/widgets/topic_label.dart';
import '../../../sessions/domain/entities/topic_mastery.dart';

class WeakTopicCards extends StatelessWidget {
  const WeakTopicCards({
    required this.topics,
    required this.onSelected,
    super.key,
  });

  static const _columns = 3;

  final List<TopicMastery> topics;
  final ValueChanged<InterviewTopic> onSelected;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();

    final shown = topics.take(_columns).toList(growable: false);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, mastery) in shown.indexed) ...[
            if (index > 0) const SizedBox(width: AppDimens.paneGap),
            Expanded(
              child: _WeakTopicCard(
                mastery: mastery,
                onPressed: () =>
                    onSelected(InterviewTopic.fromId(mastery.topic)),
              ),
            ),
          ],
          for (var filler = shown.length; filler < _columns; filler++) ...[
            const SizedBox(width: AppDimens.paneGap),
            const Expanded(child: SizedBox.shrink()),
          ],
        ],
      ),
    );
  }
}

class _WeakTopicCard extends StatelessWidget {
  const _WeakTopicCard({required this.mastery, required this.onPressed});

  final TopicMastery mastery;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topic = InterviewTopic.fromId(mastery.topic);
    final colour = context.scoreColors.forScore(mastery.score);

    return WebCard(
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.sm,
                  vertical: AppDimens.xs,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.xs),
                  border: Border.all(color: colour, width: AppDimens.hairline),
                ),
                child: Text(
                  ScoreColors.labelFor(mastery.score).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(color: colour),
                ),
              ),
              const Spacer(),
              Text(
                '${mastery.score}',
                style: AppTheme.code(context).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colour,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            topicLabel(topic),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimens.xs),
          Text(
            topic.covers,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimens.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            child: LinearProgressIndicator(
              value: mastery.score / 100,
              minHeight: 6,
              backgroundColor: theme.colorScheme.outline,
              valueColor: AlwaysStoppedAnimation<Color>(colour),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          OutlinedButton.icon(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppDimens.controlHeight),
            ),
            icon: Icon(
              Icons.my_location_rounded,
              size: AppDimens.iconSm,
              color: colour,
            ),
            label: Text(
              AppStrings.practiceTopic(topicLabel(topic)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
