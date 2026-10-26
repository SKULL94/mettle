import 'interview_topic.dart';

class SessionConfig {
  const SessionConfig({required this.topic, required this.questionCount});

  static const allowedQuestionCounts = <int>[3, 5, 10];
  static const estimatedMinutes = <int, int>{3: 10, 5: 18, 10: 35};
  static const defaultQuestionCount = 5;

  final InterviewTopic topic;
  final int questionCount;
}
