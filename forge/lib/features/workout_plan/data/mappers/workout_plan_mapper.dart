import 'package:forge/features/workout_plan/data/models/plan_exercise_record.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';

class WorkoutPlanMapper {
  const WorkoutPlanMapper._();

  static WorkoutPlan fromRecord(WorkoutPlanRecord model) => WorkoutPlan(
    id: model.planId,
    name: model.name,
    exerciseCount: model.planExercises.length,
    createdAt: model.createdAt,
  );

  static WorkoutPlanDetail toDetailFromRecord(WorkoutPlanRecord model) =>
      WorkoutPlanDetail(
        id: model.planId,
        name: model.name,
        exercises: model.planExercises
            .map(planExerciseFromRecord)
            .toList(growable: false),
        createdAt: model.createdAt,
      );

  static PlanExercise planExerciseFromRecord(PlanExerciseRecord model) =>
      PlanExercise(
        exerciseId: model.exerciseId,
        exerciseName: model.exerciseName,
        type: model.type,
        targetSets: model.targetSets,
        restPeriodSec: model.restPeriodSec,
        targetRepetitions: model.targetRepetitions,
        targetWeight: model.targetWeight,
        targetDurationSec: model.targetDurationSec,
      );

  static WorkoutPlanRecord toRecord(WorkoutPlanDetail detail) =>
      WorkoutPlanRecord(
        planId: detail.id,
        name: detail.name,
        planExercises: detail.exercises
            .map(_planExerciseToRecord)
            .toList(growable: false),
        createdAt: detail.createdAt,
        updatedAt: DateTime.now(),
      );

  static PlanExerciseRecord _planExerciseToRecord(PlanExercise exercise) =>
      PlanExerciseRecord(
        exerciseId: exercise.exerciseId,
        exerciseName: exercise.exerciseName,
        type: exercise.type,
        targetSets: exercise.targetSets,
        restPeriodSec: exercise.restPeriodSec,
        targetRepetitions: exercise.targetRepetitions,
        targetWeight: exercise.targetWeight,
        targetDurationSec: exercise.targetDurationSec,
      );
}
