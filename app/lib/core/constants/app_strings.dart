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

  static const progressTitle = 'Progress';
  static const topicMastery = 'Topic mastery';
  static const history = 'History';
  static const progressEmptyTitle = 'Nothing to chart yet';
  static const progressEmptyBody = 'Complete a session to see your progress.';

  static String trendOldest(int score) => 'Oldest $score';

  static String masterySemantics(String topic, int score, String band) =>
      '$topic, average $score out of 100, $band';

  static String needsAttention(int count) => 'Needs attention ($count)';

  static const followUp = 'FOLLOW-UP';
  static const streaming = 'Streaming';
  static const blockCursor = '▋';
  static const answerHint = 'Type your answer…';
  static const submit = 'Submit';
  static const skip = 'Skip';
  static const preparingInterview = 'Preparing your interview…';
  static const followUpSemantics = 'Follow-up question';

  static String followUpProbeSemantics(String reason) =>
      'Follow-up question, probing $reason';

  static String previousAnswer(int turn) => 'YOUR PREVIOUS ANSWER (TURN $turn)';

  static String questionProgress(int current, int total) =>
      'Q $current of $total';

  static const scorecard = 'Assessment Scorecard';
  static const correctness = 'Correctness';
  static const depth = 'Depth';
  static const clarity = 'Clarity';
  static const structure = 'Structure';
  static const whatWasMissing = 'WHAT WAS MISSING';

  static String questionNumber(int position) => 'Q$position';

  static const correctnessRubric =
      'Framework behaviour described accurately, with no wrong assumptions.';
  static const depthRubric =
      'Goes past the API surface into mechanism and trade-offs.';
  static const clarityRubric =
      'Precise terminology, and an answer that is easy to follow.';
  static const structureRubric =
      'A deliberate order: claim first, then reasoning, then example.';

  static const rubricDimensions = 'Rubric dimensions';
  static const collapseAll = 'Collapse all';
  static const expandAll = 'Expand all';
  static const evaluatorNoteBalanced =
      'Your four dimensions came out even — no single weak spot to target yet.';

  static String questionAudit(int count) => 'Question audit ($count)';

  static String evaluatorNote(String strongest, String weakest) =>
      'Strongest on $strongest, weakest on $weakest. '
      'Put your next session there.';

  static String practiceTopic(String topic) => 'Practice $topic';

  static String scoreOutOf(int value, int max) => '$value / $max';

  static const settingsTitle = 'Settings';
  static const appearance = 'Appearance';
  static const themeSystem = 'System';
  static const themeLight = 'Light';
  static const themeDark = 'Dark';
  static const mode = 'Mode';
  static const demoModeBody = 'Running on scripted questions.';
  static const liveModeTitle = 'LIVE';
  static const liveModeBody = 'Connected to a configured backend.';
  static const data = 'Data';
  static const clearData = 'Clear data';
  static const clearDataBody = 'Deletes every stored session on this device.';
  static const clearDataPrompt =
      'This removes all stored sessions and their scores. It cannot be undone.';
  static const clearDataConfirm = 'Clear';
  static const clearDataDone = 'Stored sessions deleted.';
  static const about = 'About';
  static const appVersion = '0.1.0';
  static const repository = 'Repository';
  static const repositoryUrl = 'https://github.com/SKULL94/mettle';
  static const copiedToClipboard = 'Link copied.';

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
  static const setupTopic = 'SELECT TOPIC';
  static const setupLength = 'QUESTION COUNT';
  static const setupStart = 'Start interview';
  static const setupWeakLegend = 'weak';
  static const close = 'Close';

  static String minutesEstimate(int minutes) => '~$minutes min';

  static String setupSummary(String topic, int count) =>
      'Selected: $topic$metaSeparator${questionCount(count)}';

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
  static const yourAnswer = 'YOUR ANSWER';
  static const skipped = 'Skipped';
  static const sessionNotFound =
      'That session is no longer available. Start a new one.';
  static const perQuestion = 'PER QUESTION';

  static String followUpSummary(int count) => count == 1
      ? 'The interviewer probed deeper once, where an answer was thin.'
      : 'The interviewer probed deeper $count times, where answers were thin.';
}
