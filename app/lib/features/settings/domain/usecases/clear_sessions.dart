import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/settings_repository.dart';

class ClearSessions implements UseCase<void, NoParams> {
  const ClearSessions(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.clearSessions();
}
