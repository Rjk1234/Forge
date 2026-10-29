import 'package:forge/core/database/app_database.dart';
import 'package:forge/core/enums/exercise_type.dart';

/// Inserts catalogue rows so plans can reference them (plan exercises have a
/// foreign key to the exercises table).
Future<void> ensureExercises(
  AppDatabase db,
  Iterable<String> ids, {
  ExerciseType type = ExerciseType.weighted,
}) async {
  for (final id in ids) {
    await db
        .into(db.exercises)
        .insertOnConflictUpdate(
          ExercisesCompanion.insert(id: id, name: id, type: type),
        );
  }
}
