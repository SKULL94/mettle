import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/widgets/mettle/buttons.dart';
import '../../../../core/widgets/shell/app_scaffold.dart';
import '../../../../core/widgets/shell/shell_host.dart';
import '../../../pro/presentation/pages/pro_page.dart';
import '../../../../core/widgets/shell/shell_destination.dart';
import '../../domain/entities/user_summary.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../cubit/interview_setup_cubit.dart';
import '../widgets/first_visit_view.dart';
import '../widgets/returning_view.dart';
import '../widgets/start_interview_card.dart';
import '../widgets/sticky_cta_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<DashboardCubit>()..load()),
        BlocProvider(create: (_) => InterviewSetupCubit()),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late bool _howItWorksDismissed = sl<AppPreferences>().howItWorksDismissed();

  Future<void> _setHowItWorks(bool dismissed) async {
    setState(() => _howItWorksDismissed = dismissed);
    await sl<AppPreferences>().setHowItWorksDismissed(dismissed);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) => switch (state) {
        DashboardLoading() => const _Busy(),
        DashboardError(:final message) => _Failed(message: message),
        DashboardLoaded(:final summary) => _Loaded(
          summary: summary,
          howItWorksDismissed: _howItWorksDismissed,
          onHowItWorks: _setHowItWorks,
        ),
      },
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.summary,
    required this.howItWorksDismissed,
    required this.onHowItWorks,
  });

  final UserSummary summary;
  final bool howItWorksDismissed;
  final ValueChanged<bool> onHowItWorks;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InterviewSetupCubit, InterviewSetup>(
      builder: (context, setup) {
        final canContinue = setup.canContinue && !summary.isExhausted;
        final next = summary.next;
        final followRecommendation =
            !summary.isFirstVisit &&
            !summary.isExhausted &&
            setup.topicId == null &&
            next != null;

        return AppScaffold(
          tab: ShellTab.dashboard,
          state: shellStateFor(summary),
          onSelect: (destination) => context.go(destination.path),
          onAccount: (action) => onAccountAction(context, action),
          onSeePlans: () => openPro(context),
          onUpgrade: () => openPro(context),
          bottomBar: context.sizeClass.hasStickyCta && !summary.isExhausted
              ? StickyCtaBar(
                  summaryLine: followRecommendation
                      ? '${next.topicName} · '
                            '${AppStrings.briefQuestions(next.questionCount)} '
                            '· ${AppStrings.briefAbout(next.minutes)}'
                      : summaryLine(context, summary, setup),
                  freeRemaining: summary.freeRemaining,
                  label: followRecommendation
                      ? AppStrings.recPractise(next.topicName)
                      : null,
                  onContinue: followRecommendation
                      ? () => _practise(context, next)
                      : canContinue
                      ? () => _toBrief(context, setup)
                      : null,
                )
              : null,
          body: summary.isFirstVisit
              ? FirstVisitView(
                  summary: summary,
                  setup: setup,
                  howItWorksDismissed: howItWorksDismissed,
                  onDismissHowItWorks: () => onHowItWorks(true),
                  onReopenHowItWorks: () => onHowItWorks(false),
                  onContinue: canContinue
                      ? () => _toBrief(context, setup)
                      : null,
                )
              : ReturningView(
                  summary: summary,
                  setup: setup,
                  onPractise: (item) => _practise(context, item),
                  onContinue: canContinue
                      ? () => _toBrief(context, setup)
                      : null,
                  onOpenInterview: (item) => context.pushNamed(
                    AppRoutes.scorecardName,
                    pathParameters: {AppRoutes.idParam: item.sessionId},
                  ),
                  onViewAll: () => context.go(AppRoutes.history),
                  onUpgrade: () => openPro(context),
                  onInvite: () => openPro(context),
                  onSeeProgress: () => context.go(AppRoutes.progress),
                ),
        );
      },
    );
  }
}

void _practise(BuildContext context, Recommendation next) {
  _toBrief(
    context,
    InterviewSetup(
      mode: InterviewMode.topic,
      level: next.level,
      topicId: next.topicId,
      questionCount: next.questionCount,
    ),
  );
}

void _toBrief(BuildContext context, InterviewSetup setup) {
  context.go(
    Uri(
      path: AppRoutes.brief,
      queryParameters: <String, String>{
        AppRoutes.modeParam: setup.isQuickCheck ? 'quick' : 'topic',
        AppRoutes.levelParam: setup.level.id,
        if (setup.topicId != null) AppRoutes.topicParam: setup.topicId!,
        AppRoutes.countParam: '${setup.questionCount}',
      },
    ).toString(),
  );
}

class _Busy extends StatelessWidget {
  const _Busy();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgPage,
      body: Center(child: CircularProgressIndicator(color: colors.accent)),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgPage,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: AppStrings.retry,
                onPressed: () => context.read<DashboardCubit>().load(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
