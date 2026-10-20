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
