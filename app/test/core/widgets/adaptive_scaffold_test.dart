import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mettle/core/constants/app_dimens.dart';
import 'package:mettle/core/theme/app_theme.dart';
import 'package:mettle/core/widgets/adaptive_scaffold.dart';

void main() {
  const destinations = <AdaptiveDestination>[
    AdaptiveDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    AdaptiveDestination(
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Progress',
    ),
  ];

  Future<void> pumpAt(
    WidgetTester tester,
    Size size, {
    int selected = 0,
  }) async {
    tester.view.physicalSize = size * tester.view.devicePixelRatio;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AdaptiveScaffold(
          destinations: destinations,
          selectedIndex: selected,
          onDestinationSelected: (_) {},
          body: const Center(child: Text('body')),
        ),
      ),
    );
  }

  group('AdaptiveScaffold', () {
    testWidgets('uses bottom navigation below the expanded breakpoint', (
      tester,
    ) async {
      await pumpAt(tester, const Size(420, 900));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('uses a navigation rail at the expanded breakpoint', (
      tester,
    ) async {
      await pumpAt(tester, const Size(AppDimens.breakpointExpanded, 900));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('renders the body in both layouts', (tester) async {
      await pumpAt(tester, const Size(420, 900));
      expect(find.text('body'), findsOneWidget);

      await pumpAt(tester, const Size(1200, 900));
      expect(find.text('body'), findsOneWidget);
    });

    testWidgets('reports taps with the destination index', (tester) async {
      final taps = <int>[];
      tester.view.physicalSize =
          const Size(420, 900) * tester.view.devicePixelRatio;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: AdaptiveScaffold(
            destinations: destinations,
            selectedIndex: 0,
            onDestinationSelected: taps.add,
            body: const SizedBox.shrink(),
          ),
        ),
      );

      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      expect(taps, [1]);
    });
  });
}
