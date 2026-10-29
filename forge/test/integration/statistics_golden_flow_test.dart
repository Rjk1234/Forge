import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/personal_bests/application/use_cases/get_personal_bests_use_case.dart';
import 'package:forge/features/personal_bests/domain/entities/personal_best_record.dart';
import 'package:forge/features/progress/application/use_cases/get_exercise_progress_data_use_case.dart';
import 'package:forge/features/progress/domain/entities/exercise_metrics.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';
import 'package:forge/features/stats/application/use_cases/get_statistics_use_case.dart';
import 'package:forge/features/workout_session/application/use_cases/get_workout_history_use_case.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import 'package:forge/features/workout_session/data/repositories/workout_session_repository_impl.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

SessionExercise _bench(List<ActualSet> sets) => SessionExercise(
  exerciseId: 'bench',
  exerciseName: 'Bench Press',
  type: ExerciseType.weighted,
  actualSets: sets,
);

SessionExercise _pushUp(List<ActualSet> sets) => SessionExercise(
  exerciseId: 'pushup',
  exerciseName: 'Push-Up',
  type: ExerciseType.bodyweight,
  actualSets: sets,
);

SessionExercise _plank(List<ActualSet> sets) => SessionExercise(
  exerciseId: 'plank',
  exerciseName: 'Plank',
  type: ExerciseType.timeBased,
  actualSets: sets,
);

WorkoutSession _session(String id, int day, List<SessionExercise> exercises) {
  final startedAt = DateTime(2026, 9, day, 9);
  return WorkoutSession(
    sessionId: id,
    planId: 'qa-push',
    planName: 'QA Push',
    startedAt: startedAt,
    completedAt: startedAt.add(const Duration(minutes: 45)),
    sessionDurationSec: 45 * 60,
    sessionExercises: exercises,
  );
}

final _s1 = _session('s1', 1, [
  _bench(const [
    ActualSet(repetitions: 10, weight: 60),
    ActualSet(repetitions: 8, weight: 62.5),
  ]),
  _pushUp(const [ActualSet(repetitions: 15), ActualSet(repetitions: 12)]),
  _plank(const [ActualSet(durationSec: 30)]),
]);

final _s2 = _session('s2', 2, [
  _bench(const [
    ActualSet(repetitions: 8, weight: 65),
    ActualSet(repetitions: 6, weight: 65),
  ]),
  _pushUp(const [ActualSet(repetitions: 15), ActualSet(repetitions: 15)]),
  _plank(const [ActualSet(durationSec: 40)]),
]);

final _s3 = _session('s3', 3, [
  _bench(const [
    ActualSet(skipped: true),
    ActualSet(repetitions: 5, weight: 70),
  ]),
  _pushUp(const [ActualSet(repetitions: 20), ActualSet(skipped: true)]),
  _plank(const [ActualSet(durationSec: 50)]),
]);

void main() {
  late AppDatabase db;
  late WorkoutSessionRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = WorkoutSessionRepositoryImpl(
      dataSource: WorkoutSessionLocalDataSourceImpl(db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> save(WorkoutSession session) async {
    final result = await repository.saveSession(session);
    expect(result.isRight(), isTrue);
  }

  Future<StatsSummary> stats() async => (await GetStatisticsUseCase(
    repository,
  )()).getOrElse((_) => throw StateError('stats failed'));

  Future<List<PersonalBestRecord>> bests() async =>
      (await GetPersonalBestsUseCase(
        repository,
      )()).getOrElse((_) => throw StateError('pbs failed'));

  Future<Map<String, ExerciseProgressData>> progress() async {
    final list = (await GetExerciseProgressDataUseCase(
      repository: repository,
    )()).getOrElse((_) => throw StateError('progress failed'));
    return {for (final item in list) item.exerciseName: item};
  }

  void expectBests(
    List<PersonalBestRecord> records, {
    required double bench,
    required int pushUp,
    required int plank,
  }) {
    final byName = {for (final record in records) record.exerciseName: record};
    expect(byName['Bench Press']!.bestWeight, bench);
    expect(byName['Push-Up']!.bestReps, pushUp);
    expect(byName['Plank']!.bestDurationSec, plank);
  }

  Future<void> expectAfterS1() async {
    final summary = await stats();
    expect(summary.stats.totalWorkoutsCompleted, 1);
    expect(summary.stats.totalVolumeKg, 1100);
    expectBests(await bests(), bench: 62.5, pushUp: 15, plank: 30);
  }

  Future<void> expectAfterS2() async {
    final summary = await stats();
    expect(summary.stats.totalWorkoutsCompleted, 2);
    expect(summary.stats.totalVolumeKg, 2010);
    expectBests(await bests(), bench: 65, pushUp: 15, plank: 40);

    final items = await progress();
    final bench = items['Bench Press']!;
    expect(
      bench.latestMetrics,
      const WeightedMetrics(
        topWeight: 65,
        bestReps: 8,
        totalReps: 14,
        volume: 910,
      ),
    );
    expect(
      bench.deltaMetrics,
      const WeightedMetrics(
        topWeight: 2.5,
        bestReps: -2,
        totalReps: -4,
        volume: -190,
      ),
    );
    expect(
      items['Push-Up']!.latestMetrics,
      const BodyweightMetrics(totalSets: 2, bestReps: 15, totalReps: 30),
    );
    expect(
      items['Push-Up']!.deltaMetrics,
      const BodyweightMetrics(totalSets: 0, bestReps: 0, totalReps: 3),
    );
    expect(
      items['Plank']!.latestMetrics,
      const TimedMetrics(bestDuration: 40, totalTime: 40, setCount: 1),
    );
    expect(
      items['Plank']!.deltaMetrics,
      const TimedMetrics(bestDuration: 10, totalTime: 10, setCount: 0),
    );
  }

  Future<void> expectAfterS3() async {
    final summary = await stats();
    expect(summary.stats.totalWorkoutsCompleted, 3);
    expect(summary.stats.totalVolumeKg, 2360);
    expectBests(await bests(), bench: 70, pushUp: 20, plank: 50);

    final bench = (await progress())['Bench Press']!;
    expect(
      bench.deltaMetrics,
      const WeightedMetrics(
        topWeight: 5,
        bestReps: -3,
        totalReps: -9,
        volume: -560,
      ),
    );
    expect((bench.latestMetrics as WeightedMetrics).volume, 350);
  }

  test('statistics follow the golden flow and recalculate on delete', () async {
    await save(_s1);
    await expectAfterS1();

    await save(_s2);
    await expectAfterS2();

    await save(_s3);
    await expectAfterS3();

    final history = (await GetWorkoutHistoryUseCase(
      repository,
    )()).getOrElse((_) => []);
    expect(history.map((session) => session.sessionId), ['s3', 's2', 's1']);
    expect(history.length, (await stats()).stats.totalWorkoutsCompleted);

    expect((await repository.deleteSession('s3')).isRight(), isTrue);
    await expectAfterS2();
  });
}
