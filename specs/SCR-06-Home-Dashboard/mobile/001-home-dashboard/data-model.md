# Data Model: SCR-06 Home Dashboard

**Date**: 2026-09-16 | **Phase**: 1 — Design

---

## Overview

The Home Dashboard is a read-only derived view. It introduces two **domain entities** (`DashboardSnapshot`, `TodayWorkout`) that are assembled at read-time from three existing tables. No new table is introduced; no data is written.

---

## Domain Entities

### DashboardSnapshot

```dart
// forge/lib/features/home/domain/entities/dashboard_snapshot.dart

class DashboardSnapshot extends Equatable {
  final bool hasData;          // true → populated path; false → empty state
  final TodayWorkout? todayWorkout;  // null → rest day; non-null → scheduled workout

  const DashboardSnapshot({required this.hasData, this.todayWorkout});

  @override
  List<Object?> get props => [hasData, todayWorkout];
}
```

**Derivation rules**:
- `hasData = workoutPlans.isNotEmpty || scheduleEntries.isNotEmpty || sessions.isNotEmpty`
- `todayWorkout != null` only when a `ScheduleEntry` exists for `DateTime.now().weekday` AND its referenced plan exists in the `workout_plans` table

**State branches**:

| `hasData` | `todayWorkout` | UI state shown |
|---|---|---|
| `false` | `null` | Empty state (FR-002) |
| `true` | `null` | Rest day + quick links (FR-005) |
| `true` | non-null | Today's workout card + quick links (FR-003) |
| — | — | Error state (FR-007) on read failure |

---

### TodayWorkout

```dart
// forge/lib/features/home/domain/entities/today_workout.dart

class TodayWorkout extends Equatable {
  final String planId;
  final String planName;
  final int exerciseCount;
  final ExerciseType dominantType;   // mode of all exercise types in the plan
  final int? firstExerciseRestSec;   // null when plan.planExercises.isEmpty (FR-003)

  const TodayWorkout({
    required this.planId,
    required this.planName,
    required this.exerciseCount,
    required this.dominantType,
    this.firstExerciseRestSec,
  });

  @override
  List<Object?> get props => [planId, planName, exerciseCount, dominantType, firstExerciseRestSec];
}
```

**Derivation rules**:

```
exercises = plan.planExercises

exerciseCount = exercises.length

dominantType =
  if exercises.isEmpty → ExerciseType.bodyweight (fallback, card renders without type chip)
  else → mode(exercises.map(e => e.type)), tie-break: weighted > bodyweight > timeBased

firstExerciseRestSec =
  if exercises.isEmpty → null
  else → exercises.first.restPeriodSec
```

---

## Existing Storage Records Consumed (read-only)

These are **not** modified by this feature. Listed for derivation reference.

### WorkoutPlanRecord

```
planId: String
name: String
planExercises: List<PlanExerciseRecord>
createdAt: DateTime
updatedAt: DateTime
```

### PlanExerciseRecord

```
exerciseId: String
exerciseName: String
type: ExerciseType          ← weighted | bodyweight | timeBased
targetSets: int
targetRepetitions: int?
targetWeight: double?
targetDurationSec: int?
restPeriodSec: int          ← used for firstExerciseRestSec
```

### ScheduleEntryRecord

```
weekday: int    ← 1=Monday … 7=Sunday (matches DateTime.weekday)
planId: String
planName: String
```

### WorkoutSessionRecord

Consumed only to populate the `hasData` check (`sessions.isNotEmpty`). No fields from `WorkoutSessionRecord` appear in `DashboardSnapshot`.

---

## Bloc State Machine

```
Initial
  │
  ├─ HomeLoadRequested ──→ HomeLoading
  │                              │
  │               ┌──────────────┼──────────────────────┐
  │               ▼              ▼                       ▼
  │          HomeEmpty   HomePopulated             HomeError
  │        (hasData=F)  (todayWorkout?=null/non-null)  (message)
  │               │              │                       │
  │       HomeLoadRequested  HomeLoadRequested      HomeLoadRequested
  │               │              │                       │   (Retry)
  └───────────────▼──────────────▼───────────────────────▼
                              HomeLoading  (re-entry)
```

**States**:

```dart
// forge/lib/features/home/application/bloc/home_state.dart

abstract class HomeState extends Equatable {}

class HomeInitial extends HomeState { ... }

class HomeLoading extends HomeState { ... }

class HomeEmpty extends HomeState { ... }  // no data in any table

class HomePopulated extends HomeState {
  final DashboardSnapshot snapshot;  // todayWorkout may be null (rest day)
  ...
}

class HomeError extends HomeState {
  final String message;
  ...
}
```

**Events**:

```dart
// forge/lib/features/home/application/bloc/home_event.dart

abstract class HomeEvent extends Equatable {}

class HomeLoadRequested extends HomeEvent { ... }
// Single event. Re-dispatched on tab activation AND on retry tap.
```

**Bloc handlers**:

```
on<HomeLoadRequested>:
  if state is HomeLoading → return  // idempotent; ignore duplicate while loading
  emit HomeLoading
  result = await getDashboardSnapshot()   // use case
  result.fold(
    (failure) → emit HomeError(failure.message),
    (snapshot) → snapshot.hasData
                  ? emit HomePopulated(snapshot)
                  : emit HomeEmpty
  )
```

---

## Validation Rules

| Rule | Where enforced |
|---|---|
| `weekday` is 1–7 only | `ScheduleLocalDataSource` (existing); dashboard reads it as-is |
| `planId` in schedule must exist in plans table | `HomeDashboardLocalDataSource` handles orphaned entry → treats as rest day (no crash) |
| `exerciseCount >= 0` always | Derived as `exercises.length`; empty list = 0; safe |
| `firstExerciseRestSec >= 0` | `PlanExerciseRecord.restPeriodSec` is `int` (never negative in existing models) |
| `hasData = false` iff all three tables empty | Enforced in `HomeDashboardLocalDataSource.getDashboardSnapshot()` |

---

## Entities NOT introduced

| What was considered | Decision |
|---|---|
| `QuickLink` entity | Not needed — quick link destinations are static constants in the widget |
| `BottomNavTab` entity | Not needed — tab index is an `int` managed by `StatefulShellRoute` |
| `HomeModel` (JSON) | Deleted — was a placeholder JSON model with no backend |
