# Quickstart: SCR-06 Home Dashboard Validation

**Date**: 2026-09-16 | **Phase**: 1 — Design

---

## Prerequisites

```bash
# Flutter environment
cd forge/
fvm flutter --version   # verify Flutter SDK active

# tables must be registered and opened before app launch
# Verified in: forge/lib/core/database/app_database.dart

# Run all tests (must stay green before and after implementation)
fvm flutter test
```

---

## Running the App

```bash
cd forge/
fvm flutter run
```

The app starts at the Home Dashboard (route `/`) after passing the auth gate (SCR-01/SCR-03).

To bypass auth during development, use the existing auth bypass mechanism or seed valid credentials via the existing `AppLockCubit` setup.

---

## Validation Scenarios

### VS-01 — Loading State

**Precondition**: App installed fresh (no Drift data), or simulate slow database read.

**Steps**:
1. Launch app past auth screen
2. Observe Home Dashboard immediately

**Expected**:
- A centered circular progress indicator with lime color (`#C3F400`) is visible
- No content (no card, no links) flashes before the indicator
- Bottom navigation bar is visible (tabs rendered)
- Bottom nav tabs 1–5 are visible but tapping them has no effect while loading

**FR covered**: FR-001, FR-008

---

### VS-02 — Empty State (First-Time User)

**Precondition**: All three tables empty (`workout_plans`, `schedule_entries`, `workout_sessions`).

**Steps**:
1. Launch app (or clear all Drift data before launch)
2. Wait for Home Dashboard to load

**Expected**:
- Loading indicator resolves
- Empty state is shown: icon + "No workouts yet" + "Create your first plan to get started"
- Button with label "Create your first workout plan" is visible and tappable
- **No** quick links grid appears
- Tapping the button: Plans tab becomes the active bottom nav tab AND the Create Plan screen (SCR-09) is shown within the Plans tab stack

**FR covered**: FR-002, FR-010, SC-003

---

### VS-03 — Populated / Scheduled Workout Today

**Precondition**:
1. A workout plan exists in `workout_plans` table with at least 2 exercises
2. A schedule entry exists mapping today's weekday to that plan's `planId`

**Steps**:
1. Launch app
2. Wait for Home Dashboard to load

**Expected**:
- A tappable workout card appears with:
  - Plan name (correct)
  - Exercise count (correct, e.g. "3 exercises")
  - Dominant exercise type chip (e.g. "Weighted")
  - Rest period chip showing the **first exercise's** rest period in seconds (e.g. "60s rest")
- Quick links grid appears below the card (5 tiles: Plans, Schedule, History, Progress, Stats)
- Tapping the workout card navigates to SCR-15 (Pre-Start) for that plan

**Edge**: if the plan has 0 exercises, no rest period chip is shown on the card; exercise count shows "0 exercises"

**FR covered**: FR-003, FR-004, FR-006, SC-001, SC-002

---

### VS-04 — Populated / Rest Day

**Precondition**:
1. At least one plan or session exists in the database (hasData = true)
2. No schedule entry exists for today's weekday (or weekday entry's planId does not match any plan)

**Steps**:
1. Launch app on a day with no scheduled plan
2. Wait for Home Dashboard to load

**Expected**:
- Rest day card appears: icon + "Rest Day" + "No workout scheduled for today — enjoy the recovery."
- Rest day card is **not** tappable (no ink/ripple effect)
- Quick links grid appears below the card (5 tiles)
- Each quick link navigates correctly: Plans → `/plans`, Schedule → `/schedule`, etc.

**FR covered**: FR-005, FR-006, SC-002

---

### VS-05 — Error State with Retry

**Precondition**: Simulate a database read failure (e.g., inject a mock `HomeDashboardLocalDataSource` that throws during `getDashboardSnapshot()`; or use the test build with a failing mock).

**Steps**:
1. Launch app with simulated failure
2. Observe Home Dashboard
3. Tap "Retry"

**Expected**:
- Error card appears: `Icons.error_outline` icon + "Couldn't load your dashboard" + "Retry" button
- Bottom nav tabs remain tappable (navigating to another tab works)
- Tapping "Retry": loading indicator shown → data read re-attempted → resolves to correct state (empty/populated/error)
- Retry after retry failure: error card re-shown (no crash)

**FR covered**: FR-007, FR-008, SC-004

---

### VS-06 — Tab Re-Activation Refresh (FR-012)

**Precondition**: App running with populated Home state (VS-03 or VS-04).

**Steps**:
1. Home tab active; populated state showing
2. Tap "Plans" tab → Plans placeholder shown; Home tab deactivated
3. From Plans, tap "Home" tab

**Expected**:
- Loading indicator briefly appears (Drift re-read triggered)
- Dashboard resolves to current Drift state (same or updated data)
- If a workout was completed (session written) since last Home view, state reflects the current Drift state

**Steps (sub-screen return)**:
1. Tap today's workout card → SCR-15 opens within Home stack
2. Press back → returns to Home Dashboard

**Expected**:
- Loading indicator briefly appears (re-read on `didChangeDependencies`)
- Dashboard resolves correctly

**FR covered**: FR-012, SC-001

---

### VS-07 — Navigation Tab Switching (All States)

**Precondition**: Dashboard in any non-loading state.

**Steps**:
1. Tap each of the 5 bottom nav tabs in sequence
2. Return to Home after each

**Expected**:
- Each tab switches without error (placeholder tab screens for unimplemented tabs)
- Home tab shows loading indicator briefly on each return, then resolves to data state
- Active tab indicator updates correctly in the bottom nav

**FR covered**: FR-008, SC-002

---

## Widget Test Entry Points

```
forge/test/features/home/
├── application/
│   ├── bloc/home_bloc_test.dart          — bloc state machine (no Flutter widgets)
│   └── usecases/get_dashboard_snapshot_usecase_test.dart
├── data/
│   └── datasources/home_local_data_source_test.dart
└── presentation/
    └── screens/home_screen_test.dart     — pumpWidget with mock HomeBloc
```

**Run specific test file**:
```bash
cd forge/
fvm flutter test test/features/home/application/bloc/home_bloc_test.dart
fvm flutter test test/features/home/
```

---

## References

- [data-model.md](data-model.md) — Entity definitions and derivation rules
- [contracts/home-bloc.md](contracts/home-bloc.md) — Bloc event/state contract and test cases
- [contracts/home-screen.md](contracts/home-screen.md) — Widget contracts
- [spec.md](spec.md) — Source of truth for acceptance criteria
