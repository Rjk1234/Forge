import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.displayName,
    required this.fitnessGoal,
    required this.experienceLevel,
    required this.heightCm,
    required this.weightKg,
  });

  final String displayName;
  final String fitnessGoal;
  final String experienceLevel;
  final double heightCm;
  final double weightKg;

  UserProfile copyWith({
    String? displayName,
    String? fitnessGoal,
    String? experienceLevel,
    double? heightCm,
    double? weightKg,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  @override
  List<Object?> get props => [
    displayName,
    fitnessGoal,
    experienceLevel,
    heightCm,
    weightKg,
  ];
}
