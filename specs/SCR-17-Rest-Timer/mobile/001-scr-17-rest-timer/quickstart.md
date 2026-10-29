# Quickstart Validation Guide: SCR-17 Rest Timer

**Prerequisites**: SCR-16 Active Workout must be implemented first (application/ and presentation/ layers of `workout_session` must exist). A workout plan with at least 2 sets per exercise and a configured rest period (`restPeriodSec > 0`) must be seeded in Drift.

---

## Scenario 1 — Auto-start and natural expiry

**Setup**: Plan with Exercise A — 2 sets, `restPeriodSec = 5` (use 5 seconds for fast testing).

**Steps**:
1. Navigate to SCR-15 (Pre-Start), select the plan, enter SCR-16.
2. Enter valid values for Set 1 of Exercise A. Tap **Complete Set**.

**Expected**:
- SCR-17 (Rest Timer) opens immediately — no manual action required.
- Countdown displays `0:05` in MM:SS format and begins ticking immediately.
- **Skip Rest** button is visible and tappable.
- After 5 seconds the countdown reaches `0:00` and SCR-17 closes automatically.
- SCR-16 is shown with Set 2 of Exercise A already active.

**Verify**: No user action was required to advance from SCR-17 to the next set.

---

## Scenario 2 — Skip rest early

**Setup**: Same plan as Scenario 1, `restPeriodSec = 90`.

**Steps**:
1. Complete Set 1 of Exercise A. SCR-17 opens with countdown `1:30`.
2. Immediately tap **Skip Rest**.

**Expected**:
- SCR-17 closes instantly (before reaching 0).
- SCR-16 shows Set 2 of Exercise A.

**Verify**: SCR-16 is at the correct next set; SCR-17 does not linger.

---

## Scenario 3 — OS back gesture = Skip

**Setup**: Same plan, `restPeriodSec = 90`.

**Steps**:
1. Complete Set 1. SCR-17 opens.
2. Perform iOS swipe-back or Android hardware back.

**Expected**:
- SCR-17 closes (does NOT navigate back to a stale state of SCR-16 without advancing).
- SCR-16 shows Set 2 (the next set) — identical outcome to Scenario 2.

---

## Scenario 4 — Zero rest period bypass

**Setup**: Plan with Exercise B — 2 sets, `restPeriodSec = 0`.

**Steps**:
1. Enter SCR-16 with this plan. Complete Set 1 of Exercise B.

**Expected**:
- SCR-17 does NOT appear.
- SCR-16 advances directly to Set 2 of Exercise B.

---

## Scenario 5 — Rest timer after last set of a non-last exercise

**Setup**: Plan with Exercise A (2 sets, `restPeriodSec = 5`) and Exercise B (2 sets, `restPeriodSec = 10`).

**Steps**:
1. Complete Set 1 of Exercise A → SCR-17 shows 5s. Skip.
2. Complete Set 2 (last set) of Exercise A → SCR-17 shows 5s. Skip.
3. SCR-16 now shows Exercise B, Set 1.

**Expected**: Rest timer appears after EACH set of Exercise A (including the last set of that exercise) because Exercise B still remains. SCR-17 does not appear after Set 2 of Exercise B (last set of last exercise — Finish flow runs instead).

---

## Scenario 6 — No Pause button on rest timer screen

**Setup**: Any plan with `restPeriodSec > 0`.

**Steps**:
1. Complete a set. SCR-17 opens.
2. Inspect the screen for any Pause button.

**Expected**: No Pause button is visible. Only **Skip Rest** is present.

---

## Bloc unit test commands

```bash
flutter test test/features/workout_session/application/bloc/rest_timer_bloc_test.dart
flutter test test/features/workout_session/presentation/screens/rest_timer_screen_test.dart
flutter test test/features/workout_session/application/bloc/active_workout_bloc_test.dart
```

All tests must pass with zero analyzer warnings:

```bash
flutter analyze forge/lib/features/workout_session/
```
