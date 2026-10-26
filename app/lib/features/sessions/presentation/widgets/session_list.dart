import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../domain/entities/session_summary.dart';
import 'session_row.dart';

class SessionList extends StatelessWidget {
  const SessionList({
    required this.sessions,
    required this.onSelected,
    super.key,
  });

  final List<SessionSummary> sessions;
  final ValueChanged<SessionSummary> onSelected;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, session) in sessions.indexed) ...[
            if (index > 0) const Divider(height: AppDimens.hairline),
            SessionRow(session: session, onTap: () => onSelected(session)),
          ],
        ],
      ),
    );
  }
}

class SessionListSkeleton extends StatelessWidget {
  const SessionListSkeleton({this.rows = 3, super.key});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < rows; index++) ...[
            if (index > 0) const Divider(height: AppDimens.hairline),
            const SessionRowSkeleton(),
          ],
        ],
      ),
    );
  }
}
