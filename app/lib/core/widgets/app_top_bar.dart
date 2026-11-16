import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    required this.onStartSession,
    required this.onAccountPressed,
    this.lead,
    this.actions = const [],
    super.key,
  });

  final VoidCallback onStartSession;
  final VoidCallback onAccountPressed;
  final Widget? lead;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: AppDimens.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: AppDimens.hairline,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: lead ?? const SizedBox.shrink()),
          for (final action in actions) ...[
            const SizedBox(width: AppDimens.sm),
            action,
          ],
          const SizedBox(width: AppDimens.md),
          SizedBox(
            height: AppDimens.controlHeight,
            child: FilledButton.icon(
              onPressed: onStartSession,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppDimens.controlHeight),
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
              ),
              icon: const Icon(Icons.bolt_rounded, size: AppDimens.iconMd),
              label: const Text(AppStrings.quickStart),
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          IconButton(
            onPressed: onAccountPressed,
            tooltip: AppStrings.openSettings,
            icon: Container(
              width: AppDimens.avatar,
              height: AppDimens.avatar,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: AppDimens.hairline,
                ),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: AppDimens.iconSm,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopBarPath extends StatelessWidget {
  const TopBarPath({required this.location, super.key});

  final String location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.terminal_rounded,
          size: AppDimens.iconSm,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppDimens.sm),
        Flexible(
          child: Text(
            '${AppStrings.appScheme}$location',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.code(
              context,
            ).copyWith(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class TopBarChip extends StatelessWidget {
  const TopBarChip({required this.label, this.leading, super.key});

  final String label;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: AppDimens.controlHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: AppDimens.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppDimens.sm),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
