import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:applicazione_mental_coach/features/user/models/user_model.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final box = await Hive.openBox<UserModel>('userBox');
    if (box.isNotEmpty) {
      state = box.getAt(0);
    } else {
      // Initialize with default empty user
      state = UserModel();
    }
  }

  Future<void> updateUser({
    String? name,
    int? age,
    String? gender,
    String? languageCode,
    bool? isOnboardingCompleted,
    String? avatarId,
    String? personality,
  }) async {
    final box = await Hive.openBox<UserModel>('userBox');
    
    final currentUser = state ?? UserModel();
    
    if (name != null) currentUser.name = name;
    if (age != null) currentUser.age = age;
    if (gender != null) currentUser.gender = gender;
    if (languageCode != null) currentUser.languageCode = languageCode;
    if (isOnboardingCompleted != null) currentUser.isOnboardingCompleted = isOnboardingCompleted;
    if (avatarId != null) currentUser.avatarId = avatarId;
    if (personality != null) currentUser.personality = personality;

    await box.put(0, currentUser);
    state = currentUser;
  }
  
  Future<void> completeOnboarding() async {
    await updateUser(isOnboardingCompleted: true);
  }
}
