import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = actionLabel;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimens.panelMaxWidth),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.xl,
              vertical: AppDimens.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppDimens.xxl,
                  height: AppDimens.xxl,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: AppDimens.navIcon,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppDimens.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                if (label != null && onAction != null) ...[
                  const SizedBox(height: AppDimens.lg),
                  FilledButton(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, AppDimens.ctaHeight),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.xl,
                      ),
                    ),
                    child: Text(label),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
