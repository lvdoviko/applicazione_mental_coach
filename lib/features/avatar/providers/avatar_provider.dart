import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:applicazione_mental_coach/features/avatar/data/repositories/avatar_repository.dart';
import 'package:applicazione_mental_coach/features/avatar/domain/models/avatar_config.dart';
import 'package:applicazione_mental_coach/features/avatar/domain/failures/avatar_failure.dart';

/// State for avatar management
sealed class AvatarState {
  const AvatarState();
}

class AvatarStateLoading extends AvatarState {
  const AvatarStateLoading();
}

class AvatarStateLoaded extends AvatarState {
  final AvatarConfig config;
  const AvatarStateLoaded(this.config);
}

class AvatarStateError extends AvatarState {
  final AvatarFailure failure;
  const AvatarStateError(this.failure);
}

class AvatarStateDownloading extends AvatarState {
  final double progress; // 0.0 to 1.0
  const AvatarStateDownloading(this.progress);
}

/// Provider for Dio instance (reusing existing from project)
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
});

/// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider for AvatarRepository (with async handling)
final avatarRepositoryProvider = Provider<AvatarRepository?>((ref) {
  final dio = ref.watch(dioProvider);
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  
  return prefsAsync.when(
    data: (prefs) => AvatarRepository(dio: dio, prefs: prefs),
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Main avatar state provider
class AvatarNotifier extends StateNotifier<AvatarState> {
  final AvatarRepository? _repository;

  AvatarNotifier(this._repository) : super(const AvatarStateLoading()) {
    if (_repository != null) {
      _loadAvatar();
    }
  }

  /// Load avatar from local storage
  Future<void> _loadAvatar() async {
    if (_repository == null) return;
    
    state = const AvatarStateLoading();
    
    final (config, failure) = await _repository!.getAvatar();
    
    if (failure != null) {
      state = AvatarStateError(failure);
    } else if (config != null) {
      state = AvatarStateLoaded(config);
    }
  }

  /// Save new avatar by downloading from RPM URL
  Future<void> saveAvatar(String remoteUrl) async {
    if (_repository == null) return;
    
    state = const AvatarStateDownloading(0.0);
    
    final (config, failure) = await _repository!.saveAvatar(
      remoteUrl,
      onProgress: (received, total) {
        if (total > 0) {
          final progress = received / total;
          state = AvatarStateDownloading(progress);
        }
      },
    );
    
    if (failure != null) {
      state = AvatarStateError(failure);
    } else if (config != null) {
      state = AvatarStateLoaded(config);
    }
  }

  /// Delete current avatar
  Future<void> deleteAvatar() async {
    if (_repository == null) return;
    
    state = const AvatarStateLoading();
    
    final (_, failure) = await _repository!.deleteAvatar();
    
    if (failure != null) {
      state = AvatarStateError(failure);
    } else {
      state = const AvatarStateLoaded(AvatarConfigEmpty());
    }
  }

  /// Reload avatar (useful after errors)
  Future<void> reload() async {
    await _loadAvatar();
  }

  /// Load avatar based on ID (Atlas/Serena)
  Future<void> loadAvatarFromId(String avatarId, {bool force = false}) async {
    if (_repository == null) return;

    final url = _getAvatarUrl(avatarId);
    
    // Check if we already have this avatar loaded
    if (!force && state is AvatarStateLoaded) {
      final currentConfig = (state as AvatarStateLoaded).config;
      if (currentConfig is AvatarConfigLoaded && currentConfig.remoteUrl == url) {
        return; // Already loaded
      }
    }

    await saveAvatar(url);
  }

  String _getAvatarUrl(String id) {
    // Atlas (Male)
    if (id == 'atlas') {
      return 'https://models.readyplayer.me/6929b1e97b7a88e1f60a6f9e.glb?bodyType=fullbody&quality=high';
    } 
    // Serena (Female) - Default
    else {
      return 'https://models.readyplayer.me/69286d45132e61458cee2d1f.glb?bodyType=fullbody&quality=high';
    }
  }
}

/// Provider for avatar state
final avatarProvider = StateNotifierProvider<AvatarNotifier, AvatarState>((ref) {
  final repository = ref.watch(avatarRepositoryProvider);
  
  // Return loading state if repository not ready yet
  if (repository == null) {
    return AvatarNotifier(null);
  }
  
  return AvatarNotifier(repository);
});
