import '../../domain/entities/user_summary.dart';

abstract final class UserSummaryModel {
  static UserSummary fromJson(Map<String, dynamic> json) {
    return UserSummary(
      firstName: json['first_name'] as String? ?? '',
      plan: _plan(json['plan'] as String?),
      freeTotal: json['free_total'] as int? ?? 0,
      freeRemaining: json['free_remaining'] as int? ?? 0,
      completedInterviews: json['completed_interviews'] as int? ?? 0,
      readiness: json['readiness'] as int?,
      readinessBand: _band(json['readiness_band'] as String?),
      topics: [
        for (final item in json['topics'] as List<dynamic>? ?? const [])
          _topic(item as Map<String, dynamic>),
      ],
      recent: [
        for (final item in json['recent'] as List<dynamic>? ?? const [])
          _interview(item as Map<String, dynamic>),
      ],
      next: json['next'] == null
          ? null
          : _recommendation(json['next'] as Map<String, dynamic>),
      progress: json['progress'] == null
          ? null
          : _progress(json['progress'] as Map<String, dynamic>),
      proPrice: json['pro_price'] as String?,
      nextFreeInterviewAt: DateTime.tryParse(
        json['next_free_interview_at'] as String? ?? '',
      )?.toLocal(),
      referralAvailable: json['referral_available'] as bool? ?? false,
    );
  }

  static Plan _plan(String? value) => value == 'pro' ? Plan.pro : Plan.free;

  static ReadinessBand? _band(String? value) => switch (value) {
    'needsWork' => ReadinessBand.needsWork,
    'developing' => ReadinessBand.developing,
    'interviewReady' => ReadinessBand.interviewReady,
    _ => null,
  };

  static TopicStatus _status(String? value) => switch (value) {
    'needsWork' => TopicStatus.needsWork,
    'developing' => TopicStatus.developing,
    'strong' => TopicStatus.strong,
    _ => TopicStatus.notTried,
  };

  static TopicProgress _topic(Map<String, dynamic> json) {
    return TopicProgress(
      id: json['id'] as String,
      name: json['name'] as String,
      covers: json['covers'] as String? ?? '',
      level: Level.fromId(json['difficulty'] as String? ?? ''),
      status: _status(json['status'] as String?),
      score: json['score'] as int?,
    );
  }

  static InterviewSummary _interview(Map<String, dynamic> json) {
    final date = json['date'] as String?;
    return InterviewSummary(
      sessionId: json['session_id'] as String,
      title: json['title'] as String? ?? '',
      questions: json['questions'] as int? ?? 0,
      date: date == null ? null : DateTime.tryParse(date)?.toLocal(),
      score: json['score'] as int?,
    );
  }

  static ProgressSummary _progress(Map<String, dynamic> json) {
    return ProgressSummary(
      firstScore: json['first_score'] as int? ?? 0,
      latestScore: json['latest_score'] as int? ?? 0,
      strongest: json['strongest'] as String? ?? '',
      mostImproved: json['most_improved'] as String? ?? '',
      practiseNext: json['practise_next'] as String? ?? '',
    );
  }

  static Recommendation _recommendation(Map<String, dynamic> json) {
    return Recommendation(
      topicId: json['topic_id'] as String,
      topicName: json['topic_name'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      level: Level.fromId(json['difficulty'] as String? ?? ''),
      questionCount: json['question_count'] as int? ?? 5,
      minutes: json['minutes'] as int? ?? 0,
    );
  }
}
