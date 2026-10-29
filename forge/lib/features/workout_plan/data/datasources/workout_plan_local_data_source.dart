import 'package:drift/drift.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/features/workout_plan/data/models/plan_exercise_record.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';

abstract class WorkoutPlanLocalDataSource {
  Future<List<WorkoutPlanRecord>> getAllPlans();
  Future<WorkoutPlanRecord?> getPlanById(String planId);
  Future<void> savePlan(WorkoutPlanRecord model);
  Future<void> deletePlan(String planId);
}

class WorkoutPlanLocalDataSourceImpl implements WorkoutPlanLocalDataSource {
  WorkoutPlanLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<WorkoutPlanRecord>> getAllPlans() async {
    final planQuery = _database.select(_database.workoutPlans)
      ..orderBy([(t) => OrderingTerm.asc(t.planId)]);
    final plans = await planQuery.get();
    return _assemble(plans);
  }

  @override
  Future<WorkoutPlanRecord?> getPlanById(String planId) async {
    final planQuery = _database.select(_database.workoutPlans)
      ..where((t) => t.planId.equals(planId));
    final plans = await planQuery.get();
    final assembled = await _assemble(plans);
    return assembled.isEmpty ? null : assembled.first;
  }

  @override
  Future<void> savePlan(WorkoutPlanRecord model) {
    return _database.transaction(() async {
      await _database
          .into(_database.workoutPlans)
          .insertOnConflictUpdate(
            WorkoutPlansCompanion.insert(
              planId: model.planId,
              name: model.name,
              createdAt: model.createdAt,
              updatedAt: model.updatedAt,
            ),
          );
      await (_database.delete(
        _database.planExercises,
      )..where((t) => t.planId.equals(model.planId))).go();
      await _database.batch((batch) {
        batch.insertAll(_database.planExercises, [
          for (var i = 0; i < model.planExercises.length; i++)
            _toCompanion(model.planId, i, model.planExercises[i]),
        ]);
      });
    });
  }

  @override
  Future<void> deletePlan(String planId) async {
    await (_database.delete(
      _database.workoutPlans,
    )..where((t) => t.planId.equals(planId))).go();
  }

  Future<List<WorkoutPlanRecord>> _assemble(List<WorkoutPlanRow> plans) async {
    if (plans.isEmpty) return const [];
    final exerciseQuery = _database.select(_database.planExercises)
      ..where((t) => t.planId.isIn(plans.map((plan) => plan.planId)))
      ..orderBy([(t) => OrderingTerm.asc(t.position)]);
    final exerciseRows = await exerciseQuery.get();

    final exercisesByPlan = <String, List<PlanExerciseRecord>>{};
    for (final row in exerciseRows) {
      exercisesByPlan.putIfAbsent(row.planId, () => []).add(_toRecord(row));
    }
    return [
      for (final plan in plans)
        WorkoutPlanRecord(
          planId: plan.planId,
          name: plan.name,
          planExercises: exercisesByPlan[plan.planId] ?? const [],
          createdAt: plan.createdAt,
          updatedAt: plan.updatedAt,
        ),
    ];
  }

  PlanExerciseRecord _toRecord(PlanExerciseRow row) => PlanExerciseRecord(
    exerciseId: row.exerciseId,
    exerciseName: row.exerciseName,
    type: row.type,
    targetSets: row.targetSets,
    targetRepetitions: row.targetRepetitions,
    targetWeight: row.targetWeight,
    targetDurationSec: row.targetDurationSec,
    restPeriodSec: row.restPeriodSec,
  );

  PlanExercisesCompanion _toCompanion(
    String planId,
    int position,
    PlanExerciseRecord record,
  ) => PlanExercisesCompanion.insert(
    planId: planId,
    position: position,
    exerciseId: record.exerciseId,
    exerciseName: record.exerciseName,
    type: record.type,
    targetSets: record.targetSets,
    targetRepetitions: Value(record.targetRepetitions),
    targetWeight: Value(record.targetWeight),
    targetDurationSec: Value(record.targetDurationSec),
    restPeriodSec: record.restPeriodSec,
  );
}
