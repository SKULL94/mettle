import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

@immutable
final class ScoreColors extends ThemeExtension<ScoreColors> {
  const ScoreColors({
    required this.weak,
    required this.developing,
    required this.solid,
    required this.strong,
  });

  const ScoreColors.standard()
    : weak = AppColors.scoreWeak,
      developing = AppColors.scoreDeveloping,
      solid = AppColors.scoreSolid,
      strong = AppColors.scoreStrong;

  final Color weak;
  final Color developing;
  final Color solid;
  final Color strong;

  Color forScore(int score) {
    if (score < 40) return weak;
    if (score < 60) return developing;
    if (score < 80) return solid;
    return strong;
  }

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

extension ScoreColorsX on BuildContext {
  ScoreColors get scoreColors =>
      Theme.of(this).extension<ScoreColors>() ?? const ScoreColors.standard();
}
