import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  int? age;

  @HiveField(2)
  String? gender;

  @HiveField(3)
  String? languageCode;

  @HiveField(4)
  bool isOnboardingCompleted;

  @HiveField(5)
  String? avatarId;

  UserModel({
    this.name,
    this.age,
    this.gender,
    this.languageCode,
    this.isOnboardingCompleted = false,
    this.avatarId,
  });
}
