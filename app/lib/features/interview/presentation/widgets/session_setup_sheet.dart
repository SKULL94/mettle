import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/result/result.dart';
import '../../../../core/widgets/demo_mode_chip.dart';
import '../../domain/entities/difficulty.dart';
import '../../domain/entities/interview_topic.dart';
import '../../domain/entities/session_config.dart';
import '../../domain/usecases/start_session.dart';
import 'selectable_tile.dart';
import 'topic_label.dart';

Future<String?> launchSession(
  BuildContext context, {
  InterviewTopic? topic,
  Set<InterviewTopic> weakTopics = const {},
}) async {
  final messenger = ScaffoldMessenger.of(context);

  final config = await showSessionSetupSheet(
    context,
    topic: topic,
    weakTopics: weakTopics,
  );
  if (config == null) return null;

  final result = await sl<StartSession>()(config);

  switch (result) {
    case Success(:final data):
      return data;
    case Failed(:final failure):
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
      return null;
  }
}

Future<SessionConfig?> showSessionSetupSheet(
  BuildContext context, {
  InterviewTopic? topic,
  Set<InterviewTopic> weakTopics = const {},
}) {
  return showModalBottomSheet<SessionConfig>(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight:
          MediaQuery.sizeOf(context).height * AppDimens.sheetMaxHeightFactor,
    ),
    builder: (_) =>
        SessionSetupSheet(initialTopic: topic, weakTopics: weakTopics),
  );
}

class SessionSetupSheet extends StatefulWidget {
  const SessionSetupSheet({
    this.initialTopic,
    this.weakTopics = const {},
    super.key,
  });

  final InterviewTopic? initialTopic;
  final Set<InterviewTopic> weakTopics;

  @override
  State<SessionSetupSheet> createState() => _SessionSetupSheetState();
}

class _SessionSetupSheetState extends State<SessionSetupSheet> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topic = _topic;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.lg,
          0,
          AppDimens.lg,
          AppDimens.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHeader(),
            const SizedBox(height: AppDimens.lg),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DifficultyPicker(
                      selected: _difficulty,
                      onSelected: _selectDifficulty,
                    ),
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
                      onSelected: (value) =>
                          setState(() => _questionCount = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            FilledButton(
              onPressed: topic == null
                  ? null
                  : () => Navigator.of(context).pop(
                      SessionConfig(
                        topic: topic,
                        questionCount: _questionCount,
                      ),
                    ),
              child: const Text(AppStrings.setupStart),
            ),
            if (topic != null) ...[
              const SizedBox(height: AppDimens.sm),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppStrings.setupSummary(topicLabel(topic), _questionCount),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            AppStrings.setupTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        if (!ApiConstants.isBackendConfigured) ...[
          const SizedBox(width: AppDimens.sm),
          const DemoModeChip(),
        ],
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: AppStrings.close,
          icon: const Icon(Icons.close_rounded, size: AppDimens.iconMd),
        ),
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
        _PickerLabel(
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
        const _PickerLabel(label: AppStrings.setupDifficulty),
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
        const _PickerLabel(label: AppStrings.setupLength),
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

class _PickerLabel extends StatelessWidget {
  const _PickerLabel({required this.label, this.trailing});

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
