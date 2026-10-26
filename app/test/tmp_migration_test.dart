import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mettle/core/constants/app_strings.dart';
import 'package:mettle/core/di/injection.dart';
import 'package:mettle/features/sessions/presentation/widgets/session_row.dart';
import 'package:mettle/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const legacyPayload = '''
[
  {"id":"seed-1","topic":"state-management","overall_score":58,
   "completed_at":"2026-10-12T18:04:00.000Z","question_count":5},
  {"id":"seed-2","topic":"keys","overall_score":41,
   "completed_at":"2026-10-14T08:11:00.000Z","question_count":3}
]''';

  Future<void> openWith(WidgetTester tester, String? stored) async {
    SharedPreferences.setMockInitialValues(
      stored == null
          ? <String, Object>{}
          : <String, Object>{'sessions': stored},
    );
    await resetDependencies();
    await configureDependencies();

    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MettleApp());
    await tester.pumpAndSettle();
  }

  Future<void> scrollToSessions(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text(AppStrings.lastSession),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  tearDown(resetDependencies);

  testWidgets('discards the legacy summary-only format without erroring', (
    tester,
  ) async {
    await openWith(tester, legacyPayload);

    expect(find.text(AppStrings.cacheError), findsNothing);
    expect(find.text(AppStrings.homeTitle), findsOneWidget);
    expect(find.text(AppStrings.homeEmptyTitle), findsOneWidget);
    expect(find.byType(SessionRow), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(AppStrings.navProgress));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.cacheError), findsNothing);
  });

  testWidgets('recovers from an unreadable payload', (tester) async {
    await openWith(tester, 'not json at all');

    expect(find.text(AppStrings.cacheError), findsNothing);
    expect(find.text(AppStrings.homeEmptyTitle), findsOneWidget);
    expect(find.byType(SessionRow), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recovers from a future schema version', (tester) async {
    await openWith(
      tester,
      jsonEncode(<String, dynamic>{'version': 99, 'sessions': <Object>[]}),
    );

    expect(find.text(AppStrings.cacheError), findsNothing);
    expect(find.text(AppStrings.homeEmptyTitle), findsOneWidget);
    expect(find.byType(SessionRow), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a cleared store stays cleared', (tester) async {
    await openWith(
      tester,
      jsonEncode(<String, dynamic>{'version': 2, 'sessions': <Object>[]}),
    );

    expect(find.text(AppStrings.cacheError), findsNothing);
    expect(find.text(AppStrings.homeEmptyTitle), findsOneWidget);
    expect(find.byType(SessionRow), findsNothing);
  });

  testWidgets('a fresh install starts empty', (tester) async {
    await openWith(tester, null);

    expect(find.text(AppStrings.cacheError), findsNothing);
    expect(find.text(AppStrings.homeEmptyTitle), findsOneWidget);
    expect(find.byType(SessionRow), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
