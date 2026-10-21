import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/home_overview.dart';
import '../../../sessions/domain/entities/session_summary.dart';
import '../../../sessions/domain/entities/topic_mastery.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../sessions/data/datasources/session_local_data_source.dart';

final class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._local);

  final SessionLocalDataSource _local;

  static const _weakThreshold = 60;

  static const _trendWindow = 7;

  @override
  Stream<void> watchSessions() => _local.changes;

  @override
  Future<Result<HomeOverview>> getOverview() async {
    try {
      final models = await _local.recentSessions();
      if (models.isEmpty) return const Success(HomeOverview.empty());

      final sessions = models.map((record) => record.toSummary()).toList();

      return Success(
        HomeOverview(
          averageScore: _mean(sessions.map((s) => s.overallScore)),
          recentScores: _trend(sessions),
          recentSessions: sessions,
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

  static List<int> _trend(List<SessionSummary> sessions) {
    return sessions
        .take(_trendWindow)
        .map((s) => s.overallScore)
        .toList()
        .reversed
        .toList();
  }

  static List<TopicMastery> _weakTopics(List<SessionSummary> sessions) {
    return TopicMastery.fromSessions(sessions)
        .where((mastery) => mastery.score <= _weakThreshold)
        .toList();
  }
}
