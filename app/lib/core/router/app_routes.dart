/// Route paths and names. No string literals at call sites.
///
/// This app has no authentication and no gated routes: `/splash` is the
/// `initialLocation`, performs async bootstrap, then `go`es to home. Don't add
/// `redirect` guards without a decision to introduce accounts.
abstract final class AppRoutes {
  // ── Bootstrap ────────────────────────────────────────────
  static const splash = '/splash';
  static const splashName = 'splash';

  // ── Shell tabs ───────────────────────────────────────────
  static const home = '/';
  static const homeName = 'home';

  static const progress = '/progress';
  static const progressName = 'progress';

  static const settings = '/settings';
  static const settingsName = 'settings';

  // ── Pushed above the shell ───────────────────────────────
  // Full-screen: an interview shouldn't have a tab bar competing for attention
  // mid-answer.
  static const session = '/session/:id';
  static const sessionName = 'session';

  static const scorecard = '/session/:id/result';
  static const scorecardName = 'scorecard';

  /// Path parameter key, so call sites don't repeat the literal.
  static const idParam = 'id';
}
