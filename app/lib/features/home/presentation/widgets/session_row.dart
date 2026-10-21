import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/score_pill.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../interview/domain/entities/interview_topic.dart';
import '../../../interview/presentation/widgets/topic_label.dart';
import '../../domain/entities/session_summary.dart';

class SessionRow extends StatelessWidget {
  const SessionRow({required this.session, required this.onTap, super.key});

  final SessionSummary session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppDimens.rowHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.md,
            vertical: AppDimens.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      topicLabel(InterviewTopic.fromId(session.topic)),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppDimens.xs),
                    Text(_subtitle(session), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              ScorePill(score: session.overallScore),
              Icon(
                Icons.chevron_right_rounded,
                size: AppDimens.iconMd,
                color: theme.textTheme.labelSmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _subtitle(SessionSummary session) =>
      '${_dateLabel(session.completedAt)}${AppStrings.metaSeparator}'
      '${AppStrings.questionCount(session.questionCount)}';

  static String _dateLabel(DateTime when) {
    final local = when.toLocal();
    final days = DateUtils.dateOnly(DateTime.now())
        .difference(DateUtils.dateOnly(local))
        .inDays;

    return switch (days) {
      <= 0 => AppStrings.today,
      1 => AppStrings.yesterday,
      _ => '${AppStrings.monthsShort[local.month - 1]} ${local.day}',
    };
  }
}

class SessionRowSkeleton extends StatelessWidget {
  const SessionRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: AppDimens.rowHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.md,
          vertical: AppDimens.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonBox.text(width: 140),
                  SizedBox(height: AppDimens.sm),
                  SkeletonBox.text(width: 90),
                ],
              ),
            ),
            SizedBox(width: AppDimens.sm),
            SkeletonBox(width: 88, radius: AppDimens.radiusPill),
          ],
        ),
      ),
    );
  }
}
