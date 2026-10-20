import '../error/failures.dart';

sealed class Result<T> {
  const Result();

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
