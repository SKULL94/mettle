import '../../../../core/error/exceptions.dart';
import '../models/session_summary_model.dart';

abstract interface class HomeLocalDataSource {
  Future<List<SessionSummaryModel>> recentSessions({int limit = 10});
}

final class HomeLocalDataSourceSeeded implements HomeLocalDataSource {
  const HomeLocalDataSourceSeeded({this.seed = _defaultSeed});

  final List<Map<String, dynamic>> seed;

  @override
  Future<List<SessionSummaryModel>> recentSessions({int limit = 10}) async {
    try {
      final rows = seed.map(SessionSummaryModel.fromJson).toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return rows.take(limit).toList();
    } on Object catch (error) {
      throw CacheException('malformed session row: $error');
    }
  }

  static const List<Map<String, dynamic>> _defaultSeed = <Map<String, dynamic>>[
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
