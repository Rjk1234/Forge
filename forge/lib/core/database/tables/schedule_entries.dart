// Column checks reference their own getter; this is Drift's documented
// pattern for CHECK constraints, so the self-reference lint is a false alarm.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:forge/core/database/tables/workout_plans.dart';

/// One plan per weekday (1 = Monday … 7 = Sunday). The plan id and name are
/// stored as a snapshot; deleting a plan removes its entries (cascade).
@DataClassName('ScheduleEntryRow')
class ScheduleEntries extends Table {
  IntColumn get weekday => integer().check(weekday.isBetweenValues(1, 7))();
  TextColumn get planId =>
      text().references(WorkoutPlans, #planId, onDelete: KeyAction.cascade)();
  TextColumn get planName => text()();

  @override
  Set<Column> get primaryKey => {weekday};
}
