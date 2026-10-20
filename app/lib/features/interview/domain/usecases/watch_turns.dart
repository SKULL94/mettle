import '../../../../core/usecase/usecase.dart';
import '../entities/turn_event.dart';
import '../repositories/interview_repository.dart';

class WatchTurns implements StreamUseCase<TurnEvent, String> {
  const WatchTurns(this._repository);

  final InterviewRepository _repository;

  @override
  Stream<TurnEvent> call(String params) => _repository.watchTurns(params);
}
