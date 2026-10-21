import '../../../sessions/domain/entities/session_summary.dart';
import '../../../sessions/domain/entities/topic_mastery.dart';

class ProgressOverview {
  const ProgressOverview({
    required this.trend,
    required this.mastery,
    required this.history,
  });

  const ProgressOverview.empty()
    : trend = const [],
      mastery = const [],
      history = const [];

  final List<int> trend;
  final List<TopicMastery> mastery;
  final List<SessionSummary> history;

  bool get isEmpty => history.isEmpty;
}
