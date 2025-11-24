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

/// Provider for AvatarRepository
final avatarRepositoryProvider = Provider<AvatarRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider).value;
  
  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }
  
  return AvatarRepository(dio: dio, prefs: prefs);
});

/// Main avatar state provider
class AvatarNotifier extends StateNotifier<AvatarState> {
  final AvatarRepository _repository;

  AvatarNotifier(this._repository) : super(const AvatarStateLoading()) {
    _loadAvatar();
  }

  /// Load avatar from local storage
  Future<void> _loadAvatar() async {
    state = const AvatarStateLoading();
    
    final (config, failure) = await _repository.getAvatar();
    
    if (failure != null) {
      state = AvatarStateError(failure);
    } else if (config != null) {
      state = AvatarStateLoaded(config);
    }
  }

  /// Save new avatar by downloading from RPM URL
  Future<void> saveAvatar(String remoteUrl) async {
    state = const AvatarStateDownloading(0.0);
    
    final (config, failure) = await _repository.saveAvatar(
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
    state = const AvatarStateLoading();
    
    final (_, failure) = await _repository.deleteAvatar();
    
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
}

/// Provider for avatar state
final avatarProvider = StateNotifierProvider<AvatarNotifier, AvatarState>((ref) {
  final repository = ref.watch(avatarRepositoryProvider);
  return AvatarNotifier(repository);
});
