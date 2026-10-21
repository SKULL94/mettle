import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../bloc/interview_bloc.dart';
import '../bloc/interview_event.dart';
import '../bloc/interview_state.dart';
import '../widgets/answer_composer.dart';
import '../widgets/previous_answer.dart';
import '../widgets/question_card.dart';

class InterviewPage extends StatelessWidget {
  const InterviewPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InterviewBloc(
        sessionId: sessionId,
        watchTurns: sl(),
        submitAnswer: sl(),
        skipQuestion: sl(),
      )..add(const InterviewStarted()),
      child: const InterviewView(),
    );
  }
}

class InterviewView extends StatelessWidget {
  const InterviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<InterviewBloc, InterviewState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == InterviewStatus.complete,
      listener: (context, state) => context.pushReplacementNamed(
        AppRoutes.scorecardName,
        pathParameters: {AppRoutes.idParam: state.sessionId},
      ),
      child: Scaffold(
        appBar: const _InterviewAppBar(),
        body: SafeArea(
          child: BlocBuilder<InterviewBloc, InterviewState>(
            builder: (context, state) => _InterviewBody(state: state),
          ),
        ),
      ),
    );
  }
}

class _InterviewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _InterviewAppBar();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + AppDimens.hairline * 2);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: BlocBuilder<InterviewBloc, InterviewState>(
        buildWhen: (p, c) =>
            p.answeredCount != c.answeredCount ||
            p.totalQuestions != c.totalQuestions,
        builder: (context, state) => Text(
          state.totalQuestions == 0
              ? AppStrings.appName
              : AppStrings.questionProgress(
                  (state.answeredCount + 1).clamp(1, state.totalQuestions),
                  state.totalQuestions,
                ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(AppDimens.hairline * 2),
        child: BlocBuilder<InterviewBloc, InterviewState>(
          buildWhen: (p, c) => p.progress != c.progress,
          builder: (context, state) =>
              LinearProgressIndicator(value: state.progress),
        ),
      ),
    );
  }
}

class _InterviewBody extends StatelessWidget {
  const _InterviewBody({required this.state});

  final InterviewState state;

  @override
  Widget build(BuildContext context) {
    final answered = state.transcript.where((turn) => turn.isAnswered).toList();
    final previous = answered.isEmpty ? null : answered.last;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.md),
            children: [
              if (state.showsTranscript)
                QuestionCard(
                  text: state.streamingText,
                  isFollowUp: state.isFollowUp,
                  isStreaming: state.status == InterviewStatus.streaming,
                  reason: state.pendingReason,
                )
              else
                const QuestionCardSkeleton(),
              if (state.status == InterviewStatus.connecting &&
                  !state.showsTranscript) ...[
                const SizedBox(height: AppDimens.md),
                const _StatusLine(label: AppStrings.preparingInterview),
              ],
              if (previous != null) ...[
                const SizedBox(height: AppDimens.xl),
                PreviousAnswer(turn: previous, turnNumber: answered.length),
              ],
            ],
          ),
        ),
        if (state.error != null) _InlineError(message: state.error!),
        if (state.status == InterviewStatus.submitting)
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.md,
              0,
              AppDimens.md,
              AppDimens.sm,
            ),
            child: _StatusLine(label: AppStrings.grading),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.md,
            0,
            AppDimens.md,
            AppDimens.md,
          ),
          child: AnswerComposer(
            enabled: state.canSubmit,
            isSubmitting: state.status == InterviewStatus.submitting,
            onSubmit: (answer) =>
                context.read<InterviewBloc>().add(AnswerSubmitted(answer)),
            onSkip: () =>
                context.read<InterviewBloc>().add(const QuestionSkipped()),
          ),
        ),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: AppDimens.iconSm,
          height: AppDimens.iconSm,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppDimens.sm),
        Flexible(child: Text(label, style: theme.textTheme.labelSmall)),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimens.md,
        0,
        AppDimens.md,
        AppDimens.md,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        border: Border.all(
          color: theme.colorScheme.error,
          width: AppDimens.hairline,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(message, style: theme.textTheme.bodySmall)),
          TextButton(
            onPressed: () =>
                context.read<InterviewBloc>().add(const InterviewRetried()),
            child: const Text(AppStrings.dismiss),
          ),
        ],
      ),
    );
  }
}
