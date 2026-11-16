import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_dot.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    required this.heading,
    required this.subtitle,
    required this.backendHost,
    required this.child,
    super.key,
  });

  final String heading;
  final String subtitle;
  final String backendHost;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BrandPanel(
            heading: heading,
            subtitle: subtitle,
            backendHost: backendHost,
          ),
        ),
        _FormPanel(child: child),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({
    required this.heading,
    required this.subtitle,
    required this.backendHost,
  });

  final String heading;
  final String subtitle;
  final String backendHost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.xxl,
        vertical: AppDimens.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Wordmark(),
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimens.readableMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(heading, style: theme.textTheme.displaySmall),
                const SizedBox(height: AppDimens.sm),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimens.xl),
                for (final value in AppStrings.authValueProps)
                  _ValuePoint(label: value),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              StatusDot(color: theme.colorScheme.primary),
              const SizedBox(width: AppDimens.sm),
              Flexible(
                child: Text(
                  backendHost,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.code(context).copyWith(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Text(
                AppStrings.appVersion,
                style: AppTheme.code(context).copyWith(
                  fontSize: 12,
                  color: theme.textTheme.labelSmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(AppStrings.appName, style: theme.textTheme.titleLarge),
        const SizedBox(width: AppDimens.sm),
        StatusDot(color: theme.colorScheme.primary),
        const SizedBox(width: AppDimens.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.sm,
            vertical: AppDimens.xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppDimens.xs),
          ),
          child: Text(
            AppStrings.brandTag,
            style: AppTheme.code(context).copyWith(
              fontSize: 11,
              height: 1.2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ValuePoint extends StatelessWidget {
  const _ValuePoint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: AppDimens.iconMd,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppDimens.sm),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface =
        theme.navigationRailTheme.backgroundColor ??
        theme.colorScheme.surfaceContainer;

    return Container(
      width: AppDimens.authPaneWidth,
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: AppDimens.hairline,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(0, constraints.maxHeight - AppDimens.xl * 2),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
