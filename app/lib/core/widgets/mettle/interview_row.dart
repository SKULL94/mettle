import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';
import '../../theme/size_class.dart';
import '../../../features/dashboard/domain/entities/user_summary.dart';
import 'focus_ring.dart';
import 'pills.dart';

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

class InterviewRow extends StatelessWidget {
  const InterviewRow({
    required this.title,
    required this.questions,
    required this.onTap,
    this.date,
    this.score,
    super.key,
  });

  final String title;
  final int questions;
  final VoidCallback onTap;
  final DateTime? date;
  final int? score;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;
    final value = score;
    final band = value == null ? null : bandOf(value);
    final label = interviewDateLabel(date);

    return FocusRing(
      radius: MettleSpace.rMd,
      onTap: onTap,
      semanticLabel: AppStrings.recentSemantics(
        title,
        label,
        questions,
        value ?? 0,
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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.labelMedium,
                    ),
                    const SizedBox(height: MettleSpace.s1),
                    Text(
                      AppStrings.recentMeta(label, questions),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.caption,
                    ),
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: MettleSpace.s3),
                Text(
                  '$value',
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
