import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import 'package:forge/features/workout_session/data/models/actual_set_record.dart';
import 'package:forge/features/workout_session/data/models/session_exercise_record.dart';
import 'package:forge/features/workout_session/data/models/workout_session_record.dart';

void main() {
  late AppDatabase db;
  late WorkoutSessionLocalDataSourceImpl dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = WorkoutSessionLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  final completed = DateTime(2026, 3, 1, 18);

  WorkoutSessionRecord session(
    String id, {
    String planId = 'p1',
    DateTime? startedAt,
    List<SessionExerciseRecord>? exercises,
  }) => WorkoutSessionRecord(
    sessionId: id,
    planId: planId,
    planName: 'Plan $planId',
    completedAt: completed,
    sessionDurationSec: 1800,
    startedAt: startedAt,
    sessionExercises:
        exercises ??
        const [
          SessionExerciseRecord(
            exerciseId: 'sq',
            exerciseName: 'Squat',
            type: ExerciseType.weighted,
            actualSets: [
              ActualSetRecord(repetitions: 5, weight: 100.5),
              ActualSetRecord(skipped: true),
              ActualSetRecord(repetitions: 3, weight: 110),
            ],
          ),
          SessionExerciseRecord(
            exerciseId: 'pl',
            exerciseName: 'Plank',
            type: ExerciseType.timeBased,
            actualSets: [ActualSetRecord(durationSec: 60)],
          ),
          SessionExerciseRecord(
            exerciseId: 'pu',
            exerciseName: 'Push-up',
            type: ExerciseType.bodyweight,
            actualSets: [],
          ),
        ],
  );

  Future<int> count(String table) async {
    final row = await db
        .customSelect('SELECT COUNT(*) AS c FROM $table')
        .getSingle();
    return row.read<int>('c');
  }

  test('missing session returns null and empty lists', () async {
    expect(await dataSource.getSessionById('x'), isNull);
    expect(await dataSource.getAllSessions(), isEmpty);
    expect(await dataSource.getSessionsByPlanId('p1'), isEmpty);
  });

  test('save then get returns nested exercises and sets in order', () async {
    await dataSource.saveSession(session('s1'));

    final loaded = await dataSource.getSessionById('s1');

    expect(loaded!.planId, 'p1');
    expect(loaded.planName, 'Plan p1');
    expect(loaded.completedAt, completed);
    expect(loaded.sessionDurationSec, 1800);
    expect(loaded.sessionExercises.map((e) => e.exerciseId), [
      'sq',
      'pl',
      'pu',
    ]);
    final sets = loaded.sessionExercises[0].actualSets;
    expect(sets.map((s) => s.repetitions), [5, null, 3]);
    expect(sets.map((s) => s.weight), [100.5, null, 110]);
    expect(sets.map((s) => s.skipped), [false, true, false]);
    expect(loaded.sessionExercises[1].actualSets.single.durationSec, 60);
    expect(loaded.sessionExercises[1].type, ExerciseType.timeBased);
    expect(loaded.sessionExercises[2].actualSets, isEmpty);
  });

  test('startedAt round-trips as null and as a value', () async {
    final started = DateTime(2026, 3, 1, 17, 30);
    await dataSource.saveSession(session('without'));
    await dataSource.saveSession(session('with', startedAt: started));

    expect((await dataSource.getSessionById('without'))!.startedAt, isNull);
    expect((await dataSource.getSessionById('with'))!.startedAt, started);
  });

  test('re-saving a session replaces its children', () async {
    await dataSource.saveSession(session('s1'));
    await dataSource.saveSession(
      session(
        's1',
        exercises: const [
          SessionExerciseRecord(
            exerciseId: 'only',
            exerciseName: 'Only',
            type: ExerciseType.bodyweight,
            actualSets: [ActualSetRecord(repetitions: 12)],
          ),
        ],
      ),
    );

    final loaded = await dataSource.getSessionById('s1');

    expect(loaded!.sessionExercises.single.exerciseId, 'only');
    expect(await count('workout_sessions'), 1);
    expect(await count('session_exercises'), 1);
    expect(await count('actual_sets'), 1);
  });

  test('getSessionsByPlanId filters by plan', () async {
    await dataSource.saveSession(session('s1', planId: 'p1'));
    await dataSource.saveSession(session('s2', planId: 'p2'));
    await dataSource.saveSession(session('s3', planId: 'p1'));

    final forPlan = await dataSource.getSessionsByPlanId('p1');

    expect(forPlan.map((s) => s.sessionId), ['s1', 's3']);
    expect(await dataSource.getAllSessions(), hasLength(3));
  });

  test('deleteSession cascades to its exercises and sets only', () async {
    await dataSource.saveSession(session('s1'));
    await dataSource.saveSession(session('s2'));

    await dataSource.deleteSession('s1');

    expect(await dataSource.getSessionById('s1'), isNull);
    expect(await dataSource.getSessionById('s2'), isNotNull);
    expect(await count('session_exercises'), 3);
    expect(await count('actual_sets'), 4);
  });

  test('deleting a plan does not touch its sessions', () async {
    final planSource = WorkoutPlanLocalDataSourceImpl(db);
    await planSource.savePlan(
      WorkoutPlanRecord(
        planId: 'p1',
        name: 'Plan p1',
        planExercises: const [],
        createdAt: completed,
        updatedAt: completed,
      ),
    );
    await dataSource.saveSession(session('s1', planId: 'p1'));

    await planSource.deletePlan('p1');

    final kept = await dataSource.getSessionById('s1');
    expect(kept, isNotNull);
    expect(kept!.planId, 'p1');
    expect(kept.planName, 'Plan p1');
    expect(kept.sessionExercises, hasLength(3));
    expect(kept.sessionExercises[0].actualSets, hasLength(3));
  });
}
