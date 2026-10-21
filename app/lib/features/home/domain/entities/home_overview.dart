import '../../../sessions/domain/entities/session_summary.dart';
import '../../../sessions/domain/entities/topic_mastery.dart';

class HomeOverview {
  const HomeOverview({
    required this.averageScore,
    required this.recentScores,
    required this.recentSessions,
    required this.weakTopics,
  });

  const HomeOverview.empty()
    : averageScore = null,
      recentScores = const [],
      recentSessions = const [],
      weakTopics = const [];

  final int? averageScore;

  final List<int> recentScores;

  final List<SessionSummary> recentSessions;
  final List<TopicMastery> weakTopics;

  bool get isEmpty => recentSessions.isEmpty;
}
