import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/database/objectbox_database.dart';
import 'package:ink_mind/core/errors/exceptions.dart';
import 'package:ink_mind/core/errors/failures.dart';
import 'package:ink_mind/core/utils/keyword_search.dart';
import 'package:ink_mind/core/utils/reciprocal_rank_fusion.dart';
import 'package:ink_mind/core/utils/text_chunker.dart';
import 'package:ink_mind/features/notes/data/datasources/notes_remote_data_source.dart';
import 'package:ink_mind/features/notes/data/models/note_chunk_objectbox.dart';
import 'package:ink_mind/features/notes/domain/entities/note_chunk.dart';
import 'package:ink_mind/features/notes/domain/repositories/notes_repository.dart';
import 'package:ink_mind/objectbox.g.dart';

/// ObjectBox implementation of [NotesRepository] performing native HNSW vector queries.
class NotesRepositoryObjectBoxImpl implements NotesRepository {
  const NotesRepositoryObjectBoxImpl({
    required NotesRemoteDataSource remoteDataSource,
    required ObjectBoxDatabase objectBoxDatabase,
  })  : _remoteDataSource = remoteDataSource,
        _objectBoxDatabase = objectBoxDatabase;

  final NotesRemoteDataSource _remoteDataSource;
  final ObjectBoxDatabase _objectBoxDatabase;

  @override
  Future<Either<Failure, int>> saveNote(String rawNote) async {
    debugPrint('[NotesRepositoryObjectBoxImpl] ────────── START PROCESSING NOTE (OBJECTBOX) ──────────');
    final chunks = chunkText(rawNote);
    if (chunks.isEmpty) {
      debugPrint('[NotesRepositoryObjectBoxImpl] ❌ Raw note is empty or has no processable text.');
      return const Left(UnexpectedFailure('Cannot process an empty note.'));
    }

    final trimmedNote = rawNote.trim();
    final words = trimmedNote.split(RegExp(r'\s+'));
    final sourceTitle = words.take(5).join(' ');
    final createdAt = DateTime.now().toIso8601String();

    debugPrint('[NotesRepositoryObjectBoxImpl] ✂️ Text chunked into ${chunks.length} total chunk(s):');
    for (var i = 0; i < chunks.length; i++) {
      final snippet = chunks[i].length > 60 ? '${chunks[i].substring(0, 60)}...' : chunks[i];
      debugPrint('   [Chunk #${i + 1}]: "$snippet"');
    }

    var savedCount = 0;
    try {
      final box = _objectBoxDatabase.noteChunkBox;
      debugPrint('[NotesRepositoryObjectBoxImpl] ⚡ Fetching embeddings concurrently for ${chunks.length} chunk(s)...');
      final vectors = await Future.wait(
        chunks.map((chunkText) => _remoteDataSource.fetchEmbedding(chunkText)),
      );

      for (var i = 0; i < chunks.length; i++) {
        final entity = NoteChunkObjectBox(
          text: chunks[i],
          embedding: vectors[i],
          sourceTitle: sourceTitle,
          chunkIndex: i,
          createdAt: createdAt,
        );

        box.put(entity);
        savedCount++;
      }

      debugPrint('[NotesRepositoryObjectBoxImpl] ✅ Successfully saved $savedCount chunks to ObjectBox.');
      debugPrint('[NotesRepositoryObjectBoxImpl] ────────── END PROCESSING NOTE ──────────');

      return Right(savedCount);
    } on ServerException catch (e) {
      debugPrint('[NotesRepositoryObjectBoxImpl] ❌ Server error: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('[NotesRepositoryObjectBoxImpl] ❌ Unexpected error: $e');
      debugPrint('$stackTrace');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NoteChunk>>> getRelevantChunks(String query) async {
    debugPrint('[NotesRepositoryObjectBoxImpl] 🔍 OBJECTBOX HYBRID SEARCH (Semantic + Keyword via RRF) for query: "$query"');
    try {
      final box = _objectBoxDatabase.noteChunkBox;

      if (box.isEmpty()) {
        debugPrint('[NotesRepositoryObjectBoxImpl] ℹ️ ObjectBox store is empty, 0 chunks returned.');
        return const Right([]);
      }

      final results = await Future.wait([
        () async {
          final queryEmbedding = await _remoteDataSource.fetchEmbedding(query);
          final count = box.count();
          final queryBuilder = box.query(
            NoteChunkObjectBox_.embedding.nearestNeighborsF32(queryEmbedding, count > 0 ? count : 10),
          ).build();

          final resultsWithScores = queryBuilder.findWithScores();
          queryBuilder.close();

          return resultsWithScores.map((res) {
            final obj = res.object;
            return NoteChunk(
              id: obj.id,
              text: obj.text,
              embedding: obj.embedding ?? [],
              sourceTitle: obj.sourceTitle,
              chunkIndex: obj.chunkIndex,
              createdAt: obj.createdAt,
              score: res.score,
            );
          }).toList();
        }(),
        Future.value(performKeywordSearch(
          query,
          box.getAll().map((obj) => NoteChunk(
            id: obj.id,
            text: obj.text,
            embedding: obj.embedding ?? [],
            sourceTitle: obj.sourceTitle,
            chunkIndex: obj.chunkIndex,
            createdAt: obj.createdAt,
          )).toList(),
        )),
      ]);

      final semanticChunks = results[0];
      final keywordChunks = results[1];

      final mergedChunks = reciprocalRankFusion(
        semanticResults: semanticChunks,
        keywordResults: keywordChunks,
        k: 60,
      );

      final topChunks = mergedChunks.take(3).toList();

      debugPrint('[NotesRepositoryObjectBoxImpl] 🎯 TOP ${topChunks.length} HYBRID RETRIEVED CHUNKS (RRF):');
      for (var i = 0; i < topChunks.length; i++) {
        final rrfScore = topChunks[i].score?.toStringAsFixed(4) ?? '0.0000';
        final snippet = topChunks[i].text.length > 50 ? '${topChunks[i].text.substring(0, 50)}...' : topChunks[i].text;
        debugPrint('   #${i + 1} [RRF Score: $rrfScore] "$snippet"');
      }

      return Right(topChunks);
    } on ServerException catch (e) {
      debugPrint('[NotesRepositoryObjectBoxImpl] ❌ Server error during retrieval: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('[NotesRepositoryObjectBoxImpl] ❌ Unexpected error during retrieval: $e');
      debugPrint('$stackTrace');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NoteChunk>>> keywordSearch(String query) async {
    try {
      final box = _objectBoxDatabase.noteChunkBox;
      final allEntities = box.getAll();
      final allChunks = allEntities.map((obj) => NoteChunk(
        id: obj.id,
        text: obj.text,
        embedding: obj.embedding ?? [],
        sourceTitle: obj.sourceTitle,
        chunkIndex: obj.chunkIndex,
        createdAt: obj.createdAt,
      )).toList();

      final results = performKeywordSearch(query, allChunks);
      return Right(results);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
