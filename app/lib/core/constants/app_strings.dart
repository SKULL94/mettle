/// Every user-facing string. No raw strings in widgets.
abstract final class AppStrings {
  // ── App ──────────────────────────────────────────────────
  static const appName = 'Mettle';
  static const appTagline = 'Test your mettle';

  // ── Navigation ───────────────────────────────────────────
  static const navHome = 'Home';
  static const navProgress = 'Progress';
  static const navSettings = 'Settings';

  // ── Home ─────────────────────────────────────────────────
  static const startSession = 'Start session';
  static const avgScore = 'avg score';
  static const trend = 'trend';
  static const weakTopics = 'WEAK TOPICS';
  static const recentSessions = 'RECENT SESSIONS';
  static const homeEmptyTitle = 'No sessions yet';
  static const homeEmptyBody =
      'Run your first interview and Mettle will score each answer against a '
      'rubric, then track how you improve.';

  // ── Interview ────────────────────────────────────────────
  static const followUp = 'FOLLOW-UP';
  static const answerHint = 'Type your answer…';
  static const submit = 'Submit';
  static const skip = 'Skip';
  static const preparingInterview = 'Preparing your interview…';

  /// `questionProgress(3, 5)` → `Q 3 of 5`
  static String questionProgress(int current, int total) =>
      'Q $current of $total';

  // ── Scorecard ────────────────────────────────────────────
  static const scorecard = 'Scorecard';
  static const correctness = 'Correctness';
  static const depth = 'Depth';
  static const clarity = 'Clarity';
  static const structure = 'Structure';
  static const whatWasMissing = 'What was missing';
  static const practiceWeakTopics = 'Practice weak topics';

  // ── Common actions ───────────────────────────────────────
  static const retry = 'Retry';
  static const dismiss = 'Dismiss';
  static const cancel = 'Cancel';

  // ── Status ───────────────────────────────────────────────
  static const demoMode = 'DEMO MODE';
  static const offlineBanner = "Can't reach the server — showing saved data.";

  // ── Errors ───────────────────────────────────────────────
  static const serverError = 'Something went wrong. Please try again.';
  static const noConnection = 'No internet connection.';
  static const cacheError = 'Could not read local data.';
  static const unknownError = 'Unexpected error. Please try again.';
  static const notFoundTitle = 'Page not found';
  static const notFoundBody = "That route doesn't exist.";
  static const bootstrapFailed = "Couldn't start up.";
}
