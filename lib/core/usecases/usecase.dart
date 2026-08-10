// Abstract base class for all use cases in InkMind.
//
// Every use case extends UseCase<Output, Params> where:
//   - Output is the success return type.
//   - Params is a strongly-typed parameter object (use NoParams when the
//     use case takes no arguments).
//
// The call method returns Future<Either<Failure, Output>> — never throws.
// This guarantees that nothing above the repository layer (domain or
// presentation) ever handles raw exceptions.
import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/errors/failures.dart';

/// Base interface for all use cases.
abstract interface class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

/// Use this as the [Params] type when a use case requires no arguments.
///
/// Example:
/// ```dart
/// class GetAllNotesUseCase implements UseCase<List<Note>, NoParams> {
///   @override
///   Future<Either<Failure, List<Note>>> call(NoParams params) async { ... }
/// }
/// ```
final class NoParams {
  const NoParams();
}
