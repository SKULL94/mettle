import '../../domain/entities/interview_turn.dart';
import '../../domain/entities/session_config.dart';
import '../../domain/entities/turn_event.dart';

abstract interface class InterviewRemoteDataSource {
  Future<String> startSession(SessionConfig config);

  Stream<TurnEvent> watchTurns(String sessionId);

  Future<void> submitAnswer({
    required String sessionId,
    required String turnId,
    required String answer,
  });

  Future<void> skipQuestion({
    required String sessionId,
    required String turnId,
  });

  List<InterviewTurn> turnsFor(String sessionId);

  SessionConfig configFor(String sessionId);

  void dispose(String sessionId);
}
