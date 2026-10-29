# Quickstart Validation Guide: SCR-21 Workout History Detail

**Date**: 2026-09-23 | **Branch**: `001-scr-21-workout-history-detail`

---

## Prerequisites

- SCR-20 WorkoutHistoryScreen is implemented (or stubbed) so the history list is reachable
- At least one completed `WorkoutSession` record is seeded in the Drift `workout_sessions` table
- App running on simulator or device

---

## Scenario 1 — Skeleton on entry, then full detail (US1, SC-001, SC-002)

**Setup**: Seed one completed session with two exercises — one `weighted` (4 sets) and one `timeBased` (3 sets).

**Steps**:
1. Navigate to the History tab.
2. Tap the session row for the seeded session.

**Expected**:
- Detail screen pushes with slide-in animation.
- Skeleton is visible immediately — no blank frame.
- Skeleton resolves to the Main state.
- Hero section shows: workout name (from `planName`), date/time formatted as `"Ddd, Mon D, YYYY · H:MM AM/PM"` (e.g. "Mon, Sep 7, 2026 · 6:42 PM").
- Stat row shows three boxes: "DURATION" (`{N} min`), "EXERCISES" (`2`), "SETS LOGGED" (`7`).
- Section label "Performance" appears.
- Two exercise cards appear in order — each with a type-dot, exercise name, set count tag, and set pills.
- Weighted exercise pills show `{reps}×{weight}kg` format.
- Time exercise pills show `MM:SS` format.
- No edit or delete controls visible anywhere.

---

## Scenario 2 — Bodyweight and skipped sets (US1 AC6–7)

**Setup**: Seed a session with one `bodyweight` exercise and one `weighted` exercise with one skipped set.

**Steps**:
1. Open the detail screen for this session.

**Expected**:
- Bodyweight exercise pills show `{reps} reps` format.
- Skipped set pill shows "Skipped" with strikethrough text and dim colour; NOT the reps format.
- "SETS LOGGED" count includes the skipped slot.

---

## Scenario 3 — Error state and retry (US2, SC-004)

**Setup**: Mock `WorkoutSessionRepository` to return `Left(CacheException)` from `getSessionById`.

**Steps**:
1. Navigate to the detail screen.
2. Observe the Loading skeleton, then the Error state.
3. Tap "Retry".
4. Observe the skeleton reappears.
5. Restore the mock to return a valid session.
6. Observe the Main state.

**Expected**:
- Error card shows title "Couldn't load this workout", body "Something went wrong reading local data. Your workout history is unaffected.", and a "Retry" button.
- After Retry: skeleton appears → Main state.
- Raw exception message is NOT shown to the user.

---

## Scenario 4 — Double-tap Retry debounce (US2 AC5)

**Setup**: Mock repository with a slow `getSessionById` (simulated delay).

**Steps**:
1. Navigate to the detail screen → Error state.
2. Tap Retry rapidly twice.

**Expected**:
- Only one Drift read is triggered (debounce prevents double-tap).
- No duplicate state emissions or flickering.

---

## Scenario 5 — Historical integrity after plan edit (US3, SC-003)

**Setup**: Complete a workout for plan "Push Day A". Then rename the plan to "Push Day" and remove one exercise.

**Steps**:
1. Navigate to the history list.
2. Tap the session completed before the plan edit.

**Expected**:
- Hero name shows "Push Day A" (original snapshot).
- The removed exercise still appears in the exercise list.
- No data from the current plan state is shown.

---

## Scenario 6 — Zero-exercise session (Edge case, FR-017)

**Setup**: Seed a session with no exercises (zero `sessionExercises`).

**Steps**:
1. Open the detail screen for this session.

**Expected**:
- Main state is shown (not an error or empty state).
- Stat row shows "EXERCISES: 0", "SETS LOGGED: 0".
- "Performance" section label appears.
- No exercise cards appear below the label.
- No crash or overflow error.

---

## Scenario 7 — Back navigation (FR-013)

**Setup**: History list with at least one session.

**Steps**:
1. Open the detail screen.
2. Press the back arrow (or Android system back).

**Expected**:
- Screen pops; history list (SCR-20) is restored without re-fetching.
- No loading skeleton appears on SCR-20 on return (FR-011 / StatefulShellRoute behaviour).

---

## Unit Test Checklist (WorkoutHistoryDetailBloc)

- [ ] Initial state is `WorkoutHistoryDetailInitial`
- [ ] `WorkoutHistoryDetailLoadRequested` emits `[Loading, ...]` — Loading always first
- [ ] Use case returns `Right(session)` → emits `WorkoutHistoryDetailSuccess(session)`
- [ ] Use case returns `Left(exception)` → emits `WorkoutHistoryDetailError(message)` (not Success)
- [ ] Retry: second `WorkoutHistoryDetailLoadRequested` resets to Loading then resolves
- [ ] Raw exception message does NOT appear in the error state's `message` field (uses `AppStrings.detailErrorTitle`)

## Unit Test Checklist (GetWorkoutHistoryDetailUseCase)

- [ ] `Right(session)` → `Right(session)` (pass-through)
- [ ] `Right(null)` → `Left(CacheException)` (missing session treated as failure)
- [ ] `Left(exception)` → `Left(exception)` (pass-through)

## Widget Test Checklist (WorkoutHistoryDetailScreen)

- [ ] `WorkoutHistoryDetailInitial` → `DetailSkeleton` visible
- [ ] `WorkoutHistoryDetailLoading` → `DetailSkeleton` visible
- [ ] `WorkoutHistoryDetailSuccess` → hero name, stat row, "Performance" label, exercise cards visible
- [ ] `WorkoutHistoryDetailError` → error title, error body, Retry button visible; skeleton not shown
- [ ] Tapping Retry → `WorkoutHistoryDetailLoadRequested` event fired with correct `sessionId`
- [ ] Weighted exercise pills show `{reps}×{weight}kg` format
- [ ] Bodyweight exercise pills show `{reps} reps` format
- [ ] Time exercise pills show `MM:SS` format
- [ ] Skipped set shows "Skipped" with strikethrough (SCR-16 guard: treat absent `skipped` as false)
