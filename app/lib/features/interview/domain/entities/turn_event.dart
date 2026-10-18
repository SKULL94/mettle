import 'question.dart';
import 'turn_score.dart';

sealed class TurnEvent {
  const TurnEvent();
}

final class TurnStarted extends TurnEvent {
  const TurnStarted({
    required this.index,
    required this.total,
    required this.kind,
    this.reason,
  });

  final int index;
  final int total;
  final QuestionKind kind;
  final FollowUpReason? reason;
}

final class QuestionDelta extends TurnEvent {
  const QuestionDelta(this.text);
  final String text;
}

final class QuestionDone extends TurnEvent {
  const QuestionDone(this.question);
  final Question question;
}

final class GradeStarted extends TurnEvent {
  const GradeStarted();
}

final class GradeDone extends TurnEvent {
  const GradeDone(this.score);
  final TurnScore score;
}

final class SessionCompleted extends TurnEvent {
  const SessionCompleted();
}

final class TurnFailed extends TurnEvent {
  const TurnFailed(this.message, {this.retryable = true});

  final String message;
  final bool retryable;
}
