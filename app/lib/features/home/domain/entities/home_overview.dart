import '../../../sessions/domain/entities/session_summary.dart';
import '../../../sessions/domain/entities/topic_mastery.dart';
import 'score_delta.dart';

class HomeOverview {
  const HomeOverview({
    required this.averageScore,
    required this.sessionCount,
    required this.delta,
    required this.lastSession,
    required this.recentSessions,
    required this.weakTopics,
  });

  const HomeOverview.empty()
    : averageScore = null,
      sessionCount = 0,
      delta = null,
      lastSession = null,
      recentSessions = const [],
      weakTopics = const [];

  static const recentLimit = 5;

  final int? averageScore;
  final int sessionCount;

  final ScoreDelta? delta;

  final SessionSummary? lastSession;
  final List<SessionSummary> recentSessions;
  final List<TopicMastery> weakTopics;

  bool get isEmpty => lastSession == null;
}
