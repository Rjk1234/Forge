# Quickstart Validation Guide: Local Data Persistence (LOCALDB-01)

**Date**: 2026-09-19 | **Branch**: `001-local-data-persistence`

This guide describes how to validate that the persistence contract is correctly implemented.
It does not contain implementation code — see [contracts/](contracts/) and [data-model.md](data-model.md) for those.

---

## Prerequisites

- Flutter environment configured via FVM
- `forge/` is the Flutter project root
- All commands run from `forge/`
- A simulator or physical device is available for scenario VS-* tests
- Unit and integration tests run with: `flutter test test/features/workout_session/`

---

## Unit Test Scenarios (Automated)

Run from `forge/`:
```sh
flutter test test/features/workout_session/
flutter test test/features/workout_plan/
flutter test test/features/schedule/
```

### UT-01 — Completion criterion enforced (FR-003, FR-004, SC-003)

**Verify**: `WorkoutSessionRepositoryImpl.saveSession` with a session containing zero total logged sets returns `Left(WorkoutSessionFailure.completionCriterionNotMet())` and the mock data source's `saveSession` is never called.

**Test cases**:
- Session with `sessionExercises: []` → `completionCriterionNotMet`
- Session with one exercise but `actualSets: []` → `completionCriterionNotMet`
- Session with one exercise with one set → `Right(unit)`, data source called once

### UT-02 — Write failure maps to typed failure (FR-011, FR-013, SC-006, SC-011)

**Verify**: When the mock data source's `saveSession` throws a `SqliteException`, `WorkoutSessionRepositoryImpl.saveSession` returns `Left(WorkoutSessionFailure.saveFailure(...))` — it does not rethrow.

**Test cases**:
- Data source throws `SqliteException` → returns `Left(saveFailure)`
- Data source throws generic `Exception` → returns `Left(saveFailure)`
- Data source succeeds → returns `Right(unit)`

### UT-03 — History immutability (FR-006, SC-004)

**Verify**: `WorkoutSession` domain entity is immutable (all fields `final`). No `updateSession` method exists on `WorkoutSessionRepository`. The mapper copies all values into the storage record at write time (no references to plan objects).

### UT-04 — Read returns all sessions (FR-008, SC-005)

**Verify**: `WorkoutSessionRepositoryImpl.getAllSessions()` returns all sessions from the data source mapped to domain entities, with no filtering applied.

**Test cases**:
- Data source returns 3 sessions → `Right([WorkoutSession, WorkoutSession, WorkoutSession])`
- Data source returns 0 sessions → `Right([])`
- Data source throws → `Left(readFailure)`

### UT-05 — Filter by planId (FR-008)

**Verify**: `getSessionsByPlanId('plan-A')` returns only sessions where `session.planId == 'plan-A'`.

### UT-06 — Plan deletion does not affect session records (FR-007, SC-004)

**Verify at domain level**: `WorkoutSessionRepository` has no method that deletes sessions when a plan is deleted. `WorkoutPlanRepository.deletePlan` does not call any session deletion. (Cross-feature isolation is enforced by layer boundaries — no cross-feature direct import is possible.)

---

## Integration Test Scenarios (In-Memory Drift Database)

For full end-to-end validation with a real in-memory Drift database (`AppDatabase(NativeDatabase.memory())`, not a mock), run the integration tests or use the simulator:

### IT-01 — Write and read back (SC-001, SC-002, FR-001, FR-002, FR-005)

1. Create and save a `WorkoutSession` with known field values
2. Call `getAllSessions()` — session appears in result
3. Call `getSessionById(sessionId)` — session fields match exactly
4. Hot-restart or cold-start the test (close and reopen the database) — session survives

### IT-02 — Zero-set session produces no record (FR-004, SC-003)

1. Attempt to save a `WorkoutSession` with `sessionExercises: []`
2. Call `getAllSessions()` — no new record added
3. Repeat with non-empty `sessionExercises` but all `actualSets: []` — no new record added

### IT-03 — Plan deletion does not delete session records (FR-007, SC-004)

1. Save session S1 referencing planId 'plan-X'
2. Delete plan 'plan-X' via `WorkoutPlanRepository.deletePlan('plan-X')`
3. Call `WorkoutSessionRepository.getAllSessions()` — S1 is still present
4. Call `WorkoutSessionRepository.getSessionsByPlanId('plan-X')` — S1 is still returned

### IT-04 — Plan name snapshot is preserved (FR-006, SC-004)

1. Save plan with name "Strength A"
2. Start and finish a workout session — session saves with `planName: "Strength A"`
3. Edit plan name to "Power B" (overwrite via savePlan)
4. Read the session — `session.planName` is still "Strength A"

---

## Simulator Validation Scenarios

These require a running app on a simulator or device.

### VS-01 — Data survives app restart (US1, SC-001, SC-002, FR-010)

1. Launch app; create a workout plan
2. Complete a workout (log ≥1 set; tap Finish)
3. Force-close the app
4. Reopen the app
5. **Expected**: Plan appears in workout plans list; workout record appears in history

### VS-02 — Cancel produces no history record (US3, FR-004, SC-003)

1. Start a workout; cancel it without logging any sets
2. Check workout history
3. **Expected**: No new record in history

### VS-03 — Zero-set Finish produces no history record (US3, FR-004, SC-003)

1. Start a workout; tap Finish without logging any sets
2. Check workout history
3. **Expected**: No new record in history

### VS-04 — Plan edit does not change history (US2, FR-006, SC-004)

1. Complete a workout using Plan A (record exercise names, sets, reps)
2. Edit Plan A (rename an exercise, change rep targets)
3. Open workout history; open the record from step 1
4. **Expected**: Record shows original exercise names and values, not the edited ones

### VS-05 — Plan deletion does not remove history (US2, FR-007, SC-004)

1. Complete a workout using Plan A
2. Delete Plan A
3. Open workout history
4. **Expected**: Workout record from Plan A is still visible with full data

### VS-06 — Write failure shows visible error (FR-013, SC-011)

*Note*: This scenario is validated when the owning screen (SCR-19) implements the error state. LOCALDB-01 defines the failure type; the screen test verifies the visible error.

---

## Static Analysis Gate

After implementation, run from `forge/`:

```sh
dart format .
flutter analyze
flutter test test/features/workout_session/
flutter test test/features/workout_plan/
```

**Expected**: Zero errors, zero warnings introduced by LOCALDB-01 changes.
