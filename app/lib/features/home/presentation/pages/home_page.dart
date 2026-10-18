import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/session_row.dart';
import '../widgets/stat_card.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) => switch (state) {
            HomeInitial() || HomeLoading() => const _HomeSkeleton(),
            HomeEmpty() => const _HomeEmpty(),
            HomeLoaded() => _HomeLoaded(state: state),
            HomeError(:final message) => _HomeError(message: message),
          },
        ),
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
      padding: const EdgeInsets.all(AppDimens.md),
      children: children,
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
        StatCardSkeleton(),
        SizedBox(height: AppDimens.lg),
        SkeletonHeader(),
        SessionRowSkeleton(),
        SessionRowSkeleton(),
        SessionRowSkeleton(),
      ],
    );
  }
}

class SkeletonHeader extends StatelessWidget {
  const SkeletonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: AppDimens.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SkeletonBox.text(width: 110),
      ),
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
        const StatCard(averageScore: null, trend: []),
        const SizedBox(height: AppDimens.xl),
        Text(
          AppStrings.homeEmptyTitle,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.sm),
        Text(
          AppStrings.homeEmptyBody,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.lg),
        const _StartSessionButton(),
      ],
    );
  }
}

class _HomeLoaded extends StatelessWidget {
  const _HomeLoaded({required this.state});

  final HomeLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overview = state.overview;

    return _Body(
      onRefresh: () async =>
          context.read<HomeBloc>().add(const HomeRefreshed()),
      children: [
        if (state.staleWarning != null)
          _StaleBanner(message: state.staleWarning!),
        StatCard(
          averageScore: overview.averageScore,
          trend: overview.recentScores,
        ),
        const SizedBox(height: AppDimens.lg),
        const _StartSessionButton(),
        if (overview.weakTopics.isNotEmpty) ...[
          const SizedBox(height: AppDimens.xl),
          WeakTopicChips(topics: overview.weakTopics, onSelected: (_) {}),
        ],
        const SizedBox(height: AppDimens.xl),
        Text(AppStrings.recentSessions, style: theme.textTheme.labelSmall),
        const SizedBox(height: AppDimens.xs),
        for (final session in overview.recentSessions)
          SessionRow(
            session: session,
            onTap: () => context.pushNamed(
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
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        border: Border.all(color: theme.colorScheme.outline),
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

class _StartSessionButton extends StatelessWidget {
  const _StartSessionButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.play_arrow_rounded),
      label: const Text(AppStrings.startSession),
    );
  }
}
