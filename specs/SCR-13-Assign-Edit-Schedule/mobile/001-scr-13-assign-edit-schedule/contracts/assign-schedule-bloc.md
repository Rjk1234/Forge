# Contract: `AssignScheduleBloc`

**Layer**: Application (`features/schedule/application/bloc/`)

## Events

```dart
sealed class AssignScheduleEvent extends Equatable {}

class AssignScheduleInitialized extends AssignScheduleEvent {
  final String planId;
}
class DayToggled extends AssignScheduleEvent {
  final int weekday; // 1–7
}
class SaveRequested extends AssignScheduleEvent {}
class RetrySaveRequested extends AssignScheduleEvent {}
```

- `AssignScheduleInitialized`: dispatched once from `AssignScheduleScreen.initState()` with the `planId` route parameter.
- `DayToggled`: dispatched on every day-chip tap, regardless of its current state (unselected/selected/conflict) — toggles membership in `selectedDays` and recomputes `conflicts`.
- `SaveRequested` / `RetrySaveRequested`: mirror `CreateEditWorkoutPlanBloc`'s pattern exactly, including that `RetrySaveRequested` is a no-op unless the current state is `AssignScheduleSaveFailure`.

## States

```dart
sealed class AssignScheduleState extends Equatable {}

class AssignScheduleInitial extends AssignScheduleState {}
class AssignScheduleLoading extends AssignScheduleState {}
class AssignScheduleReady extends AssignScheduleState {
  final String planId;
  final String planName;
  final Set<int> originalDays;
  final Set<int> selectedDays;
  final Map<int, String> occupiedDays;
  final Map<int, String> conflicts;
  bool get canSave => selectedDays.isNotEmpty && conflicts.isEmpty;
  bool get isEditMode => originalDays.isNotEmpty; // drives "New Schedule" vs "Edit Schedule" app bar title
}
class AssignScheduleInvalidPlan extends AssignScheduleState {
  final String planId;
}
class AssignScheduleSaving extends AssignScheduleState {
  final AssignScheduleReady readyState;
}
class AssignScheduleSaved extends AssignScheduleState {}
class AssignScheduleSaveFailure extends AssignScheduleState {
  final AssignScheduleReady readyState;
  final String message;
}
```

## Transition table

| Current state | Event | Repository result | Next state |
|---|---|---|---|
| `Initial` | `AssignScheduleInitialized` | — | `Loading` |
| `Loading` | (internal) | `Right(ctx)`, `ctx.planName == null` | `InvalidPlan(planId)` |
| `Loading` | (internal) | `Right(ctx)`, `ctx.planName != null` | `Ready(originalDays=selectedDays=ctx.currentDays, occupiedDays=ctx.occupiedDays, conflicts={})` |
| `Loading` | (internal) | `Left(failure)` | `InvalidPlan(planId)` — a load failure is presented identically to an invalid plan (both replace the plan field with an explanatory, blocking message); see Note below |
| `Ready` | `DayToggled(d)` | — | `Ready` with `selectedDays` toggled for `d` and `conflicts` recomputed against `occupiedDays` |
| `Ready` (canSave) | `SaveRequested` | — | `Saving(readyState: this)` |
| `Ready` (!canSave) | `SaveRequested` | — | *(ignored — Save is not actionable; UI should already disable the control)* |
| `Saving` | (internal) | `Right(_)` | `Saved` |
| `Saving` | (internal) | `Left(failure)` | `SaveFailure(readyState, failure.message)` |
| `SaveFailure` | `RetrySaveRequested` | — | `Saving(readyState)` (same `readyState`, re-attempts) |
| `Loading`/`Saving` | `RetrySaveRequested` | — | *(ignored — no-op; matches `CreateEditWorkoutPlanBloc`'s guard)* |

**Note on load-failure presentation**: Unlike SCR-12 (which has a dedicated retryable error state for load failures), this screen presents any `loadAssignmentContext` failure the same way as `AssignScheduleInvalidPlan` — an explanatory, non-recoverable-here message — because the spec's only two load-time terminal states are "ready to edit" and "plan unavailable" (User Story 5); there is no separate load-retry story specified for this screen (unlike SCR-12's User Story 4, which is specifically about save-time failure). This keeps the state machine aligned exactly to spec.md's five user stories.

## UI mapping (consumed by `AssignScheduleScreen` via `BlocBuilder`)

| State | Rendering |
|---|---|
| `Initial`, `Loading` | Loading indicator (reuse `core` conventions — see `home/presentation/widgets/loading_indicator.dart` shape) |
| `Ready` | App bar title from `isEditMode` ("Edit Schedule"/"New Schedule"); `PlanSelectorDisplay`, `DayChipRow` (with `conflicts` driving each chip's tri-state and an inline conflict message when non-empty), `RecurrenceRow`, footer Save button (`enabled: canSave`) |
| `InvalidPlan` | `InvalidPlanBanner` replaces the plan selector; day selection area dimmed/disabled; Save disabled |
| `Saving` | Same layout as the `readyState` it carries, but dimmed/non-interactive per design spec §3.5, with a spinner + "Saving…" on the Save button; `PopScope(canPop: false)` |
| `Saved` | Not rendered — the screen pops itself (`context.pop()`) the moment this state is reached |
| `SaveFailure` | Same layout as `readyState`, plus `ScheduleSaveFailureBanner` above the content; Save button reads "Retry Save" |

## Test contract (`assign_schedule_bloc_test.dart`, `bloc_test`)

| Case | Seed | Act | Expect |
|---|---|---|---|
| New assignment path | `loadAssignmentContext` returns `Right` with empty `currentDays` | `add(AssignScheduleInitialized(planId))` | `[Loading, Ready(selectedDays: {}, canSave: false)]` |
| Edit path, pre-filled | `loadAssignmentContext` returns `Right` with `currentDays: {1,3}` | `add(AssignScheduleInitialized(planId))` | `[Loading, Ready(selectedDays: {1,3}, canSave: true)]` |
| Invalid plan | `loadAssignmentContext` returns `Right` with `planName: null` | `add(AssignScheduleInitialized(planId))` | `[Loading, InvalidPlan(planId)]` |
| Toggle introduces conflict | `Ready` seeded with `occupiedDays: {2: 'Push Day'}` | `add(DayToggled(2))` | `Ready` with `conflicts: {2: 'Push Day'}`, `canSave: false` |
| Toggle clears conflict | `Ready` seeded mid-conflict on day 2 | `add(DayToggled(2))` (deselect) | `Ready` with `conflicts: {}`, `canSave` reflects remaining selection |
| Save success | `Ready(canSave: true)`; `saveAssignment` returns `Right(null)` | `add(SaveRequested())` | `[Saving, Saved]` |
| Save failure + retry | `saveAssignment` returns `Left` then `Right` | `add(SaveRequested())`, then `add(RetrySaveRequested())` | `[Saving, SaveFailure, Saving, Saved]` |
| Save ignored when not canSave | `Ready(canSave: false)` | `add(SaveRequested())` | no new states emitted |
