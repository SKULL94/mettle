import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mettle/core/constants/app_colors.dart';
import 'package:mettle/core/theme/app_theme.dart';
import 'package:mettle/core/theme/score_colors.dart';

void main() {
  group('AppTheme', () {
    test('both brightnesses build and are Material 3', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        expect(theme.useMaterial3, isTrue);
      }
      expect(AppTheme.light().brightness, Brightness.light);
      expect(AppTheme.dark().brightness, Brightness.dark);
    });

    test('registers the ScoreColors extension in both brightnesses', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        expect(theme.extension<ScoreColors>(), isNotNull);
      }
    });

    test('dark theme uses the designed ground, not a seeded surface', () {
      final dark = AppTheme.dark();
      expect(dark.colorScheme.surface, AppColors.bgDark);
      expect(dark.scaffoldBackgroundColor, AppColors.bgDark);
    });

    test('dark theme suppresses shadows; light theme keeps them', () {
      expect(AppTheme.dark().cardTheme.elevation, 0);
      expect(AppTheme.light().cardTheme.elevation, greaterThan(0));
    });

    testWidgets('buttons meet the minimum touch target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: FilledButton(onPressed: () {}, child: const Text('Go')),
          ),
        ),
      );

      final size = tester.getSize(find.byType(FilledButton));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('layout survives 1.3x text scaling', (tester) async {
      tester.view.physicalSize = const Size(400 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            minScaleFactor: 1.3,
            maxScaleFactor: 1.3,
            child: child!,
          ),
          home: Scaffold(
            appBar: AppBar(title: const Text('Mettle')),
            body: FilledButton(onPressed: () {}, child: const Text('Start')),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
