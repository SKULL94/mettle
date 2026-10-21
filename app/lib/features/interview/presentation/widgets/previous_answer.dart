import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/interview_turn.dart';

class PreviousAnswer extends StatelessWidget {
  const PreviousAnswer({
    required this.turn,
    required this.turnNumber,
    super.key,
  });

  final InterviewTurn turn;
  final int turnNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answer = turn.answer ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.previousAnswer(turnNumber),
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: AppDimens.sm),
        if (answer.isEmpty)
          Text(AppStrings.skipped, style: theme.textTheme.bodyMedium)
        else
          Container(
            padding: const EdgeInsets.only(left: AppDimens.md),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.colorScheme.outline,
                  width: AppDimens.hairline,
                ),
              ),
            ),
            child: Text(answer, style: theme.textTheme.bodyMedium),
          ),
      ],
    );
  }
}
