import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/mettle/boxes.dart';
import '../../../../core/widgets/mettle/buttons.dart';

import '../../../../core/widgets/mettle/pills.dart';
import '../../../../core/widgets/mettle/segmented_tabs.dart';
import '../../../../core/widgets/mettle/surface_card.dart';
import '../../domain/entities/user_summary.dart';
import '../cubit/interview_setup_cubit.dart';
import 'option_grid.dart';
import 'pro_sheet.dart';

class StartInterviewCard extends StatelessWidget {
  const StartInterviewCard({
    required this.summary,
    required this.setup,
    required this.onContinue,
    super.key,
  });

  final UserSummary summary;
  final InterviewSetup setup;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final styles = context.text;
    final compact = context.sizeClass.isCompact;
    final gap = compact ? MettleSpace.s5 : MettleSpace.s6;
    final cubit = context.read<InterviewSetupCubit>();
    final topics = summary.topicsFor(setup.level);

    return SurfaceCard(
      padding: EdgeInsets.all(context.startCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(text: AppStrings.startTitle, large: true),
          const SizedBox(height: MettleSpace.s2),
          Text(
            AppStrings.startSubtitle(summary.freeRemaining),
            style: styles.bodyMedium,
          ),
          SizedBox(height: gap),
          LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 2;
              final badgeInTab = tabWidth >= SegmentedTabs.badgeMinWidth;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedTabs(
                    selected: setup.isQuickCheck ? 0 : 1,
                    onSelected: (index) => cubit.setMode(
                      index == 0
                          ? InterviewMode.quickCheck
                          : InterviewMode.topic,
                    ),
                    options: const [
                      SegmentedOption(
                        label: AppStrings.startModeQuick,
                        badge: AppStrings.startRecommended,
                      ),
                      SegmentedOption(label: AppStrings.startModeTopic),
                    ],
                  ),
                  if (setup.isQuickCheck) ...[
                    SizedBox(height: gap),
                    if (!badgeInTab) ...[
                      const RecommendedBadge(
                        label: AppStrings.startRecommended,
                      ),
                      const SizedBox(height: MettleSpace.s2),
                    ],
                    InfoBox(
                      icon: Icons.track_changes_rounded,
                      title: AppStrings.startQuickInfoTitle,
                      body: AppStrings.startQuickInfoBody(
                        summary.freeRemaining - 1,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          SizedBox(height: gap),
          _Field(
            label: AppStrings.startLevelLabel,
            child: LevelGrid(selected: setup.level, onSelected: cubit.setLevel),
          ),
          AnimatedSize(
            duration: context.motion(MettleMotion.expand),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: setup.isQuickCheck
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: gap),
                      _Field(
                        label: AppStrings.startTopicLabel,
                        child: TopicGrid(
                          topics: topics,
                          selected: setup.topicId,
                          onSelected: cubit.setTopic,
                        ),
                      ),
                      SizedBox(height: gap),
                      _Field(
                        label: AppStrings.startCountLabel,
                        child: CountGrid(
                          selected: setup.questionCount,
                          onSelected: cubit.setQuestionCount,
                          onLocked: () => showProSheet(context),
                        ),
                      ),
                    ],
                  ),
          ),
          if (!compact) ...[
            SizedBox(height: gap),
            _Footer(summary: summary, setup: setup, onContinue: onContinue),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.labelMedium),
        const SizedBox(height: MettleSpace.s3),
        child,
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.summary,
    required this.setup,
    required this.onContinue,
  });

  final UserSummary summary;
  final InterviewSetup setup;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;
    final enabled = setup.canContinue && onContinue != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          height: MettleSpace.border,
          thickness: MettleSpace.border,
          color: colors.borderSubtle,
        ),
        const SizedBox(height: MettleSpace.s5),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: MettleSpace.s4,
          spacing: MettleSpace.s4,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  summaryLine(context, summary, setup),
                  style: styles.labelMedium,
                ),
                const SizedBox(height: MettleSpace.s1),
                Text(
                  AppStrings.startUses(summary.freeRemaining),
                  style: styles.caption,
                ),
              ],
            ),
            PrimaryButton(
              label: enabled
                  ? AppStrings.startContinue
                  : AppStrings.startContinueDisabled,
              trailingIcon: enabled ? Icons.arrow_forward_rounded : null,
              onPressed: enabled ? onContinue : null,
            ),
          ],
        ),
      ],
    );
  }
}

String summaryLine(
  BuildContext context,
  UserSummary summary,
  InterviewSetup setup,
) {
  if (setup.isQuickCheck) {
    return AppStrings.startSummaryQuick(setup.level.label);
  }

  final topicId = setup.topicId;
  if (topicId == null) return AppStrings.startNoTopic;

  final topic = summary.topics.where((t) => t.id == topicId).firstOrNull;
  if (topic == null) return AppStrings.startNoTopic;

  return AppStrings.startSummaryTopic(
    topic.name,
    setup.level.label,
    setup.questionCount,
    setup.minutes,
  );
}
