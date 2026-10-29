import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/models/plan_exercise_record.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';
import '../../../../helpers/database.dart';

void main() {
  late AppDatabase db;
  late WorkoutPlanLocalDataSourceImpl dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = WorkoutPlanLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  final created = DateTime(2026, 1, 1, 10);
  final updated = DateTime(2026, 1, 2, 11);

  PlanExerciseRecord weighted(String id) => PlanExerciseRecord(
    exerciseId: id,
    exerciseName: 'Name $id',
    type: ExerciseType.weighted,
    targetSets: 4,
    targetRepetitions: 8,
    targetWeight: 52.5,
    restPeriodSec: 90,
  );

  WorkoutPlanRecord plan(
    String planId,
    List<PlanExerciseRecord> exercises, {
    String name = 'Plan',
  }) => WorkoutPlanRecord(
    planId: planId,
    name: name,
    planExercises: exercises,
    createdAt: created,
    updatedAt: updated,
  );

  Future<void> save(WorkoutPlanRecord record) async {
    await ensureExercises(db, record.planExercises.map((e) => e.exerciseId));
    await dataSource.savePlan(record);
  }

  Future<int> planExerciseCount() async {
    final row = await db
        .customSelect('SELECT COUNT(*) AS c FROM plan_exercises')
        .getSingle();
    return row.read<int>('c');
  }

  test('missing plan returns null and empty list', () async {
    expect(await dataSource.getPlanById('x'), isNull);
    expect(await dataSource.getAllPlans(), isEmpty);
  });

  test('save then get preserves fields and exercise order', () async {
    await save(
      plan('p1', [weighted('z'), weighted('a'), weighted('m')], name: 'Push'),
    );

    final loaded = await dataSource.getPlanById('p1');

    expect(loaded!.name, 'Push');
    expect(loaded.createdAt, created);
    expect(loaded.updatedAt, updated);
    expect(loaded.planExercises.map((e) => e.exerciseId), ['z', 'a', 'm']);
    final first = loaded.planExercises.first;
    expect(first.exerciseName, 'Name z');
    expect(first.type, ExerciseType.weighted);
    expect(first.targetSets, 4);
    expect(first.targetRepetitions, 8);
    expect(first.targetWeight, 52.5);
    expect(first.restPeriodSec, 90);
    expect(first.targetDurationSec, isNull);
  });

  test('nullable target fields round-trip as null', () async {
    await save(
      plan('p1', [
        const PlanExerciseRecord(
          exerciseId: 'plank',
          exerciseName: 'Plank',
          type: ExerciseType.timeBased,
          targetSets: 3,
          targetDurationSec: 45,
          restPeriodSec: 30,
        ),
      ]),
    );

    final stored = (await dataSource.getPlanById('p1'))!.planExercises.single;

    expect(stored.targetDurationSec, 45);
    expect(stored.targetRepetitions, isNull);
    expect(stored.targetWeight, isNull);
    expect(stored.type, ExerciseType.timeBased);
  });

  test('a plan with no exercises is stored with an empty list', () async {
    await save(plan('p1', const []));

    expect((await dataSource.getPlanById('p1'))!.planExercises, isEmpty);
  });

  test('re-saving a plan replaces its exercises without stale rows', () async {
    await save(plan('p1', [weighted('a'), weighted('b')]));
    await save(plan('p1', [weighted('c')], name: 'Renamed'));

    final loaded = await dataSource.getPlanById('p1');

    expect(loaded!.name, 'Renamed');
    expect(loaded.planExercises.map((e) => e.exerciseId), ['c']);
    expect(await planExerciseCount(), 1);
    expect(await dataSource.getAllPlans(), hasLength(1));
  });

  test('getAllPlans returns every plan with its own exercises', () async {
    await save(plan('p2', [weighted('b')]));
    await save(plan('p1', [weighted('a'), weighted('c')]));

    final all = await dataSource.getAllPlans();

    expect(all.map((p) => p.planId), ['p1', 'p2']);
    expect(all[0].planExercises.map((e) => e.exerciseId), ['a', 'c']);
    expect(all[1].planExercises.map((e) => e.exerciseId), ['b']);
  });

  test('deletePlan removes the plan and its exercises only', () async {
    await save(plan('p1', [weighted('a'), weighted('b')]));
    await save(plan('p2', [weighted('c')]));

    await dataSource.deletePlan('p1');

    expect(await dataSource.getPlanById('p1'), isNull);
    expect(await planExerciseCount(), 1);
    expect(
      (await dataSource.getPlanById('p2'))!.planExercises.single.exerciseId,
      'c',
    );
  });

  test('savePlan is atomic when an exercise insert fails', () async {
    await save(plan('p1', [weighted('a')], name: 'Original'));
    await db.customStatement('''
      CREATE TRIGGER fail_insert BEFORE INSERT ON plan_exercises
      WHEN NEW.exercise_id = 'boom'
      BEGIN SELECT RAISE(ABORT, 'forced failure'); END
    ''');

    await expectLater(
      save(plan('p1', [weighted('b'), weighted('boom')], name: 'Changed')),
      throwsA(anything),
    );

    final loaded = await dataSource.getPlanById('p1');
    expect(loaded!.name, 'Original');
    expect(loaded.planExercises.map((e) => e.exerciseId), ['a']);
  });
}
