import '../result/result.dart';

/// One operation, one class, one `call()`.
///
/// A use case that is a thin pass-through to its repository is normal and
/// correct — it is the seam the bloc depends on, which is what keeps blocs
/// testable without a repository. Parameters beyond a single primitive go in a
/// record or a small `*Params` class in the same file as the use case.
abstract interface class UseCase<Out, In> {
  Future<Result<Out>> call(In params);
}

/// For use cases that take no arguments. `void` can't be a type argument here in
/// a way that reads well at the call site, so this exists instead.
final class NoParams {
  const NoParams();
}
