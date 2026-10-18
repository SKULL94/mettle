import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/app_preferences.dart';
import 'splash_state.dart';

/// Owns application bootstrap.
///
/// A `Cubit` rather than a `Bloc` because there is exactly one thing that
/// happens and no event worth naming — events are documentation, and inventing
/// `BootstrapRequested` here would document nothing.
///
/// This is the one place that constructs its own dependencies instead of
/// resolving them from `sl`: it *is* what builds the container, so it cannot
/// come out of it.
final class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashBootstrapping());

  Future<void> bootstrap() async {
    try {
      // Real work, deliberately un-padded. No artificial delay — a timed splash
      // that waits to look impressive is a tell. This typically lands in
      // 100-300ms, which is why there is no spinner.
      await configureDependencies();

      // Generate-or-load the anonymous device id now so the first API call
      // already has it, rather than racing to create it mid-request.
      await sl<AppPreferences>().deviceId();

      if (isClosed) return;
      emit(const SplashReady());
    } on Object catch (error) {
      // Only local failures are plausible here (corrupt preferences store), and
      // they must never be a dead end — the view offers an inline retry.
      if (isClosed) return;
      emit(SplashFailed('${AppStrings.bootstrapFailed} $error'));
    }
  }

  /// Retry after [SplashFailed]. Resets the container first so a half-finished
  /// registration from the failed attempt can't collide on re-run.
  Future<void> retry() async {
    emit(const SplashBootstrapping());
    await resetDependencies();
    await bootstrap();
  }
}
