import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../router/app_routes.dart';

/// `errorBuilder` target. Reachable on the web by editing the URL, so it has to
/// offer a way back rather than trapping the visitor.
class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.notFoundTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                AppStrings.notFoundBody,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.lg),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text(AppStrings.navHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
