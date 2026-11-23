import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/mettle/buttons.dart';
import '../../../../core/widgets/shell/free_plan_card.dart';
import '../../domain/entities/user_summary.dart';
import '../cubit/interview_setup_cubit.dart';
import 'how_it_works_card.dart';
import 'side_cards.dart';
import 'start_interview_card.dart';

class FirstVisitView extends StatelessWidget {
  const FirstVisitView({
    required this.summary,
    required this.setup,
    required this.howItWorksDismissed,
    required this.onDismissHowItWorks,
    required this.onReopenHowItWorks,
    required this.onContinue,
    super.key,
  });

  final UserSummary summary;
  final InterviewSetup setup;
  final bool howItWorksDismissed;
  final VoidCallback onDismissHowItWorks;
  final VoidCallback onReopenHowItWorks;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.sizeClass;
    final gap = context.sectionGap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = context.pagePadding;
        final contentWidth = constraints.maxWidth - padding.horizontal;
        final twoColumn = contentWidth >= MettleSpace.twoColumnMinWidth;

        final start = StartInterviewCard(
          summary: summary,
          setup: setup,
          onContinue: onContinue,
        );
        const side = [ReadinessEmptyCard(), HowScoredCard()];

        return SingleChildScrollView(
          padding: padding.copyWith(
            bottom:
                padding.bottom + (sizeClass.hasStickyCta ? MettleSpace.s6 : 0),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: MettleSpace.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    firstName: summary.firstName,
                    showReopen: howItWorksDismissed,
                    onReopen: onReopenHowItWorks,
                  ),
                  if (!howItWorksDismissed) ...[
                    SizedBox(height: gap),
                    HowItWorksCard(onDismiss: onDismissHowItWorks),
                  ],
                  SizedBox(height: gap),
                  if (twoColumn)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: start),
                        const SizedBox(width: MettleSpace.s6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              side.first,
                              const SizedBox(height: MettleSpace.s6),
                              side.last,
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    start,
                    SizedBox(height: gap),
                    side.first,
                    SizedBox(height: gap),
                    side.last,
                    if (!sizeClass.hasSidebar) ...[
                      SizedBox(height: gap),
                      FreePlanCard(
                        remaining: summary.freeRemaining,
                        total: summary.freeTotal,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.firstName,
    required this.showReopen,
    required this.onReopen,
  });

  static const subtitleMaxWidth = 640.0;

  final String firstName;
  final bool showReopen;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final styles = context.text;
    final compact = context.sizeClass.isCompact;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          firstName.isEmpty
              ? AppStrings.dashWelcome
              : AppStrings.dashWelcomeNamed(firstName),
          style: styles.display,
        ),
        const SizedBox(height: MettleSpace.s2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: subtitleMaxWidth),
          child: Text(AppStrings.dashSubtitle, style: styles.bodyLarge),
        ),
        if (showReopen && compact) ...[
          const SizedBox(height: MettleSpace.s2),
          TextLink(label: AppStrings.dashHowItWorksOpen, onTap: onReopen),
        ],
      ],
    );

    if (!showReopen || compact) return title;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: MettleSpace.s4,
      runSpacing: MettleSpace.s4,
      children: [
        title,
        SmallButton(label: AppStrings.dashHowItWorksOpen, onPressed: onReopen),
      ],
    );
  }
}
