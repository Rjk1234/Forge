# Contract: ActiveWorkoutBloc Amendments for SCR-19

**Feature**: SCR-19 Workout Summary & Completion
**Target file**: `forge/lib/features/workout_session/application/bloc/active_workout_bloc.dart`
(and associated event/state files)

These amendments SUPERSEDE the SCR-16 contract's Finish path design.
Apply AFTER the SCR-18 amendments (cancel path) are applied.

---

## Reason for amendments

SCR-19 owns the Drift write and error handling for the Finish flow. The SCR-16
contract placed the save inside `ActiveWorkoutBloc._triggerFinish` with error
handling via `writeError: String?`. SCR-19 supersedes this design: the save is
removed from `ActiveWorkoutBloc` and moved to `WorkoutSummaryBloc`. These
amendments reflect the corrected Finish path.

---

## Amendment 1: Remove `writeError` from `ActiveWorkoutRunning`

**File**: `forge/lib/features/workout_session/application/bloc/active_workout_state.dart`

Remove field (was planned by SCR-16 data-model):
```dart
// REMOVE this field — SCR-19 owns error handling; never emitted for Finish
final String? writeError;
```

Remove from `props` list.
Remove from `copyWith` signature.

---

## Amendment 2: Add `completedSession` to `ActiveWorkoutRunning`

**File**: `forge/lib/features/workout_session/application/bloc/active_workout_state.dart`

Add field:
```dart
// NEW — carries the built session when navigateToPostWorkout is true;
// BlocListener reads this and passes it as extra to the SCR-19 route
final WorkoutSession? completedSession;
```

Add to `props` list: `completedSession`.
Add to `copyWith` signature: `WorkoutSession? completedSession`.

---

## Amendment 3: Remove `ActiveWorkoutRetryFinishRequested` event

**File**: `forge/lib/features/workout_session/application/bloc/active_workout_event.dart`

Remove (was planned by SCR-16 data-model):
```dart
// REMOVE — retry is handled by WorkoutSummaryBloc on SCR-19
class ActiveWorkoutRetryFinishRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutRetryFinishRequested();
}
```

Also remove its handler registration from `ActiveWorkoutBloc`'s constructor.

---

## Amendment 4: Add `ActiveWorkoutPostWorkoutNavigated` event

**File**: `forge/lib/features/workout_session/application/bloc/active_workout_event.dart`

```dart
// NEW — dispatched by BlocListener after context.go() to SCR-19
class ActiveWorkoutPostWorkoutNavigated extends ActiveWorkoutEvent {
  const ActiveWorkoutPostWorkoutNavigated();
}
```

Handler registration (in `ActiveWorkoutBloc` constructor):
```dart
on<ActiveWorkoutPostWorkoutNavigated>(_onPostWorkoutNavigated);
```

Handler implementation:
```dart
void _onPostWorkoutNavigated(
  ActiveWorkoutPostWorkoutNavigated event,
  Emitter emit,
) {
  if (state is! ActiveWorkoutRunning) return;
  emit((state as ActiveWorkoutRunning).copyWith(
    navigateToPostWorkout: false,
    completedSession: null,
  ));
}
```

---

## Amendment 5: Change `ActiveWorkoutBloc` constructor (remove use case)

**File**: `forge/lib/features/workout_session/application/bloc/active_workout_bloc.dart`

**SCR-16 contract** (superseded):
```dart
ActiveWorkoutBloc({required SaveWorkoutSessionUseCase saveWorkoutSession})
```

**Corrected**:
```dart
ActiveWorkoutBloc()
```

No `saveWorkoutSession` injection. The `SaveWorkoutSessionUseCase` is still registered
in `get_it_setup.dart` (for `WorkoutSummaryBloc`) — only the constructor parameter
and private field `_saveWorkoutSession` in `ActiveWorkoutBloc` are removed.

`get_it_setup.dart` DI registration for `ActiveWorkoutBloc`:
```dart
getIt.registerFactory<ActiveWorkoutBloc>(() => ActiveWorkoutBloc());
```

---

## Amendment 6: Simplify `_triggerFinish` → `_prepareFinish`

**File**: `forge/lib/features/workout_session/application/bloc/active_workout_bloc.dart`

**SCR-16 contract** `_triggerFinish` (superseded):
```dart
Future<void> _triggerFinish(Emitter emit) async {
  final session = _buildSession();
  _completedSession = session;
  final result = await _saveWorkoutSession(session);
  result.fold(
    (failure) => emit(_currentState.copyWith(writeError: failure.message)),
    (_) { _completedSession = null; },
  );
}
```

**Corrected `_prepareFinish`**:
```dart
void _prepareFinish(Emitter emit) {
  final session = _buildSession();
  emit(_buildRunning().copyWith(
    navigateToPostWorkout: true,
    completedSession: session,
  ));
}
```

Synchronous. No async, no use-case call, no `writeError`. The private
`_completedSession: WorkoutSession?` field in `ActiveWorkoutBloc` is removed;
the session now travels via emitted state.

---

## Amendment 7: `active_workout_screen.dart` BlocListener — point 4

**File**: `forge/lib/features/workout_session/presentation/screens/active_workout_screen.dart`

Amend the `navigateToPostWorkout` branch of the BlocListener (positions alongside
existing `navigateToRestTimer` and `navigateToCancel` branches from SCR-17 and SCR-18):

```dart
// SCR-19 amendment — replace the SCR-16 stub with the real navigation
if (state.navigateToPostWorkout && state.completedSession != null) {
  if (!context.mounted) return;
  context.go(RoutePaths.postWorkout, extra: state.completedSession);
  context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutPostWorkoutNavigated());
}
```

`context.go` replaces the current stack entry (SCR-16 is removed) — ensures the
user cannot navigate back to the active workout (FR-003, SC-004).

---

## Amendment summary

| File | Change | Reason |
|---|---|---|
| `active_workout_state.dart` | Remove `writeError`, add `completedSession` | SCR-19 owns error; session needs to travel via state |
| `active_workout_event.dart` | Remove `RetryFinishRequested`, add `PostWorkoutNavigated` | Retry owned by SCR-19; navigation reset event follows SCR-18 pattern |
| `active_workout_bloc.dart` | Remove use-case param, simplify `_prepareFinish` | Save moved to `WorkoutSummaryBloc` |
| `active_workout_screen.dart` | Amend BlocListener `navigateToPostWorkout` branch | Pass session as extra; use `context.go` not `context.push` |
