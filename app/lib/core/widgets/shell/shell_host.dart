import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/dashboard/domain/entities/user_summary.dart';
import '../../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../features/dashboard/presentation/cubit/dashboard_state.dart';
import '../../constants/app_strings.dart';
import '../../di/injection.dart';
import '../../router/app_routes.dart';
import 'account_row.dart';
import 'app_scaffold.dart';
import 'shell_destination.dart';

class ShellHost extends StatelessWidget {
  const ShellHost({required this.tab, required this.child, super.key});

  final ShellTab tab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardCubit>()..load(),
      child: _Host(tab: tab, child: child),
    );
  }
}

class _Host extends StatelessWidget {
  const _Host({required this.tab, required this.child});

  final ShellTab tab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final summary = switch (state) {
          DashboardLoaded(:final summary) => summary,
          _ => const UserSummary.empty(),
        };

        return AppScaffold(
          tab: tab,
          state: shellStateFor(summary),
          onSelect: (destination) => context.go(destination.path),
          onAccount: (action) => onAccountAction(context, action),
          body: child,
        );
      },
    );
  }
}

ShellState shellStateFor(UserSummary summary) {
  final user = sl<AuthRepository>().currentUser;
  final name = user?.displayName;

  return ShellState(
    name: switch (true) {
      _ when name != null && name.isNotEmpty => name,
      _ when summary.firstName.isNotEmpty => summary.firstName,
      _ => AppStrings.accountFallback,
    },
    email: user?.email ?? AppStrings.signedOut,
    freeRemaining: summary.freeRemaining,
    freeTotal: summary.freeTotal,
    completedInterviews: summary.completedInterviews,
  );
}

Future<void> onAccountAction(BuildContext context, AccountAction action) async {
  final router = GoRouter.of(context);

  switch (action) {
    case AccountAction.profile:
    case AccountAction.billing:
      await router.pushNamed<void>(AppRoutes.settingsName);
    case AccountAction.signOut:
      await sl<AuthRepository>().signOut();
      router.go(AppRoutes.signIn);
  }
}
