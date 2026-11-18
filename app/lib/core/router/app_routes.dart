abstract final class AppRoutes {
  static const splash = '/splash';
  static const splashName = 'splash';

  static const signIn = '/sign-in';
  static const signInName = 'signIn';

  static const home = '/';
  static const homeName = 'home';

  static const progress = '/progress';
  static const progressName = 'progress';

  static const settings = '/settings';
  static const settingsName = 'settings';

  static const latestScorecard = '/scorecard';
  static const latestScorecardName = 'latestScorecard';

  static const session = '/session/:id';
  static const sessionName = 'session';

  static const scorecard = '/session/:id/result';
  static const scorecardName = 'scorecard';

  static const idParam = 'id';
}
