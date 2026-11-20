import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/dashboard/domain/entities/user_summary.dart';
import '../../features/dashboard/presentation/cubit/interview_setup_cubit.dart';
import '../../features/dashboard/presentation/pages/brief_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/interview/presentation/pages/interview_page.dart';
import '../../features/interview/presentation/pages/scorecard_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../widgets/not_found_view.dart';
import '../widgets/shell/shell_destination.dart';
import '../widgets/shell/shell_host.dart';
import 'app_routes.dart';

InterviewSetup _setupFrom(Map<String, String> query) {
  final mode = query[AppRoutes.modeParam] == 'topic'
      ? InterviewMode.topic
      : InterviewMode.quickCheck;
  final count = int.tryParse(query[AppRoutes.countParam] ?? '');

  return InterviewSetup(
    mode: mode,
    level: Level.fromId(query[AppRoutes.levelParam] ?? ''),
    topicId: mode == InterviewMode.topic ? query[AppRoutes.topicParam] : null,
    questionCount: questionCounts.contains(count) ? count! : 5,
  );
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => AppRoutes.dashboard),
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: AppRoutes.signInName,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboardName,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.progress,
        name: AppRoutes.progressName,
        builder: (context, state) =>
            const ShellHost(tab: ShellTab.progress, child: ProgressPage()),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: AppRoutes.historyName,
        builder: (context, state) =>
            const ShellHost(tab: ShellTab.history, child: HistoryPage()),
      ),
      GoRoute(
        path: AppRoutes.brief,
        name: AppRoutes.briefName,
        builder: (context, state) =>
            BriefPage(setup: _setupFrom(state.uri.queryParameters)),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settingsName,
        builder: (context, state) => const SettingsPage(),
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
