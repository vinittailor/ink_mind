import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/errors/failures.dart';
import 'package:ink_mind/core/usecases/usecase.dart';
import 'package:ink_mind/features/notes/domain/entities/note_chunk.dart';
import 'package:ink_mind/features/notes/domain/repositories/notes_repository.dart';

class GetRelevantChunks implements UseCase<List<NoteChunk>, String> {
  const GetRelevantChunks(this.repository);

  final NotesRepository repository;

  @override
  Future<Either<Failure, List<NoteChunk>>> call(String params) {
    return repository.getRelevantChunks(params);
  }
}
