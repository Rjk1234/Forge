# Quickstart Validation Guide: SCR-18 Cancel Active Workout Confirmation

**Date**: 2026-09-23 | **Feature**: SCR-18

---

## Prerequisites

- SCR-15 (Pre-Start) and SCR-16 (Active Workout) fully implemented and passing
- `RoutePaths.cancelWorkout = '/workout/cancel'` defined in `app_routes.dart` (from SCR-16 data model)
- `AppColors.scrimBarrier` exists in `app_colors.dart` (confirmed)
- `flutter test` passes with no regressions on SCR-16 tests before starting

---

## Run Commands

```bash
# Unit tests (Bloc amendments)
flutter test test/features/workout_session/application/bloc/active_workout_bloc_test.dart

# Widget tests (CancelWorkoutScreen)
flutter test test/features/workout_session/presentation/screens/cancel_workout_screen_test.dart

# Analyzer (no new warnings)
flutter analyze forge/lib/features/workout_session/

# Format
dart format forge/lib/features/workout_session/
```

---

## Validation Scenarios

### Scenario 1 — Cancel Button Triggers Modal (US1, FR-001, SC-001)

**Setup**: Active workout with ≥1 set logged (use a plan with exercises).

**Steps**:
1. Navigate to SCR-16 (active workout screen).
2. Tap the Cancel button in the app bar.

**Expected**:
- `CancelWorkoutScreen` appears as a transparent overlay.
- SCR-16 is still visible in a dimmed state behind the modal.
- Modal shows the title `'Cancel this workout?'`, the active plan name (FR-003), and the subtitle warning about no save and no history entry.
- Two buttons visible: `'Keep Going'` and `'Discard Workout'`.

**Verify**: `ActiveWorkoutBloc` emitted `navigateToCancel: true`; BlocListener pushed `/workout/cancel`.

---

### Scenario 2 — Keep Going Restores Workout State (US1, FR-005, SC-002)

**Setup**: Active workout with specific set values logged (e.g., Exercise 2, Set 3, weight `80kg`).

**Steps**:
1. Trigger Cancel (app bar) → SCR-18 appears.
2. Tap `'Keep Going'`.

**Expected**:
- SCR-18 is dismissed.
- SCR-16 shows the **exact same** exercise (Exercise 2), set index (Set 3), and field values (weight `80kg`) as before the modal appeared.
- No state reset. No page scroll change.
- `ActiveWorkoutBloc.state.navigateToCancel` is `false`.

---

### Scenario 3 — Discard Workout Clears Stack (US1, FR-006, FR-007, SC-003, SC-004)

**Setup**: Active workout with ≥1 set logged.

**Steps**:
1. Trigger Cancel → SCR-18 appears.
2. Tap `'Discard Workout'`.

**Expected**:
- User lands on SCR-06 (Home Dashboard).
- Navigation stack is empty — no back gesture returns to SCR-16 or SCR-18.
- The discarded workout does NOT appear in workout history.
- `ActiveWorkoutBloc` is disposed (widget tree no longer contains it).

**Verify**: `Navigator.canPop(context)` on Home returns `false` (no back entry).

---

### Scenario 4 — OS Back Gesture Triggers Modal (US2, FR-002, SC-001)

**Setup**: Active workout in progress.

**Steps**:
1. While on SCR-16, trigger OS back gesture (iOS: swipe from left edge; Android: hardware back).

**Expected**:
- SCR-18 `CancelWorkoutScreen` appears — same modal as Cancel button path.
- SCR-16 is NOT popped silently.
- Workout state is preserved behind the modal.

**Verify**: `PopScope.canPop = false` is respected; `ActiveWorkoutCancelRequested` was dispatched.

---

### Scenario 5 — Scrim Tap Dismisses Modal as Keep Going (US2, FR-008)

**Setup**: SCR-18 is open.

**Steps**:
1. Tap anywhere outside the modal card (on the dimmed scrim area).

**Expected**:
- Modal is dismissed.
- SCR-16 resumes with no state change.
- Same behaviour as "Keep Going".

---

### Scenario 6 — OS Back While Modal Open = Keep Going (US2, FR-009)

**Setup**: SCR-18 is open.

**Steps**:
1. Trigger OS back gesture while SCR-18 is the active screen.

**Expected**:
- Modal is dismissed.
- SCR-16 resumes with no state change.
- The workout is NOT discarded.

**Verify**: `PopScope` in `CancelWorkoutScreen` (`canPop: false`, `onPopInvokedWithResult → _handleKeepGoing`).

---

### Scenario 7 — Double-Tap Guard on Discard Button (FR-011)

**Steps**:
1. SCR-18 open → tap `'Discard Workout'` twice rapidly.

**Expected**:
- Navigation to home occurs exactly once.
- After the first tap, the Discard button is visually disabled.
- No duplicate navigation event.

---

### Scenario 8 — Zero Sets Logged (Edge Case)

**Setup**: Active workout with 0 sets logged.

**Steps**:
1. Trigger Cancel immediately after starting the workout.

**Expected**:
- SCR-18 appears normally (same modal, same copy).
- Tapping `'Discard Workout'` navigates to home.
- No crash or error from an empty session state.

---

### Scenario 9 — Repeated Cancel/Keep Going Cycles (Regression)

**Steps**:
1. Trigger Cancel → Keep Going → (log a set) → Trigger Cancel again → Discard.

**Expected**:
- Each cancel cycle opens SCR-18 cleanly.
- `navigateToCancel` resets to `false` after each keep-going.
- Final discard navigates to home correctly.

---

## Bloc Unit Test Checklist

Confirm these scenarios pass in `active_workout_bloc_test.dart`:

- [ ] `CancelRequested` when state is `ActiveWorkoutRunning` → emits `navigateToCancel: true`
- [ ] `CancelNavigated` after `CancelRequested` → emits `navigateToCancel: false`
- [ ] `CancelRequested` when state is NOT `ActiveWorkoutRunning` → no state change
- [ ] Repeated `CancelRequested` / `CancelNavigated` cycle → flag alternates correctly

## Widget Test Checklist

Confirm these scenarios pass in `cancel_workout_screen_test.dart`:

- [ ] Screen renders with correct title, plan name (FR-003), subtitle, and both buttons
- [ ] `'Keep Going'` tap calls `context.pop()`
- [ ] `'Discard Workout'` tap calls `context.go('/')`
- [ ] After Discard tap, button is disabled (no `onPressed`)
- [ ] OS back gesture while screen is open → `_handleKeepGoing` (no discard)
- [ ] Scrim area tap → `_handleKeepGoing` (no discard)
- [ ] Double-tap on Discard → only one navigation
- [ ] Empty `planName` renders without crash or overflow
