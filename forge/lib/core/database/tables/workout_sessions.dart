// Column checks reference their own getter; this is Drift's documented
// pattern for CHECK constraints, so the self-reference lint is a false alarm.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:forge/core/validation/workout_value_rules.dart';

/// Completed workout sessions. Plan id and name are a snapshot, so deleting a
/// plan never alters workout history.
@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table {
  TextColumn get sessionId => text()();
  TextColumn get planId => text()();
  TextColumn get planName => text()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get sessionDurationSec => integer().check(
    sessionDurationSec.isBetweenValues(0, WorkoutLimits.maxSessionDurationSec),
  )();
  DateTimeColumn get startedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {sessionId};
}
