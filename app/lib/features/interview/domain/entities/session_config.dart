import 'interview_topic.dart';

class SessionConfig {
  const SessionConfig({required this.topic, required this.questionCount});

  static const allowedQuestionCounts = <int>[3, 5, 10];

  final InterviewTopic topic;
  final int questionCount;
}
