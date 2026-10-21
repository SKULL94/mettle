import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/session_record_model.dart';
import 'session_seed.dart';

abstract interface class SessionLocalDataSource {
  Future<List<SessionRecordModel>> recentSessions({int limit = 10});

  Future<SessionRecordModel?> findById(String id);

  Future<void> save(SessionRecordModel record);

  Future<void> clear();

  Stream<void> get changes;
}

final class SessionLocalDataSourceStored implements SessionLocalDataSource {
  SessionLocalDataSourceStored(this._prefs, {this.seed = sessionSeed});

  final SharedPreferences _prefs;

  final List<Map<String, dynamic>> seed;

  final _changes = StreamController<void>.broadcast();

  static const _key = 'sessions';
  static const _schemaVersion = 2;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<SessionRecordModel>> recentSessions({int limit = 10}) async {
    final records = await _records();

    return (records..sort((a, b) => b.completedAt.compareTo(a.completedAt)))
        .take(limit)
        .toList();
  }

  @override
  Future<SessionRecordModel?> findById(String id) async {
    final records = await _records();

    for (final record in records) {
      if (record.id == id) return record;
    }
    return null;
  }

  @override
  Future<void> save(SessionRecordModel record) async {
    final rows = _read() ?? await _writeSeed()
      ..removeWhere((row) => row['id'] == record.id);

    await _write([...rows, record.toJson()]);
  }

  @override
  Future<void> clear() => _write(const <Map<String, dynamic>>[]);

  Future<List<SessionRecordModel>> _records() async {
    try {
      final rows = _read() ?? await _writeSeed();
      return rows.map(SessionRecordModel.fromJson).toList();
    } on CacheException {
      rethrow;
    } on Object catch (error) {
      throw CacheException('malformed session row: $error');
    }
  }

  List<Map<String, dynamic>>? _read() {
    final stored = _prefs.getString(_key);
    if (stored == null) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(stored);
    } on FormatException {
      return null;
    }

    if (decoded is! Map<String, dynamic>) return null;
    if (decoded['version'] != _schemaVersion) return null;

    final rows = decoded['sessions'];
    if (rows is! List) throw const CacheException('sessions are not a list');

    return rows.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> _writeSeed() async {
    await _write(seed);
    return [...seed];
  }

  Future<void> _write(List<Map<String, dynamic>> rows) async {
    await _prefs.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'version': _schemaVersion,
        'sessions': rows,
      }),
    );
    if (!_changes.isClosed) _changes.add(null);
  }
}
