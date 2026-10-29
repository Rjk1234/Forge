import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/profile/application/use_cases/save_profile_use_case.dart';
import 'package:forge/features/profile/domain/entities/user_profile.dart';
import 'package:forge/features/profile/domain/repositories/profile_repository.dart';

const _profile = UserProfile(
  displayName: 'Bob',
  fitnessGoal: 'Lose Weight',
  experienceLevel: 'Advanced',
  heightCm: 180,
  weightKg: 80,
);

class _FakeRepo implements ProfileRepository {
  _FakeRepo({required this.saveResult});
  final Either<AppException, UserProfile> saveResult;

  @override
  Future<Either<AppException, UserProfile>> getProfile() async => const Right(
    UserProfile(
      displayName: '',
      fitnessGoal: '',
      experienceLevel: 'Beginner',
      heightCm: 0,
      weightKg: 0,
    ),
  );

  @override
  Future<Either<AppException, UserProfile>> saveProfile(
    UserProfile profile,
  ) async => saveResult;
}

void main() {
  group('SaveProfileUseCase', () {
    test('returns saved profile on success', () async {
      final useCase = SaveProfileUseCase(
        repository: _FakeRepo(saveResult: const Right(_profile)),
      );

      final result = await useCase(_profile);

      expect(result.isRight(), true);
      result.fold((_) => fail('Expected Right'), (profile) {
        expect(profile.displayName, 'Bob');
        expect(profile.weightKg, 80);
      });
    });

    test('propagates CacheException on write failure', () async {
      final failure = CacheException(message: 'write failed');
      final useCase = SaveProfileUseCase(
        repository: _FakeRepo(saveResult: Left(failure)),
      );

      final result = await useCase(_profile);

      expect(result.isLeft(), true);
      result.fold(
        (e) => expect(e.message, 'write failed'),
        (_) => fail('Expected Left'),
      );
    });
  });
}
