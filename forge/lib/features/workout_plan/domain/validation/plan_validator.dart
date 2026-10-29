import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/domain/validation/plan_violation.dart';

/// Checks a plan against the manager's rules before it can be stored.
class PlanValidator {
  const PlanValidator();

  List<PlanViolation> validate(WorkoutPlanDetail plan) {
    return [
      if (!WorkoutValueRules.isValidName(plan.name))
        const PlanViolation(PlanViolationType.nameInvalid),
      if (plan.exercises.isEmpty)
        const PlanViolation(PlanViolationType.exercisesRequired),
      for (var i = 0; i < plan.exercises.length; i++)
        ..._validateExercise(plan.exercises[i], i),
    ];
  }

  List<PlanViolation> _validateExercise(PlanExercise exercise, int index) {
    PlanViolation violation(PlanViolationType type) =>
        PlanViolation(type, exerciseIndex: index);

    return [
      if (!WorkoutValueRules.isValidSetCount(exercise.targetSets))
        violation(PlanViolationType.setsInvalid),
      if (!WorkoutValueRules.isValidRestSec(exercise.restPeriodSec))
        violation(PlanViolationType.restInvalid),
      ...switch (exercise.type) {
        ExerciseType.weighted => [
          if (!WorkoutValueRules.isValidRepetitions(exercise.targetRepetitions))
            violation(PlanViolationType.repetitionsInvalid),
          if (!WorkoutValueRules.isValidWeight(exercise.targetWeight))
            violation(PlanViolationType.weightInvalid),
          if (exercise.targetDurationSec != null)
            violation(PlanViolationType.unexpectedField),
        ],
        ExerciseType.bodyweight => [
          if (!WorkoutValueRules.isValidRepetitions(exercise.targetRepetitions))
            violation(PlanViolationType.repetitionsInvalid),
          if (exercise.targetWeight != null ||
              exercise.targetDurationSec != null)
            violation(PlanViolationType.unexpectedField),
        ],
        ExerciseType.timeBased => [
          if (!WorkoutValueRules.isValidDurationSec(exercise.targetDurationSec))
            violation(PlanViolationType.durationInvalid),
          if (exercise.targetRepetitions != null ||
              exercise.targetWeight != null)
            violation(PlanViolationType.unexpectedField),
        ],
      },
    ];
  }
}
