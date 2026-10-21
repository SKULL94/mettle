import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/status_dot.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _BrandMark(),
            const SizedBox(width: AppDimens.sm),
            Expanded(
              child: Text(
                AppStrings.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge,
              ),
            ),
            if (!ApiConstants.isBackendConfigured) ...[
              const SizedBox(width: AppDimens.sm),
              const Flexible(child: DemoModeChip()),
            ],
          ],
        ),
        const SizedBox(height: AppDimens.md),
        Text(AppStrings.dashboardTitle, style: theme.textTheme.displaySmall),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: AppDimens.brandMark,
      height: AppDimens.brandMark,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.sm),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: AppDimens.hairline,
        ),
      ),
      child: ExcludeSemantics(
        child: Text(
          AppStrings.brandMark,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class DemoModeChip extends StatelessWidget {
  const DemoModeChip({super.key});

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
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: AppDimens.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(color: theme.colorScheme.primary),
          const SizedBox(width: AppDimens.xs),
          Flexible(
            child: Text(
              AppStrings.demoMode,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
