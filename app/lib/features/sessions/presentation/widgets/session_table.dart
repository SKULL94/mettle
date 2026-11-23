import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/score_colors.dart';
import '../../../../core/widgets/status_dot.dart';
import '../../../interview/domain/entities/interview_topic.dart';
import '../../../interview/presentation/widgets/topic_label.dart';
import '../../domain/entities/session_summary.dart';
import 'session_row.dart';

class SessionTable extends StatelessWidget {
  const SessionTable({
    required this.sessions,
    required this.onSelected,
    super.key,
  });

  final List<SessionSummary> sessions;
  final ValueChanged<SessionSummary> onSelected;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _HeaderRow(),
          Divider(
            height: AppDimens.hairline,
            color: theme.colorScheme.outlineVariant,
          ),
          for (final (index, session) in sessions.indexed) ...[
            if (index > 0)
              Divider(
                height: AppDimens.hairline,
                color: theme.colorScheme.outlineVariant,
              ),
            _TableRow(session: session, onTap: () => onSelected(session)),
          ],
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall;

    return Container(
      color: theme.colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(AppStrings.colDate.toUpperCase(), style: style),
          ),
          Expanded(
            flex: 6,
            child: Text(AppStrings.colTopic.toUpperCase(), style: style),
          ),
          Expanded(
            flex: 3,
            child: Text(
              AppStrings.colQuestions.toUpperCase(),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              AppStrings.colScore.toUpperCase(),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              AppStrings.colScorecard.toUpperCase(),
              textAlign: TextAlign.end,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.session, required this.onTap});

  final SessionSummary session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topic = InterviewTopic.fromId(session.topic);
    final colour = context.scoreColors.forScore(session.overallScore);
    final mono = AppTheme.code(context).copyWith(fontSize: 13);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md,
          vertical: AppDimens.md,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                sessionDateLabel(session.completedAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: mono.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                topicLabel(topic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${session.questionCount}',
                textAlign: TextAlign.center,
                style: mono,
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatusDot(color: colour),
                  const SizedBox(width: AppDimens.xs),
                  Text(
                    AppStrings.scoreOutOf(session.overallScore, 100),
                    style: mono.copyWith(
                      color: colour,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    AppStrings.viewScorecard,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: AppDimens.iconMd,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
