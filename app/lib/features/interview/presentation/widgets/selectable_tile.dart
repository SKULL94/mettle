import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/status_dot.dart';
import '../../domain/entities/interview_topic.dart';
import 'topic_label.dart';

class SelectableTile extends StatelessWidget {
  const SelectableTile({
    required this.selected,
    required this.onTap,
    required this.child,
    this.semanticLabel,
    super.key,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      selected: selected,
      label: semanticLabel,
      button: true,
      child: Material(
        color: selected ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outline,
            width: AppDimens.hairline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDimens.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.md,
                vertical: AppDimens.sm,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class TopicTile extends StatelessWidget {
  const TopicTile({
    required this.topic,
    required this.selected,
    required this.isWeak,
    required this.onTap,
    super.key,
  });

  final InterviewTopic topic;
  final bool selected;
  final bool isWeak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = topicLabel(topic);

    return SelectableTile(
      selected: selected,
      onTap: onTap,
      semanticLabel: isWeak ? '$label, ${AppStrings.setupWeakLegend}' : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected) ...[
            Icon(
              Icons.check_circle_rounded,
              size: AppDimens.iconSm,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppDimens.sm),
          ] else if (isWeak) ...[
            StatusDot(color: context.scoreColors.developing),
            const SizedBox(width: AppDimens.sm),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionCountTile extends StatelessWidget {
  const QuestionCountTile({
    required this.count,
    required this.selected,
    required this.onTap,
    this.minutes,
    super.key,
  });

  final int count;
  final bool selected;
  final VoidCallback onTap;
  final int? minutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estimate = minutes;

    return SelectableTile(
      selected: selected,
      onTap: onTap,
      semanticLabel: AppStrings.questionCount(count),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (estimate != null)
            Text(
              AppStrings.minutesEstimate(estimate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
        ],
      ),
    );
  }
}

class WeakLegend extends StatelessWidget {
  const WeakLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusDot(color: context.scoreColors.developing),
        const SizedBox(width: AppDimens.xs),
        Text(AppStrings.setupWeakLegend, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
