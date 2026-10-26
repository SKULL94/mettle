import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/usecases/clear_sessions.dart';
import '../../domain/usecases/get_theme_mode.dart';
import '../../domain/usecases/set_theme_mode.dart';

final class SettingsCubit extends Cubit<AppThemeMode> {
  SettingsCubit(this._getThemeMode, this._setThemeMode, this._clearSessions)
    : super(AppThemeMode.system);

  final GetThemeMode _getThemeMode;
  final SetThemeMode _setThemeMode;
  final ClearSessions _clearSessions;

  Future<void> load() async {
    final result = await _getThemeMode(const NoParams());
    if (isClosed) return;

    if (result case Success(:final data)) emit(data);
  }

  Future<void> selectThemeMode(AppThemeMode mode) async {
    if (mode == state) return;

    final result = await _setThemeMode(mode);
    if (isClosed) return;

    if (result is Success<void>) emit(mode);
  }

  Future<bool> clearSessions() async {
    final result = await _clearSessions(const NoParams());
    return result is Success<void>;
  }
}
