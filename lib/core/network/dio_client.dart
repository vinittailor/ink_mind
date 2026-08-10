// Centralized Dio HTTP client configuration.
//
// A single Dio instance is created here and registered in get_it so every
// data source shares the same base options, interceptors, and timeouts. Feature
// code should never construct its own Dio instance.
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ink_mind/core/constants/app_constants.dart';
import 'package:ink_mind/core/network/api_key_interceptor.dart';

/// Returns a fully-configured [Dio] instance ready for injection.
///
/// Attach additional interceptors (logging, auth refresh, etc.) here as the
/// project grows — call sites remain unchanged.
Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.geminiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Interceptor order matters: ApiKey runs first, then logging.
  dio.interceptors.addAll([
    ApiKeyInterceptor(),
    if (kDebugMode)
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
  ]);

  return dio;
}
