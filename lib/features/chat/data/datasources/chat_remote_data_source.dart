import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ink_mind/core/errors/exceptions.dart';

abstract interface class ChatRemoteDataSource {
  Stream<String> askQuestion(String question);
}

/// Remote data source implementation consuming Gemini SSE byte stream via Dio.
/// Endpoint: POST models/gemini-flash-lite-latest:streamGenerateContent?alt=sse
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Stream<String> askQuestion(String question) async* {
    debugPrint('[ChatRemoteDataSource] Initiating Gemini stream for: "$question"');
    try {
      final response = await _dio.post<ResponseBody>(
        'models/gemini-flash-lite-latest:streamGenerateContent?alt=sse',
        data: {
          'contents': [
            {
              'parts': [
                {'text': question}
              ]
            }
          ],
        },
        options: Options(responseType: ResponseType.stream),
      );

      final responseStream = response.data?.stream;
      if (responseStream == null) {
        throw const ServerException('No stream data received from Gemini API.');
      }

      final lineStream = responseStream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lineStream) {
        final trimmedLine = line.trim();
        if (trimmedLine.startsWith('data: ')) {
          final jsonString = trimmedLine.substring(6).trim();
          if (jsonString.isEmpty || jsonString == '[DONE]') continue;

          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            final candidates = json['candidates'] as List?;
            if (candidates != null && candidates.isNotEmpty) {
              final parts = candidates[0]['content']?['parts'] as List?;
              if (parts != null && parts.isNotEmpty) {
                final text = parts[0]['text'] as String?;
                if (text != null && text.isNotEmpty) {
                  yield text;
                }
              }
            }
          } catch (e) {
            debugPrint('[ChatRemoteDataSource] Error parsing SSE chunk: $e');
          }
        }
      }
    } on DioException catch (e) {
      final message = e.message ?? 'Network error occurred during streaming.';
      debugPrint('[ChatRemoteDataSource] Stream DioException [${e.response?.statusCode}]: $message');
      throw ServerException(message);
    } catch (e) {
      debugPrint('[ChatRemoteDataSource] Stream Exception: $e');
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
