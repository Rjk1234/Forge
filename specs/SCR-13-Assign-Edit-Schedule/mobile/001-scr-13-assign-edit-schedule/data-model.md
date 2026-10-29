# Phase 1 Data Model: SCR-13 Assign / Edit Schedule

No new table or column. This feature reads and writes the same two existing tables SCR-12 reads (`schedule_entries`, `workout_plans`), via the same existing datasource methods (`ScheduleLocalDataSource.getAllEntries/saveEntry/deleteEntry`, `WorkoutPlanLocalDataSource.getPlanById`).

## New Domain entity

### `ScheduleFormContext`

Everything the form needs at init, in one shape (`domain/entities/schedule_form_context.dart`).

| Field | Type | Description |
|---|---|---|
| `planId` | `String` | The plan this screen is scheduling |
| `planName` | `String?` | Null means the plan no longer exists (User Story 5 / `AssignScheduleInvalidPlan`); non-null is the display name |
| `currentDays` | `Set<int>` | Weekdays (1–7) currently assigned to this plan — empty means "New" mode (Decision 1) |
| `occupiedDays` | `Map<int, String>` | Weekday → the *other* plan's name currently occupying it (excludes this plan's own days per FR-005) |

Validation rules:
- `planName == null` ⟺ the plan no longer exists in `workout_plans` ⟺ the screen renders State D (Invalid Plan) and `currentDays`/`occupiedDays` are not used.
- `occupiedDays` never contains a day that's also in `currentDays` (self-conflict exclusion, FR-005) — enforced by the repository when building this context, not by the UI.

## Application-layer (Bloc) state shape — not persisted

`AssignScheduleReady` (`application/bloc/assign_schedule_state.dart`) carries the live form:

| Field | Type | Description |
|---|---|---|
| `planId` | `String` | Unchanged from context |
| `planName` | `String` | Unchanged from context (non-null — Ready is never reached for an invalid plan) |
| `originalDays` | `Set<int>` | Snapshot of `currentDays` at load time — used as the "previous" side of the save diff (Decision 2/8) |
| `selectedDays` | `Set<int>` | The user's live selection, starts equal to `originalDays` |
| `occupiedDays` | `Map<int, String>` | Unchanged from context — the fixed occupancy map conflicts are checked against |
| `conflicts` | `Map<int, String>` | Derived: `{d: occupiedDays[d] for d in selectedDays if d in occupiedDays}` — recomputed on every `DayToggled` |

Derived: `canSave => selectedDays.isNotEmpty && conflicts.isEmpty` (mirrors `CreateEditPlanReady.canSave`'s shape).

This form-shaped state deliberately lives in the Application layer (Bloc state), not as a Domain entity — consistent with the existing `PlanExerciseFormEntry` precedent in `workout_plan`, where per-keystroke form state is Application-layer and only the validated result crosses back into a Domain call.

## State transitions (Bloc, not persisted)

```
AssignScheduleInitial
   │  AssignScheduleInitialized(planId)
   ▼
AssignScheduleLoading
   │  loadAssignmentContext(planId) resolves
   ├─ Left(failure)                       → (treated as load failure — see contracts/assign-schedule-bloc.md)
   ├─ Right(ctx), ctx.planName == null    → AssignScheduleInvalidPlan(planId)
   └─ Right(ctx), ctx.planName != null    → AssignScheduleReady(originalDays=ctx.currentDays, selectedDays=ctx.currentDays, ...)

AssignScheduleReady
   │  DayToggled(weekday)
   ▼
AssignScheduleReady (selectedDays/conflicts recomputed)

AssignScheduleReady (canSave)
   │  SaveRequested
   ▼
AssignScheduleSaving(readyState)
   │  saveAssignment(...) resolves
   ├─ Left(failure)  → AssignScheduleSaveFailure(readyState, message)
   └─ Right(_)       → AssignScheduleSaved

AssignScheduleSaveFailure
   │  RetrySaveRequested
   ▼
AssignScheduleSaving(readyState)  (same readyState, re-attempts)
```

Only one database-mutating operation exists in this feature: `saveAssignment`, invoked exclusively from `SaveRequested`/`RetrySaveRequested`. Nothing is written during `Loading`, `DayToggled`, or on back navigation (FR-013's own screen never writes on cancel — Edge Case).
