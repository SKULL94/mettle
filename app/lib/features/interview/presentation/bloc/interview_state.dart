import '../../domain/entities/interview_turn.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/turn_score.dart';

enum InterviewStatus {
  connecting,
  streaming,
  awaitingAnswer,
  submitting,
  complete,
  failed,
}

class InterviewState {
  const InterviewState({
    required this.sessionId,
    this.status = InterviewStatus.connecting,
    this.transcript = const <InterviewTurn>[],
    this.current,
    this.streamingText = '',
    this.pendingKind = QuestionKind.initial,
    this.pendingReason,
    this.answeredCount = 0,
    this.totalQuestions = 0,
    this.error,
  });

  final String sessionId;
  final InterviewStatus status;
  final List<InterviewTurn> transcript;
  final Question? current;
  final String streamingText;
  final QuestionKind pendingKind;
  final FollowUpReason? pendingReason;
  final int answeredCount;
  final int totalQuestions;
  final String? error;

  bool get isFollowUp => pendingKind == QuestionKind.followUp;

  bool get canSubmit => status == InterviewStatus.awaitingAnswer;

  bool get showsTranscript => transcript.isNotEmpty || streamingText.isNotEmpty;

  double get progress =>
      totalQuestions == 0 ? 0 : (answeredCount / totalQuestions).clamp(0, 1);

  TurnScore? get lastScore => transcript.isEmpty ? null : transcript.last.score;

  InterviewState copyWith({
    InterviewStatus? status,
    List<InterviewTurn>? transcript,
    Question? current,
    bool clearCurrent = false,
    String? streamingText,
    QuestionKind? pendingKind,
    FollowUpReason? pendingReason,
    bool clearPendingReason = false,
    int? answeredCount,
    int? totalQuestions,
    String? error,
    bool clearError = false,
  }) {
    return InterviewState(
      sessionId: sessionId,
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      current: clearCurrent ? null : (current ?? this.current),
      streamingText: streamingText ?? this.streamingText,
      pendingKind: pendingKind ?? this.pendingKind,
      pendingReason: clearPendingReason
          ? null
          : (pendingReason ?? this.pendingReason),
      answeredCount: answeredCount ?? this.answeredCount,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
