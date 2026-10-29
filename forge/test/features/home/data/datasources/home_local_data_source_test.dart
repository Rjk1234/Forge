import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/data/datasources/exercise_local_data_source.dart';
import 'package:forge/features/exercise/data/models/exercise_record.dart';
import 'package:forge/features/home/data/datasources/home_local_data_source.dart';
import 'package:forge/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:forge/features/schedule/data/models/schedule_entry_record.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/models/plan_exercise_record.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import 'package:forge/features/home/domain/entities/week_day_status.dart';
import 'package:forge/features/workout_session/data/models/actual_set_record.dart';
import 'package:forge/features/workout_session/data/models/session_exercise_record.dart';
import 'package:forge/features/workout_session/data/models/workout_session_record.dart';

// ---------------------------------------------------------------------------
// Manual fakes
// ---------------------------------------------------------------------------

class _FakePlanSource implements WorkoutPlanLocalDataSource {
  final List<WorkoutPlanRecord> plans;
  _FakePlanSource(this.plans);

  @override
  Future<List<WorkoutPlanRecord>> getAllPlans() async => plans;

  @override
  Future<WorkoutPlanRecord?> getPlanById(String id) async {
    try {
      return plans.firstWhere((p) => p.planId == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePlan(WorkoutPlanRecord plan) async {}

  @override
  Future<void> deletePlan(String planId) async {}
}

class _FakeScheduleSource implements ScheduleLocalDataSource {
  final List<ScheduleEntryRecord> entries;
  _FakeScheduleSource(this.entries);

  @override
  Future<List<ScheduleEntryRecord>> getAllEntries() async => entries;

  @override
  Future<ScheduleEntryRecord?> getEntryByWeekday(int weekday) async {
    try {
      return entries.firstWhere((e) => e.weekday == weekday);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveEntry(ScheduleEntryRecord entry) async {}

  @override
  Future<void> deleteEntry(int weekday) async {}

  @override
  Future<void> replaceAssignment({
    required String planId,
    required String planName,
    required Set<int> removedWeekdays,
    required Set<int> savedWeekdays,
  }) async {}
}

class _FakeExerciseSource implements ExerciseLocalDataSource {
  _FakeExerciseSource(this.exercises);

  final List<ExerciseRecord> exercises;

  @override
  Future<List<ExerciseRecord>> getAllExercises() async => exercises;

  @override
  Future<ExerciseRecord?> getExerciseById(String id) async =>
      exercises.where((e) => e.id == id).firstOrNull;

  @override
  Future<void> seedExercises(List<ExerciseRecord> exercises) async {}
}

class _FakeSessionSource implements WorkoutSessionLocalDataSource {
  final List<WorkoutSessionRecord> sessions;
  _FakeSessionSource(this.sessions);

  @override
  Future<List<WorkoutSessionRecord>> getAllSessions() async => sessions;

  @override
  Future<WorkoutSessionRecord?> getSessionById(String id) async => null;

  @override
  Future<List<WorkoutSessionRecord>> getSessionsByPlanId(String planId) async =>
      [];

  @override
  Future<void> saveSession(WorkoutSessionRecord session) async {}

  @override
  Future<void> deleteSession(String sessionId) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

WorkoutPlanRecord _makePlan({
  String id = 'p1',
  String name = 'Push Day',
  List<PlanExerciseRecord> exercises = const [],
}) => WorkoutPlanRecord(
  planId: id,
  name: name,
  planExercises: exercises,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

PlanExerciseRecord _makeExercise({
  ExerciseType type = ExerciseType.weighted,
  int restPeriodSec = 60,
}) => PlanExerciseRecord(
  exerciseId: 'ex1',
  exerciseName: 'Bench Press',
  type: type,
  targetSets: 3,
  restPeriodSec: restPeriodSec,
);

ScheduleEntryRecord _makeEntry(int weekday, String planId) =>
    ScheduleEntryRecord(weekday: weekday, planId: planId, planName: 'Push');

HomeDashboardLocalDataSourceImpl _dataSource({
  List<WorkoutPlanRecord> plans = const [],
  List<ScheduleEntryRecord> entries = const [],
  List<WorkoutSessionRecord> sessions = const [],
  List<ExerciseRecord> catalogue = const [],
  DateTime Function()? now,
}) => HomeDashboardLocalDataSourceImpl(
  planDataSource: _FakePlanSource(plans),
  scheduleDataSource: _FakeScheduleSource(entries),
  sessionDataSource: _FakeSessionSource(sessions),
  exerciseDataSource: _FakeExerciseSource(catalogue),
  now: now ?? DateTime.now,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('HomeDashboardLocalDataSourceImpl', () {
    test('hasPlans is false when there are no plans', () async {
      final result = await _dataSource().getDashboardSnapshot();
      expect(result.hasPlans, isFalse);
      expect(result.todayWorkout, isNull);
    });

    test('hasPlans is true when the plan source is non-empty', () async {
      final result = await _dataSource(
        plans: [_makePlan()],
      ).getDashboardSnapshot();
      expect(result.hasPlans, isTrue);
    });

    test('todayWorkout is null when no schedule entry for today', () async {
      final result = await _dataSource(
        plans: [_makePlan()],
      ).getDashboardSnapshot();
      expect(result.todayWorkout, isNull);
    });

    test('todayWorkout populated when schedule entry matches today', () async {
      final plan = _makePlan(exercises: [_makeExercise(restPeriodSec: 90)]);
      final entry = _makeEntry(DateTime.now().weekday, plan.planId);
      final result = await _dataSource(
        plans: [plan],
        entries: [entry],
      ).getDashboardSnapshot();

      expect(result.todayWorkout, isNotNull);
      expect(result.todayWorkout!.planId, plan.planId);
      expect(result.todayWorkout!.exerciseCount, 1);
      expect(result.todayWorkout!.firstExerciseRestSec, 90);
    });

    test('firstExerciseRestSec is null when plan has no exercises', () async {
      final plan = _makePlan(exercises: []);
      final entry = _makeEntry(DateTime.now().weekday, plan.planId);
      final result = await _dataSource(
        plans: [plan],
        entries: [entry],
      ).getDashboardSnapshot();

      expect(result.todayWorkout, isNotNull);
      expect(result.todayWorkout!.firstExerciseRestSec, isNull);
      expect(result.todayWorkout!.exerciseCount, 0);
    });

    test(
      'dominantType is weighted when weighted exercises are most frequent',
      () async {
        final plan = _makePlan(
          exercises: [
            _makeExercise(type: ExerciseType.weighted),
            _makeExercise(type: ExerciseType.weighted),
            _makeExercise(type: ExerciseType.bodyweight),
          ],
        );
        final entry = _makeEntry(DateTime.now().weekday, plan.planId);
        final result = await _dataSource(
          plans: [plan],
          entries: [entry],
        ).getDashboardSnapshot();

        expect(result.todayWorkout!.dominantType, ExerciseType.weighted);
      },
    );

    test(
      'tie-break: weighted wins over bodyweight when counts equal',
      () async {
        final plan = _makePlan(
          exercises: [
            _makeExercise(type: ExerciseType.weighted),
            _makeExercise(type: ExerciseType.bodyweight),
          ],
        );
        final entry = _makeEntry(DateTime.now().weekday, plan.planId);
        final result = await _dataSource(
          plans: [plan],
          entries: [entry],
        ).getDashboardSnapshot();

        expect(result.todayWorkout!.dominantType, ExerciseType.weighted);
      },
    );

    test(
      'todayWorkout is null when schedule entry planId has no matching plan',
      () async {
        final entry = _makeEntry(DateTime.now().weekday, 'missing-plan');
        final result = await _dataSource(
          entries: [entry],
        ).getDashboardSnapshot();

        expect(result.todayWorkout, isNull);
      },
    );
  });

  group('HomeDashboardLocalDataSourceImpl — richer dashboard', () {
    // Wednesday 14 October 2026.
    DateTime wednesday() => DateTime(2026, 10, 14, 9);

    WorkoutSessionRecord session(String id, DateTime completedAt) =>
        WorkoutSessionRecord(
          sessionId: id,
          planId: 'p1',
          planName: 'Push Day',
          completedAt: completedAt,
          startedAt: completedAt.subtract(const Duration(hours: 1)),
          sessionDurationSec: 3000,
          sessionExercises: const [
            SessionExerciseRecord(
              exerciseId: 'ex1',
              exerciseName: 'Bench Press',
              type: ExerciseType.weighted,
              actualSets: [
                ActualSetRecord(repetitions: 10, weight: 50),
                ActualSetRecord(repetitions: 8, weight: 50, skipped: true),
              ],
            ),
          ],
        );

    test('today carries targets, volume, time and muscle groups', () async {
      final plan = _makePlan(
        exercises: const [
          PlanExerciseRecord(
            exerciseId: 'ex1',
            exerciseName: 'Bench Press',
            type: ExerciseType.weighted,
            targetSets: 4,
            targetRepetitions: 10,
            targetWeight: 60,
            restPeriodSec: 75,
          ),
          PlanExerciseRecord(
            exerciseId: 'ex2',
            exerciseName: 'Plank',
            type: ExerciseType.timeBased,
            targetSets: 2,
            targetDurationSec: 60,
            restPeriodSec: 30,
          ),
        ],
      );
      final result = await _dataSource(
        plans: [plan],
        entries: [_makeEntry(DateTime.wednesday, plan.planId)],
        catalogue: const [
          ExerciseRecord(
            id: 'ex1',
            name: 'Bench Press',
            type: ExerciseType.weighted,
            muscleGroup: 'Chest',
          ),
          ExerciseRecord(
            id: 'ex2',
            name: 'Plank',
            type: ExerciseType.timeBased,
            muscleGroup: 'Core',
          ),
        ],
        now: wednesday,
      ).getDashboardSnapshot();

      final today = result.todayWorkout!;
      expect(today.exercises, hasLength(2));
      expect(today.exercises.first.name, 'Bench Press');
      expect(today.plannedVolumeKg, 2400);
      expect(today.totalSets, 6);
      // 4 x (45 + 75) + 2 x (60 + 30) = 660 s = 11 min
      expect(today.estimatedMinutes, 11);
      expect(today.muscleGroups, ['Chest', 'Core']);
    });

    group('today is done when its plan was completed today', () {
      Future<bool?> isCompletedToday({
        required String scheduledPlanId,
        required List<WorkoutSessionRecord> sessions,
      }) async {
        final plan = _makePlan(id: scheduledPlanId);
        final result = await _dataSource(
          plans: [plan],
          entries: [_makeEntry(DateTime.wednesday, plan.planId)],
          sessions: sessions,
          now: wednesday,
        ).getDashboardSnapshot();
        return result.todayWorkout?.isCompletedToday;
      }

      test('a session of the scheduled plan today', () async {
        expect(
          await isCompletedToday(
            scheduledPlanId: 'p1',
            sessions: [session('s1', DateTime(2026, 10, 14, 8))],
          ),
          isTrue,
        );
      });

      test('not when the session was yesterday', () async {
        expect(
          await isCompletedToday(
            scheduledPlanId: 'p1',
            sessions: [session('s1', DateTime(2026, 10, 13, 18))],
          ),
          isFalse,
        );
      });

      test('not when a different plan was done today', () async {
        expect(
          await isCompletedToday(
            scheduledPlanId: 'p2',
            sessions: [session('s1', DateTime(2026, 10, 14, 8))],
          ),
          isFalse,
        );
      });

      test('not when nothing was logged', () async {
        expect(
          await isCompletedToday(scheduledPlanId: 'p1', sessions: const []),
          isFalse,
        );
      });
    });

    test('the week marks completed, planned and rest days', () async {
      final plan = _makePlan();
      final result = await _dataSource(
        plans: [plan],
        entries: [
          _makeEntry(DateTime.monday, plan.planId),
          _makeEntry(DateTime.tuesday, plan.planId),
          _makeEntry(DateTime.wednesday, plan.planId),
        ],
        sessions: [
          session('s1', DateTime(2026, 10, 12, 18)),
          session('s2', DateTime(2026, 10, 12, 20)),
        ],
        now: wednesday,
      ).getDashboardSnapshot();

      final states = {for (final d in result.weekDays) d.weekday: d.state};
      expect(states[DateTime.monday], WeekDayState.completed);
      expect(states[DateTime.tuesday], WeekDayState.missed);
      expect(states[DateTime.wednesday], WeekDayState.planned);
      final monday = result.weekDays.first;
      expect(monday.session!.sessionId, 's2');
      expect(monday.session!.count, 2);
      expect(monday.plan!.planName, 'Push Day');
      expect(states[DateTime.friday], WeekDayState.rest);
      expect(
        result.weekDays.singleWhere((d) => d.isToday).weekday,
        DateTime.wednesday,
      );
    });

    test('a workout from last week does not mark this week', () async {
      final result = await _dataSource(
        sessions: [session('s1', DateTime(2026, 10, 9, 18))],
        now: wednesday,
      ).getDashboardSnapshot();

      expect(
        result.weekDays.every((d) => d.state != WeekDayState.completed),
        isTrue,
      );
    });

    test(
      'next workout wraps past Sunday and uses the live plan name',
      () async {
        final plan = _makePlan(id: 'p1', name: 'Renamed Push');
        final result = await _dataSource(
          plans: [plan],
          entries: [_makeEntry(DateTime.tuesday, plan.planId)],
          now: wednesday,
        ).getDashboardSnapshot();

        expect(result.hasSchedule, isTrue);
        expect(result.nextWorkout!.weekday, DateTime.tuesday);
        expect(result.nextWorkout!.planName, 'Renamed Push');
      },
    );

    test('no schedule means no next workout', () async {
      final result = await _dataSource(
        plans: [_makePlan()],
        now: wednesday,
      ).getDashboardSnapshot();

      expect(result.hasSchedule, isFalse);
      expect(result.nextWorkout, isNull);
    });

    test('last workout is the newest completed one, with its volume', () async {
      final result = await _dataSource(
        sessions: [
          session('old', DateTime(2026, 10, 1, 18)),
          session('new', DateTime(2026, 10, 12, 18)),
        ],
        now: wednesday,
      ).getDashboardSnapshot();

      expect(result.lastWorkout!.sessionId, 'new');
      expect(result.lastWorkout!.volumeKg, 500);
      expect(result.lastWorkout!.durationSec, 3000);
    });
  });
}
