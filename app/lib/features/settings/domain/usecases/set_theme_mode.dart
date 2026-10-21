import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_theme_mode.dart';
import '../repositories/settings_repository.dart';

class SetThemeMode implements UseCase<void, AppThemeMode> {
  const SetThemeMode(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<void>> call(AppThemeMode params) =>
      _repository.setThemeMode(params);
}
