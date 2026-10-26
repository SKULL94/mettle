import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/interview_turn.dart';
import 'turn_breakdown.dart';

typedef AuditEntry = ({InterviewTurn turn, int? position});

List<AuditEntry> auditEntries(List<InterviewTurn> turns) {
  final entries = <AuditEntry>[];
  var position = 0;

  for (final turn in turns) {
    if (turn.question.isFollowUp) {
      entries.add((turn: turn, position: null));
    } else {
      position += 1;
      entries.add((turn: turn, position: position));
    }
  }

  return entries;
}

class QuestionAudit extends StatefulWidget {
  const QuestionAudit({required this.turns, super.key});

  final List<InterviewTurn> turns;

  @override
  State<QuestionAudit> createState() => _QuestionAuditState();
}

class _QuestionAuditState extends State<QuestionAudit> {
  final _expanded = <int>{0};

  void _toggle(int index) {
    setState(() {
      if (!_expanded.remove(index)) _expanded.add(index);
    });
  }

  void _toggleAll(List<AuditEntry> entries) {
    setState(() {
      if (_expanded.isEmpty) {
        _expanded.addAll(List.generate(entries.length, (index) => index));
      } else {
        _expanded.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = auditEntries(widget.turns);
    final questionCount = entries
        .where((entry) => entry.position != null)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppDimens.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              AppStrings.questionAudit(questionCount),
              style: theme.textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => _toggleAll(entries),
              child: Text(
                _expanded.isEmpty
                    ? AppStrings.expandAll
                    : AppStrings.collapseAll,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        for (final (index, entry) in entries.indexed)
          TurnBreakdown(
            turn: entry.turn,
            position: entry.position,
            expanded: _expanded.contains(index),
            onToggle: () => _toggle(index),
          ),
      ],
    );
  }
}
