import 'package:equatable/equatable.dart';

import 'package:forge/features/profile/domain/entities/user_profile.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();

  @override
  List<Object?> get props => [];
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();

  @override
  List<Object?> get props => [];
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.profile,
    this.fitnessGoal,
    this.experienceLevel,
    this.hasHeightError = false,
    this.hasWeightError = false,
    this.showSavedToast = false,
  });

  static const String defaultExperienceLevel = 'Beginner';

  final UserProfile profile;

  /// Unsaved picker choices; fall back to the stored [profile] when null.
  final String? fitnessGoal;
  final String? experienceLevel;
  final bool hasHeightError;
  final bool hasWeightError;
  final bool showSavedToast;

  String get selectedFitnessGoal => fitnessGoal ?? profile.fitnessGoal;

  String get selectedExperienceLevel =>
      experienceLevel ??
      (profile.experienceLevel.isEmpty
          ? defaultExperienceLevel
          : profile.experienceLevel);

  bool get hasValidationError => hasHeightError || hasWeightError;

  ProfileLoaded copyWith({
    String? fitnessGoal,
    String? experienceLevel,
    bool? hasHeightError,
    bool? hasWeightError,
    bool? showSavedToast,
  }) {
    return ProfileLoaded(
      profile: profile,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      hasHeightError: hasHeightError ?? this.hasHeightError,
      hasWeightError: hasWeightError ?? this.hasWeightError,
      showSavedToast: showSavedToast ?? this.showSavedToast,
    );
  }

  @override
  List<Object?> get props => [
    profile,
    fitnessGoal,
    experienceLevel,
    hasHeightError,
    hasWeightError,
    showSavedToast,
  ];
}

final class ProfileSaving extends ProfileState {
  const ProfileSaving({required this.profile});

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileLoadError extends ProfileState {
  const ProfileLoadError();

  @override
  List<Object?> get props => [];
}

final class ProfileSaveError extends ProfileState {
  const ProfileSaveError({required this.profile});

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}
