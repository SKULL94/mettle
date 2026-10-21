import '../../../../core/result/result.dart';
import '../entities/progress_overview.dart';

abstract interface class ProgressRepository {
  Future<Result<ProgressOverview>> getOverview();
}
