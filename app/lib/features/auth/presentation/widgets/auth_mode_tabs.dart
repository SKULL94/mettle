import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../cubit/sign_in_state.dart';

class AuthModeTabs extends StatelessWidget {
  const AuthModeTabs({required this.mode, required this.onChanged, super.key});

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Row(
        children: [
          _Tab(
            label: AppStrings.authSignIn,
            selected: mode == AuthMode.signIn,
            onTap: () => onChanged(AuthMode.signIn),
          ),
          _Tab(
            label: AppStrings.authSignUp,
            selected: mode == AuthMode.signUp,
            onTap: () => onChanged(AuthMode.signUp),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radius),
          child: Container(
            height: AppDimens.minTouchTarget,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.surfaceContainerHigh
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radius),
              border: selected
                  ? Border.all(color: theme.colorScheme.outlineVariant)
                  : null,
            ),
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: selected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
