// Column checks reference their own getter; this is Drift's documented
// pattern for CHECK constraints, so the self-reference lint is a false alarm.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/core/database/tables/exercises.dart';
import 'package:forge/core/database/tables/workout_plans.dart';
import 'package:forge/core/enums/exercise_type.dart';

/// Ordered exercises of a plan; removed together with the plan.
@DataClassName('PlanExerciseRow')
class PlanExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get planId =>
      text().references(WorkoutPlans, #planId, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.restrict)();
  TextColumn get exerciseName => text()();
  TextColumn get type => textEnum<ExerciseType>()();
  IntColumn get targetSets =>
      integer().check(targetSets.isBetweenValues(1, WorkoutLimits.maxSets))();
  IntColumn get targetRepetitions => integer().nullable().check(
    targetRepetitions.isBetweenValues(1, WorkoutLimits.maxRepetitions),
  )();
  RealColumn get targetWeight => real().nullable().check(
    targetWeight.isBiggerThanValue(0) &
        targetWeight.isSmallerOrEqualValue(WorkoutLimits.maxWeightKg),
  )();
  IntColumn get targetDurationSec => integer().nullable().check(
    targetDurationSec.isBetweenValues(1, WorkoutLimits.maxDurationSec),
  )();
  IntColumn get restPeriodSec => integer().check(
    restPeriodSec.isBetweenValues(0, WorkoutLimits.maxRestSec),
  )();
}
