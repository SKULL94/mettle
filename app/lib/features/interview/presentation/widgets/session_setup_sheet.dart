import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/interview_topic.dart';
import '../../domain/entities/session_config.dart';
import 'topic_label.dart';

Future<SessionConfig?> showSessionSetupSheet(
  BuildContext context, {
  InterviewTopic? topic,
}) {
  return showModalBottomSheet<SessionConfig>(
    context: context,
    isScrollControlled: true,
    builder: (_) => SessionSetupSheet(initialTopic: topic),
  );
}

class SessionSetupSheet extends StatefulWidget {
  const SessionSetupSheet({this.initialTopic, super.key});

  final InterviewTopic? initialTopic;

  @override
  State<SessionSetupSheet> createState() => _SessionSetupSheetState();
}

class _SessionSetupSheetState extends State<SessionSetupSheet> {
  late InterviewTopic _topic =
      widget.initialTopic ?? InterviewTopic.stateManagement;
  int _questionCount = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Text(AppStrings.setupTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppDimens.lg),

            Text(AppStrings.setupTopic, style: theme.textTheme.labelSmall),
            const SizedBox(height: AppDimens.sm),
            Wrap(
              spacing: AppDimens.sm,
              runSpacing: AppDimens.sm,
              children: [
                for (final topic in InterviewTopic.values)
                  ChoiceChip(
                    label: Text(topicLabel(topic)),
                    selected: topic == _topic,
                    onSelected: (_) => setState(() => _topic = topic),
                  ),
              ],
            ),

            const SizedBox(height: AppDimens.lg),
            Text(AppStrings.setupLength, style: theme.textTheme.labelSmall),
            const SizedBox(height: AppDimens.sm),
            Wrap(
              spacing: AppDimens.sm,
              children: [
                for (final count in SessionConfig.allowedQuestionCounts)
                  ChoiceChip(
                    label: Text('$count'),
                    selected: count == _questionCount,
                    onSelected: (_) => setState(() => _questionCount = count),
                  ),
              ],
            ),

            const SizedBox(height: AppDimens.xl),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                SessionConfig(topic: _topic, questionCount: _questionCount),
              ),
              child: const Text(AppStrings.setupStart),
            ),
          ],
        ),
      ),
    );
  }
}
