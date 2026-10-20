sealed class HomeEvent {
  const HomeEvent();
}

final class HomeRequested extends HomeEvent {
  const HomeRequested();
}

final class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}

final class HomeErrorDismissed extends HomeEvent {
  const HomeErrorDismissed();
}
