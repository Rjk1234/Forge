import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/stats/application/use_cases/get_statistics_use_case.dart';
import 'package:forge/features/workout_session/application/use_cases/get_workout_history_use_case.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements WorkoutSessionRepository {}

WorkoutSession _session(String id, DateTime startedAt) => WorkoutSession(
  sessionId: id,
  planId: 'p',
  planName: 'Plan $id',
  completedAt: startedAt.add(const Duration(hours: 1)),
  startedAt: startedAt,
  sessionDurationSec: 3600,
  sessionExercises: const [
    SessionExercise(
      exerciseId: 'sq',
      exerciseName: 'Squat',
      type: ExerciseType.weighted,
      actualSets: [ActualSet(repetitions: 5, weight: 100)],
    ),
  ],
);

void main() {
  late _MockRepository repository;
  late GetWorkoutHistoryUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = GetWorkoutHistoryUseCase(repository);
  });

  test('sorts sessions newest first', () async {
    final older = _session('older', DateTime(2026, 8, 1));
    final newer = _session('newer', DateTime(2026, 9, 1));
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Right([older, newer]));

    final result = await useCase();

    expect(result.getOrElse((_) => []), [newer, older]);
  });

  test('lists only completed sessions', () async {
    final valid = _session('valid', DateTime(2026, 9, 1));
    final invalid = WorkoutSession(
      sessionId: 'invalid',
      planId: 'p',
      planName: 'Plan',
      completedAt: DateTime(2026, 9, 2),
      startedAt: DateTime(2026, 9, 2),
      sessionDurationSec: 60,
      sessionExercises: const [
        SessionExercise(
          exerciseId: 'sq',
          exerciseName: 'Squat',
          type: ExerciseType.weighted,
          actualSets: [ActualSet(repetitions: 5), ActualSet(skipped: true)],
        ),
      ],
    );
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Right([invalid, valid]));

    expect((await useCase()).getOrElse((_) => []), [valid]);
  });

  test('equal start times fall back to completion time then id', () async {
    final start = DateTime(2026, 9, 1);
    final a = _session('a', start);
    final b = _session('b', start);
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Right([a, b]));
    expect((await useCase()).getOrElse((_) => []), [b, a]);

    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Right([b, a]));
    expect((await useCase()).getOrElse((_) => []), [b, a]);
  });

  test('does not mutate the repository list', () async {
    final older = _session('older', DateTime(2026, 8, 1));
    final newer = _session('newer', DateTime(2026, 9, 1));
    final source = [older, newer];
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Right(source));

    await useCase();

    expect(source, [older, newer]);
  });

  test('empty list stays empty', () async {
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => const Right([]));

    final result = await useCase();

    expect(result.getOrElse((_) => [_session('x', DateTime(2026))]), isEmpty);
  });

  test('passes a failure through unchanged', () async {
    final failure = CacheException(message: 'read failed');
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Left(failure));

    final result = await useCase();

    expect(result, Left<AppException, List<WorkoutSession>>(failure));
  });

  test('history count equals the Stats workouts completed', () async {
    final invalid = WorkoutSession(
      sessionId: 'invalid',
      planId: 'p',
      planName: 'Plan',
      completedAt: DateTime(2026, 9, 2),
      startedAt: DateTime(2026, 9, 2),
      sessionDurationSec: 60,
      sessionExercises: const [
        SessionExercise(
          exerciseId: 'sq',
          exerciseName: 'Squat',
          type: ExerciseType.weighted,
          actualSets: [ActualSet(weight: 100)],
        ),
      ],
    );
    final sessions = [
      _session('a', DateTime(2026, 9, 1)),
      invalid,
      _session('b', DateTime(2026, 9, 3)),
    ];
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Right(sessions));

    final history = (await useCase()).getOrElse((_) => []);
    final stats = (await GetStatisticsUseCase(
      repository,
    )()).getOrElse((_) => throw StateError('failed'));

    expect(history, hasLength(2));
    expect(history.length, stats.stats.totalWorkoutsCompleted);
  });
}
