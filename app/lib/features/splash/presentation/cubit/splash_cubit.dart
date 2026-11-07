import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/app_preferences.dart';
import 'splash_state.dart';

final class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._preferences, {
    this.minimumDisplay = const Duration(milliseconds: 2500),
  }) : super(const SplashWarmingUp());

  final AppPreferences _preferences;
  final Duration minimumDisplay;

  Future<void> warmUp() async {
    try {
      await Future.wait<void>([
        _preferences.deviceId(),
        Future<void>.delayed(minimumDisplay),
      ]);

      if (isClosed) return;
      emit(const SplashReady());
    } on Object catch (error) {
      if (isClosed) return;
      emit(SplashFailed('${AppStrings.bootstrapFailed} $error'));
    }
  }

  Future<void> retry() async {
    emit(const SplashWarmingUp());
    await warmUp();
  }
}
