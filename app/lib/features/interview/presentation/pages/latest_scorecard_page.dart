import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/home_event.dart';
import '../../../home/presentation/bloc/home_state.dart';
import '../widgets/session_setup_sheet.dart';
import 'scorecard_page.dart';

class LatestScorecardPage extends StatelessWidget {
  const LatestScorecardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const HomeRequested()),
      child: const _LatestScorecardView(),
    );
  }
}

class _LatestScorecardView extends StatelessWidget {
  const _LatestScorecardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) => switch (state) {
        HomeLoaded(:final overview) when overview.lastSession != null =>
          ScorecardPage(sessionId: overview.lastSession!.id, embedded: true),
        HomeInitial() || HomeLoading() => const _Loading(),
        HomeError(:final message) => _Empty(message: message),
        _ => const _Empty(message: AppStrings.scorecardEmptyBody),
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SkeletonBox.circle(size: AppDimens.scoreRingHero),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

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
              AppStrings.scorecardEmptyTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.lg),
            FilledButton(
              onPressed: () => startSessionFlow(context),
              child: const Text(AppStrings.startSession),
            ),
          ],
        ),
      ),
    );
  }
}
