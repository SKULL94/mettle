import '../../../sessions/domain/entities/session_summary.dart';
import '../../../sessions/domain/entities/topic_mastery.dart';
import 'score_delta.dart';

class HomeOverview {
  const HomeOverview({
    required this.averageScore,
    required this.sessionCount,
    required this.delta,
    required this.lastSession,
    required this.weakTopics,
  });

  const HomeOverview.empty()
    : averageScore = null,
      sessionCount = 0,
      delta = null,
      lastSession = null,
      weakTopics = const [];

  final int? averageScore;
  final int sessionCount;

  final ScoreDelta? delta;

  final SessionSummary? lastSession;
  final List<TopicMastery> weakTopics;

  bool get isEmpty => lastSession == null;
}
