enum Plan { free, pro }

enum TopicStatus { notTried, needsWork, developing, strong }

enum ReadinessBand { needsWork, developing, interviewReady }

enum InterviewMode { quickCheck, topic }

enum Level {
  junior('easy', 'Junior', '0–2 years'),
  mid('medium', 'Mid-level', '2–5 years'),
  senior('hard', 'Senior', '5+ years');

  const Level(this.id, this.label, this.years);

  final String id;
  final String label;
  final String years;

  static const fallback = Level.mid;

  static Level fromId(String id) =>
      Level.values.firstWhere((l) => l.id == id, orElse: () => fallback);
}

class TopicProgress {
  const TopicProgress({
    required this.id,
    required this.name,
    required this.covers,
    required this.level,
    required this.status,
    this.score,
  });

  final String id;
  final String name;
  final String covers;
  final Level level;
  final TopicStatus status;
  final int? score;
}

class InterviewSummary {
  const InterviewSummary({
    required this.sessionId,
    required this.title,
    required this.questions,
    this.date,
    this.score,
  });

  final String sessionId;
  final String title;
  final int questions;
  final DateTime? date;
  final int? score;
}

class Recommendation {
  const Recommendation({
    required this.topicId,
    required this.topicName,
    required this.reason,
    required this.level,
    required this.questionCount,
    required this.minutes,
  });

  final String topicId;
  final String topicName;
  final String reason;
  final Level level;
  final int questionCount;
  final int minutes;
}

class ProgressSummary {
  const ProgressSummary({
    required this.firstScore,
    required this.latestScore,
    required this.strongest,
    required this.mostImproved,
    required this.practiseNext,
  });

  final int firstScore;
  final int latestScore;
  final String strongest;
  final String mostImproved;
  final String practiseNext;

  int get delta => latestScore - firstScore;
}

class UserSummary {
  const UserSummary({
    required this.firstName,
    required this.plan,
    required this.freeTotal,
    required this.freeRemaining,
    required this.completedInterviews,
    required this.topics,
    required this.recent,
    this.readiness,
    this.readinessBand,
    this.next,
    this.progress,
    this.proPrice,
    this.nextFreeInterviewAt,
    this.referralAvailable = false,
  });

  const UserSummary.empty()
    : firstName = '',
      plan = Plan.free,
      freeTotal = 3,
      freeRemaining = 3,
      completedInterviews = 0,
      topics = const [],
      recent = const [],
      readiness = null,
      readinessBand = null,
      next = null,
      progress = null,
      proPrice = null,
      nextFreeInterviewAt = null,
      referralAvailable = false;

  final String firstName;
  final Plan plan;
  final int freeTotal;
  final int freeRemaining;
  final int completedInterviews;
  final List<TopicProgress> topics;
  final List<InterviewSummary> recent;
  final int? readiness;
  final ReadinessBand? readinessBand;
  final Recommendation? next;
  final ProgressSummary? progress;
  final String? proPrice;
  final DateTime? nextFreeInterviewAt;
  final bool referralAvailable;

  bool get isFirstVisit => completedInterviews == 0;
  bool get isExhausted => freeRemaining == 0;
  bool get isLastFree => freeRemaining == 1;

  List<TopicProgress> topicsFor(Level level) =>
      topics.where((topic) => topic.level == level).toList(growable: false);
}
