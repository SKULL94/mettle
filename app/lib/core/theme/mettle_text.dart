import 'package:flutter/material.dart';

import 'mettle_colors.dart';
import 'size_class.dart';

@immutable
final class MettleText {
  const MettleText._({
    required this.display,
    required this.headline,
    required this.titleLarge,
    required this.cardTitle,
    required this.bodyLarge,
    required this.labelLarge,
    required this.labelMedium,
    required this.bodyMedium,
    required this.bodySmall,
    required this.caption,
    required this.overline,
    required this.badge,
    required this.buttonLarge,
    required this.buttonMedium,
    required this.link,
    required this.monoLarge,
    required this.monoMedium,
    required this.monoPlaceholder,
    required this.monoSmall,
  });

  static const sans = 'Inter';
  static const mono = 'JetBrains Mono';

  static const _tabular = <FontFeature>[FontFeature.tabularFigures()];

  final TextStyle display;
  final TextStyle headline;
  final TextStyle titleLarge;
  final TextStyle cardTitle;
  final TextStyle bodyLarge;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle caption;
  final TextStyle overline;
  final TextStyle badge;
  final TextStyle buttonLarge;
  final TextStyle buttonMedium;
  final TextStyle link;
  final TextStyle monoLarge;
  final TextStyle monoMedium;
  final TextStyle monoPlaceholder;
  final TextStyle monoSmall;

  factory MettleText.of(BuildContext context) {
    final colors = context.colors;
    final phone = context.sizeClass.isCompact;

    return MettleText._(
      display: TextStyle(
        fontFamily: sans,
        fontSize: phone ? 28 : 36,
        height: phone ? 1.21 : 1.22,
        fontWeight: FontWeight.w800,
        letterSpacing: phone ? -0.56 : -0.72,
        color: colors.textPrimary,
      ),
      headline: TextStyle(
        fontFamily: sans,
        fontSize: phone ? 24 : 28,
        height: phone ? 30 / 24 : 34 / 28,
        fontWeight: FontWeight.w800,
        letterSpacing: phone ? -0.24 : -0.28,
        color: colors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: sans,
        fontSize: phone ? 20 : 22,
        height: phone ? 1.3 : 1.27,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
      cardTitle: TextStyle(
        fontFamily: sans,
        fontSize: phone ? 17 : 18,
        height: phone ? 1.41 : 1.33,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: sans,
        fontSize: phone ? 15 : 16,
        height: phone ? 1.47 : 1.5,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: sans,
        fontSize: 15,
        height: 1.33,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: sans,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: sans,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontFamily: sans,
        fontSize: 13,
        height: 1.46,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      caption: TextStyle(
        fontFamily: sans,
        fontSize: 12,
        height: 1.33,
        fontWeight: FontWeight.w400,
        color: colors.textTertiary,
      ),
      overline: TextStyle(
        fontFamily: sans,
        fontSize: 12,
        height: 1.33,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.72,
        color: colors.textTertiary,
      ),
      badge: TextStyle(
        fontFamily: sans,
        fontSize: 11,
        height: 1.27,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.44,
        color: colors.onAccent,
      ),
      buttonLarge: TextStyle(
        fontFamily: sans,
        fontSize: 15,
        height: 1.33,
        fontWeight: FontWeight.w700,
        color: colors.onAccent,
      ),
      buttonMedium: TextStyle(
        fontFamily: sans,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      link: TextStyle(
        fontFamily: sans,
        fontSize: 13,
        height: 1.38,
        fontWeight: FontWeight.w600,
        color: colors.accentText,
      ),
      monoLarge: TextStyle(
        fontFamily: mono,
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w700,
        fontFeatures: _tabular,
        color: colors.textPrimary,
      ),
      monoMedium: TextStyle(
        fontFamily: mono,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w700,
        fontFeatures: _tabular,
        color: colors.accentText,
      ),
      monoPlaceholder: TextStyle(
        fontFamily: mono,
        fontSize: 22,
        height: 1.27,
        fontWeight: FontWeight.w500,
        fontFeatures: _tabular,
        color: colors.textTertiary,
      ),
      monoSmall: TextStyle(
        fontFamily: mono,
        fontSize: 12,
        height: 1.33,
        fontWeight: FontWeight.w500,
        fontFeatures: _tabular,
        color: colors.textTertiary,
      ),
    );
  }
}

extension MettleTextX on BuildContext {
  MettleText get text => MettleText.of(this);
}
