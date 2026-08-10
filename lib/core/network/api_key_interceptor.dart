// Interceptor that injects the Gemini API key into outgoing requests via X-goog-api-key header.
//
// This is the single place to add, remove, or rotate API keys.
// Feature data sources never reference keys directly — they depend on the
// shared Dio instance which already has this interceptor attached.
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ??
        const String.fromEnvironment('GEMINI_API_KEY');

    if (apiKey.isEmpty) {
      throw StateError(
        'GEMINI_API_KEY environment variable is missing. '
        'Please set GEMINI_API_KEY in your .env file or pass --dart-define=GEMINI_API_KEY=your_key_here',
      );
    }

    // Inject the key via X-goog-api-key header as specified in official Google API curl docs
    options.headers['X-goog-api-key'] = apiKey;
    debugPrint('[ApiKeyInterceptor] Injected X-goog-api-key header to ${options.path}');

    handler.next(options);
  }
}
