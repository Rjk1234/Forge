import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/data/datasources/exercise_local_data_source.dart';
import 'package:forge/features/home/domain/entities/dashboard_snapshot.dart';
import 'package:forge/features/home/domain/entities/last_workout.dart';
import 'package:forge/features/home/domain/entities/planned_exercise.dart';
import 'package:forge/features/home/domain/entities/today_workout.dart';
import 'package:forge/features/home/domain/entities/week_day_status.dart';
import 'package:forge/features/home/domain/rules/planned_workout_math.dart';
import 'package:forge/features/home/domain/rules/week_overview.dart';
import 'package:forge/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:forge/features/schedule/data/models/schedule_entry_record.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/models/plan_exercise_record.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import 'package:forge/features/workout_session/data/mappers/workout_session_mapper.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/rules/completed_today_rule.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';
import 'package:forge/features/workout_session/domain/rules/session_ordering.dart';
import 'package:forge/features/workout_session/domain/rules/workout_volume.dart';

abstract class HomeDashboardLocalDataSource {
  Future<DashboardSnapshot> getDashboardSnapshot();
}

class HomeDashboardLocalDataSourceImpl implements HomeDashboardLocalDataSource {
  const HomeDashboardLocalDataSourceImpl({
    required this.planDataSource,
    required this.scheduleDataSource,
    required this.sessionDataSource,
    required this.exerciseDataSource,
    this.now = DateTime.now,
  });

  /// Muscle groups shown in the plan description.
  static const int maxDescribedMuscleGroups = 3;

  final WorkoutPlanLocalDataSource planDataSource;
  final ScheduleLocalDataSource scheduleDataSource;
  final WorkoutSessionLocalDataSource sessionDataSource;
  final ExerciseLocalDataSource exerciseDataSource;

  /// The clock, replaceable in tests.
  final DateTime Function() now;

  @override
  Future<DashboardSnapshot> getDashboardSnapshot() async {
    final today = now();
    final plans = await planDataSource.getAllPlans();
    final entries = await scheduleDataSource.getAllEntries();
    final sessions = (await sessionDataSource.getAllSessions())
        .map(WorkoutSessionMapper.toDomain)
        .where(isCompletedSession)
        .toList();

    return DashboardSnapshot(
      hasPlans: plans.isNotEmpty,
      todayWorkout: await _buildTodayWorkout(today, plans, entries, sessions),
      weekDays: buildWeekDays(
        today: today,
        planned: _plannedByWeekday(plans, entries),
        completed: _completedByWeekday(today, sessions),
      ),
      nextWorkout: findNextWorkout(
        todayWeekday: today.weekday,
        planNameByWeekday: _planNames(plans, entries),
      ),
      hasSchedule: entries.isNotEmpty,
      lastWorkout: _lastWorkout(sessions),
    );
  }

  Future<TodayWorkout?> _buildTodayWorkout(
    DateTime today,
    List<WorkoutPlanRecord> plans,
    List<ScheduleEntryRecord> entries,
    List<WorkoutSession> sessions,
  ) async {
    final entry = entries.where((e) => e.weekday == today.weekday).firstOrNull;
    final plan = plans.where((p) => p.planId == entry?.planId).firstOrNull;
    if (plan == null) return null;

    final records = plan.planExercises;
    final exercises = records.map(_toPlannedExercise).toList();
    return TodayWorkout(
      planId: plan.planId,
      planName: plan.name,
      exerciseCount: records.length,
      dominantType: _dominantType(records),
      firstExerciseRestSec: records.isEmpty
          ? null
          : records.first.restPeriodSec,
      exercises: exercises,
      muscleGroups: await _muscleGroups(records),
      estimatedMinutes: estimatedWorkoutMinutes(exercises),
      plannedVolumeKg: plannedVolumeKg(exercises),
      totalSets: plannedSetCount(exercises),
      isCompletedToday: hasCompletedWorkoutOn(
        sessions: sessions,
        planId: plan.planId,
        day: today,
      ),
    );
  }

  PlannedExercise _toPlannedExercise(PlanExerciseRecord record) =>
      PlannedExercise(
        name: record.exerciseName,
        type: record.type,
        sets: record.targetSets,
        restSec: record.restPeriodSec,
        repetitions: record.targetRepetitions,
        weightKg: record.targetWeight,
        durationSec: record.targetDurationSec,
      );

  /// Distinct muscle groups in plan order, from the exercise catalogue.
  Future<List<String>> _muscleGroups(List<PlanExerciseRecord> records) async {
    final groups = <String>[];
    for (final record in records) {
      final group = (await exerciseDataSource.getExerciseById(
        record.exerciseId,
      ))?.muscleGroup;
      if (group != null && !groups.contains(group)) groups.add(group);
    }
    return groups.take(maxDescribedMuscleGroups).toList();
  }

  /// Latest completed workout per weekday of the week containing [today].
  Map<int, WeekSessionRef> _completedByWeekday(
    DateTime today,
    List<WorkoutSession> sessions,
  ) {
    final monday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );
    final nextMonday = monday.add(const Duration(days: daysInWeek));
    final byWeekday = <int, List<WorkoutSession>>{};
    for (final session in sessions) {
      final done = session.completedAt;
      if (done.isBefore(monday) || !done.isBefore(nextMonday)) continue;
      byWeekday.putIfAbsent(done.weekday, () => []).add(session);
    }
    return {
      for (final entry in byWeekday.entries)
        entry.key: WeekSessionRef(
          sessionId:
              (entry.value..sort(compareSessionsNewestFirst)).first.sessionId,
          planName: entry.value.first.planName,
          count: entry.value.length,
        ),
    };
  }

  Map<int, WeekPlanRef> _plannedByWeekday(
    List<WorkoutPlanRecord> plans,
    List<ScheduleEntryRecord> entries,
  ) {
    final nameById = {for (final plan in plans) plan.planId: plan.name};
    return {
      for (final entry in entries)
        entry.weekday: WeekPlanRef(
          planId: entry.planId,
          planName: nameById[entry.planId] ?? entry.planName,
        ),
    };
  }

  Map<int, String> _planNames(
    List<WorkoutPlanRecord> plans,
    List<ScheduleEntryRecord> entries,
  ) {
    final nameById = {for (final plan in plans) plan.planId: plan.name};
    return {
      for (final entry in entries)
        entry.weekday: nameById[entry.planId] ?? entry.planName,
    };
  }

  LastWorkout? _lastWorkout(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return null;
    final latest = ([...sessions]..sort(compareSessionsNewestFirst)).first;
    return LastWorkout(
      sessionId: latest.sessionId,
      planName: latest.planName,
      completedAt: latest.completedAt,
      durationSec: latest.sessionDurationSec,
      volumeKg: totalVolume([latest]),
    );
  }

  ExerciseType _dominantType(List<PlanExerciseRecord> exercises) {
    if (exercises.isEmpty) return ExerciseType.bodyweight;
    final typeCounts = <ExerciseType, int>{};
    for (final exercise in exercises) {
      typeCounts[exercise.type] = (typeCounts[exercise.type] ?? 0) + 1;
    }
    // Tie-break: weighted > bodyweight > timeBased
    final sorted = typeCounts.entries.toList()
      ..sort((a, b) {
        if (a.value != b.value) return b.value - a.value;
        return _typePriority(a.key) - _typePriority(b.key);
      });
    return sorted.first.key;
  }

  // Lower number = higher priority in tie-break.
  int _typePriority(ExerciseType type) => switch (type) {
    ExerciseType.weighted => 0,
    ExerciseType.bodyweight => 1,
    ExerciseType.timeBased => 2,
  };
}
