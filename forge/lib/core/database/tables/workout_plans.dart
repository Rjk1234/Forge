// Column checks reference their own getter; this is Drift's documented
// pattern for CHECK constraints, so the self-reference lint is a false alarm.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:forge/core/validation/workout_value_rules.dart';

/// User-created workout plans. Independent of completed workout history.
@DataClassName('WorkoutPlanRow')
class WorkoutPlans extends Table {
  TextColumn get planId => text()();
  TextColumn get name => text().check(
    name.trim().length.isBetweenValues(1, WorkoutLimits.maxPlanNameLength),
  )();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {planId};
}
