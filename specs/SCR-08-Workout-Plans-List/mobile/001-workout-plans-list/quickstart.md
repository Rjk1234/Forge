# Quickstart Validation Guide: SCR-08 Workout Plans List

**Branch**: `001-workout-plans-list` | **Date**: 2026-09-17

**Purpose**: Runnable validation scenarios that confirm SCR-08 works end-to-end. These scenarios are for manual testing on a simulator/device and for structuring widget tests.

**References**:
- Spec: [spec.md](spec.md)
- Data model: [data-model.md](data-model.md)

---

## Prerequisites

1. App is running in debug mode on iOS Simulator or Android Emulator.
2. The user is logged in (app-lock is unlocked).
3. The `workout_plans` table is open (registered in `workout_plans` table).
4. `WorkoutPlansBloc` is registered in GetIt and provided at the Plans route.

---

## VS-01 — Loading Skeleton Appears Immediately

**Setup**: Navigate away from the Plans tab. Artificially delay the database read in `WorkoutPlanLocalDataSource.getAllPlans()` by 500 ms (debug only).

**Steps**:
1. Tap the Plans tab (second tab in bottom nav bar).

**Expected**:
- Within 1 frame: 4 skeleton plan cards with shimmer animation visible.
- A skeleton FAB placeholder appears in the top-right of the app bar (filled rectangle, no icon).
- Bottom nav bar remains fully visible; Plans tab icon is lime-coloured (active).

---

## VS-02 — Populated State: Plans Visible Newest-First

**Setup**: Seed `workout_plans` table with 3 plans created at times T1 < T2 < T3 (T3 is most recent). Plan A (T1): "Push Day", 3 exercises. Plan B (T2): "Pull Day", 5 exercises. Plan C (T3): "Leg Day", 7 exercises.

**Steps**:
1. Tap the Plans tab.

**Expected**:
- After skeleton resolves: list shows Plan C ("Leg Day") first, Plan B ("Pull Day") second, Plan A ("Push Day") third.
- Each card: plan name in bold white, "N exercises" in muted text below, right-pointing chevron.
- Lime "+" FAB visible in app bar top-right (38 × 38 pt, lime fill).
- "Workout Plans" title in app bar.

---

## VS-03 — Empty State

**Setup**: Ensure `workout_plans` table is empty.

**Steps**:
1. Tap the Plans tab.

**Expected**:
- After skeleton resolves: centred empty state with list icon, "No workout plans yet" title, "Build your first workout plan to see it listed here." subtitle.
- Lime "Create a workout plan" button below the subtitle.
- **No "+" FAB** in the app bar.

---

## VS-04 — "Create a workout plan" CTA Navigation

**Setup**: Empty `workout_plans` table (VS-03 state).

**Steps**:
1. Tap "Create a workout plan" button.

**Expected**:
- Navigates to SCR-09 (Create / Edit Workout Plan) in create mode (slide-left transition).
- Back button on SCR-09 returns to Plans list.

---

## VS-05 — "+" FAB Navigation

**Setup**: At least one plan in `workout_plans` table (VS-02 state).

**Steps**:
1. Tap the lime "+" FAB in the app bar.

**Expected**:
- Navigates to SCR-09 (Create / Edit Workout Plan) in create mode.

---

## VS-06 — Plan Card Tap → Plan Detail

**Setup**: At least one plan in `workout_plans` table (VS-02 state).

**Steps**:
1. Tap the "Push Day" plan card anywhere on the row.

**Expected**:
- Navigates to SCR-10 (Plan Detail) with "Push Day" plan data (slide-left transition).
- Back button on SCR-10 returns to Plans list.

---

## VS-07 — Error State + Retry

**Setup**: Simulate a database read failure (e.g., mock `getAllPlans()` to throw `CacheException`).

**Steps**:
1. Tap the Plans tab.

**Expected after skeleton**:
- Error card with danger border: warning icon, "Couldn't load your workout plans" title, "Something went wrong reading local data.\nYour history is unaffected." body.
- Lime "Retry" button inside the error card.
- No "+" FAB.

**Steps (continued)**:
2. Tap "Retry".

**Expected**:
- Returns to skeleton loading state while re-read runs.
- If retry succeeds: transitions to populated or empty state.
- If retry fails: error card reappears (same copy, no escalation).

---

## VS-08 — Singular Exercise Count ("1 exercise")

**Setup**: Seed one plan with exactly 1 exercise.

**Steps**:
1. Tap the Plans tab and wait for populated state.

**Expected**:
- Plan card shows "1 exercise" (singular), not "1 exercises".

---

## VS-09 — Optimistic Re-Read on Tab Return

**Setup**: Plans list is loaded showing 3 plans (VS-02 state).

**Steps**:
1. Tap the "+" FAB to navigate to SCR-09.
2. Immediately tap the back button on SCR-09 to return to Plans without creating a plan.

**Expected**:
- While returning to Plans tab: the existing 3-plan list remains visible (no skeleton flash).
- The list silently updates if plans changed (should be unchanged in this scenario).

---

## VS-10 — New Plan Appears After Creation

**Setup**: Plans list is loaded showing 1 plan ("Push Day"). A second plan has been created in SCR-09.

**Steps**:
1. Navigate to SCR-09 and create "Leg Day" (3 exercises).
2. Return to Plans tab.

**Expected**:
- "Leg Day" (the newly created plan) appears at the **top** of the list (newest-first sort).
- "Push Day" appears below it.
- No skeleton flash during the re-read.

---

## VS-11 — Long Plan Name Truncated

**Setup**: Seed one plan with a very long name: "This Is A Very Long Plan Name That Should Truncate With An Ellipsis At The End Of The Line".

**Steps**:
1. Tap the Plans tab.

**Expected**:
- Plan name is rendered on 1 line only, truncated with a trailing ellipsis (…).
- The exercise count and chevron remain visible on the right.

---

## Running Widget Tests

```bash
cd forge
flutter test test/features/workout_plan/
```

Expected: all tests pass. If the full suite is run:

```bash
flutter test
```

No regressions in SCR-07 (exercise catalogue) or home feature tests.
