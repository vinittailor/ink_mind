import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ink_mind/core/database/app_database.dart';
import 'package:ink_mind/core/errors/exceptions.dart';
import 'package:ink_mind/features/notes/domain/entities/note_chunk.dart';

abstract interface class NotesLocalDataSource {
  Future<int> insertChunk(
    String text,
    List<double> embedding, {
    String? sourceTitle,
    int? chunkIndex,
    String? createdAt,
  });
  Future<List<Map<String, dynamic>>> getAllChunks();
  Future<List<NoteChunk>> getParsedChunks();
}

/// Local data source for inserting chunk text and JSON-encoded embedding vectors into SQLite.
class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  const NotesLocalDataSourceImpl(this._appDatabase);

  final AppDatabase _appDatabase;

  @override
  Future<int> insertChunk(
    String text,
    List<double> embedding, {
    String? sourceTitle,
    int? chunkIndex,
    String? createdAt,
  }) async {
    try {
      final db = await _appDatabase.database;
      final embeddingJson = jsonEncode(embedding);

      final id = await db.insert('note_chunks', {
        'text': text,
        'embedding': embeddingJson,
        'sourceTitle': sourceTitle,
        'chunkIndex': chunkIndex,
        'createdAt': createdAt,
      });

      final snippet = text.length > 50 ? '${text.substring(0, 50)}...' : text;
      final vectorSnippet = embedding.length > 5 
          ? '[${embedding.take(5).join(', ')}, ... (${embedding.length} dims)]' 
          : embedding.toString();

      debugPrint('[NotesLocalDataSource] 💾 STORED IN SQLITE [ID: #$id]:');
      debugPrint('   ├─ Text: "$snippet"');
      debugPrint('   ├─ Source: "$sourceTitle" | ChunkIndex: #$chunkIndex | CreatedAt: $createdAt');
      debugPrint('   └─ Vector: $vectorSnippet');

      return id;
    } catch (e) {
      debugPrint('[NotesLocalDataSource] SQLite insert error: $e');
      throw CacheException('Failed to save chunk to local database: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllChunks() async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query('note_chunks');
      debugPrint('[NotesLocalDataSource] 📂 DATABASE CONTENT DUMP (${rows.length} total rows in SQLite):');
      for (final row in rows) {
        final id = row['id'];
        final text = row['text'] as String?;
        final embeddingStr = row['embedding'] as String?;
        final snippet = (text != null && text.length > 40) ? '${text.substring(0, 40)}...' : text;
        final listLength = (embeddingStr != null) ? (jsonDecode(embeddingStr) as List).length : 0;
        debugPrint('   ├─ Row #$id | Text: "$snippet" | Vector Size: $listLength dims');
      }
      return rows;
    } catch (e) {
      debugPrint('[NotesLocalDataSource] SQLite query error: $e');
      throw CacheException('Failed to fetch chunks from local database: $e');
    }
  }

  @override
  Future<List<NoteChunk>> getParsedChunks() async {
    final rows = await getAllChunks();
    return rows.map((row) {
      final id = row['id'] as int?;
      final text = row['text'] as String;
      final embeddingJson = row['embedding'] as String;
      final embeddingList = (jsonDecode(embeddingJson) as List)
          .cast<num>()
          .map((n) => n.toDouble())
          .toList();

      return NoteChunk(
        id: id,
        text: text,
        embedding: embeddingList,
        sourceTitle: row['sourceTitle'] as String?,
        chunkIndex: row['chunkIndex'] as int?,
        createdAt: row['createdAt'] as String?,
      );
    }).toList();
  }
}
