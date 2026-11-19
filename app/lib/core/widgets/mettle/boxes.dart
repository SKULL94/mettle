import 'package:flutter/material.dart';

import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';

class InfoBox extends StatelessWidget {
  const InfoBox({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;

    return Container(
      padding: const EdgeInsets.all(MettleSpace.s4),
      decoration: BoxDecoration(
        color: colors.accentTint8,
        borderRadius: BorderRadius.circular(MettleSpace.rMd),
        border: Border.all(
          color: colors.accentBorder28,
          width: MettleSpace.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              icon,
              size: MettleSpace.iconInfo,
              color: colors.accentText,
            ),
          ),
          const SizedBox(width: MettleSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: styles.labelLarge),
                const SizedBox(height: MettleSpace.s1),
                Text(body, style: styles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TipBox extends StatelessWidget {
  const TipBox({required this.lead, required this.body, super.key});

  final String lead;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MettleSpace.s4,
        vertical: MettleSpace.s3,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(MettleSpace.rMd),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: lead,
              style: styles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            TextSpan(text: ' $body', style: styles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class StepNumber extends StatelessWidget {
  const StepNumber({required this.value, super.key});

  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: MettleSpace.s8,
      height: MettleSpace.s8,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.accentTint14,
        shape: BoxShape.circle,
      ),
      child: Text('$value', style: context.text.monoMedium),
    );
  }
}

class CheckItem extends StatelessWidget {
  const CheckItem({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(
            Icons.check_rounded,
            size: MettleSpace.iconCheck,
            color: colors.accentText,
          ),
        ),
        const SizedBox(width: MettleSpace.s3),
        Expanded(child: Text(label, style: context.text.bodyMedium)),
      ],
    );
  }
}
