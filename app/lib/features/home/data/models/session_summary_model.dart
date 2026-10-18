import '../../domain/entities/session_summary.dart';

class SessionSummaryModel {
  const SessionSummaryModel({
    required this.id,
    required this.topic,
    required this.overallScore,
    required this.completedAt,
    required this.questionCount,
  });

  factory SessionSummaryModel.fromJson(Map<String, dynamic> json) {
    return SessionSummaryModel(
      id: json['id'] as String,
      topic: json['topic'] as String,
      overallScore: json['overall_score'] as int,
      completedAt: DateTime.parse(json['completed_at'] as String),
      questionCount: json['question_count'] as int,
    );
  }

  final String id;
  final String topic;
  final int overallScore;
  final DateTime completedAt;
  final int questionCount;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'topic': topic,
    'overall_score': overallScore,
    'completed_at': completedAt.toIso8601String(),
    'question_count': questionCount,
  };

  SessionSummary toEntity() => SessionSummary(
    id: id,
    topic: topic,
    overallScore: overallScore,
    completedAt: completedAt,
    questionCount: questionCount,
  );
}
