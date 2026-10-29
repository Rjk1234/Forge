# Data Model: SCR-08 Workout Plans List

**Branch**: `001-workout-plans-list` | **Date**: 2026-09-17

---

## Existing Storage Records (Extended by SCR-08, not modified)

### WorkoutPlanRecord (existing)

Stored in `workout_plans` table. Keyed by `planId` (String).
File: `forge/lib/features/workout_plan/data/models/workout_plan_record.dart`

| Field | Type | Notes |
|---|---|---|
| `planId` | `String` | Primary key; stable unique identifier |
| `name` | `String` | User-supplied plan name |
| `planExercises` | `List<PlanExerciseRecord>` | Ordered exercise list; `planExercises.length` = exercise count |
| `createdAt` | `DateTime` | Used for newest-first sort |
| `updatedAt` | `DateTime` | Not used by SCR-08 |

**SCR-08 reads this table via `WorkoutPlanLocalDataSource.getAllPlans()`. No writes.**

---

### PlanExerciseRecord (existing)

Embedded within `WorkoutPlanRecord.planExercises`. Not read individually by SCR-08 — only the length of the list is consumed.
File: `forge/lib/features/workout_plan/data/models/plan_exercise_record.dart`

SCR-08 accesses this type transitively (as part of the parent `WorkoutPlanRecord`) but does not use any of its fields directly. No mapping is needed for the embedded exercises beyond counting them.

---

## New Domain Entity (SCR-08)

### WorkoutPlan

**File**: `forge/lib/features/workout_plan/domain/entities/workout_plan.dart`

Immutable, equatable domain object mapped from `WorkoutPlanRecord` by `WorkoutPlanMapper`. Carries only the fields needed for the plans list screen.

| Field | Type | Nullable | Constraints |
|---|---|---|---|
| `id` | `String` | No | Non-empty; matches `WorkoutPlanRecord.planId` |
| `name` | `String` | No | Non-empty |
| `exerciseCount` | `int` | No | ≥ 0; derived from `planExercises.length` |
| `createdAt` | `DateTime` | No | Used for newest-first sort; immutable after creation |

**Validation rules**: None at runtime — user-created data is trusted within the closed local system. The mapper asserts non-empty `id` and `name` in debug mode.

**State transitions**: None — `WorkoutPlan` is immutable and read-only on this screen.

**Display rules**:
- Exercise count label: `"1 exercise"` when `exerciseCount == 1`; `"N exercises"` otherwise (including `"0 exercises"`)
- Name truncation: 1 line, `TextOverflow.ellipsis`

---

## New Domain Interface (SCR-08)

### WorkoutPlanRepository (abstract)

**File**: `forge/lib/features/workout_plan/domain/repositories/workout_plan_repository.dart`

```
abstract class WorkoutPlanRepository {
  Future<Either<AppException, List<WorkoutPlan>>> getAllPlans();
}
```

Returns plans sorted newest-first. The `Either` type uses `fpdart` (existing governed dependency).

---

## New Data-Layer Artifacts (SCR-08)

### WorkoutPlanMapper

**File**: `forge/lib/features/workout_plan/data/mappers/workout_plan_mapper.dart`

Static method: `WorkoutPlan fromRecord(WorkoutPlanRecord model)`.

Mapping:
- `model.planId` → `id`
- `model.name` → `name`
- `model.planExercises.length` → `exerciseCount`
- `model.createdAt` → `createdAt`

The list-level sort (newest-first) is applied in `WorkoutPlanRepositoryImpl`, not in the mapper.

---

### WorkoutPlanRepositoryImpl

**File**: `forge/lib/features/workout_plan/data/repositories/workout_plan_repository_impl.dart`

Implements `WorkoutPlanRepository`. Constructor-injected `WorkoutPlanLocalDataSource`.

`getAllPlans()` implementation:
1. Call `dataSource.getAllPlans()` — returns `List<WorkoutPlanRecord>` (all plans, unordered)
2. Sort list by `model.createdAt` descending (newest first)
3. Map each `WorkoutPlanRecord` → `WorkoutPlan` via `WorkoutPlanMapper.fromRecord`
4. Return `Right(sortedMappedList)` on success
5. Catch all exceptions, return `Left(CacheException(message: ...))` on failure

---

## Core Navigation Infrastructure (new — SCR-08)

### WorkoutPlansReloadNotifier

**File**: `forge/lib/core/navigation/workout_plans_reload_notifier.dart`

A lightweight `ChangeNotifier` (or thin broadcast `Stream<void>`) registered as a singleton in GetIt. `AppShell` calls `notifier.notify()` when the Plans branch (index 1) becomes active. `WorkoutPlansScreen` subscribes in `initState` and dispatches `WorkoutPlansLoadRequested` to its Bloc, triggering the optimistic re-read.

This is a navigation-infrastructure object (`core/navigation/`), not a domain or application object.

---

## Application-Layer State Machine (SCR-08)

### WorkoutPlansBloc State Diagram

```
WorkoutPlansInitial
       │
       ▼ (WorkoutPlansLoadRequested — first load)
WorkoutPlansLoading
       │
       ├─ success + plans.isNotEmpty → WorkoutPlansPopulated(plans: List<WorkoutPlan>)
       ├─ success + plans.isEmpty   → WorkoutPlansEmpty
       └─ failure                   → WorkoutPlansError(message: String)

WorkoutPlansPopulated or WorkoutPlansEmpty
       │
       ▼ (WorkoutPlansLoadRequested — re-read / optimistic)
       ┌─ [NO Loading emitted — existing state kept during read]
       │
       ├─ success + plans.isNotEmpty → WorkoutPlansPopulated(plans: List<WorkoutPlan>)
       ├─ success + plans.isEmpty   → WorkoutPlansEmpty
       └─ failure                   → WorkoutPlansError(message: String)

WorkoutPlansError
       │
       ▼ (WorkoutPlansLoadRequested — retry)
WorkoutPlansLoading   [Loading IS emitted — we have no previous data to keep]
       └─ ... (same as first load)
```
