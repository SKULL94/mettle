sealed class AppException implements Exception {
  const AppException([this.detail]);

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

final class StreamException extends AppException {
  const StreamException([super.detail]);
}

final class AuthException extends AppException {
  const AuthException([super.detail]);
}

final class AuthCancelledException extends AppException {
  const AuthCancelledException([super.detail]);
}

final class AuthConfirmationPendingException extends AppException {
  const AuthConfirmationPendingException([super.detail]);
}
