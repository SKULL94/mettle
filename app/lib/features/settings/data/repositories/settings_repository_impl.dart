import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/result/result.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../sessions/data/datasources/session_local_data_source.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/settings_repository.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(
    this._prefs,
    this._sessions,
    this._api,
    this._auth,
  );

  final AppPreferences _prefs;
  final SessionLocalDataSource _sessions;
  final ApiClient _api;
  final AuthRepository _auth;

  @override
  Future<AppThemeMode> themeMode() async =>
      AppThemeMode.fromName(_prefs.themeMode());

  @override
  Future<Result<void>> setThemeMode(AppThemeMode mode) async {
    try {
      await _prefs.setThemeMode(mode.name);
      return const Success(null);
    } on Object {
      return const Failed(CacheFailure());
    }
  }

  @override
  Future<Result<void>> clearSessions() async {
    try {
      await _sessions.clear();
      return const Success(null);
    } on CacheException {
      return const Failed(CacheFailure());
    } on Object {
      return const Failed(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _api.delete(ApiConstants.me);
    } on NetworkException {
      return const Failed(NetworkFailure());
    } on ServerException {
      return const Failed(ServerFailure());
    } on Object {
      return const Failed(UnknownFailure());
    }

    await _auth.signOut();
    return const Success(null);
  }
}
