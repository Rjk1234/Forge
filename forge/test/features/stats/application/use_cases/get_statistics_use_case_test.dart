import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/stats/application/use_cases/get_statistics_use_case.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements WorkoutSessionRepository {}

SessionExercise _exercise(
  String name,
  ExerciseType type,
  List<ActualSet> sets,
) => SessionExercise(
  exerciseId: name,
  exerciseName: name,
  type: type,
  actualSets: sets,
);

WorkoutSession _session(
  int day,
  List<SessionExercise> exercises, {
  int durationSec = 3600,
}) => WorkoutSession(
  sessionId: 's$day',
  planId: 'p',
  planName: 'Plan',
  completedAt: DateTime(2026, 9, day),
  startedAt: DateTime(2026, 9, day),
  sessionDurationSec: durationSec,
  sessionExercises: exercises,
);

void main() {
  late _MockRepository repository;
  late GetStatisticsUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = GetStatisticsUseCase(repository);
  });

  Future<StatsSummary> run(List<WorkoutSession> sessions) async {
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Right(sessions));
    return (await useCase()).getOrElse((_) => throw StateError('failed'));
  }

  test('no sessions: zeroed totals, undefined average, no exercises', () async {
    final summary = await run([]);

    expect(summary.stats.totalWorkoutsCompleted, 0);
    expect(summary.stats.totalVolumeKg, 0);
    expect(summary.stats.totalDurationSec, 0);
    expect(summary.stats.avgDurationSec, isNull);
    expect(summary.exercises, isEmpty);
  });

  test('sessions with every set skipped are not counted', () async {
    final summary = await run([
      _session(1, [
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(skipped: true),
        ]),
      ]),
      _session(2, [
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 100),
        ]),
      ]),
    ]);

    expect(summary.stats.totalWorkoutsCompleted, 1);
  });

  test('volume sums weighted, non-skipped sets only', () async {
    final summary = await run([
      _session(1, [
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(repetitions: 8, weight: 60),
          const ActualSet(repetitions: 5, weight: 62.5),
          const ActualSet(repetitions: 10, weight: 200, skipped: true),
        ]),
        _exercise('Push-Ups', ExerciseType.bodyweight, [
          const ActualSet(repetitions: 20),
        ]),
      ]),
    ]);

    expect(summary.stats.totalVolumeKg, 792.5);
  });

  test('duration total and integer average', () async {
    final summary = await run([
      _session(1, [
        _exercise('Push-Ups', ExerciseType.bodyweight, [
          const ActualSet(repetitions: 5),
        ]),
      ], durationSec: 1000),
      _session(2, [
        _exercise('Push-Ups', ExerciseType.bodyweight, [
          const ActualSet(repetitions: 5),
        ]),
      ], durationSec: 2001),
    ]);

    expect(summary.stats.totalDurationSec, 3001);
    expect(summary.stats.avgDurationSec, 1500);
  });

  test(
    'breakdown counts sessions, tracks bests, sorts by count then name',
    () async {
      final summary = await run([
        _session(1, [
          _exercise('Squat', ExerciseType.weighted, [
            const ActualSet(repetitions: 5, weight: 100),
          ]),
          _exercise('Plank', ExerciseType.timeBased, [
            const ActualSet(durationSec: 60),
          ]),
          _exercise('Apple Curl', ExerciseType.bodyweight, [
            const ActualSet(repetitions: 9),
          ]),
        ]),
        _session(2, [
          _exercise('Squat', ExerciseType.weighted, [
            const ActualSet(repetitions: 5, weight: 110),
          ]),
          _exercise('Plank', ExerciseType.timeBased, [
            const ActualSet(durationSec: 70),
            const ActualSet(durationSec: 500, skipped: true),
          ]),
        ]),
      ]);

      expect(summary.exercises.map((row) => row.exerciseName), [
        'Plank',
        'Squat',
        'Apple Curl',
      ]);
      expect(summary.exercises[0].sessionCount, 2);
      expect(summary.exercises[0].bestDurationSec, 70);
      expect(summary.exercises[1].bestWeight, 110);
      expect(summary.exercises[2].bestReps, 9);
    },
  );

  test(
    'an exercise whose sets were all skipped is left out of the breakdown',
    () async {
      final summary = await run([
        _session(1, [
          _exercise('Squat', ExerciseType.weighted, [
            const ActualSet(repetitions: 5, weight: 100),
          ]),
          _exercise('Row', ExerciseType.weighted, [
            const ActualSet(skipped: true),
          ]),
        ]),
      ]);

      expect(summary.exercises.map((row) => row.exerciseName), ['Squat']);
    },
  );

  test('a read failure propagates', () async {
    final failure = CacheException(message: 'boom');
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Left(failure));

    expect((await useCase()).isLeft(), isTrue);
  });

  test('a weighted set without a weight changes no statistic', () async {
    final summary = await run([
      _session(1, [
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(repetitions: 5),
        ]),
      ]),
    ]);

    expect(summary.stats.totalWorkoutsCompleted, 0);
    expect(summary.stats.totalVolumeKg, 0);
    expect(summary.exercises, isEmpty);
  });

  test('a bodyweight-only workout counts with zero volume', () async {
    final summary = await run([
      _session(1, [
        _exercise('Push-Ups', ExerciseType.bodyweight, [
          const ActualSet(repetitions: 12),
        ]),
      ]),
    ]);

    expect(summary.stats.totalWorkoutsCompleted, 1);
    expect(summary.stats.totalVolumeKg, 0);
  });

  test('fractional volume is summed to one decimal', () async {
    final summary = await run([
      _session(1, [
        _exercise('Curl', ExerciseType.weighted, [
          const ActualSet(repetitions: 1, weight: 10.4),
          const ActualSet(repetitions: 1, weight: 10.4),
        ]),
      ]),
    ]);

    expect(summary.stats.totalVolumeKg, 20.8);
  });

  test('exercise identity is the id: a rename keeps one row', () async {
    final summary = await run([
      _session(1, [
        const SessionExercise(
          exerciseId: 'bench',
          exerciseName: 'Bench',
          type: ExerciseType.weighted,
          actualSets: [ActualSet(repetitions: 5, weight: 60)],
        ),
      ]),
      _session(2, [
        const SessionExercise(
          exerciseId: 'bench',
          exerciseName: 'Bench Press',
          type: ExerciseType.weighted,
          actualSets: [ActualSet(repetitions: 5, weight: 65)],
        ),
      ]),
    ]);

    expect(summary.exercises, hasLength(1));
    expect(summary.exercises.single.exerciseName, 'Bench Press');
    expect(summary.exercises.single.sessionCount, 2);
    expect(summary.exercises.single.bestWeight, 65);
  });

  test('an exercise twice in one session counts as one session', () async {
    final summary = await run([
      _session(1, [
        _exercise('Squat', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 100),
        ]),
        _exercise('Squat', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 110),
        ]),
      ]),
    ]);

    expect(summary.exercises.single.sessionCount, 1);
    expect(summary.exercises.single.bestWeight, 110);
  });

  test('a stored non-finite weight is ignored and stats still load', () async {
    final summary = await run([
      _session(1, [
        _exercise('Squat', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: double.infinity),
          const ActualSet(repetitions: 5, weight: 100),
        ]),
      ]),
    ]);

    expect(summary.stats.totalVolumeKg, 500);
    expect(summary.exercises.single.bestWeight, 100);
  });
}
