import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._auth) : super(const SignInState());

  final AuthRepository _auth;

  void setMode(AuthMode mode) {
    if (mode == state.mode) return;
    emit(
      state.copyWith(
        mode: mode,
        showErrors: false,
        status: const SignInEditing(),
      ),
    );
  }

  void emailChanged(String value) => emit(
    state.copyWith(email: value, status: const SignInEditing()),
  );

  void passwordChanged(String value) => emit(
    state.copyWith(password: value, status: const SignInEditing()),
  );

  void toggleObscure() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleRemember() =>
      emit(state.copyWith(rememberDevice: !state.rememberDevice));

  Future<void> continueWithGoogle() async {
    if (state.isBusy) return;
    emit(state.copyWith(status: const SignInBusy(AuthAction.google)));
    _settle(await _auth.signInWithGoogle());
  }

  Future<void> submit() async {
    if (state.isBusy) return;

    if (!state.canSubmit) {
      emit(state.copyWith(showErrors: true, status: const SignInEditing()));
      return;
    }

    emit(state.copyWith(status: const SignInBusy(AuthAction.email)));

    final email = state.email.trim();
    final result = state.mode == AuthMode.signIn
        ? await _auth.signInWithEmail(
            email: email,
            password: state.password,
            rememberDevice: state.rememberDevice,
          )
        : await _auth.signUpWithEmail(email: email, password: state.password);

    _settle(result);
  }

  Future<void> forgotPassword() async {
    if (state.isBusy) return;

    if (!state.isEmailValid) {
      emit(state.copyWith(showErrors: true, status: const SignInEditing()));
      return;
    }

    emit(state.copyWith(status: const SignInBusy(AuthAction.reset)));

    switch (await _auth.sendPasswordReset(state.email.trim())) {
      case Success():
        emit(state.copyWith(status: const SignInResetSent()));
      case Failed(:final failure):
        emit(state.copyWith(status: SignInFailed(failure.message)));
    }
  }

  void _settle(Result<AuthUser> result) {
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(status: SignInSucceeded(data)));
      case Failed(failure: AuthCancelledFailure()):
        emit(state.copyWith(status: const SignInEditing()));
      case Failed(:final failure):
        emit(state.copyWith(status: SignInFailed(failure.message)));
    }
  }

  void dismissError() {
    if (state.status is SignInFailed || state.status is SignInResetSent) {
      emit(state.copyWith(status: const SignInEditing()));
    }
  }

  String? get emailError =>
      state.showErrors && !state.isEmailValid ? AppStrings.authEmailInvalid : null;

  String? get passwordError => state.showErrors && !state.isPasswordValid
      ? AppStrings.authPasswordTooShort
      : null;
}
