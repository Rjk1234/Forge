import 'package:drift/drift.dart' show HasResultSet, ResultSetImplementation;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/profile/data/datasources/account_data_local_data_source.dart';
import 'package:forge/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:forge/features/profile/data/models/user_profile_record.dart';
import 'package:forge/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:forge/features/schedule/data/models/schedule_entry_record.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/models/plan_exercise_record.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import 'package:forge/features/workout_session/data/models/actual_set_record.dart';
import 'package:forge/features/workout_session/data/models/session_exercise_record.dart';
import 'package:forge/features/workout_session/data/models/workout_session_record.dart';

import '../../../../helpers/database.dart';

void main() {
  late AppDatabase db;
  late AccountDataLocalDataSourceImpl dataSource;
  final now = DateTime(2026, 10, 1, 9);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = AccountDataLocalDataSourceImpl(db);
    await ensureExercises(db, ['bench']);
    await ProfileLocalDataSourceImpl(db).saveProfile(
      UserProfileRecord(
        displayName: 'Alex',
        fitnessGoal: 'Strength',
        experienceLevel: 'Beginner',
        heightCm: 180,
        weightKg: 80,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await WorkoutPlanLocalDataSourceImpl(db).savePlan(
      WorkoutPlanRecord(
        planId: 'p1',
        name: 'Push',
        planExercises: const [
          PlanExerciseRecord(
            exerciseId: 'bench',
            exerciseName: 'bench',
            type: ExerciseType.weighted,
            targetSets: 3,
            restPeriodSec: 60,
            targetRepetitions: 8,
            targetWeight: 60,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    );
    await ScheduleLocalDataSourceImpl(db).saveEntry(
      const ScheduleEntryRecord(weekday: 1, planId: 'p1', planName: 'Push'),
    );
    await WorkoutSessionLocalDataSourceImpl(db).saveSession(
      WorkoutSessionRecord(
        sessionId: 's1',
        planId: 'p1',
        planName: 'Push',
        completedAt: now,
        startedAt: now.subtract(const Duration(hours: 1)),
        sessionDurationSec: 3000,
        sessionExercises: const [
          SessionExerciseRecord(
            exerciseId: 'bench',
            exerciseName: 'bench',
            type: ExerciseType.weighted,
            actualSets: [ActualSetRecord(repetitions: 8, weight: 60)],
          ),
        ],
      ),
    );
  });

  tearDown(() => db.close());

  Future<int> count(
    ResultSetImplementation<HasResultSet, dynamic> table,
  ) async => (await db.select(table).get()).length;

  test('the fixture really holds data in every user table', () async {
    expect(await count(db.userProfiles), 1);
    expect(await count(db.workoutPlans), 1);
    expect(await count(db.planExercises), 1);
    expect(await count(db.scheduleEntries), 1);
    expect(await count(db.workoutSessions), 1);
    expect(await count(db.sessionExercises), 1);
    expect(await count(db.actualSets), 1);
  });

  test('clearUserData empties every user table', () async {
    await dataSource.clearUserData();

    expect(await count(db.userProfiles), 0);
    expect(await count(db.workoutPlans), 0);
    expect(await count(db.planExercises), 0);
    expect(await count(db.scheduleEntries), 0);
    expect(await count(db.workoutSessions), 0);
    expect(await count(db.sessionExercises), 0);
    expect(await count(db.actualSets), 0);
  });

  test('the exercise catalogue is kept', () async {
    await dataSource.clearUserData();

    expect(await count(db.exercises), 1);
  });

  test('a new user can start again after the wipe', () async {
    await dataSource.clearUserData();

    await WorkoutPlanLocalDataSourceImpl(db).savePlan(
      WorkoutPlanRecord(
        planId: 'p2',
        name: 'Pull',
        planExercises: const [
          PlanExerciseRecord(
            exerciseId: 'bench',
            exerciseName: 'bench',
            type: ExerciseType.weighted,
            targetSets: 3,
            restPeriodSec: 60,
            targetRepetitions: 8,
            targetWeight: 60,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(await count(db.workoutPlans), 1);
    expect(await ProfileLocalDataSourceImpl(db).getProfile(), isNull);
  });

  test('clearing an already empty database is harmless', () async {
    await dataSource.clearUserData();
    await dataSource.clearUserData();

    expect(await count(db.workoutPlans), 0);
  });
}
