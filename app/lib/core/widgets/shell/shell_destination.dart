import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';

enum ShellTab { dashboard, progress, history }

@immutable
final class ShellDestination {
  const ShellDestination({
    required this.tab,
    required this.icon,
    required this.label,
    required this.path,
  });

  final ShellTab tab;
  final IconData icon;
  final String label;
  final String path;
}

const shellDestinations = <ShellDestination>[
  ShellDestination(
    tab: ShellTab.dashboard,
    icon: Icons.home_outlined,
    label: AppStrings.shellDashboard,
    path: '/dashboard',
  ),
  ShellDestination(
    tab: ShellTab.progress,
    icon: Icons.trending_up_rounded,
    label: AppStrings.shellProgress,
    path: '/progress',
  ),
  ShellDestination(
    tab: ShellTab.history,
    icon: Icons.schedule_rounded,
    label: AppStrings.shellHistory,
    path: '/history',
  ),
];
