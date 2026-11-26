import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/result/result.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/mettle_snack_bar.dart';
import '../../../../core/widgets/window_size.dart';
import '../../domain/entities/interview_topic.dart';
import '../../domain/entities/session_config.dart';
import '../../domain/usecases/start_session.dart';
import 'session_setup_form.dart';

Future<void> startSessionFlow(
  BuildContext context, {
  InterviewTopic? topic,
  Set<InterviewTopic> weakTopics = const {},
}) async {
  final router = GoRouter.of(context);

  final sessionId = await launchSession(
    context,
    topic: topic,
    weakTopics: weakTopics,
  );
  if (sessionId == null) return;

  await router.pushNamed(
    AppRoutes.sessionName,
    pathParameters: {AppRoutes.idParam: sessionId},
  );
}

Future<String?> launchSession(
  BuildContext context, {
  InterviewTopic? topic,
  Set<InterviewTopic> weakTopics = const {},
}) async {
  final config = await showSessionSetup(
    context,
    topic: topic,
    weakTopics: weakTopics,
  );
  if (config == null || !context.mounted) return null;

  return startConfiguredSession(context, config);
}

Future<String?> startConfiguredSession(
  BuildContext context,
  SessionConfig config,
) async {
  final result = await sl<StartSession>()(config);

  switch (result) {
    case Success(:final data):
      return data;
    case Failed(:final failure):
      if (context.mounted) showMettleSnackBar(context, failure.message);
      return null;
  }
}

Future<SessionConfig?> showSessionSetup(
  BuildContext context, {
  InterviewTopic? topic,
  Set<InterviewTopic> weakTopics = const {},
}) {
  if (context.isWideWindow) {
    return showDialog<SessionConfig>(
      context: context,
      builder: (dialogContext) =>
          _SessionSetupDialog(initialTopic: topic, weakTopics: weakTopics),
    );
  }

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

class _SessionSetupDialog extends StatelessWidget {
  const _SessionSetupDialog({this.initialTopic, this.weakTopics = const {}});

  final InterviewTopic? initialTopic;
  final Set<InterviewTopic> weakTopics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: AppDimens.hairline,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimens.dialogMaxWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SetupHeader(),
              const SizedBox(height: AppDimens.lg),
              Flexible(
                child: SingleChildScrollView(
                  child: SessionSetupForm(
                    initialTopic: initialTopic,
                    weakTopics: weakTopics,
                    submitIcon: Icons.rocket_launch_rounded,
                    onSubmit: (config) => Navigator.of(context).pop(config),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SessionSetupSheet extends StatelessWidget {
  const SessionSetupSheet({
    this.initialTopic,
    this.weakTopics = const {},
    super.key,
  });

  final InterviewTopic? initialTopic;
  final Set<InterviewTopic> weakTopics;

  @override
  Widget build(BuildContext context) {
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
            const SetupHeader(),
            const SizedBox(height: AppDimens.lg),
            Flexible(
              child: SingleChildScrollView(
                child: SessionSetupForm(
                  initialTopic: initialTopic,
                  weakTopics: weakTopics,
                  onSubmit: (config) => Navigator.of(context).pop(config),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SetupHeader extends StatelessWidget {
  const SetupHeader({super.key});

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
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: AppStrings.close,
          icon: const Icon(Icons.close_rounded, size: AppDimens.iconMd),
        ),
      ],
    );
  }
}
