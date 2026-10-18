import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/scorecard.dart';
import '../bloc/scorecard_cubit.dart';
import '../bloc/scorecard_state.dart';
import '../widgets/rubric_bars.dart';
import '../widgets/topic_label.dart';
import '../widgets/turn_breakdown.dart';

class ScorecardPage extends StatelessWidget {
  const ScorecardPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ScorecardCubit(sessionId: sessionId, getScorecard: sl())..load(),
      child: const ScorecardView(),
    );
  }
}

class ScorecardView extends StatelessWidget {
  const ScorecardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scorecard),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<ScorecardCubit, ScorecardState>(
          builder: (context, state) => switch (state) {
            ScorecardLoading() => const _ScorecardSkeleton(),
            ScorecardLoaded(:final scorecard) => _ScorecardBody(
              scorecard: scorecard,
            ),
            ScorecardError(:final message) => _ScorecardError(message: message),
          },
        ),
      ),
    );
  }
}

class _ScorecardBody extends StatelessWidget {
  const _ScorecardBody({required this.scorecard});

  final Scorecard scorecard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppDimens.md),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              children: [
                ScoreRing(score: scorecard.overall, size: 120),
                const SizedBox(height: AppDimens.sm),
                Text(
                  ScoreColors.labelFor(scorecard.overall),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimens.xs),
                Text(
                  topicLabel(scorecard.topic),
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: AppDimens.lg),
                RubricBars(score: scorecard.dimensions),
              ],
            ),
          ),
        ),
        if (scorecard.followUpCount > 0) ...[
          const SizedBox(height: AppDimens.md),
          _FollowUpNote(count: scorecard.followUpCount),
        ],
        const SizedBox(height: AppDimens.xl),
        Text(AppStrings.perQuestion, style: theme.textTheme.labelSmall),
        const SizedBox(height: AppDimens.sm),
        for (var i = 0; i < scorecard.turns.length; i++)
          TurnBreakdown(turn: scorecard.turns[i], position: i + 1),
        const SizedBox(height: AppDimens.lg),
        FilledButton(
          onPressed: () => context.go(AppRoutes.home),
          child: const Text(AppStrings.practiceWeakTopics),
        ),
      ],
    );
  }
}

class _FollowUpNote extends StatelessWidget {
  const _FollowUpNote({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(
            Icons.subdirectory_arrow_right_rounded,
            size: AppDimens.md,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: Text(
              AppStrings.followUpSummary(count),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScorecardSkeleton extends StatelessWidget {
  const _ScorecardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.md),
      children: const [
        Card(
          child: Padding(
            padding: EdgeInsets.all(AppDimens.lg),
            child: Column(
              children: [
                SkeletonBox.circle(size: 120),
                SizedBox(height: AppDimens.md),
                SkeletonBox.text(width: 72),
                SizedBox(height: AppDimens.lg),
                RubricBarsSkeleton(),
              ],
            ),
          ),
        ),
        SizedBox(height: AppDimens.xl),
        SkeletonBox.text(width: 110),
        SizedBox(height: AppDimens.md),
        SkeletonBox(height: 56, radius: AppDimens.radiusCard),
        SizedBox(height: AppDimens.sm),
        SkeletonBox(height: 56, radius: AppDimens.radiusCard),
      ],
    );
  }
}

class _ScorecardError extends StatelessWidget {
  const _ScorecardError({required this.message});

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
              onPressed: () => context.read<ScorecardCubit>().load(),
              child: const Text(AppStrings.retry),
            ),
            const SizedBox(height: AppDimens.sm),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text(AppStrings.navHome),
            ),
          ],
        ),
      ),
    );
  }
}
