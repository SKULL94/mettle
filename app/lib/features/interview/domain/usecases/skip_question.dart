import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/interview_repository.dart';

class SkipQuestionParams {
  const SkipQuestionParams({required this.sessionId, required this.turnId});

  final String sessionId;
  final String turnId;
}

class SkipQuestion implements UseCase<void, SkipQuestionParams> {
  const SkipQuestion(this._repository);

  final InterviewRepository _repository;

  @override
  Future<Result<void>> call(SkipQuestionParams params) => _repository
      .skipQuestion(sessionId: params.sessionId, turnId: params.turnId);
}
