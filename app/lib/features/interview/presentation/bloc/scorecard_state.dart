import '../../domain/entities/scorecard.dart';

sealed class ScorecardState {
  const ScorecardState();
}

final class ScorecardLoading extends ScorecardState {
  const ScorecardLoading();
}

final class ScorecardLoaded extends ScorecardState {
  const ScorecardLoaded(this.scorecard);
  final Scorecard scorecard;
}

final class ScorecardError extends ScorecardState {
  const ScorecardError(this.message);
  final String message;
}
