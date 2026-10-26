import 'session_summary.dart';

class TopicMastery {
  const TopicMastery({
    required this.topic,
    required this.score,
    required this.sessionCount,
  });

  final String topic;

  final int score;
  final int sessionCount;

  static List<TopicMastery> fromSessions(List<SessionSummary> sessions) {
    final byTopic = <String, List<int>>{};
    for (final session in sessions) {
      byTopic
          .putIfAbsent(session.topic, () => <int>[])
          .add(session.overallScore);
    }

    final mastery = [
      for (final entry in byTopic.entries)
        TopicMastery(
          topic: entry.key,
          score: _mean(entry.value),
          sessionCount: entry.value.length,
        ),
    ]..sort((a, b) => a.score.compareTo(b.score));

    return mastery;
  }

  static int _mean(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return (list.reduce((a, b) => a + b) / list.length).round();
  }
}
