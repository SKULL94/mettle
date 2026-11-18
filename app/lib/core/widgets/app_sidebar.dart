import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import 'nav_destination.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    required this.selectedIndex,
    required this.onSelected,
    required this.onStartSession,
    required this.sessionActive,
    required this.accountName,
    required this.accountDetail,
    required this.backendHost,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onStartSession;
  final bool sessionActive;
  final String accountName;
  final String accountDetail;
  final String backendHost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface =
        theme.navigationRailTheme.backgroundColor ??
        theme.colorScheme.surfaceContainer;

    return Container(
      width: AppDimens.sidebarWidth,
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: AppDimens.hairline,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.md,
            vertical: AppDimens.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Brand(),
              const SizedBox(height: AppDimens.lg),
              _StartButton(onPressed: onStartSession),
              const SizedBox(height: AppDimens.lg),
              for (final (index, destination) in navDestinations.indexed)
                if (destination.inSidebar)
                  _NavItem(
                    icon: destination.icon,
                    label: destination.longLabel,
                    selected: selectedIndex == index,
                    onTap: () => onSelected(index),
                  ),
              const Spacer(),
              _AccountRow(
                name: accountName,
                detail: accountDetail,
                onTap: () => onSelected(settingsDestination),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm),
      child: Row(
        children: [
          Flexible(
            child: Text(
              AppStrings.appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(width: AppDimens.sm),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.play_arrow_rounded, size: AppDimens.iconMd),
      label: const Text(
        AppStrings.startInterview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.xs),
      child: Material(
        color: selected
            ? theme.colorScheme.surfaceContainerHigh
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radius),
          child: Semantics(
            selected: selected,
            button: true,
            child: Container(
              height: AppDimens.minTouchTarget,
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(icon, size: AppDimens.navIcon, color: foreground),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: foreground,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.name,
    required this.detail,
    required this.onTap,
  });

  final String name;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        child: Semantics(
          button: true,
          label: AppStrings.openSettings,
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.sm),
            child: Row(
              children: [
                Container(
                  width: AppDimens.avatar,
                  height: AppDimens.avatar,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: AppDimens.iconSm,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_vert_rounded,
                  size: AppDimens.iconMd,
                  color: theme.textTheme.labelSmall?.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
