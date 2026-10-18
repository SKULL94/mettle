import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/score_colors.dart';
import '../../domain/entities/topic_mastery.dart';

class WeakTopicChips extends StatelessWidget {
  const WeakTopicChips({
    required this.topics,
    required this.onSelected,
    super.key,
  });

  final List<TopicMastery> topics;
  final ValueChanged<TopicMastery> onSelected;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.weakTopics,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: AppDimens.sm),
        Wrap(
          spacing: AppDimens.sm,
          runSpacing: AppDimens.sm,
          children: [
            for (final topic in topics)
              ActionChip(
                avatar: Icon(
                  Icons.circle,
                  size: AppDimens.sm,
                  color: context.scoreColors.forScore(topic.score),
                ),
                label: Text('${topic.topic} · ${topic.score}'),
                onPressed: () => onSelected(topic),
              ),
          ],
        ),
      ],
    );
  }
}
