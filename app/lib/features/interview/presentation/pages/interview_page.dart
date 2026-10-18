import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/interview_turn.dart';
import '../bloc/interview_bloc.dart';
import '../bloc/interview_event.dart';
import '../bloc/interview_state.dart';
import '../widgets/answer_composer.dart';
import '../widgets/question_bubble.dart';

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
        appBar: AppBar(
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
            preferredSize: const Size.fromHeight(2),
            child: BlocBuilder<InterviewBloc, InterviewState>(
              buildWhen: (p, c) => p.progress != c.progress,
              builder: (context, state) =>
                  LinearProgressIndicator(value: state.progress),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<InterviewBloc, InterviewState>(
            builder: (context, state) => _InterviewBody(state: state),
          ),
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
    if (state.status == InterviewStatus.connecting && !state.showsTranscript) {
      return const _Connecting();
    }

    final answered = state.transcript.where((turn) => turn.isAnswered).toList();
    final previous = answered.isEmpty ? null : answered.last;

    return Column(
      children: [
        Expanded(
          child: ListView(
            reverse: true,
            padding: const EdgeInsets.all(AppDimens.md),
            children: [
              if (state.streamingText.isNotEmpty)
                QuestionBubble(
                  text: state.streamingText,
                  isFollowUp: state.isFollowUp,
                  isStreaming: state.status == InterviewStatus.streaming,
                  reason: state.pendingReason,
                ),
              if (state.status == InterviewStatus.submitting)
                const _GradingRow(),
              if (previous != null) _PreviousAnswer(turn: previous),
            ],
          ),
        ),
        if (state.error != null) _InlineError(message: state.error!),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.md,
            0,
            AppDimens.md,
            AppDimens.md,
          ),
          child: AnswerComposer(
            enabled: state.canSubmit,
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

class _Connecting extends StatelessWidget {
  const _Connecting();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppStrings.preparingInterview,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _GradingRow extends StatelessWidget {
  const _GradingRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
      child: Text(
        AppStrings.grading,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _PreviousAnswer extends StatelessWidget {
  const _PreviousAnswer({required this.turn});

  final InterviewTurn turn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answer = turn.answer ?? '';

    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            answer.isEmpty ? AppStrings.skipped : AppStrings.yourAnswer,
            style: theme.textTheme.labelSmall,
          ),
          if (answer.isNotEmpty) ...[
            const SizedBox(height: AppDimens.xs),
            Opacity(
              opacity: 0.6,
              child: Text(
                answer,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ],
      ),
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
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        border: Border.all(color: theme.colorScheme.error),
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
