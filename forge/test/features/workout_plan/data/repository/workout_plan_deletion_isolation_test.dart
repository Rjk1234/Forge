import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/data/datasources/exercise_local_data_source.dart';
import 'package:forge/features/exercise/data/models/exercise_record.dart';
import 'package:forge/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:forge/features/schedule/data/models/schedule_entry_record.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/models/plan_exercise_record.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';
import 'package:forge/features/workout_plan/data/repositories/workout_plan_repository_impl.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import 'package:forge/features/workout_session/data/models/actual_set_record.dart';
import 'package:forge/features/workout_session/data/models/session_exercise_record.dart';
import 'package:forge/features/workout_session/data/models/workout_session_record.dart';

/// Runs the real repository and data sources against an in-memory database
/// to prove what deleting a plan removes and what it must leave alone.
void main() {
  late AppDatabase db;
  late WorkoutPlanRepositoryImpl repository;
  late ScheduleLocalDataSourceImpl scheduleDataSource;
  late WorkoutSessionLocalDataSourceImpl sessionDataSource;

  final created = DateTime(2026, 1, 1);

  WorkoutPlanRecord plan(String id) => WorkoutPlanRecord(
    planId: id,
    name: 'Plan $id',
    planExercises: const [
      PlanExerciseRecord(
        exerciseId: 'ex_bench',
        exerciseName: 'Bench Press',
        type: ExerciseType.weighted,
        targetSets: 2,
        targetRepetitions: 10,
        targetWeight: 60,
        restPeriodSec: 30,
      ),
    ],
    createdAt: created,
    updatedAt: created,
  );

  WorkoutSessionRecord session(String id, String planId) =>
      WorkoutSessionRecord(
        sessionId: id,
        planId: planId,
        planName: 'Plan $planId',
        completedAt: created.add(const Duration(hours: 1)),
        startedAt: created,
        sessionDurationSec: 3600,
        sessionExercises: const [
          SessionExerciseRecord(
            exerciseId: 'ex_bench',
            exerciseName: 'Bench Press',
            type: ExerciseType.weighted,
            actualSets: [ActualSetRecord(repetitions: 10, weight: 60)],
          ),
        ],
      );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final planDataSource = WorkoutPlanLocalDataSourceImpl(db);
    scheduleDataSource = ScheduleLocalDataSourceImpl(db);
    sessionDataSource = WorkoutSessionLocalDataSourceImpl(db);
    repository = WorkoutPlanRepositoryImpl(dataSource: planDataSource);

    await ExerciseLocalDataSourceImpl(db).seedExercises(const [
      ExerciseRecord(
        id: 'ex_bench',
        name: 'Bench Press',
        type: ExerciseType.weighted,
      ),
    ]);
    await planDataSource.savePlan(plan('p1'));
    await planDataSource.savePlan(plan('p2'));
    await scheduleDataSource.saveEntry(
      const ScheduleEntryRecord(weekday: 1, planId: 'p1', planName: 'Plan p1'),
    );
    await scheduleDataSource.saveEntry(
      const ScheduleEntryRecord(weekday: 3, planId: 'p2', planName: 'Plan p2'),
    );
    await sessionDataSource.saveSession(session('s1', 'p1'));
  });

  tearDown(() async {
    await db.close();
  });

  test('deleting a plan removes its schedule entries but not others', () async {
    final result = await repository.deletePlan('p1');

    expect(result.isRight(), isTrue);
    final entries = await scheduleDataSource.getAllEntries();
    expect(entries.map((e) => e.planId), ['p2']);
  });

  test('deleting a plan leaves its completed sessions untouched', () async {
    await repository.deletePlan('p1');

    final kept = await sessionDataSource.getSessionById('s1');

    expect(kept, isNotNull);
    expect(kept!.planId, 'p1');
    expect(kept.sessionExercises.single.actualSets, hasLength(1));
  });

  test('deleting a plan removes its planned exercises', () async {
    await repository.deletePlan('p1');

    final plans = await WorkoutPlanLocalDataSourceImpl(db).getAllPlans();

    expect(plans.map((p) => p.planId), ['p2']);
  });
}
