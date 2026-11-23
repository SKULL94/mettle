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

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool get isEmailValid => _email.hasMatch(email.trim());

  bool get isPasswordValid => password.length >= 8;

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
