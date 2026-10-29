# Contract: WorkoutSessionRepository

**Feature**: LOCALDB-01 Local Data Persistence
**File**: `forge/lib/features/workout_session/domain/repositories/workout_session_repository.dart`
**Status**: NEW — to be implemented

---

## Interface Definition

```dart
abstract class WorkoutSessionRepository {
  /// Returns all completed session records, unsorted.
  /// Never throws — returns Left(WorkoutSessionFailure.readFailure) on a database exception.
  Future<Either<WorkoutSessionFailure, List<WorkoutSession>>> getAllSessions();

  /// Returns all completed sessions for a specific plan (for history filtering).
  /// Never throws — returns Left(WorkoutSessionFailure.readFailure) on a database exception.
  Future<Either<WorkoutSessionFailure, List<WorkoutSession>>> getSessionsByPlanId(String planId);

  /// Returns a single session by ID, or null if not found.
  /// Never throws — returns Left(WorkoutSessionFailure.readFailure) on a database exception.
  Future<Either<WorkoutSessionFailure, WorkoutSession?>> getSessionById(String sessionId);

  /// Persists a completed session record.
  ///
  /// Enforces the completion criterion (FR-003):
  ///   - session.sessionExercises must be non-empty
  ///   - At least one SessionExercise.actualSets must be non-empty
  /// If criterion fails → Left(WorkoutSessionFailure.completionCriterionNotMet())
  ///   and NO write is performed (FR-004).
  ///
  /// On a database exception → Left(WorkoutSessionFailure.saveFailure)
  ///   and the write transaction is rolled back, so previously persisted data is NOT corrupted (FR-011).
  ///
  /// Never throws.
  Future<Either<WorkoutSessionFailure, Unit>> saveSession(WorkoutSession session);

  /// Deletes a session record (e.g. data-clear flows).
  /// Never throws — returns Left(WorkoutSessionFailure.deleteFailure) on a database exception.
  Future<Either<WorkoutSessionFailure, Unit>> deleteSession(String sessionId);
}
```

---

## Completion Criterion (FR-003 / FR-004)

The repository implementation MUST enforce this guard before calling the data source:

```dart
bool _meetsCompletionCriterion(WorkoutSession session) {
  if (session.sessionExercises.isEmpty) return false;
  return session.sessionExercises.any((e) => e.actualSets.isNotEmpty);
}
```

If `_meetsCompletionCriterion` returns `false`:
- Return `Left(WorkoutSessionFailure.completionCriterionNotMet())`
- Do NOT call `dataSource.saveSession()`
- No database write occurs — history is unchanged

---

## Error Mapping (Constitution II.5 / VI.2)

```dart
// In WorkoutSessionRepositoryImpl.saveSession:
try {
  final record = mapper.toRecord(session);
  await dataSource.saveSession(record); // one database.transaction
  return const Right(unit);
} on SqliteException catch (e) {
  return Left(WorkoutSessionFailure.saveFailure(detail: e.message));
} catch (e) {
  return Left(WorkoutSessionFailure.saveFailure(detail: e.toString()));
}
```

The same pattern applies to `deleteSession` (catching and returning `deleteFailure`).

For reads (also asynchronous), await inside try/catch returning `readFailure`.

---

## Invariants

| Invariant | Source |
|-----------|--------|
| A write failure MUST NOT corrupt previously persisted data | FR-011, SC-006 |
| A zero-set or cancelled session MUST NOT produce a record | FR-003, FR-004, SC-003 |
| Records are immutable after write — no `updateSession` method exists | FR-006, SC-004 |
| `planId` is retained in records for filtering; plan content is NOT re-read | FR-006 |
| No network call in any code path | FR-012, SC-007 |

---

## GetIt Registration

```dart
// In forge/lib/config/di/injection.dart (or equivalent):
getIt.registerLazySingleton<WorkoutSessionLocalDataSource>(
  () => WorkoutSessionLocalDataSourceImpl(getIt<AppDatabase>()),
);
getIt.registerLazySingleton<WorkoutSessionRepository>(
  () => WorkoutSessionRepositoryImpl(
    localDataSource: getIt<WorkoutSessionLocalDataSource>(),
    mapper: WorkoutSessionMapper(),
  ),
);
```
