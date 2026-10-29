# Quickstart: SCR-15 Workout Pre-Start / Overview

**Phase 1 — manual validation scenarios**

---

## Prerequisites

1. App builds and launches with no analyzer errors:
   ```bash
   cd forge && flutter analyze && flutter run
   ```
2. At least two workout plans exist in local Drift storage:
   - **Plan A** — "Push Day": 3 exercises (1 weighted, 1 bodyweight, 1 time-based)
   - **Plan B** — "Empty Plan": 0 exercises
3. Weekly Schedule has Push Day assigned to at least one weekday.
4. The test device date is known (for the "Today" meta-line scenario).

---

## Scenario 1: State A — Loading skeleton (US1, AC1)

**Entry**: From Plan Detail screen, tap "Start Workout."

**Expected**:
- Shimmer skeleton of exactly 3 cards appears immediately.
- App bar title is dimmed or shows "Overview."
- No "Begin Workout" button is visible.
- Skeleton animates (sweeps left-to-right or fades) until the plan loads.

**Pass criterion**: Skeleton visible; no button; no content flash before shimmer.

---

## Scenario 2: State B — Plan loaded (US1, AC2 + AC3)

**Entry**: From Plan Detail screen for Push Day → tap "Start Workout."

**Expected after load**:
- Hero section: plan name "Push Day" at large weight, exercise count meta.
- "EXERCISES" section label.
- 3 exercise cards in configured order.
  - Weighted exercise: lime dot (8×8 circle), 3-column grid (Sets / Reps / Weight).
    - If weight was set: numeric value + "kg" suffix.
    - If weight was not set: "—" displayed.
  - Bodyweight exercise: muted dot, 2-column grid (Sets / Reps).
  - Time-based exercise: cyan dot, 2-column grid (Sets / Duration as `MM:SS`).
- "Begin Workout" lime pill button pinned at bottom.

**Pass criterion**: Correct dot colors, correct column counts, correct field values, button visible.

---

## Scenario 3: FR-008 meta line — entered from Weekly Schedule (US1, FR-008)

**Entry**: From Weekly Schedule, tap Start on a weekday that is NOT today.

**Expected**: Meta line shows `"{weekday name} · {exercise count} exercises"` (no "Today").

**Entry**: From Weekly Schedule, tap Start on today's weekday.

**Expected**: Meta line shows `"{weekday name} · Today · {exercise count} exercises"`.

**Entry**: From Plan Detail screen (no weekday context).

**Expected**: Meta line shows only `"{exercise count} exercises"` (no weekday name, no "Today").

**Pass criterion**: All three variations correct per FR-008.

---

## Scenario 4: State C — Plan unavailable (US2, AC1 + AC2)

**Entry A**: Force-delete Push Day from storage while the app is on another screen, then open the overview via any entry point that references Push Day.

**Expected**: Full-screen centred state with alert-circle icon (danger color), "This plan is no longer available", "Back to Schedule" button. No "Begin Workout" button.

**Entry B**: Open the overview for Empty Plan (0 exercises).

**Expected**: Same centred blocked state as above (same wording, same button).

**Pass criterion**: Both conditions render identically; no crash; no "Begin Workout" visible.

---

## Scenario 5: State C — "Back to Schedule" always goes to weekly schedule (FR-006, Clarification)

**Entry**: Open the overview from Plan Detail for a deleted plan → blocked state → tap "Back to Schedule."

**Expected**: Navigation goes to Weekly Schedule screen, not Plan Detail.

**Entry**: Open the overview from Weekly Schedule for a deleted plan → blocked state → tap "Back to Schedule."

**Expected**: Navigation goes to Weekly Schedule screen.

**Pass criterion**: In both cases, destination is Weekly Schedule (FR-006 clarification confirmed 2026-09-23).

---

## Scenario 6: State D — Load failure and Retry (US3, AC1 + AC2)

**Trigger**: Simulate a Drift read failure (e.g., unavailable database during testing, or by injecting a mock in the Bloc test; for manual validation, force by temporarily replacing the data source to throw).

**Expected state D**:
- Full-screen centred error: calendar-error icon (danger color).
- Title: "Couldn't load this workout."
- Body: reassurance that data is safe + retry instruction.
- Two buttons: "Retry" (lime, primary) and "Back to Schedule" (secondary, cardAlt fill).

**Tap Retry**:
- Loading skeleton reappears.
- If the issue is cleared: resolves to State B (plan preview) or State C (unavailable).
- If issue persists: returns to State D.

**Pass criterion**: Wording is distinct from "plan unavailable"; Retry triggers re-load; both buttons work.

---

## Scenario 7: FR-009 — Rapid retry taps (US3, AC2 edge case)

**Trigger**: Tap Retry very quickly multiple times while skeleton is showing.

**Expected**: Only one Drift read completes; no duplicate state emissions; no UI flicker between two concurrent loads.

**Pass criterion**: Single load attempt per retry event sequence; state machine emits `PreStartLoading` once, then one terminal state.

---

## Scenario 8: App-bar back navigation (FR-006)

**Entry from Plan Detail**: Open overview → tap app-bar back (or swipe back on iOS).

**Expected**: Returns to Plan Detail screen. Nothing written to Drift.

**Entry from Weekly Schedule**: Open overview → tap app-bar back (or swipe back on iOS).

**Expected**: Returns to Weekly Schedule screen. Nothing written to Drift.

**Pass criterion**: Caller screen is correctly restored in both cases.

---

## Scenario 9: "Begin Workout" navigation stub (FR-003)

**Setup**: Plan is loaded successfully.

**Action**: Tap "Begin Workout."

**Expected**: Navigate to `/workout/active` route (SCR-16 stub screen showing "SCR-16 — Active Workout (coming soon)" or similar placeholder).

**Pass criterion**: Navigation fires; no crash; stub screen visible.

---

## Bloc unit test coverage (reference to `pre_start_bloc_test.dart`)

The following cases MUST have passing bloc_test scenarios:

| Scenario | Input event | Expected states emitted |
|---|---|---|
| Happy path — plan with exercises | `PreStartRequested(planId: 'p1', scheduledWeekday: null)` | `[PreStartLoading, PreStartLoaded(…)]` |
| Today weekday | `PreStartRequested(planId: 'p1', scheduledWeekday: DateTime.now().weekday)` | `[PreStartLoading, PreStartLoaded(isScheduledForToday: true)]` |
| Non-today weekday | `PreStartRequested(planId: 'p1', scheduledWeekday: otherWeekday)` | `[PreStartLoading, PreStartLoaded(isScheduledForToday: false)]` |
| Plan not found (null) | Use case returns `Right(null)` | `[PreStartLoading, PreStartUnavailable]` |
| Plan with empty exercises | Use case returns plan with `exercises: []` | `[PreStartLoading, PreStartUnavailable]` |
| Use case throws (Left) | Use case returns `Left(CacheException)` | `[PreStartLoading, PreStartError(…)]` |
| Retry after error | `PreStartRequested` → `PreStartError`, then `PreStartRetried` | `[…, PreStartLoading, PreStartLoaded(…)]` |
| FR-009 guard — rapid retry | `PreStartRequested` while loading | second event ignored; only one load |

---

## Running tests

```bash
cd forge
flutter test test/features/workout_plan/application/bloc/pre_start_bloc_test.dart
flutter test test/features/workout_plan/presentation/screens/pre_start_screen_test.dart
flutter test
```

All tests must pass with zero analyzer warnings:

```bash
flutter analyze
```
