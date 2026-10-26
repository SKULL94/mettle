import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../sessions/domain/entities/session_summary.dart';
import '../../../sessions/presentation/widgets/session_list.dart';

class LastSession extends StatelessWidget {
  const LastSession({
    required this.session,
    required this.onSelected,
    super.key,
  });

  final SessionSummary? session;
  final ValueChanged<SessionSummary> onSelected;

  @override
  Widget build(BuildContext context) {
    final last = session;
    if (last == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: AppStrings.lastSession),
        const SizedBox(height: AppDimens.md),
        SessionList(sessions: [last], onSelected: onSelected),
      ],
    );
  }
}

class LastSessionSkeleton extends StatelessWidget {
  const LastSessionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SessionListSkeleton(rows: 1);
  }
}
