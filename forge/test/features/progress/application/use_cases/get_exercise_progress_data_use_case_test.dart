import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/progress/application/use_cases/get_exercise_progress_data_use_case.dart';
import 'package:forge/features/progress/domain/entities/exercise_metrics.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/workout_session/domain/rules/workout_volume.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements WorkoutSessionRepository {}

SessionExercise _weighted(String name, List<ActualSet> sets) => SessionExercise(
  exerciseId: name,
  exerciseName: name,
  type: ExerciseType.weighted,
  actualSets: sets,
);

WorkoutSession _session(
  DateTime completedAt,
  List<SessionExercise> exercises, {
  int durationSec = 3600,
}) => WorkoutSession(
  sessionId: completedAt.toIso8601String(),
  planId: 'p',
  planName: 'Plan',
  completedAt: completedAt,
  startedAt: completedAt.subtract(const Duration(hours: 1)),
  sessionDurationSec: durationSec,
  sessionExercises: exercises,
);

void main() {
  late _MockRepository repository;
  late GetExerciseProgressDataUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = GetExerciseProgressDataUseCase(repository: repository);
  });

  Future<List<ExerciseProgressData>> run(List<WorkoutSession> sessions) async {
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Right(sessions));
    final result = await useCase();
    return result.getOrElse((_) => []);
  }

  final day1 = DateTime(2026, 9, 1);
  final day2 = DateTime(2026, 9, 3);
  final day3 = DateTime(2026, 9, 5);

  test('no sessions gives an empty list', () async {
    expect(await run([]), isEmpty);
  });

  test(
    'a single session lands in the non-comparable group without delta',
    () async {
      final result = await run([
        _session(day1, [
          _weighted('Bench', [const ActualSet(repetitions: 8, weight: 60)]),
        ]),
      ]);

      expect(result.single.totalValidSessions, 1);
      expect(result.single.deltaMetrics, isNull);
    },
  );

  test('weighted metrics: top weight, best reps, rounded volume', () async {
    final result = await run([
      _session(day1, [
        _weighted('Bench', [
          const ActualSet(repetitions: 8, weight: 60),
          const ActualSet(repetitions: 6, weight: 62.5),
          const ActualSet(repetitions: 10, weight: 100, skipped: true),
        ]),
      ]),
    ]);

    expect(
      result.single.latestMetrics,
      const WeightedMetrics(
        topWeight: 62.5,
        bestReps: 8,
        totalReps: 14,
        volume: 855,
      ),
    );
  });

  test('delta is latest minus previous, negative on regression', () async {
    final result = await run([
      _session(day1, [
        _weighted('Bench', [const ActualSet(repetitions: 8, weight: 60)]),
      ]),
      _session(day2, [
        _weighted('Bench', [const ActualSet(repetitions: 6, weight: 65)]),
      ]),
    ]);

    expect(
      result.single.deltaMetrics,
      const WeightedMetrics(
        topWeight: 5,
        bestReps: -2,
        totalReps: -2,
        volume: -90,
      ),
    );
  });

  test('bodyweight metrics count sets and reps', () async {
    final result = await run([
      _session(day1, [
        const SessionExercise(
          exerciseId: 'p',
          exerciseName: 'Push-Ups',
          type: ExerciseType.bodyweight,
          actualSets: [
            ActualSet(repetitions: 15),
            ActualSet(repetitions: 12),
            ActualSet(skipped: true),
          ],
        ),
      ]),
    ]);

    expect(
      result.single.latestMetrics,
      const BodyweightMetrics(totalSets: 2, bestReps: 15, totalReps: 27),
    );
  });

  test('time-based metrics use seconds and plot the best duration', () async {
    final result = await run([
      _session(day1, [
        const SessionExercise(
          exerciseId: 'pl',
          exerciseName: 'Plank',
          type: ExerciseType.timeBased,
          actualSets: [ActualSet(durationSec: 45), ActualSet(durationSec: 60)],
        ),
      ]),
    ]);

    expect(
      result.single.latestMetrics,
      const TimedMetrics(bestDuration: 60, totalTime: 105, setCount: 2),
    );
    expect(result.single.sessionDataPoints.single.metricValue, 60);
  });

  test('sessions where every set was skipped do not count', () async {
    final result = await run([
      _session(day1, [
        _weighted('Bench', [const ActualSet(skipped: true)]),
      ]),
      _session(day2, [
        _weighted('Bench', [const ActualSet(repetitions: 8, weight: 60)]),
      ]),
    ]);

    expect(result.single.totalValidSessions, 1);
  });

  test('chart is capped at 12 sessions but stats use the two latest', () async {
    final sessions = [
      for (var i = 0; i < 15; i++)
        _session(DateTime(2026, 1, 1).add(Duration(days: i)), [
          _weighted('Bench', [ActualSet(repetitions: 8, weight: 50.0 + i)]),
        ]),
    ];

    final data = (await run(sessions)).single;

    expect(data.totalValidSessions, 15);
    expect(data.sessionDataPoints, hasLength(12));
    expect(data.sessionDataPoints.first.metricValue, 53);
    expect(data.sessionDataPoints.last.isLatest, isTrue);
    expect((data.deltaMetrics! as WeightedMetrics).topWeight, 1);
  });

  test('chips: comparable first, newest first, alphabetical on ties', () async {
    const one = ActualSet(repetitions: 8, weight: 60);
    final result = await run([
      _session(day1, [
        _weighted('Squat', [one]),
        _weighted('Bench', [one]),
      ]),
      _session(day2, [
        _weighted('Bench', [one]),
        _weighted('Row', [one]),
      ]),
      _session(day3, [
        _weighted('Curl', [one]),
        _weighted('Apple', [one]),
      ]),
    ]);

    expect(result.map((e) => e.exerciseName), [
      'Bench',
      'Apple',
      'Curl',
      'Row',
      'Squat',
    ]);
  });

  test('an unknown skipped flag defaults to counted', () async {
    final result = await run([
      _session(day1, [
        _weighted('Bench', [const ActualSet(repetitions: 5, weight: 40)]),
      ]),
    ]);

    expect(result.single.totalValidSessions, 1);
  });

  test('a read failure propagates', () async {
    final failure = CacheException(message: 'boom');
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Left(failure));

    expect(
      await useCase(),
      Left<AppException, List<ExerciseProgressData>>(failure),
    );
  });

  test('an exercise twice in one session is a single entry', () async {
    final result = await run([
      _session(day1, [
        _weighted('Bench', [const ActualSet(repetitions: 5, weight: 60)]),
        _weighted('Bench', [const ActualSet(repetitions: 5, weight: 70)]),
      ]),
    ]);

    expect(result.single.totalValidSessions, 1);
    expect(result.single.sessionDataPoints, hasLength(1));
    expect(result.single.deltaMetrics, isNull);
    expect((result.single.latestMetrics as WeightedMetrics).volume, 650);
  });

  test('weight deltas carry no floating-point noise', () async {
    final result = await run([
      _session(day1, [
        _weighted('Bench', [const ActualSet(repetitions: 5, weight: 70.2)]),
      ]),
      _session(day2, [
        _weighted('Bench', [const ActualSet(repetitions: 5, weight: 72.5)]),
      ]),
    ]);

    expect((result.single.deltaMetrics! as WeightedMetrics).topWeight, 2.3);
  });

  test('a rename keeps one history under the latest name', () async {
    SessionExercise bench(String name, double weight) => SessionExercise(
      exerciseId: 'bench',
      exerciseName: name,
      type: ExerciseType.weighted,
      actualSets: [ActualSet(repetitions: 5, weight: weight)],
    );

    final result = await run([
      _session(day1, [bench('Bench', 60)]),
      _session(day2, [bench('Bench Press', 65)]),
    ]);

    expect(result.single.exerciseName, 'Bench Press');
    expect(result.single.totalValidSessions, 2);
  });

  test('equal timestamps are ordered by session id', () async {
    WorkoutSession at(String id, double weight) => WorkoutSession(
      sessionId: id,
      planId: 'p',
      planName: 'Plan',
      completedAt: day1,
      startedAt: day1,
      sessionDurationSec: 60,
      sessionExercises: [
        _weighted('Bench', [ActualSet(repetitions: 5, weight: weight)]),
      ],
    );

    final forward = await run([at('a', 60), at('b', 65)]);
    final reversed = await run([at('b', 65), at('a', 60)]);

    expect(forward, reversed);
    expect((forward.single.latestMetrics as WeightedMetrics).topWeight, 65);
  });

  test('a weighted set without a weight changes no progress', () async {
    final result = await run([
      _session(day1, [
        _weighted('Bench', [const ActualSet(repetitions: 5)]),
      ]),
    ]);

    expect(result, isEmpty);
  });

  test('summed progress volume equals the Stats total volume', () async {
    final sessions = [
      _session(day1, [
        _weighted('Curl', [
          const ActualSet(repetitions: 1, weight: 10.4),
          const ActualSet(repetitions: 1, weight: 10.4),
        ]),
      ]),
    ];

    final progress = await run(sessions);
    final progressVolume =
        (progress.single.latestMetrics as WeightedMetrics).volume;

    expect(progressVolume, 20.8);
    expect(totalVolume(sessions), progressVolume);
  });

  test(
    'workout duration and total reps are compared with the previous',
    () async {
      final result = await run([
        _session(day1, [
          _weighted('Bench', [
            const ActualSet(repetitions: 8, weight: 60),
            const ActualSet(repetitions: 8, weight: 60),
          ]),
        ], durationSec: 3000),
        _session(day2, [
          _weighted('Bench', [const ActualSet(repetitions: 6, weight: 60)]),
        ], durationSec: 2700),
      ]);

      expect(result.single.latestWorkoutDurationSec, 2700);
      expect(result.single.workoutDurationDeltaSec, -300);
      expect((result.single.deltaMetrics! as WeightedMetrics).totalReps, -10);
    },
  );
}
