import 'package:flutter/material.dart';

import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';
import '../../../features/dashboard/domain/entities/user_summary.dart';

Color statusColor(BuildContext context, TopicStatus status) {
  final colors = context.colors;
  return switch (status) {
    TopicStatus.strong => colors.success,
    TopicStatus.developing => colors.warning,
    TopicStatus.needsWork => colors.danger,
    TopicStatus.notTried => colors.textTertiary,
  };
}

Color bandColor(BuildContext context, ReadinessBand band) {
  final colors = context.colors;
  return switch (band) {
    ReadinessBand.interviewReady => colors.success,
    ReadinessBand.developing => colors.warning,
    ReadinessBand.needsWork => colors.danger,
  };
}

class MetaPill extends StatelessWidget {
  const MetaPill({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: MettleSpace.s3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(MettleSpace.rFull),
        border: Border.all(
          color: colors.borderDefault,
          width: MettleSpace.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: MettleText.sans,
          fontSize: 13,
          height: 18 / 13,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(MettleSpace.rFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: MettleText.sans,
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class StatusLabel extends StatelessWidget {
  const StatusLabel({required this.label, required this.status, super.key});

  final String label;
  final TopicStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final notTried = status == TopicStatus.notTried;
    final color = statusColor(context, status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: notTried ? colors.borderStrong : color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: MettleSpace.pip),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: MettleText.sans,
              fontSize: 12,
              height: 16 / 12,
              color: notTried ? colors.textTertiary : color,
            ),
          ),
        ),
      ],
    );
  }
}

class RecommendedBadge extends StatelessWidget {
  const RecommendedBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: MettleSpace.s2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(MettleSpace.rFull),
      ),
      child: Text(label.toUpperCase(), style: context.text.badge),
    );
  }
}

class ProBadge extends StatelessWidget {
  const ProBadge({required this.label, this.iconOnly = false, super.key});

  final String label;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          height: 20,
          padding: EdgeInsets.symmetric(
            horizontal: iconOnly ? MettleSpace.s1 : MettleSpace.s2,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MettleSpace.rFull),
            border: Border.all(
              color: colors.accentBorder40,
              width: MettleSpace.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: MettleSpace.iconLockBadge,
                color: colors.accentText,
              ),
              if (!iconOnly) ...[
                const SizedBox(width: MettleSpace.s1),
                Text(
                  label,
                  style: context.text.badge.copyWith(color: colors.accentText),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
