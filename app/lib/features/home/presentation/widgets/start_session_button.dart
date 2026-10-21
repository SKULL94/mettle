import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/result/result.dart';
import '../../../../core/router/app_routes.dart';
import '../../../interview/domain/entities/interview_topic.dart';
import '../../../interview/domain/entities/session_config.dart';
import '../../../interview/domain/usecases/start_session.dart';
import '../../../interview/presentation/widgets/session_setup_sheet.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';

class StartSessionButton extends StatelessWidget {
  const StartSessionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton(
      onPressed: () => beginSession(context),
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

Future<void> beginSession(BuildContext context, {InterviewTopic? topic}) async {
  final homeBloc = context.read<HomeBloc>();
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);

  final SessionConfig? config = await showSessionSetupSheet(
    context,
    topic: topic,
  );
  if (config == null) return;

  final result = await sl<StartSession>()(config);

  switch (result) {
    case Success(:final data):
      await router.pushNamed(
        AppRoutes.sessionName,
        pathParameters: {AppRoutes.idParam: data},
      );
      homeBloc.add(const HomeRefreshed());
    case Failed(:final failure):
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
  }
}
