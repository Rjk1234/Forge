# Contract: `ScheduleRepository`

**Layer**: Domain (`features/schedule/domain/repositories/schedule_repository.dart`)
**Implementation**: `features/schedule/data/repositories/schedule_repository_impl.dart`

```dart
abstract class ScheduleRepository {
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule();
}
```

## Behavior

1. Reads all entries via `ScheduleLocalDataSource.getAllEntries()` and, for each of the 7 weekdays, looks up whether an entry exists for it.
2. For each weekday with an entry, resolves the plan via `WorkoutPlanLocalDataSource.getPlanById(entry.planId)`:
   - Plan found → `ScheduleDay.assignedPlan = ScheduledPlanRef(planId, plan.name, recurrenceLabel: 'Weekly')`.
   - Plan not found (orphaned reference, FR-009) → `ScheduleDay.assignedPlan = null` (rendered as "Rest day"), and the repository calls `ScheduleLocalDataSource.deleteEntry(weekday)` to remove the stale entry (research.md Decision 2).
3. For each weekday without an entry → `ScheduleDay.assignedPlan = null`.
4. Determines `isToday` using `DateTime.now().weekday`; if the platform clock is unavailable and throws, `isToday` is `false` for all 7 days rather than propagating the failure (spec Edge Case: "today's date cannot be determined").
5. On any unexpected exception reading either table, returns `Left(CacheException(message: "Couldn't load your schedule"))` — mirrors `WorkoutPlanRepositoryImpl`'s failure-mapping convention. The UI never sees the raw exception (Principle II.5 / VII).
6. Never returns `Left` for an empty schedule — an all-rest-days week is a valid `Right(WeeklySchedule)` whose emptiness the Bloc interprets as `WeekScheduleEmpty` (FR-002).

## Non-goals

- No write/assign/remove methods — those belong to SCR-13/SCR-14's own repository contracts, not this one.
- No pagination or filtering parameters — always returns the full, current 7-day week.

## Test contract (`schedule_repository_impl_test.dart`)

| Case | Given | Expect |
|---|---|---|
| All entries resolve | 3 entries, all `planId`s exist | `Right(WeeklySchedule)` with 3 days populated, 4 rest days |
| Orphaned entry | 1 entry references a deleted `planId` | `Right(WeeklySchedule)` with that day as rest; `deleteEntry(weekday)` called once |
| No entries | `getAllEntries()` returns `[]` | `Right(WeeklySchedule)` with all 7 days rest |
| Drift read throws | `getAllEntries()` throws | `Left(CacheException)` with user-safe message, no raw exception text |
| Today resolution | `DateTime.now().weekday == 3` | Exactly the Wednesday `ScheduleDay.isToday == true`, all others `false` |
