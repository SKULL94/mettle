/// Typed exceptions thrown by data sources.
///
/// Data sources `throw` these; repository implementations catch them and return
/// `Failed(...)`. Nothing above the repository layer uses `try/catch` for domain
/// errors — a bloc reads a `Result` and never catches.
sealed class AppException implements Exception {
  const AppException([this.detail]);

  /// Developer-facing context. Never shown to a user — the user-facing copy
  /// lives on the `Failure` this maps to.
  final String? detail;

  @override
  String toString() =>
      detail == null ? '$runtimeType' : '$runtimeType: $detail';
}

final class ServerException extends AppException {
  const ServerException([super.detail, this.statusCode]);
  final int? statusCode;
}

final class NetworkException extends AppException {
  const NetworkException([super.detail]);
}

final class CacheException extends AppException {
  const CacheException([super.detail]);
}

/// The stream closed or malformed mid-turn. Distinct from a plain network drop
/// because the Interview screen must preserve the transcript and offer an
/// inline retry rather than replacing the screen with an error.
final class StreamException extends AppException {
  const StreamException([super.detail]);
}
