import 'interview_topic.dart';
import 'interview_turn.dart';
import 'turn_score.dart';

class Scorecard {
  const Scorecard({
    required this.sessionId,
    required this.topic,
    required this.turns,
    required this.overall,
    required this.dimensions,
  });

  final String sessionId;
  final InterviewTopic topic;
  final List<InterviewTurn> turns;
  final int overall;
  final TurnScore dimensions;

  int get answeredCount =>
      turns.where((t) => (t.answer ?? '').isNotEmpty).length;

  int get followUpCount => turns.where((t) => t.question.isFollowUp).length;

  List<String> get missing {
    final seen = <String>{};
    for (final turn in turns) {
      seen.addAll(turn.score?.missing ?? const <String>[]);
    }
    return seen.toList();
  }
}
