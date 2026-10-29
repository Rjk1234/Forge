# Research: SCR-17 Rest Timer

**Phase 0 decisions — resolved before design**

---

## D-01: Feature ownership — `workout_session` (existing)

**Decision**: SCR-17 belongs inside the existing `workout_session` feature at `forge/lib/features/workout_session/`. No new feature directory is created.

**Rationale**: The rest timer is an interstitial screen within the workout execution flow — it appears between sets of the same session that `workout_session` already owns. Creating a separate `rest_timer` feature would require cross-feature imports of `PlanExercise` and `ActiveWorkoutBloc` state, which the constitution prohibits (Principle I §5). All execution-time logic (active workout, rest timer) belongs to the same feature.

**Alternatives considered**:
- New `rest_timer` feature — rejected: cross-feature coupling unavoidable; ownership unclear; `workout_session` already owns the session domain.
- Part of `workout_plan` — rejected: `workout_plan` reads plan data; execution state is owned by `workout_session`.

---

## D-02: Dedicated `RestTimerBloc` (not widget-level timer, not `ActiveWorkoutBloc` extension)

**Decision**: SCR-17 has its own `RestTimerBloc extends Bloc<RestTimerEvent, RestTimerState>` in `workout_session/application/bloc/`.

**Rationale**: The countdown (decrement per second, auto-advance when zero) is application-level logic — it belongs in a Bloc, not a widget (CLAUDE.md rule 42). Folding it into `ActiveWorkoutBloc` would give that Bloc two concurrent responsibilities (workout execution state AND per-second timer ticking), violating single-responsibility and making the state machine harder to test. A dedicated `RestTimerBloc` is independently testable with `bloc_test` and can be registered/disposed cleanly through `GetIt`.

**Alternatives considered**:
- Widget-level `Timer.periodic` in a `StatefulWidget` — rejected: constitutes business logic in a widget (CLAUDE.md rule 42, rule 45); untestable with `bloc_test`.
- `ActiveWorkoutBloc` owns the countdown — rejected: dual-responsibility; per-second tick events would pollute the workout Bloc's event stream; harder to isolate in tests.
- `TimerCubit` — rejected: constitution II §1 prohibits `Cubit`; must be `Bloc`.

---

## D-03: `Timer.periodic` inside `RestTimerBloc` — lifecycle management

**Decision**: `RestTimerBloc` holds a private `Timer? _timer` field. On `RestTimerStarted`:
1. Immediately emit `RestTimerRunning(totalSec: restPeriodSec, remainingSec: restPeriodSec)`.
2. Start `_timer = Timer.periodic(const Duration(seconds: 1), (_) => add(RestTimerTicked()))`.

On `RestTimerTicked`:
- If `remainingSec > 1`: emit `copyWith(remainingSec: state.remainingSec - 1)`.
- If `remainingSec == 1`: cancel `_timer`, emit `copyWith(remainingSec: 0, navigateBack: true)`.

On `RestTimerSkipped`:
- Cancel `_timer`, emit `copyWith(navigateBack: true)`.

In `close()`:
- Always cancel `_timer` to prevent the callback firing after dispose (CLAUDE.md rule 71).

**Rationale**: `Timer.periodic` is `dart:async` — no new dependency. Cancelling in `close()` is mandatory for lifecycle safety. The `add(RestTimerTicked())` pattern is the idiomatic `flutter_bloc` approach for external time events.

**Alternatives considered**:
- `Stream.periodic` + `emit.forEach` — possible but adds complexity without benefit at this scale.
- `Future.delayed` chain — rejected: CLAUDE.md rule 74 prohibits `Future.delayed` to paper over timing; also not cancellable.

---

## D-04: Navigation flow — set index advances BEFORE navigating to SCR-17

**Decision**: When `ActiveWorkoutBloc` handles a valid set completion:
1. Logs the set and advances private `_loggedSets`, `_currentSetIndex`, `_currentExerciseIndex` (the next position is now active in the Bloc's internal state).
2. Checks the just-completed exercise's `restPeriodSec`:
   - `restPeriodSec == 0`: emit new `ActiveWorkoutRunning` showing the next set directly. No SCR-17.
   - `restPeriodSec > 0`: emit `ActiveWorkoutRunning.copyWith(navigateToRestTimer: true, restPeriodSec: N, ...next-set fields...)`.
3. `ActiveWorkoutScreen` BlocListener detects `navigateToRestTimer == true`, calls `context.push(RoutePaths.restTimer, extra: N)`, then dispatches `ActiveWorkoutRestTimerNavigated()` (a new event that resets the flag to false).
4. SCR-17 (`RestTimerScreen`) is pushed on top of SCR-16. When Skip or expiry fires, SCR-17 pops itself (no result needed — the Bloc already advanced).
5. SCR-16 re-appears showing the already-advanced next set.

**Rationale**: Advancing state BEFORE navigation means SCR-16 is already in the correct position when SCR-17 is dismissed. No result-passing from SCR-17 is required. The `navigateToRestTimer` flag resets via an event immediately after navigation (same pattern as `navigateToPostWorkout` in SCR-16).

**Alternatives considered**:
- Advance set index AFTER SCR-17 returns — rejected: requires result-passing from `go_router.push()` return value or a separate Bloc event dispatch from SCR-17's pop callback; more complex and couples the screens.
- Use `go_router` route result / `pop(result)` — possible but adds unnecessary coupling for a one-directional advance.

---

## D-05: OS back gesture on SCR-17 = Skip

**Decision**: Wrap `RestTimerScreen` with `PopScope(canPop: false, onPopInvokedWithResult: (_, __) => context.read<RestTimerBloc>().add(RestTimerSkipped()))`. This intercepts swipe-back (iOS) and hardware back (Android) and dispatches `RestTimerSkipped`, which cancels the timer and emits `navigateBack: true`. The BlocListener then calls `context.pop()`.

**Rationale**: Identical pattern to SCR-16's OS back interception (research.md D-05 in SCR-16). `PopScope` is the current non-deprecated Flutter 3.12+ API. `canPop: false` prevents go_router from popping directly; the BlocListener-driven `context.pop()` is the controlled exit path.

**Alternatives considered**:
- Allow back gesture to silently pop — rejected: spec FR-007 requires back = Skip (advances workout state). A silent pop would leave `ActiveWorkoutBloc` thinking a rest is in progress.

---

## D-06: SCR-17 depends on unreleased SCR-16 code — additive contract amendments

**Decision**: SCR-17 requires two additive changes to the yet-to-be-implemented SCR-16 contracts:

1. **`ActiveWorkoutRunning` — 2 new fields** (amends SCR-16 `data-model.md`):
   - `navigateToRestTimer: bool` — defaults false; set true when rest should show.
   - `restPeriodSec: int` — defaults 0; holds the duration for SCR-17.

2. **`ActiveWorkoutBloc` — 1 new event** (`active_workout_event.dart`):
   - `ActiveWorkoutRestTimerNavigated` — fired by the screen after pushing SCR-17; resets the navigation flag.

Since SCR-16 is not yet implemented (application/ and presentation/ directories do not exist), these are additive changes to the planned contracts, not rework of shipped code. The SCR-17 implementation tasks cover both these additions and the new SCR-17 files.

**Rationale**: This is the minimum invasive change to SCR-16's planned contract. No SCR-16 domain or data layer files change. The `ActiveWorkoutBloc` logic change (check `restPeriodSec` after set completion) is a natural extension of the existing "set completed → advance" path.

---

## D-07: `RestTimerScreen` — thin presentation; single `BlocProvider` wrapping

**Decision**: `RestTimerScreen` is a `StatelessWidget` wrapped in `BlocProvider<RestTimerBloc>` at the route level. It:
1. Reads `restPeriodSec` from `GoRouterState.extra` (passed as `int`).
2. In the `BlocProvider.create` callback, immediately dispatches `RestTimerStarted(restPeriodSec: n)` so the timer begins before the first frame renders.
3. Uses a `BlocBuilder` for the countdown display and a `BlocListener` for the `navigateBack == true` signal (which calls `context.pop()`).
4. Shows one action button (Skip Rest) that dispatches `RestTimerSkipped`.

**Rationale**: A thin screen that delegates all timer logic to the Bloc. The `BlocProvider.create` + immediate event dispatch is the idiomatic approach (same as `ActiveWorkoutScreen` dispatching `ActiveWorkoutStarted` with the plan).

---

## D-08: `RestTimerBloc` — registered as `registerFactory` in GetIt

**Decision**: `getIt.registerFactory<RestTimerBloc>(() => RestTimerBloc())`. Factory registration (not singleton) because each rest period in a workout needs a fresh Bloc instance with its own timer.

**Rationale**: A singleton `RestTimerBloc` would retain state across rest periods. `registerFactory` creates a new instance per `getIt<RestTimerBloc>()` call, which happens each time the route is pushed. The Bloc is disposed when the `BlocProvider` is removed from the widget tree (route popped).
