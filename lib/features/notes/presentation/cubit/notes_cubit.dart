import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_mind/features/notes/domain/entities/note_chunk.dart';
import 'package:ink_mind/features/notes/domain/usecases/get_relevant_chunks.dart';
import 'package:ink_mind/features/notes/domain/usecases/save_note.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

final class NotesIdle extends NotesState {
  const NotesIdle();
}

final class NotesSaving extends NotesState {
  const NotesSaving();
}

final class NotesSaved extends NotesState {
  const NotesSaved(this.chunkCount);

  final int chunkCount;

  @override
  List<Object?> get props => [chunkCount];
}

final class NotesRetrieving extends NotesState {
  const NotesRetrieving();
}

final class NotesRetrieved extends NotesState {
  const NotesRetrieved(this.chunks);

  final List<NoteChunk> chunks;

  @override
  List<Object?> get props => [chunks];
}

final class NotesError extends NotesState {
  const NotesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NotesCubit extends Cubit<NotesState> {
  NotesCubit({
    required SaveNote saveNote,
    required GetRelevantChunks getRelevantChunks,
  })  : _saveNote = saveNote,
        _getRelevantChunks = getRelevantChunks,
        super(const NotesIdle());

  final SaveNote _saveNote;
  final GetRelevantChunks _getRelevantChunks;

  Future<void> save(String rawNote) async {
    final trimmed = rawNote.trim();
    if (trimmed.isEmpty) {
      emit(const NotesError('Please enter some text before saving.'));
      return;
    }

    debugPrint('[NotesCubit] Saving raw note text...');
    emit(const NotesSaving());

    final result = await _saveNote(trimmed);

    result.fold(
      (failure) {
        debugPrint('[NotesCubit] Error saving note: ${failure.message}');
        emit(NotesError(failure.message));
      },
      (chunkCount) {
        debugPrint('[NotesCubit] Successfully saved $chunkCount chunks.');
        emit(NotesSaved(chunkCount));
      },
    );
  }

  Future<void> testRetrieval(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(const NotesError('Please enter a query to test retrieval.'));
      return;
    }

    debugPrint('[NotesCubit] Testing retrieval for: "$trimmed"');
    emit(const NotesRetrieving());

    final result = await _getRelevantChunks(trimmed);

    result.fold(
      (failure) {
        debugPrint('[NotesCubit] Error retrieving chunks: ${failure.message}');
        emit(NotesError(failure.message));
      },
      (chunks) {
        debugPrint('[NotesCubit] Retrieved ${chunks.length} chunks.');
        emit(NotesRetrieved(chunks));
      },
    );
  }
}
