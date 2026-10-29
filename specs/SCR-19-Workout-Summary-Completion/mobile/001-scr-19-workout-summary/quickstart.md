# Quickstart Validation Guide: SCR-19 Workout Summary & Completion

**Date**: 2026-09-23 | **Feature**: SCR-19

---

## Prerequisites

- SCR-16 (Active Workout), SCR-17 (Rest Timer), and SCR-18 (Cancel Confirmation)
  fully implemented and passing — SCR-19 depends on:
  - `ActiveWorkoutBloc._prepareFinish` (SCR-19 amendment to SCR-16)
  - `WorkoutSession.startedAt` (SCR-16 data-model amendment)
  - `ActualSet.skipped: bool` (SCR-16 data-model amendment)
  - `RoutePaths.postWorkout` route stub (SCR-16 tasks)
- `WorkoutSummaryBloc` registered in `get_it_setup.dart`
- `AppColors.successBg` added to `app_colors.dart`
- `flutter test` passes with no regressions on SCR-16/17/18 before starting

---

## Run Commands

```bash
# Bloc unit tests
flutter test test/features/workout_session/application/bloc/workout_summary_bloc_test.dart

# Screen widget tests
flutter test test/features/workout_session/presentation/screens/workout_summary_screen_test.dart

# Active workout Bloc amendment tests
flutter test test/features/workout_session/application/bloc/active_workout_bloc_test.dart

# Analyzer
flutter analyze forge/lib/features/workout_session/
flutter analyze forge/lib/config/routes/app_routes.dart
flutter analyze forge/lib/core/theme/app_colors.dart

# Format
dart format forge/lib/features/workout_session/
```

---

## Validation Scenarios

### Scenario 1 — Happy Path: Loading to Summary (US1, FR-001–007, SC-001, SC-003)

**Setup**: Active workout with at least 2 exercises; at least one set logged per
exercise; at least one set skipped.

**Steps**:
1. Navigate to SCR-16 (active workout).
2. Log at least one set per exercise; skip at least one set.
3. Advance through all exercises until Finish triggers.

**Expected**:
- Loading state appears immediately: Finish button shows spinner and "Saving Workout…"
  text; Cancel link is suppressed.
- After save: summary screen replaces SCR-16 on the stack.
- Summary shows: plan name, session start date/time (not Finish time), duration in
  minutes, `{N} Sets` (non-skipped only), `{M} Exercises` (all in plan).
- Exercise breakdown shows all exercises in session order.
- Each exercise shows name, type indicator chip, and one pill per set:
  weighted → `{reps}×{weight}kg`, bodyweight → `{reps} reps`,
  time → `MM:SS`, skipped → "Skipped" with muted strikethrough.

**Verify**: Back gesture on summary does nothing (FR-013).

---

### Scenario 2 — All Sets Skipped (Edge Case, FR-003, SC-001)

**Setup**: Active workout; skip every set on every exercise.

**Steps**:
1. Skip every set until Finish triggers.

**Expected**:
- Loading state appears.
- Summary shows: Sets = 0, all exercise cards show only Skipped pills.
- Session is still saved (completion criterion: ≥1 exercise with ≥1 set).

Wait — verify the completion criterion. `WorkoutSessionRepositoryImpl._meetsCompletionCriterion`
checks `session.sessionExercises.any((e) => e.actualSets.isNotEmpty)`. A fully
skipped session still has `actualSets` entries (each skipped set is an `ActualSet`
with `skipped: true`). So the criterion passes and the session is saved.

---

### Scenario 3 — Done Navigation Clears Stack (US1, FR-012, SC-004)

**Steps** (from summary screen):
1. Tap "Done".

**Expected**:
- User lands on Home (SCR-06).
- No back gesture returns to summary or active workout.
- `Navigator.canPop(context)` on Home returns false.

---

### Scenario 4 — View History Keeps Summary on Stack (US1, FR-012, US3-AC-2)

**Steps** (from summary screen):
1. Tap "View History".

**Expected**:
- SCR-20 (Workout History) opens on top of the summary.
- Navigating back from SCR-20 returns to the summary (read-only, unchanged).
- Back gesture on the summary (below SCR-20) is still blocked.

---

### Scenario 5 — Save Failure Shows Error State (US2, FR-008–010)

**Setup**: Mock `WorkoutSessionRepository.saveSession` to return a `Left(CacheException(...))`.

**Steps**:
1. Tap Finish on SCR-16.

**Expected**:
- Loading state appears briefly.
- Error state displays: plan name, failure title, reassurance message, Retry button.
- OS back gesture on error state does nothing (FR-014).
- No navigation away from error state except via Retry.

---

### Scenario 6 — Retry Succeeds (US2, FR-010, SC-002)

**Setup**: Mock first save call to fail, second to succeed.

**Steps**:
1. Trigger save failure (Scenario 5).
2. Tap Retry.

**Expected**:
- Loading state reappears.
- Summary displays on second save success.
- Exactly ONE session record in workout history (dedup guard ensures no duplicate).

---

### Scenario 7 — Dedup Guard Prevents Duplicate on Retry (US2, FR-011, SC-002)

**Setup**: Mock first save call to "fail" (return Left) BUT the underlying Drift
write actually succeeded before the error was returned (simulate ambiguous failure).
Seed `workout_sessions` table with the session already present.

**Steps**:
1. Trigger Retry after error.

**Expected**:
- `getSessionById` returns the existing session.
- No second write occurs.
- Summary displayed (using the existing session record).

---

### Scenario 8 — Retry Double-Tap Guard (US2, FR-015)

**Steps**:
1. Error state open → tap Retry twice rapidly.

**Expected**:
- Retry button becomes non-interactive on first tap.
- Only one `WorkoutSummaryRetryRequested` event is dispatched.
- One write attempt made.

---

### Scenario 9 — Back Blocked on Summary (US3, FR-013)

**Steps**:
1. Summary displayed.
2. Trigger OS back (iOS: swipe from left edge; Android: hardware back).

**Expected**: Summary remains; no navigation occurs.

---

### Scenario 10 — Active Workout Regression: Finish No Longer Saves in SCR-16

**Verify**: `ActiveWorkoutBloc` unit tests confirm `_prepareFinish` emits
`navigateToPostWorkout: true` WITHOUT calling a repository. No `writeError`
is emitted. `ActiveWorkoutRetryFinishRequested` handling is absent.

---

## Bloc Unit Test Checklist

Confirm in `workout_summary_bloc_test.dart`:

- [ ] `Started(session)` → emits `Loading(planName)` → emits `Success` (dedup miss + save OK)
- [ ] `Started(session)` → emits `Loading` → emits `Error` (dedup miss + save fail)
- [ ] `Started(session)` when `getSessionById` returns existing session → emits `Success` without writing
- [ ] `RetryRequested` from `Error` → emits `Loading` → re-attempts save → `Success`
- [ ] `RetryRequested` from `Error` → emits `Loading` → re-attempts save → `Error` again
- [ ] `RetryRequested` from `Error` → dedup finds session → `Success` (no write)
- [ ] `_session` retained across retry (same session ID on each attempt)

## Widget Test Checklist

Confirm in `workout_summary_screen_test.dart`:

- [ ] Loading state: shows plan name, loading indicator, "Saving Workout…" text; back gesture has no effect
- [ ] Success state: shows plan name, formatted start date/time, duration suffix "min", Sets count (non-skipped), Exercises count (all)
- [ ] Success state: exercise breakdown shows all exercises with correct set pills
- [ ] Skipped pill renders "Skipped" with strikethrough styling
- [ ] Done tap calls `context.go(RoutePaths.home)` (clears stack)
- [ ] View History tap calls `context.push(RoutePaths.workoutHistory)`
- [ ] Error state: shows plan name, error title, error message, Retry button
- [ ] Error state: back gesture has no effect (FR-014)
- [ ] Retry tap dispatches `WorkoutSummaryRetryRequested`; button becomes non-interactive
- [ ] Double Retry tap only dispatches one event
