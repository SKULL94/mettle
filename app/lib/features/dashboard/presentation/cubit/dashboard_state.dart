import '../../domain/entities/user_summary.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  const DashboardLoaded(this.summary, {this.staleWarning});

  final UserSummary summary;
  final String? staleWarning;

  DashboardLoaded withWarning(String? warning) =>
      DashboardLoaded(summary, staleWarning: warning);
}

final class DashboardError extends DashboardState {
  const DashboardError(this.message);

  final String message;
}
