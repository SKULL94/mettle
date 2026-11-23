import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/widgets/mettle/boxes.dart';
import '../../../../core/widgets/mettle/score_ring.dart';
import '../../../../core/widgets/mettle/surface_card.dart';

class ReadinessEmptyCard extends StatelessWidget {
  const ReadinessEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(text: AppStrings.readinessTitle),
          const SizedBox(height: MettleSpace.s4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ScoreRing(score: null),
              const SizedBox(width: MettleSpace.s4),
              Expanded(
                child: Text(
                  AppStrings.readinessEmptyBody,
                  style: context.text.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: MettleSpace.s4),
          const CheckItem(label: AppStrings.readinessCheck1),
          const SizedBox(height: MettleSpace.s3),
          const CheckItem(label: AppStrings.readinessCheck2),
          const SizedBox(height: MettleSpace.s3),
          const CheckItem(label: AppStrings.readinessCheck3),
        ],
      ),
    );
  }
}

typedef _Rubric = ({String name, String body});

const _rubric = <_Rubric>[
  (name: AppStrings.scoredCorrectness, body: AppStrings.scoredCorrectnessBody),
  (name: AppStrings.scoredDepth, body: AppStrings.scoredDepthBody),
  (name: AppStrings.scoredClarity, body: AppStrings.scoredClarityBody),
  (name: AppStrings.scoredStructure, body: AppStrings.scoredStructureBody),
];

class HowScoredCard extends StatelessWidget {
  const HowScoredCard({super.key});

  @override
  Widget build(BuildContext context) {
    final styles = context.text;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(text: AppStrings.scoredTitle),
          const SizedBox(height: MettleSpace.s4),
          for (final entry in _rubric) ...[
            Text(entry.name, style: styles.labelMedium),
            const SizedBox(height: MettleSpace.s1),
            Text(entry.body, style: styles.bodySmall),
            const SizedBox(height: MettleSpace.s4),
          ],
          const TipBox(
            lead: AppStrings.scoredTipLead,
            body: AppStrings.scoredTipBody,
          ),
        ],
      ),
    );
  }
}
