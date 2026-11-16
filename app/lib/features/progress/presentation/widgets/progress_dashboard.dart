import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/page_frame.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../sessions/presentation/widgets/session_table.dart';
import '../../domain/entities/progress_overview.dart';
import '../cubit/progress_cubit.dart';
import 'topic_mastery_list.dart';
import 'trend_card.dart';

class ProgressDashboard extends StatelessWidget {
  const ProgressDashboard({required this.overview, super.key});

  final ProgressOverview overview;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      onRefresh: () => context.read<ProgressCubit>().load(),
      children: [
        PageHeader(
          eyebrow: AppStrings.navAnalytics,
          title: AppStrings.progressTitle,
          subtitle: AppStrings.progressSubtitle,
          actions: [
            OutlinedButton.icon(
              onPressed: () => context.read<ProgressCubit>().load(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppDimens.controlHeight),
              ),
              icon: const Icon(Icons.refresh_rounded, size: AppDimens.iconMd),
              label: const Text(AppStrings.refresh),
            ),
          ],
        ),
        PaneRow(
          panes: [
            (flex: 7, child: TrendCard(trend: overview.trend)),
            (
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: AppStrings.topicMastery),
                  const SizedBox(height: AppDimens.md),
                  TopicMasteryList(mastery: overview.mastery),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.xl),
        SectionHeader(
          title: AppStrings.history,
          trailing: MetaTag(
            label: AppStrings.sessionCount(overview.history.length),
          ),
        ),
        const SizedBox(height: AppDimens.md),
        SessionTable(
          sessions: overview.history,
          onSelected: (session) => context.pushNamed(
            AppRoutes.scorecardName,
            pathParameters: {AppRoutes.idParam: session.id},
          ),
        ),
      ],
    );
  }
}
