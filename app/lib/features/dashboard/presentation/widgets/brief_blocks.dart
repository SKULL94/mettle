import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/widgets/mettle/pills.dart';
import '../../../../core/widgets/mettle/surface_card.dart';

typedef _Expect = ({IconData icon, String title, String body});

const _expectations = <_Expect>[
  (
    icon: Icons.chat_bubble_outline_rounded,
    title: AppStrings.briefExpect1Title,
    body: AppStrings.briefExpect1Body,
  ),
  (
    icon: Icons.schedule_rounded,
    title: AppStrings.briefExpect2Title,
    body: AppStrings.briefExpect2Body,
  ),
  (
    icon: Icons.skip_next_rounded,
    title: AppStrings.briefExpect3Title,
    body: AppStrings.briefExpect3Body,
  ),
  (
    icon: Icons.description_outlined,
    title: AppStrings.briefExpect4Title,
    body: AppStrings.briefExpect4Body,
  ),
];

class BriefIntro extends StatelessWidget {
  const BriefIntro({
    required this.subject,
    required this.level,
    required this.questions,
    required this.minutes,
    required this.mixedTopics,
    super.key,
  });

  final String subject;
  final String level;
  final int questions;
  final int minutes;
  final bool mixedTopics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.briefOverline,
          style: TextStyle(
            fontFamily: MettleText.mono,
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            color: colors.accentText,
          ),
        ),
        const SizedBox(height: MettleSpace.s2),
        Text(AppStrings.briefTitle(subject, level), style: styles.display),
        const SizedBox(height: MettleSpace.s3),
        Wrap(
          spacing: MettleSpace.s2,
          runSpacing: MettleSpace.s2,
          children: [
            MetaPill(label: AppStrings.briefQuestions(questions)),
            MetaPill(label: AppStrings.briefAbout(minutes)),
            if (mixedTopics) const MetaPill(label: AppStrings.briefMixedTopics),
          ],
        ),
      ],
    );
  }
}

class BriefExpectCard extends StatelessWidget {
  const BriefExpectCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(text: AppStrings.briefExpectTitle),
          const SizedBox(height: MettleSpace.s4),
          for (final (index, item) in _expectations.indexed) ...[
            if (index > 0) const SizedBox(height: MettleSpace.s4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    item.icon,
                    size: MettleSpace.iconInfo,
                    color: colors.accentText,
                  ),
                ),
                const SizedBox(width: MettleSpace.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: styles.labelLarge),
                      const SizedBox(height: MettleSpace.s1),
                      Text(item.body, style: styles.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class BriefCreditNotice extends StatelessWidget {
  const BriefCreditNotice({
    required this.remaining,
    required this.total,
    super.key,
  });

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;
    final lastOne = remaining <= 1;
    final used = (total - remaining).clamp(0, total);

    return Container(
      padding: const EdgeInsets.all(MettleSpace.s4),
      decoration: BoxDecoration(
        color: colors.accentTint8,
        borderRadius: BorderRadius.circular(MettleSpace.rMd),
        border: Border.all(
          color: colors.accentBorder28,
          width: MettleSpace.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: MettleSpace.pip),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < total; index++) ...[
                  if (index > 0) const SizedBox(width: MettleSpace.s1),
                  Container(
                    width: 14,
                    height: MettleSpace.pip,
                    decoration: BoxDecoration(
                      color: index >= used
                          ? colors.accent
                          : colors.borderStrong,
                      borderRadius: BorderRadius.circular(MettleSpace.rPip),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: MettleSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lastOne
                      ? AppStrings.briefLastFreeTitle
                      : AppStrings.briefCreditTitle(remaining),
                  style: styles.labelLarge,
                ),
                const SizedBox(height: MettleSpace.s1),
                Text(
                  lastOne
                      ? AppStrings.briefLastFreeBody
                      : AppStrings.briefCreditBody(remaining),
                  style: styles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
