import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/session_config.dart';
import '../repositories/interview_repository.dart';

class StartSession implements UseCase<String, SessionConfig> {
  const StartSession(this._repository);

  final InterviewRepository _repository;

  @override
  Future<Result<String>> call(SessionConfig params) =>
      _repository.startSession(params);
}
