/// Spacing, radii, and layout breakpoints. No bare `EdgeInsets.all(16)` in
/// widgets — every value comes from here.
abstract final class AppDimens {
  // ── Spacing scale ────────────────────────────────────────
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  // ── Radii ────────────────────────────────────────────────
  static const radius = 12.0;
  static const radiusCard = 16.0;
  static const radiusPill = 999.0;

  // ── Borders ──────────────────────────────────────────────
  /// Dark mode carries hierarchy with borders, not shadows — shadows are
  /// invisible on dark surfaces.
  static const hairline = 1.0;

  // ── Responsive breakpoints ───────────────────────────────
  /// Below this width: bottom navigation, single column.
  static const breakpointCompact = 600.0;

  /// At or above this width: navigation rail, two-pane where content justifies.
  static const breakpointExpanded = 840.0;

  // ── Component sizes ──────────────────────────────────────
  /// Minimum touch target. Non-negotiable for accessibility.
  static const minTouchTarget = 48.0;
  static const scoreRingSize = 96.0;
  static const scoreRingStroke = 8.0;
  static const sparklineHeight = 32.0;
}
