import '../../../../core/result/result.dart';
import '../entities/user_summary.dart';

abstract interface class DashboardRepository {
  Future<Result<UserSummary>> getSummary();
}
