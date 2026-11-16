import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/page_frame.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../interview/domain/entities/interview_topic.dart';
import '../../../interview/domain/entities/session_config.dart';
import '../../../interview/presentation/widgets/session_setup_form.dart';
import '../../../interview/presentation/widgets/session_setup_sheet.dart';
import '../../../sessions/presentation/widgets/session_table.dart';
import '../../domain/entities/home_overview.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import 'calibration_card.dart';
import 'weak_topic_cards.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({required this.overview, this.staleWarning, super.key});

  final HomeOverview overview;
  final String? staleWarning;

  @override
  Widget build(BuildContext context) {
    final weakTopics = overview.weakTopics
        .map((mastery) => InterviewTopic.fromId(mastery.topic))
        .toSet();

    return PageFrame(
      onRefresh: () async =>
          context.read<HomeBloc>().add(const HomeRefreshed()),
      children: [
        PageHeader(
          eyebrow: AppStrings.dashboardEyebrow,
          title: AppStrings.dashboardTitle,
          subtitle: AppStrings.appTagline,
          actions: [
            OutlinedButton.icon(
              onPressed: () =>
                  context.read<HomeBloc>().add(const HomeRefreshed()),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppDimens.controlHeight),
              ),
              icon: const Icon(Icons.refresh_rounded, size: AppDimens.iconMd),
              label: const Text(AppStrings.refresh),
            ),
          ],
        ),
        if (staleWarning != null) ...[
          _StaleBanner(message: staleWarning!),
          const SizedBox(height: AppDimens.lg),
        ],
        PaneRow(
          panes: [
            (flex: 7, child: _LauncherCard(weakTopics: weakTopics)),
            (flex: 4, child: CalibrationCard(overview: overview)),
          ],
        ),
        if (overview.weakTopics.isNotEmpty) ...[
          const SizedBox(height: AppDimens.xl),
          SectionHeader(
            title: AppStrings.weakTopics,
            trailing: MetaTag(
              label: AppStrings.needsAttention(overview.weakTopics.length),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          WeakTopicCards(
            topics: overview.weakTopics,
            onSelected: (topic) =>
                _launch(context, topic: topic, weakTopics: weakTopics),
          ),
        ],
        if (overview.recentSessions.isNotEmpty) ...[
          const SizedBox(height: AppDimens.xl),
          SectionHeader(
            title: AppStrings.recentSessions,
            trailing: MetaTag(
              label: AppStrings.recentSessionsCaption(
                overview.recentSessions.length,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          SessionTable(
            sessions: overview.recentSessions,
            onSelected: (session) => context.pushNamed(
              AppRoutes.scorecardName,
              pathParameters: {AppRoutes.idParam: session.id},
            ),
          ),
        ],
      ],
    );
  }
}

class _LauncherCard extends StatelessWidget {
  const _LauncherCard({required this.weakTopics});

  final Set<InterviewTopic> weakTopics;

  @override
  Widget build(BuildContext context) {
    return WebCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeading(
            icon: Icons.terminal_rounded,
            title: AppStrings.configureSession,
          ),
          const SizedBox(height: AppDimens.lg),
          SessionSetupForm(
            weakTopics: weakTopics,
            submitLabel: AppStrings.launchInterview,
            submitIcon: Icons.rocket_launch_rounded,
            onSubmit: (config) => _start(context, config),
          ),
        ],
      ),
    );
  }
}

Future<void> _start(BuildContext context, SessionConfig config) async {
  final homeBloc = context.read<HomeBloc>();
  final router = GoRouter.of(context);

  final sessionId = await startConfiguredSession(context, config);
  if (sessionId == null) return;

  await router.pushNamed(
    AppRoutes.sessionName,
    pathParameters: {AppRoutes.idParam: sessionId},
  );
  homeBloc.add(const HomeRefreshed());
}

Future<void> _launch(
  BuildContext context, {
  required InterviewTopic topic,
  required Set<InterviewTopic> weakTopics,
}) async {
  final homeBloc = context.read<HomeBloc>();

  await startSessionFlow(context, topic: topic, weakTopics: weakTopics);
  homeBloc.add(const HomeRefreshed());
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: AppDimens.hairline,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(message, style: theme.textTheme.bodySmall)),
          TextButton(
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeErrorDismissed()),
            child: const Text(AppStrings.dismiss),
          ),
        ],
      ),
    );
  }
}
