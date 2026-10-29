# Quickstart: SCR-16 Active Workout

**Phase 1 — manual validation scenarios**

---

## Prerequisites

1. App builds and launches with no analyzer errors:
   ```bash
   cd forge && flutter analyze && flutter run
   ```
2. At least one workout plan exists in Drift with the following exercises in order:
   - **Exercise 1 (Weighted)**: "Bench Press" — 3 sets, 10 reps target, 80 kg target
   - **Exercise 2 (Bodyweight)**: "Push-Up" — 2 sets, 15 reps target
   - **Exercise 3 (Time-based)**: "Plank" — 2 sets, 60 sec target
3. The `/workout/active` route is wired and the `ActiveWorkoutBloc` is registered in GetIt.
4. The SCR-18 and SCR-19 stub routes (`/workout/cancel`, `/workout/summary`) are wired.
5. Navigate to this screen via SCR-15's "Begin Workout" button — the `WorkoutPlanDetail` is passed as route `extra`.

---

## Scenario 1: Screen opens at first exercise, first set (FR-001, US1 AC1)

**Entry**: Tap "Begin Workout" on the SCR-15 pre-start screen.

**Expected**:
- `ActiveWorkoutScreen` opens showing "Bench Press" (weighted exercise).
- Reps field pre-populated with `10`.
- Weight field pre-populated with `80`.
- Set indicator row shows 3 dots: dot 1 = active/pending, dots 2–3 = pending.
- Exercise counter reads "Exercise 1 / 3".
- Set counter reads "Set 1 / 3".
- No validation error visible.
- No data written to Drift (verify: open database inspector or add debug log — `workout_sessions` table still empty).

**Pass criterion**: Correct field pre-population, correct exercise/set counters, no data written.

---

## Scenario 2: Valid set → advances to next set (FR-007, US1 AC2)

**Entry**: Scenario 1 complete; fields show Reps=10, Weight=80.

**Action**: Tap "Complete Set" (values unchanged).

**Expected**:
- Set 1 dot turns to logged state (lime indicator).
- Set counter reads "Set 2 / 3".
- Reps and Weight fields still pre-populated with plan targets (10 / 80 for set 2).
- No navigation away from screen.

**Pass criterion**: Dot 1 = logged, focus on set 2, no Drift write.

---

## Scenario 3: Inline validation — non-positive reps (FR-003, US2 AC1)

**Entry**: Screen shows Exercise 1, Set 1, Reps=10, Weight=80.

**Action**: Clear Reps field and enter `0`. Tap "Complete Set".

**Expected**:
- Inline error appears below Reps: "Reps must be greater than 0".
- Set is NOT logged; set indicator dot unchanged.
- Screen stays on same exercise/set.

**Action**: Change Reps field to `1`.

**Expected**:
- Error clears immediately (before next Complete Set tap).

**Pass criterion**: Error appears on tap, clears in real time, no set logged on invalid tap.

---

## Scenario 4: Inline validation — negative weight (FR-004, US2 AC2)

**Entry**: Weighted exercise, any set. Clear Weight and enter `-5`. Tap "Complete Set".

**Expected**: Inline error on Weight: "Weight cannot be negative". Set not logged.

**Pass criterion**: Weight error appears; set not advanced.

---

## Scenario 5: Inline validation — non-positive duration (FR-005, US2 AC3)

**Entry**: Advance to Exercise 3 (Plank — time-based). Duration field shows `60`. Enter `0`. Tap "Complete Set".

**Expected**: Inline error on Duration: "Duration must be greater than 0". Set not logged.

**Pass criterion**: Duration error appears; set not advanced; no Weight or Reps field visible (single-column layout).

---

## Scenario 6: Skip a set (FR-010, US1 AC-skip)

**Entry**: Exercise 1, Set 1.

**Action**: Tap "Skip".

**Expected**:
- Set 1 dot shows skipped state (dim/muted, visually distinct from logged).
- Screen advances to Set 2 / 3.
- No data written to Drift.

**Pass criterion**: Skipped dot correct color, advanced to set 2.

---

## Scenario 7: Complete workout — Finish with ≥1 logged set (FR-008, US1 AC3)

**Entry**: Complete or skip all sets for all exercises, ensuring at least one set across the workout is logged (not skipped).

**Action**: Tap "Complete Set" on the last set of Exercise 3 (Plank, Set 2) with a valid duration value.

**Expected**:
- App navigates to `/workout/summary` (SCR-19 stub screen).
- SCR-15 pre-start screen is NOT on the back-stack (back from SCR-19 goes to the screen before SCR-15).
- `workout_sessions` table now contains exactly one record.
- Record includes: UUID sessionId, planId, planName, startedAt, completedAt, sessionDurationSec, and all 7 sets (logged and skipped, each with a `skipped` boolean).

**Pass criterion**: SCR-19 stub visible; one Drift record; all sets present in record including skipped.

---

## Scenario 8: Finish with zero logged sets — discard path (FR-009, US4 AC4)

**Entry**: Start a fresh workout. Skip every set (all 7 sets).

**Action**: Tap "Complete Set" on the last set while it shows as skipped (or: skip the last set directly via Skip).

**Expected**:
- App routes to `/workout/cancel` (SCR-18 stub), not to SCR-19.
- No record written to `workout_sessions` table.

**Pass criterion**: SCR-18 stub visible; table still empty.

---

## Scenario 9: Pause and Resume (FR-011, US3)

**Entry**: Exercise 1, Set 1. Log one set. On Set 2: tap "Pause".

**Expected**:
- Paused overlay appears centered on screen.
- Underlying workout content is visible at reduced opacity and desaturated (no solid scrim).
- No Drift write.

**Action**: Tap "Resume".

**Expected**:
- Overlay dismissed; workout shows Exercise 1, Set 2 exactly as before Pause.
- Logged values for Set 1 are intact.

**Pass criterion**: Overlay shown/dismissed correctly; execution state preserved.

---

## Scenario 10: Cancel via button (FR-012, US4 AC1)

**Entry**: Exercise 1, Set 1, Active state.

**Action**: Tap "Cancel".

**Expected**: Navigates to `/workout/cancel` (SCR-18 stub). No Drift write.

**Pass criterion**: SCR-18 stub visible; Drift empty.

---

## Scenario 11: Cancel via OS back gesture (FR-013, US4 AC2)

**Entry**: Exercise 1, Set 1, Active state.

**Action (iOS)**: Swipe right from left edge. **(Android)**: Tap hardware back.

**Expected**: Navigates to `/workout/cancel` (SCR-18 stub). Screen is NOT popped directly.

**Pass criterion**: SCR-18 stub visible (not the screen before SCR-16).

---

## Scenario 12: Finish write failure and Retry (FR-015, edge case)

**Trigger**: Inject a mock `SaveWorkoutSessionUseCase` that returns `Left(CacheException('disk full'))` on the first call, then `Right(unit)` on the second.

**Action**: Complete a valid workout (Finish trigger fires).

**Expected (first call fails)**:
- Write-error banner appears on screen: "Couldn't save your workout" + reassurance body + "Retry" button.
- Screen does NOT navigate to SCR-19.
- No Drift record written.

**Action**: Tap "Retry".

**Expected (second call succeeds)**:
- App navigates to SCR-19 stub.
- Exactly one Drift record written (same `sessionId` — no duplicate).

**Pass criterion**: Write-error banner shown on failure; Retry recovers; no duplicate record.

---

## Scenario 13: Bodyweight exercise — single-column layout (US1 AC5)

**Entry**: Advance to Exercise 2 (Push-Up — bodyweight).

**Expected**:
- Only one field visible: "Reps" pre-populated with `15`.
- No Weight field visible.
- No Duration field visible.

**Pass criterion**: Single-column Reps-only layout.

---

## Bloc unit test coverage (reference to `active_workout_bloc_test.dart`)

| Scenario | Event sequence | Expected final state |
|---|---|---|
| (1) Valid complete advances | `Started` → `CompleteSet(reps:10)` | `Running(setIndex: 1)` |
| (2) Invalid reps blocked | `Started` → `CompleteSet(reps:0)` | `Running(repError: ≠null)` |
| (3) Invalid weight blocked | `Started` → `CompleteSet(reps:5, weight:-1)` | `Running(weightError: ≠null)` |
| (4) Field changed clears error | `Started` → `CompleteSet(reps:0)` → `FieldChanged(reps,'5')` | `Running(repError: null)` |
| (5) Skip advances | `Started` → `SkipSet` | `Running(setIndex: 1, setStatuses:[skipped,...])` |
| (6) Pause/Resume | `Started` → `Pause` | `Running(isPaused: true)` |
| (7) Resume clears pause | `Started` → `Pause` → `Resume` | `Running(isPaused: false)` |
| (8) Finish happy path | all sets logged → `CompleteSet` on last | navigate=postWorkout flag |
| (9) Finish zero-logged discard | all skipped → `Skip` on last | navigate=cancel flag |
| (10) Write failure → retry | Finish → use case fails → `RetryFinish` | navigate=postWorkout on 2nd call |
| (11) Idempotent retry | same UUID used on retry | `saveSession` called with same sessionId |

---

## Running tests

```bash
cd forge
flutter test test/features/workout_session/application/bloc/active_workout_bloc_test.dart
flutter test test/features/workout_session/presentation/screens/active_workout_screen_test.dart
flutter test
flutter analyze
```

All tests must pass with zero analyzer warnings.
