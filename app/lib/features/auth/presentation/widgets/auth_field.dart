import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    required this.label,
    required this.icon,
    required this.onChanged,
    this.hint,
    this.obscure = false,
    this.errorText,
    this.suffix,
    this.trailingLabel,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? hint;
  final bool obscure;
  final String? errorText;
  final Widget? suffix;
  final Widget? trailingLabel;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (trailingLabel != null) ...[
              const Spacer(),
              trailingLabel!,
            ],
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        TextField(
          onChanged: onChanged,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          autocorrect: false,
          enableSuggestions: !obscure,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: Icon(icon, size: AppDimens.navIcon),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
