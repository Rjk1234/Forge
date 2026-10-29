# Data Model: SCR-15 Workout Pre-Start / Overview

**Phase 1 — entity shape and state model**

---

## Existing entities (no changes)

SCR-15 uses two existing domain entities without modification:

### `WorkoutPlanDetail`

```
forge/lib/features/workout_plan/domain/entities/workout_plan_detail.dart
```

| Field | Type | Notes |
|-------|------|-------|
| `id` | `String` | Plan identifier |
| `name` | `String` | Displayed in hero header |
| `exercises` | `List<PlanExercise>` | Ordered list rendered in the card list |
| `createdAt` | `DateTime` | Not used by SCR-15 |

**SCR-15 behavior**: If `exercises.isEmpty` → emit `PreStartUnavailable` (treated as unavailable, same as a deleted plan).

---

### `PlanExercise`

```
forge/lib/features/workout_plan/domain/entities/plan_exercise.dart
```

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| `exerciseId` | `String` | No | Not displayed |
| `exerciseName` | `String` | No | Card title |
| `type` | `ExerciseType` | No | Determines dot color and field grid |
| `targetSets` | `int` | No | Always shown |
| `restPeriodSec` | `int` | No | **Not shown** in SCR-15 (per design spec) |
| `targetRepetitions` | `int?` | Yes | Shown for weighted + bodyweight |
| `targetWeight` | `double?` | Yes | Shown for weighted; `null` → display `"—"` |
| `targetDurationSec` | `int?` | Yes | Shown for time-based; formatted as `MM:SS` |

---

### `ExerciseType`

```
forge/lib/core/enums/exercise_type.dart
```

| Value | Type dot color | Field grid |
|-------|---------------|------------|
| `weighted` | `AppColors.lime` (#C3F400) | 3-col: Sets / Reps / Weight |
| `timeBased` | `AppColors.cyan` (#7DF4FF) | 2-col: Sets / Duration |
| `bodyweight` | `AppColors.textMuted` (#C4C9AC) | 2-col: Sets / Reps |

---

## New Bloc state model

### `PreStartState` sealed class hierarchy

```
PreStartState (sealed)
├── PreStartInitial          — before first event
├── PreStartLoading          — Drift read in flight → shimmer skeleton (State A)
├── PreStartLoaded           — plan valid + exercises present → plan preview (State B)
├── PreStartUnavailable      — plan null OR exercises.isEmpty → blocked state (State C)
└── PreStartError(message)   — Left(AppException) from use case → retry state (State D)
```

### `PreStartLoaded` fields

| Field | Type | Nullable | Source |
|-------|------|----------|--------|
| `plan` | `WorkoutPlanDetail` | No | Use case result |
| `scheduledWeekday` | `int?` | Yes | From `PreStartRequested` event; null when entered from Plan Detail |
| `isScheduledForToday` | `bool` | No | `scheduledWeekday == DateTime.now().weekday`; false when weekday is null |

**FR-008 rendering rules** (computed in Bloc, consumed read-only by widget):

| `scheduledWeekday` | `isScheduledForToday` | Meta line shown |
|---|---|---|
| `null` | `false` | `"{exercise count} exercises"` only |
| `non-null` | `false` | `"{weekday name} · {exercise count} exercises"` |
| `non-null` | `true` | `"{weekday name} · Today · {exercise count} exercises"` |

---

## New event model

### `PreStartEvent` sealed class hierarchy

```
PreStartEvent (sealed)
├── PreStartRequested(planId, scheduledWeekday?)   — dispatched on initState
└── PreStartRetried(planId, scheduledWeekday?)     — dispatched on Retry tap
```

Both events carry identical payload fields.

---

## New strings (`AppStrings`)

Section to be added to `forge/lib/core/strings/app_strings.dart`:

```dart
// SCR-15: Workout Pre-Start / Overview
static const String preStartScreenTitle = 'Overview';
static const String preStartExercisesSectionLabel = 'EXERCISES';
static const String preStartBeginButton = 'Begin Workout';
static const String preStartWeightNotSet = '—';

// Meta line fragments
static const String preStartMetaToday = 'Today';
// weekday names come from AppStrings.weekdayFullNames (SCR-13, already defined)

// State C — unavailable
static const String preStartUnavailableTitle = 'This plan is no longer available';
static const String preStartUnavailableBody =
    'It may have been deleted or has no exercises configured.';
static const String preStartBackToScheduleButton = 'Back to Schedule';

// State D — error
static const String preStartErrorTitle = "Couldn't load this workout";
static const String preStartErrorBody =
    'Something went wrong reading local data. Your data is safe — tap Retry to try again.';
static const String preStartRetryButton = 'Retry';

// Loading semantics
static const String preStartLoadingSemantics = 'Loading workout overview';
```

---

## New utility: `formatDuration`

Added to `forge/lib/core/utils/` (new file or appended to existing utils):

```dart
/// Formats [seconds] as "MM:SS". Example: 90 → "01:30".
String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
```

---

## Route constants added to `RoutePaths`

```dart
// Updated
static const String workoutPreStart = '/plans/:planId/start';
static const String workoutPreStartName = 'workoutPreStart';

// New stub for SCR-16
static const String activeWorkout = '/workout/active';
static const String activeWorkoutName = 'activeWorkout';
```

---

## No new table or column

SCR-15 is **read-only**. No new table, column, or schema change is introduced.
