import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../sessions/data/datasources/session_local_data_source.dart';
import '../../../sessions/data/models/session_record_model.dart';
import '../../domain/entities/interview_topic.dart';
import '../../domain/entities/interview_turn.dart';
import '../../domain/entities/scorecard.dart';
import '../../domain/entities/session_config.dart';
import '../../domain/entities/turn_event.dart';
import '../../domain/entities/turn_score.dart';
import '../../domain/repositories/interview_repository.dart';
import '../datasources/interview_remote_data_source.dart';

final class InterviewRepositoryImpl implements InterviewRepository {
  const InterviewRepositoryImpl(this._remote, this._sessions);

  final InterviewRemoteDataSource _remote;
  final SessionLocalDataSource _sessions;

  @override
  Future<Result<String>> startSession(SessionConfig config) async {
    try {
      return Success(await _remote.startSession(config));
    } on NetworkException catch (error) {
      return Failed(NetworkFailure(error.detail ?? AppStrings.serverUnreachable));
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
    } on NetworkException catch (error) {
      return Failed(NetworkFailure(error.detail ?? AppStrings.serverUnreachable));
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
    } on NetworkException catch (error) {
      return Failed(NetworkFailure(error.detail ?? AppStrings.serverUnreachable));
    } on Object {
      return const Failed(UnknownFailure());
    }
  }

  @override
  Future<Result<Scorecard>> getScorecard(String sessionId) async {
    try {
      final live = await _liveScorecard(sessionId);
      if (live != null) return Success(live);

      final stored = await _sessions.findById(sessionId);
      if (stored == null) return const Failed(NotFoundFailure());

      return Success(
        _scorecard(
          sessionId: sessionId,
          topic: InterviewTopic.fromId(stored.topic),
          turns: stored.turns,
        ),
      );
    } on CacheException {
      return const Failed(CacheFailure());
    } on Object {
      return const Failed(UnknownFailure());
    }
  }

  Future<Scorecard?> _liveScorecard(String sessionId) async {
    final List<InterviewTurn> turns;
    final InterviewTopic topic;

    try {
      turns = _remote.turnsFor(sessionId);
      topic = _remote.configFor(sessionId).topic;
    } on Object {
      return null;
    }

    if (turns.isEmpty) return null;

    await _sessions.save(
      SessionRecordModel(
        id: sessionId,
        topic: topic.id,
        completedAt: DateTime.now(),
        turns: turns,
      ),
    );

    return _scorecard(sessionId: sessionId, topic: topic, turns: turns);
  }

  static Scorecard _scorecard({
    required String sessionId,
    required InterviewTopic topic,
    required List<InterviewTurn> turns,
  }) {
    final scores = turns.map((turn) => turn.score).whereType<TurnScore>();

    final dimensions = TurnScore(
      correctness: _mean(scores.map((s) => s.correctness)),
      depth: _mean(scores.map((s) => s.depth)),
      clarity: _mean(scores.map((s) => s.clarity)),
      structure: _mean(scores.map((s) => s.structure)),
    );

    return Scorecard(
      sessionId: sessionId,
      topic: topic,
      turns: turns,
      overall: dimensions.overall,
      dimensions: dimensions,
    );
  }

  static int _mean(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return (list.reduce((a, b) => a + b) / list.length).round();
  }
}
