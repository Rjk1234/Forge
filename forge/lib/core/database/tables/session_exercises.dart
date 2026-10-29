import 'package:drift/drift.dart';
import 'package:forge/core/database/tables/workout_sessions.dart';
import 'package:forge/core/enums/exercise_type.dart';

/// Ordered exercises performed in a session; removed with the session.
@DataClassName('SessionExerciseRow')
class SessionExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().references(
    WorkoutSessions,
    #sessionId,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get position => integer()();
  TextColumn get exerciseId => text()();
  TextColumn get exerciseName => text()();
  TextColumn get type => textEnum<ExerciseType>()();
}
