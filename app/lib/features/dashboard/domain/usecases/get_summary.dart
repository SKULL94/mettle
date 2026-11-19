import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_summary.dart';
import '../repositories/dashboard_repository.dart';

final class GetSummary implements UseCase<UserSummary, NoParams> {
  const GetSummary(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Result<UserSummary>> call(NoParams params) => _repository.getSummary();
}
