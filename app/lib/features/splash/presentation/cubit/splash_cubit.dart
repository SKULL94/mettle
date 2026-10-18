import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/app_preferences.dart';
import 'splash_state.dart';

final class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashBootstrapping());

  Future<void> bootstrap() async {
    try {
      await configureDependencies();

      await sl<AppPreferences>().deviceId();

      if (isClosed) return;
      emit(const SplashReady());
    } on Object catch (error) {
      if (isClosed) return;
      emit(SplashFailed('${AppStrings.bootstrapFailed} $error'));
    }
  }

  Future<void> retry() async {
    emit(const SplashBootstrapping());
    await resetDependencies();
    await bootstrap();
  }
}
