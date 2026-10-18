import 'interview_turn.dart';
import 'turn_score.dart';

class Scorecard {
  const Scorecard({
    required this.sessionId,
    required this.turns,
    required this.overall,
    required this.dimensions,
  });

  final String sessionId;
  final List<InterviewTurn> turns;
  final int overall;
  final TurnScore dimensions;
}
