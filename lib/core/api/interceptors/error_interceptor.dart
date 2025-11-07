import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../exceptions/api_exceptions.dart';
import '../models/auth_response.dart';

/// Dio interceptor for error handling and logging
class ErrorInterceptor extends Interceptor {
  final Logger _logger = Logger();
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('API Request: ${options.method} ${options.uri}');
    
    // Don't log sensitive data in production
    if (options.path.contains('auth') || options.path.contains('token')) {
      _logger.d('Request data: [REDACTED - Auth endpoint]');
    } else {
      _logger.d('Request data: ${options.data}');
    }
    
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('API Response: ${response.statusCode} ${response.requestOptions.uri}');
    
    // Don't log sensitive response data
    if (response.requestOptions.path.contains('auth') || 
        response.requestOptions.path.contains('token')) {
      _logger.d('Response data: [REDACTED - Auth endpoint]');
    } else {
      _logger.d('Response data: ${response.data}');
    }
    
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('API Error: ${err.message}', error: err);
    
    // Convert DioException to our custom exceptions
    final customException = _mapDioExceptionToCustomException(err);
    
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      error: customException,
      type: err.type,
    ));
  }
  
  ApiException _mapDioExceptionToCustomException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Request timeout. Please check your internet connection.',
          code: 'TIMEOUT',
        );
        
      case DioExceptionType.badResponse:
        return _handleResponseError(err);
        
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled', code: 'CANCELLED');
        
      case DioExceptionType.connectionError:
        return const NetworkException(
          'Connection failed. Please check your internet connection.',
          code: 'CONNECTION_ERROR',
        );
        
      case DioExceptionType.badCertificate:
        return const CertificatePinningException(
          'Certificate validation failed. Potential security risk detected.',
          code: 'CERT_PINNING_FAILED',
        );
        
      case DioExceptionType.unknown:
      default:
        if (err.error is SocketException) {
          return const NetworkException(
            'No internet connection available.',
            code: 'NO_INTERNET',
          );
        }
        
        return NetworkException(
          'An unexpected error occurred: ${err.message}',
          code: 'UNKNOWN',
        );
    }
  }
  
  ApiException _handleResponseError(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;
    final responseData = err.response?.data;
    
    String message = 'Request failed';
    String? code;
    Map<String, dynamic>? details;
    
    // Try to parse error response
    if (responseData is Map<String, dynamic>) {
      try {
        final errorResponse = ApiErrorResponse.fromJson(responseData);
        message = errorResponse.message;
        code = errorResponse.code;
        details = errorResponse.details;
      } catch (e) {
        // Fallback to raw response data
        message = responseData['message']?.toString() ?? message;
        code = responseData['code']?.toString();
      }
    }
    
    // Map status codes to specific exceptions
    switch (statusCode) {
      case 400:
        return ClientException(message, statusCode, code: code, details: details);
        
      case 401:
        return AuthException(message, code: code, details: details);
        
      case 403:
        return ClientException('Access forbidden', statusCode, code: code, details: details);
        
      case 404:
        return ClientException('Resource not found', statusCode, code: code, details: details);
        
      case 409:
        return ClientException('Conflict - resource already exists', statusCode, code: code, details: details);
        
      case 422:
        return ClientException('Validation failed', statusCode, code: code, details: details);
        
      case 429:
        final retryAfter = _extractRetryAfter(err.response?.headers);
        return RateLimitException(
          'Too many requests. Please try again later.',
          retryAfterSeconds: retryAfter,
          code: code,
          details: details,
        );
        
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          'Server error occurred. Please try again later.',
          statusCode,
          code: code,
          details: details,
        );
        
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return ClientException(message, statusCode, code: code, details: details);
        } else if (statusCode >= 500) {
          return ServerException(message, statusCode, code: code, details: details);
        } else {
          return NetworkException(message, code: code, details: details);
        }
    }
  }
  
  int? _extractRetryAfter(Headers? headers) {
    final retryAfterHeader = headers?.value('retry-after');
    if (retryAfterHeader != null) {
      return int.tryParse(retryAfterHeader);
    }
    return null;
  }
}