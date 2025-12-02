import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/config/app_config.dart';


/// Service for guest (anonymous) authentication
/// Allows users to access chat without account creation
class GuestAuthService {
  final Dio _dio;
  final Uuid _uuid = const Uuid();

  static const String _guestBoxName = 'guest_auth';
  static const String _guestIdKey = 'guest_user_id';
  static const String _guestTokenKey = 'guest_session_token';
  static const String _guestTokenExpiryKey = 'guest_token_expiry';

  Box<String>? _guestBox;

  GuestAuthService({
    Dio? dio,
  })  : _dio = dio ?? Dio();

  /// Initialize guest box
  Future<void> _ensureInitialized() async {
    if (_guestBox == null || !_guestBox!.isOpen) {
      _guestBox = await Hive.openBox<String>(_guestBoxName);
    }
  }

  /// Initialize guest authentication
  /// Creates or retrieves existing guest session
  Future<GuestAuthResult> authenticateAsGuest() async {
    debugPrint('🔐 Starting v1-lite authentication...');

    // Check if we have an existing valid guest session
    final existingToken = await _getStoredGuestToken();
    if (existingToken != null && !await isTokenExpired()) {
      final guestId = await _getOrCreateGuestId();
      debugPrint('✅ Using cached websocket token');
      return GuestAuthResult(
        guestId: guestId, // Kept for local reference, though backend uses session_id
        sessionToken: existingToken,
        isNewGuest: false,
      );
    }

    // Generate Request ID for tracing
    final requestId = _uuid.v4();
    debugPrint('🆔 Request ID: $requestId');

    try {
      _dio.options.baseUrl = AppConfig.baseUrl;

      debugPrint('📡 Calling: ${AppConfig.baseUrl}/v1/auth/session');
      debugPrint('🏢 Tenant: ${AppConfig.tenantId}');
      
      final response = await _dio.post(
        '/v1/auth/session',
        options: Options(
          headers: {
            'X-Tenant-Id': AppConfig.tenantId,
            'Content-Type': 'application/json',
            'X-Request-ID': requestId,
          },
        ),
        data: {
          'tenant_id': AppConfig.tenantId,
          'api_key': AppConfig.apiKey,
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      
      final data = response.data;
      final websocketToken = data['websocket_token'] as String?;
      final sessionId = data['session_id'] as String?;
      final expiresAt = data['expires_at'] as String?;

      if (websocketToken == null || sessionId == null) {
        throw GuestAuthException('Invalid response: missing websocket_token or session_id');
      }

      debugPrint('🎫 Got websocket token');
      debugPrint('🆔 Session ID: $sessionId');

      // Calculate expiry duration
      Duration expiresIn = const Duration(hours: 1); // Default fallback
      if (expiresAt != null) {
        try {
          final expiryDate = DateTime.parse(expiresAt);
          final now = DateTime.now();
          if (expiryDate.isAfter(now)) {
            expiresIn = expiryDate.difference(now);
          }
        } catch (e) {
          debugPrint('⚠️ Failed to parse expires_at: $e');
        }
      }

      // Store the session token (websocket_token)
      await _storeGuestToken(
        websocketToken,
        expiresIn,
      );
      
      // Store session ID as guest ID for consistency
      await _guestBox!.put(_guestIdKey, sessionId);

      return GuestAuthResult(
        guestId: sessionId,
        sessionToken: websocketToken,
        isNewGuest: true,
      );
    } catch (e) {
      debugPrint('❌ Authentication error: $e');
      if (e is DioException) {
        debugPrint('❌ DioException type: ${e.type}');
        debugPrint('❌ Response: ${e.response?.data}');
      }
      throw GuestAuthException('Authentication failed: $e');
    }
  }

  /// Get or create a persistent guest ID
  Future<String> _getOrCreateGuestId() async {
    await _ensureInitialized();

    String? guestId = _guestBox!.get(_guestIdKey);

    if (guestId == null) {
      // Generate new guest ID
      guestId = 'guest_${_uuid.v4()}';
      await _guestBox!.put(_guestIdKey, guestId);
    }

    return guestId;
  }

  /// Store guest token securely
  Future<void> _storeGuestToken(String token, Duration expiresIn) async {
    await _ensureInitialized();

    final expiryTime = DateTime.now().add(expiresIn);

    await _guestBox!.put(_guestTokenKey, token);
    await _guestBox!.put(_guestTokenExpiryKey, expiryTime.toIso8601String());
    await _guestBox!.put('tenant_id', AppConfig.tenantId); // Store tenant ID
  }

  /// Get stored guest token
  Future<String?> _getStoredGuestToken() async {
    await _ensureInitialized();
    
    // Check if tenant changed
    final storedTenant = _guestBox!.get('tenant_id');
    if (storedTenant != AppConfig.tenantId) {
      debugPrint('🔄 Tenant changed ($storedTenant -> ${AppConfig.tenantId}), clearing session...');
      await clearGuestSession();
      return null;
    }

    return _guestBox!.get(_guestTokenKey);
  }

  /// Check if guest token is expired
  Future<bool> isTokenExpired() async {
    await _ensureInitialized();

    // Debug: Simulate token expiry for testing
    if (AppConfig.debugSimulateTokenExpiry) {
      debugPrint('🐛 DEBUG: Simulating token expiry');
      return true;
    }

    final expiryString = _guestBox!.get(_guestTokenExpiryKey);
    if (expiryString == null) return true;

    try {
      final expiry = DateTime.parse(expiryString);
      // Add buffer time for refresh
      return DateTime.now().isAfter(
        expiry.subtract(AppConfig.tokenRefreshBuffer),
      );
    } catch (e) {
      return true;
    }
  }

  /// Get current guest ID if exists
  Future<String?> getCurrentGuestId() async {
    await _ensureInitialized();
    return _guestBox!.get(_guestIdKey);
  }

  /// Get current guest session token if valid
  Future<String?> getValidGuestToken() async {
    final token = await _getStoredGuestToken();
    if (token != null && !await isTokenExpired()) {
      return token;
    }
    return null;
  }

  /// Refresh guest session token
  Future<String> refreshGuestToken() async {
    final result = await authenticateAsGuest();
    return result.sessionToken;
  }

  /// Clear guest session (logout)
  Future<void> clearGuestSession() async {
    await _ensureInitialized();

    await _guestBox!.delete(_guestTokenKey);
    await _guestBox!.delete(_guestTokenExpiryKey);
    // Keep guest_id for potential re-authentication
  }
}


/// Result of guest authentication
class GuestAuthResult {
  final String guestId;
  final String sessionToken;
  final bool isNewGuest;

  GuestAuthResult({
    required this.guestId,
    required this.sessionToken,
    required this.isNewGuest,
  });
}

/// Exception thrown during guest authentication
class GuestAuthException implements Exception {
  final String message;
  final int? statusCode;

  GuestAuthException(this.message, {this.statusCode});

  @override
  String toString() => 'GuestAuthException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
