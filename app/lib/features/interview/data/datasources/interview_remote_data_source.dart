import 'dart:async';
import 'dart:math';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/interview_turn.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/session_config.dart';
import '../../domain/entities/turn_event.dart';
import '../../domain/entities/turn_score.dart';
import 'question_bank.dart';

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

final class InterviewScriptedDataSource implements InterviewRemoteDataSource {
  InterviewScriptedDataSource({
    this.tokenDelay = const Duration(milliseconds: 28),
    this.gradeDelay = const Duration(milliseconds: 420),
  });

  final Duration tokenDelay;
  final Duration gradeDelay;

  static const _maxFollowUpDepth = 2;
  static const _weakDimensionThreshold = 2;

  final _sessions = <String, _ScriptedSession>{};

  @override
  Future<String> startSession(SessionConfig config) async {
    final id = 'local-${DateTime.now().microsecondsSinceEpoch}';
    _sessions[id] = _ScriptedSession(
      config: config,
      bank: QuestionBank.forTopic(config.topic),
    );
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
    if (!session.started) {
      session.started = true;
      scheduleMicrotask(() => _emitQuestion(session));
    }
    return session.events.stream;
  }

  @override
  Future<void> submitAnswer({
    required String sessionId,
    required String turnId,
    required String answer,
  }) async {
    final session = _require(sessionId);
    if (session.pending?.id != turnId) {
      throw const StreamException('answer does not match the pending question');
    }
    await _grade(session, answer);
  }

  @override
  Future<void> skipQuestion({
    required String sessionId,
    required String turnId,
  }) async {
    final session = _require(sessionId);
    if (session.pending?.id != turnId) {
      throw const StreamException('skip does not match the pending question');
    }
    await _grade(session, '');
  }

  @override
  List<InterviewTurn> turnsFor(String sessionId) =>
      List.unmodifiable(_require(sessionId).turns);

  @override
  SessionConfig configFor(String sessionId) => _require(sessionId).config;

  @override
  void dispose(String sessionId) {
    _sessions.remove(sessionId)?.events.close();
  }

  _ScriptedSession _require(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null) {
      throw const StreamException('unknown session');
    }
    return session;
  }

  Future<void> _emitQuestion(_ScriptedSession session) async {
    final events = session.events;
    if (events.isClosed) return;

    final isFollowUp = session.followUpDepth > 0;
    final scripted = session.bank[session.bankIndex % session.bank.length];
    final text = isFollowUp ? scripted.followUp : scripted.text;

    events.add(
      TurnStarted(
        index: session.askedCount + 1,
        total: session.config.questionCount,
        kind: isFollowUp ? QuestionKind.followUp : QuestionKind.initial,
        reason: isFollowUp ? session.followUpReason : null,
      ),
    );

    final buffer = StringBuffer();
    for (final chunk in _chunk(text)) {
      if (events.isClosed) return;
      await Future<void>.delayed(tokenDelay);
      if (events.isClosed) return;
      buffer.write(chunk);
      events.add(QuestionDelta(chunk));
    }

    if (events.isClosed) return;

    final question = Question(
      id: 'q-${session.askedCount}-${session.followUpDepth}',
      text: buffer.toString(),
      index: session.askedCount + 1,
      total: session.config.questionCount,
      kind: isFollowUp ? QuestionKind.followUp : QuestionKind.initial,
      reason: isFollowUp ? session.followUpReason : null,
    );

    session.pending = question;
    session.activeKeywords = scripted.keywords;
    events.add(QuestionDone(question));
  }

  Future<void> _grade(_ScriptedSession session, String answer) async {
    final events = session.events;
    if (events.isClosed) return;

    events.add(const GradeStarted());
    await Future<void>.delayed(gradeDelay);
    if (events.isClosed) return;

    final asked = session.pending;
    final score = _score(answer, session.activeKeywords);
    if (asked != null) {
      session.turns.add(
        InterviewTurn(question: asked, answer: answer, score: score),
      );
    }
    session.pending = null;
    events.add(GradeDone(score));

    final shouldProbe =
        score.weakest <= _weakDimensionThreshold &&
        session.followUpDepth < _maxFollowUpDepth;

    if (shouldProbe) {
      session.followUpDepth += 1;
      session.followUpReason = _weakestReason(score);
      await _emitQuestion(session);
      return;
    }

    session.askedCount += 1;
    session.followUpDepth = 0;
    session.followUpReason = null;
    session.bankIndex += 1;

    if (session.askedCount >= session.config.questionCount) {
      if (!events.isClosed) events.add(const SessionCompleted());
      return;
    }

    await _emitQuestion(session);
  }

  static TurnScore _score(String answer, List<String> keywords) {
    final normalised = answer.toLowerCase();
    final words = normalised
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;

    if (words == 0) {
      return const TurnScore(
        correctness: 1,
        depth: 1,
        clarity: 1,
        structure: 1,
        missing: ['no answer given'],
      );
    }

    final hit = keywords.where(normalised.contains).toList();
    final coverage = keywords.isEmpty ? 1.0 : hit.length / keywords.length;
    final sentences = normalised
        .split(RegExp(r'[.!?]'))
        .where((s) => s.trim().isNotEmpty)
        .length;

    final correctness = _band(coverage);
    final depth = _band(min(words / 70, 1));
    final clarity = _band(min(words / 25, 1) * (sentences > 1 ? 1 : 0.7));
    final structure = _band(min(sentences / 3, 1));

    return TurnScore(
      correctness: correctness,
      depth: depth,
      clarity: clarity,
      structure: structure,
      missing: keywords.where((k) => !hit.contains(k)).toList(),
    );
  }

  static int _band(double ratio) {
    if (ratio >= 0.85) return 5;
    if (ratio >= 0.6) return 4;
    if (ratio >= 0.4) return 3;
    if (ratio >= 0.2) return 2;
    return 1;
  }

  static FollowUpReason _weakestReason(TurnScore score) {
    final byReason = <FollowUpReason, int>{
      FollowUpReason.correctness: score.correctness,
      FollowUpReason.depth: score.depth,
      FollowUpReason.clarity: score.clarity,
      FollowUpReason.structure: score.structure,
    };
    final lowest = byReason.values.reduce(min);
    return byReason.entries.firstWhere((e) => e.value == lowest).key;
  }

  static Iterable<String> _chunk(String text) {
    final words = text.split(' ');
    return [
      for (var i = 0; i < words.length; i++)
        i == words.length - 1 ? words[i] : '${words[i]} ',
    ];
  }
}

final class _ScriptedSession {
  _ScriptedSession({required this.config, required this.bank});

  final SessionConfig config;
  final List<ScriptedQuestion> bank;
  final events = StreamController<TurnEvent>.broadcast();
  final turns = <InterviewTurn>[];

  bool started = false;
  int askedCount = 0;
  int bankIndex = 0;
  int followUpDepth = 0;
  FollowUpReason? followUpReason;
  Question? pending;
  List<String> activeKeywords = const <String>[];
}
