import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Score semantics as a theme extension.
///
/// `ColorScheme` has no slot for "this score is weak", but the convention that
/// widgets read colors from `Theme` still has to hold. A `ThemeExtension` is the
/// supported way to add a semantic palette without widgets reaching for
/// [AppColors] directly.
///
/// Read it with `Theme.of(context).extension<ScoreColors>()!` — or, more
/// conveniently, `context.scoreColors`.
@immutable
final class ScoreColors extends ThemeExtension<ScoreColors> {
  const ScoreColors({
    required this.weak,
    required this.developing,
    required this.solid,
    required this.strong,
  });

  /// Identical in both brightnesses: these four are chosen at one lightness
  /// level so the ramp reads as a single scale, and re-tinting them per theme
  /// would break that.
  const ScoreColors.standard()
    : weak = AppColors.scoreWeak,
      developing = AppColors.scoreDeveloping,
      solid = AppColors.scoreSolid,
      strong = AppColors.scoreStrong;

  final Color weak;
  final Color developing;
  final Color solid;
  final Color strong;

  /// Maps a 0–100 score onto the ramp.
  ///
  /// Score is never communicated by color alone — callers pair this with the
  /// numeric value or [labelFor], which is an accessibility requirement, not a
  /// preference.
  Color forScore(int score) {
    if (score < 40) return weak;
    if (score < 60) return developing;
    if (score < 80) return solid;
    return strong;
  }

  /// The text label that must accompany [forScore].
  static String labelFor(int score) {
    if (score < 40) return 'Weak';
    if (score < 60) return 'Developing';
    if (score < 80) return 'Solid';
    return 'Strong';
  }

  @override
  ScoreColors copyWith({
    Color? weak,
    Color? developing,
    Color? solid,
    Color? strong,
  }) {
    return ScoreColors(
      weak: weak ?? this.weak,
      developing: developing ?? this.developing,
      solid: solid ?? this.solid,
      strong: strong ?? this.strong,
    );
  }

  @override
  ScoreColors lerp(ScoreColors? other, double t) {
    if (other == null) return this;
    return ScoreColors(
      weak: Color.lerp(weak, other.weak, t)!,
      developing: Color.lerp(developing, other.developing, t)!,
      solid: Color.lerp(solid, other.solid, t)!,
      strong: Color.lerp(strong, other.strong, t)!,
    );
  }
}

/// Saves `Theme.of(context).extension<ScoreColors>()!` at every call site.
extension ScoreColorsX on BuildContext {
  ScoreColors get scoreColors =>
      Theme.of(this).extension<ScoreColors>() ?? const ScoreColors.standard();
}
