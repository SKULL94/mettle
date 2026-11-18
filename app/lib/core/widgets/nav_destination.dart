import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../router/app_routes.dart';

@immutable
final class AppDestination {
  const AppDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.longLabel,
    required this.path,
    this.inSidebar = true,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String longLabel;
  final String path;
  final bool inSidebar;
}

int get settingsDestination =>
    navDestinations.indexWhere((d) => d.path == AppRoutes.settings);

const navDestinations = <AppDestination>[
  AppDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: AppStrings.navHome,
    longLabel: AppStrings.navDashboard,
    path: AppRoutes.home,
  ),
  AppDestination(
    icon: Icons.trending_up_rounded,
    selectedIcon: Icons.trending_up_rounded,
    label: AppStrings.navProgress,
    longLabel: AppStrings.navAnalytics,
    path: AppRoutes.progress,
  ),
  AppDestination(
    icon: Icons.assessment_outlined,
    selectedIcon: Icons.assessment_rounded,
    label: AppStrings.navScorecard,
    longLabel: AppStrings.scorecard,
    path: AppRoutes.latestScorecard,
  ),
  AppDestination(
    icon: Icons.tune_rounded,
    selectedIcon: Icons.tune_rounded,
    label: AppStrings.navSettings,
    longLabel: AppStrings.navSettings,
    path: AppRoutes.settings,
    inSidebar: false,
  ),
];
