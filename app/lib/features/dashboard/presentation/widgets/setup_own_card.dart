import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/mettle/buttons.dart';
import '../../../../core/widgets/mettle/option_tile.dart';
import '../../../../core/widgets/mettle/pills.dart';
import '../../../../core/widgets/mettle/surface_card.dart';
import '../../domain/entities/user_summary.dart';
import '../cubit/interview_setup_cubit.dart';
import 'option_grid.dart';
import 'pro_sheet.dart';
import 'start_interview_card.dart';

String statusWord(TopicStatus status) => switch (status) {
  TopicStatus.strong => AppStrings.statusStrong,
  TopicStatus.developing => AppStrings.statusDeveloping,
  TopicStatus.needsWork => AppStrings.statusNeedsWork,
  TopicStatus.notTried => AppStrings.statusNotTried,
};

class SetupOwnCard extends StatelessWidget {
  const SetupOwnCard({
    required this.summary,
    required this.setup,
    required this.onContinue,
    super.key,
  });

  static const tileMin = 200.0;

  final UserSummary summary;
  final InterviewSetup setup;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final compact = context.sizeClass.isCompact;
    final cubit = context.read<InterviewSetupCubit>();
    final topics = summary.topicsFor(setup.level);
    final picked = setup.topicId != null;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(text: AppStrings.setupOwnTitle),
          const SizedBox(height: MettleSpace.s4),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = columnsFor(
                width: constraints.maxWidth,
                tileMin: tileMin,
                min: 2,
                max: 4,
              );

              return TileGrid(
                columns: columns,
                tiles: [
                  for (final topic in topics)
                    OptionTile(
                      title: topic.name,
                      selected: topic.id == setup.topicId,
                      onTap: () => cubit.setTopic(topic.id),
                      trailing: null,
                      subtitle: null,
                      statusSlot: StatusLabel(
                        label: statusWord(topic.status),
                        status: topic.status,
                      ),
                      hint: topic.covers,
                    ),
                ],
              );
            },
          ),
          AnimatedSize(
            duration: context.motion(MettleMotion.expand),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !picked
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: MettleSpace.s4),
                      Text(
                        AppStrings.startLevelLabel,
                        style: context.text.labelMedium,
                      ),
                      const SizedBox(height: MettleSpace.s3),
                      LevelGrid(
                        selected: setup.level,
                        onSelected: cubit.setLevel,
                      ),
                      const SizedBox(height: MettleSpace.s4),
                      Text(
                        AppStrings.startCountLabel,
                        style: context.text.labelMedium,
                      ),
                      const SizedBox(height: MettleSpace.s3),
                      CountGrid(
                        selected: setup.questionCount,
                        onSelected: cubit.setQuestionCount,
                        onLocked: () => showProSheet(context),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: MettleSpace.s4),
                        _Footer(
                          summary: summary,
                          setup: setup,
                          onContinue: onContinue,
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
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
    final free = summary.plan == Plan.free;

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
          spacing: MettleSpace.s4,
          runSpacing: MettleSpace.s4,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  summaryLine(context, summary, setup),
                  style: styles.labelMedium,
                ),
                if (free) ...[
                  const SizedBox(height: MettleSpace.s1),
                  Text(
                    AppStrings.startUses(summary.freeRemaining),
                    style: styles.caption,
                  ),
                ],
              ],
            ),
            PrimaryButton(
              label: AppStrings.startContinue,
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: onContinue,
            ),
          ],
        ),
      ],
    );
  }
}
