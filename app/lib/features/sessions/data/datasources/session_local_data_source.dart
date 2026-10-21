import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/session_summary_model.dart';

abstract interface class SessionLocalDataSource {
  Future<List<SessionSummaryModel>> recentSessions({int limit = 10});

  Future<void> clear();

  Stream<void> get changes;
}

final class SessionLocalDataSourceStored implements SessionLocalDataSource {
  SessionLocalDataSourceStored(this._prefs, {this.seed = demoSeed});

  final SharedPreferences _prefs;

  final List<Map<String, dynamic>> seed;

  final _changes = StreamController<void>.broadcast();

  static const _key = 'sessions';

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<SessionSummaryModel>> recentSessions({int limit = 10}) async {
    try {
      final rows = _read() ?? await _writeSeed();

      return (rows.map(SessionSummaryModel.fromJson).toList()
            ..sort((a, b) => b.completedAt.compareTo(a.completedAt)))
          .take(limit)
          .toList();
    } on CacheException {
      rethrow;
    } on Object catch (error) {
      throw CacheException('malformed session row: $error');
    }
  }

  @override
  Future<void> clear() async {
    await _prefs.setString(_key, jsonEncode(<Object>[]));
    if (!_changes.isClosed) _changes.add(null);
  }

  List<Map<String, dynamic>>? _read() {
    final stored = _prefs.getString(_key);
    if (stored == null) return null;

    final decoded = jsonDecode(stored);
    if (decoded is! List) throw const CacheException('sessions are not a list');

    return decoded.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> _writeSeed() async {
    await _prefs.setString(_key, jsonEncode(seed));
    return seed;
  }

  static const List<Map<String, dynamic>> demoSeed = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'seed-1',
      'topic': 'state-management',
      'overall_score': 58,
      'completed_at': '2026-10-12T18:04:00.000Z',
      'question_count': 5,
    },
    <String, dynamic>{
      'id': 'seed-2',
      'topic': 'widget-lifecycle',
      'overall_score': 64,
      'completed_at': '2026-10-13T19:20:00.000Z',
      'question_count': 5,
    },
    <String, dynamic>{
      'id': 'seed-3',
      'topic': 'keys',
      'overall_score': 41,
      'completed_at': '2026-10-14T08:11:00.000Z',
      'question_count': 3,
    },
    <String, dynamic>{
      'id': 'seed-4',
      'topic': 'async-isolates',
      'overall_score': 52,
      'completed_at': '2026-10-15T21:45:00.000Z',
      'question_count': 5,
    },
    <String, dynamic>{
      'id': 'seed-5',
      'topic': 'performance',
      'overall_score': 71,
      'completed_at': '2026-10-16T17:02:00.000Z',
      'question_count': 5,
    },
    <String, dynamic>{
      'id': 'seed-6',
      'topic': 'navigation',
      'overall_score': 76,
      'completed_at': '2026-10-17T20:30:00.000Z',
      'question_count': 10,
    },
    <String, dynamic>{
      'id': 'seed-7',
      'topic': 'testing',
      'overall_score': 82,
      'completed_at': '2026-10-18T09:15:00.000Z',
      'question_count': 5,
    },
  ];
}
