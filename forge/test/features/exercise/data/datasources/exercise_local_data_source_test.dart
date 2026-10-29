import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';
import 'package:forge/features/workout_plan/data/models/plan_exercise_record.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/core/database/exercise_seed_data.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/data/datasources/exercise_local_data_source.dart';
import 'package:forge/features/exercise/data/models/exercise_record.dart';

void main() {
  late AppDatabase db;
  late ExerciseLocalDataSourceImpl dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = ExerciseLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  const bench = ExerciseRecord(
    id: 'b',
    name: 'Bench',
    type: ExerciseType.weighted,
    muscleGroup: 'Chest',
    description: 'Press',
  );
  const plank = ExerciseRecord(
    id: 'a',
    name: 'Plank',
    type: ExerciseType.timeBased,
  );

  test('empty database returns no exercises', () async {
    expect(await dataSource.getAllExercises(), isEmpty);
  });

  test('getAllExercises is ordered by id', () async {
    await dataSource.seedExercises([bench, plank]);

    final all = await dataSource.getAllExercises();

    expect(all.map((e) => e.id), ['a', 'b']);
  });

  test('getExerciseById returns the record on hit and null on miss', () async {
    await dataSource.seedExercises([bench, plank]);

    final hit = await dataSource.getExerciseById('b');
    expect(hit, isNotNull);
    expect(hit!.name, 'Bench');
    expect(hit.type, ExerciseType.weighted);
    expect(hit.muscleGroup, 'Chest');
    expect(hit.description, 'Press');
    expect(await dataSource.getExerciseById('nope'), isNull);
  });

  test('nullable columns round-trip as null', () async {
    await dataSource.seedExercises([plank]);

    final stored = await dataSource.getExerciseById('a');

    expect(stored!.muscleGroup, isNull);
    expect(stored.description, isNull);
    expect(stored.type, ExerciseType.timeBased);
  });

  test('seeding again replaces the whole catalogue', () async {
    await dataSource.seedExercises([bench, plank]);
    await dataSource.seedExercises([
      const ExerciseRecord(
        id: 'z',
        name: 'Push-up',
        type: ExerciseType.bodyweight,
      ),
    ]);

    final all = await dataSource.getAllExercises();

    expect(all.map((e) => e.id), ['z']);
    expect(await dataSource.getExerciseById('a'), isNull);
  });

  test('seeding an empty list clears the catalogue', () async {
    await dataSource.seedExercises([bench]);
    await dataSource.seedExercises([]);

    expect(await dataSource.getAllExercises(), isEmpty);
  });

  test('seeding again updates existing rows in place', () async {
    await dataSource.seedExercises([bench]);

    await dataSource.seedExercises([
      const ExerciseRecord(
        id: 'b',
        name: 'Bench Press',
        type: ExerciseType.weighted,
      ),
    ]);

    final all = await dataSource.getAllExercises();
    expect(all, hasLength(1));
    expect(all.single.name, 'Bench Press');
  });

  test('an exercise that left the seed is removed while unused', () async {
    await dataSource.seedExercises([bench, plank]);

    await dataSource.seedExercises([bench]);

    expect((await dataSource.getAllExercises()).map((e) => e.id), ['b']);
  });

  test('an exercise that left the seed is kept while a plan uses it', () async {
    await dataSource.seedExercises([bench, plank]);
    final planDataSource = WorkoutPlanLocalDataSourceImpl(db);
    final now = DateTime(2026, 1, 1);
    await planDataSource.savePlan(
      WorkoutPlanRecord(
        planId: 'p1',
        name: 'Plan',
        planExercises: const [
          PlanExerciseRecord(
            exerciseId: 'a',
            exerciseName: 'Plank',
            type: ExerciseType.timeBased,
            targetSets: 1,
            targetDurationSec: 30,
            restPeriodSec: 30,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    );

    await dataSource.seedExercises([bench]);

    expect((await dataSource.getAllExercises()).map((e) => e.id), ['a', 'b']);
  });

  test('seeds every real catalogue entry with unique ids', () async {
    final seed = exerciseSeedData;
    expect(seed.map((e) => e.id).toSet().length, seed.length);

    await dataSource.seedExercises(seed);
    final stored = await dataSource.getAllExercises();

    expect(stored.length, seed.length);
    for (final entry in seed) {
      final match = await dataSource.getExerciseById(entry.id);
      expect(match, isNotNull, reason: entry.id);
      expect(match!.name, entry.name);
      expect(match.type, entry.type);
      expect(match.muscleGroup, entry.muscleGroup);
      expect(match.description, entry.description);
    }
  });
}
