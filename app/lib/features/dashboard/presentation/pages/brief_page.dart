import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/result/result.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/mettle/buttons.dart';
import '../../../../core/widgets/mettle_snack_bar.dart';
import '../../../interview/domain/entities/difficulty.dart';
import '../../../interview/domain/entities/interview_topic.dart';
import '../../../interview/domain/entities/session_config.dart';
import '../../../interview/domain/usecases/start_session.dart';
import '../../domain/entities/user_summary.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../cubit/interview_setup_cubit.dart';
import '../widgets/brief_blocks.dart';
import '../widgets/brief_top_bar.dart';

class BriefPage extends StatelessWidget {
  const BriefPage({required this.setup, super.key});

  static const contentMaxWidth = 760.0;

  final InterviewSetup setup;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<DashboardCubit>()..load(),
      child: BriefView(setup: setup),
    );
  }
}

class BriefView extends StatefulWidget {
  const BriefView({required this.setup, super.key});

  final InterviewSetup setup;

  @override
  State<BriefView> createState() => _BriefViewState();
}

class _BriefViewState extends State<BriefView> {
  bool _starting = false;

  void _back() => context.go(AppRoutes.dashboard);

  Future<void> _start() async {
    if (_starting) return;
    setState(() => _starting = true);

    final router = GoRouter.of(context);
    final topic = _topic();

    final result = await sl<StartSession>()(
      SessionConfig(topic: topic, questionCount: widget.setup.effectiveCount),
    );

    if (!mounted) return;
    setState(() => _starting = false);

    switch (result) {
      case Success(:final data):
        await router.pushNamed(
          AppRoutes.sessionName,
          pathParameters: {AppRoutes.idParam: data},
        );
      case Failed():
        showMettleSnackBar(context, AppStrings.briefFailed);
    }
  }

  InterviewTopic _topic() {
    final id = widget.setup.topicId;
    if (id != null) return InterviewTopic.fromId(id);

    final forLevel = InterviewTopic.forDifficulty(
      Difficulty.fromId(widget.setup.level.id),
    );
    return forLevel.isEmpty ? InterviewTopic.fallback : forLevel.first;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizeClass = context.sizeClass;
    final compact = sizeClass.isCompact;

    return Scaffold(
      backgroundColor: colors.bgPage,
      body: Column(
        children: [
          BriefTopBar(onBack: _back),
          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                final summary = state is DashboardLoaded
                    ? state.summary
                    : const UserSummary.empty();

                return SingleChildScrollView(
                  padding: compact
                      ? const EdgeInsets.fromLTRB(
                          MettleSpace.s4,
                          MettleSpace.s6,
                          MettleSpace.s4,
                          MettleSpace.s6,
                        )
                      : EdgeInsets.fromLTRB(
                          sizeClass.isExpanded
                              ? MettleSpace.s10
                              : MettleSpace.s6,
                          MettleSpace.s12,
                          sizeClass.isExpanded
                              ? MettleSpace.s10
                              : MettleSpace.s6,
                          MettleSpace.s16,
                        ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: BriefPage.contentMaxWidth,
                      ),
                      child: _Blocks(
                        setup: widget.setup,
                        summary: summary,
                        starting: _starting,
                        onStart: _start,
                        onChange: _back,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: compact
          ? BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) => _ActionBar(
                starting: _starting,
                onStart: _start,
                onChange: _back,
              ),
            )
          : null,
    );
  }
}

class _Blocks extends StatelessWidget {
  const _Blocks({
    required this.setup,
    required this.summary,
    required this.starting,
    required this.onStart,
    required this.onChange,
  });

  final InterviewSetup setup;
  final UserSummary summary;
  final bool starting;
  final VoidCallback onStart;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final compact = context.sizeClass.isCompact;
    final gap = compact ? MettleSpace.s5 : MettleSpace.s7;

    final topic = summary.topics
        .where((t) => t.id == setup.topicId)
        .firstOrNull;
    final subject = setup.isQuickCheck
        ? AppStrings.startModeQuick
        : topic?.name ?? AppStrings.startModeQuick;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BriefIntro(
          subject: subject,
          level: setup.level.label,
          questions: setup.effectiveCount,
          minutes: setup.minutes,
          mixedTopics: setup.isQuickCheck,
        ),
        SizedBox(height: gap),
        const BriefExpectCard(),
        if (summary.plan == Plan.free) ...[
          SizedBox(height: gap),
          BriefCreditNotice(
            remaining: summary.freeRemaining,
            total: summary.freeTotal,
          ),
        ],
        if (!compact) ...[
          SizedBox(height: gap),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: MettleSpace.s3,
            runSpacing: MettleSpace.s3,
            children: [
              SecondaryButton(
                label: AppStrings.briefChange,
                onPressed: starting ? null : onChange,
              ),
              PrimaryButton(
                label: AppStrings.briefStart,
                leadingIcon: Icons.play_arrow_rounded,
                busy: starting,
                onPressed: onStart,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.starting,
    required this.onStart,
    required this.onChange,
  });

  final bool starting;
  final VoidCallback onStart;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        MettleSpace.s4,
        MettleSpace.s3,
        MettleSpace.s4,
        MettleSpace.s3,
      ),
      decoration: BoxDecoration(
        color: colors.bgSidebar,
        border: Border(
          top: BorderSide(
            color: colors.borderSubtle,
            width: MettleSpace.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(
              label: AppStrings.briefStart,
              leadingIcon: Icons.play_arrow_rounded,
              fullWidth: true,
              busy: starting,
              onPressed: onStart,
            ),
            const SizedBox(height: MettleSpace.s2),
            SecondaryButton(
              label: AppStrings.briefChange,
              size: ButtonSize.medium,
              fullWidth: true,
              onPressed: starting ? null : onChange,
            ),
          ],
        ),
      ),
    );
  }
}
