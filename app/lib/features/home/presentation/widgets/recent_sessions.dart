import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../sessions/domain/entities/session_summary.dart';
import '../../../sessions/presentation/widgets/session_list.dart';

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
        SessionList(sessions: sessions, onSelected: onSelected),
      ],
    );
  }
}

class RecentSessionsSkeleton extends StatelessWidget {
  const RecentSessionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SessionListSkeleton();
  }
}
