import 'package:drift/drift.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/features/exercise/data/models/exercise_record.dart';

abstract class ExerciseLocalDataSource {
  /// All exercises from the seeded catalogue.
  Future<List<ExerciseRecord>> getAllExercises();

  /// Single exercise by ID, or null if not found.
  Future<ExerciseRecord?> getExerciseById(String id);

  /// Brings the catalogue in line with [exercises] (called by
  /// ExerciseSeedService on every launch; the catalogue is read-only data).
  /// Existing rows are updated in place and an exercise that has left the
  /// seed is removed only while no plan references it.
  Future<void> seedExercises(List<ExerciseRecord> exercises);
}

class ExerciseLocalDataSourceImpl implements ExerciseLocalDataSource {
  ExerciseLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<ExerciseRecord>> getAllExercises() async {
    final query = _database.select(_database.exercises)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    final rows = await query.get();
    return rows.map(_toRecord).toList();
  }

  @override
  Future<ExerciseRecord?> getExerciseById(String id) async {
    final query = _database.select(_database.exercises)
      ..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toRecord(row);
  }

  @override
  Future<void> seedExercises(List<ExerciseRecord> exercises) {
    return _database.transaction(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.exercises,
          exercises.map(_toCompanion).toList(),
        );
      });
      await _removeUnreferencedLeftovers({for (final e in exercises) e.id});
    });
  }

  Future<void> _removeUnreferencedLeftovers(Set<String> seededIds) async {
    final referenceQuery = _database.selectOnly(
      _database.planExercises,
      distinct: true,
    )..addColumns([_database.planExercises.exerciseId]);
    final referenced = await referenceQuery
        .map((row) => row.read(_database.planExercises.exerciseId)!)
        .get();
    await (_database.delete(
      _database.exercises,
    )..where((t) => t.id.isNotIn(seededIds) & t.id.isNotIn(referenced))).go();
  }

  ExerciseRecord _toRecord(ExerciseRow row) => ExerciseRecord(
    id: row.id,
    name: row.name,
    type: row.type,
    muscleGroup: row.muscleGroup,
    description: row.description,
  );

  ExercisesCompanion _toCompanion(ExerciseRecord record) =>
      ExercisesCompanion.insert(
        id: record.id,
        name: record.name,
        type: record.type,
        muscleGroup: Value(record.muscleGroup),
        description: Value(record.description),
      );
}
