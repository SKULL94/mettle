import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/mettle/buttons.dart';
import '../../../../core/widgets/mettle/pills.dart';
import '../../../../core/widgets/mettle/score_ring.dart';
import '../../../../core/widgets/mettle/surface_card.dart';
import '../../domain/entities/user_summary.dart';

class RecommendedCard extends StatelessWidget {
  const RecommendedCard({
    required this.summary,
    required this.onPractise,
    required this.onChooseElse,
    super.key,
  });

  static const reasonMaxWidth = 560.0;

  final UserSummary summary;
  final ValueChanged<Recommendation> onPractise;
  final VoidCallback onChooseElse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;
    final next = summary.next;
    final free = summary.plan == Plan.free;
    final lastFree = free && summary.isLastFree;

    final overline = switch (true) {
      _ when next == null => AppStrings.recOverlineNone,
      _ when lastFree => AppStrings.recOverlineLast,
      _ => AppStrings.recOverline,
    };

    return SurfaceCard(
      highlight: true,
      padding: EdgeInsets.all(context.startCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            overline,
            style: TextStyle(
              fontFamily: MettleText.mono,
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: colors.accentText,
            ),
          ),
          const SizedBox(height: MettleSpace.s4),
          Text(
            next?.topicName ?? AppStrings.recPickNext,
            style: styles.headline,
          ),
          if (next != null) ...[
            const SizedBox(height: MettleSpace.s2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: reasonMaxWidth),
              child: Text(next.reason, style: styles.bodyLarge),
            ),
            const SizedBox(height: MettleSpace.s4),
            Wrap(
              spacing: MettleSpace.s2,
              runSpacing: MettleSpace.s2,
              children: [
                MetaPill(label: next.level.label),
                MetaPill(label: AppStrings.briefQuestions(next.questionCount)),
                MetaPill(label: AppStrings.briefAbout(next.minutes)),
              ],
            ),
          ],
          const SizedBox(height: MettleSpace.s5),
          Wrap(
            spacing: MettleSpace.s4,
            runSpacing: MettleSpace.s4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PrimaryButton(
                label: next == null
                    ? AppStrings.recPickNext
                    : AppStrings.recPractise(_lowerFirst(next.topicName)),
                leadingIcon: next == null ? null : Icons.play_arrow_rounded,
                onPressed: next == null ? onChooseElse : () => onPractise(next),
              ),
              if (next != null)
                TextLink(
                  label: AppStrings.recChooseElse,
                  large: true,
                  onTap: onChooseElse,
                ),
            ],
          ),
          if (free && next != null) ...[
            const SizedBox(height: MettleSpace.s4),
            Text(
              lastFree
                  ? AppStrings.recLastFreeCaption
                  : AppStrings.recUses(summary.freeRemaining),
              style: styles.caption,
            ),
          ],
        ],
      ),
    );
  }

  static String _lowerFirst(String value) =>
      value.isEmpty ? value : value[0].toLowerCase() + value.substring(1);
}

class ReadinessScoreCard extends StatelessWidget {
  const ReadinessScoreCard({required this.summary, super.key});

  final UserSummary summary;

  @override
  Widget build(BuildContext context) {
    final styles = context.text;
    final band = summary.readinessBand ?? ReadinessBand.developing;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(text: AppStrings.readinessTitle),
          const SizedBox(height: MettleSpace.s4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScoreRing(score: summary.readiness, bandLabel: _bandWord(band)),
              const SizedBox(width: MettleSpace.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusPill(
                      label: _bandWord(band),
                      color: bandColor(context, band),
                    ),
                    const SizedBox(height: MettleSpace.s2),
                    Text(
                      AppStrings.basedOn(summary.completedInterviews),
                      style: styles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MettleSpace.s4),
          const _BandLegend(),
        ],
      ),
    );
  }

  static String _bandWord(ReadinessBand band) => switch (band) {
    ReadinessBand.needsWork => AppStrings.statusNeedsWork,
    ReadinessBand.developing => AppStrings.statusDeveloping,
    ReadinessBand.interviewReady => AppStrings.bandReadyWord,
  };
}

class _BandLegend extends StatelessWidget {
  const _BandLegend();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;

    const labels = [
      AppStrings.bandNeedsWork,
      AppStrings.bandDeveloping,
      AppStrings.bandReady,
    ];

    final bandColors = [colors.danger, colors.warning, colors.success];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          if (index > 0) const SizedBox(width: MettleSpace.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: bandColors[index],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: MettleSpace.s1),
                Text(labels[index], style: styles.caption),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
