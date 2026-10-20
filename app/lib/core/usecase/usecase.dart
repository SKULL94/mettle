import '../result/result.dart';

abstract interface class UseCase<Out, In> {
  Future<Result<Out>> call(In params);
}

abstract interface class StreamUseCase<Out, In> {
  Stream<Out> call(In params);
}

final class NoParams {
  const NoParams();
}
