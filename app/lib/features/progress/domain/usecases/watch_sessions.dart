import '../../../../core/usecase/usecase.dart';
import '../repositories/progress_repository.dart';

class WatchSessions implements StreamUseCase<void, NoParams> {
  const WatchSessions(this._repository);

  final ProgressRepository _repository;

  @override
  Stream<void> call(NoParams params) => _repository.watchSessions();
}
