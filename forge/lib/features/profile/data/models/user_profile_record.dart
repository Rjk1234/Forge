/// The single local user profile row, stored under [kProfileKey].
class UserProfileRecord {
  final String displayName;

  final String fitnessGoal;

  /// 'Beginner' | 'Intermediate' | 'Advanced'
  final String experienceLevel;

  final double heightCm;

  final double weightKg;

  final DateTime createdAt;

  final DateTime updatedAt;

  const UserProfileRecord({
    required this.displayName,
    required this.fitnessGoal,
    required this.experienceLevel,
    required this.heightCm,
    required this.weightKg,
    required this.createdAt,
    required this.updatedAt,
  });
}
