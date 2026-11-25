abstract final class AppStrings {
  static const appName = 'Mettle';
  static const appTagline = 'AI Mock Interviews for Software Engineers';
  static const brandMark = 'M';
  static const brandTag = 'FLUTTER';
  static const appScheme = 'mettle://';

  static const navHome = 'Home';
  static const navProgress = 'Progress';
  static const navSettings = 'Settings';

  static const briefOverline = 'BEFORE YOU START';
  static const briefBack = 'Back to dashboard';
  static const briefExpectTitle = 'What to expect';
  static const briefMixedTopics = 'Mixed topics';
  static const briefStart = 'Start interview';
  static const briefChange = 'Change settings';
  static const briefFailed = "Couldn't start the interview. Try again.";

  static const briefExpect1Title = 'One question at a time';
  static const briefExpect1Body =
      "Type your answer the way you'd say it out loud in an interview, in "
      'full sentences.';
  static const briefExpect2Title = 'No timer';
  static const briefExpect2Body =
      'Take the time you need. Most good answers take 2 to 3 minutes.';
  static const briefExpect3Title = 'You can skip a question';
  static const briefExpect3Body =
      "A skipped question scores 0, but you'll still see what a strong "
      'answer looks like.';
  static const briefExpect4Title = 'Your scorecard is ready when you finish';
  static const briefExpect4Body =
      'Every answer scored on correctness, depth, clarity and structure, '
      'with notes on what to improve.';

  static const briefLastFreeTitle = 'This is your last free interview';
  static const briefLastFreeBody =
      'It only counts once you submit your first answer.';

  static String briefQuestions(int count) =>
      count == 1 ? '1 question' : '$count questions';

  static String briefAbout(int minutes) => 'About $minutes min';

  static String briefTitle(String subject, String level) => '$subject · $level';

  static String briefCreditTitle(int remaining) =>
      'This uses 1 of your $remaining free interviews';

  static String briefCreditBody(int remaining) =>
      'It only counts once you submit your first answer. If you leave '
      'before that, you keep all $remaining.';

  static const recOverline = 'RECOMMENDED NEXT';
  static const recOverlineLast = 'YOUR LAST FREE INTERVIEW';
  static const recOverlineNone = 'NEXT INTERVIEW';
  static const recPickNext = 'Pick your next topic';
  static const recChooseElse = 'Choose something else';
  static const setupOwnTitle = 'Or set up your own';
  static const recentTitle = 'Recent interviews';
  static const recentViewAll = 'View all';
  static const recentTrendNote =
      'Your score trend shows up on Progress after your second interview.';
  static const statusStrong = 'Strong';
  static const statusDeveloping = 'Developing';
  static const statusNeedsWork = 'Needs work';
  static const statusNotTried = 'Not tried yet';
  static const bandNeedsWork = '0–39 Needs work';
  static const bandDeveloping = '40–69 Developing';
  static const bandReady = '70+ Interview-ready';
  static const bandReadyWord = 'Interview-ready';
  static const dashBackSubtitle = "Here's what to work on next.";
  static const dashBackSubtitleQuick =
      "Your quick check is done. Here's what to work on next.";

  static String dashWelcomeBack(String name) =>
      name.isEmpty ? 'Welcome back' : 'Welcome back, $name';

  static String recPractise(String topic) => 'Practise $topic';

  static String recUses(int remaining) =>
      'Uses 1 of your $remaining remaining free interviews';

  static const recLastFreeCaption =
      'This is your last free interview. It counts once you submit your '
      'first answer.';

  static String basedOn(int count) => count == 1
      ? 'Based on 1 interview. It gets more accurate with each one.'
      : 'Based on $count interviews. It gets more accurate with each one.';

  static const limitSubtitle =
      "Here's how far you've come, and how to keep going.";
  static const limitFirst = 'FIRST';
  static const limitLatest = 'LATEST';
  static const limitStrongest = 'Strongest';
  static const limitMostImproved = 'Most improved';
  static const limitPractiseNext = 'Practise next';
  static const limitSeeProgress = 'See full progress';
  static const proComingOverline = 'PRO';
  static const proComingTitle = 'Pro is coming soon';
  static const proComingBody =
      'Mettle is free while it is being built. Pro is not on sale yet, so '
      'there is nothing to buy and nothing to cancel.';
  static const proComingWhat = 'What Pro will include';
  static const proComingFreeTitle = 'Your free interviews keep working';
  static const proComingFreeBody =
      'Scorecards, progress and history stay free to view, always.';
  static const proComingBack = 'Back to dashboard';
  static const proTitle = 'Keep practising with Pro';
  static const proPerMonth = ' / month';
  static const proPerk1 = 'Unlimited interviews on every topic';
  static const proPerk2 = '10-question sessions';
  static const proPerk3 = 'Drills built from your weakest answers';
  static const proPerk4 = 'Voice interviewer (coming soon)';
  static const proNotReady = 'Not ready yet?';
  static const proInvite = 'Invite a friend, you both get 1 interview';
  static const lockedTitle = 'New interviews need Pro';
  static const lockedBody =
      'Your scorecards and progress stay free to view, always.';

  static String limitHeadline(String name, int total) => name.isEmpty
      ? "Nice work. You've used all $total free interviews."
      : "Nice work, $name. You've used all $total free interviews.";

  static String limitInterviews(int count) => 'Your $count interviews';

  static String limitDelta(int delta, String band) => switch (delta) {
    > 0 => '+$delta points · $band',
    < 0 => '−${delta.abs()} points · $band',
    _ => 'No change yet · $band',
  };

  static String proWeekly(String date) =>
      'Or wait for your free weekly interview on $date';

  static String recentMeta(String date, int questions) =>
      '$date · ${questions == 1 ? '1 question' : '$questions questions'}';

  static String recentSemantics(
    String title,
    String date,
    int questions,
    int score,
    String band,
  ) =>
      '$title, $date, '
      '${questions == 1 ? '1 question' : '$questions questions'}, '
      'score $score, $band. Opens scorecard.';

  static String scoreRowSemantics(int first, int latest, String band) {
    final delta = latest - first;
    final move = switch (delta) {
      > 0 => 'up $delta points',
      < 0 => 'down ${delta.abs()} points',
      _ => 'no change',
    };
    return 'First score $first, latest $latest, $move, $band';
  }

  static const dashWelcome = 'Welcome to Mettle';
  static const dashSubtitle =
      'Mock interviews for Flutter developers. Real questions from real '
      'interviews, with a score and feedback on every answer.';
  static const dashHowItWorksOpen = 'How Mettle works';

  static String dashWelcomeNamed(String name) => 'Welcome to Mettle, $name';

  static const howItWorks = 'How it works';
  static const howItWorksGotIt = 'Got it';
  static const howStep1Title = 'Pick a level and topic';
  static const howStep1Body =
      'Not sure where to start? Take the quick check across all topics.';
  static const howStep2Title = "Answer like it's the real thing";
  static const howStep2Body =
      'Questions come from real Flutter interviews. AI rewords them so you '
      "can't just memorise answers.";
  static const howStep3Title = 'Get your scorecard';
  static const howStep3Body =
      'Each answer is scored on 4 things, with notes on what to improve and '
      'what to practise next.';

  static const startTitle = 'Start your first interview';
  static const startModeQuick = 'Quick check';
  static const startModeTopic = 'Choose a topic';
  static const startRecommended = 'Recommended';
  static const startLevelLabel = 'What level are you interviewing for?';
  static const startTopicLabel = 'Pick a topic';
  static const startCountLabel = 'How many questions?';
  static const startNotTried = 'Not tried';
  static const startContinue = 'Continue';
  static const startContinueDisabled = 'Pick a topic to continue';
  static const startNoTopic = 'No topic picked yet';
  static const startQuickInfoTitle =
      'Quick check: 3 questions, mixed topics, about 10 min';

  static String startSubtitle(int remaining) =>
      'You have $remaining free interviews. '
      "Here's the best way to use the first one.";

  static String startQuickInfoBody(int rest) =>
      'Gives you a starting score for each topic, so after this Mettle can '
      'tell you what to practise with your other $rest free interviews.';

  static String startUses(int remaining) =>
      'Uses 1 of your $remaining free interviews';

  static String startStickyContinue(int remaining) =>
      'Continue · uses 1 of $remaining free';

  static String startSummaryQuick(String level) =>
      'Quick check · $level · 3 questions · ~10 min';

  static String startSummaryTopic(
    String topic,
    String level,
    int count,
    int minutes,
  ) => '$topic · $level · $count questions · ~$minutes min';

  static String startMinutes(int minutes) => '~$minutes min';

  static const proSheetTitle = '10-question interviews are part of Pro';
  static const proSheetBody =
      'Unlimited interviews, 10-question sessions and drills on your weak '
      'topics.';
  static const proSheetSeePlans = 'See plans';
  static const proSheetNotNow = 'Not now';
  static const proBadge = 'Pro';

  static const readinessTitle = 'Your readiness';
  static const readinessEmptyBody =
      'Your score appears after your first interview.';
  static const readinessCheck1 = 'A readiness score out of 100';
  static const readinessCheck2 = 'Your strong and weak topics';
  static const readinessCheck3 = 'Feedback on every answer';

  static const scoredTitle = "How you're scored";
  static const scoredCorrectness = 'Correctness';
  static const scoredCorrectnessBody =
      'You describe how Flutter really behaves, with no wrong assumptions.';
  static const scoredDepth = 'Depth';
  static const scoredDepthBody =
      'You go past the API into how it works and the trade-offs.';
  static const scoredClarity = 'Clarity';
  static const scoredClarityBody =
      "Precise terms, and an answer that's easy to follow.";
  static const scoredStructure = 'Structure';
  static const scoredStructureBody =
      'Your answer first, then the reasoning, then an example.';
  static const scoredTipLead = 'Tip:';
  static const scoredTipBody =
      'Interviewers like the same order. Say your answer in one line, then '
      'explain it.';

  static const readinessOutOf = 'of 100';
  static const readinessUnavailable = 'Readiness not available yet';

  static String readinessSemantics(int score, String band) =>
      'Readiness $score out of 100, $band';

  static const shellBrandTagline = 'Flutter interviews';
  static const shellDashboard = 'Dashboard';
  static const shellProgress = 'Progress';
  static const shellHistory = 'History';
  static const shellNewInterview = 'New interview';
  static const shellProgressLocked =
      'Progress unlocks after your first interview.';
  static const shellAccountMenu = 'Account menu';
  static const shellSettings = 'Settings';
  static const shellProfile = 'Profile';
  static const shellPlanBilling = 'Plan and billing';
  static const shellSignOut = 'Sign out';

  static const planOverline = 'FREE PLAN';
  static const planSeePlans = 'See plans';
  static const planUpgrade = 'Upgrade to Pro';
  static const planLastFree = 'Last free interview';
  static const planFirstRunNote =
      'An interview only counts once you answer the first question.';
  static const planLastFreeNote =
      'Make it count. We suggest your weakest topic.';

  static String planRemaining(int remaining, int total) =>
      '$remaining of $total free interviews left';

  static String planCreditsSemantics(int remaining, int total) =>
      '$remaining of $total free interviews left';

  static String planChip(int remaining) => '$remaining free left';

  static const navScorecard = 'Scorecard';
  static const navDashboard = 'Dashboard';
  static const navInterview = 'Interview Session';
  static const navAnalytics = 'Progress & Analytics';

  static const startInterview = 'Start Interview';
  static const quickStart = 'Quick Start';
  static const backendLabel = 'BACKEND';
  static const signedOut = 'Not signed in';
  static const accountFallback = 'Engineer';
  static const openSettings = 'Open settings';

  static const homeTitle = 'Practice';
  static const startSession = 'Start session';

  static const dashboardEyebrow = 'Session hub';
  static const dashboardTitle = 'Welcome back';
  static const dashboardTitleFirstRun = 'Welcome to Mettle';
  static const dashboardEyebrowFirstRun = 'Getting started';
  static const dashboardSubtitleFirstRun =
      'Pick a topic below and Mettle will interview you one question at a '
      'time, score every answer against a four-dimension rubric, and dig '
      'deeper wherever an answer comes up thin.';
  static const configureSession = 'Configure session';
  static const launchInterview = 'Launch AI interview';
  static const calibration = 'Calibration';
  static const readiness = 'OVERALL READINESS';
  static const statSessions = 'Sessions';
  static const statWeakTopics = 'Weak topics';
  static const statLatest = 'Latest';
  static const recentSessions = 'Recent sessions';
  static const refresh = 'Refresh';
  static const practice = 'Practice';
  static const colDate = 'Date';
  static const colTopic = 'Topic';
  static const colQuestions = 'Questions';
  static const colScore = 'Score';
  static const colScorecard = 'Scorecard';

  static String recentSessionsCaption(int count) =>
      'Showing the last ${sessionCount(count)}';
  static const yourProgress = 'YOUR PROGRESS';
  static const averageScore = 'Average score';
  static const latest = 'Latest';
  static const weakTopics = 'Weak topics';
  static const lastSession = 'Your last session';
  static const homeEmptyTitle = 'No sessions yet';
  static const homeEmptyBody =
      'Run your first interview and Mettle will score each answer against a '
      'rubric, then track how you improve.';

  static const emptyValue = '—';
  static const outOfHundred = '/ 100';
  static const noScoreYet = 'No score yet';

  static String scoreSemantics(int score, String band) =>
      'Score $score out of 100, $band';

  static const metaSeparator = ' · ';
  static const today = 'Today';
  static const yesterday = 'Yesterday';
  static const historyTitle = 'Interview history';
  static const historySubtitle =
      'Every interview you have finished, newest first.';
  static const historyThisMonth = 'This month';
  static const historyCompleted = 'Completed';
  static const historyAverage = 'Average score';
  static const historyBest = 'Best score';
  static const historyAnswered = 'Questions answered';
  static const historySkipped = 'Questions skipped';
  static const historyEmptyTitle = 'No interviews yet';
  static const historyEmptyBody =
      'Finish your first interview and it will show up here with its '
      'scorecard.';
  static const historyEmptyCta = 'Start an interview';
  static const historyFailedTitle = 'History could not load';

  static String historyCount(int count) => sessionCount(count);

  static const months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

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

  static String topicCount(int count) =>
      count == 1 ? '1 topic' : '$count topics';

  static String questionCount(int count) =>
      count == 1 ? '1 question' : '$count questions';

  static String sessionTrend(int count) => '$count-SESSION TREND';

  static String averageAcross(int count) =>
      'Average score across ${sessionCount(count)}';

  static String deltaSummary(int points) => switch (points) {
    > 0 => '+$points pts above average',
    < 0 => '${points.abs()} pts below average',
    _ => 'In line with your average',
  };

  static String deltaSemantics(int points) => switch (points) {
    > 0 => 'Last session, $points points above your average',
    < 0 => 'Last session, ${points.abs()} points below your average',
    _ => 'Last session, level with your average',
  };

  static const viewProgress = 'View progress';

  static const progressTitle = 'Progress';
  static const progressSubtitle =
      'Score trend, topic mastery and session history.';
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
  static const scorecardEyebrow = 'Evaluation report';
  static const scorecardEmptyTitle = 'No scorecard yet';
  static const scorecardEmptyBody =
      'Finish an interview and its scorecard will appear here.';
  static const scorecardSubtitle =
      'Every answer scored against the same four-dimension rubric.';
  static const backToDashboard = 'Back to dashboard';
  static const endSession = 'End session';
  static const answerPane = 'Your answer';
  static const interviewPane = 'Interviewer';
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
  static const evaluatorNoteUnscored =
      'Nothing was scored here — every question was skipped.';
  static const evaluatorNoteFloor =
      'Every dimension bottomed out. Start with correctness: get the '
      'framework behaviour right, then build depth on top.';

  static String questionAudit(int count) => 'Question audit ($count)';

  static String evaluatorNote(String strongest, String weakest) =>
      'Strongest on $strongest, weakest on $weakest. '
      'Put your next session there.';

  static String practiceTopic(String topic) => 'Practice $topic';

  static String scoreOutOf(int value, int max) => '$value / $max';

  static const settingsTitle = 'Settings';
  static const settingsSubtitle =
      'Appearance, evaluation backend and local data.';
  static const settingsIndex = 'Configuration';
  static const appearance = 'Appearance';
  static const themeSystem = 'System';
  static const themeLight = 'Light';
  static const themeDark = 'Dark';
  static const backend = 'Backend';
  static const backendBody = 'Interviews are generated and graded here.';
  static const data = 'Data';
  static const clearData = 'Clear history';
  static const clearDataBody = 'Deletes every session on your account.';
  static const clearDataPrompt =
      'This permanently deletes every interview and score on your account — '
      'here and anywhere else you are signed in, including your phone. '
      'It cannot be undone.';
  static const clearDataConfirm = 'Delete everything';
  static const clearDataDone = 'Your interview history was deleted.';
  static const about = 'About';
  static const appVersion = '0.1.0';
  static const repository = 'Repository';
  static const repositoryUrl = 'https://github.com/SKULL94/mettle';
  static const copiedToClipboard = 'Link copied.';

  static const retry = 'Retry';
  static const dismiss = 'Dismiss';
  static const cancel = 'Cancel';

  static const offlineBanner = "Can't reach the server — showing saved data.";

  static const serverError = 'Something went wrong. Please try again.';
  static const serverUnreachable = "Can't reach the Mettle server.";
  static const requestTimeout =
      'The server took too long to respond. Please retry.';
  static const streamInterrupted =
      'Lost the connection to the server. Retry to pick up where you left off.';
  static const cacheError = 'Could not read local data.';
  static const unknownError = 'Unexpected error. Please try again.';
  static const notFoundTitle = 'Page not found';
  static const notFoundBody = "That route doesn't exist.";
  static const bootstrapFailed = "Couldn't start up.";

  static const authTitle = 'Sign In';
  static const authSignIn = 'Sign in';
  static const authSignUp = 'Sign up';
  static const authWelcomeBack = 'Welcome back';
  static const authCreateAccount = 'Create your account';
  static const authSubtitle = 'Prepare for Flutter & Mobile System interviews.';
  static const authContinueGoogle = 'Continue with Google';
  static const authEmailDivider = 'OR CONTINUE WITH EMAIL';
  static const authEmailLabel = 'EMAIL ADDRESS';
  static const authEmailHint = 'you@domain.com';
  static const authPasswordLabel = 'PASSWORD';
  static const authForgotPassword = 'Forgot password?';
  static const authRememberDevice = 'Remember this device for 30 days';
  static const authSubmitSignIn = 'Sign In to Mettle';
  static const authSubmitSignUp = 'Create Account';
  static const authNoAccount = "Don't have an account?";
  static const authHaveAccount = 'Already have an account?';
  static const authEmailInvalid = 'Enter a valid email address.';
  static const authPasswordTooShort = 'Use at least 8 characters.';
  static const authPasswordTooLong = 'Use no more than 32 characters.';
  static const authPasswordNeedsUpper = 'Include an uppercase letter.';
  static const authPasswordNeedsLower = 'Include a lowercase letter.';
  static const authPasswordNeedsNumber = 'Include a number.';
  static const authPasswordNeedsSymbol = 'Include a symbol, such as ! or @.';
  static const authPasswordRequired = 'Enter your password.';
  static const authResetSent = 'Check your inbox for a reset link.';
  static const authRedirecting = 'Opening Google sign-in…';
  static const authValueProps = <String>[
    'Every answer scored against a four-dimension rubric.',
    'Follow-up probes when an answer runs thin.',
    'Topic mastery and score trend tracked across sessions.',
  ];
  static const authShowPassword = 'Show password';
  static const authHidePassword = 'Hide password';
  static const authFailed = 'Could not sign you in. Please try again.';
  static const authCancelled = 'Sign-in cancelled.';
  static const authNotConfigured = 'Supabase is not configured in this build.';
  static const authGoogleNotConfigured =
      'Google sign-in is not configured in this build.';
  static const authGoogleUnavailable =
      "Google sign-in isn't available on this device.";
  static const authConfirmEmailSent =
      'Check your inbox to confirm your email, then sign in.';

  static const setupTitle = 'New session';
  static const setupDifficulty = 'DIFFICULTY';
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
