import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/scorecard.dart';
import '../../domain/entities/session_config.dart';
import '../../domain/entities/turn_event.dart';
import '../../domain/entities/turn_score.dart';
import '../../domain/repositories/interview_repository.dart';
import '../datasources/interview_remote_data_source.dart';

final class InterviewRepositoryImpl implements InterviewRepository {
  const InterviewRepositoryImpl(this._remote);

  final InterviewRemoteDataSource _remote;

  @override
  Future<Result<String>> startSession(SessionConfig config) async {
    try {
      return Success(await _remote.startSession(config));
    } on NetworkException {
      return const Failed(NetworkFailure());
    } on ServerException {
      return const Failed(ServerFailure());
    } on Object {
      return const Failed(UnknownFailure());
    }
  }

  @override
  Stream<TurnEvent> watchTurns(String sessionId) {
    return _remote.watchTurns(sessionId).handleError((Object error) {
      throw error is AppException ? error : const StreamException();
    });
  }

  @override
  Future<Result<void>> submitAnswer({
    required String sessionId,
    required String turnId,
    required String answer,
  }) async {
    try {
      await _remote.submitAnswer(
        sessionId: sessionId,
        turnId: turnId,
        answer: answer,
      );
      return const Success(null);
    } on NetworkException {
      return const Failed(NetworkFailure());
    } on StreamException {
      return const Failed(ServerFailure());
    } on Object {
      return const Failed(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> skipQuestion({
    required String sessionId,
    required String turnId,
  }) async {
    try {
      await _remote.skipQuestion(sessionId: sessionId, turnId: turnId);
      return const Success(null);
    } on NetworkException {
      return const Failed(NetworkFailure());
    } on Object {
      return const Failed(UnknownFailure());
    }
  }

  @override
  Future<Result<Scorecard>> getScorecard(String sessionId) async {
    try {
      final turns = _remote.turnsFor(sessionId);
      if (turns.isEmpty) return const Failed(CacheFailure());

      final scores = turns
          .map((turn) => turn.score)
          .whereType<TurnScore>()
          .toList();
      if (scores.isEmpty) return const Failed(CacheFailure());

      final dimensions = TurnScore(
        correctness: _mean(scores.map((s) => s.correctness)),
        depth: _mean(scores.map((s) => s.depth)),
        clarity: _mean(scores.map((s) => s.clarity)),
        structure: _mean(scores.map((s) => s.structure)),
      );

      return Success(
        Scorecard(
          sessionId: sessionId,
          topic: _remote.configFor(sessionId).topic,
          turns: turns,
          overall: dimensions.overall,
          dimensions: dimensions,
        ),
      );
    } on Object {
      return const Failed(UnknownFailure());
    }
  }

  static int _mean(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return (list.reduce((a, b) => a + b) / list.length).round();
  }
}
