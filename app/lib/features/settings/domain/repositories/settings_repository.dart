import '../../../../core/result/result.dart';
import '../entities/app_theme_mode.dart';

abstract interface class SettingsRepository {
  Future<AppThemeMode> themeMode();

  Future<Result<void>> setThemeMode(AppThemeMode mode);

  Future<Result<void>> clearSessions();
}
