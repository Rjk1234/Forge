# Quickstart Validation Guide: Plan Detail (SCR-10)

**Feature**: SCR-10-Plan-Detail  
**Date**: 2026-09-19

This guide describes how to validate the SCR-10 implementation end-to-end. It covers prerequisites, the key validation scenarios, and expected outcomes. Implementation code belongs in `tasks.md` — this guide is for verification only.

---

## Prerequisites

1. ForgeApp builds and runs on iOS Simulator or Android Emulator.
2. At least one workout plan with exercises of all three types (Weighted, Time-based, Bodyweight) exists in the local Drift store. Use the seed data or create one via SCR-09.
3. `flutter analyze` produces zero errors and zero warnings introduced by the SCR-10 changes.
4. `flutter test` passes with the SCR-10 test suite included.

---

## Validation Scenarios

### VS-01 — Navigation from Plans List

**Setup**: Open the app; navigate to the Plans tab (SCR-08).

**Steps**:
1. Tap any plan card.

**Expected outcome**: The Plan Detail screen opens with the plan name in the app bar title area, the exercise count subtitle (e.g. "3 exercises"), and the exercise list populated with cards.

---

### VS-02 — Loading Skeleton

**Setup**: Slow down database reads in a debug build (or run on a slow device profile).

**Steps**:
1. Navigate to any plan detail.

**Expected outcome**: A skeleton screen appears immediately with:
- Shimmer placeholder for the plan title and subtitle lines
- Three shimmer exercise card placeholders
- Two skeleton footer button placeholders
- The back chevron is visible and tappable (live, not a skeleton)

---

### VS-03 — Back chevron during loading

**Setup**: Same as VS-02, with the skeleton visible.

**Steps**:
1. Tap the back chevron while the skeleton is showing.

**Expected outcome**: The app navigates back to the Plans List (SCR-08) immediately, without waiting for the database read to complete.

---

### VS-04 — Weighted exercise fields

**Setup**: A plan containing at least one Weighted exercise (e.g. Barbell Bench Press, 4 sets, 8 reps, 60 kg, 90s rest).

**Steps**:
1. Open that plan's detail.
2. Locate the Weighted exercise card.

**Expected outcome**:
- Type dot is cyan; label reads "Weighted"
- Four field boxes: Sets ("4"), Reps ("8"), Weight ("60 kg"), Rest ("90s")
- Layout: 3-column row (Sets, Reps, Weight) + 1-column row (Rest)
- No input controls are tappable or focusable

---

### VS-05 — Time-based exercise fields

**Setup**: A plan containing at least one Time-based exercise (e.g. Plank, 3 sets, 45s, 60s rest).

**Steps**:
1. Open that plan's detail.
2. Locate the Time-based exercise card.

**Expected outcome**:
- Type dot is lime (yellow-green); label reads "Time-Based"
- Three field boxes in one row: Sets ("3"), Duration ("00:45"), Rest ("60s")
- No Weight field appears

---

### VS-06 — Bodyweight exercise fields

**Setup**: A plan containing at least one Bodyweight exercise (e.g. Push-Up, 3 sets, 15 reps, 60s rest).

**Steps**:
1. Open that plan's detail.
2. Locate the Bodyweight exercise card.

**Expected outcome**:
- Type dot is muted grey; label reads "Bodyweight"
- Three field boxes in one row: Sets ("3"), Reps ("15"), Rest ("60s")
- No Weight field appears

---

### VS-07 — Scrollable exercise list

**Setup**: A plan with 6 or more exercises.

**Steps**:
1. Open that plan's detail.
2. Scroll the exercise list down.

**Expected outcome**: The exercise list scrolls; the app bar (with back, edit, delete buttons) and the footer (Schedule, Start Workout) remain fixed and visible throughout.

---

### VS-08 — Edit navigation

**Setup**: Any populated plan detail.

**Steps**:
1. Tap the Edit icon button (pencil icon in the top-right area of the app bar).

**Expected outcome**: The Create/Edit Workout Plan screen (SCR-09) opens in edit mode with the current plan's name and exercises pre-filled.

---

### VS-09 — Data refresh after edit

**Steps**:
1. Open a plan named "Push Day".
2. Tap Edit; rename the plan to "Push Day — Updated".
3. Save the plan (tapping "Save Plan").
4. Observe the screen that appears after save.

**Expected outcome**: After saving, SCR-09 navigates to the plan detail (SCR-10). The plan detail shows "Push Day — Updated" as the plan name, reflecting the saved change.

---

### VS-10 — Delete navigation

**Setup**: Any populated plan detail.

**Steps**:
1. Tap the Delete icon button (trash icon in the top-right area of the app bar).

**Expected outcome**: The Delete Plan Confirmation screen (SCR-11) opens. *(If SCR-11 is not yet implemented, the router's error page is shown — acceptable for this validation.)*

---

### VS-11 — Start Workout navigation

**Setup**: A plan with at least one exercise.

**Steps**:
1. Open that plan's detail.
2. Tap "Start Workout".

**Expected outcome**: The Workout Pre-Start Overview screen (SCR-15) opens with the plan's exercises visible. *(If SCR-15 is not yet implemented, the router's error page is shown — acceptable for this validation.)*

---

### VS-12 — Schedule navigation

**Setup**: Any populated plan detail.

**Steps**:
1. Tap "Schedule".

**Expected outcome**: The Assign/Edit Schedule screen (SCR-13) opens. *(If SCR-13 is not yet implemented, the router's error page is shown — acceptable for this validation.)*

---

### VS-13 — Empty plan (0 exercises)

**Setup**: Create a plan via SCR-09 with no exercises added (plan name only, then save).

**Steps**:
1. Navigate to that plan's detail.

**Expected outcome**:
- The plan name and "0 exercises" subtitle are shown
- The "EXERCISES" section label appears with no exercise cards below it
- The "Start Workout" button is visible in the footer but visually dimmed/disabled and non-interactive

---

### VS-14 — Error / Not-Found state

**Setup**: Use a deep-link or test harness to navigate to `/plans/nonexistent-plan-id`.

**Steps**:
1. Open the plan detail with an ID that does not exist in the database.

**Expected outcome**:
- The error card appears with "This plan is no longer available"
- No Edit or Delete icon buttons appear in the app bar
- A "Back to Plans" button is visible

---

### VS-15 — "Back to Plans" in error state

**Setup**: Same as VS-14, with error state visible.

**Steps**:
1. Tap "Back to Plans".

**Expected outcome**: The app navigates to the Plans List (SCR-08).

---

## Automated Test Coverage

Reference test files (created as part of SCR-10 implementation):

| File | Coverage |
|------|----------|
| `test/features/workout_plan/application/bloc/plan_detail_bloc_test.dart` | Bloc state transitions for load, refresh, success, error, not-found |
| `test/features/workout_plan/presentation/widgets/plan_exercise_detail_card_test.dart` | Field layout per exercise type, type dot colour, read-only fields |
| `test/features/workout_plan/presentation/screens/plan_detail_screen_test.dart` | Full screen widget tests covering all states: Loading, Loaded, NotFound, empty plan, navigation |

Run all SCR-10 tests:

```bash
flutter test test/features/workout_plan/
```

Run with full test suite:

```bash
flutter test
```

---

## Analyzer Check

```bash
flutter analyze
```

Expected: zero errors, zero warnings introduced by SCR-10 changes.
