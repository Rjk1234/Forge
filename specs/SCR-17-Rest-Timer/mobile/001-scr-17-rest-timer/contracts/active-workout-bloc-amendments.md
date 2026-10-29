# Contract: ActiveWorkoutBloc Amendments for SCR-17

**Feature**: SCR-17 Rest Timer
**Amends**: `SCR-16-Active-Workout/mobile/001-scr-16-active-workout/contracts/active-workout-bloc.md`
**Files modified**:
- `forge/lib/features/workout_session/application/bloc/active_workout_state.dart`
- `forge/lib/features/workout_session/application/bloc/active_workout_event.dart`
- `forge/lib/features/workout_session/application/bloc/active_workout_bloc.dart`
- `forge/lib/features/workout_session/presentation/screens/active_workout_screen.dart`

---

## `ActiveWorkoutRunning` — 2 new fields

Add to the existing `ActiveWorkoutRunning` class (fields 13 and 14 in `props`):

```dart
/// Set true after a valid set completion when restPeriodSec > 0.
/// BlocListener in ActiveWorkoutScreen pushes SCR-17 and immediately
/// dispatches ActiveWorkoutRestTimerNavigated to reset this flag.
final bool navigateToRestTimer;   // default: false

/// The rest duration in seconds to pass to SCR-17 via route extra.
/// Reset to 0 by ActiveWorkoutRestTimerNavigated.
final int restPeriodSec;          // default: 0
```

Updated `props` (14 items total):
```dart
@override
List<Object?> get props => [
  currentExercise, exerciseIndex, exerciseCount,
  currentSetIndex, setStatuses,
  repError, weightError, durationError,
  isPaused, writeError,
  navigateToPostWorkout, navigateToCancel,
  navigateToRestTimer, restPeriodSec,   // ← NEW (SCR-17)
];
```

---

## `ActiveWorkoutEvent` — 1 new event

Add to `active_workout_event.dart`:

```dart
/// Fired by ActiveWorkoutScreen's BlocListener after it calls
/// context.push(RoutePaths.restTimer, extra: N).
/// Resets navigateToRestTimer and restPeriodSec to their neutral defaults.
class ActiveWorkoutRestTimerNavigated extends ActiveWorkoutEvent {
  const ActiveWorkoutRestTimerNavigated();
  @override
  List<Object?> get props => [];
}
```

---

## `ActiveWorkoutBloc` — set-completion logic fork

In the handler for `ActiveWorkoutCompleteSetRequested`, after validating and logging the set, replace the existing single-path "advance and emit" with:

```
// Capture rest period from the exercise whose set was JUST completed
// (before advancing _currentExerciseIndex)
final completedExercise = _plan.exercises[_currentExerciseIndex];
final restSec = completedExercise.restPeriodSec;

// ... advance _currentSetIndex / _currentExerciseIndex as before ...

if (restSec > 0 && !_isFinishTriggered) {
  // Advance state AND signal rest-timer navigation
  emit(nextRunningState.copyWith(
    navigateToRestTimer: true,
    restPeriodSec: restSec,
  ));
} else {
  // Zero rest or Finish path — advance state directly (no SCR-17)
  emit(nextRunningState);
}
```

Handler for `ActiveWorkoutRestTimerNavigated`:

```dart
on<ActiveWorkoutRestTimerNavigated>((event, emit) {
  if (state is ActiveWorkoutRunning) {
    emit((state as ActiveWorkoutRunning).copyWith(
      navigateToRestTimer: false,
      restPeriodSec: 0,
    ));
  }
});
```

---

## `ActiveWorkoutScreen` BlocListener amendment

Add a `listenWhen` branch (or extend the existing listener) to handle `navigateToRestTimer`:

```dart
BlocListener<ActiveWorkoutBloc, ActiveWorkoutState>(
  listener: (context, state) {
    if (state is! ActiveWorkoutRunning) return;
    if (state.navigateToRestTimer) {
      context.push(RoutePaths.restTimer, extra: state.restPeriodSec);
      context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutRestTimerNavigated());
    }
    if (state.navigateToPostWorkout) {
      context.go(RoutePaths.postWorkout);
    }
    if (state.navigateToCancel) {
      context.push(RoutePaths.cancelWorkout);
    }
  },
  child: ...,
)
```

---

## State machine impact on existing tests

The 13 existing bloc test scenarios for `ActiveWorkoutBloc` (T019 in SCR-16 tasks.md) must be updated:

1. Any scenario involving a non-last set completion on an exercise with `restPeriodSec > 0` now emits `navigateToRestTimer: true` + `restPeriodSec: N` in the intermediate state, followed by an `ActiveWorkoutRestTimerNavigated` event that resets them.
2. Any scenario with `restPeriodSec == 0` continues to emit directly to the next-set state (no change).
3. A new test scenario is required: "set completion with `restPeriodSec > 0` emits navigateToRestTimer flag, then `RestTimerNavigated` resets it."
