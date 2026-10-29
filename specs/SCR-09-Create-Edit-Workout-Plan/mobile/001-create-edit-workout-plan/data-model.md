# Data Model: SCR-09 Create / Edit Workout Plan

**Feature**: `001-create-edit-workout-plan`
**Date**: 2026-09-17

---

## Storage Records (Data Layer — unchanged)

These models already exist and require **no structural changes** for SCR-09.

### `WorkoutPlanRecord`

File: `forge/lib/features/workout_plan/data/models/workout_plan_record.dart`

| Field | Dart Type | Notes |
|---|---|---|
| `planId` | `String` | UUID v4; key in the `workout_plans` table |
| `name` | `String` | 1–100 non-whitespace characters |
| `planExercises` | `List<PlanExerciseRecord>` | Ordered; length ≥ 1 for valid save |
| `createdAt` | `DateTime` | Set once on create; unchanged on edit |
| `updatedAt` | `DateTime` | Updated on every successful save |

### `PlanExerciseRecord`

File: `forge/lib/features/workout_plan/data/models/plan_exercise_record.dart`

| Field | Dart Type | Notes |
|---|---|---|
| `exerciseId` | `String` | ID from the exercise catalogue; no FK constraint in the database |
| `exerciseName` | `String` | Snapshot at creation time |
| `type` | `ExerciseType` | Weighted / TimeBased / Bodyweight |
| `targetSets` | `int` | > 0 to save; default 0 on card creation |
| `targetRepetitions` | `int?` | Weighted + Bodyweight only; > 0 to save |
| `targetWeight` | `double?` | Weighted only; > 0.0 to save; ≤ 1dp |
| `targetDurationSec` | `int?` | TimeBased only; > 0 to save; stored as seconds |
| `restPeriodSec` | `int` | ≥ 0 always valid; default 0 on card creation |

### `ExerciseType` — enum, exists in `forge/lib/core/enums/exercise_type.dart`

`weighted` | `timeBased` | `bodyweight`

---

## Domain Entities (New)

### `WorkoutPlanDetail`

File: `forge/lib/features/workout_plan/domain/entities/workout_plan_detail.dart` *(new)*

Full plan representation used by the create/edit screen — distinct from `WorkoutPlan` (the list-view projection which only carries `id`, `name`, `exerciseCount`, `createdAt`).

| Field | Dart Type | Notes |
|---|---|---|
| `id` | `String` | Plan UUID; empty string in create mode before first save |
| `name` | `String` | Plan name |
| `exercises` | `List<PlanExercise>` | Ordered exercise entries |
| `createdAt` | `DateTime` | Preserved from the database on edit; set to `DateTime.now()` on create |
| `updatedAt` | `DateTime` | Set to `DateTime.now()` on every save |

Implements `Equatable`.

### `PlanExercise`

File: `forge/lib/features/workout_plan/domain/entities/plan_exercise.dart` *(new)*

Domain representation of a single exercise entry in a plan. Maps to/from `PlanExerciseRecord`.

| Field | Dart Type | Notes |
|---|---|---|
| `exerciseId` | `String` | Catalogue ID |
| `exerciseName` | `String` | Snapshot name |
| `type` | `ExerciseType` | Determines which target fields apply |
| `targetSets` | `int` | ≥ 0 in domain; > 0 for valid save |
| `targetRepetitions` | `int?` | Weighted + Bodyweight; null for TimeBased |
| `targetWeight` | `double?` | Weighted only; null for others |
| `targetDurationSec` | `int?` | TimeBased only; null for others |
| `restPeriodSec` | `int` | ≥ 0 |

Implements `Equatable`.

---

## In-Memory Form State (Application Layer)

### `PlanExerciseFormEntry`

File: `forge/lib/features/workout_plan/application/bloc/plan_exercise_form_entry.dart` *(new)*

A mutable value object used **only inside `CreateEditWorkoutPlanBloc` state**. Not a domain entity, not stored in the database. Holds the current field values being edited for one exercise card.

| Field | Dart Type | Default | Notes |
|---|---|---|---|
| `exerciseId` | `String` | (from picker) | Immutable after card creation |
| `exerciseName` | `String` | (from picker) | Immutable after card creation |
| `type` | `ExerciseType` | (from picker) | Immutable after card creation |
| `targetSets` | `int` | `0` | Editable |
| `targetRepetitions` | `int?` | `0` (weighted/bodyweight), `null` (timeBased) | Editable |
| `targetWeight` | `double?` | `0.0` (weighted), `null` (others) | Editable; enforces 1dp |
| `targetDurationSec` | `int?` | `0` (timeBased), `null` (others) | Editable; input as mm:ss |
| `restPeriodSec` | `int` | `0` | Editable |

`PlanExerciseFormEntry` is `Equatable`. The Bloc holds a `List<PlanExerciseFormEntry>` in its state. On `ExerciseAdded`, a new entry is appended with all defaults at 0. On `ExerciseRemoved(index)`, the entry at that index is removed. On `ExerciseFieldChanged(index, field, value)`, the specific field is updated and its validation error (if any) is cleared immediately.

---

## Repository Interface Changes

### `WorkoutPlanRepository` — extended (not replaced)

File: `forge/lib/features/workout_plan/domain/repositories/workout_plan_repository.dart`

Two methods added to the existing interface:

```
getAllPlans()         → Either<AppException, List<WorkoutPlan>>  (EXISTS)
getPlanById(String planId) → Either<AppException, WorkoutPlanDetail>  (NEW)
savePlan(WorkoutPlanDetail plan) → Either<AppException, Unit>  (NEW)
```

`WorkoutPlanRepositoryImpl` implements both new methods:
- `getPlanById` reads `WorkoutPlanLocalDataSource.getPlanById(planId)` and maps via `WorkoutPlanMapper.toDetailFromRecord(model)`.
- `savePlan` converts `WorkoutPlanDetail` to `WorkoutPlanRecord` via `WorkoutPlanMapper.toRecord(detail)` and writes via `WorkoutPlanLocalDataSource.savePlan(model)`.

Both methods catch all exceptions and return `Left(CacheException(...))`.

---

## Mapper Extensions

### `WorkoutPlanMapper` — extended

File: `forge/lib/features/workout_plan/data/mappers/workout_plan_mapper.dart`

Two new static methods added alongside the existing `fromRecord`:

| Method | Direction | Notes |
|---|---|---|
| `fromRecord(model)` | Drift → `WorkoutPlan` | EXISTS — list-view projection |
| `toDetailFromRecord(model)` | Drift → `WorkoutPlanDetail` | NEW — full plan with exercises |
| `toRecord(detail)` | `WorkoutPlanDetail` → Drift | NEW — for save |

`PlanExerciseMapper` (inline static methods on `WorkoutPlanMapper` or a new class):

| Method | Notes |
|---|---|
| `planExerciseFromRecord(model)` | `PlanExerciseRecord` → `PlanExercise` |
| `planExerciseToRecord(entity)` | `PlanExercise` → `PlanExerciseRecord` |
| `formEntryToPlanExercise(entry)` | `PlanExerciseFormEntry` → `PlanExercise` (for save) |

---

## Validation Rules (Runtime)

These rules are enforced in `CreateEditWorkoutPlanBloc` on `SaveRequested`:

| Field | Rule | Error message |
|---|---|---|
| Plan name | Not empty/whitespace | "Plan name can't be blank." |
| Plan name | Length ≤ 100 chars | Enforced at input level — cannot trigger at save time |
| Exercise list | Length ≥ 1 | Save button disabled (no error message shown) |
| targetSets | > 0 | "Sets must be greater than 0." |
| targetRepetitions | > 0 (weighted/bodyweight) | "Reps must be greater than 0." |
| targetWeight | > 0.0 (weighted) | "Weight must be greater than 0." |
| targetDurationSec | > 0 (timeBased) | "Duration must be greater than 00:00." |
| exerciseId | Exists in catalogue | "This exercise is no longer available." |

Multiple errors per exercise card are collected into a `List<String>` and displayed as a combined message below the card.

---

## State Transitions — CreateEditWorkoutPlanBloc

```
CreateEditPlanInitial
  → [CreateEditPlanInitialized(planId: null)] → CreateEditPlanReady (create mode, clean, canSave: false)
  → [CreateEditPlanInitialized(planId: 'abc')] → CreateEditPlanLoading → CreateEditPlanReady (edit mode, pre-filled, canSave: true if valid)
  → [CreateEditPlanInitialized(planId: 'abc')] → CreateEditPlanLoading → CreateEditPlanLoadError (plan not found)

CreateEditPlanReady
  → [PlanNameChanged] → CreateEditPlanReady (updated name, re-evaluated canSave, isDirty: true)
  → [ExerciseAdded] → CreateEditPlanReady (new card appended, isDirty: true)
  → [ExerciseRemoved] → CreateEditPlanReady (card removed, isDirty: true)
  → [ExerciseFieldChanged] → CreateEditPlanReady (field updated, error cleared, canSave re-evaluated)
  → [SaveRequested] (validation fails) → CreateEditPlanReady (errors set, canSave: false)
  → [SaveRequested] (validation passes) → CreateEditPlanSaving

CreateEditPlanSaving
  → (database write succeeds) → CreateEditPlanSaved(planId)
  → (database write throws) → CreateEditPlanSaveFailure (form data preserved)

CreateEditPlanSaveFailure
  → [PlanNameChanged / ExerciseAdded / ExerciseRemoved / ExerciseFieldChanged] → CreateEditPlanSaveFailure (form editable, same state type)
  → [RetrySaveRequested] → CreateEditPlanSaving

CreateEditPlanSaved
  → (Presentation layer navigates away; Bloc closed)
```
