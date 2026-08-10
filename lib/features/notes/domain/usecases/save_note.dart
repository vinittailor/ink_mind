import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/errors/failures.dart';
import 'package:ink_mind/core/usecases/usecase.dart';
import 'package:ink_mind/features/notes/domain/repositories/notes_repository.dart';

class SaveNote implements UseCase<int, String> {
  const SaveNote(this.repository);

  final NotesRepository repository;

  @override
  Future<Either<Failure, int>> call(String params) {
    return repository.saveNote(params);
  }
}
