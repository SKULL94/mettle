import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/progress_overview.dart';
import '../repositories/progress_repository.dart';

class GetProgressOverview implements UseCase<ProgressOverview, NoParams> {
  const GetProgressOverview(this._repository);

  final ProgressRepository _repository;

  @override
  Future<Result<ProgressOverview>> call(NoParams params) =>
      _repository.getOverview();
}
