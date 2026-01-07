class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});

  factory ServerException.timeout() =>
      ServerException('Connection timeout', statusCode: 408);
  factory ServerException.unauthorized() =>
      ServerException('Unauthorized access', statusCode: 401);
  factory ServerException.notFound() =>
      ServerException('Resource not found', statusCode: 404);
  factory ServerException.rateLimited() =>
      ServerException('Too many requests', statusCode: 429);
  factory ServerException.serverError() =>
      ServerException('Internal server error', statusCode: 500);

  @override
  String toString() =>
      'ServerException: $message${statusCode != null ? ' (Code: $statusCode)' : ''}';
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  factory NetworkException.noConnection() =>
      NetworkException('No internet connection');
  factory NetworkException.timeout() => NetworkException('Connection timeout');

  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);

  factory AuthenticationException.invalidCredentials() =>
      AuthenticationException('Invalid email or password');
  factory AuthenticationException.emailAlreadyExists() =>
      AuthenticationException('Email already registered');
  factory AuthenticationException.weakPassword() =>
      AuthenticationException('Password is too weak');
  factory AuthenticationException.sessionExpired() =>
      AuthenticationException('Session expired, please login again');

  @override
  String toString() => 'AuthenticationException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  ValidationException(this.message, {this.errors});

  @override
  String toString() => 'ValidationException: $message';
}
