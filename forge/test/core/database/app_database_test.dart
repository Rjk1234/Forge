import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/core/enums/exercise_type.dart';
import '../../helpers/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> count(String table) async {
    final row = await db
        .customSelect('SELECT COUNT(*) AS c FROM $table')
        .getSingle();
    return row.read<int>('c');
  }

  final now = DateTime(2026, 1, 1);

  Future<void> insertPlanWithExercise(String planId) async {
    await db
        .into(db.workoutPlans)
        .insert(
          WorkoutPlansCompanion.insert(
            planId: planId,
            name: 'Plan',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await ensureExercises(db, ['ex']);
    await db
        .into(db.planExercises)
        .insert(
          PlanExercisesCompanion.insert(
            planId: planId,
            position: 0,
            exerciseId: 'ex',
            exerciseName: 'Ex',
            type: ExerciseType.weighted,
            targetSets: 3,
            restPeriodSec: 60,
          ),
        );
  }

  group('schema', () {
    test('creates all tables', () async {
      final rows = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();
      final names = rows.map((r) => r.read<String>('name')).toSet();
      expect(
        names,
        containsAll(<String>[
          'user_profiles',
          'exercises',
          'workout_plans',
          'plan_exercises',
          'schedule_entries',
          'workout_sessions',
          'session_exercises',
          'actual_sets',
        ]),
      );
    });

    test('schemaVersion is 1', () {
      expect(db.schemaVersion, 1);
    });
  });

  group('foreign keys', () {
    test('are enabled', () async {
      final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(row.read<int>('foreign_keys'), 1);
    });

    test('plan_exercises rejects an unknown plan', () async {
      expect(
        () => db
            .into(db.planExercises)
            .insert(
              PlanExercisesCompanion.insert(
                planId: 'missing',
                position: 0,
                exerciseId: 'ex',
                exerciseName: 'Ex',
                type: ExerciseType.weighted,
                targetSets: 1,
                restPeriodSec: 30,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('deleting a plan cascades to plan_exercises', () async {
      await insertPlanWithExercise('p1');
      await insertPlanWithExercise('p2');

      await (db.delete(
        db.workoutPlans,
      )..where((t) => t.planId.equals('p1'))).go();

      final remaining = await db.select(db.planExercises).get();
      expect(remaining.map((e) => e.planId), ['p2']);
    });

    test('deleting a session cascades to exercises and sets', () async {
      await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              sessionId: 's1',
              planId: 'p',
              planName: 'Plan',
              completedAt: now,
              sessionDurationSec: 100,
            ),
          );
      final exerciseId = await db
          .into(db.sessionExercises)
          .insert(
            SessionExercisesCompanion.insert(
              sessionId: 's1',
              position: 0,
              exerciseId: 'ex',
              exerciseName: 'Ex',
              type: ExerciseType.bodyweight,
            ),
          );
      await db
          .into(db.actualSets)
          .insert(
            ActualSetsCompanion.insert(
              sessionExerciseId: exerciseId,
              position: 0,
              repetitions: const Value(10),
            ),
          );
      expect(await count('session_exercises'), 1);
      expect(await count('actual_sets'), 1);

      await (db.delete(
        db.workoutSessions,
      )..where((t) => t.sessionId.equals('s1'))).go();

      expect(await count('session_exercises'), 0);
      expect(await count('actual_sets'), 0);
    });
  });

  group('ExerciseType storage', () {
    test('is stored as text and round-trips every value', () async {
      for (final type in ExerciseType.values) {
        await db
            .into(db.exercises)
            .insert(
              ExercisesCompanion.insert(id: type.name, name: 'N', type: type),
            );
      }

      final raw = await db.customSelect('SELECT id, type FROM exercises').get();
      for (final row in raw) {
        expect(row.read<String>('type'), row.read<String>('id'));
      }
      final rows = await db.select(db.exercises).get();
      expect(
        {for (final r in rows) r.id: r.type},
        {for (final t in ExerciseType.values) t.name: t},
      );
    });
  });

  group('value constraints', () {
    Future<void> insertPlanRow({String name = 'Plan'}) => db
        .into(db.workoutPlans)
        .insert(
          WorkoutPlansCompanion.insert(
            planId: 'p',
            name: name,
            createdAt: now,
            updatedAt: now,
          ),
        );

    Future<void> insertPlanExercise({
      int sets = 3,
      int? reps,
      double? weight,
      int? durationSec,
      int rest = 60,
      String exerciseId = 'ex',
    }) async {
      await ensureExercises(db, [exerciseId]);
      await db
          .into(db.planExercises)
          .insert(
            PlanExercisesCompanion.insert(
              planId: 'p',
              position: 0,
              exerciseId: exerciseId,
              exerciseName: 'Ex',
              type: ExerciseType.weighted,
              targetSets: sets,
              restPeriodSec: rest,
              targetRepetitions: Value(reps),
              targetWeight: Value(weight),
              targetDurationSec: Value(durationSec),
            ),
          );
    }

    test('a blank or whitespace plan name is rejected', () async {
      await expectLater(insertPlanRow(name: '   '), throwsA(anything));
      await expectLater(insertPlanRow(name: ''), throwsA(anything));
    });

    test('invalid plan numbers are rejected', () async {
      await insertPlanRow();
      await expectLater(insertPlanExercise(sets: 0), throwsA(anything));
      await expectLater(insertPlanExercise(reps: 0), throwsA(anything));
      await expectLater(insertPlanExercise(weight: -5), throwsA(anything));
      await expectLater(insertPlanExercise(weight: 0), throwsA(anything));
      await expectLater(insertPlanExercise(rest: -1), throwsA(anything));
      await expectLater(insertPlanExercise(durationSec: 0), throwsA(anything));
    });

    test('valid plan numbers are accepted', () async {
      await insertPlanRow();
      await insertPlanExercise(reps: 10, weight: 52.5, rest: 0);
      expect(await db.select(db.planExercises).get(), hasLength(1));
    });

    test('a plan exercise must reference an existing exercise', () async {
      await insertPlanRow();
      await expectLater(
        db
            .into(db.planExercises)
            .insert(
              PlanExercisesCompanion.insert(
                planId: 'p',
                position: 0,
                exerciseId: 'not_in_catalogue',
                exerciseName: 'Ex',
                type: ExerciseType.weighted,
                targetSets: 1,
                restPeriodSec: 0,
              ),
            ),
        throwsA(anything),
      );
    });

    test('an exercise still used by a plan cannot be deleted', () async {
      await insertPlanRow();
      await insertPlanExercise(exerciseId: 'used');
      await expectLater(
        (db.delete(db.exercises)..where((t) => t.id.equals('used'))).go(),
        throwsA(anything),
      );
    });

    test('invalid set and session values are rejected', () async {
      await expectLater(
        db
            .into(db.workoutSessions)
            .insert(
              WorkoutSessionsCompanion.insert(
                sessionId: 's',
                planId: 'p',
                planName: 'Plan',
                completedAt: now,
                sessionDurationSec: -1,
              ),
            ),
        throwsA(anything),
      );
    });
  });
}
