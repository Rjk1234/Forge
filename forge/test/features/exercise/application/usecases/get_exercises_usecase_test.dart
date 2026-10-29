import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:forge/features/exercise/domain/usecases/get_exercises_usecase.dart';
import 'package:fpdart/fpdart.dart';

class _FakeRepo implements ExerciseRepository {
  final Either<AppException, List<Exercise>> response;
  _FakeRepo(this.response);

  @override
  Future<Either<AppException, List<Exercise>>> getExercises() async => response;
}

void main() {
  const exercise = Exercise(
    id: 'ex_squat',
    name: 'Squat',
    type: ExerciseType.weighted,
  );

  group('GetExercisesUseCase', () {
    test('delegates to repository and returns Right on success', () async {
      final useCase = GetExercisesUseCase(
        repository: _FakeRepo(Right([exercise])),
      );
      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (exercises) => expect(exercises, [exercise]),
      );
    });

    test('delegates to repository and returns Left on failure', () async {
      final failure = CacheException(message: 'Error');
      final useCase = GetExercisesUseCase(repository: _FakeRepo(Left(failure)));
      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (e) => expect(e.message, 'Error'),
        (_) => fail('Expected Left'),
      );
    });

    test('returns empty list when repository returns empty Right', () async {
      final useCase = GetExercisesUseCase(
        repository: _FakeRepo(const Right([])),
      );
      final result = await useCase();

      result.fold(
        (_) => fail('Expected Right'),
        (exercises) => expect(exercises, isEmpty),
      );
    });
  });
}
