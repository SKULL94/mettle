import '../../../../core/result/result.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;

  Stream<AuthUser?> get changes;

  Future<Result<AuthUser>> signInWithGoogle();

  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
    bool rememberDevice,
  });

  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<Result<void>> sendPasswordReset(String email);

  Future<Result<void>> signOut();
}
