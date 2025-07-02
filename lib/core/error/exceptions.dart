class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException({required this.message, this.code});
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  const ValidationException({required this.message, this.errors});
}
