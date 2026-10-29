import 'package:forge/features/profile/data/models/user_profile_record.dart';
import 'package:forge/features/profile/domain/entities/user_profile.dart';

class UserProfileMapper {
  const UserProfileMapper._();

  static UserProfile fromRecord(UserProfileRecord model) {
    return UserProfile(
      displayName: model.displayName,
      fitnessGoal: model.fitnessGoal,
      experienceLevel: model.experienceLevel,
      heightCm: model.heightCm,
      weightKg: model.weightKg,
    );
  }

  static UserProfileRecord toRecord(UserProfile entity, {DateTime? createdAt}) {
    final now = DateTime.now();
    return UserProfileRecord(
      displayName: entity.displayName,
      fitnessGoal: entity.fitnessGoal,
      experienceLevel: entity.experienceLevel,
      heightCm: entity.heightCm,
      weightKg: entity.weightKg,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
  }
}
