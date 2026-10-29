# Data Model: Delete Plan Confirmation (SCR-11)

**Date**: 2026-09-19 | **Feature**: SCR-11

---

## Drift Tables Involved

| Table | SQL name | Key Type | Record Type | SCR-11 operation |
|-------|----------|----------|-------------|-----------------|
| `WorkoutPlans` | `workout_plans` | `String` (planId) | `WorkoutPlanRecord` | **DELETE** row by planId |
| `ScheduleEntries` | `schedule_entries` | `int` (weekday 1–7) | `ScheduleEntryRecord` | **DELETE** all rows where `entry.planId == planId` (max 7) |
| `WorkoutSessions` | `workout_sessions` | `String` (sessionId) | `WorkoutSessionRecord` | **NOT TOUCHED** — preserved per FR-6 / SEC-2 |

---

## Domain Entities (read-only for dialog)

### `WorkoutPlanDetail`

Used to populate the dialog subtitle (plan name). Already exists in `domain/entities/workout_plan_detail.dart`. Not modified by SCR-11.

| Field | Type | Used in SCR-11 |
|-------|------|----------------|
| `id` | `String` | planId passed to `DeleteWorkoutPlanUseCase` |
| `name` | `String` | Displayed in dialog subtitle: `""{name}" and its schedule assignments…"` |
| `exercises` | `List<PlanExercise>` | Not used in SCR-11 |
| `createdAt` | `DateTime` | Not used in SCR-11 |

### `ScheduleEntryRecord`

Existing storage record. Relevant field for SCR-11:

| Field | Type | Column | Role in SCR-11 |
|-------|------|--------|---------------|
| `weekday` | `int` | `weekday` (PK) | Row key — used to delete the row for that weekday |
| `planId` | `String` | `plan_id` | Compared against the planId being deleted |
| `planName` | `String` | `plan_name` | Not used in SCR-11 |

---

## New Use Case Interface

### `DeleteWorkoutPlanUseCase`

| Parameter | Type | Description |
|-----------|------|-------------|
| `planId` | `String` | ID of the plan to delete |

**Returns**: `Future<Either<AppException, void>>`

**Sequence**:
1. Calls `repository.deletePlan(planId)`
2. Repository deletes schedule entries referencing planId (`schedule_entries` table, max 7 ops)
3. Repository deletes plan row (`workout_plans` table, 1 op)
4. Returns `Right(null)` on success, `Left(CacheException(...))` on any error

---

## Repository Method Addition

### `WorkoutPlanRepository.deletePlan`

```
deletePlan(planId: String) → Future<Either<AppException, void>>
```

**Pre-condition**: `planId` is non-empty. If the plan does not exist in the table when delete is called, deleting by `planId` affects zero rows — treated as success (EC-3 in spec: plan already gone = success).

**Post-condition**:
- `workout_plans` table no longer contains `planId`
- `schedule_entries` table contains no rows where `entry.planId == planId`
- `workout_sessions` table is unchanged

---

## `DeletePlanBloc` State Machine

```
Initial state: DeletePlanConfirmation

DeletePlanConfirmation
    │
    ├─ [Cancel / scrim tap / back gesture] → Navigator.pop(context, false)   [no state change]
    │
    └─ [DeletePlanConfirmed(planId)] ──────────────────────────────────────────────────────────┐
                                                                                                │
DeletePlanDeleting                                                                              │
    │                                                                                           │
    ├─ [Drift write failure] → DeletePlanFailure(message)                                       │
    │                               │                                                           │
    │                               ├─ [Cancel] → Navigator.pop(context, false)                │
    │                               │                                                           │
    │                               └─ [DeletePlanConfirmed(planId)] ──────────────────────────┘
    │
    └─ [Drift write success] → DeletePlanSuccess
                                    │
                                    └─ BlocListener → Navigator.pop(context, true)
                                                         ↓
                                                    SCR-10 _onDelete:
                                                    context.go('/plans')
```

---

## Bloc State Definitions

| State | Fields | Description |
|-------|--------|-------------|
| `DeletePlanConfirmation` | — | Initial state; dialog shows Cancel + Delete buttons, both enabled |
| `DeletePlanDeleting` | — | Drift write in progress; Cancel disabled (opacity 0.5); Delete shows spinner + "Deleting…" |
| `DeletePlanSuccess` | — | Write completed; dialog pops with `true`; caller navigates to SCR-08 |
| `DeletePlanFailure` | `message: String` | Write failed; inline error shown; Cancel restored; Retry (lime) button shown |

## Bloc Event Definitions

| Event | Fields | Trigger |
|-------|--------|---------|
| `DeletePlanConfirmed` | `planId: String` | Delete button tap (Confirmation state) OR Retry button tap (Failure state) |

Cancel is handled via `Navigator.pop(context, false)` directly — no Bloc event.
