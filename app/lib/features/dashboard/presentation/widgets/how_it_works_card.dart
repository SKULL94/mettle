import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/widgets/mettle/boxes.dart';
import '../../../../core/widgets/mettle/buttons.dart';
import '../../../../core/widgets/mettle/surface_card.dart';

typedef _Step = ({String title, String body});

const _steps = <_Step>[
  (title: AppStrings.howStep1Title, body: AppStrings.howStep1Body),
  (title: AppStrings.howStep2Title, body: AppStrings.howStep2Body),
  (title: AppStrings.howStep3Title, body: AppStrings.howStep3Body),
];

class HowItWorksCard extends StatelessWidget {
  const HowItWorksCard({required this.onDismiss, super.key});

  static const columnsMinWidth = 720.0;

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(child: CardTitle(text: AppStrings.howItWorks)),
              const SizedBox(width: MettleSpace.s4),
              SmallButton(
                label: AppStrings.howItWorksGotIt,
                onPressed: onDismiss,
              ),
            ],
          ),
          const SizedBox(height: MettleSpace.s5),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= columnsMinWidth) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (index, step) in _steps.indexed) ...[
                      if (index > 0) const SizedBox(width: MettleSpace.s4),
                      Expanded(
                        child: _StepRow(index: index + 1, step: step),
                      ),
                    ],
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (index, step) in _steps.indexed) ...[
                    if (index > 0) const SizedBox(height: MettleSpace.s4),
                    _StepRow(index: index + 1, step: step),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.step});

  final int index;
  final _Step step;

  @override
  Widget build(BuildContext context) {
    final styles = context.text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepNumber(value: index),
        const SizedBox(width: MettleSpace.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.title, style: styles.labelLarge),
              const SizedBox(height: MettleSpace.s1),
              Text(step.body, style: styles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
