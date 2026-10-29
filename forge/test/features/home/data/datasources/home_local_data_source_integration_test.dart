import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/data/datasources/exercise_local_data_source.dart';
import 'package:forge/features/home/data/datasources/home_local_data_source.dart';
import 'package:forge/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:forge/features/schedule/data/models/schedule_entry_record.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/models/plan_exercise_record.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import '../../../../helpers/database.dart';

void main() {
  late AppDatabase db;
  late WorkoutPlanLocalDataSourceImpl planSource;
  late ScheduleLocalDataSourceImpl scheduleSource;
  late HomeDashboardLocalDataSourceImpl dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    planSource = WorkoutPlanLocalDataSourceImpl(db);
    scheduleSource = ScheduleLocalDataSourceImpl(db);
    dataSource = HomeDashboardLocalDataSourceImpl(
      planDataSource: planSource,
      scheduleDataSource: scheduleSource,
      sessionDataSource: WorkoutSessionLocalDataSourceImpl(db),
      exerciseDataSource: ExerciseLocalDataSourceImpl(db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  PlanExerciseRecord exercise(String id, ExerciseType type, int rest) =>
      PlanExerciseRecord(
        exerciseId: id,
        exerciseName: id,
        type: type,
        targetSets: 3,
        restPeriodSec: rest,
      );

  Future<void> savePlan(String id, List<PlanExerciseRecord> exercises) async {
    final now = DateTime(2026, 1, 1);
    await ensureExercises(db, exercises.map((e) => e.exerciseId));
    await planSource.savePlan(
      WorkoutPlanRecord(
        planId: id,
        name: 'Plan $id',
        planExercises: exercises,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  test('empty database has no plans and no workout today', () async {
    final snapshot = await dataSource.getDashboardSnapshot();

    expect(snapshot.hasPlans, isFalse);
    expect(snapshot.todayWorkout, isNull);
  });

  test('plan assigned to today yields the today workout', () async {
    await savePlan('p1', [
      exercise('a', ExerciseType.timeBased, 45),
      exercise('b', ExerciseType.weighted, 90),
      exercise('c', ExerciseType.weighted, 60),
    ]);
    await scheduleSource.saveEntry(
      ScheduleEntryRecord(
        weekday: DateTime.now().weekday,
        planId: 'p1',
        planName: 'Plan p1',
      ),
    );

    final snapshot = await dataSource.getDashboardSnapshot();

    expect(snapshot.hasPlans, isTrue);
    final today = snapshot.todayWorkout;
    expect(today, isNotNull);
    expect(today!.planId, 'p1');
    expect(today.planName, 'Plan p1');
    expect(today.exerciseCount, 3);
    expect(today.dominantType, ExerciseType.weighted);
    expect(today.firstExerciseRestSec, 45);
  });

  test('plan scheduled on another weekday gives no today workout', () async {
    await savePlan('p1', [exercise('a', ExerciseType.weighted, 60)]);
    final otherDay = DateTime.now().weekday % 7 + 1;
    await scheduleSource.saveEntry(
      ScheduleEntryRecord(weekday: otherDay, planId: 'p1', planName: 'Plan p1'),
    );

    final snapshot = await dataSource.getDashboardSnapshot();

    expect(snapshot.hasPlans, isTrue);
    expect(snapshot.todayWorkout, isNull);
  });

  test('deleting the scheduled plan removes today\'s workout', () async {
    await savePlan('p1', [exercise('a', ExerciseType.weighted, 60)]);
    await scheduleSource.saveEntry(
      ScheduleEntryRecord(
        weekday: DateTime.now().weekday,
        planId: 'p1',
        planName: 'Plan p1',
      ),
    );

    await planSource.deletePlan('p1');
    final snapshot = await dataSource.getDashboardSnapshot();

    expect(snapshot.hasPlans, isFalse);
    expect(snapshot.todayWorkout, isNull);
  });
}
