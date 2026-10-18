import '../constants/app_strings.dart';

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
