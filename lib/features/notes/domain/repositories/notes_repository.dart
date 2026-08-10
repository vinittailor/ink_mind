import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/errors/failures.dart';
import 'package:ink_mind/features/notes/domain/entities/note_chunk.dart';

abstract interface class NotesRepository {
  /// Chunks the raw note text, fetches embeddings for each chunk,
  /// saves them locally to SQLite, and returns the count of saved chunks.
  Future<Either<Failure, int>> saveNote(String rawNote);

  /// Embeds the query text, compares against local chunk vectors using semantic similarity
  /// and keyword word matching, merges them via RRF, and returns top 3 [NoteChunk]s.
  Future<Either<Failure, List<NoteChunk>>> getRelevantChunks(String query);

  /// Performs keyword search matching query significant words against stored chunk text,
  /// returning chunks ranked by match count.
  Future<Either<Failure, List<NoteChunk>>> keywordSearch(String query);
}
