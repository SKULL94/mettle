import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mettle/core/constants/app_strings.dart';
import 'package:mettle/core/di/injection.dart';
import 'package:mettle/core/router/app_router.dart';
import 'package:mettle/core/router/app_routes.dart';
import 'package:mettle/core/theme/app_theme.dart';
import 'package:mettle/core/widgets/not_found_view.dart';
import 'package:mettle/features/home/presentation/pages/home_page.dart';
import 'package:mettle/features/interview/presentation/pages/interview_page.dart';
import 'package:mettle/features/settings/presentation/pages/settings_page.dart';
import 'package:mettle/features/splash/presentation/pages/splash_page.dart';
import 'package:mettle/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await resetDependencies();

    await configureDependencies();
  });

  tearDown(resetDependencies);

  Future<GoRouter> pumpAt(WidgetTester tester, String location) async {
    final router = createRouter();
    router.go(location);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    return router;
  }

  group('app bootstrap', () {
    testWidgets('starts on splash and lands on home', (tester) async {
      await tester.pumpWidget(const MettleApp());

      expect(find.byType(SplashPage), findsOneWidget);
      expect(find.text(AppStrings.appName), findsWidgets);

      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('splash leaves the stack, so back from home exits', (
      tester,
    ) async {
      await tester.pumpWidget(const MettleApp());
      await tester.pumpAndSettle();

      final router = tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .widget;
      expect(router, isNotNull);
      expect(find.byType(SplashPage), findsNothing);
    });
  });

  group('routing', () {
    testWidgets('resolves the shell tabs', (tester) async {
      await pumpAt(tester, AppRoutes.home);
      expect(find.byType(HomePage), findsOneWidget);

      await pumpAt(tester, AppRoutes.settings);
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('shell tabs show navigation chrome', (tester) async {
      await pumpAt(tester, AppRoutes.home);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('interview is pushed above the shell with no tab bar', (
      tester,
    ) async {
      await pumpAt(tester, '/session/abc123');

      expect(find.byType(InterviewPage), findsOneWidget);

      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('session id reaches the page from the path', (tester) async {
      await pumpAt(tester, '/session/abc123');

      final page = tester.widget<InterviewPage>(find.byType(InterviewPage));
      expect(page.sessionId, 'abc123');
    });

    testWidgets('unknown route renders the not-found view', (tester) async {
      await pumpAt(tester, '/does-not-exist');
      expect(find.byType(NotFoundView), findsOneWidget);
    });

    testWidgets('not-found offers a way back home', (tester) async {
      await pumpAt(tester, '/does-not-exist');

      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
