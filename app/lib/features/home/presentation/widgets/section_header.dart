import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppDimens.sm,
      runSpacing: AppDimens.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        ?trailing,
      ],
    );
  }
}
