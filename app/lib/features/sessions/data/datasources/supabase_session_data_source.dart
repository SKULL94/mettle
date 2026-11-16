import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/error/exceptions.dart';
import '../../../interview/domain/entities/interview_turn.dart';
import '../../../interview/domain/entities/question.dart';
import '../../../interview/domain/entities/turn_score.dart';
import '../models/session_record_model.dart';
import 'session_local_data_source.dart';

final class SupabaseSessionDataSource implements SessionLocalDataSource {
  SupabaseSessionDataSource(this._client);

  final sb.SupabaseClient _client;

  final _changes = StreamController<void>.broadcast();

  static const _sessions = 'sessions';

  static const _columns =
      'id, topic, completed_at, '
      'turns(position, question_id, question, total, kind, reason, answer, '
      'correctness, depth, clarity, structure, missing)';

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<SessionRecordModel>> recentSessions({int limit = 10}) async {
    final rows = await _guard(
      () => _client
          .from(_sessions)
          .select(_columns)
          .order('completed_at', ascending: false)
          .limit(limit),
    );

    return [for (final row in rows) _toModel(row)];
  }

  @override
  Future<SessionRecordModel?> findById(String id) async {
    final row = await _guard(
      () => _client.from(_sessions).select(_columns).eq('id', id).maybeSingle(),
    );

    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> save(SessionRecordModel record) async => _notify();

  @override
  Future<void> clear() async {
    final userId = _requireUserId();

    await _guard(() => _client.from(_sessions).delete().eq('user_id', userId));
    _notify();
  }

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  String _requireUserId() {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const ServerException('not signed in');
    return id;
  }

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on sb.PostgrestException catch (error) {
      throw ServerException(error.message);
    } on sb.AuthException catch (error) {
      throw ServerException(error.message);
    }
  }

  static SessionRecordModel _toModel(Map<String, dynamic> row) {
    try {
      final turns =
          (row['turns'] as List<dynamic>? ?? const <dynamic>[])
              .cast<Map<String, dynamic>>()
              .toList()
            ..sort(
              (a, b) => (a['position'] as int).compareTo(b['position'] as int),
            );

      return SessionRecordModel(
        id: row['id'] as String,
        topic: row['topic'] as String,
        completedAt: DateTime.parse(row['completed_at'] as String),
        turns: [for (final turn in turns) _toTurn(turn)],
      );
    } on Object catch (error) {
      throw CacheException('malformed session row: $error');
    }
  }

  static InterviewTurn _toTurn(Map<String, dynamic> row) {
    final correctness = row['correctness'] as int?;
    final reason = row['reason'] as String?;

    return InterviewTurn(
      question: Question(
        id: row['question_id'] as String,
        text: row['question'] as String,
        index: row['position'] as int,
        total: row['total'] as int,
        kind: QuestionKind.values.byName(row['kind'] as String),
        reason: reason == null ? null : FollowUpReason.values.byName(reason),
      ),
      answer: row['answer'] as String?,
      score: correctness == null
          ? null
          : TurnScore(
              correctness: correctness,
              depth: row['depth'] as int,
              clarity: row['clarity'] as int,
              structure: row['structure'] as int,
              missing: [
                for (final item
                    in row['missing'] as List<dynamic>? ?? const <dynamic>[])
                  item as String,
              ],
            ),
    );
  }
}
