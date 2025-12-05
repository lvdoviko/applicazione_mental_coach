import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:applicazione_mental_coach/features/avatar/domain/models/avatar_config.dart';
import 'package:applicazione_mental_coach/features/avatar/domain/failures/avatar_failure.dart';

/// Repository for managing avatar data with Local-First strategy
/// 
/// Implements:
/// - Download .glb files from Ready Player Me
/// - Store files locally for offline access
/// - Persist metadata in SharedPreferences
/// - Retry logic for failed downloads
class AvatarRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  
  static const String _avatarConfigKey = 'avatar_config';
  // static const String _avatarFileName = 'coach.glb'; // Removed for cache busting
  static const int _maxRetries = 3;

  AvatarRepository({
    required Dio dio,
    required SharedPreferences prefs,
  })  : _dio = dio,
        _prefs = prefs;

  /// Get current avatar configuration
  /// 
  /// Returns AvatarConfigEmpty if no avatar is configured
  /// Returns AvatarConfigLoaded if avatar exists locally
  Future<(AvatarConfig?, AvatarFailure?)> getAvatar() async {
    try {
      final configJson = _prefs.getString(_avatarConfigKey);
      
      if (configJson == null) {
        return (const AvatarConfigEmpty(), null);
      }

      final config = AvatarConfigLoaded.fromJson(
        jsonDecode(configJson) as Map<String, dynamic>,
      );

      // Verify local file still exists
      final file = File(config.localPath);
      if (!await file.exists()) {
        // File was deleted - try to re-download
        return await _redownloadAvatar(config.remoteUrl);
      }

      return (config, null);
    } catch (e) {
      return (null, StorageFailure('Failed to load avatar: $e'));
    }
  }

  /// Save avatar by downloading from Ready Player Me URL
  /// 
  /// Downloads .glb file to local storage and saves metadata
  /// Shows progress via optional callback
  Future<(AvatarConfig?, AvatarFailure?)> saveAvatar(
    String remoteUrl, {
    void Function(int received, int total)? onProgress,
  }) async {
    // Validate URL
    if (!_isValidRpmUrl(remoteUrl)) {
      return (null, const ValidationFailure('Invalid Ready Player Me URL'));
    }

    try {
      // Get local storage directory
      final directory = await _getAvatarDirectory();
      
      // CACHE BUSTING: Use unique filename based on URL hash
      // This ensures WebView reloads the model when avatar changes
      final fileName = 'avatar_${remoteUrl.hashCode}.glb';
      final localPath = '${directory.path}/$fileName';

      // Append query parameters for optimization
      // NUCLEAR OPTION: Force HIGH quality.
      // Medium was still too small (1.1MB) and missing bones.
      // FORZA BRUTA: Ignora i parametri in ingresso e usa quelli "NUCLEAR"
      // Usiamo HIGH quality (2-3MB) per garantire le ossa. Base64 regge fino a 5MB.
      final Uri originalUri = Uri.parse(remoteUrl);
      final Uri newUri = originalUri.replace(queryParameters: {
        'bodyType': 'fullbody', // Sempre fullbody per le ossa
        'quality': 'high',      // High = Sicurezza scheletrica (~3MB)
      });
      
      final String optimizedUrl = newUri.toString();
      debugPrint("🔥 URL NUCLEAR (HIGH QUALITY): $optimizedUrl");

      // Download with retry logic
      await _downloadWithRetry(
        optimizedUrl, // Use the optimized URL for download
        localPath,
        onProgress: onProgress,
      );

      // Create config (store the original remoteUrl, not the optimized one)
      final config = AvatarConfigLoaded(
        remoteUrl: remoteUrl,
        localPath: localPath,
        lastUpdated: DateTime.now(),
      );

      // Save metadata
      await _prefs.setString(_avatarConfigKey, jsonEncode(config.toJson()));

      return (config, null);
    } on DioException catch (e) {
      return (null, _handleDioError(e));
    } catch (e) {
      return (null, FileSystemFailure('Failed to save avatar: $e'));
    }
  }

  /// Delete avatar and all associated data
  Future<(void, AvatarFailure?)> deleteAvatar() async {
    try {
      final configJson = _prefs.getString(_avatarConfigKey);
      
      if (configJson != null) {
        final config = AvatarConfigLoaded.fromJson(
          jsonDecode(configJson) as Map<String, dynamic>,
        );

        // Delete local file
        final file = File(config.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Clear metadata
      await _prefs.remove(_avatarConfigKey);

      return (null, null);
    } catch (e) {
      return (null, StorageFailure('Failed to delete avatar: $e'));
    }
  }

  /// Re-download avatar if local file is missing
  Future<(AvatarConfig?, AvatarFailure?)> _redownloadAvatar(
    String remoteUrl,
  ) async {
    return await saveAvatar(remoteUrl);
  }

  /// Download file with retry logic
  Future<void> _downloadWithRetry(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
    int attempt = 1,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
    } on DioException catch (e) {
      if (attempt < _maxRetries) {
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: attempt * 2));
        return _downloadWithRetry(
          url,
          savePath,
          onProgress: onProgress,
          attempt: attempt + 1,
        );
      }
      rethrow;
    }
  }

  /// Get or create avatar storage directory
  Future<Directory> _getAvatarDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${appDir.path}/avatars');
    
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }
    
    return avatarDir;
  }

  /// Validate Ready Player Me URL format
  bool _isValidRpmUrl(String url) {
    return url.startsWith('https://models.readyplayer.me/') &&
           url.contains('.glb');
  }

  /// Convert Dio errors to domain failures
  AvatarFailure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');
      
      case DioExceptionType.badResponse:
        return DownloadFailure(
          'Download failed: ${error.response?.statusMessage ?? "Unknown error"}',
          statusCode: error.response?.statusCode,
        );
      
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      
      case DioExceptionType.cancel:
        return const DownloadFailure('Download cancelled');
      
      default:
        return DownloadFailure('Download failed: ${error.message}');
    }
  }
}
