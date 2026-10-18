import '../../../../core/result/result.dart';
import '../entities/scorecard.dart';
import '../entities/session_config.dart';
import '../entities/turn_event.dart';

abstract interface class InterviewRepository {
  Future<Result<String>> startSession(SessionConfig config);

  Stream<TurnEvent> watchTurns(String sessionId);

  Future<Result<void>> submitAnswer({
    required String sessionId,
    required String turnId,
    required String answer,
  });

  Future<Result<void>> skipQuestion({
    required String sessionId,
    required String turnId,
  });

  Future<Result<Scorecard>> getScorecard(String sessionId);
}
