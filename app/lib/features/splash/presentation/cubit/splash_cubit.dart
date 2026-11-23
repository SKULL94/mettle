import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'splash_state.dart';

final class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._preferences,
    this._auth, {
    this.minimumDisplay = const Duration(milliseconds: 2500),
  }) : super(const SplashWarmingUp());

  final AppPreferences _preferences;
  final AuthRepository _auth;
  final Duration minimumDisplay;

  Future<void> warmUp() async {
    try {
      await Future.wait<void>([
        _preferences.deviceId(),
        Future<void>.delayed(minimumDisplay),
      ]);

      if (isClosed) return;
      emit(SplashReady(signedIn: _auth.currentUser != null));
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
