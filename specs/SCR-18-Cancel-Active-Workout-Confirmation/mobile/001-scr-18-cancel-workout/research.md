# Research: SCR-18 Cancel Active Workout Confirmation

**Date**: 2026-09-23 | **Feature**: SCR-18 — Cancel Active Workout Confirmation

---

## D-01: Feature Ownership — `workout_session`

**Decision**: SCR-18 lives in the existing `workout_session` feature. No new feature directory.

**Rationale**: The cancel confirmation guards an in-progress workout session — a domain concern that belongs entirely to `workout_session`. The same feature owns `ActiveWorkoutBloc`, `ActiveWorkoutScreen`, and all session lifecycle logic. Splitting a dialog that directly manipulates `ActiveWorkoutBloc` into a new feature would violate the cross-feature import prohibition (Constitution §I.5).

**Alternatives considered**:
- New `cancel_workout` feature directory — rejected: creates an artificial split for what is a single guard step within one active session lifecycle.

---

## D-02: Presentation — Transparent Pushed Route, Not `showDialog()`

**Decision**: `CancelWorkoutScreen` is registered as a real `GoRoute` at `RoutePaths.cancelWorkout = '/workout/cancel'`, using `CustomTransitionPage` with `opaque: false` and `barrierColor: AppColors.scrimBarrier`. It replaces the existing SCR-16 stub screen at that path. `showDialog()` is NOT used.

**Rationale**: SCR-16's plan (D-05 in SCR-16 research.md) already committed to `context.push(RoutePaths.cancelWorkout)` from both the Cancel button path and the `PopScope`. The entry mechanism is a route push, not a dialog. A transparent pushed route (via `CustomTransitionPage(opaque: false)`) allows SCR-16 to remain visible in a dimmed state beneath SCR-18 — the same visual effect as an overlay dialog. This technique is idiomatic in go_router for "overlay screens" and requires no secondary routing mechanism.

`showDialog()` would work visually but conflicts with the established `context.push` entry design and does not support route-based navigation from `PopScope.onPopInvokedWithResult`.

**Implementation detail**: The `GoRoute.pageBuilder` returns:
```dart
CustomTransitionPage(
  key: state.pageKey,
  opaque: false,
  barrierColor: AppColors.scrimBarrier,
  child: const CancelWorkoutScreen(),
  transitionsBuilder: (_, animation, __, child) =>
      FadeTransition(opacity: animation, child: child),
)
```
`opaque: false` keeps SCR-16 rendered in the background. The scrim color (`rgba(10,10,10,.62)`) comes from the existing `AppColors.scrimBarrier` token — no new color needed.

**Alternatives considered**:
- `showDialog()` — rejected: inconsistent with SCR-16's established `context.push` entry pattern; PopScope integration is cleaner with a route.
- `go_router` `ShellRoute` overlay — rejected: unnecessary complexity for a simple confirmation overlay.

---

## D-03: No Dedicated Bloc for SCR-18

**Decision**: `CancelWorkoutScreen` is a `StatefulWidget` with a single `bool _isDiscarding = false` local state. No `CancelWorkoutBloc`, no use case.

**Rationale**: The discard operation has no business logic of its own — there is no Drift write, no async operation, and no error state to handle (see D-04). The only local state concern is disabling the "Discard Workout" button after the first tap to prevent double-fire (FR-011). This is a genuine local UI concern (CLAUDE.md §45 permits `setState()` for local UI state). Adding a Bloc for a one-flag state machine would violate CLAUDE.md rule 6 ("no speculative abstractions").

**Contrast with SCR-11**: `DeletePlanBloc` exists in SCR-11 because that feature has a real async Drift delete with loading, success, and failure states. SCR-18 has none of these.

**Alternatives considered**:
- `CancelWorkoutBloc` with states `CancelInitial`, `CancelDiscarding`, `CancelComplete` — rejected: overcomplicated for a no-op discard (navigate-only); would add a Bloc for a state machine that has no async work and no error recovery path.

---

## D-04: In-Progress Session Is In-Memory Only — No Drift Delete on Discard

**Decision**: Discarding a workout does NOT require a Drift operation. The in-progress session is held exclusively in `ActiveWorkoutBloc`'s in-memory state. "Discard" means navigating away without saving; the session disappears when `ActiveWorkoutBloc` is disposed.

**Rationale**: `WorkoutSessionLocalDataSourceImpl` (inspected at `forge/lib/features/workout_session/data/datasources/workout_session_local_data_source.dart`) only exposes operations on COMPLETED sessions in the `workout_sessions` table. There is no "in-progress session" Drift table, no `saveInProgressSession`, and no `deleteInProgressSession` API anywhere in the `workout_session` data layer. The active session data (exercises, sets, current index) lives entirely in `ActiveWorkoutBloc`'s fields, not in Drift.

**Consequence for FR-012**: The spec's "Drift delete operation fails" scenario cannot occur because no Drift delete is triggered on discard. FR-012's intent is still satisfied: if any unexpected error occurs during the discard path, navigate to SCR-06 anyway and log. In practice, `context.go(RoutePaths.home)` is synchronous and does not fail.

**Design spec discrepancy**: The design spec (`design/spec.md §4`) describes the discard as "workoutSession record deleted." This reflects the design-level intent (session is gone), not a literal Drift delete operation. The data layer confirms there is no in-progress stored record to delete.

**Alternatives considered**:
- Write session to Drift at session start, delete on discard — rejected: adds a Drift write on every workout start for a record that exists only to be potentially deleted; no design spec or domain model supports this.

---

## D-05: Discard Navigation — `context.go(RoutePaths.home)`

**Decision**: Tapping "Discard Workout" calls `context.go(RoutePaths.home)`. `RoutePaths.home = '/'`.

**Rationale**: `context.go()` replaces the entire navigation stack with the target route, clearing SCR-15 (Pre-Start), SCR-16 (Active Workout), and SCR-18 (Cancel Confirmation) in one operation. This satisfies FR-007 ("navigation stack MUST be cleared") and SC-004 ("user cannot return to discarded workout via any gesture"). `context.pop()` from SCR-18 would only return to SCR-16 — insufficient. `context.pushReplacement()` would retain the stack below SCR-16. `context.go()` is the correct go_router idiom for "replace everything with a known root route."

The go_router `StatefulShellRoute` at `/` (home tab) is the app shell; navigating to `/` lands on the Home tab (SCR-06) by default.

**Alternatives considered**:
- `context.pop()` then `context.go()` from SCR-16 — rejected: SCR-16 BlocListener cannot detect the discard without a Bloc event; adds unnecessary coordination.
- `context.popUntil()` — rejected: not a go_router API; only available in Navigator 1.0.

---

## D-06: SCR-16 Amendments — Filling the Pre-Designed Cancel Path

**Decision**: SCR-18 provides the following additive amendments to the SCR-16 files (these fill in the cancel path that SCR-16's data model pre-designed but left stubbed):

1. **`active_workout_event.dart`** — add two new event classes:
   - `ActiveWorkoutCancelRequested` (dispatched by Cancel button and PopScope in `ActiveWorkoutScreen`)
   - `ActiveWorkoutCancelNavigated` (dispatched by BlocListener after pushing SCR-18 to reset the navigation flag)

2. **`active_workout_bloc.dart`** — add two handlers:
   - `on<ActiveWorkoutCancelRequested>`: emits `(state as ActiveWorkoutRunning).copyWith(navigateToCancel: true)`; guard: only if `state is ActiveWorkoutRunning`
   - `on<ActiveWorkoutCancelNavigated>`: emits `copyWith(navigateToCancel: false)`

3. **`active_workout_screen.dart`** — three amendments:
   - BlocListener: add branch `if (state.navigateToCancel) { context.push(RoutePaths.cancelWorkout); context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelNavigated()); }`
   - Cancel button `onPressed`: change from `context.push(RoutePaths.cancelWorkout)` (the SCR-16 stub) to `context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelRequested())`
   - PopScope `onPopInvokedWithResult`: change from `context.push(RoutePaths.cancelWorkout)` (the SCR-16 stub) to `context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelRequested())`

**Rationale**: The SCR-16 data model explicitly has `navigateToCancel: bool` with "BlocListener routes to SCR-18" — the event and handler filling that intent are the natural completion of that design. The existing stub implementations in SCR-16 (which directly called `context.push`) are upgraded to the full Bloc-mediated pattern for consistency with `navigateToRestTimer` (SCR-17) and `navigateToPostWorkout`.

**Alternatives considered**:
- Cancel button and PopScope continue calling `context.push` directly — rejected: leaves `navigateToCancel` as a dead state field; inconsistent with the other navigation flags' patterns.

---

## D-07: AppStrings — New SCR-18 Section

**Decision**: Add a dedicated SCR-18 section to `forge/lib/core/strings/app_strings.dart`:

```dart
// SCR-18: Cancel Active Workout Confirmation
static const String cancelWorkoutTitle = 'Cancel this workout?';
static const String cancelWorkoutSubtitle =
    "Your progress won't be saved. "
    "This session won't appear in your workout history.";
static const String cancelWorkoutKeepGoingButton = 'Keep Going';
static const String cancelWorkoutDiscardButton = 'Discard Workout';
```

**Rationale**: Body copy confirmed from the design spec §3. "Keep Going" and "Discard Workout" are confirmed from the design spec OQ-5/OQ-6 assumptions ("treat as final unless corrected"). Distinct string keys are needed because SCR-16 already has `activeWorkoutCancelButton = 'Cancel'` (for the app bar Cancel link) — separate keys prevent naming conflicts. The subtitle is a two-sentence string constant matching the design spec copy exactly.

The existing `cancelWorkoutStubLabel` constant added by SCR-16 can be removed once the stub screen is replaced.

---

## D-08: AppColors — No New Tokens Required

**Decision**: All required color tokens already exist in `AppColors`. No additions needed.

**Token mapping**:
| Design token | `AppColors` constant | Status |
|---|---|---|
| `rgba(10,10,10,.62)` scrim | `AppColors.scrimBarrier` | ✅ Exists |
| `#201f22` card (dialog bg) | `AppColors.card` | ✅ Exists |
| `#2a2a2c` card-alt (Keep Going bg) | `AppColors.cardAlt` | ✅ Exists |
| `#444933` border (Keep Going border) | `AppColors.border` | ✅ Exists |
| `#f5f6f1` white (Keep Going text) | `AppColors.white` | ✅ Exists |
| `#ff6b6b` danger (Discard bg) | `AppColors.danger` | ✅ Exists |
| `#2a1414` on-danger (Discard text) | `AppColors.onDanger` | ✅ Exists (added in SCR-11) |
| `#2a1f1f` dangerBg (icon wrap bg) | `AppColors.dangerBg` | ✅ Exists |

`AppColors.onDanger` (added during SCR-11 research D-04) covers the `#2a1010` / `#2a1414` danger text color. No new color token needed for SCR-18.
