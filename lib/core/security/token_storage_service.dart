import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Service for secure storage of JWT tokens with encryption
class TokenStorageService {
  static const String _boxName = 'secure_tokens';
  static const String _jwtKey = 'jwt_token';
  static const String _refreshKey = 'refresh_token';
  static const String _expiryKey = 'jwt_expiry';
  
  Box<String>? _secureBox;
  HiveAesCipher? _encryptionCipher;
  
  /// Initialize the secure storage
  Future<void> initialize() async {
    final encryptionKey = await _getEncryptionKey();
    _encryptionCipher = HiveAesCipher(encryptionKey);
    
    _secureBox = await Hive.openBox<String>(
      _boxName,
      encryptionCipher: _encryptionCipher,
    );
  }
  
  /// Store JWT and refresh tokens securely
  Future<void> storeTokens({
    required String jwtToken,
    required String refreshToken,
    DateTime? jwtExpiry,
  }) async {
    await _ensureInitialized();
    
    await _secureBox!.put(_jwtKey, jwtToken);
    await _secureBox!.put(_refreshKey, refreshToken);
    
    if (jwtExpiry != null) {
      await _secureBox!.put(_expiryKey, jwtExpiry.toIso8601String());
    }
  }
  
  /// Get stored JWT token
  Future<String?> getJwtToken() async {
    await _ensureInitialized();
    return _secureBox!.get(_jwtKey);
  }
  
  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    await _ensureInitialized();
    return _secureBox!.get(_refreshKey);
  }
  
  /// Check if JWT token is expired
  Future<bool> isJwtExpired() async {
    await _ensureInitialized();
    
    final expiryString = _secureBox!.get(_expiryKey);
    if (expiryString == null) return true;
    
    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5))); // 5min buffer
  }
  
  /// Clear all stored tokens
  Future<void> clearTokens() async {
    await _ensureInitialized();
    
    await _secureBox!.delete(_jwtKey);
    await _secureBox!.delete(_refreshKey);
    await _secureBox!.delete(_expiryKey);
  }
  
  /// Check if user has valid authentication
  Future<bool> hasValidAuth() async {
    final jwt = await getJwtToken();
    final isExpired = await isJwtExpired();
    
    return jwt != null && !isExpired;
  }
  
  Future<void> _ensureInitialized() async {
    if (_secureBox == null) {
      await initialize();
    }
  }
  
  /// Generate device-specific encryption key
  Future<Uint8List> _getEncryptionKey() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceId;
    
    try {
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else {
        deviceId = 'unknown_platform';
      }
    } catch (e) {
      deviceId = 'fallback_device_id';
    }
    
    // Create deterministic key from device ID and app-specific salt
    const appSalt = 'kaix_mental_coach_v1';
    final combined = '$deviceId:$appSalt';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    
    return Uint8List.fromList(digest.bytes);
  }
}