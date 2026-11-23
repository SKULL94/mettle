import 'package:flutter/material.dart';

@immutable
final class MettleColors extends ThemeExtension<MettleColors> {
  const MettleColors({
    required this.bgPage,
    required this.bgSidebar,
    required this.surfaceCard,
    required this.surfaceRaised,
    required this.surfaceDisabled,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentHover,
    required this.accentPressed,
    required this.surfacePressed,
    required this.accentText,
    required this.accentTextHover,
    required this.onAccent,
    required this.accentTint12,
    required this.accentTint14,
    required this.accentTint8,
    required this.accentBorder28,
    required this.accentBorder40,
    required this.avatarBg,
    required this.success,
    required this.warning,
    required this.danger,
  });

  const MettleColors.dark()
    : bgPage = const Color(0xFF0D0D10),
      bgSidebar = const Color(0xFF111114),
      surfaceCard = const Color(0xFF17171B),
      surfaceRaised = const Color(0xFF1E1E23),
      surfaceDisabled = const Color(0xFF23232A),
      borderSubtle = const Color(0xFF23232A),
      borderDefault = const Color(0xFF2A2A31),
      borderStrong = const Color(0xFF3A3A44),
      textPrimary = const Color(0xFFF4F4F5),
      textSecondary = const Color(0xFFB4B4BD),
      textTertiary = const Color(0xFF8E8E98),
      accent = const Color(0xFFA78BFA),
      accentHover = const Color(0xFFB097FA),
      accentPressed = const Color(0xFF967DE1),
      surfacePressed = const Color(0xFF26262C),
      accentText = const Color(0xFFC4B5FD),
      accentTextHover = const Color(0xFFDDD6FE),
      onAccent = const Color(0xFF14111F),
      accentTint12 = const Color(0x1FA78BFA),
      accentTint14 = const Color(0x24A78BFA),
      accentTint8 = const Color(0x14A78BFA),
      accentBorder28 = const Color(0x47A78BFA),
      accentBorder40 = const Color(0x66A78BFA),
      avatarBg = const Color(0xFF2E2645),
      success = const Color(0xFF86EFAC),
      warning = const Color(0xFFFCD34D),
      danger = const Color(0xFFFDBA74);

  final Color bgPage;
  final Color bgSidebar;
  final Color surfaceCard;
  final Color surfaceRaised;
  final Color surfaceDisabled;
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color accentHover;
  final Color accentPressed;
  final Color surfacePressed;
  final Color accentText;
  final Color accentTextHover;
  final Color onAccent;
  final Color accentTint12;
  final Color accentTint14;
  final Color accentTint8;
  final Color accentBorder28;
  final Color accentBorder40;
  final Color avatarBg;
  final Color success;
  final Color warning;
  final Color danger;

  @override
  MettleColors copyWith({
    Color? bgPage,
    Color? bgSidebar,
    Color? surfaceCard,
    Color? surfaceRaised,
    Color? surfaceDisabled,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentHover,
    Color? accentPressed,
    Color? surfacePressed,
    Color? accentText,
    Color? accentTextHover,
    Color? onAccent,
    Color? accentTint12,
    Color? accentTint14,
    Color? accentTint8,
    Color? accentBorder28,
    Color? accentBorder40,
    Color? avatarBg,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return MettleColors(
      bgPage: bgPage ?? this.bgPage,
      bgSidebar: bgSidebar ?? this.bgSidebar,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceDisabled: surfaceDisabled ?? this.surfaceDisabled,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      accentPressed: accentPressed ?? this.accentPressed,
      surfacePressed: surfacePressed ?? this.surfacePressed,
      accentText: accentText ?? this.accentText,
      accentTextHover: accentTextHover ?? this.accentTextHover,
      onAccent: onAccent ?? this.onAccent,
      accentTint12: accentTint12 ?? this.accentTint12,
      accentTint14: accentTint14 ?? this.accentTint14,
      accentTint8: accentTint8 ?? this.accentTint8,
      accentBorder28: accentBorder28 ?? this.accentBorder28,
      accentBorder40: accentBorder40 ?? this.accentBorder40,
      avatarBg: avatarBg ?? this.avatarBg,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  MettleColors lerp(MettleColors? other, double t) {
    if (other == null) return this;
    return MettleColors(
      bgPage: Color.lerp(bgPage, other.bgPage, t)!,
      bgSidebar: Color.lerp(bgSidebar, other.bgSidebar, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceDisabled: Color.lerp(surfaceDisabled, other.surfaceDisabled, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentPressed: Color.lerp(accentPressed, other.accentPressed, t)!,
      surfacePressed: Color.lerp(surfacePressed, other.surfacePressed, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      accentTextHover: Color.lerp(accentTextHover, other.accentTextHover, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentTint12: Color.lerp(accentTint12, other.accentTint12, t)!,
      accentTint14: Color.lerp(accentTint14, other.accentTint14, t)!,
      accentTint8: Color.lerp(accentTint8, other.accentTint8, t)!,
      accentBorder28: Color.lerp(accentBorder28, other.accentBorder28, t)!,
      accentBorder40: Color.lerp(accentBorder40, other.accentBorder40, t)!,
      avatarBg: Color.lerp(avatarBg, other.avatarBg, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension MettleColorsX on BuildContext {
  MettleColors get colors =>
      Theme.of(this).extension<MettleColors>() ?? const MettleColors.dark();
}
