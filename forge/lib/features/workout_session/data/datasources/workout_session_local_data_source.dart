import 'package:drift/drift.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/features/workout_session/data/models/actual_set_record.dart';
import 'package:forge/features/workout_session/data/models/session_exercise_record.dart';
import 'package:forge/features/workout_session/data/models/workout_session_record.dart';

abstract class WorkoutSessionLocalDataSource {
  /// All completed session records, unsorted.
  Future<List<WorkoutSessionRecord>> getAllSessions();

  /// Sessions for a specific plan (for history filtering).
  Future<List<WorkoutSessionRecord>> getSessionsByPlanId(String planId);

  /// Single session by ID.
  Future<WorkoutSessionRecord?> getSessionById(String sessionId);

  /// Persist a completed session record.
  Future<void> saveSession(WorkoutSessionRecord model);

  /// Delete a session record (e.g. data-clear flow).
  Future<void> deleteSession(String sessionId);
}

class WorkoutSessionLocalDataSourceImpl
    implements WorkoutSessionLocalDataSource {
  WorkoutSessionLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<WorkoutSessionRecord>> getAllSessions() => _load();

  @override
  Future<List<WorkoutSessionRecord>> getSessionsByPlanId(String planId) =>
      _load(where: (t) => t.planId.equals(planId));

  @override
  Future<WorkoutSessionRecord?> getSessionById(String sessionId) async {
    final sessions = await _load(where: (t) => t.sessionId.equals(sessionId));
    return sessions.isEmpty ? null : sessions.first;
  }

  @override
  Future<void> saveSession(WorkoutSessionRecord model) {
    return _database.transaction(() async {
      await _deleteRows(model.sessionId);
      await _database
          .into(_database.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              sessionId: model.sessionId,
              planId: model.planId,
              planName: model.planName,
              completedAt: model.completedAt,
              sessionDurationSec: model.sessionDurationSec,
              startedAt: Value(model.startedAt),
            ),
          );
      for (var i = 0; i < model.sessionExercises.length; i++) {
        await _insertExercise(model.sessionId, i, model.sessionExercises[i]);
      }
    });
  }

  @override
  Future<void> deleteSession(String sessionId) => _deleteRows(sessionId);

  Future<void> _deleteRows(String sessionId) async {
    await (_database.delete(
      _database.workoutSessions,
    )..where((t) => t.sessionId.equals(sessionId))).go();
  }

  Future<void> _insertExercise(
    String sessionId,
    int position,
    SessionExerciseRecord exercise,
  ) async {
    final exerciseId = await _database
        .into(_database.sessionExercises)
        .insert(
          SessionExercisesCompanion.insert(
            sessionId: sessionId,
            position: position,
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.exerciseName,
            type: exercise.type,
          ),
        );
    await _database.batch((batch) {
      batch.insertAll(_database.actualSets, [
        for (var i = 0; i < exercise.actualSets.length; i++)
          ActualSetsCompanion.insert(
            sessionExerciseId: exerciseId,
            position: i,
            repetitions: Value(exercise.actualSets[i].repetitions),
            weight: Value(exercise.actualSets[i].weight),
            durationSec: Value(exercise.actualSets[i].durationSec),
            skipped: Value(exercise.actualSets[i].skipped),
          ),
      ]);
    });
  }

  Future<List<WorkoutSessionRecord>> _load({
    Expression<bool> Function($WorkoutSessionsTable table)? where,
  }) async {
    final sessionQuery = _database.select(_database.workoutSessions)
      ..orderBy([(t) => OrderingTerm.asc(t.sessionId)]);
    if (where != null) sessionQuery.where(where);
    final sessions = await sessionQuery.get();
    if (sessions.isEmpty) return const [];

    final exerciseQuery = _database.select(_database.sessionExercises)
      ..where((t) => t.sessionId.isIn(sessions.map((s) => s.sessionId)))
      ..orderBy([(t) => OrderingTerm.asc(t.position)]);
    final exerciseRows = await exerciseQuery.get();

    final setQuery = _database.select(_database.actualSets)
      ..where((t) => t.sessionExerciseId.isIn(exerciseRows.map((e) => e.id)))
      ..orderBy([(t) => OrderingTerm.asc(t.position)]);
    final setRows = await setQuery.get();

    return _assemble(sessions, exerciseRows, setRows);
  }

  List<WorkoutSessionRecord> _assemble(
    List<WorkoutSessionRow> sessions,
    List<SessionExerciseRow> exerciseRows,
    List<ActualSetRow> setRows,
  ) {
    final setsByExercise = <int, List<ActualSetRecord>>{};
    for (final row in setRows) {
      setsByExercise
          .putIfAbsent(row.sessionExerciseId, () => [])
          .add(
            ActualSetRecord(
              repetitions: row.repetitions,
              weight: row.weight,
              durationSec: row.durationSec,
              skipped: row.skipped,
            ),
          );
    }
    final exercisesBySession = <String, List<SessionExerciseRecord>>{};
    for (final row in exerciseRows) {
      exercisesBySession
          .putIfAbsent(row.sessionId, () => [])
          .add(
            SessionExerciseRecord(
              exerciseId: row.exerciseId,
              exerciseName: row.exerciseName,
              type: row.type,
              actualSets: setsByExercise[row.id] ?? const [],
            ),
          );
    }
    return [
      for (final session in sessions)
        WorkoutSessionRecord(
          sessionId: session.sessionId,
          planId: session.planId,
          planName: session.planName,
          completedAt: session.completedAt,
          sessionDurationSec: session.sessionDurationSec,
          sessionExercises: exercisesBySession[session.sessionId] ?? const [],
          startedAt: session.startedAt,
        ),
    ];
  }
}
