import '../../../../core/result/result.dart';
import '../entities/progress_overview.dart';

abstract interface class ProgressRepository {
  Stream<void> watchSessions();

  Future<Result<ProgressOverview>> getOverview();
}
