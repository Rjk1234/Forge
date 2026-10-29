# Quickstart Validation Guide: SCR-09 Create / Edit Workout Plan

**Feature**: `001-create-edit-workout-plan`
**Date**: 2026-09-17

This guide documents how to validate SCR-09 end-to-end once implementation is complete. Run these scenarios after `flutter run` on an iOS Simulator or Android Emulator. The exercise catalogue must be seeded (it is seeded automatically on first boot via `ExerciseSeedService`).

For entity and field definitions see [data-model.md](data-model.md).

---

## Prerequisites

1. `flutter run` boots without errors on a target simulator/emulator.
2. The app is unlocked (past the login screen).
3. The exercise catalogue is seeded (verify by tapping any exercise entry in Browse).
4. The Workout Plans table is accessible (no database init errors in the debug console).

---

## VS-01 — Create Mode: Blank Form

**Route**: `/plans/create` (via the "+" FAB from a populated list, or "Create a workout plan" from the empty-state CTA)

**Steps**:
1. Navigate to the Plans tab. Tap the "+" FAB (or "Create a workout plan" CTA if no plans exist).

**Expected**:
- App bar title: "New Workout Plan"
- Plan name field: empty, placeholder "e.g., Push Day"
- Exercise section: dashed "Add Exercise" button visible
- Empty well below "Add Exercise": icon + "No exercises added yet"
- Footer: "Save Plan" button is dim and non-tappable

**Pass criteria**: All expected elements visible; tapping "Save Plan" does nothing.

---

## VS-02 — Add Exercise from Picker (Weighted)

**Prerequisite**: VS-01 in progress (create mode open)

**Steps**:
1. Tap "Add Exercise".
2. Select any **Weighted** exercise (e.g., Barbell Bench Press) from the picker.

**Expected**:
- Returns to the form with one new exercise card at the bottom.
- Card shows exercise name and a "Weighted" type badge (cyan dot or label).
- Card shows four target fields: Sets (0), Reps (0), Weight (0, kg suffix), Rest (0s) — Rest is on its own full-width row.
- "No exercises added yet" empty well is gone; dashed "Add Exercise" button is replaced by a regular "Add Exercise" button at the bottom of the list.
- "Save Plan" button remains dim (name is still empty).

**Pass criteria**: Card rendered with correct field layout; defaults all 0.

---

## VS-03 — Add Exercise from Picker (Time-Based)

**Prerequisite**: VS-01 in progress

**Steps**:
1. Tap "Add Exercise". Select any **Time-Based** exercise (e.g., Plank).

**Expected**:
- Card shows Sets (0), Duration (00:00), Rest (0s) in a single row. No Reps or Weight field.

---

## VS-04 — Add Exercise from Picker (Bodyweight)

**Prerequisite**: VS-01 in progress

**Steps**:
1. Tap "Add Exercise". Select any **Bodyweight** exercise (e.g., Push-Up).

**Expected**:
- Card shows Sets (0), Reps (0), Rest (0s) in a single row. No Weight field and no separate Rest row.

---

## VS-05 — Remove Exercise

**Prerequisite**: At least one exercise card on the form.

**Steps**:
1. Tap the Remove (×) button on an exercise card.

**Expected**:
- The card is removed immediately with no confirmation dialog.
- If the list is now empty: empty well reappears; "Save Plan" becomes dim.
- If exercises remain: the list re-renders without the removed card.

---

## VS-06 — Save Valid Plan (Create Mode)

**Prerequisite**: Plan name entered, at least one exercise added with all target fields > 0.

**Steps**:
1. Type "Push Day" into the plan name field.
2. Add one Weighted exercise. Set Sets = 3, Reps = 8, Weight = 60.0, Rest = 90.
3. Verify "Save Plan" button is now lime/active.
4. Tap "Save Plan".

**Expected**:
- Immediately: button changes to lime spinner + "Saving…"; form dims; back icon dims.
- Within ~1 second: navigation to Plan Detail (SCR-10) for the newly created plan, showing "Push Day".
- Back from SCR-10 returns to Plans list (not to the create form — form is off the back stack).
- The new plan "Push Day" is visible in the Plans list (SCR-08).

**Pass criteria**: Plan saved to the database; navigation correct; no residual form on back stack.

---

## VS-07 — Edit Mode: Pre-filled Form

**Prerequisite**: At least one plan exists (e.g., "Push Day" from VS-06 with at least one exercise of each type).

**Steps**:
1. From Plans list, tap "Push Day" → Plan Detail (SCR-10).
2. Tap the edit action (pencil icon or "Edit Plan" button on SCR-10).

**Expected**:
- App bar title: "Edit Workout Plan"
- Plan name field: pre-filled with "Push Day"
- Exercise cards: one per exercise, pre-filled with saved target values and correct type-specific field layout
- "Save Plan" button: lime/active (form is already valid)

---

## VS-08 — Inline Validation: Empty Name

**Prerequisite**: Create mode open; at least one exercise added with all fields > 0.

**Steps**:
1. Do NOT type a plan name.
2. Tap "Save Plan".

**Expected**:
- No navigation.
- Name field border turns danger (red); error below: "Plan name can't be blank."
- "Save Plan" button becomes dim.
- After typing a non-whitespace character, the danger border and error message clear and the button becomes active again.

---

## VS-09 — Inline Validation: Invalid Exercise Fields

**Prerequisite**: Create mode open; plan name entered; one Weighted exercise added (all fields at 0).

**Steps**:
1. Tap "Save Plan".

**Expected**:
- No navigation.
- Sets, Reps, and Weight field boxes all show danger borders with danger-coloured values.
- Error below card: "Sets must be greater than 0. Reps must be greater than 0. Weight must be greater than 0." (or combined equivalent)
- After entering Sets = 1, the Sets danger border clears immediately. After entering Reps = 8 and Weight = 50, all errors clear and the button becomes active.

---

## VS-10 — Weight Field Input: 1dp Enforcement

**Prerequisite**: Any exercise card with a Weight field is visible.

**Steps**:
1. Tap the Weight field.
2. Type: `6`, `0`, `.`, `5`, `5` (attempting 60.55)

**Expected**:
- After `6`, `0`, `.`, `5`: field shows "60.5"
- Typing the second `5`: field remains "60.5" — the digit is blocked by the input formatter

---

## VS-11 — Duration Field Input: mm:ss Masking

**Prerequisite**: A Time-Based exercise card is visible.

**Steps**:
1. Tap the Duration field.
2. Type: `0`, `1`, `3`, `0` (attempting 01:30)

**Expected**:
- Field shows `00:00` initially, then formats to `01:30` as digits are entered (leading zero enforcement, mm:ss display)

---

## VS-12 — Unsaved Changes Guard (Discard)

**Prerequisite**: Create mode open; type "Push Day" into plan name.

**Steps**:
1. Tap the back icon (or swipe from left on iOS / use system back on Android).

**Expected**:
- Discard dialog appears: title "Discard changes?", subtitle as per spec, "Discard" button (dim, left), "Keep Editing" button (lime, right).
- Tap scrim: dialog dismisses; form unchanged.
- Tap back icon again; dialog appears; tap "Keep Editing": dialog dismisses; form unchanged.
- Tap back icon again; dialog appears; tap "Discard": navigates to Plans list; form discarded.

---

## VS-13 — Clean Form (No Guard)

**Prerequisite**: Create mode open; form untouched (no name typed, no exercises added).

**Steps**:
1. Tap the back icon.

**Expected**:
- No dialog; navigates immediately to Plans list.

---

## VS-14 — Save Failure and Retry

**Prerequisite**: Requires triggering a database write failure. In widget tests, use a fake data source that throws; for manual validation, simulate by filling device storage (advanced) or use a debug hook. In practice, this scenario is verified primarily via automated widget tests.

**Expected behavior** (from automated tests):
- On write failure: error banner appears ("Couldn't save your changes"); form is editable; "Retry Save" button (lime) is visible.
- Tapping "Retry Save": returns to saving state (spinner, dimmed form).
- On second success: navigates to Plan Detail.

---

## VS-15 — Duplicate Exercise in Same Plan

**Prerequisite**: Create mode open; plan name entered.

**Steps**:
1. Tap "Add Exercise". Add "Barbell Bench Press".
2. Tap "Add Exercise" again. Add "Barbell Bench Press" again.

**Expected**:
- Two separate exercise cards for "Barbell Bench Press" appear in the list, each with their own independent target fields.
- No uniqueness error or snackbar appears.
- After filling all fields > 0 in both cards, "Save Plan" is active and save succeeds.

---

## Automated Test Coverage Map

| Scenario | Test type | Test file |
|---|---|---|
| VS-01 Create mode blank form | Widget test (US1) | `create_edit_workout_plan_screen_test.dart` |
| VS-02–04 Add exercises by type | Widget test (US3) | `create_edit_workout_plan_screen_test.dart` |
| VS-05 Remove exercise | Widget test (US3) | `create_edit_workout_plan_screen_test.dart` |
| VS-06 Save valid plan | Widget test (US4) | `create_edit_workout_plan_screen_test.dart` |
| VS-07 Edit mode pre-filled | Widget test (US2) | `create_edit_workout_plan_screen_test.dart` |
| VS-08–09 Inline validation | Widget test (US5) | `create_edit_workout_plan_screen_test.dart` |
| VS-10 Weight 1dp formatter | Unit test | `decimal_one_digit_input_formatter_test.dart` |
| VS-12–13 Discard guard | Widget test (US6) | `create_edit_workout_plan_screen_test.dart` |
| VS-14 Save failure + retry | Widget test (US7) | `create_edit_workout_plan_screen_test.dart` |
| VS-15 Duplicate exercise | Widget test | `create_edit_workout_plan_screen_test.dart` |
| Bloc state transitions | Bloc test | `create_edit_workout_plan_bloc_test.dart` |
| Repository savePlan | Unit test | `workout_plan_repository_impl_test.dart` |
| Repository getPlanById | Unit test | `workout_plan_repository_impl_test.dart` |
| Mapper toRecord / toDetailFromRecord | Unit test | `workout_plan_mapper_test.dart` |
