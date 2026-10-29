import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/profile/application/use_cases/get_profile_use_case.dart';
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
  _FakeRepo(this._result);
  final Either<AppException, UserProfile> _result;

  @override
  Future<Either<AppException, UserProfile>> getProfile() async => _result;

  @override
  Future<Either<AppException, UserProfile>> saveProfile(
    UserProfile profile,
  ) async => Right(profile);
}

void main() {
  group('GetProfileUseCase', () {
    test('returns default profile when no record exists', () async {
      final useCase = GetProfileUseCase(
        repository: _FakeRepo(const Right(_defaultProfile)),
      );

      final result = await useCase();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (profile) => expect(profile.experienceLevel, 'Beginner'),
      );
    });

    test('returns saved profile values', () async {
      final useCase = GetProfileUseCase(
        repository: _FakeRepo(const Right(_savedProfile)),
      );

      final result = await useCase();

      expect(result.isRight(), true);
      result.fold((_) => fail('Expected Right'), (profile) {
        expect(profile.displayName, 'Alice');
        expect(profile.fitnessGoal, 'Build Muscle');
        expect(profile.heightCm, 170);
      });
    });

    test('propagates CacheException on read failure', () async {
      final failure = CacheException(message: 'read failed');
      final useCase = GetProfileUseCase(repository: _FakeRepo(Left(failure)));

      final result = await useCase();

      expect(result.isLeft(), true);
      result.fold(
        (e) => expect(e.message, 'read failed'),
        (_) => fail('Expected Left'),
      );
    });
  });
}
