sealed class SplashState {
  const SplashState();
}

final class SplashWarmingUp extends SplashState {
  const SplashWarmingUp();
}

final class SplashReady extends SplashState {
  const SplashReady();
}

final class SplashFailed extends SplashState {
  const SplashFailed(this.message);

  final String message;
}
