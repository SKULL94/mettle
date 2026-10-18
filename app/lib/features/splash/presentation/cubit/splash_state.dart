/// Sealed so an unhandled state is a compile error, not a forgotten branch.
sealed class SplashState {
  const SplashState();
}

final class SplashBootstrapping extends SplashState {
  const SplashBootstrapping();
}

final class SplashReady extends SplashState {
  const SplashReady();
}

final class SplashFailed extends SplashState {
  const SplashFailed(this.message);
  final String message;
}
