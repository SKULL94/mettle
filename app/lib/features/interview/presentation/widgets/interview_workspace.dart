import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/page_frame.dart';
import '../../../../core/widgets/status_dot.dart';
import '../bloc/interview_bloc.dart';
import '../bloc/interview_event.dart';
import '../bloc/interview_state.dart';
import 'answer_composer.dart';
import 'previous_answer.dart';
import 'question_card.dart';

class InterviewWorkspace extends StatelessWidget {
  const InterviewWorkspace({required this.state, super.key});

  final InterviewState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.lg,
                AppDimens.lg,
                AppDimens.lg,
                0,
              ),
              child: Row(
                children: [
                  Expanded(child: _SessionStatus(state: state)),
                  const SizedBox(width: AppDimens.md),
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.dashboard),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, AppDimens.controlHeight),
                    ),
                    icon: const Icon(
                      Icons.call_end_rounded,
                      size: AppDimens.iconMd,
                    ),
                    label: const Text(AppStrings.endSession),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _QuestionPane(state: state)),
                    const SizedBox(width: AppDimens.paneGap),
                    Expanded(flex: 7, child: _AnswerPane(state: state)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionStatus extends StatelessWidget {
  const _SessionStatus({required this.state});

  final InterviewState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        StatusDot(color: theme.colorScheme.primary),
        const SizedBox(width: AppDimens.sm),
        Text(
          state.totalQuestions == 0
              ? AppStrings.preparingInterview
              : AppStrings.questionProgress(
                  (state.answeredCount + 1).clamp(1, state.totalQuestions),
                  state.totalQuestions,
                ),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(width: AppDimens.md),
        SizedBox(
          width: AppDimens.indexWidth,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 4,
              backgroundColor: theme.colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionPane extends StatelessWidget {
  const _QuestionPane({required this.state});

  final InterviewState state;

  @override
  Widget build(BuildContext context) {
    final answered = state.transcript.where((turn) => turn.isAnswered).toList();
    final previous = answered.isEmpty ? null : answered.last;

    return ListView(
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
          const StatusLine(label: AppStrings.preparingInterview),
        ],
        if (previous != null) ...[
          const SizedBox(height: AppDimens.xl),
          PreviousAnswer(turn: previous, turnNumber: answered.length),
        ],
      ],
    );
  }
}

class _AnswerPane extends StatelessWidget {
  const _AnswerPane({required this.state});

  final InterviewState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WebCard(
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.answerPane,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (state.status == InterviewStatus.submitting)
                const StatusLine(label: AppStrings.grading)
              else
                Text(
                  AppStrings.appScheme,
                  style: AppTheme.code(context).copyWith(
                    fontSize: 12,
                    color: theme.textTheme.labelSmall?.color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Expanded(
            child: AnswerComposer(
              expand: true,
              enabled: state.canSubmit,
              isSubmitting: state.status == InterviewStatus.submitting,
              onSubmit: (answer) =>
                  context.read<InterviewBloc>().add(AnswerSubmitted(answer)),
              onSkip: () =>
                  context.read<InterviewBloc>().add(const QuestionSkipped()),
            ),
          ),
          if (state.error != null) ...[
            const SizedBox(height: AppDimens.sm),
            InlineError(message: state.error!),
          ],
        ],
      ),
    );
  }
}

class StatusLine extends StatelessWidget {
  const StatusLine({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
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

class InlineError extends StatelessWidget {
  const InlineError({required this.message, super.key});

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
