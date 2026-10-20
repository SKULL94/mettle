import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/interview_repository.dart';

class SubmitAnswerParams {
  const SubmitAnswerParams({
    required this.sessionId,
    required this.turnId,
    required this.answer,
  });

  final String sessionId;
  final String turnId;
  final String answer;
}

class SubmitAnswer implements UseCase<void, SubmitAnswerParams> {
  const SubmitAnswer(this._repository);

  final InterviewRepository _repository;

  @override
  Future<Result<void>> call(SubmitAnswerParams params) =>
      _repository.submitAnswer(
        sessionId: params.sessionId,
        turnId: params.turnId,
        answer: params.answer,
      );
}
