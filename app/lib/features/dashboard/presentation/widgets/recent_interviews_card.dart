import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/widgets/mettle/buttons.dart';
import '../../../../core/widgets/mettle/interview_row.dart';
import '../../../../core/widgets/mettle/surface_card.dart';
import '../../domain/entities/user_summary.dart';

export '../../../../core/widgets/mettle/interview_row.dart'
    show bandOf, bandWordOf, interviewDateLabel;

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
            InterviewRow(
              title: item.title,
              questions: item.questions,
              date: item.date,
              score: item.score,
              onTap: () => onOpen(item),
            ),
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
