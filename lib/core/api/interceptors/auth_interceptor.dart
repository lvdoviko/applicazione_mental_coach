import 'package:dio/dio.dart';
import '../../../core/security/token_storage_service.dart';
import '../exceptions/api_exceptions.dart';

/// Dio interceptor for handling JWT authentication and token refresh
class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage;
  final Dio _dio;
  bool _isRefreshing = false;
  
  AuthInterceptor(this._tokenStorage, this._dio);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Skip auth for login and refresh endpoints
      if (_shouldSkipAuth(options.path)) {
        return handler.next(options);
      }
      
      // Check if token is expired and refresh if needed
      if (await _tokenStorage.isJwtExpired()) {
        await _refreshTokenIfNeeded();
      }
      
      // Add JWT token to request
      final token = await _tokenStorage.getJwtToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      
      handler.next(options);
    } catch (e) {
      handler.reject(DioException(
        requestOptions: options,
        error: AuthException('Failed to add authentication: $e'),
      ));
    }
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 unauthorized - try to refresh token
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      try {
        await _refreshTokenIfNeeded();
        
        // Retry the original request with new token
        final token = await _tokenStorage.getJwtToken();
        if (token != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          
          final retryResponse = await _dio.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          
          return handler.resolve(retryResponse);
        }
      } catch (refreshError) {
        // Token refresh failed, clear tokens and let error propagate
        await _tokenStorage.clearTokens();
        return handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: AuthException('Authentication failed: $refreshError'),
        ));
      }
    }
    
    handler.next(err);
  }
  
  bool _shouldSkipAuth(String path) {
    const skipPaths = [
      '/v1/auth/login',
      '/v1/auth/refresh',
      '/v1/auth/register',
    ];
    
    return skipPaths.any((skipPath) => path.contains(skipPath));
  }

  /// Handle WebSocket token requests with enhanced validation
  Future<String?> getWebSocketToken() async {
    try {
      // Ensure JWT token is valid before requesting WebSocket token
      if (await _tokenStorage.isJwtExpired()) {
        await _refreshTokenIfNeeded();
      }

      final jwtToken = await _tokenStorage.getJwtToken();
      if (jwtToken == null) {
        throw const AuthException('No JWT token available for WebSocket token request');
      }

      // Request WebSocket token from backend
      final response = await _dio.post(
        '/v1/auth/ws-token',
        options: Options(
          headers: {'Authorization': 'Bearer $jwtToken'},
        ),
      );

      if (response.statusCode == 200) {
        final wsToken = response.data['ws_token'] as String?;
        if (wsToken == null || wsToken.isEmpty) {
          throw const AuthException('Invalid WebSocket token received from server');
        }
        return wsToken;
      } else {
        throw const AuthException('WebSocket token request failed');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        // JWT expired during WebSocket token request, try refresh once
        try {
          await _refreshTokenIfNeeded();
          return await getWebSocketToken(); // Retry once after refresh
        } catch (refreshError) {
          throw const AuthException('WebSocket token request failed after token refresh');
        }
      }
      throw AuthException('WebSocket token request failed: $e');
    }
  }

  /// Validate WebSocket token format and expiration
  bool isValidWebSocketToken(String token) {
    if (token.isEmpty) return false;
    
    try {
      // Basic format validation - WebSocket tokens should be base64 or JWT format
      // This is a simple check, actual validation would depend on token format
      return token.length > 20 && !token.contains(' ');
    } catch (e) {
      return false;
    }
  }
  
  Future<void> _refreshTokenIfNeeded() async {
    if (_isRefreshing) {
      // Wait for ongoing refresh to complete
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }
    
    _isRefreshing = true;
    
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        throw const AuthException('No refresh token available');
      }
      
      final response = await _dio.post('/v1/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        await _tokenStorage.storeTokens(
          jwtToken: data['access_token'],
          refreshToken: data['refresh_token'] ?? refreshToken,
          jwtExpiry: DateTime.now().add(Duration(seconds: data['expires_in'])),
        );
      } else {
        throw AuthException('Token refresh failed: ${response.statusCode}');
      }
    } finally {
      _isRefreshing = false;
    }
  }
}