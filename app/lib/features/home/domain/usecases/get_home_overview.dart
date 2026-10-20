import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/home_overview.dart';
import '../repositories/home_repository.dart';

class GetHomeOverview implements UseCase<HomeOverview, NoParams> {
  const GetHomeOverview(this._repository);

  final HomeRepository _repository;

  @override
  Future<Result<HomeOverview>> call(NoParams params) =>
      _repository.getOverview();
}
