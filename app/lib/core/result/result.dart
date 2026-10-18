import '../error/failures.dart';

/// Success-or-failure carrier.
///
/// Deliberately hand-rolled rather than `dartz`/`fpdart`: a sealed class plus
/// Dart 3 pattern matching gives exhaustiveness checking with no dependency and
/// far better readability at the call site.
///
/// ```dart
/// emit(switch (result) {
///   Success(:final data) => SessionLoaded(data),
///   Failed(:final failure) => SessionError(failure.message),
/// });
/// ```
sealed class Result<T> {
  const Result();

  /// Convenience for the common "did it work?" check. Prefer pattern matching
  /// when you need the payload.
  bool get isSuccess => this is Success<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);
  final Failure failure;
}
