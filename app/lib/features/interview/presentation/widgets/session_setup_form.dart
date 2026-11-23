import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/difficulty.dart';
import '../../domain/entities/interview_topic.dart';
import '../../domain/entities/session_config.dart';
import 'selectable_tile.dart';
import 'topic_label.dart';

class SessionSetupForm extends StatefulWidget {
  const SessionSetupForm({
    required this.onSubmit,
    this.initialTopic,
    this.weakTopics = const {},
    this.submitLabel = AppStrings.setupStart,
    this.submitIcon,
    super.key,
  });

  final ValueChanged<SessionConfig> onSubmit;
  final InterviewTopic? initialTopic;
  final Set<InterviewTopic> weakTopics;
  final String submitLabel;
  final IconData? submitIcon;

  @override
  State<SessionSetupForm> createState() => _SessionSetupFormState();
}

class _SessionSetupFormState extends State<SessionSetupForm> {
  late Difficulty _difficulty =
      widget.initialTopic?.difficulty ?? Difficulty.defaultLevel;
  late InterviewTopic? _topic = widget.initialTopic;
  int _questionCount = SessionConfig.defaultQuestionCount;

  void _selectDifficulty(Difficulty value) {
    if (value == _difficulty) return;
    setState(() {
      _difficulty = value;
      _topic = null;
    });
  }

  void _submit() {
    final topic = _topic;
    if (topic == null) return;
    widget.onSubmit(SessionConfig(topic: topic, questionCount: _questionCount));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topic = _topic;
    final icon = widget.submitIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _DifficultyPicker(selected: _difficulty, onSelected: _selectDifficulty),
        const SizedBox(height: AppDimens.lg),
        _TopicPicker(
          difficulty: _difficulty,
          selected: topic,
          weakTopics: widget.weakTopics,
          onSelected: (value) => setState(() => _topic = value),
        ),
        const SizedBox(height: AppDimens.lg),
        _QuestionCountPicker(
          selected: _questionCount,
          onSelected: (value) => setState(() => _questionCount = value),
        ),
        const SizedBox(height: AppDimens.lg),
        FilledButton(
          onPressed: topic == null ? null : _submit,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(AppDimens.ctaHeight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.submitLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppDimens.sm),
                Icon(icon, size: AppDimens.iconMd),
              ],
            ],
          ),
        ),
        if (topic != null) ...[
          const SizedBox(height: AppDimens.sm),
          Text(
            AppStrings.setupSummary(topicLabel(topic), _questionCount),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ],
    );
  }
}

class _TopicPicker extends StatelessWidget {
  const _TopicPicker({
    required this.difficulty,
    required this.selected,
    required this.weakTopics,
    required this.onSelected,
  });

  final Difficulty difficulty;
  final InterviewTopic? selected;
  final Set<InterviewTopic> weakTopics;
  final ValueChanged<InterviewTopic> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PickerLabel(
          label: AppStrings.setupTopic,
          trailing: weakTopics.isEmpty ? null : const WeakLegend(),
        ),
        const SizedBox(height: AppDimens.sm),
        Wrap(
          spacing: AppDimens.sm,
          runSpacing: AppDimens.sm,
          children: [
            for (final topic in InterviewTopic.forDifficulty(difficulty))
              TopicTile(
                topic: topic,
                selected: topic == selected,
                isWeak: weakTopics.contains(topic),
                onTap: () => onSelected(topic),
              ),
          ],
        ),
      ],
    );
  }
}

class _DifficultyPicker extends StatelessWidget {
  const _DifficultyPicker({required this.selected, required this.onSelected});

  final Difficulty selected;
  final ValueChanged<Difficulty> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PickerLabel(label: AppStrings.setupDifficulty),
        const SizedBox(height: AppDimens.sm),
        Row(
          children: [
            for (final level in Difficulty.values) ...[
              if (level != Difficulty.values.first)
                const SizedBox(width: AppDimens.sm),
              Expanded(
                child: DifficultyTile(
                  level: level,
                  selected: level == selected,
                  onTap: () => onSelected(level),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _QuestionCountPicker extends StatelessWidget {
  const _QuestionCountPicker({
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PickerLabel(label: AppStrings.setupLength),
        const SizedBox(height: AppDimens.sm),
        Row(
          children: [
            for (final count in SessionConfig.allowedQuestionCounts) ...[
              if (count != SessionConfig.allowedQuestionCounts.first)
                const SizedBox(width: AppDimens.sm),
              Expanded(
                child: QuestionCountTile(
                  count: count,
                  minutes: SessionConfig.estimatedMinutes[count],
                  selected: count == selected,
                  onTap: () => onSelected(count),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class PickerLabel extends StatelessWidget {
  const PickerLabel({required this.label, this.trailing, super.key});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppDimens.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        ?trailing,
      ],
    );
  }
}
