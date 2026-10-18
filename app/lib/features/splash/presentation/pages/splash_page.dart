import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

/// Route boundary: provides the cubit and nothing else.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit()..bootstrap(),
      child: const SplashView(),
    );
  }
}

/// Pure UI — takes no dependencies, which is what makes it widget-testable.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocListener for the one-shot navigation effect, BlocBuilder for
    // rendering. Never navigation inside a builder.
    return BlocListener<SplashCubit, SplashState>(
      listenWhen: (previous, current) => current is SplashReady,
      listener: (context, state) {
        // `go`, not `push`: splash leaves the stack, so back-from-Home exits
        // the app instead of returning here.
        context.go(AppRoutes.home);
      },
      child: Scaffold(
        body: Center(
          child: BlocBuilder<SplashCubit, SplashState>(
            builder: (context, state) => switch (state) {
              SplashBootstrapping() || SplashReady() => const _Wordmark(),
              SplashFailed(:final message) => _BootstrapError(message: message),
            },
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(AppStrings.appName, style: theme.textTheme.displaySmall),
        const SizedBox(height: AppDimens.xs),
        Text(AppStrings.appTagline, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

/// Bootstrap only touches local storage, so failure here is rare — but it must
/// never be a dead end.
class _BootstrapError extends StatelessWidget {
  const _BootstrapError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.appName,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.lg),
          FilledButton(
            onPressed: () => context.read<SplashCubit>().retry(),
            child: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}
