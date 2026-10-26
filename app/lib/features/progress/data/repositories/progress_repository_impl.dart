import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../sessions/data/datasources/session_local_data_source.dart';
import '../../../sessions/domain/entities/session_summary.dart';
import '../../../sessions/domain/entities/topic_mastery.dart';
import '../../domain/entities/progress_overview.dart';
import '../../domain/repositories/progress_repository.dart';

final class ProgressRepositoryImpl implements ProgressRepository {
  const ProgressRepositoryImpl(this._local);

  final SessionLocalDataSource _local;

  static const _historyLimit = 10;

  @override
  Stream<void> watchSessions() => _local.changes;

  @override
  Future<Result<ProgressOverview>> getOverview() async {
    try {
      final models = await _local.recentSessions(limit: _historyLimit);
      if (models.isEmpty) return const Success(ProgressOverview.empty());

      final sessions = models.map((record) => record.toSummary()).toList();

      return Success(
        ProgressOverview(
          trend: _trend(sessions),
          mastery: TopicMastery.fromSessions(sessions),
          history: sessions,
        ),
      );
    } on CacheException {
      return const Failed(CacheFailure());
    } on Object {
      return const Failed(UnknownFailure());
    }
  }

  static List<int> _trend(List<SessionSummary> sessions) => sessions
      .map((session) => session.overallScore)
      .toList()
      .reversed
      .toList();
}
