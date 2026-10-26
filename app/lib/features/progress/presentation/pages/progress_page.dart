import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../interview/presentation/widgets/session_setup_sheet.dart';
import '../../../sessions/presentation/widgets/session_list.dart';
import '../../domain/entities/progress_overview.dart';
import '../cubit/progress_cubit.dart';
import '../cubit/progress_state.dart';
import '../widgets/topic_mastery_list.dart';
import '../widgets/trend_card.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgressCubit(sl(), sl())..load(),
      child: const ProgressView(),
    );
  }
}

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.progressTitle)),
      body: SafeArea(
        child: BlocBuilder<ProgressCubit, ProgressState>(
          builder: (context, state) => switch (state) {
            ProgressLoading() => const _ProgressSkeleton(),
            ProgressEmpty() => const _ProgressEmpty(),
            ProgressLoaded(:final overview) => _ProgressBody(
              overview: overview,
            ),
            ProgressError(:final message) => _ProgressError(message: message),
          },
        ),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.overview});

  final ProgressOverview overview;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProgressCubit>().load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.md,
          AppDimens.md,
          AppDimens.md,
          AppDimens.xl,
        ),
        children: [
          TrendCard(trend: overview.trend),
          const SizedBox(height: AppDimens.xl),
          const SectionHeader(title: AppStrings.topicMastery),
          const SizedBox(height: AppDimens.md),
          TopicMasteryList(mastery: overview.mastery),
          const SizedBox(height: AppDimens.xl),
          const SectionHeader(title: AppStrings.history),
          const SizedBox(height: AppDimens.md),
          SessionList(
            sessions: overview.history,
            onSelected: (session) => context.pushNamed(
              AppRoutes.scorecardName,
              pathParameters: {AppRoutes.idParam: session.id},
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSkeleton extends StatelessWidget {
  const _ProgressSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.md),
      children: const [
        TrendCardSkeleton(),
        SizedBox(height: AppDimens.xl),
        TopicMasteryListSkeleton(),
        SizedBox(height: AppDimens.xl),
        SessionListSkeleton(),
      ],
    );
  }
}

class _ProgressEmpty extends StatelessWidget {
  const _ProgressEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.progressEmptyTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              AppStrings.progressEmptyBody,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.lg),
            FilledButton(
              onPressed: () => _startSession(context),
              child: const Text(AppStrings.startSession),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _startSession(BuildContext context) async {
  final router = GoRouter.of(context);
  final cubit = context.read<ProgressCubit>();

  final sessionId = await launchSession(context);
  if (sessionId == null) return;

  await router.pushNamed(
    AppRoutes.sessionName,
    pathParameters: {AppRoutes.idParam: sessionId},
  );
  await cubit.load();
}

class _ProgressError extends StatelessWidget {
  const _ProgressError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.lg),
            FilledButton(
              onPressed: () => context.read<ProgressCubit>().load(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
