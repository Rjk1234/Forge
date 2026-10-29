# Contract: ActiveWorkoutBloc Amendments (SCR-18)

**Amends**: SCR-16 ActiveWorkoutBloc  
**Files modified**: `active_workout_event.dart`, `active_workout_bloc.dart`, `active_workout_screen.dart`

These amendments fill in the cancel path that SCR-16 pre-designed but left as a stub. They are purely additive — no existing SCR-16 events, states, or handlers are changed.

---

## New Events

### `ActiveWorkoutCancelRequested`

```dart
class ActiveWorkoutCancelRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutCancelRequested();
}
```

**Dispatched by**:
- `ActiveWorkoutScreen` — Cancel button `onPressed` (app bar)
- `ActiveWorkoutScreen` — `PopScope.onPopInvokedWithResult` (OS back gesture on SCR-16)

**Effect**: Bloc emits `ActiveWorkoutRunning.copyWith(navigateToCancel: true)` → BlocListener pushes `/workout/cancel`.

---

### `ActiveWorkoutCancelNavigated`

```dart
class ActiveWorkoutCancelNavigated extends ActiveWorkoutEvent {
  const ActiveWorkoutCancelNavigated();
}
```

**Dispatched by**:
- `ActiveWorkoutScreen` BlocListener — immediately after calling `context.push(RoutePaths.cancelWorkout)`.

**Effect**: Bloc emits `ActiveWorkoutRunning.copyWith(navigateToCancel: false)` — resets the navigation flag so re-opening SCR-18 works correctly on repeated cancel attempts.

---

## New Handlers

```dart
// In active_workout_bloc.dart constructor registration:
on<ActiveWorkoutCancelRequested>(_onCancelRequested);
on<ActiveWorkoutCancelNavigated>(_onCancelNavigated);
```

```dart
void _onCancelRequested(
  ActiveWorkoutCancelRequested event,
  Emitter<ActiveWorkoutState> emit,
) {
  if (state is! ActiveWorkoutRunning) return;
  emit((state as ActiveWorkoutRunning).copyWith(navigateToCancel: true));
}

void _onCancelNavigated(
  ActiveWorkoutCancelNavigated event,
  Emitter<ActiveWorkoutState> emit,
) {
  if (state is! ActiveWorkoutRunning) return;
  emit((state as ActiveWorkoutRunning).copyWith(navigateToCancel: false));
}
```

**Guard**: Both handlers return early if `state is! ActiveWorkoutRunning`. This prevents errors if an event arrives in an unexpected state.

---

## ActiveWorkoutScreen Amendments

Three amendment points in `active_workout_screen.dart`. All are surgical replacements of existing stub code — no surrounding code changes.

### 1. BlocListener — Add `navigateToCancel` Branch

Add alongside existing `navigateToRestTimer` and `navigateToPostWorkout` branches:

```dart
// Add in BlocListener's listenWhen/listener block:
if (state.navigateToCancel) {
  context.push(RoutePaths.cancelWorkout);
  context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelNavigated());
}
```

The `context.push()` call is placed before the `add(CancelNavigated())` so the route is registered before the flag resets.

### 2. Cancel Button — Replace Stub

```dart
// SCR-16 stub (REMOVE):
onPressed: () => context.push(RoutePaths.cancelWorkout),

// SCR-18 replacement (ADD):
onPressed: () =>
    context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelRequested()),
```

### 3. PopScope — Replace Stub

```dart
// SCR-16 stub (REMOVE, per SCR-16 D-05):
PopScope(
  canPop: false,
  onPopInvokedWithResult: (_, __) => context.push(RoutePaths.cancelWorkout),
  ...
)

// SCR-18 replacement (UPDATE handler):
PopScope(
  canPop: false,
  onPopInvokedWithResult: (_, __) =>
      context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelRequested()),
  ...
)
```

---

## State Transition Table (Cancel Path)

| Current state | Event | New state | Side effect |
|---------------|-------|-----------|-------------|
| `ActiveWorkoutRunning(navigateToCancel: false)` | `CancelRequested` | `ActiveWorkoutRunning(navigateToCancel: true)` | BlocListener fires `context.push` |
| `ActiveWorkoutRunning(navigateToCancel: true)` | `CancelNavigated` | `ActiveWorkoutRunning(navigateToCancel: false)` | Flag reset for next cancel |
| Any other state | `CancelRequested` | Unchanged | Guard: early return |
| Any other state | `CancelNavigated` | Unchanged | Guard: early return |

---

## Test Scenarios

| Scenario | Event sequence | Expected final state |
|----------|----------------|----------------------|
| Cancel from running workout | `CancelRequested` | `navigateToCancel: true` |
| Navigation flag reset | `CancelRequested` → `CancelNavigated` | `navigateToCancel: false` |
| Cancel in non-running state | `CancelRequested` when `state is ActiveWorkoutLoading` | State unchanged |
| Repeated cancel-keep going | `CancelRequested` → `CancelNavigated` → `CancelRequested` | `navigateToCancel: true` (second cancel works) |
