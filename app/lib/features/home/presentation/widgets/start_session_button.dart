import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../interview/domain/entities/interview_topic.dart';
import '../../../interview/presentation/widgets/session_setup_sheet.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';

class StartSessionButton extends StatelessWidget {
  const StartSessionButton({this.weakTopics = const {}, super.key});

  final Set<InterviewTopic> weakTopics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton(
      onPressed: () => beginSession(context, weakTopics: weakTopics),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppDimens.ctaHeight),
        textStyle: theme.textTheme.titleLarge,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              AppStrings.startSession,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: AppDimens.sm),
          Icon(Icons.arrow_forward_rounded, size: AppDimens.iconMd),
        ],
      ),
    );
  }
}

Future<void> beginSession(
  BuildContext context, {
  InterviewTopic? topic,
  Set<InterviewTopic> weakTopics = const {},
}) async {
  final homeBloc = context.read<HomeBloc>();
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
  homeBloc.add(const HomeRefreshed());
}
