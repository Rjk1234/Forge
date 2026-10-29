import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/profile/application/bloc/profile_bloc.dart';
import 'package:forge/features/profile/application/bloc/profile_event.dart';
import 'package:forge/features/profile/application/bloc/profile_state.dart';
import 'package:forge/features/profile/application/use_cases/get_profile_use_case.dart';
import 'package:forge/features/profile/application/use_cases/save_profile_use_case.dart';
import 'package:forge/features/profile/domain/entities/user_profile.dart';
import 'package:forge/features/profile/domain/repositories/profile_repository.dart';

const _defaultProfile = UserProfile(
  displayName: '',
  fitnessGoal: '',
  experienceLevel: 'Beginner',
  heightCm: 0,
  weightKg: 0,
);

const _savedProfile = UserProfile(
  displayName: 'Alice',
  fitnessGoal: 'Build Muscle',
  experienceLevel: 'Intermediate',
  heightCm: 170,
  weightKg: 65,
);

class _FakeRepo implements ProfileRepository {
  _FakeRepo({required this.getResult, required this.saveResult});
  final Either<AppException, UserProfile> getResult;
  final Either<AppException, UserProfile> saveResult;

  @override
  Future<Either<AppException, UserProfile>> getProfile() async => getResult;

  @override
  Future<Either<AppException, UserProfile>> saveProfile(
    UserProfile profile,
  ) async => saveResult;
}

ProfileBloc _makeBloc({
  Either<AppException, UserProfile> getResult = const Right(_defaultProfile),
  Either<AppException, UserProfile> saveResult = const Right(_savedProfile),
}) {
  final repo = _FakeRepo(getResult: getResult, saveResult: saveResult);
  return ProfileBloc(
    getProfile: GetProfileUseCase(repository: repo),
    saveProfile: SaveProfileUseCase(repository: repo),
  );
}

void main() {
  group('ProfileBloc — ProfileLoadRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] on successful load',
      build: _makeBloc,
      act: (bloc) => bloc.add(const ProfileLoadRequested()),
      expect: () => [
        const ProfileLoading(),
        const ProfileLoaded(profile: _defaultProfile),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoadError] on read failure',
      build: () =>
          _makeBloc(getResult: Left(CacheException(message: 'read error'))),
      act: (bloc) => bloc.add(const ProfileLoadRequested()),
      expect: () => [const ProfileLoading(), const ProfileLoadError()],
    );
  });

  group('ProfileBloc — ProfileSaveRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileSaving, ProfileLoaded] on successful save',
      build: _makeBloc,
      act: (bloc) =>
          bloc.add(const ProfileSaveRequested(profile: _defaultProfile)),
      expect: () => [
        const ProfileSaving(profile: _defaultProfile),
        const ProfileLoaded(profile: _savedProfile, showSavedToast: true),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'hides the saved toast after its duration',
      build: _makeBloc,
      act: (bloc) =>
          bloc.add(const ProfileSaveRequested(profile: _defaultProfile)),
      wait: ProfileBloc.savedToastDuration + const Duration(milliseconds: 100),
      expect: () => [
        const ProfileSaving(profile: _defaultProfile),
        const ProfileLoaded(profile: _savedProfile, showSavedToast: true),
        const ProfileLoaded(profile: _savedProfile),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileSaving, ProfileSaveError] on write failure',
      build: () =>
          _makeBloc(saveResult: Left(CacheException(message: 'write error'))),
      act: (bloc) =>
          bloc.add(const ProfileSaveRequested(profile: _defaultProfile)),
      expect: () => [
        const ProfileSaving(profile: _defaultProfile),
        const ProfileSaveError(profile: _defaultProfile),
      ],
    );
  });

  group('ProfileBloc — form editing', () {
    blocTest<ProfileBloc, ProfileState>(
      'stores the chosen fitness goal and experience level',
      build: _makeBloc,
      seed: () => const ProfileLoaded(profile: _defaultProfile),
      act: (bloc) => bloc
        ..add(const ProfileFitnessGoalSelected('Lose Weight'))
        ..add(const ProfileExperienceLevelSelected('Advanced')),
      expect: () => [
        const ProfileLoaded(
          profile: _defaultProfile,
          fitnessGoal: 'Lose Weight',
        ),
        const ProfileLoaded(
          profile: _defaultProfile,
          fitnessGoal: 'Lose Weight',
          experienceLevel: 'Advanced',
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'flags invalid height and weight without saving',
      build: _makeBloc,
      seed: () => const ProfileLoaded(profile: _defaultProfile),
      act: (bloc) => bloc.add(
        const ProfileSubmitted(
          displayName: 'Alice',
          heightText: 'abc',
          weightText: '-3',
        ),
      ),
      expect: () => [
        const ProfileLoaded(
          profile: _defaultProfile,
          hasHeightError: true,
          hasWeightError: true,
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'saves the parsed form with the selected goal and level',
      build: _makeBloc,
      seed: () => const ProfileLoaded(
        profile: _defaultProfile,
        fitnessGoal: 'Build Muscle',
        experienceLevel: 'Intermediate',
      ),
      act: (bloc) => bloc.add(
        const ProfileSubmitted(
          displayName: 'Alice',
          heightText: '170',
          weightText: '65',
        ),
      ),
      expect: () => [
        const ProfileSaving(profile: _savedProfile),
        const ProfileLoaded(profile: _savedProfile, showSavedToast: true),
      ],
    );
  });
}
