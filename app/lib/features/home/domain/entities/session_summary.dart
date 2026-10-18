class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.topic,
    required this.overallScore,
    required this.completedAt,
    required this.questionCount,
  });

  final String id;
  final String topic;

  final int overallScore;
  final DateTime completedAt;
  final int questionCount;
}
