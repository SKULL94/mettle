import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';
import 'credit_meter.dart';

class CreditChip extends StatelessWidget {
  const CreditChip({
    required this.remaining,
    required this.total,
    required this.onTap,
    super.key,
  });

  final int remaining;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final exhausted = remaining == 0;

    return Semantics(
      button: true,
      label: exhausted
          ? AppStrings.planUpgrade
          : AppStrings.planCreditsSemantics(remaining, total),
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            height: MettleSpace.minTouchTarget,
            child: Center(
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: MettleSpace.s3),
                decoration: BoxDecoration(
                  color: exhausted ? colors.accent : colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(MettleSpace.rFull),
                  border: exhausted
                      ? null
                      : Border.all(
                          color: colors.borderDefault,
                          width: MettleSpace.border,
                        ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!exhausted) ...[
                      CreditMeter(
                        remaining: remaining,
                        total: total,
                        mini: true,
                      ),
                      const SizedBox(width: MettleSpace.s2),
                    ],
                    Text(
                      exhausted
                          ? AppStrings.planUpgrade
                          : AppStrings.planChip(remaining),
                      style: TextStyle(
                        fontFamily: MettleText.sans,
                        fontSize: 13,
                        height: 18 / 13,
                        fontWeight: FontWeight.w600,
                        color: exhausted ? colors.onAccent : colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
