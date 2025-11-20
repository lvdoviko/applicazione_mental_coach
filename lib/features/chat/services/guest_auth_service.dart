import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../core/security/token_storage_service.dart';

/// Service for guest (anonymous) authentication
/// Allows users to access chat without account creation
class GuestAuthService {
  final Dio _dio;
  final TokenStorageService _tokenStorage;
  final Uuid _uuid = const Uuid();

  static const String _guestBoxName = 'guest_auth';
  static const String _guestIdKey = 'guest_user_id';
  static const String _guestTokenKey = 'guest_session_token';
  static const String _guestTokenExpiryKey = 'guest_token_expiry';

  Box<String>? _guestBox;

  GuestAuthService({
    required TokenStorageService tokenStorage,
    Dio? dio,
  })  : _tokenStorage = tokenStorage,
        _dio = dio ?? Dio();

  /// Initialize guest box
  Future<void> _ensureInitialized() async {
    if (_guestBox == null || !_guestBox!.isOpen) {
      _guestBox = await Hive.openBox<String>(_guestBoxName);
    }
  }

  /// Initialize guest authentication
  /// Creates or retrieves existing guest session
  Future<GuestAuthResult> authenticateAsGuest() async {
    debugPrint('🔐 Starting guest authentication...');

    // Check if we have an existing valid guest session
    final existingToken = await _getStoredGuestToken();
    if (existingToken != null && !await _isGuestTokenExpired()) {
      final guestId = await _getOrCreateGuestId();
      debugPrint('✅ Using cached guest token for: $guestId');
      return GuestAuthResult(
        guestId: guestId,
        sessionToken: existingToken,
        isNewGuest: false,
      );
    }

    // Create new guest session
    final guestId = await _getOrCreateGuestId();
    debugPrint('🆔 Guest ID: $guestId');

    try {
      _dio.options.baseUrl = AppConfig.baseUrl;

      debugPrint('📡 Calling: ${AppConfig.baseUrl}/v1/auth/guest');
      debugPrint('🏢 Tenant: ${AppConfig.tenantId}');
      debugPrint('🔑 API Key: ${AppConfig.apiKey.substring(0, 20)}...');

      final response = await _dio.post(
        '/v1/auth/guest',
        options: Options(
          headers: {
            'X-Tenant-Id': AppConfig.tenantId,
            'X-Api-Key': AppConfig.apiKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'guest_id': guestId,
          'device_info': await _getDeviceInfo(),
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      final sessionToken = response.data['session_token'] as String?;
      final expiresIn = response.data['expires_in'] as int? ?? 86400; // Default 24h

      if (sessionToken == null) {
        throw GuestAuthException('Invalid response: missing session_token');
      }

      debugPrint('🎫 Got session token (${sessionToken.length} chars)');
      debugPrint('⏰ Expires in: ${expiresIn}s');

      // Store the guest session token
      await _storeGuestToken(
        sessionToken,
        Duration(seconds: expiresIn),
      );

      return GuestAuthResult(
        guestId: guestId,
        sessionToken: sessionToken,
        isNewGuest: true,
      );
    } catch (e) {
      debugPrint('❌ Guest authentication error: $e');
      if (e is DioException) {
        debugPrint('❌ DioException type: ${e.type}');
        debugPrint('❌ Response: ${e.response?.data}');
        debugPrint('❌ Status: ${e.response?.statusCode}');
        debugPrint('❌ Message: ${e.message}');
      }
      throw GuestAuthException('Guest authentication failed: $e');
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
  }

  /// Get stored guest token
  Future<String?> _getStoredGuestToken() async {
    await _ensureInitialized();
    return _guestBox!.get(_guestTokenKey);
  }

  /// Check if guest token is expired
  Future<bool> _isGuestTokenExpired() async {
    await _ensureInitialized();

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
    if (token != null && !await _isGuestTokenExpired()) {
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

  /// Get device information for guest authentication
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // Return basic device info (privacy-preserving)
    return {
      'platform': 'flutter',
      'timestamp': DateTime.now().toIso8601String(),
    };
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
