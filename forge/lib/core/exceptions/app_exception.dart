/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({required this.message, this.code, this.originalException});

  @override
  String toString() => message;
}

/// Network-related exceptions (no connectivity, timeout, etc.)
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Server-related exceptions (4xx / 5xx responses)
class ServerException extends AppException {
  ServerException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Cache-related exceptions (local storage read/write failures)
class CacheException extends AppException {
  CacheException({required super.message, super.code, super.originalException});
}

/// Parsing-related exceptions (JSON decode failures, type mismatches)
class ParsingException extends AppException {
  ParsingException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Raised when workout data breaks a business rule (blank name, non-positive
/// sets, unknown exercise, …). [code] names the first violated rule.
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code,
    super.originalException,
  });
}
