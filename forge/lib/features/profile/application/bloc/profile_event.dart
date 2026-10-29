import 'package:equatable/equatable.dart';

import 'package:forge/features/profile/domain/entities/user_profile.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}

final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();

  @override
  List<Object?> get props => [];
}

final class ProfileSaveRequested extends ProfileEvent {
  const ProfileSaveRequested({required this.profile});

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileFitnessGoalSelected extends ProfileEvent {
  const ProfileFitnessGoalSelected(this.goal);

  final String goal;

  @override
  List<Object?> get props => [goal];
}

final class ProfileExperienceLevelSelected extends ProfileEvent {
  const ProfileExperienceLevelSelected(this.level);

  final String level;

  @override
  List<Object?> get props => [level];
}

/// Raw form input; the Bloc validates it and saves when valid.
final class ProfileSubmitted extends ProfileEvent {
  const ProfileSubmitted({
    required this.displayName,
    required this.heightText,
    required this.weightText,
  });

  final String displayName;
  final String heightText;
  final String weightText;

  @override
  List<Object?> get props => [displayName, heightText, weightText];
}
