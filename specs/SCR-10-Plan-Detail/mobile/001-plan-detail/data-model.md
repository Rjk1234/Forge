# Data Model: Plan Detail (SCR-10)

**Feature**: SCR-10-Plan-Detail  
**Date**: 2026-09-19

SCR-10 is a **read-only consumer** of domain entities that already exist. No new storage records, mappers, or repository methods are required. This document confirms the entities in use and adds the new application-layer state objects.

---

## Domain Entities (existing — no changes)

### `WorkoutPlanDetail`

Located at `forge/lib/features/workout_plan/domain/entities/workout_plan_detail.dart`.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | UUID identifying the plan (= `planId`) |
| `name` | `String` | Display name — shown in the title block |
| `exercises` | `List<PlanExercise>` | Ordered list of exercises; empty list is valid |
| `createdAt` | `DateTime` | Plan creation timestamp (not displayed on SCR-10) |

**Used by**: `PlanDetailLoaded` state carries one `WorkoutPlanDetail`.  
**Source**: `WorkoutPlanRepository.getPlanById(planId)` → `GetWorkoutPlanByIdUseCase`.

---

### `PlanExercise`

Located at `forge/lib/features/workout_plan/domain/entities/plan_exercise.dart`.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `exerciseId` | `String` | No | ID in the exercise catalogue |
| `exerciseName` | `String` | No | Name snapshot at plan-creation time |
| `type` | `ExerciseType` | No | `weighted` / `timeBased` / `bodyweight` |
| `targetSets` | `int` | No | Number of sets |
| `restPeriodSec` | `int` | No | Rest in seconds (0 is valid) |
| `targetRepetitions` | `int?` | Yes | Weighted + Bodyweight only |
| `targetWeight` | `double?` | Yes | Weighted only; positive |
| `targetDurationSec` | `int?` | Yes | TimeBased only; stored in seconds |

**Display rules by type**:
- `weighted`: Shows Sets, Reps (`targetRepetitions`), Weight (`targetWeight` formatted as "N kg"), Rest
- `timeBased`: Shows Sets, Duration (`targetDurationSec` formatted as "mm:ss"), Rest
- `bodyweight`: Shows Sets, Reps (`targetRepetitions`), Rest (no Weight column)

**Broken-ref handling**: If an exercise cannot be matched back to the exercise catalogue (exerciseName was snapshotted at creation time, so the name is always available), a "Exercise unavailable" placeholder is shown. Since `exerciseName` is snapshotted, this scenario only arises if the plan itself has corrupted data. The UI falls back to the placeholder card.

---

### `ExerciseType` (enum — existing)

Located at `forge/lib/core/enums/exercise_type.dart`.

| Value | Badge label | Type dot colour | Display fields |
|-------|-------------|-----------------|----------------|
| `weighted` | "Weighted" | `AppColors.cyan` | Sets + Reps + Weight + Rest |
| `timeBased` | "Time-Based" | `AppColors.lime` | Sets + Duration + Rest |
| `bodyweight` | "Bodyweight" | `AppColors.textMuted` | Sets + Reps + Rest |

> **Note**: `bodyweight` badge colour changes from `AppColors.amber` (SCR-09 initial impl) → `AppColors.textMuted` to align with the design spec. This is a corrective change applied in both `ExerciseCard` (SCR-09) and `PlanExerciseDetailCard` (SCR-10).

---

## Application Layer — New State Objects

### `PlanDetailState` (sealed class)

Located at `forge/lib/features/workout_plan/application/bloc/plan_detail_state.dart`.

```
PlanDetailState (sealed)
├── PlanDetailInitial         — before first event fires
├── PlanDetailLoading         — database read in flight; shows skeleton
├── PlanDetailLoaded          — carries WorkoutPlanDetail
│     plan: WorkoutPlanDetail
└── PlanDetailNotFound        — plan missing or read exception
      message: String         — user-facing error copy
```

State transitions:
```
Initial ──[PlanDetailLoadRequested]──► Loading
Loading ──[Drift success]─────────────► Loaded(plan)
Loading ──[database error / not found]───► NotFound(message)
Loaded  ──[PlanDetailLoadRequested]──► Loading  (re-read on return from child)
NotFound──[back navigation]──────────► (screen popped — no retry state)
```

### `PlanDetailEvent` (sealed class)

Located at `forge/lib/features/workout_plan/application/bloc/plan_detail_event.dart`.

| Event | Fields | Purpose |
|-------|--------|---------|
| `PlanDetailLoadRequested` | `planId: String` | Initial load + re-read on return from child screen |

> A single event handles both initial load and refresh because the behaviour is identical: emit Loading → call use case → emit Loaded or NotFound.

---

## Value Formatting (display layer)

These are stateless presentation rules applied in `PlanExerciseDetailCard`:

| Field | Source | Display format | Example |
|-------|--------|---------------|---------|
| Sets | `targetSets` | Plain integer | `"4"` |
| Reps | `targetRepetitions` | Plain integer | `"8"` |
| Weight | `targetWeight` | `"${weight.toStringAsFixed(0)} kg"` if whole; `"${weight} kg"` if fractional | `"60 kg"` |
| Rest | `restPeriodSec` | `"${rest}s"` | `"90s"` |
| Duration | `targetDurationSec` | `"${(sec ~/ 60).toString().padLeft(2,'0')}:${(sec % 60).toString().padLeft(2,'0')}"` | `"00:45"` |

---

## Repository & Use Case (existing — no changes)

| Layer | Component | Status |
|-------|-----------|--------|
| Repository interface | `WorkoutPlanRepository.getPlanById(planId)` | ✅ Exists |
| Repository impl | `WorkoutPlanRepositoryImpl.getPlanById(planId)` | ✅ Exists |
| Use case | `GetWorkoutPlanByIdUseCase` | ✅ Exists, registered in GetIt |
| Data source | `WorkoutPlanLocalDataSource.getPlanById(planId)` | ✅ Exists |
| storage record | `WorkoutPlanRecord` + `PlanExerciseRecord` | ✅ Exists |
| Mapper | `WorkoutPlanMapper` | ✅ Exists |

No new data layer components are needed for SCR-10.
