import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/status_dot.dart';
import '../../domain/entities/question.dart';
import 'topic_label.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
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
    final showsBadges = isFollowUp || isStreaming;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showsBadges) ...[
              _BadgeRow(
                isFollowUp: isFollowUp,
                isStreaming: isStreaming,
                reason: reason,
              ),
              const SizedBox(height: AppDimens.md),
            ],
            _StreamingText(
              text: text,
              isStreaming: isStreaming,
              style: theme.textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({
    required this.isFollowUp,
    required this.isStreaming,
    this.reason,
  });

  final bool isFollowUp;
  final bool isStreaming;
  final FollowUpReason? reason;

  @override
  Widget build(BuildContext context) {
    final probe = reason;

    return Wrap(
      spacing: AppDimens.sm,
      runSpacing: AppDimens.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (isFollowUp) _FollowUpBadge(reason: probe),
        if (isFollowUp && probe != null)
          _Badge(label: followUpReasonLabel(probe).toUpperCase()),
        if (isStreaming) const _StreamingBadge(),
      ],
    );
  }
}

class _FollowUpBadge extends StatelessWidget {
  const _FollowUpBadge({this.reason});

  final FollowUpReason? reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: reason == null
          ? AppStrings.followUpSemantics
          : AppStrings.followUpProbeSemantics(followUpReasonLabel(reason!)),
      child: ExcludeSemantics(
        child: _Badge(
          label: AppStrings.followUp,
          color: theme.colorScheme.primary,
          icon: Icons.subdirectory_arrow_right_rounded,
        ),
      ),
    );
  }
}

class _StreamingBadge extends StatelessWidget {
  const _StreamingBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Badge(
      label: AppStrings.streaming,
      leading: StatusDot(color: theme.colorScheme.primary),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.color, this.icon, this.leading});

  final String label;
  final Color? color;
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = color ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sm,
        vertical: AppDimens.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(
          color: color ?? theme.colorScheme.outline,
          width: AppDimens.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: AppDimens.iconSm, color: foreground),
          ?leading,
          if (icon != null || leading != null)
            const SizedBox(width: AppDimens.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: foreground),
          ),
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
  );

  @override
  void initState() {
    super.initState();
    if (widget.isStreaming) _blink.repeat();
  }

  @override
  void didUpdateWidget(_StreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming == oldWidget.isStreaming) return;

    if (widget.isStreaming) {
      _blink.repeat();
    } else {
      _blink.stop();
    }
  }

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
                text: AppStrings.blockCursor,
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

class QuestionCardSkeleton extends StatelessWidget {
  const QuestionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
              width: 96,
              height: AppDimens.lg,
              radius: AppDimens.radiusPill,
            ),
            SizedBox(height: AppDimens.md),
            SkeletonBox(height: AppDimens.lg),
            SizedBox(height: AppDimens.sm),
            SkeletonBox(height: AppDimens.lg),
            SizedBox(height: AppDimens.sm),
            SkeletonBox(width: 180, height: AppDimens.lg),
          ],
        ),
      ),
    );
  }
}
