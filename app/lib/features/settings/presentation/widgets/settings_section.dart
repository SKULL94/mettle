import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/widgets/section_header.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: AppDimens.md),
        child,
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.title,
    this.body,
    this.leading,
    this.trailing,
    this.onTap,
    this.titleColor,
    super.key,
  });

  final String title;
  final String? body;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = body;

    final content = Padding(
      padding: const EdgeInsets.all(AppDimens.md),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppDimens.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(color: titleColor),
                ),
                if (description != null) ...[
                  const SizedBox(height: AppDimens.xs),
                  Text(description, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppDimens.sm),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppDimens.minTouchTarget),
        child: content,
      ),
    );
  }
}
