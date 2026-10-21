import '../../domain/entities/progress_overview.dart';

sealed class ProgressState {
  const ProgressState();
}

final class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

final class ProgressEmpty extends ProgressState {
  const ProgressEmpty();
}

final class ProgressLoaded extends ProgressState {
  const ProgressLoaded(this.overview);

  final ProgressOverview overview;
}

final class ProgressError extends ProgressState {
  const ProgressError(this.message);

  final String message;
}
