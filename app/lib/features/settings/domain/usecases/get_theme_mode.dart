import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_theme_mode.dart';
import '../repositories/settings_repository.dart';

class GetThemeMode implements UseCase<AppThemeMode, NoParams> {
  const GetThemeMode(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<AppThemeMode>> call(NoParams params) async =>
      Success(await _repository.themeMode());
}
