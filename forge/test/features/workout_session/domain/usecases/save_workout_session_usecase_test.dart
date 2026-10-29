import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/usecases/save_workout_session_usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../helpers/fake_exercise_repository.dart';

class _RecordingRepository implements WorkoutSessionRepository {
  final List<WorkoutSession> saved = [];

  @override
  Future<Either<AppException, void>> saveSession(WorkoutSession session) async {
    saved.add(session);
    return const Right(null);
  }

  @override
  Future<Either<AppException, List<WorkoutSession>>> getAllSessions() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, List<WorkoutSession>>> getSessionsByPlanId(
    String planId,
  ) => throw UnimplementedError();

  @override
  Future<Either<AppException, WorkoutSession?>> getSessionById(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, void>> deleteSession(String sessionId) =>
      throw UnimplementedError();
}

const _catalogue = [
  Exercise(id: 'ex_bench', name: 'Bench Press', type: ExerciseType.weighted),
];

WorkoutSession _session({
  String exerciseId = 'ex_bench',
  List<ActualSet>? sets,
}) {
  final start = DateTime(2026, 1, 1, 9);
  return WorkoutSession(
    sessionId: 's1',
    planId: 'p1',
    planName: 'Push',
    completedAt: start.add(const Duration(hours: 1)),
    startedAt: start,
    sessionDurationSec: 3600,
    sessionExercises: [
      SessionExercise(
        exerciseId: exerciseId,
        exerciseName: 'Bench Press',
        type: ExerciseType.weighted,
        actualSets: sets ?? const [ActualSet(repetitions: 8, weight: 60)],
      ),
    ],
  );
}

SaveWorkoutSessionUseCase _useCase(_RecordingRepository repository) =>
    SaveWorkoutSessionUseCase(
      repository: repository,
      exerciseRepository: const FakeExerciseRepository(_catalogue),
    );

void main() {
  test('saves a valid session', () async {
    final repository = _RecordingRepository();

    final result = await _useCase(repository)(_session());

    expect(result.isRight(), isTrue);
    expect(repository.saved, hasLength(1));
  });

  test('rejects a session with no valid logged set', () async {
    final repository = _RecordingRepository();

    final result = await _useCase(repository)(
      _session(sets: const [ActualSet(skipped: true)]),
    );

    result.fold(
      (error) => expect(error.code, 'noValidLoggedSet'),
      (_) => fail('expected a failure'),
    );
    expect(repository.saved, isEmpty);
  });

  test('rejects a weighted set logged without a weight', () async {
    final repository = _RecordingRepository();

    final result = await _useCase(repository)(
      _session(sets: const [ActualSet(repetitions: 8)]),
    );

    expect(result.isLeft(), isTrue);
    expect(repository.saved, isEmpty);
  });

  test('rejects an exercise that is not in the catalogue', () async {
    final repository = _RecordingRepository();

    final result = await _useCase(repository)(
      _session(exerciseId: 'ex_missing'),
    );

    result.fold(
      (error) => expect(error.code, 'unknownExercise'),
      (_) => fail('expected a failure'),
    );
    expect(repository.saved, isEmpty);
  });

  test('passes a catalogue failure through and saves nothing', () async {
    final repository = _RecordingRepository();
    final failure = CacheException(message: 'catalogue unavailable');
    final useCase = SaveWorkoutSessionUseCase(
      repository: repository,
      exerciseRepository: FakeExerciseRepository(_catalogue, failure: failure),
    );

    final result = await useCase(_session());

    result.fold(
      (error) => expect(error, same(failure)),
      (_) => fail('expected a failure'),
    );
    expect(repository.saved, isEmpty);
  });
}
