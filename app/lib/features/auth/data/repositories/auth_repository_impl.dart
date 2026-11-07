import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._prefs);

  final AuthRemoteDataSource _remote;
  final AppPreferences _prefs;

  @override
  AuthUser? get currentUser => _remote.currentUser;

  @override
  Stream<AuthUser?> get changes => _remote.changes;

  @override
  Future<Result<AuthUser>> signInWithGoogle() async {
    try {
      final user = await _remote.signInWithGoogle();
      await _prefs.setRememberDevice(true);
      return Success(user);
    } on Object catch (error) {
      return Failed(_failureFor(error));
    }
  }

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
    bool rememberDevice = true,
  }) async {
    try {
      final user = await _remote.signInWithEmail(
        email: email,
        password: password,
      );
      await _prefs.setRememberDevice(rememberDevice);
      return Success(user);
    } on Object catch (error) {
      return Failed(_failureFor(error));
    }
  }

  @override
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remote.signUpWithEmail(
        email: email,
        password: password,
      );
      await _prefs.setRememberDevice(true);
      return Success(user);
    } on Object catch (error) {
      return Failed(_failureFor(error));
    }
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    try {
      await _remote.sendPasswordReset(email);
      return const Success(null);
    } on Object catch (error) {
      return Failed(_failureFor(error));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remote.signOut();
      return const Success(null);
    } on Object catch (error) {
      return Failed(_failureFor(error));
    }
  }

  static Failure _failureFor(Object error) => switch (error) {
    AuthCancelledException() => const AuthCancelledFailure(),
    AuthConfirmationPendingException(:final detail) => AuthFailure(
      detail ?? AppStrings.authConfirmEmailSent,
    ),
    AuthException(:final detail) => AuthFailure(detail ?? AppStrings.authFailed),
    sb.AuthRetryableFetchException() => const NetworkFailure(),
    sb.AuthException(:final message) => AuthFailure(message),
    SocketException() => const NetworkFailure(),
    _ => const UnknownFailure(),
  };
}
