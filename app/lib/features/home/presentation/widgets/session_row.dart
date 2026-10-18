import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/session_summary.dart';

class SessionRow extends StatelessWidget {
  const SessionRow({required this.session, required this.onTap, super.key});

  final SessionSummary session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = session.overallScore;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.xs),
      title: Text(session.topic, style: theme.textTheme.bodyLarge),
      subtitle: Text(
        '${session.questionCount} questions · ${_relative(session.completedAt)}',
        style: theme.textTheme.bodySmall,
      ),

      trailing: Text(
        '$score',
        style: theme.textTheme.titleMedium?.copyWith(
          color: context.scoreColors.forScore(score),
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      onTap: onTap,
    );
  }

  static String _relative(DateTime when) {
    final days = DateTime.now().toUtc().difference(when.toUtc()).inDays;
    return switch (days) {
      <= 0 => 'today',
      1 => 'yesterday',
      < 7 => '$days days ago',
      < 14 => 'last week',
      _ => '${days ~/ 7} weeks ago',
    };
  }
}

class SessionRowSkeleton extends StatelessWidget {
  const SessionRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppDimens.xs),
      title: Padding(
        padding: EdgeInsets.only(bottom: AppDimens.xs),
        child: SkeletonBox.text(width: 140),
      ),
      subtitle: SkeletonBox.text(width: 90),
      trailing: SkeletonBox.text(width: 24),
    );
  }
}
