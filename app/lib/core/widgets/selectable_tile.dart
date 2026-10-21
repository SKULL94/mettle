import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';

class SelectableTile extends StatelessWidget {
  const SelectableTile({
    required this.selected,
    required this.onTap,
    required this.child,
    this.semanticLabel,
    super.key,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      selected: selected,
      label: semanticLabel,
      button: true,
      child: Material(
        color: selected ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outline,
            width: AppDimens.hairline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDimens.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.md,
                vertical: AppDimens.sm,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
