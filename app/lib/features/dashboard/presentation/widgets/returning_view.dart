import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/shell/free_plan_card.dart';
import '../../domain/entities/user_summary.dart';
import '../cubit/interview_setup_cubit.dart';
import 'limit_cards.dart';
import 'recent_interviews_card.dart';
import 'recommended_card.dart';
import 'setup_own_card.dart';

class ReturningView extends StatefulWidget {
  const ReturningView({
    required this.summary,
    required this.setup,
    required this.onPractise,
    required this.onContinue,
    required this.onOpenInterview,
    required this.onViewAll,
    required this.onUpgrade,
    required this.onInvite,
    required this.onSeeProgress,
    super.key,
  });

  final UserSummary summary;
  final InterviewSetup setup;
  final ValueChanged<Recommendation> onPractise;
  final VoidCallback? onContinue;
  final ValueChanged<InterviewSummary> onOpenInterview;
  final VoidCallback onViewAll;
  final VoidCallback onUpgrade;
  final VoidCallback onInvite;
  final VoidCallback onSeeProgress;

  @override
  State<ReturningView> createState() => _ReturningViewState();
}

class _ReturningViewState extends State<ReturningView> {
  final _setupKey = GlobalKey();

  Future<void> _scrollToSetup() async {
    final target = _setupKey.currentContext;
    if (target == null) return;

    await Scrollable.ensureVisible(
      target,
      duration: context.motion(MettleMotion.expand),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final exhausted = summary.plan == Plan.free && summary.isExhausted;
    final sizeClass = context.sizeClass;
    final gap = context.sectionGap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = context.pagePadding;
        final twoColumn =
            constraints.maxWidth - padding.horizontal >=
            MettleSpace.twoColumnMinWidth;

        return SingleChildScrollView(
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: MettleSpace.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(summary: summary, exhausted: exhausted),
                  SizedBox(height: gap),
                  if (twoColumn)
                    ..._twoColumn(exhausted, gap)
                  else
                    ..._stacked(exhausted, gap, sizeClass),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _twoColumn(bool exhausted, double gap) => [
    IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 2, child: _primaryCard(exhausted)),
          const SizedBox(width: MettleSpace.s6),
          Expanded(child: _sideCard(exhausted)),
        ],
      ),
    ),
    SizedBox(height: gap),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _setupCard(exhausted)),
        const SizedBox(width: MettleSpace.s6),
        Expanded(child: _recentCard(exhausted)),
      ],
    ),
  ];

  List<Widget> _stacked(bool exhausted, double gap, SizeClass sizeClass) => [
    _primaryCard(exhausted),
    SizedBox(height: gap),
    _sideCard(exhausted),
    SizedBox(height: gap),
    if (exhausted) ...[
      _recentCard(exhausted),
      SizedBox(height: gap),
      _setupCard(exhausted),
    ] else ...[
      _setupCard(exhausted),
      SizedBox(height: gap),
      _recentCard(exhausted),
      if (!sizeClass.hasSidebar && widget.summary.plan == Plan.free) ...[
        SizedBox(height: gap),
        FreePlanCard(
          remaining: widget.summary.freeRemaining,
          total: widget.summary.freeTotal,
        ),
      ],
    ],
  ];

  Widget _primaryCard(bool exhausted) => exhausted
      ? ProgressSummaryCard(
          summary: widget.summary,
          onSeeProgress: widget.onSeeProgress,
        )
      : RecommendedCard(
          summary: widget.summary,
          onPractise: widget.onPractise,
          onChooseElse: _scrollToSetup,
        );

  Widget _sideCard(bool exhausted) => exhausted
      ? ProOfferCard(
          summary: widget.summary,
          onUpgrade: widget.onUpgrade,
          onInvite: widget.onInvite,
        )
      : ReadinessScoreCard(summary: widget.summary);

  Widget _setupCard(bool exhausted) => exhausted
      ? const LockedSetupCard()
      : Container(
          key: _setupKey,
          child: SetupOwnCard(
            summary: widget.summary,
            setup: widget.setup,
            onContinue: widget.onContinue,
          ),
        );

  Widget _recentCard(bool exhausted) => RecentInterviewsCard(
    summary: widget.summary,
    onOpen: widget.onOpenInterview,
    onViewAll: widget.onViewAll,
    showTrendNote: !exhausted,
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.summary, required this.exhausted});

  final UserSummary summary;
  final bool exhausted;

  @override
  Widget build(BuildContext context) {
    final styles = context.text;
    final onlyQuickCheck =
        summary.completedInterviews == 1 &&
        summary.recent.isNotEmpty &&
        summary.recent.first.title.startsWith(AppStrings.startModeQuick);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exhausted
              ? AppStrings.limitHeadline(summary.firstName, summary.freeTotal)
              : AppStrings.dashWelcomeBack(summary.firstName),
          style: styles.display,
        ),
        const SizedBox(height: MettleSpace.s2),
        Text(switch (true) {
          _ when exhausted => AppStrings.limitSubtitle,
          _ when onlyQuickCheck => AppStrings.dashBackSubtitleQuick,
          _ => AppStrings.dashBackSubtitle,
        }, style: styles.bodyLarge),
      ],
    );
  }
}
