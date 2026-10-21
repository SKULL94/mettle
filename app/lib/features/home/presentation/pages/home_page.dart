import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../interview/domain/entities/interview_topic.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_header.dart';
import '../widgets/progress_card.dart';
import '../widgets/recent_sessions.dart';
import '../widgets/start_session_button.dart';
import '../widgets/weak_topic_chips.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const HomeRequested()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) => switch (state) {
          HomeInitial() || HomeLoading() => const _HomeSkeleton(),
          HomeEmpty() => const _HomeEmpty(),
          HomeLoaded() => _HomeLoaded(state: state),
          HomeError(:final message) => _HomeError(message: message),
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.children, this.onRefresh});

  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.md,
        AppDimens.md,
        AppDimens.md,
        AppDimens.xl,
      ),
      children: [const HomeHeader(), ...children],
    );

    if (onRefresh == null) return list;
    return RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _Body(
      children: [
        SizedBox(height: AppDimens.lg),
        ProgressCardSkeleton(),
        SizedBox(height: AppDimens.lg),
        SkeletonBox(height: AppDimens.ctaHeight, radius: AppDimens.radius),
        SizedBox(height: AppDimens.xl),
        Align(alignment: Alignment.centerLeft, child: SkeletonBox.text()),
        SizedBox(height: AppDimens.md),
        RecentSessionsSkeleton(),
      ],
    );
  }
}

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Body(
      children: [
        const SizedBox(height: AppDimens.lg),
        const ProgressCard(averageScore: null, trend: [], sessionCount: 0),
        const SizedBox(height: AppDimens.xl),
        Text(
          AppStrings.homeEmptyTitle,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.sm),
        Text(
          AppStrings.homeEmptyBody,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.lg),
        const StartSessionButton(),
      ],
    );
  }
}

class _HomeLoaded extends StatelessWidget {
  const _HomeLoaded({required this.state});

  final HomeLoaded state;

  @override
  Widget build(BuildContext context) {
    final overview = state.overview;
    final weakTopics = overview.weakTopics
        .map((mastery) => InterviewTopic.fromId(mastery.topic))
        .toSet();

    return _Body(
      onRefresh: () async =>
          context.read<HomeBloc>().add(const HomeRefreshed()),
      children: [
        if (state.staleWarning != null) ...[
          const SizedBox(height: AppDimens.md),
          _StaleBanner(message: state.staleWarning!),
        ],
        const SizedBox(height: AppDimens.lg),
        ProgressCard(
          averageScore: overview.averageScore,
          trend: overview.recentScores,
          sessionCount: overview.recentSessions.length,
        ),
        const SizedBox(height: AppDimens.lg),
        StartSessionButton(weakTopics: weakTopics),
        if (overview.weakTopics.isNotEmpty) ...[
          const SizedBox(height: AppDimens.xl),
          WeakTopicChips(
            topics: overview.weakTopics,
            onSelected: (topic) =>
                beginSession(context, topic: topic, weakTopics: weakTopics),
          ),
        ],
        const SizedBox(height: AppDimens.xl),
        RecentSessions(
          sessions: overview.recentSessions,
          onSelected: (session) => context.pushNamed(
            AppRoutes.scorecardName,
            pathParameters: {AppRoutes.idParam: session.id},
          ),
        ),
      ],
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message});

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
              onPressed: () =>
                  context.read<HomeBloc>().add(const HomeRequested()),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
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
