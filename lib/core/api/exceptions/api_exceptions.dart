/// Base exception for all API-related errors
abstract class ApiException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  
  const ApiException(this.message, {this.code, this.details});
  
  @override
  String toString() => 'ApiException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for network connectivity issues
class NetworkException extends ApiException {
  const NetworkException(super.message, {super.code, super.details});
}

/// Exception for authentication failures
class AuthException extends ApiException {
  const AuthException(super.message, {super.code, super.details});
}

/// Exception for token-related issues
class TokenException extends ApiException {
  const TokenException(super.message, {super.code, super.details});
}

/// Exception for server errors (5xx)
class ServerException extends ApiException {
  final int statusCode;
  
  const ServerException(super.message, this.statusCode, {super.code, super.details});
  
  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Exception for client errors (4xx)
class ClientException extends ApiException {
  final int statusCode;
  
  const ClientException(super.message, this.statusCode, {super.code, super.details});
  
  @override
  String toString() => 'ClientException: $message (status: $statusCode)';
}

/// Exception for rate limiting
class RateLimitException extends ApiException {
  final int? retryAfterSeconds;
  
  const RateLimitException(super.message, {this.retryAfterSeconds, super.code, super.details});
  
  @override
  String toString() => 'RateLimitException: $message${retryAfterSeconds != null ? ' (retry after: ${retryAfterSeconds}s)' : ''}';
}

/// Exception for WebSocket connection issues
class WebSocketException extends ApiException {
  const WebSocketException(super.message, {super.code, super.details});
}

/// Exception for health data sync failures
class HealthSyncException extends ApiException {
  const HealthSyncException(super.message, {super.code, super.details});
}

/// Exception for certificate pinning failures
class CertificatePinningException extends ApiException {
  const CertificatePinningException(super.message, {super.code, super.details});
}

/// Exception for chat-related issues
class ChatException extends ApiException {
  const ChatException(super.message, {super.code, super.details});
}