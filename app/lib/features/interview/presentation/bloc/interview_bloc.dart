import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/interview_turn.dart';
import '../../domain/entities/turn_event.dart';
import '../../domain/entities/turn_score.dart';
import '../../domain/usecases/skip_question.dart';
import '../../domain/usecases/submit_answer.dart';
import '../../domain/usecases/watch_turns.dart';
import 'interview_event.dart';
import 'interview_state.dart';

final class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  InterviewBloc({
    required String sessionId,
    required this._watchTurns,
    required this._submitAnswer,
    required this._skipQuestion,
  }) : super(InterviewState(sessionId: sessionId)) {
    on<InterviewStarted>(_onStarted);
    on<AnswerSubmitted>(_onAnswerSubmitted);
    on<QuestionSkipped>(_onQuestionSkipped);
    on<InterviewRetried>(_onRetried);
  }

  final WatchTurns _watchTurns;
  final SubmitAnswer _submitAnswer;
  final SkipQuestion _skipQuestion;

  Future<void> _onStarted(
    InterviewStarted event,
    Emitter<InterviewState> emit,
  ) async {
    emit(state.copyWith(status: InterviewStatus.connecting, clearError: true));

    await emit.onEach<TurnEvent>(
      _watchTurns(state.sessionId),
      onData: (turnEvent) => emit(_reduce(state, turnEvent)),
      onError: (error, stackTrace) => emit(
        state.copyWith(
          status: InterviewStatus.failed,
          error: AppStrings.serverError,
        ),
      ),
    );
  }

  Future<void> _onAnswerSubmitted(
    AnswerSubmitted event,
    Emitter<InterviewState> emit,
  ) async {
    final question = state.current;
    if (question == null) return;

    final answer = event.answer.trim();
    if (answer.isEmpty) return;

    emit(
      state.copyWith(
        status: InterviewStatus.submitting,
        transcript: _recordAnswer(state.transcript, answer),
        clearError: true,
      ),
    );

    final result = await _submitAnswer(
      SubmitAnswerParams(
        sessionId: state.sessionId,
        turnId: question.id,
        answer: answer,
      ),
    );

    if (result case Failed(:final failure)) {
      emit(
        state.copyWith(
          status: InterviewStatus.awaitingAnswer,
          error: failure.message,
        ),
      );
    }
  }

  Future<void> _onQuestionSkipped(
    QuestionSkipped event,
    Emitter<InterviewState> emit,
  ) async {
    final question = state.current;
    if (question == null) return;

    emit(
      state.copyWith(
        status: InterviewStatus.submitting,
        transcript: _recordAnswer(state.transcript, ''),
        clearError: true,
      ),
    );

    final result = await _skipQuestion(
      SkipQuestionParams(sessionId: state.sessionId, turnId: question.id),
    );

    if (result case Failed(:final failure)) {
      emit(
        state.copyWith(
          status: InterviewStatus.awaitingAnswer,
          error: failure.message,
        ),
      );
    }
  }

  Future<void> _onRetried(
    InterviewRetried event,
    Emitter<InterviewState> emit,
  ) async {
    emit(state.copyWith(clearError: true));
  }

  static InterviewState _reduce(InterviewState state, TurnEvent event) {
    return switch (event) {
      TurnStarted(:final index, :final total, :final kind, :final reason) =>
        state.copyWith(
          status: InterviewStatus.streaming,
          streamingText: '',
          clearCurrent: true,
          pendingKind: kind,
          pendingReason: reason,
          clearPendingReason: reason == null,
          answeredCount: index - 1,
          totalQuestions: total,
          clearError: true,
        ),
      QuestionDelta(:final text) => state.copyWith(
        streamingText: state.streamingText + text,
      ),
      QuestionDone(:final question) => state.copyWith(
        status: InterviewStatus.awaitingAnswer,
        current: question,
        streamingText: question.text,
        transcript: [
          ...state.transcript,
          InterviewTurn(question: question),
        ],
      ),
      GradeStarted() => state.copyWith(status: InterviewStatus.submitting),
      GradeDone(:final score) => state.copyWith(
        transcript: _recordScore(state.transcript, score),
      ),
      SessionCompleted() => state.copyWith(
        status: InterviewStatus.complete,
        clearCurrent: true,
      ),
      TurnFailed(:final message) => state.copyWith(
        status: InterviewStatus.failed,
        error: message,
      ),
    };
  }

  static List<InterviewTurn> _recordAnswer(
    List<InterviewTurn> transcript,
    String answer,
  ) {
    if (transcript.isEmpty) return transcript;
    return [
      ...transcript.take(transcript.length - 1),
      transcript.last.withAnswer(answer),
    ];
  }

  static List<InterviewTurn> _recordScore(
    List<InterviewTurn> transcript,
    TurnScore score,
  ) {
    if (transcript.isEmpty) return transcript;
    return [
      ...transcript.take(transcript.length - 1),
      transcript.last.withScore(score),
    ];
  }
}
