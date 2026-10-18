import '../constants/app_strings.dart';

/// Domain-level error. Carries a message that is already safe to show a user —
/// exceptions get translated into these at the repository boundary, so nothing
/// above it has to think about transport details.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = AppStrings.serverError]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = AppStrings.noConnection]);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = AppStrings.cacheError]);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = AppStrings.unknownError]);
}
