import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ink_mind/core/errors/exceptions.dart';

abstract interface class NotesRemoteDataSource {
  Future<List<double>> fetchEmbedding(String text);
}

/// Remote data source for generating vector embeddings via Gemini REST API (gemini-embedding-2).
class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  const NotesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<double>> fetchEmbedding(String text) async {
    final snippet = text.length > 40 ? '${text.substring(0, 40)}...' : text;
    debugPrint('[NotesRemoteDataSource] 🌐 Requesting embedding from Gemini (gemini-embedding-2) for: "$snippet"');
    try {
      final response = await _dio.post(
        'models/gemini-embedding-2:embedContent',
        data: {
          'model': 'models/gemini-embedding-2',
          'content': {
            'parts': [
              {'text': text}
            ]
          }
        },
      );

      final embeddingObj = response.data['embedding'];
      if (embeddingObj != null && embeddingObj['values'] != null) {
        final values = (embeddingObj['values'] as List).cast<num>().map((n) => n.toDouble()).toList();
        final vectorPreview = values.length > 4 ? '[${values.take(4).join(', ')}, ... ${values.length} dims]' : values.toString();
        debugPrint('[NotesRemoteDataSource] ✅ Embedding received: $vectorPreview');
        return values;
      }
      throw const ServerException('Empty or malformed embedding payload received.');
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['error']?['message'];
      final message = serverMessage ?? e.message ?? 'Network error fetching embedding.';
      debugPrint('[NotesRemoteDataSource] ❌ DioException [${e.response?.statusCode}]: $message');
      throw ServerException(message.toString());
    } catch (e) {
      debugPrint('[NotesRemoteDataSource] ❌ Exception: $e');
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
