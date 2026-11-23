import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/mettle/boxes.dart';
import '../../../../core/widgets/mettle/buttons.dart';
import '../../../../core/widgets/mettle/pills.dart';
import '../../../../core/widgets/mettle/surface_card.dart';
import '../../domain/entities/user_summary.dart';
import 'recent_interviews_card.dart';

class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({
    required this.summary,
    required this.onSeeProgress,
    super.key,
  });

  final UserSummary summary;
  final VoidCallback onSeeProgress;

  @override
  Widget build(BuildContext context) {
    final progress = summary.progress;

    return SurfaceCard(
      padding: EdgeInsets.all(context.startCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(
            text: AppStrings.limitInterviews(summary.completedInterviews),
          ),
          if (progress != null) ...[
            const SizedBox(height: MettleSpace.s6),
            _ScoreRow(progress: progress),
            const SizedBox(height: MettleSpace.s6),
            _StatTiles(progress: progress),
          ],
          const SizedBox(height: MettleSpace.s6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextLink(
              label: AppStrings.limitSeeProgress,
              large: true,
              onTap: onSeeProgress,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.progress});

  final ProgressSummary progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final band = bandOf(progress.latestScore);
    final colour = bandColor(context, band);

    return Semantics(
      label: AppStrings.scoreRowSemantics(
        progress.firstScore,
        progress.latestScore,
        bandWordOf(band),
      ),
      child: ExcludeSemantics(
        child: Wrap(
          spacing: MettleSpace.s5,
          runSpacing: MettleSpace.s4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Score(
              label: AppStrings.limitFirst,
              value: progress.firstScore,
              colour: colors.textSecondary,
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 28,
              color: colors.textTertiary,
            ),
            _Score(
              label: AppStrings.limitLatest,
              value: progress.latestScore,
              colour: colour,
            ),
            StatusPill(
              label: AppStrings.limitDelta(progress.delta, bandWordOf(band)),
              color: colour,
            ),
          ],
        ),
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({
    required this.label,
    required this.value,
    required this.colour,
  });

  final String label;
  final int value;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: context.text.overline),
        const SizedBox(height: MettleSpace.s1),
        Text(
          '$value',
          style: TextStyle(
            fontFamily: MettleText.mono,
            fontSize: 40,
            height: 44 / 40,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: colour,
          ),
        ),
      ],
    );
  }
}

class _StatTiles extends StatelessWidget {
  const _StatTiles({required this.progress});

  final ProgressSummary progress;

  @override
  Widget build(BuildContext context) {
    final tiles = <({String label, String value})>[
      (label: AppStrings.limitStrongest, value: progress.strongest),
      (label: AppStrings.limitMostImproved, value: progress.mostImproved),
      (label: AppStrings.limitPractiseNext, value: progress.practiseNext),
    ];

    final columns = context.sizeClass.isCompact ? 1 : 3;

    return Column(
      children: [
        for (var start = 0; start < tiles.length; start += columns) ...[
          if (start > 0) const SizedBox(height: MettleSpace.s3),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < columns; index++) ...[
                  if (index > 0) const SizedBox(width: MettleSpace.s3),
                  Expanded(
                    child: start + index < tiles.length
                        ? _StatTile(entry: tiles[start + index])
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.entry});

  final ({String label, String value}) entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;

    return Container(
      padding: const EdgeInsets.all(MettleSpace.s4),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(MettleSpace.rMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(entry.label, style: styles.caption),
          const SizedBox(height: MettleSpace.s1),
          Text(entry.value, style: styles.labelLarge),
        ],
      ),
    );
  }
}

class ProOfferCard extends StatelessWidget {
  const ProOfferCard({
    required this.summary,
    required this.onUpgrade,
    required this.onInvite,
    super.key,
  });

  final UserSummary summary;
  final VoidCallback onUpgrade;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;
    final price = summary.proPrice;
    final weekly = summary.nextFreeInterviewAt;
    final showFooter = summary.referralAvailable || weekly != null;

    return SurfaceCard(
      highlight: true,
      padding: EdgeInsets.all(context.startCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.proTitle, style: styles.titleLarge),
          if (price != null) ...[
            const SizedBox(height: MettleSpace.s1),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: TextStyle(
                      fontFamily: MettleText.mono,
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: AppStrings.proPerMonth,
                    style: styles.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: MettleSpace.s4),
          for (final perk in const [
            AppStrings.proPerk1,
            AppStrings.proPerk2,
            AppStrings.proPerk3,
            AppStrings.proPerk4,
          ]) ...[
            CheckItem(label: perk),
            const SizedBox(height: MettleSpace.s3),
          ],
          const SizedBox(height: MettleSpace.s1),
          PrimaryButton(
            label: AppStrings.planUpgrade,
            fullWidth: true,
            onPressed: onUpgrade,
          ),
          if (showFooter) ...[
            const SizedBox(height: MettleSpace.s4),
            Divider(
              height: MettleSpace.border,
              thickness: MettleSpace.border,
              color: colors.borderDefault,
            ),
            const SizedBox(height: MettleSpace.s4),
            Text(
              AppStrings.proNotReady,
              style: styles.link.copyWith(color: colors.textSecondary),
            ),
            if (summary.referralAvailable) ...[
              const SizedBox(height: MettleSpace.s3),
              SecondaryButton(
                label: AppStrings.proInvite,
                size: ButtonSize.medium,
                fullWidth: true,
                onPressed: onInvite,
              ),
            ],
            if (weekly != null) ...[
              const SizedBox(height: MettleSpace.s3),
              Center(
                child: Text(
                  AppStrings.proWeekly(
                    '${weekly.day} ${AppStrings.monthsShort[weekly.month - 1]}',
                  ),
                  style: styles.caption,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class LockedSetupCard extends StatelessWidget {
  const LockedSetupCard({super.key});

  static const minHeight = 240.0;
  static const bodyMaxWidth = 380.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;

    return SurfaceCard(
      padding: EdgeInsets.all(context.cardPadding),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minHeight),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: MettleSpace.s6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 28,
                  color: colors.accentText,
                ),
                const SizedBox(height: MettleSpace.s4),
                Text(
                  AppStrings.lockedTitle,
                  textAlign: TextAlign.center,
                  style: styles.cardTitle,
                ),
                const SizedBox(height: MettleSpace.s2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: bodyMaxWidth),
                  child: Text(
                    AppStrings.lockedBody,
                    textAlign: TextAlign.center,
                    style: styles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
