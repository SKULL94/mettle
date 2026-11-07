import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/mettle_mark.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

const _markSize = 96.0;
const _taglineMaxWidth = 280.0;

const _overlay = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: AppColors.bgDark,
  systemNavigationBarIconBrightness: Brightness.light,
);

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit(sl(), sl())..warmUp(),
      child: const SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _overlay,
        child: BlocListener<SplashCubit, SplashState>(
          listener: (context, state) {
            if (state is! SplashReady) return;
            context.go(state.signedIn ? AppRoutes.home : AppRoutes.signIn);
          },
          child: Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.md,
                    vertical: AppDimens.xl,
                  ),
                  child: BlocBuilder<SplashCubit, SplashState>(
                    builder: (context, state) => switch (state) {
                      SplashWarmingUp() || SplashReady() => const _Lockup(),
                      SplashFailed(:final message) => _BootstrapError(
                        message: message,
                      ),
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Lockup extends StatelessWidget {
  const _Lockup();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MettleMark(size: _markSize),
        const SizedBox(height: AppDimens.lg),
        const MettleWordmark(),
        const SizedBox(height: AppDimens.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _taglineMaxWidth),
          child: Text(
            AppStrings.appTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
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
          onPressed: context.read<SplashCubit>().retry,
          child: const Text(AppStrings.retry),
        ),
      ],
    );
  }
}
