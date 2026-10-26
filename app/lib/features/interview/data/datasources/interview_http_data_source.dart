import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/sse_client.dart';
import '../../domain/entities/interview_turn.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/session_config.dart';
import '../../domain/entities/turn_event.dart';
import '../../domain/entities/turn_score.dart';
import 'interview_remote_data_source.dart';

final class InterviewHttpDataSource implements InterviewRemoteDataSource {
  InterviewHttpDataSource(this._api) : _sse = SseClient(_api.raw);

  final ApiClient _api;
  final SseClient _sse;

  final _sessions = <String, _HttpSession>{};

  @override
  Future<String> startSession(SessionConfig config) async {
    final body = await _api.postJson(ApiConstants.sessions, {
      'topic': config.topic.id,
      'question_count': config.questionCount,
    });

    final id = body['session_id'];
    if (id is! String || id.isEmpty) {
      throw const ServerException('session_id missing from response');
    }

    _sessions[id] = _HttpSession(config);
    return id;
  }

  @override
  Stream<TurnEvent> watchTurns(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null) {
      return Stream.value(
        const TurnFailed(AppStrings.sessionNotFound, retryable: false),
      );
    }
    return _events(sessionId, session);
  }

  Stream<TurnEvent> _events(String sessionId, _HttpSession session) async* {
    final uri = _api.uri(ApiConstants.turnStream(sessionId));
    final headers = await _api.headers();

    await for (final raw in _sse.connect(uri, headers: headers)) {
      final mapped = _map(session, raw);
      if (mapped != null) yield mapped;
    }
  }

  @override
  Future<void> submitAnswer({
    required String sessionId,
    required String turnId,
    required String answer,
  }) async {
    _require(sessionId).lastAnswer = answer;
    await _api.post(ApiConstants.answer(sessionId), {
      'turn_id': turnId,
      'answer': answer,
    });
  }

  @override
  Future<void> skipQuestion({
    required String sessionId,
    required String turnId,
  }) async {
    _require(sessionId).lastAnswer = '';
    await _api.post(ApiConstants.skip(sessionId), {'turn_id': turnId});
  }

  @override
  List<InterviewTurn> turnsFor(String sessionId) =>
      List.unmodifiable(_require(sessionId).turns);

  @override
  SessionConfig configFor(String sessionId) => _require(sessionId).config;

  @override
  void dispose(String sessionId) {
    _sessions.remove(sessionId);
  }

  _HttpSession _require(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null) {
      throw const StreamException('unknown session');
    }
    return session;
  }

  static TurnEvent? _map(_HttpSession session, ServerSentEvent raw) {
    final data = raw.data;

    switch (raw.event) {
      case 'turn.started':
        return TurnStarted(
          index: _int(data['index'], 1),
          total: _int(data['total'], session.config.questionCount),
          kind: _kind(data['kind']),
          reason: _reason(data['reason']),
        );

      case 'question.delta':
        return QuestionDelta(data['text'] as String? ?? '');

      case 'question.done':
        final question = Question(
          id: data['question_id'] as String? ?? '',
          text: data['text'] as String? ?? '',
          index: _int(data['index'], 1),
          total: _int(data['total'], session.config.questionCount),
          kind: _kind(data['kind']),
          reason: _reason(data['reason']),
        );
        session.pending = question;
        return QuestionDone(question);

      case 'grade.started':
        return const GradeStarted();

      case 'grade.done':
        final score = TurnScore(
          correctness: _int(data['correctness'], 1),
          depth: _int(data['depth'], 1),
          clarity: _int(data['clarity'], 1),
          structure: _int(data['structure'], 1),
          missing: _strings(data['missing']),
        );
        final asked = session.pending;
        if (asked != null) {
          session.turns.add(
            InterviewTurn(
              question: asked,
              answer: session.lastAnswer,
              score: score,
            ),
          );
          session.pending = null;
        }
        return GradeDone(score);

      case 'session.done':
        return const SessionCompleted();

      case 'error':
        return TurnFailed(
          data['message'] as String? ?? AppStrings.serverError,
          retryable: data['retryable'] as bool? ?? true,
        );
    }

    return null;
  }

  static int _int(Object? value, int fallback) =>
      value is int ? value : (value is num ? value.toInt() : fallback);

  static List<String> _strings(Object? value) => value is List
      ? value.whereType<String>().toList(growable: false)
      : const <String>[];

  static QuestionKind _kind(Object? value) =>
      value == 'follow_up' ? QuestionKind.followUp : QuestionKind.initial;

  static FollowUpReason? _reason(Object? value) => switch (value) {
    'depth' => FollowUpReason.depth,
    'correctness' => FollowUpReason.correctness,
    'clarity' => FollowUpReason.clarity,
    'structure' => FollowUpReason.structure,
    _ => null,
  };
}

final class _HttpSession {
  _HttpSession(this.config);

  final SessionConfig config;
  final turns = <InterviewTurn>[];

  Question? pending;
  String lastAnswer = '';
}
