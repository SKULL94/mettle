abstract final class AppStrings {
  static const appName = 'Mettle';
  static const appTagline = 'Test your mettle';
  static const brandMark = 'M';

  static const navHome = 'Home';
  static const navProgress = 'Progress';
  static const navSettings = 'Settings';

  static const dashboardTitle = 'Practice Dashboard';
  static const startSession = 'Start session';
  static const yourProgress = 'YOUR PROGRESS';
  static const averageScore = 'Average score';
  static const latest = 'Latest';
  static const weakTopics = 'Weak topics';
  static const recentSessions = 'Recent sessions';
  static const homeEmptyTitle = 'No sessions yet';
  static const homeEmptyBody =
      'Run your first interview and Mettle will score each answer against a '
      'rubric, then track how you improve.';

  static const emptyValue = '—';
  static const noScoreYet = 'No score yet';

  static String scoreSemantics(int score, String band) =>
      'Score $score out of 100, $band';

  static const metaSeparator = ' · ';
  static const today = 'Today';
  static const yesterday = 'Yesterday';
  static const monthsShort = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String sessionCount(int count) =>
      count == 1 ? '1 session' : '$count sessions';

  static String questionCount(int count) =>
      count == 1 ? '1 question' : '$count questions';

  static String sessionTrend(int count) => '$count-SESSION TREND';

  static String needsAttention(int count) => 'Needs attention ($count)';

  static const followUp = 'FOLLOW-UP';
  static const answerHint = 'Type your answer…';
  static const submit = 'Submit';
  static const skip = 'Skip';
  static const preparingInterview = 'Preparing your interview…';

  static String questionProgress(int current, int total) =>
      'Q $current of $total';

  static const scorecard = 'Scorecard';
  static const correctness = 'Correctness';
  static const depth = 'Depth';
  static const clarity = 'Clarity';
  static const structure = 'Structure';
  static const whatWasMissing = 'What was missing';
  static const practiceWeakTopics = 'Practice weak topics';

  static const retry = 'Retry';
  static const dismiss = 'Dismiss';
  static const cancel = 'Cancel';

  static const demoMode = 'DEMO MODE';
  static const offlineBanner = "Can't reach the server — showing saved data.";

  static const serverError = 'Something went wrong. Please try again.';
  static const noConnection = 'No internet connection.';
  static const cacheError = 'Could not read local data.';
  static const unknownError = 'Unexpected error. Please try again.';
  static const notFoundTitle = 'Page not found';
  static const notFoundBody = "That route doesn't exist.";
  static const bootstrapFailed = "Couldn't start up.";

  static const setupTitle = 'New session';
  static const setupTopic = 'TOPIC';
  static const setupLength = 'QUESTIONS';
  static const setupStart = 'Begin';

  static const topicStateManagement = 'State management';
  static const topicWidgetLifecycle = 'Widget lifecycle';
  static const topicKeys = 'Keys';
  static const topicAsyncIsolates = 'Async & isolates';
  static const topicPerformance = 'Performance';
  static const topicNavigation = 'Navigation';
  static const topicTesting = 'Testing';

  static const reasonDepth = 'depth';
  static const reasonCorrectness = 'correctness';
  static const reasonClarity = 'clarity';
  static const reasonStructure = 'structure';

  static const grading = 'Scoring your answer…';
  static const sessionComplete = 'Session complete';
  static const viewScorecard = 'View scorecard';
  static const yourAnswer = 'Your answer';
  static const skipped = 'Skipped';
  static const sessionNotFound =
      'That session is no longer available. Start a new one.';
  static const perQuestion = 'PER QUESTION';

  static String followUpSummary(int count) => count == 1
      ? 'The interviewer probed deeper once, where an answer was thin.'
      : 'The interviewer probed deeper $count times, where answers were thin.';
}
