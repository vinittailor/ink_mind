import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/errors/exceptions.dart';
import 'package:ink_mind/core/errors/failures.dart';
import 'package:ink_mind/core/utils/keyword_search.dart';
import 'package:ink_mind/core/utils/reciprocal_rank_fusion.dart';
import 'package:ink_mind/core/utils/text_chunker.dart';
import 'package:ink_mind/core/utils/vector_math.dart';
import 'package:ink_mind/features/notes/data/datasources/notes_local_data_source.dart';
import 'package:ink_mind/features/notes/data/datasources/notes_remote_data_source.dart';
import 'package:ink_mind/features/notes/domain/entities/note_chunk.dart';
import 'package:ink_mind/features/notes/domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  const NotesRepositoryImpl({
    required NotesRemoteDataSource remoteDataSource,
    required NotesLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final NotesRemoteDataSource _remoteDataSource;
  final NotesLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, int>> saveNote(String rawNote) async {
    debugPrint('[NotesRepositoryImpl] ────────── START PROCESSING NOTE ──────────');
    final chunks = chunkText(rawNote);
    if (chunks.isEmpty) {
      debugPrint('[NotesRepositoryImpl] ❌ Raw note is empty or has no processable text.');
      return const Left(UnexpectedFailure('Cannot process an empty note.'));
    }

    debugPrint('[NotesRepositoryImpl] ✂️ Text chunked into ${chunks.length} total chunk(s):');
    for (var i = 0; i < chunks.length; i++) {
      final snippet = chunks[i].length > 60 ? '${chunks[i].substring(0, 60)}...' : chunks[i];
      debugPrint('   [Chunk #${i + 1}]: "$snippet"');
    }

    final trimmedNote = rawNote.trim();
    final words = trimmedNote.split(RegExp(r'\s+'));
    final sourceTitle = words.take(5).join(' ');
    final createdAt = DateTime.now().toIso8601String();

    var savedCount = 0;
    try {
      debugPrint('[NotesRepositoryImpl] ⚡ Fetching embeddings concurrently for ${chunks.length} chunk(s)...');
      final vectors = await Future.wait(
        chunks.map((chunkText) => _remoteDataSource.fetchEmbedding(chunkText)),
      );

      for (var i = 0; i < chunks.length; i++) {
        await _localDataSource.insertChunk(
          chunks[i],
          vectors[i],
          sourceTitle: sourceTitle,
          chunkIndex: i,
          createdAt: createdAt,
        );
        savedCount++;
      }

      debugPrint('[NotesRepositoryImpl] ✅ Successfully saved $savedCount chunks to SQLite.');
      
      // Print full local DB status dump to console for easy tracking
      await _localDataSource.getAllChunks();
      debugPrint('[NotesRepositoryImpl] ────────── END PROCESSING NOTE ──────────');

      return Right(savedCount);
    } on ServerException catch (e) {
      debugPrint('[NotesRepositoryImpl] ❌ Server error: ${e.message}');
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      debugPrint('[NotesRepositoryImpl] ❌ Cache error: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('[NotesRepositoryImpl] ❌ Unexpected error: $e');
      debugPrint('$stackTrace');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NoteChunk>>> getRelevantChunks(String query) async {
    debugPrint('[NotesRepositoryImpl] 🔍 HYBRID SEARCH (Semantic + Keyword via RRF) for query: "$query"');
    try {
      final storedChunks = await _localDataSource.getParsedChunks();

      if (storedChunks.isEmpty) {
        debugPrint('[NotesRepositoryImpl] ℹ️ Local database is empty, 0 chunks returned.');
        return const Right([]);
      }

      final results = await Future.wait([
        () async {
          final queryEmbedding = await _remoteDataSource.fetchEmbedding(query);
          return compute(
            _rankChunksBySimilarity,
            (queryEmbedding, storedChunks),
          );
        }(),
        Future.value(performKeywordSearch(query, storedChunks)),
      ]);

      final semanticChunks = results[0];
      final keywordChunks = results[1];

      final mergedChunks = reciprocalRankFusion(
        semanticResults: semanticChunks,
        keywordResults: keywordChunks,
        k: 60,
      );

      final topChunks = mergedChunks.take(3).toList();
      debugPrint('[NotesRepositoryImpl] 🎯 TOP ${topChunks.length} HYBRID RETRIEVED CHUNKS (RRF):');
      for (var i = 0; i < topChunks.length; i++) {
        final rrfScore = topChunks[i].score?.toStringAsFixed(4) ?? '0.0000';
        final snippet = topChunks[i].text.length > 50 ? '${topChunks[i].text.substring(0, 50)}...' : topChunks[i].text;
        debugPrint('   #${i + 1} [RRF Score: $rrfScore] "$snippet"');
      }

      return Right(topChunks);
    } on ServerException catch (e) {
      debugPrint('[NotesRepositoryImpl] ❌ Server error during retrieval: ${e.message}');
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      debugPrint('[NotesRepositoryImpl] ❌ Cache error during retrieval: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('[NotesRepositoryImpl] ❌ Unexpected error during retrieval: $e');
      debugPrint('$stackTrace');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NoteChunk>>> keywordSearch(String query) async {
    try {
      final storedChunks = await _localDataSource.getParsedChunks();
      final results = performKeywordSearch(query, storedChunks);
      return Right(results);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

/// Standalone top-level function to compute cosine similarity across stored chunks on a background isolate via [compute].
List<NoteChunk> _rankChunksBySimilarity(
  (List<double> queryEmbedding, List<NoteChunk> storedChunks) params,
) {
  final (queryEmbedding, storedChunks) = params;
  final scoredChunks = storedChunks.map((chunk) {
    final similarity = cosineSimilarity(queryEmbedding, chunk.embedding);
    return chunk.copyWith(score: similarity);
  }).toList();

  scoredChunks.sort((a, b) => (b.score ?? 0.0).compareTo(a.score ?? 0.0));
  return scoredChunks;
}
