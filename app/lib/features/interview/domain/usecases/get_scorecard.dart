import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/scorecard.dart';
import '../repositories/interview_repository.dart';

class GetScorecard implements UseCase<Scorecard, String> {
  const GetScorecard(this._repository);

  final InterviewRepository _repository;

  @override
  Future<Result<Scorecard>> call(String params) =>
      _repository.getScorecard(params);
}
