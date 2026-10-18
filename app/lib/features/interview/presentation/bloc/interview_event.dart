sealed class InterviewEvent {
  const InterviewEvent();
}

final class InterviewStarted extends InterviewEvent {
  const InterviewStarted();
}

final class AnswerSubmitted extends InterviewEvent {
  const AnswerSubmitted(this.answer);
  final String answer;
}

final class QuestionSkipped extends InterviewEvent {
  const QuestionSkipped();
}

final class InterviewRetried extends InterviewEvent {
  const InterviewRetried();
}
