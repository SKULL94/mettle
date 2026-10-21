import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/result/result.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/interview_topic.dart';
import '../../domain/entities/scorecard.dart';
import '../../domain/usecases/start_session.dart';
import '../bloc/scorecard_cubit.dart';
import '../bloc/scorecard_state.dart';
import '../widgets/overall_score_card.dart';
import '../widgets/question_audit.dart';
import '../widgets/rubric_bars.dart';
import '../widgets/session_setup_sheet.dart';
import '../widgets/topic_label.dart';

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
    return BlocBuilder<ScorecardCubit, ScorecardState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.scorecard),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: AppStrings.navHome,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: SafeArea(
          child: switch (state) {
            ScorecardLoading() => const _ScorecardSkeleton(),
            ScorecardLoaded(:final scorecard) => _ScorecardBody(
              scorecard: scorecard,
            ),
            ScorecardError(:final message) => _ScorecardError(message: message),
          },
        ),
        bottomNavigationBar: switch (state) {
          ScorecardLoaded(:final scorecard) => _PracticeBar(
            topic: scorecard.topic,
          ),
          _ => null,
        },
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
        _SessionMeta(scorecard: scorecard),
        const SizedBox(height: AppDimens.md),
        OverallScoreCard(
          overall: scorecard.overall,
          dimensions: scorecard.dimensions,
        ),
        const SizedBox(height: AppDimens.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.rubricDimensions,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppDimens.md),
                RubricBars(score: scorecard.dimensions, showDescriptions: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimens.xl),
        if (scorecard.followUpCount > 0) ...[
          _FollowUpNote(count: scorecard.followUpCount),
          const SizedBox(height: AppDimens.md),
        ],
        QuestionAudit(turns: scorecard.turns),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.subdirectory_arrow_right_rounded,
          size: AppDimens.iconSm,
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
    );
  }
}

class _SessionMeta extends StatelessWidget {
  const _SessionMeta({required this.scorecard});

  final Scorecard scorecard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppDimens.sm,
      runSpacing: AppDimens.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.sm,
            vertical: AppDimens.xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            border: Border.all(
              color: theme.colorScheme.outline,
              width: AppDimens.hairline,
            ),
          ),
          child: Text(
            topicLabel(scorecard.topic).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          AppStrings.questionCount(scorecard.questionCount),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _PracticeBar extends StatelessWidget {
  const _PracticeBar({required this.topic});

  final InterviewTopic topic;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.md),
        child: FilledButton(
          onPressed: () => practiceAgain(context, topic),
          child: Text(AppStrings.practiceTopic(topicLabel(topic))),
        ),
      ),
    );
  }
}

Future<void> practiceAgain(BuildContext context, InterviewTopic topic) async {
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final config = await showSessionSetupSheet(context, topic: topic);
  if (config == null) return;

  final result = await sl<StartSession>()(config);

  switch (result) {
    case Success(:final data):
      await router.pushReplacementNamed(
        AppRoutes.sessionName,
        pathParameters: {AppRoutes.idParam: data},
      );
    case Failed(:final failure):
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
  }
}

class _ScorecardSkeleton extends StatelessWidget {
  const _ScorecardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.md),
      children: const [
        SkeletonBox.text(width: 160),
        SizedBox(height: AppDimens.md),
        Card(
          child: Padding(
            padding: EdgeInsets.all(AppDimens.lg),
            child: Column(
              children: [
                SkeletonBox.circle(size: AppDimens.scoreRingHero),
                SizedBox(height: AppDimens.lg),
                SkeletonBox.text(width: 220),
              ],
            ),
          ),
        ),
        SizedBox(height: AppDimens.md),
        Card(
          child: Padding(
            padding: EdgeInsets.all(AppDimens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox.text(width: 140),
                SizedBox(height: AppDimens.md),
                RubricBarsSkeleton(),
              ],
            ),
          ),
        ),
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
