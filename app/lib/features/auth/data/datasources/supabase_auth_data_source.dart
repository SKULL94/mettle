import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_user.dart';
import 'auth_remote_data_source.dart';

final class SupabaseAuthDataSource implements AuthRemoteDataSource {
  Future<void>? _googleReady;

  sb.SupabaseClient get _client {
    if (!SupabaseConstants.isConfigured) {
      throw const AuthException(AppStrings.authNotConfigured);
    }
    return sb.Supabase.instance.client;
  }

  @override
  AuthUser? get currentUser {
    if (!SupabaseConstants.isConfigured) return null;
    final user = sb.Supabase.instance.client.auth.currentUser;
    return user == null ? null : _toEntity(user);
  }

  @override
  Stream<AuthUser?> get changes {
    if (!SupabaseConstants.isConfigured) return const Stream.empty();
    return sb.Supabase.instance.client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user == null ? null : _toEntity(user);
    });
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _require(response.user);
  }

  @override
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: SupabaseConstants.redirectUrl,
    );

    if (response.session == null) {
      throw const AuthConfirmationPendingException(
        AppStrings.authConfirmEmailSent,
      );
    }
    return _require(response.user);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    if (!SupabaseConstants.isConfigured) {
      throw const AuthException(AppStrings.authNotConfigured);
    }
    if (SupabaseConstants.googleWebClientId.isEmpty) {
      throw const AuthException(AppStrings.authGoogleNotConfigured);
    }

    await _initGoogle();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const AuthException(AppStrings.authGoogleUnavailable);
    }

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (error) {
      throw error.code == GoogleSignInExceptionCode.canceled
          ? const AuthCancelledException()
          : AuthException(error.description ?? error.code.name);
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthException(AppStrings.authFailed);
    }

    final response = await _client.auth.signInWithIdToken(
      provider: sb.OAuthProvider.google,
      idToken: idToken,
    );
    return _require(response.user);
  }

  @override
  Future<void> sendPasswordReset(String email) => _client.auth
      .resetPasswordForEmail(email, redirectTo: SupabaseConstants.redirectUrl);

  @override
  Future<void> signOut() async {
    if (_googleReady != null) {
      await GoogleSignIn.instance.signOut();
    }
    await _client.auth.signOut();
  }

  Future<void> _initGoogle() {
    return _googleReady ??= GoogleSignIn.instance
        .initialize(
          clientId: defaultTargetPlatform == TargetPlatform.iOS
              ? _orNull(SupabaseConstants.googleIosClientId)
              : null,
          serverClientId: _orNull(SupabaseConstants.googleWebClientId),
        )
        .onError<Object>((error, stackTrace) {
          _googleReady = null;
          Error.throwWithStackTrace(error, stackTrace);
        });
  }

  static String? _orNull(String value) => value.isEmpty ? null : value;

  static AuthUser _require(sb.User? user) {
    if (user == null) throw const AuthException(AppStrings.authFailed);
    return _toEntity(user);
  }

  static AuthUser _toEntity(sb.User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    return AuthUser(
      id: user.id,
      isAnonymous: user.isAnonymous,
      email: user.email,
      displayName:
          metadata['full_name'] as String? ?? metadata['name'] as String?,
      avatarUrl:
          metadata['avatar_url'] as String? ?? metadata['picture'] as String?,
    );
  }
}
