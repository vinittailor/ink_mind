// Custom exceptions thrown by data-layer sources.
class ServerException implements Exception {
  const ServerException([this.message = 'Server error.']);
  final String message;

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache error.']);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection.']);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when an on-device model inference or preprocessing operation fails.
class ModelException implements Exception {
  const ModelException([this.message = 'Model error.']);
  final String message;

  @override
  String toString() => 'ModelException: $message';
}
