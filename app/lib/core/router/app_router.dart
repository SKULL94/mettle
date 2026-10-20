import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/interview/presentation/pages/interview_page.dart';
import '../../features/interview/presentation/pages/scorecard_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../constants/app_strings.dart';
import '../widgets/adaptive_scaffold.dart';
import '../widgets/not_found_view.dart';
import 'app_routes.dart';

const _destinations = <AdaptiveDestination>[
  AdaptiveDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: AppStrings.navHome,
  ),
  AdaptiveDestination(
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights,
    label: AppStrings.navProgress,
  ),
  AdaptiveDestination(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: AppStrings.navSettings,
  ),
];

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashPage(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveScaffold(
            destinations: _destinations,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,

              initialLocation: index == navigationShell.currentIndex,
            ),
            body: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.homeName,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                name: AppRoutes.progressName,
                builder: (context, state) => const ProgressPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: AppRoutes.settingsName,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.session,
        name: AppRoutes.sessionName,
        builder: (context, state) =>
            InterviewPage(sessionId: state.pathParameters[AppRoutes.idParam]!),
        routes: [
          GoRoute(
            path: 'result',
            name: AppRoutes.scorecardName,
            builder: (context, state) => ScorecardPage(
              sessionId: state.pathParameters[AppRoutes.idParam]!,
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundView(),
  );
}
