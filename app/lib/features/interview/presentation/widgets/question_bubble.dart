import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/question.dart';
import 'topic_label.dart';

class QuestionBubble extends StatelessWidget {
  const QuestionBubble({
    required this.text,
    required this.isFollowUp,
    required this.isStreaming,
    this.reason,
    super.key,
  });

  final String text;
  final bool isFollowUp;
  final bool isStreaming;
  final FollowUpReason? reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFollowUp) ...[
              _FollowUpBadge(reason: reason),
              const SizedBox(height: AppDimens.sm),
            ],
            _StreamingText(
              text: text,
              isStreaming: isStreaming,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowUpBadge extends StatelessWidget {
  const _FollowUpBadge({this.reason});

  final FollowUpReason? reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = reason == null ? null : followUpReasonLabel(reason!);

    return Semantics(
      label: label == null
          ? 'Follow-up question'
          : 'Follow-up question, probing $label',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.subdirectory_arrow_right_rounded,
                size: AppDimens.md,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppDimens.xs),
              Text(
                AppStrings.followUp,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (label != null) Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _StreamingText extends StatefulWidget {
  const _StreamingText({
    required this.text,
    required this.isStreaming,
    this.style,
  });

  final String text;
  final bool isStreaming;
  final TextStyle? style;

  @override
  State<_StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<_StreamingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;

    if (!widget.isStreaming) {
      return Text(widget.text, style: style);
    }

    return AnimatedBuilder(
      animation: _blink,
      builder: (context, _) {
        final visible = _blink.value < 0.5;
        return Text.rich(
          TextSpan(
            text: widget.text,
            style: style,
            children: [
              TextSpan(
                text: '▋',
                style: style?.copyWith(
                  color: visible
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
