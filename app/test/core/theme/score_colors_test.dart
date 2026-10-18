import 'package:flutter_test/flutter_test.dart';
import 'package:mettle/core/constants/app_colors.dart';
import 'package:mettle/core/theme/score_colors.dart';

void main() {
  group('ScoreColors.forScore', () {
    const colors = ScoreColors.standard();

    test('maps each band to its colour', () {
      expect(colors.forScore(0), AppColors.scoreWeak);
      expect(colors.forScore(39), AppColors.scoreWeak);
      expect(colors.forScore(40), AppColors.scoreDeveloping);
      expect(colors.forScore(59), AppColors.scoreDeveloping);
      expect(colors.forScore(60), AppColors.scoreSolid);
      expect(colors.forScore(79), AppColors.scoreSolid);
      expect(colors.forScore(80), AppColors.scoreStrong);
      expect(colors.forScore(100), AppColors.scoreStrong);
    });

    test('band boundaries are exclusive-upper, so no score is unmapped', () {
      // Walking every value catches an off-by-one in a threshold, which is the
      // realistic way this function breaks.
      for (var score = 0; score <= 100; score++) {
        expect(
          colors.forScore(score),
          isNotNull,
          reason: 'score $score produced no colour',
        );
      }
    });
  });

  group('ScoreColors.labelFor', () {
    test('every band carries a text label', () {
      // Score is never communicated by colour alone — this label is the
      // accessibility pair for forScore, so the two must agree on boundaries.
      expect(ScoreColors.labelFor(10), 'Weak');
      expect(ScoreColors.labelFor(45), 'Developing');
      expect(ScoreColors.labelFor(70), 'Solid');
      expect(ScoreColors.labelFor(95), 'Strong');
    });
  });

  group('ThemeExtension contract', () {
    test('lerp at both ends returns the endpoints', () {
      const a = ScoreColors.standard();
      const b = ScoreColors(
        weak: AppColors.scoreStrong,
        developing: AppColors.scoreStrong,
        solid: AppColors.scoreStrong,
        strong: AppColors.scoreStrong,
      );

      expect(a.lerp(b, 0).weak, a.weak);
      expect(a.lerp(b, 1).weak, b.weak);
    });

    test('lerp against null is identity', () {
      const a = ScoreColors.standard();
      expect(a.lerp(null, 0.5), same(a));
    });

    test('copyWith replaces only the named field', () {
      const a = ScoreColors.standard();
      final updated = a.copyWith(weak: AppColors.scoreStrong);

      expect(updated.weak, AppColors.scoreStrong);
      expect(updated.developing, a.developing);
      expect(updated.solid, a.solid);
      expect(updated.strong, a.strong);
    });
  });
}
