import 'package:flutter/material.dart';

/// Raw palette. Feeds [ThemeData] only — widgets read
/// `Theme.of(context).colorScheme` and the `ScoreColors` theme extension, never
/// this class directly. That indirection is what makes dark mode work without
/// touching a single widget.
abstract final class AppColors {
  // ── Accent ───────────────────────────────────────────────
  /// Soft violet. Deliberately not default Material indigo.
  static const accentDark = Color(0xFF9D8DF1);
  static const onAccentDark = Color(0xFF16111F);
  static const accentLight = Color(0xFF6D5AE0);
  static const onAccentLight = Color(0xFFFFFFFF);

  // ── Dark surfaces (the design origin) ────────────────────
  static const bgDark = Color(0xFF0E0E11);
  static const surfaceDark = Color(0xFF17171C);
  static const surfaceElevatedDark = Color(0xFF1F1F26);
  static const outlineDark = Color(0xFF2E2E38);
  static const textPrimaryDark = Color(0xFFEDEDF2);
  static const textSecondaryDark = Color(0xFF9A9AA8);
  static const textMutedDark = Color(0xFF6B6B78);

  // ── Light surfaces ───────────────────────────────────────
  static const bgLight = Color(0xFFFAFAFC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceElevatedLight = Color(0xFFF1F1F5);
  static const outlineLight = Color(0xFFDEDEE6);
  static const textPrimaryLight = Color(0xFF16161C);
  static const textSecondaryLight = Color(0xFF5B5B6B);
  static const textMutedLight = Color(0xFF8A8A9A);

  // ── Score semantics ──────────────────────────────────────
  // The only saturated colors in the app. All four sit at the same lightness
  // level so the ramp reads as one scale rather than four unrelated colors.
  static const scoreWeak = Color(0xFFF87171);
  static const scoreDeveloping = Color(0xFFFB923C);
  static const scoreSolid = Color(0xFFFBBF24);
  static const scoreStrong = Color(0xFF34D399);

  static const danger = scoreWeak;
}
