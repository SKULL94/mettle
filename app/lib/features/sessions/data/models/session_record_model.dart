import '../../../interview/domain/entities/interview_turn.dart';
import '../../../interview/domain/entities/question.dart';
import '../../../interview/domain/entities/turn_score.dart';
import '../../domain/entities/session_summary.dart';

class SessionRecordModel {
  const SessionRecordModel({
    required this.id,
    required this.topic,
    required this.completedAt,
    required this.turns,
  });

  factory SessionRecordModel.fromJson(Map<String, dynamic> json) {
    return SessionRecordModel(
      id: json['id'] as String,
      topic: json['topic'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      turns: [
        for (final turn in json['turns'] as List<dynamic>)
          _turnFromJson(turn as Map<String, dynamic>),
      ],
    );
  }

  final String id;
  final String topic;
  final DateTime completedAt;
  final List<InterviewTurn> turns;

  int get questionCount =>
      turns.where((turn) => !turn.question.isFollowUp).length;

  TurnScore get dimensions {
    final scores = turns.map((turn) => turn.score).whereType<TurnScore>();

    return TurnScore(
      correctness: _mean(scores.map((score) => score.correctness)),
      depth: _mean(scores.map((score) => score.depth)),
      clarity: _mean(scores.map((score) => score.clarity)),
      structure: _mean(scores.map((score) => score.structure)),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'topic': topic,
    'completed_at': completedAt.toIso8601String(),
    'turns': [for (final turn in turns) _turnToJson(turn)],
  };

  SessionSummary toSummary() => SessionSummary(
    id: id,
    topic: topic,
    overallScore: dimensions.overall,
    completedAt: completedAt,
    questionCount: questionCount,
  );

  static int _mean(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return (list.reduce((a, b) => a + b) / list.length).round();
  }

  static InterviewTurn _turnFromJson(Map<String, dynamic> json) {
    final score = json['score'] as Map<String, dynamic>?;

    return InterviewTurn(
      question: Question(
        id: json['id'] as String,
        text: json['question'] as String,
        index: json['index'] as int,
        total: json['total'] as int,
        kind: QuestionKind.values.byName(json['kind'] as String),
        reason: json['reason'] == null
            ? null
            : FollowUpReason.values.byName(json['reason'] as String),
      ),
      answer: json['answer'] as String?,
      score: score == null
          ? null
          : TurnScore(
              correctness: score['correctness'] as int,
              depth: score['depth'] as int,
              clarity: score['clarity'] as int,
              structure: score['structure'] as int,
              missing: [
                for (final item in score['missing'] as List<dynamic>? ?? [])
                  item as String,
              ],
            ),
    );
  }

  static Map<String, dynamic> _turnToJson(InterviewTurn turn) {
    final score = turn.score;

    return <String, dynamic>{
      'id': turn.question.id,
      'question': turn.question.text,
      'index': turn.question.index,
      'total': turn.question.total,
      'kind': turn.question.kind.name,
      'reason': turn.question.reason?.name,
      'answer': turn.answer,
      if (score != null)
        'score': <String, dynamic>{
          'correctness': score.correctness,
          'depth': score.depth,
          'clarity': score.clarity,
          'structure': score.structure,
          'missing': score.missing,
        },
    };
  }
}
