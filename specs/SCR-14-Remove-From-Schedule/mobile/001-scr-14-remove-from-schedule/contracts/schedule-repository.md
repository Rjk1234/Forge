# Contract: `ScheduleRepository` (extended, third feature to add to it)

**Layer**: Domain (`features/schedule/domain/repositories/schedule_repository.dart`)
**Implementation**: `features/schedule/data/repositories/schedule_repository_impl.dart`

This feature adds one method to the interface SCR-12 (`getWeeklySchedule()`) and SCR-13 (`loadAssignmentContext()`, `saveAssignment()`) already define/extend.

```dart
abstract class ScheduleRepository {
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule(); // SCR-12 — unchanged
  Future<Either<AppException, ScheduleFormContext>> loadAssignmentContext(String planId); // SCR-13 — unchanged
  Future<Either<AppException, void>> saveAssignment({...}); // SCR-13 — unchanged

  // SCR-14 addition:
  Future<Either<AppException, void>> removeEntry(int weekday);
}
```

## `removeEntry(weekday)` behavior

1. Calls `ScheduleLocalDataSource.deleteEntry(weekday)`.
2. On success, returns `Right(null)`.
3. On any exception, returns `Left(CacheException(message: "Couldn't remove this entry"))` — matches `DeleteWorkoutPlanUseCase`/`WorkoutPlanRepositoryImpl`'s failure-mapping convention exactly.
4. Performs no existence check and no plan-identity verification beforehand (research.md Decision 4) — deleting an already-absent row by weekday is a safe no-op in Drift (zero rows affected), so even a (theoretically impossible, single-user/offline) double-delete cannot throw or corrupt state.

## Test contract (`schedule_repository_impl_test.dart` — new cases added to the existing file)

| Case | Given | Expect |
|---|---|---|
| Remove — success | `deleteEntry(weekday)` completes normally | `Right(null)`; `deleteEntry` called exactly once with the given weekday |
| Remove — Drift throws | `deleteEntry(weekday)` throws | `Left(CacheException)`, no exception propagates |
| Remove — already absent | `deleteEntry` called for a weekday with no existing entry | `Right(null)` — Drift's delete-of-absent-key is a no-op, not an error |
