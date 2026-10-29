# Contract: Persistence Failure Types

**Feature**: LOCALDB-01 Local Data Persistence
**Status**: NEW (WorkoutSessionFailure) / EXISTING PATTERN (WorkoutPlanFailure)

---

## WorkoutSessionFailure (NEW)

**File**: `forge/lib/features/workout_session/domain/failures/workout_session_failure.dart`

```dart
sealed class WorkoutSessionFailure {
  const WorkoutSessionFailure();

  /// A database save operation failed. Previously persisted data is unaffected.
  const factory WorkoutSessionFailure.saveFailure({String? detail}) = _SaveFailure;

  /// A database read operation failed.
  const factory WorkoutSessionFailure.readFailure({String? detail}) = _ReadFailure;

  /// A database delete operation failed.
  const factory WorkoutSessionFailure.deleteFailure({String? detail}) = _DeleteFailure;

  /// Session did not meet the completion criterion (≥1 set logged).
  /// No write was attempted. This is a guard rejection, not a database error.
  const factory WorkoutSessionFailure.completionCriterionNotMet() = _CompletionCriterionNotMet;
}
```

---

## Existing Pattern Reference

`WorkoutPlanFailure` (workout_plan feature) follows the same sealed class pattern with `loadFailure`, `saveFailure`, `deleteFailure`. Implement `WorkoutSessionFailure` consistently with this established pattern.

---

## UI Mapping Requirement (FR-013, SC-011)

When a Bloc receives a `WorkoutSessionFailure.saveFailure`:
- Display a visible error message on the current screen
- The message must be from `AppStrings.*` — never a raw exception string
- The user must be able to retry the failed operation
- The screen must NOT enter a blank or undefined state

The Bloc owning the save operation (in SCR-19 Workout Execution) is responsible for mapping the failure to an error state. LOCALDB-01 defines the failure type; SCR-19 defines the error UI.

`completionCriterionNotMet` does not require a user-visible error — it is a guard condition that the workout execution flow controls. The execution Bloc decides whether to silently discard or surface this as a UI message.
