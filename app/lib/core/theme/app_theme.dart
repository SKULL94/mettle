import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import 'score_colors.dart';

abstract final class AppTheme {
  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    scheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.accentDark,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.accentDark,
          onPrimary: AppColors.onAccentDark,
          surface: AppColors.bgDark,
          onSurface: AppColors.textPrimaryDark,
          surfaceContainer: AppColors.surfaceDark,
          surfaceContainerHigh: AppColors.surfaceElevatedDark,
          onSurfaceVariant: AppColors.textSecondaryDark,
          outline: AppColors.outlineDark,
          outlineVariant: AppColors.outlineDark,
          error: AppColors.danger,
        ),
    mutedText: AppColors.textMutedDark,
  );

  static ThemeData light() => _build(
    brightness: Brightness.light,
    scheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.accentLight,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.accentLight,
          onPrimary: AppColors.onAccentLight,
          surface: AppColors.bgLight,
          onSurface: AppColors.textPrimaryLight,
          surfaceContainer: AppColors.surfaceLight,
          surfaceContainerHigh: AppColors.surfaceElevatedLight,
          onSurfaceVariant: AppColors.textSecondaryLight,
          outline: AppColors.outlineLight,
          outlineVariant: AppColors.outlineLight,
          error: AppColors.danger,
        ),
    mutedText: AppColors.textMutedLight,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color mutedText,
  }) {
    final isDark = brightness == Brightness.dark;
    final text = _textTheme(scheme, mutedText);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      extensions: const <ThemeExtension<dynamic>>[ScoreColors.standard()],

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: isDark ? 0 : 1,
        centerTitle: false,
        titleTextStyle: text.titleMedium,
      ),

      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : null,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          side: isDark
              ? BorderSide(color: scheme.outline, width: AppDimens.hairline)
              : BorderSide.none,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: AppDimens.hairline,
        space: AppDimens.md,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppDimens.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius),
          ),
          textStyle: text.titleMedium,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppDimens.minTouchTarget,
            AppDimens.minTouchTarget,
          ),
          textStyle: text.titleMedium,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppDimens.minTouchTarget),
          side: BorderSide(color: scheme.outline, width: AppDimens.hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius),
          ),
          textStyle: text.titleMedium,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        hintStyle: text.bodyMedium?.copyWith(color: mutedText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md,
          vertical: AppDimens.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        side: BorderSide(color: scheme.outline, width: AppDimens.hairline),
        shape: const StadiumBorder(),
        labelStyle: text.bodySmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.sm,
          vertical: AppDimens.xs,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(text.labelSmall),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusCard),
          ),
        ),
        showDragHandle: true,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.outline,
        linearMinHeight: 2,
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme, Color mutedText) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),

      labelSmall: TextStyle(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: mutedText,
      ),
    );
  }

  static TextStyle code(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'JetBrains Mono',
      fontFamilyFallback: const <String>[
        'Consolas',
        'Menlo',
        'DejaVu Sans Mono',
        'monospace',
      ],
      fontSize: 14,
      height: 22 / 14,
      color: scheme.onSurface,
    );
  }
}
