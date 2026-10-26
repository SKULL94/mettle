import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/home_overview.dart';
import '../../domain/entities/score_delta.dart';
import '../../../sessions/domain/entities/session_summary.dart';
import '../../../sessions/domain/entities/topic_mastery.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../sessions/data/datasources/session_local_data_source.dart';

final class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._local);

  final SessionLocalDataSource _local;

  static const _weakThreshold = 60;

  @override
  Stream<void> watchSessions() => _local.changes;

  @override
  Future<Result<HomeOverview>> getOverview() async {
    try {
      final models = await _local.recentSessions();
      if (models.isEmpty) return const Success(HomeOverview.empty());

      final sessions = models.map((record) => record.toSummary()).toList();
      final average = _mean(sessions.map((s) => s.overallScore));

      return Success(
        HomeOverview(
          averageScore: average,
          sessionCount: sessions.length,
          delta: _delta(sessions, average),
          lastSession: sessions.first,
          weakTopics: _weakTopics(sessions),
        ),
      );
    } on CacheException {
      return const Failed(CacheFailure());
    } on Object {
      return const Failed(UnknownFailure());
    }
  }

  static int _mean(Iterable<int> values) {
    final list = values.toList();
    return (list.reduce((a, b) => a + b) / list.length).round();
  }

  static ScoreDelta? _delta(List<SessionSummary> sessions, int average) {
    if (sessions.length < 2) return null;

    return ScoreDelta(sessions.first.overallScore - average);
  }

  static List<TopicMastery> _weakTopics(List<SessionSummary> sessions) {
    return TopicMastery.fromSessions(sessions)
        .where((mastery) => mastery.score <= _weakThreshold)
        .toList();
  }
}
