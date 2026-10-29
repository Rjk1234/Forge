# Phase 1 Data Model: SCR-12 View Weekly Workout Schedule

No new table or column is introduced. This feature reads two existing tables (`schedule_entries`, `workout_plans`) and defines new **Domain-layer, in-memory-only** entities to shape that data for the Bloc and UI.

## Existing Data-layer models (unchanged, read-only)

### `ScheduleEntryRecord` (`features/schedule/data/models/schedule_entry_record.dart`)

| Field | Type | Notes |
|---|---|---|
| `weekday` | `int` | 1=Monday … 7=Sunday. Primary key. |
| `planId` | `String` | References `WorkoutPlanRecord.planId`; may be orphaned. |
| `planName` | `String` | Denormalized snapshot — **not** used by SCR-12 (see Decision 2 in research.md: the current plan name is re-resolved live from `WorkoutPlanLocalDataSource` so a rename elsewhere is reflected immediately; this snapshot exists for other consumers). |

### `WorkoutPlanRecord` (`features/workout_plan/data/models/workout_plan_record.dart`, existing)

Referenced only via `WorkoutPlanLocalDataSource.getPlanById(planId)`; SCR-12 reads `planId` and `name` from the resulting model (via the existing `WorkoutPlan`/mapper), and does not need `planExercises` or `createdAt`.

## New Domain entities

### `ScheduleDay`

Represents one row of the week (`domain/entities/schedule_day.dart`).

| Field | Type | Description |
|---|---|---|
| `weekday` | `int` | 1=Monday … 7=Sunday |
| `date` | `DateTime` | The actual calendar date for this weekday in the current week (Assumption A-4 in spec.md) |
| `isToday` | `bool` | True for exactly one day per `WeeklySchedule`, or false for all seven if today cannot be determined (Edge Case) |
| `assignedPlan` | `ScheduledPlanRef?` | Null → "Rest day". Non-null → plan name + id to display/navigate with. |

Validation rules:
- Exactly one `ScheduleDay.isToday == true` per `WeeklySchedule`, unless the current weekday cannot be determined, in which case all seven are `false` (spec Edge Case: "today's date cannot be determined").
- `weekday` values across the 7 entries are always `{1,2,3,4,5,6,7}`, each exactly once, in that order (spec Assumption A-1).

### `ScheduledPlanRef`

Small value object embedded in `ScheduleDay` (`domain/entities/schedule_day.dart`, same file).

| Field | Type | Description |
|---|---|---|
| `planId` | `String` | Used for Start/Edit navigation target |
| `planName` | `String` | Displayed plan name; truncates in the UI layer, not here (Edge Case) |
| `recurrenceLabel` | `String` | Always `"Weekly"` per current scope (spec Assumption A-2); kept as a field, not a hardcoded UI string, so a future recurrence type is a data change, not a UI rewrite |

### `WeeklySchedule`

Top-level Domain entity returned by the repository (`domain/entities/weekly_schedule.dart`).

| Field | Type | Description |
|---|---|---|
| `days` | `List<ScheduleDay>` | Always exactly 7 entries, Monday→Sunday order |

Derived/computed (not stored): "is the whole week empty" = `days.every((d) => d.assignedPlan == null)` → drives the Bloc's `WeekScheduleEmpty` vs. `WeekSchedulePopulated` decision (FR-002/FR-003).

## State transitions (Bloc, not persisted)

```
WeekScheduleInitial
   │  WeekScheduleRequested (screen initState)
   ▼
WeekScheduleLoading
   │  repository call resolves
   ├─ Left(failure)              → WeekScheduleError(message)
   ├─ Right(schedule) all empty  → WeekScheduleEmpty
   └─ Right(schedule) not empty  → WeekSchedulePopulated(schedule)

WeekScheduleError
   │  WeekScheduleRetried (Retry tap; ignored if already Loading — Edge Case EC-7)
   ▼
WeekScheduleLoading  (same transitions as above)
```

No entity in this feature has a create/update/delete lifecycle from the UI — SCR-12 is read-only (Assumption). The only mutation is the internal orphaned-entry cleanup described in research.md Decision 2, which is a repository-level side effect, not a user-facing state transition.
