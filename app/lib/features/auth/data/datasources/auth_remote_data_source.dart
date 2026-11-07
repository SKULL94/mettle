import '../../domain/entities/auth_user.dart';

abstract interface class AuthRemoteDataSource {
  AuthUser? get currentUser;

  Stream<AuthUser?> get changes;

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
