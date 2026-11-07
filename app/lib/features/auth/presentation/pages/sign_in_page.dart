import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/sign_in_cubit.dart';
import '../cubit/sign_in_state.dart';
import '../widgets/auth_field.dart';
import '../widgets/auth_mode_tabs.dart';
import '../widgets/google_mark.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignInCubit(sl()),
      child: const SignInView(),
    );
  }
}

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInCubit, SignInState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        switch (state.status) {
          case SignInSucceeded():
            context.go(AppRoutes.home);
          case SignInFailed(:final message):
            messenger.showSnackBar(SnackBar(content: Text(message)));
            context.read<SignInCubit>().dismissError();
          case SignInResetSent():
            messenger.showSnackBar(
              const SnackBar(content: Text(AppStrings.authResetSent)),
            );
            context.read<SignInCubit>().dismissError();
          case SignInEditing() || SignInBusy():
            break;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<SignInCubit, SignInState>(
            builder: (context, state) => _Form(state: state),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.state});

  final SignInState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<SignInCubit>();
    final isSignIn = state.mode == AuthMode.signIn;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.md,
        AppDimens.sm,
        AppDimens.md,
        AppDimens.xl,
      ),
      children: [
        // const _BrandRow(),
        const SizedBox(height: AppDimens.lg),

        AuthModeTabs(mode: state.mode, onChanged: cubit.setMode),
        const SizedBox(height: AppDimens.xl),

        Text(
          isSignIn ? AppStrings.authWelcomeBack : AppStrings.authCreateAccount,
          style: theme.textTheme.displaySmall,
        ),
        const SizedBox(height: AppDimens.sm),
        Text(
          AppStrings.authSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimens.xl),

        _GoogleButton(
          busy: state.busyAction == AuthAction.google,
          onPressed: state.isBusy ? null : cubit.continueWithGoogle,
        ),
        const SizedBox(height: AppDimens.lg),

        const _EmailDivider(),
        const SizedBox(height: AppDimens.lg),

        AuthField(
          label: AppStrings.authEmailLabel,
          hint: AppStrings.authEmailHint,
          icon: Icons.mail_outline_rounded,
          errorText: cubit.emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: cubit.emailChanged,
        ),
        const SizedBox(height: AppDimens.md),

        AuthField(
          label: AppStrings.authPasswordLabel,
          icon: Icons.lock_outline_rounded,
          obscure: state.obscurePassword,
          errorText: cubit.passwordError,
          textInputAction: TextInputAction.done,
          onChanged: cubit.passwordChanged,
          onSubmitted: (_) => cubit.submit(),
          trailingLabel: isSignIn
              ? _ForgotPassword(
                  onPressed: state.isBusy ? null : cubit.forgotPassword,
                )
              : null,
          suffix: IconButton(
            onPressed: cubit.toggleObscure,
            tooltip: state.obscurePassword
                ? AppStrings.authShowPassword
                : AppStrings.authHidePassword,
            icon: Icon(
              state.obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.md),

        _RememberDevice(
          value: state.rememberDevice,
          onChanged: (_) => cubit.toggleRemember(),
        ),
        const SizedBox(height: AppDimens.lg),

        _SubmitButton(
          label: isSignIn
              ? AppStrings.authSubmitSignIn
              : AppStrings.authSubmitSignUp,
          busy: state.busyAction == AuthAction.email,
          onPressed: state.isBusy ? null : cubit.submit,
        ),
        const SizedBox(height: AppDimens.lg),

        _SwitchModePrompt(
          mode: state.mode,
          onPressed: () => cubit.setMode(
            isSignIn ? AuthMode.signUp : AuthMode.signIn,
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: AppDimens.ctaHeight,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceContainer,
          foregroundColor: theme.colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius),
          ),
        ),
        child: busy
            ? const SizedBox.square(
                dimension: AppDimens.iconMd,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GoogleMark(),
                  const SizedBox(width: AppDimens.sm),
                  Flexible(
                    child: Text(
                      AppStrings.authContinueGoogle,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmailDivider extends StatelessWidget {
  const _EmailDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
          child: Text(
            AppStrings.authEmailDivider,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _ForgotPassword extends StatelessWidget {
  const _ForgotPassword({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPressed,
      child: Text(
        AppStrings.authForgotPassword,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _RememberDevice extends StatelessWidget {
  const _RememberDevice({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppDimens.radius),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged),
          const SizedBox(width: AppDimens.xs),
          Expanded(
            child: Text(
              AppStrings.authRememberDevice,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.ctaHeight,
      child: FilledButton(
        onPressed: onPressed,
        child: busy
            ? const SizedBox.square(
                dimension: AppDimens.iconMd,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(label, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  const Icon(Icons.arrow_forward_rounded, size: AppDimens.iconMd),
                ],
              ),
      ),
    );
  }
}

class _SwitchModePrompt extends StatelessWidget {
  const _SwitchModePrompt({required this.mode, required this.onPressed});

  final AuthMode mode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSignIn = mode == AuthMode.signIn;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            isSignIn ? AppStrings.authNoAccount : AppStrings.authHaveAccount,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            isSignIn ? AppStrings.authSignUp : AppStrings.authSignIn,
          ),
        ),
      ],
    );
  }
}
