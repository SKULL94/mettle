import 'question.dart';
import 'turn_score.dart';

class InterviewTurn {
  const InterviewTurn({required this.question, this.answer, this.score});

  final Question question;
  final String? answer;
  final TurnScore? score;

  bool get isAnswered => answer != null;

  InterviewTurn withAnswer(String value) =>
      InterviewTurn(question: question, answer: value, score: score);

  InterviewTurn withScore(TurnScore value) =>
      InterviewTurn(question: question, answer: answer, score: value);
}
