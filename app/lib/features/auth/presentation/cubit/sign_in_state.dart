import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/auth_user.dart';

enum AuthMode { signIn, signUp }

enum AuthAction { google, email, reset }

sealed class SignInStatus {
  const SignInStatus();
}

final class SignInEditing extends SignInStatus {
  const SignInEditing();
}

final class SignInBusy extends SignInStatus {
  const SignInBusy(this.action);

  final AuthAction action;
}

final class SignInFailed extends SignInStatus {
  const SignInFailed(this.message);

  final String message;
}

final class SignInSucceeded extends SignInStatus {
  const SignInSucceeded(this.user);

  final AuthUser user;
}

final class SignInResetSent extends SignInStatus {
  const SignInResetSent();
}

class SignInState {
  const SignInState({
    this.mode = AuthMode.signIn,
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.rememberDevice = true,
    this.showErrors = false,
    this.status = const SignInEditing(),
  });

  final AuthMode mode;
  final String email;
  final String password;
  final bool obscurePassword;
  final bool rememberDevice;
  final bool showErrors;
  final SignInStatus status;

  static final _emailCheck = FormBuilderValidators.compose<String>([
    FormBuilderValidators.required(errorText: AppStrings.authEmailInvalid),
    FormBuilderValidators.email(errorText: AppStrings.authEmailInvalid),
  ]);

  static final _passwordCheck = FormBuilderValidators.compose<String>([
    FormBuilderValidators.required(errorText: AppStrings.authPasswordRequired),
    FormBuilderValidators.minLength(
      8,
      errorText: AppStrings.authPasswordTooShort,
    ),
    FormBuilderValidators.maxLength(
      32,
      errorText: AppStrings.authPasswordTooLong,
    ),
    FormBuilderValidators.hasUppercaseChars(
      errorText: AppStrings.authPasswordNeedsUpper,
    ),
    FormBuilderValidators.hasLowercaseChars(
      errorText: AppStrings.authPasswordNeedsLower,
    ),
    FormBuilderValidators.hasNumericChars(
      errorText: AppStrings.authPasswordNeedsNumber,
    ),
    FormBuilderValidators.hasSpecialChars(
      errorText: AppStrings.authPasswordNeedsSymbol,
    ),
  ]);

  String? get emailIssue => _emailCheck(email.trim());

  String? get passwordIssue => mode == AuthMode.signUp
      ? _passwordCheck(password)
      : (password.isEmpty ? AppStrings.authPasswordRequired : null);

  bool get isEmailValid => emailIssue == null;

  bool get isPasswordValid => passwordIssue == null;

  bool get canSubmit => isEmailValid && isPasswordValid;

  bool get isBusy => status is SignInBusy;

  AuthAction? get busyAction =>
      status is SignInBusy ? (status as SignInBusy).action : null;

  SignInState copyWith({
    AuthMode? mode,
    String? email,
    String? password,
    bool? obscurePassword,
    bool? rememberDevice,
    bool? showErrors,
    SignInStatus? status,
  }) {
    return SignInState(
      mode: mode ?? this.mode,
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberDevice: rememberDevice ?? this.rememberDevice,
      showErrors: showErrors ?? this.showErrors,
      status: status ?? this.status,
    );
  }
}
