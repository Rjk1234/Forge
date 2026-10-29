# Contract: `ScheduleRepository` (extended)

**Layer**: Domain (`features/schedule/domain/repositories/schedule_repository.dart`)
**Implementation**: `features/schedule/data/repositories/schedule_repository_impl.dart`

This feature extends the interface SCR-12's plan defines with two new methods. `getWeeklySchedule()` (SCR-12) is unchanged by this feature.

```dart
abstract class ScheduleRepository {
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule(); // SCR-12 — unchanged

  // SCR-13 additions:
  Future<Either<AppException, ScheduleFormContext>> loadAssignmentContext(String planId);

  Future<Either<AppException, void>> saveAssignment({
    required String planId,
    required String planName,
    required Set<int> previousWeekdays,
    required Set<int> newWeekdays,
  });
}
```

## `loadAssignmentContext(planId)` behavior

1. Looks up the plan via `WorkoutPlanLocalDataSource.getPlanById(planId)`.
   - Not found → returns `Right(ScheduleFormContext(planId: planId, planName: null, currentDays: {}, occupiedDays: {}))` (User Story 5 — plan no longer exists is a valid, non-error result, not a `Left`).
   - Found → continue.
2. Reads all entries via `ScheduleLocalDataSource.getAllEntries()`.
3. `currentDays` = the set of weekdays whose entry's `planId` equals the given `planId` (Decision 2 — computed grouping).
4. `occupiedDays` = a map of weekday → `planName` for every entry whose `planId` does **not** equal the given `planId` (FR-005 — self-exclusion).
5. Returns `Right(ScheduleFormContext(planId, planName: plan.name, currentDays, occupiedDays))`.
6. On any unexpected exception reading either table, returns `Left(CacheException(message: "Couldn't load this schedule"))`.

## `saveAssignment(...)` behavior

1. Computes `toRemove = previousWeekdays - newWeekdays` and `toWrite = newWeekdays` (Decision 2/8).
2. For each weekday in `toRemove`: calls `ScheduleLocalDataSource.deleteEntry(weekday)`.
3. For each weekday in `toWrite`: calls `ScheduleLocalDataSource.saveEntry(ScheduleEntryRecord(weekday: weekday, planId: planId, planName: planName))` — this also correctly re-affirms unchanged days (present in both sets) by re-writing them, which is harmless (idempotent put).
4. On success, returns `Right(null)`.
5. On any exception during steps 2–3 (including partial completion — Decision 8), returns `Left(CacheException(message: "Couldn't save your schedule"))`. No rollback of already-completed deletes/puts is attempted.
6. Never validates conflicts itself — the caller (Bloc) only calls this when `conflicts.isEmpty`, per the client-side check in `loadAssignmentContext`'s `occupiedDays`. This method trusts its caller, consistent with `WorkoutPlanRepositoryImpl.savePlan` trusting `CreateEditWorkoutPlanBloc`'s prior validation.

## Test contract (`schedule_repository_impl_test.dart` — new cases added to SCR-12's file)

| Case | Given | Expect |
|---|---|---|
| Load — new plan, no existing days | Plan exists; no entries reference its id | `Right(ScheduleFormContext(currentDays: {}, occupiedDays: {other days}))` |
| Load — existing assignment | Plan exists; entries for weekdays {1,3,5} reference it | `Right(ScheduleFormContext(currentDays: {1,3,5}, ...))` |
| Load — self-exclusion | Plan's own days present among all entries | `occupiedDays` never contains the plan's own days |
| Load — invalid plan | `getPlanById` returns null | `Right(ScheduleFormContext(planName: null, currentDays: {}, occupiedDays: {}))` — not a `Left` |
| Load — Drift throws | `getAllEntries()` throws | `Left(CacheException)` |
| Save — pure addition | `previousWeekdays: {}`, `newWeekdays: {2,4}` | `saveEntry` called for 2 and 4; `deleteEntry` never called |
| Save — pure removal | `previousWeekdays: {2,4}`, `newWeekdays: {}` | `deleteEntry` called for 2 and 4; `saveEntry` never called |
| Save — mixed diff | `previousWeekdays: {1,3}`, `newWeekdays: {3,5}` | `deleteEntry(1)`, `saveEntry(3)`, `saveEntry(5)` |
| Save — Drift throws | Any `saveEntry`/`deleteEntry` call throws | `Left(CacheException)`, no exception propagates |
