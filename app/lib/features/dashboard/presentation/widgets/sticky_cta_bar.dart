import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/widgets/mettle/buttons.dart';

class StickyCtaBar extends StatelessWidget {
  const StickyCtaBar({
    required this.summaryLine,
    required this.freeRemaining,
    required this.onContinue,
    this.label,
    super.key,
  });

  static const height = 100.0;

  final String summaryLine;
  final int freeRemaining;
  final VoidCallback? onContinue;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onContinue != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        MettleSpace.s4,
        MettleSpace.s3,
        MettleSpace.s4,
        MettleSpace.s3,
      ),
      decoration: BoxDecoration(
        color: colors.bgSidebar,
        border: Border(
          top: BorderSide(
            color: colors.borderSubtle,
            width: MettleSpace.border,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            summaryLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall,
          ),
          const SizedBox(height: MettleSpace.s2),
          PrimaryButton(
            label: switch (true) {
              _ when label != null => label!,
              _ when enabled => AppStrings.startStickyContinue(freeRemaining),
              _ => AppStrings.startContinueDisabled,
            },
            fullWidth: true,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}
