# Contract: ActiveWorkoutBloc

**Feature**: SCR-16 Active Workout
**Location**: `forge/lib/features/workout_session/application/bloc/active_workout_bloc.dart`

---

## Class declaration

```dart
class ActiveWorkoutBloc extends Bloc<ActiveWorkoutEvent, ActiveWorkoutState>
```

**Constructor**:

```dart
ActiveWorkoutBloc({required SaveWorkoutSessionUseCase saveWorkoutSession})
    : super(const ActiveWorkoutInitial())
```

Registered in `get_it_setup.dart` as `sl.registerFactory<ActiveWorkoutBloc>`.

---

## Private Bloc state (not emitted)

```dart
late WorkoutPlanDetail _plan;
late DateTime _startedAt;

// [exerciseIdx][setIdx] — one entry per set
late List<List<_SetEntry>> _loggedSets;

// Non-null only while a failed Finish write is retryable
WorkoutSession? _completedSession;
```

```dart
class _SetEntry {
  _SetEntry({required this.targetReps, required this.targetWeight, required this.targetDurationSec});
  int? targetReps;
  double? targetWeight;
  int? targetDurationSec;
  SetStatus status = SetStatus.pending;
  int? actualReps;
  double? actualWeight;
  int? actualDurationSec;
}
```

---

## Events

### `ActiveWorkoutStarted`

```dart
class ActiveWorkoutStarted extends ActiveWorkoutEvent {
  const ActiveWorkoutStarted({required this.plan});
  final WorkoutPlanDetail plan;
}
```

- Dispatched from `ActiveWorkoutScreen` route builder (in `app_routes.dart`), after reading `plan` from `state.extra as WorkoutPlanDetail`.
- Initializes `_plan`, `_startedAt`, and `_loggedSets` from `plan.exercises`.
- Emits `ActiveWorkoutRunning` at exercise 0, set 0, all statuses `pending`.

### `ActiveWorkoutCompleteSetRequested`

```dart
class ActiveWorkoutCompleteSetRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutCompleteSetRequested({this.reps, this.weight, this.durationSec});
  final int? reps;
  final double? weight;
  final int? durationSec;
}
```

- Dispatched when the user taps "Complete Set".
- Bloc validates values against the current exercise type.
- On validation failure: emits `ActiveWorkoutRunning.copyWith(repError/weightError/durationError: ...)`.
- On success: marks set as `logged`, advances to next set/exercise. If this was the last set and `_loggedSets` has ≥1 logged entry → triggers Finish.

### `ActiveWorkoutSkipSetRequested`

```dart
class ActiveWorkoutSkipSetRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutSkipSetRequested();
}
```

- Marks current set as `skipped`. Advances to next set/exercise.
- If this was the last set of the last exercise AND total logged count == 0 → triggers FR-009 (discard path to SCR-18, via `ActiveWorkoutRunning.copyWith(writeError: AppStrings.activeWorkoutDiscardZeroSets)` or dedicated navigation event — see "Navigation" section).
- If this was the last set of the last exercise AND ≥1 logged → stay on this set (user sees skipped dot, Complete Set still available).

### `ActiveWorkoutPauseRequested`

```dart
class ActiveWorkoutPauseRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutPauseRequested();
}
```

- Emits `ActiveWorkoutRunning.copyWith(isPaused: true)`. No other state changes.

### `ActiveWorkoutResumeRequested`

```dart
class ActiveWorkoutResumeRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutResumeRequested();
}
```

- Emits `ActiveWorkoutRunning.copyWith(isPaused: false)`. No other state changes.

### `ActiveWorkoutFieldChanged`

```dart
class ActiveWorkoutFieldChanged extends ActiveWorkoutEvent {
  const ActiveWorkoutFieldChanged({required this.field, required this.value});
  final ActiveWorkoutField field;
  final String value;
}
```

- Dispatched by the presentation on every text change in a field.
- Clears the error for `field` if it is currently set:
  - `ActiveWorkoutField.reps` → clear `repError`
  - `ActiveWorkoutField.weight` → clear `weightError`
  - `ActiveWorkoutField.duration` → clear `durationError`
- Emits updated `ActiveWorkoutRunning` with the relevant error nulled. If the error was already null, this event is a no-op.

### `ActiveWorkoutRetryFinishRequested`

```dart
class ActiveWorkoutRetryFinishRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutRetryFinishRequested();
}
```

- Dispatched when the user taps Retry after a write error.
- Reuses `_completedSession` (same UUID — idempotent write).
- Calls `SaveWorkoutSessionUseCase` again.
- On success: `_completedSession = null`, navigate to SCR-19 (side effect via Bloc listener).
- On failure: re-emits the running state with `writeError`.

---

## States

### `ActiveWorkoutInitial`

```dart
class ActiveWorkoutInitial extends ActiveWorkoutState {
  const ActiveWorkoutInitial();
}
```

Initial Bloc state. Never rendered. Replaced immediately when `ActiveWorkoutStarted` fires in the route builder.

### `ActiveWorkoutRunning`

See `data-model.md` for the full field list and `props`.

Also carries the `copyWith` pattern for efficient incremental updates.

---

## State transition table

| Current state | Event | Guard | → Next state / side effect |
|---|---|---|---|
| `Initial` | `ActiveWorkoutStarted` | — | `Running` (ex:0, set:0, all pending) |
| `Running` | `CompleteSetRequested` | validation fails | `Running` (same position, errors set) |
| `Running` | `CompleteSetRequested` | valid, not last-of-last | `Running` (next position, errors cleared) |
| `Running` | `CompleteSetRequested` | valid, last-of-last, ≥1 logged | Trigger Finish → on success: navigate to SCR-19; on fail: `Running(writeError: ...)` |
| `Running` | `CompleteSetRequested` | valid, last-of-last, 0 logged | Trigger FR-009: navigate to SCR-18 |
| `Running` | `SkipSetRequested` | not last-of-last | `Running` (next position, current set = skipped) |
| `Running` | `SkipSetRequested` | last-of-last, ≥1 logged | `Running` (same position, current set = skipped, Complete Set still available) |
| `Running` | `SkipSetRequested` | last-of-last, 0 logged | Trigger FR-009: navigate to SCR-18 |
| `Running` | `PauseRequested` | — | `Running.copyWith(isPaused: true)` |
| `Running(paused)` | `ResumeRequested` | — | `Running.copyWith(isPaused: false)` |
| `Running` | `FieldChanged` | error exists for field | `Running.copyWith(<field>Error: null)` |
| `Running` | `FieldChanged` | error already null | no-op (no emit) |
| `Running(writeError≠null)` | `RetryFinishRequested` | — | call use case → success: navigate SCR-19; fail: `Running.copyWith(writeError: ...)` |

---

## Handler pseudo-code (abbreviated)

```dart
// CompleteSetRequested
Future<void> _onCompleteSet(ActiveWorkoutCompleteSetRequested event, Emitter emit) async {
  final exercise = _plan.exercises[_exerciseIdx];
  final errors = _validate(exercise.type, event.reps, event.weight, event.durationSec);
  if (errors.hasError) {
    emit(_currentState.copyWith(repError: errors.repError, weightError: errors.weightError, durationError: errors.durationError));
    return;
  }
  _loggedSets[_exerciseIdx][_setIdx]
    ..status = SetStatus.logged
    ..actualReps = event.reps
    ..actualWeight = event.weight
    ..actualDurationSec = event.durationSec;
  if (_isLastOfLast) {
    if (_loggedCount > 0) await _triggerFinish(emit);
    else _triggerDiscard(emit);  // navigate to SCR-18 via side-effect event
  } else {
    _advance();
    emit(_buildRunning());
  }
}

// _triggerFinish
Future<void> _triggerFinish(Emitter emit) async {
  final session = _buildSession();
  _completedSession = session;
  final result = await _saveWorkoutSession(session);
  result.fold(
    (failure) => emit(_currentState.copyWith(writeError: failure.message, isPaused: false)),
    (_) { _completedSession = null; /* navigate to SCR-19 via listener */ },
  );
}
```

---

## Navigation side effects

The Bloc does NOT navigate directly. Navigation is handled via `BlocListener` in the screen:

```dart
// In ActiveWorkoutScreen:
BlocListener<ActiveWorkoutBloc, ActiveWorkoutState>(
  listener: (context, state) {
    if (state is ActiveWorkoutRunning) {
      if (state.shouldNavigateToPostWorkout) {
        if (!context.mounted) return;
        context.go(RoutePaths.postWorkout);
      }
      if (state.shouldNavigateToCancel) {
        if (!context.mounted) return;
        context.push(RoutePaths.cancelWorkout);
      }
    }
  },
  child: ...,
)
```

To signal navigation without adding a separate state class, `ActiveWorkoutRunning` carries two boolean navigation flags:
- `navigateToPostWorkout: bool` — set true when Finish write succeeds
- `navigateToCancel: bool` — set true when FR-009 fires (zero logged sets)

Both default to `false`; the `copyWith` sets them. The listener fires, navigates, and the flag is never re-emitted (the navigation itself destroys the screen).

---

## DI registration

```dart
// get_it_setup.dart — workout_session section
sl.registerLazySingleton<SaveWorkoutSessionUseCase>(
  () => SaveWorkoutSessionUseCase(repository: sl()),
);

sl.registerFactory<ActiveWorkoutBloc>(
  () => ActiveWorkoutBloc(saveWorkoutSession: sl()),
);
```

---

## Route wiring

```dart
// app_routes.dart — top-level GoRoute (not nested under /plans/:planId)
GoRoute(
  path: RoutePaths.activeWorkout,   // '/workout/active'
  name: RoutePaths.activeWorkoutName,
  builder: (context, state) {
    final plan = state.extra as WorkoutPlanDetail;
    return BlocProvider(
      create: (_) => sl<ActiveWorkoutBloc>()
        ..add(ActiveWorkoutStarted(plan: plan)),
      child: const ActiveWorkoutScreen(),
    );
  },
),

GoRoute(
  path: RoutePaths.cancelWorkout,   // '/workout/cancel' — SCR-18 stub
  name: RoutePaths.cancelWorkoutName,
  builder: (_, __) => Scaffold(
    body: Center(child: Text(AppStrings.cancelWorkoutStubLabel)),
  ),
),

GoRoute(
  path: RoutePaths.postWorkout,     // '/workout/summary' — SCR-19 stub
  name: RoutePaths.postWorkoutName,
  builder: (_, __) => Scaffold(
    body: Center(child: Text(AppStrings.postWorkoutStubLabel)),
  ),
),
```

**Entry from SCR-15**:
```dart
// pre_start_screen.dart — Begin Workout button
context.pushReplacement(
  RoutePaths.activeWorkout,
  extra: plan,  // the WorkoutPlanDetail already loaded by PreStartBloc
);
```

`pushReplacement` ensures SCR-15 is removed from the back-stack. The OS back gesture from SCR-16 is intercepted by `PopScope` (D-05) and routes to SCR-18.
