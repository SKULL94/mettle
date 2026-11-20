import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/mettle/boxes.dart';
import '../../../../core/widgets/mettle/buttons.dart';
import '../../../../core/widgets/mettle/interview_row.dart';
import '../../../../core/widgets/mettle/pills.dart';
import '../../../../core/widgets/mettle/surface_card.dart';
import '../../../progress/domain/entities/progress_overview.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';
import '../../../progress/presentation/cubit/progress_state.dart';
import '../../../sessions/domain/entities/session_summary.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgressCubit(sl(), sl())..load(),
      child: const HistoryView(),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressCubit, ProgressState>(
      builder: (context, state) => _Frame(
        child: switch (state) {
          ProgressLoading() => const _Busy(),
          ProgressEmpty() => const _Empty(),
          ProgressLoaded(:final overview) => _Body(overview: overview),
          ProgressError(:final message) => _Failed(message: message),
        },
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: MettleSpace.contentMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.historyTitle, style: context.text.display),
              const SizedBox(height: MettleSpace.s2),
              Text(AppStrings.historySubtitle, style: context.text.bodyLarge),
              SizedBox(height: context.sectionGap),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.overview});

  final ProgressOverview overview;

  @override
  Widget build(BuildContext context) {
    final groups = _groupByMonth(overview.history);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Stats(sessions: overview.history),
        SizedBox(height: context.sectionGap),
        for (final (index, group) in groups.indexed) ...[
          if (index > 0) SizedBox(height: context.sectionGap),
          _Group(label: group.label, sessions: group.sessions),
        ],
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.sessions});

  final List<SessionSummary> sessions;

  @override
  Widget build(BuildContext context) {
    final best = sessions
        .map((s) => s.overallScore)
        .reduce((a, b) => a > b ? a : b);
    final total = sessions.fold(0, (sum, s) => sum + s.overallScore);
    final average = (total / sessions.length).round();
    final questions = sessions.fold(0, (sum, s) => sum + s.questionCount);

    final tiles = <({String label, String value})>[
      (label: AppStrings.historyCompleted, value: '${sessions.length}'),
      (label: AppStrings.historyAverage, value: '$average'),
      (label: AppStrings.historyBest, value: '$best'),
      (label: AppStrings.historyAnswered, value: '$questions'),
    ];

    final columns = context.sizeClass.isCompact ? 2 : 4;

    return SurfaceCard(
      child: Column(
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
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.entry});

  final ({String label, String value}) entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          Text(entry.label, style: context.text.caption),
          const SizedBox(height: MettleSpace.s1),
          Text(
            entry.value,
            style: TextStyle(
              fontFamily: MettleText.mono,
              fontSize: 22,
              height: 28 / 22,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.sessions});

  final String label;
  final List<SessionSummary> sessions;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: CardTitle(text: label)),
              const SizedBox(width: MettleSpace.s3),
              MetaPill(label: AppStrings.historyCount(sessions.length)),
            ],
          ),
          const SizedBox(height: MettleSpace.s3),
          for (final (index, session) in sessions.indexed) ...[
            if (index > 0) const SizedBox(height: MettleSpace.s3),
            InterviewRow(
              title: session.topic,
              questions: session.questionCount,
              date: session.completedAt,
              score: session.overallScore,
              onTap: () => context.pushNamed(
                AppRoutes.scorecardName,
                pathParameters: {AppRoutes.idParam: session.id},
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MettleSpace.s12),
      child: Center(
        child: CircularProgressIndicator(color: context.colors.accent),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.all(context.startCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(text: AppStrings.historyEmptyTitle),
          const SizedBox(height: MettleSpace.s2),
          Text(AppStrings.historyEmptyBody, style: context.text.bodyMedium),
          const SizedBox(height: MettleSpace.s5),
          Align(
            alignment: Alignment.centerLeft,
            child: PrimaryButton(
              label: AppStrings.historyEmptyCta,
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
          ),
        ],
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoBox(
            icon: Icons.error_outline_rounded,
            title: AppStrings.historyFailedTitle,
            body: message,
          ),
          const SizedBox(height: MettleSpace.s4),
          Align(
            alignment: Alignment.centerLeft,
            child: SecondaryButton(
              label: AppStrings.retry,
              onPressed: () => context.read<ProgressCubit>().load(),
            ),
          ),
        ],
      ),
    );
  }
}

List<({String label, List<SessionSummary> sessions})> _groupByMonth(
  List<SessionSummary> sessions,
) {
  final sorted = [...sessions]
    ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

  final groups = <({String label, List<SessionSummary> sessions})>[];

  for (final session in sorted) {
    final label = _monthLabel(session.completedAt);
    if (groups.isNotEmpty && groups.last.label == label) {
      groups.last.sessions.add(session);
      continue;
    }
    groups.add((label: label, sessions: [session]));
  }

  return groups;
}

String _monthLabel(DateTime when) {
  final now = DateTime.now();
  final month = AppStrings.months[when.month - 1];

  if (when.year == now.year && when.month == now.month) {
    return AppStrings.historyThisMonth;
  }
  if (when.year == now.year) return month;

  return '$month ${when.year}';
}
