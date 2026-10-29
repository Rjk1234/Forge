import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/usecases/delete_workout_session_usecase.dart';
import 'package:forge/features/workout_session/domain/usecases/save_workout_session_usecase.dart';
import 'package:forge/features/workout_session/domain/usecases/update_workout_session_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionRepository extends Mock implements WorkoutSessionRepository {}

class _MockExerciseRepository extends Mock implements ExerciseRepository {}

final _original = WorkoutSession(
  sessionId: 's1',
  planId: 'p1',
  planName: 'Push',
  completedAt: DateTime(2026, 9, 7, 19),
  startedAt: DateTime(2026, 9, 7, 18),
  sessionDurationSec: 3600,
  sessionExercises: const [
    SessionExercise(
      exerciseId: 'bench',
      exerciseName: 'Bench',
      type: ExerciseType.weighted,
      actualSets: [ActualSet(repetitions: 5, weight: 60)],
    ),
  ],
);

WorkoutSession _edited({
  List<ActualSet> sets = const [ActualSet(repetitions: 8, weight: 65)],
  String exerciseId = 'bench',
}) {
  return WorkoutSession(
    sessionId: 's1',
    planId: 'tampered',
    planName: 'Tampered',
    completedAt: DateTime(2030),
    startedAt: DateTime(2029),
    sessionDurationSec: 1,
    sessionExercises: [
      SessionExercise(
        exerciseId: exerciseId,
        exerciseName: 'Bench',
        type: ExerciseType.weighted,
        actualSets: sets,
      ),
    ],
  );
}

void main() {
  late _MockSessionRepository repository;
  late _MockExerciseRepository exercises;
  late UpdateWorkoutSessionUseCase update;

  setUpAll(() => registerFallbackValue(_original));

  setUp(() {
    repository = _MockSessionRepository();
    exercises = _MockExerciseRepository();
    when(() => exercises.getExercises()).thenAnswer(
      (_) async => const Right([
        Exercise(id: 'bench', name: 'Bench', type: ExerciseType.weighted),
      ]),
    );
    when(
      () => repository.getSessionById('s1'),
    ).thenAnswer((_) async => Right(_original));
    when(
      () => repository.saveSession(any()),
    ).thenAnswer((_) async => const Right(null));
    update = UpdateWorkoutSessionUseCase(
      repository: repository,
      saveSession: SaveWorkoutSessionUseCase(
        repository: repository,
        exerciseRepository: exercises,
      ),
    );
  });

  group('DeleteWorkoutSessionUseCase', () {
    test('deletes through the repository', () async {
      when(
        () => repository.deleteSession('s1'),
      ).thenAnswer((_) async => const Right(null));

      final result = await DeleteWorkoutSessionUseCase(repository)('s1');

      expect(result.isRight(), isTrue);
      verify(() => repository.deleteSession('s1')).called(1);
    });

    test('returns the repository failure', () async {
      when(
        () => repository.deleteSession('s1'),
      ).thenAnswer((_) async => Left(CacheException(message: 'disk')));

      final result = await DeleteWorkoutSessionUseCase(repository)('s1');

      expect(result.isLeft(), isTrue);
    });
  });

  group('UpdateWorkoutSessionUseCase', () {
    test('saves new sets but keeps ids, times and duration', () async {
      final result = await update(_edited());

      expect(result.isRight(), isTrue);
      final saved =
          verify(() => repository.saveSession(captureAny())).captured.single
              as WorkoutSession;
      expect(saved.sessionId, 's1');
      expect(saved.planId, 'p1');
      expect(saved.planName, 'Push');
      expect(saved.startedAt, _original.startedAt);
      expect(saved.completedAt, _original.completedAt);
      expect(saved.sessionDurationSec, 3600);
      expect(saved.sessionExercises.single.actualSets.single.weight, 65);
    });

    test('rejects an unknown session without writing', () async {
      when(
        () => repository.getSessionById('s1'),
      ).thenAnswer((_) async => const Right(null));

      final result = await update(_edited());

      expect(result.isLeft(), isTrue);
      verifyNever(() => repository.saveSession(any()));
    });

    test('rejects a session with no valid logged set', () async {
      final result = await update(
        _edited(sets: const [ActualSet(skipped: true)]),
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => repository.saveSession(any()));
    });

    test('rejects an out-of-range value', () async {
      final result = await update(
        _edited(sets: const [ActualSet(repetitions: 0, weight: 10)]),
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => repository.saveSession(any()));
    });

    test('rejects an exercise missing from the catalogue', () async {
      final result = await update(_edited(exerciseId: 'ghost'));

      expect(result.isLeft(), isTrue);
      verifyNever(() => repository.saveSession(any()));
    });

    test('returns the read failure', () async {
      when(
        () => repository.getSessionById('s1'),
      ).thenAnswer((_) async => Left(CacheException(message: 'disk')));

      expect((await update(_edited())).isLeft(), isTrue);
    });
  });
}
