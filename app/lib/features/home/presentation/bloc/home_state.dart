import '../../domain/entities/home_overview.dart';

sealed class HomeState {
  const HomeState();
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeEmpty extends HomeState {
  const HomeEmpty();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.overview, {this.staleWarning});

  final HomeOverview overview;

  final String? staleWarning;

  HomeLoaded withWarning(String? warning) =>
      HomeLoaded(overview, staleWarning: warning);
}

final class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
}
