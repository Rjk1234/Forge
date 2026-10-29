// Column checks reference their own getter; this is Drift's documented
// pattern for CHECK constraints, so the self-reference lint is a false alarm.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/core/database/tables/session_exercises.dart';

/// Ordered sets actually performed for a session exercise.
@DataClassName('ActualSetRow')
class ActualSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionExerciseId => integer().references(
    SessionExercises,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get position => integer()();
  IntColumn get repetitions => integer().nullable().check(
    repetitions.isBetweenValues(1, WorkoutLimits.maxRepetitions),
  )();
  RealColumn get weight => real().nullable().check(
    weight.isBiggerThanValue(0) &
        weight.isSmallerOrEqualValue(WorkoutLimits.maxWeightKg),
  )();
  IntColumn get durationSec => integer().nullable().check(
    durationSec.isBetweenValues(1, WorkoutLimits.maxDurationSec),
  )();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
}
