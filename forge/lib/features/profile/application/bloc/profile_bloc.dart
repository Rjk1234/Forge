import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:forge/features/profile/application/use_cases/get_profile_use_case.dart';
import 'package:forge/features/profile/application/use_cases/save_profile_use_case.dart';
import 'package:forge/features/profile/application/bloc/profile_event.dart';
import 'package:forge/features/profile/application/bloc/profile_state.dart';
import 'package:forge/features/profile/domain/entities/user_profile.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required this.getProfile, required this.saveProfile})
    : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileSaveRequested>(_onSaveRequested);
    on<ProfileFitnessGoalSelected>(_onFitnessGoalSelected);
    on<ProfileExperienceLevelSelected>(_onExperienceLevelSelected);
    on<ProfileSubmitted>(_onSubmitted);
  }

  static const Duration savedToastDuration = Duration(milliseconds: 2500);

  final GetProfileUseCase getProfile;
  final SaveProfileUseCase saveProfile;

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await getProfile();
    result.fold(
      (failure) => emit(const ProfileLoadError()),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  FutureOr<void> _onSaveRequested(
    ProfileSaveRequested event,
    Emitter<ProfileState> emit,
  ) => _save(event.profile, emit);

  void _onFitnessGoalSelected(
    ProfileFitnessGoalSelected event,
    Emitter<ProfileState> emit,
  ) {
    final current = state;
    if (current is! ProfileLoaded) return;
    emit(current.copyWith(fitnessGoal: event.goal));
  }

  void _onExperienceLevelSelected(
    ProfileExperienceLevelSelected event,
    Emitter<ProfileState> emit,
  ) {
    final current = state;
    if (current is! ProfileLoaded) return;
    emit(current.copyWith(experienceLevel: event.level));
  }

  FutureOr<void> _onSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) {
    final current = state;
    if (current is! ProfileLoaded) return null;

    final isHeightValid = _isValidPositiveNumber(event.heightText);
    final isWeightValid = _isValidPositiveNumber(event.weightText);
    if (!isHeightValid || !isWeightValid) {
      emit(
        current.copyWith(
          hasHeightError: !isHeightValid,
          hasWeightError: !isWeightValid,
        ),
      );
      return null;
    }

    return _save(
      UserProfile(
        displayName: event.displayName,
        fitnessGoal: current.selectedFitnessGoal,
        experienceLevel: current.selectedExperienceLevel,
        heightCm: double.tryParse(event.heightText) ?? 0,
        weightKg: double.tryParse(event.weightText) ?? 0,
      ),
      emit,
    );
  }

  bool _isValidPositiveNumber(String value) {
    if (value.isEmpty) return true;
    final parsed = double.tryParse(value);
    return parsed != null && parsed > 0;
  }

  Future<void> _save(UserProfile profile, Emitter<ProfileState> emit) async {
    emit(ProfileSaving(profile: profile));
    final result = await saveProfile(profile);
    final saved = result.fold((failure) => null, (saved) => saved);
    if (saved == null) {
      emit(ProfileSaveError(profile: profile));
      return;
    }
    emit(ProfileLoaded(profile: saved, showSavedToast: true));
    await Future<void>.delayed(savedToastDuration);
    if (emit.isDone) return;
    final current = state;
    if (current is ProfileLoaded && current.showSavedToast) {
      emit(current.copyWith(showSavedToast: false));
    }
  }
}
