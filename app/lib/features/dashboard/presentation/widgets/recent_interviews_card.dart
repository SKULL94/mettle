import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/mettle/buttons.dart';
import '../../../../core/widgets/mettle/focus_ring.dart';
import '../../../../core/widgets/mettle/pills.dart';
import '../../../../core/widgets/mettle/surface_card.dart';
import '../../domain/entities/user_summary.dart';

String interviewDateLabel(DateTime? when) {
  if (when == null) return '';

  final today = DateUtils.dateOnly(DateTime.now());
  final days = today.difference(DateUtils.dateOnly(when)).inDays;

  return switch (days) {
    <= 0 => AppStrings.today,
    1 => AppStrings.yesterday,
    _ => '${when.day} ${AppStrings.monthsShort[when.month - 1]}',
  };
}

ReadinessBand bandOf(int score) {
  if (score < 40) return ReadinessBand.needsWork;
  if (score < 70) return ReadinessBand.developing;
  return ReadinessBand.interviewReady;
}

String bandWordOf(ReadinessBand band) => switch (band) {
  ReadinessBand.needsWork => AppStrings.statusNeedsWork,
  ReadinessBand.developing => AppStrings.statusDeveloping,
  ReadinessBand.interviewReady => AppStrings.bandReadyWord,
};

class RecentInterviewsCard extends StatelessWidget {
  const RecentInterviewsCard({
    required this.summary,
    required this.onOpen,
    required this.onViewAll,
    this.showTrendNote = true,
    super.key,
  });

  final UserSummary summary;
  final ValueChanged<InterviewSummary> onOpen;
  final VoidCallback onViewAll;
  final bool showTrendNote;

  @override
  Widget build(BuildContext context) {
    final styles = context.text;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: CardTitle(text: AppStrings.recentTitle)),
              const SizedBox(width: MettleSpace.s3),
              TextLink(label: AppStrings.recentViewAll, onTap: onViewAll),
            ],
          ),
          const SizedBox(height: MettleSpace.s3),
          for (final (index, item) in summary.recent.indexed) ...[
            if (index > 0) const SizedBox(height: MettleSpace.s3),
            _Row(item: item, onTap: () => onOpen(item)),
          ],
          if (showTrendNote && summary.completedInterviews == 1) ...[
            const SizedBox(height: MettleSpace.s3),
            Text(
              AppStrings.recentTrendNote,
              style: styles.bodySmall.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.onTap});

  final InterviewSummary item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;
    final score = item.score;
    final band = score == null ? null : bandOf(score);
    final date = interviewDateLabel(item.date);

    return FocusRing(
      radius: MettleSpace.rMd,
      onTap: onTap,
      semanticLabel: AppStrings.recentSemantics(
        item.title,
        date,
        item.questions,
        score ?? 0,
        band == null ? '' : bandWordOf(band),
      ),
      builder: (context, hovered, pressed) {
        return AnimatedContainer(
          duration: context.motion(MettleMotion.fast),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(
            horizontal: MettleSpace.s4,
            vertical: MettleSpace.s3,
          ),
          decoration: BoxDecoration(
            color: pressed ? colors.surfacePressed : colors.surfaceRaised,
            borderRadius: BorderRadius.circular(MettleSpace.rMd),
            border: Border.all(
              color: hovered ? colors.borderStrong : colors.borderDefault,
              width: MettleSpace.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.labelMedium,
                    ),
                    const SizedBox(height: MettleSpace.s1),
                    Text(
                      AppStrings.recentMeta(date, item.questions),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.caption,
                    ),
                  ],
                ),
              ),
              if (score != null) ...[
                const SizedBox(width: MettleSpace.s3),
                Text(
                  '$score',
                  style: TextStyle(
                    fontFamily: MettleText.mono,
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: bandColor(context, band!),
                  ),
                ),
              ],
              const SizedBox(width: MettleSpace.s3),
              Icon(
                Icons.chevron_right_rounded,
                size: MettleSpace.iconCheck,
                color: colors.textTertiary,
              ),
            ],
          ),
        );
      },
    );
  }
}
