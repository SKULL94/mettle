import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../theme/app_theme.dart';

class PageFrame extends StatelessWidget {
  const PageFrame({required this.children, this.onRefresh, super.key});

  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.gutter,
        vertical: AppDimens.lg,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimens.contentMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );

    if (onRefresh == null) return list;
    return RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag = eyebrow;
    final caption = subtitle;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tag != null) ...[
                      Text(
                        tag.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.code(context).copyWith(
                          fontSize: 12,
                          height: 1.4,
                          letterSpacing: 0.6,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xs),
                    ],
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.displaySmall,
                    ),
                    if (caption != null) ...[
                      const SizedBox(height: AppDimens.xs),
                      Text(caption, style: theme.textTheme.bodyLarge),
                    ],
                  ],
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(width: AppDimens.md),
                Wrap(
                  spacing: AppDimens.sm,
                  runSpacing: AppDimens.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: actions,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Divider(
            height: AppDimens.hairline,
            color: theme.colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}

class PaneRow extends StatelessWidget {
  const PaneRow({
    required this.panes,
    this.stacked = false,
    this.gap = AppDimens.paneGap,
    super.key,
  });

  final List<({int flex, Widget child})> panes;
  final bool stacked;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, pane) in panes.indexed) ...[
            if (index > 0) SizedBox(height: gap),
            pane.child,
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, pane) in panes.indexed) ...[
          if (index > 0) SizedBox(width: gap),
          Expanded(flex: pane.flex, child: pane.child),
        ],
      ],
    );
  }
}

class WebCard extends StatelessWidget {
  const WebCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.lg),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: padding, child: child),
    );
  }
}

class CardHeading extends StatelessWidget {
  const CardHeading({
    required this.icon,
    required this.title,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: AppDimens.iconMd, color: theme.colorScheme.primary),
        const SizedBox(width: AppDimens.sm),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class MetaTag extends StatelessWidget {
  const MetaTag({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sm,
        vertical: AppDimens.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.xs),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall,
      ),
    );
  }
}
