import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/session_summary.dart';
import 'section_header.dart';
import 'session_row.dart';

class RecentSessions extends StatelessWidget {
  const RecentSessions({
    required this.sessions,
    required this.onSelected,
    super.key,
  });

  final List<SessionSummary> sessions;
  final ValueChanged<SessionSummary> onSelected;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: AppStrings.recentSessions),
        const SizedBox(height: AppDimens.md),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (index, session) in sessions.indexed) ...[
                if (index > 0) const Divider(height: AppDimens.hairline),
                SessionRow(session: session, onTap: () => onSelected(session)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class RecentSessionsSkeleton extends StatelessWidget {
  const RecentSessionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SessionRowSkeleton(),
          Divider(height: AppDimens.hairline),
          SessionRowSkeleton(),
          Divider(height: AppDimens.hairline),
          SessionRowSkeleton(),
        ],
      ),
    );
  }
}
