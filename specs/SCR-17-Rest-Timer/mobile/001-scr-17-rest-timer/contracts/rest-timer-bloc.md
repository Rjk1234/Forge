# Contract: RestTimerBloc

**Feature**: SCR-17 Rest Timer
**File**: `forge/lib/features/workout_session/application/bloc/rest_timer_bloc.dart`

---

## State contract

### Initial state

`RestTimerInitial()` — emitted before `RestTimerStarted` is dispatched. Screen never renders while in this state (the `BlocProvider.create` dispatches `RestTimerStarted` synchronously, so the first rendered frame is already `RestTimerRunning`).

### Running state sequence (example: 90-second rest)

| Event | Emitted state | Notes |
|---|---|---|
| `RestTimerStarted(restPeriodSec: 90)` | `RestTimerRunning(totalSec: 90, remainingSec: 90, navigateBack: false)` | Timer started |
| `RestTimerTicked` (×1) | `RestTimerRunning(totalSec: 90, remainingSec: 89, navigateBack: false)` | 1 second elapsed |
| … (×88 more) | `RestTimerRunning(totalSec: 90, remainingSec: 1, navigateBack: false)` | 89 seconds elapsed |
| `RestTimerTicked` | `RestTimerRunning(totalSec: 90, remainingSec: 0, navigateBack: true)` | Timer cancelled; navigate flag set |

### Skip path (at any point)

| Event | Emitted state | Notes |
|---|---|---|
| `RestTimerSkipped` | `RestTimerRunning(totalSec: 90, remainingSec: N, navigateBack: true)` | `remainingSec` is whatever was current; timer cancelled |

---

## Event handling rules

| Event | Guard | Action |
|---|---|---|
| `RestTimerStarted` | None | Cancel any prior `_timer`; emit `RestTimerRunning(totalSec, remainingSec: totalSec)`; start `Timer.periodic` |
| `RestTimerTicked` | `state is RestTimerRunning` | Decrement `remainingSec`; if becomes 0: cancel timer, set `navigateBack: true` |
| `RestTimerSkipped` | `state is RestTimerRunning` | Cancel timer; set `navigateBack: true` |

---

## BlocListener responsibility (RestTimerScreen)

```dart
BlocListener<RestTimerBloc, RestTimerState>(
  listenWhen: (prev, curr) =>
      curr is RestTimerRunning && (curr as RestTimerRunning).navigateBack,
  listener: (context, state) => context.pop(),
)
```

The listener calls `context.pop()` exactly once when `navigateBack` becomes true. No further interaction between SCR-17 and SCR-16 is needed — `ActiveWorkoutBloc` already holds the advanced set position.

---

## Lifecycle invariants

1. `_timer` MUST be cancelled in `close()` — prevents callback fires after the Bloc is disposed.
2. `_timer` MUST be cancelled before starting a new one in `_onStarted` — guards against re-dispatching `RestTimerStarted` (defensive only; the UI should not allow this).
3. `RestTimerTicked` events MUST be ignored when `state is! RestTimerRunning` — defensive guard for any race between `cancel()` and an in-flight tick callback.

---

## Test scenarios (bloc_test)

| Scenario | Events | Expected states |
|---|---|---|
| Natural expiry (3-second rest) | `Started(3)`, `Ticked`, `Ticked`, `Ticked` | `Running(3,3,false)` → `Running(3,2,false)` → `Running(3,1,false)` → `Running(3,0,true)` |
| Skip immediately | `Started(90)`, `Skipped` | `Running(90,90,false)` → `Running(90,90,true)` |
| Skip mid-countdown | `Started(90)`, `Ticked`×5, `Skipped` | …`Running(90,85,false)` → `Running(90,85,true)` |
| Zero-second rest — bypass (no Bloc instantiation) | N/A | SCR-17 never created; test at ActiveWorkoutBloc level |
