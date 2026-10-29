# Feature Specification: SCR-09 Create / Edit Workout Plan

**Feature Branch**: `SCR-09-create-edit-workout-plan`

**Created**: 2026-09-17

**Status**: Draft

**Design Reference**: [SCR-09 Design Spec](../../design/spec.md) — 6 artboards: Main.dc.html, CreateMode.dc.html, ValidationErrors.dc.html, SavingLoading.dc.html, SaveFailure.dc.html, DiscardConfirm.dc.html

---

## Clarifications

### Session 2026-09-17

- **OQ-1 (Entry point for edit mode)**: Resolved — SCR-08 plan card tap → SCR-10 (Plan Detail) first; edit action within SCR-10 → SCR-09 in edit mode. SCR-08 does **not** navigate directly to SCR-09.
- **OQ-2 (Duration input mechanism)**: Resolved — Masked text input showing `mm:ss` with numeric keyboard; leading zeros enforced; value stored as total seconds internally.
- **OQ-3 (Weight unit and decimal)**: Resolved — kg only for V1; one decimal place allowed; unit suffix is display-only, value stored as a numeric.
- **OQ-4 (Rest display format)**: Resolved — Displayed as plain integer + "s" suffix (e.g., "90s") regardless of magnitude; stored as integer seconds.
- **OQ-5 (Empty exercise list rule)**: Resolved — Save is blocked when the exercise list is empty; the Save button stays disabled (dim) until at least one exercise is added.
- **OQ-6 (Default values for newly-added exercise)**: Resolved — All target fields (Sets, Reps, Duration, Weight, Rest) default to 0 when an exercise is first added from SCR-07.
- **OQ-7 (Tapping scrim behind discard dialog)**: Resolved — Tap on scrim = "Keep Editing" (safe dismiss), consistent with iOS and Material conventions.
- **OQ-8 (Invalid exercise reference UI)**: Resolved — Danger border on the card + error message below: "This exercise is no longer available." Save is blocked when any exercise reference is invalid.
- **OQ-9 (Plan name max length)**: Resolved — 100 characters maximum; enforced at the input level.
- **OQ-10 (Presentation style)**: Resolved — Pushed (slide-left) transition; not a modal sheet. Back gesture / swipe-from-left-edge triggers the unsaved-changes guard in both iOS and Android.
- **OQ-11 (Editing form in Save Failure state)**: Resolved — Form is fully editable in the Save Failure state; adding/removing an exercise does not automatically clear the failure banner or re-enable the primary save button label — user retries via "Retry Save".
- **OQ-12 (Sets validation)**: Resolved — Sets = 0 is an error, shown with danger `.field-box` on the Sets cell; error message below card: "Sets must be greater than 0."
- **CL-01 (Weight field input mechanism)**: Resolved — Numeric keyboard with a 1dp input formatter; additional decimal digits beyond the first are blocked as the user types (no silent rounding on save).
- **CL-02 (Duplicate exercises in a plan)**: Resolved — Allowed. The same exercise ID may appear more than once in a plan (valid for drop sets, repeated movements). No uniqueness constraint is enforced.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Create Mode: Blank Form (Priority: P1)

As a user who wants to build a new workout plan, I want to open a blank form where I can name the plan and add exercises so that I can create a personalised training routine.

When I arrive at SCR-09 in create mode (from the "+" FAB or the "Create a workout plan" CTA on SCR-08), I see an empty form with the title "New Workout Plan". The plan name field is empty with a placeholder "e.g., Push Day". Below the name field is a dashed "Add Exercise" button. Below that is an empty well showing a list icon and "No exercises added yet". The Save Plan button is disabled (dim/not tappable) because neither a name nor any exercises have been entered.

**Why this priority**: Create mode is the first and most fundamental interaction. A user with zero existing plans must create their first plan through this form. All other user stories (edit, add exercises, save) depend on this baseline UI being correct.

**Independent Test**: Navigate to SCR-09 in create mode from the SCR-08 "+" FAB or CTA button. Verify the form is blank, the title is "New Workout Plan", the plan name placeholder reads "e.g., Push Day", the dashed "Add Exercise" button is visible, the empty-well message "No exercises added yet" is shown, and the Save Plan button is disabled.

**Acceptance Scenarios**:

1. **Given** I tap the "+" FAB from the populated Plans list (SCR-08), **When** SCR-09 opens, **Then** I see the title "New Workout Plan", an empty plan name field with placeholder "e.g., Push Day", a dashed "Add Exercise" button, the "No exercises added yet" empty well, and a dim/disabled "Save Plan" button.
2. **Given** I tap "Create a workout plan" from the empty Plans list (SCR-08), **When** SCR-09 opens, **Then** I see the same blank create-mode form as scenario 1.
3. **Given** the form is blank, **When** I tap the disabled "Save Plan" button, **Then** nothing happens — no validation errors appear and no navigation occurs.
4. **Given** I type a plan name into the field, **When** the name field has non-whitespace content but no exercises have been added, **Then** the Save Plan button remains disabled.
5. **Given** the plan name field is empty, **When** I type text and then delete it all, **Then** the placeholder "e.g., Push Day" reappears and the Save Plan button stays disabled.

---

### User Story 2 — Edit Mode: Pre-filled Form (Priority: P2)

As a user who wants to update an existing workout plan, I want to open a pre-filled form showing the plan's current name and exercises so that I can make changes without starting from scratch.

When I arrive at SCR-09 in edit mode (from the edit action within SCR-10), I see the title "Edit Workout Plan". The plan name field is pre-filled with the existing name. The exercises section shows one card per existing exercise, each pre-filled with the saved target values (sets, reps/duration, weight, rest) appropriate to that exercise's type. The Save Plan button is active (lime) immediately because the form starts in a valid state.

**Why this priority**: Edit mode is the second most important interaction — any user with existing plans needs to be able to modify them. Without a correctly pre-filled edit form, plan management is limited to create-only.

**Independent Test**: Navigate to SCR-10 (Plan Detail) for a plan that has a name and at least two exercises of different types, then tap the edit action. Verify the title is "Edit Workout Plan", the name field contains the plan name, and each exercise card is pre-filled with the correct type-appropriate target fields.

**Acceptance Scenarios**:

1. **Given** I tap the edit action from SCR-10 for a plan named "Push Day" with a Barbell Bench Press (weighted) exercise, **When** SCR-09 opens, **Then** I see the title "Edit Workout Plan", the name field shows "Push Day", and the exercise card shows Sets/Reps/Weight/Rest fields pre-filled with the saved values.
2. **Given** a plan contains a time-based exercise (e.g., Plank), **When** the edit form displays that exercise card, **Then** I see Sets/Duration/Rest fields (no Reps or Weight field); Duration is displayed as `mm:ss`.
3. **Given** a plan contains a bodyweight exercise (e.g., Push-Up), **When** the edit form displays that exercise card, **Then** I see Sets/Reps/Rest fields (no Weight field and no separate full-width Rest row).
4. **Given** the edit form opens with valid existing data, **When** the form first appears, **Then** the Save Plan button is active (lime) and tappable.
5. **Given** I modify the plan name in edit mode, **When** I clear the entire name field, **Then** the Save Plan button becomes disabled; when I type a valid name again, the button becomes active again.

---

### User Story 3 — Add and Remove Exercises (Priority: P3)

As a user building or editing a workout plan, I want to add exercises from the catalogue and remove exercises I no longer want so that I can compose the exact set of exercises for my plan.

Tapping "Add Exercise" (either the dashed button in create mode or the "Add Exercise" button at the bottom of the populated list) navigates to SCR-07 (Exercise Catalogue) in Picker mode. When I select an exercise from SCR-07 and return, a new exercise card appears at the bottom of the exercise list with all target fields defaulting to 0. Tapping the Remove (×) button on any exercise card removes that card from the list immediately.

**Why this priority**: Adding and removing exercises is the core editing action. Without this, the form cannot progress from the empty create-mode state to a saveable state.

**Independent Test**: In create mode, tap "Add Exercise", select one exercise from SCR-07 picker, and confirm it appears in the list with default values. Then tap "Add Exercise" again, add a second exercise, and verify both cards appear. Tap the Remove (×) on the first exercise and verify it disappears. When the last exercise is removed, verify the "No exercises added yet" empty well reappears.

**Acceptance Scenarios**:

1. **Given** I am on the form (create or edit mode), **When** I tap the "Add Exercise" button, **Then** the Exercise Catalogue (SCR-07) opens in Picker mode.
2. **Given** I am on SCR-07 in Picker mode, **When** I select an exercise, **Then** I am returned to SCR-09 and the selected exercise appears as a new card at the bottom of the exercise list with all target fields set to 0.
3. **Given** a weighted exercise was added, **When** its card renders, **Then** I see a Sets field, a Reps field, a Weight field, and a Rest field (full-width on its own row).
4. **Given** a time-based exercise was added, **When** its card renders, **Then** I see a Sets field, a Duration field (displaying "00:00"), and a Rest field in a single row.
5. **Given** a bodyweight exercise was added, **When** its card renders, **Then** I see a Sets field, a Reps field, and a Rest field in a single row (no Weight field).
6. **Given** at least one exercise is in the list, **When** I tap the Remove (×) button on an exercise card, **Then** that card is removed from the list immediately without a confirmation dialog.
7. **Given** I remove all exercises from the list, **When** the last card is removed, **Then** the "No exercises added yet" empty well reappears and the Save Plan button becomes disabled.
8. **Given** I have a valid plan name and at least one exercise with all defaults at 0, **When** I look at the form, **Then** the "Add Exercise" button is always visible at the bottom of the exercise list regardless of how many exercises are present.

---

### User Story 4 — Save a Valid Plan (Priority: P4)

As a user who has filled out a valid plan form, I want to tap Save and have the plan written to local storage so that it appears in my plan list.

When I tap "Save Plan" and the form passes all validation, the screen enters a saving state: the button shows a spinner and the text "Saving…", the form content is dimmed, all form interactions are disabled, and the back navigation is disabled. On a successful database write, I am navigated to the Plan Detail screen (SCR-10) for the newly saved plan. The saved plan is now accessible from the Plans list (SCR-08).

**Why this priority**: Saving is the culminating action of the entire create/edit flow. Without a working save, the feature delivers no lasting value.

**Independent Test**: In create mode, enter a valid plan name, add at least one exercise, set all target values to positive numbers, and tap Save Plan. Verify the saving state appears (spinner, dimmed form, "Saving…"), then verify navigation to SCR-10 with the new plan's data.

**Acceptance Scenarios**:

1. **Given** the form is valid (non-empty name, at least one exercise, all target fields > 0), **When** I tap "Save Plan", **Then** the button immediately shows a spinner with the label "Saving…" (lime background), the form content becomes semi-transparent and non-interactive, and back navigation is disabled.
2. **Given** the saving state is active, **When** the database write succeeds, **Then** I am navigated to the Plan Detail screen (SCR-10) for the saved plan; SCR-09 is removed from the back stack so back from SCR-10 does not return to the form.
3. **Given** I was in create mode, **When** the save succeeds, **Then** the newly created plan is visible in SCR-08 when I return to the Plans list.
4. **Given** I was in edit mode, **When** the save succeeds, **Then** the plan's updated name and exercises are reflected in SCR-10 (Plan Detail).
5. **Given** the saving state is active, **When** I attempt to tap the back icon or swipe back, **Then** the navigation is blocked — the form stays on screen while the write is in progress.

---

### User Story 5 — Validate and Block an Invalid Save Attempt (Priority: P5)

As a user who attempts to save an incomplete or invalid form, I want to see inline errors that tell me exactly what needs to be fixed so that I can correct the form without losing any of my other inputs.

When I tap "Save Plan" and one or more fields are invalid, no navigation occurs and no database write is attempted. Inline errors appear: the plan name field gets a danger border with the error "Plan name can't be blank." if the name is empty or whitespace; each exercise card shows danger borders on invalid field boxes and an error message below the card listing the specific problems. The Save Plan button becomes disabled (dim) while errors exist.

**Why this priority**: Validation protects data integrity. It must be tested before save to confirm the form cannot submit garbage data.

**Independent Test**: In create mode, type a plan name and add one exercise but leave all target fields at 0, then tap "Save Plan". Verify no navigation occurs, the exercise card shows danger borders on all invalid fields, and an error message appears below the card. Then clear the plan name and tap Save again — verify the name field shows its danger border and error copy.

**Acceptance Scenarios**:

1. **Given** the plan name is empty or whitespace-only, **When** I tap "Save Plan", **Then** the plan name field border turns danger (red), the error "Plan name can't be blank." appears below the name field, and the Save Plan button becomes disabled.
2. **Given** a weighted exercise card has Sets = 0, Reps = 0, and Weight = 0, **When** I tap "Save Plan", **Then** the Sets, Reps, and Weight field boxes all show danger borders and danger-coloured values, and the combined error "Sets must be greater than 0. Reps must be greater than 0. Weight must be greater than 0." appears below the card.
3. **Given** a time-based exercise card has Duration = 00:00, **When** I tap "Save Plan", **Then** the Duration field box shows a danger border and the error "Duration must be greater than 00:00." appears below the card.
4. **Given** a bodyweight exercise card has Sets = 0 or Reps = 0, **When** I tap "Save Plan", **Then** the affected field boxes show danger borders and the error "Sets must be greater than 0." and/or "Reps must be greater than 0." appear below the card.
5. **Given** a plan contains an exercise whose catalogue reference is no longer valid, **When** I tap "Save Plan", **Then** that exercise card shows a danger border and the error "This exercise is no longer available." appears below the card; the save is blocked.
6. **Given** the plan name is valid but the exercise list is empty, **When** I look at the Save Plan button, **Then** the button is disabled (dim) without requiring a save attempt — the button only becomes active when both conditions (valid name AND at least one exercise) are met.
7. **Given** validation errors are shown, **When** I fix all the errors, **Then** the danger borders and error messages clear and the Save Plan button becomes active (lime).
8. **Given** there are validation errors, **When** I tap the disabled Save Plan button, **Then** nothing happens — no new errors appear and no navigation occurs.

---

### User Story 6 — Unsaved Changes Guard (Priority: P6)

As a user who has made changes to a plan form but decides not to save, I want a confirmation dialog when I try to navigate away so that I do not accidentally lose my work.

When I tap the back icon or trigger a back gesture while the form has unsaved changes, a modal dialog appears over the form (which remains visible behind a scrim). The dialog has a lime "Keep Editing" button (right, primary/safe action) and a dim "Discard" button (left, destructive action). Tapping "Keep Editing" dismisses the dialog and returns me to the form unchanged. Tapping "Discard" navigates back to the Plans list (SCR-08) discarding all unsaved changes. If the form has no unsaved changes, back navigation proceeds immediately without the dialog.

**Why this priority**: The unsaved-changes guard is a critical data-protection feature. Without it, users risk accidentally losing plan edits with a single wrong tap.

**Independent Test**: In create mode, type a plan name, then tap the back icon. Verify the discard dialog appears. Tap "Keep Editing" and verify the form is unchanged. Tap back again, then tap "Discard" and verify navigation to SCR-08 with the form changes lost.

**Acceptance Scenarios**:

1. **Given** I have typed text in the plan name field (unsaved changes exist), **When** I tap the back icon, **Then** the discard dialog appears with the title "Discard changes?", the subtitle "You have unsaved changes to this workout plan. Leaving now will discard them.", a "Discard" button (left, dim fill), and a "Keep Editing" button (right, lime fill).
2. **Given** the discard dialog is shown, **When** I tap "Keep Editing", **Then** the dialog dismisses and I remain on the form with all my inputs intact.
3. **Given** the discard dialog is shown, **When** I tap "Discard", **Then** the dialog dismisses and I am navigated back to the Plans list (SCR-08); all form inputs are discarded.
4. **Given** the discard dialog is shown, **When** I tap anywhere on the scrim outside the dialog, **Then** the dialog dismisses (same as "Keep Editing") and I remain on the form.
5. **Given** the form is in its original state (no changes made — either blank create mode or unmodified edit mode), **When** I tap the back icon, **Then** I navigate back immediately without the discard dialog.
6. **Given** I added an exercise from SCR-07 but have not saved, **When** I tap the back icon, **Then** the discard dialog appears (adding an exercise constitutes an unsaved change).
7. **Given** the saving state is active (database write in progress), **When** I look at the back icon, **Then** the icon appears dim and tapping it has no effect — back navigation is disabled during saving.

---

### User Story 7 — Save Failure and Retry (Priority: P7)

As a user whose plan save fails due to a local storage error, I want to see an error banner that preserves my edits and offers a retry option so that a transient failure does not lose my work.

When the database write fails during the saving state, the spinner is replaced by an error banner at the top of the form content area. The banner explains the failure and advises the user that their edits are preserved. The footer button changes from "Saving…" to "Retry Save" (lime). The form content is fully editable again. Tapping "Retry Save" re-attempts the database write (returning to the saving state) without re-running validation — the data was already valid.

**Why this priority**: Save failure handling is the lowest priority user story because it handles an abnormal path. However, it is essential for robustness — silently losing a plan when a write fails would be a serious bug.

**Independent Test**: Simulate a database write exception during the saving state (via a fake data source in tests). Verify the error banner appears with the correct copy, the form is editable, and tapping "Retry Save" re-enters the saving state and re-attempts the write.

**Acceptance Scenarios**:

1. **Given** the saving state is active, **When** the database write throws an exception, **Then** the form transitions to the Save Failure state: the error banner appears below the app bar reading "Couldn't save your changes" (bold) with the body "Something went wrong writing to local storage. Your edits below are kept — tap Retry to try again."; the footer button changes to "Retry Save" (lime).
2. **Given** the Save Failure state is shown, **When** I look at the form, **Then** all fields are fully editable and interactive; my edits from before the failed save are still present.
3. **Given** the Save Failure state is shown, **When** I tap "Retry Save", **Then** the error banner disappears and the form transitions back to the saving state (spinner, dimmed form, "Saving…") without re-running validation.
4. **Given** I tapped "Retry Save" and the second write also fails, **When** the second write completes with an error, **Then** the error banner reappears with identical copy; "Retry Save" is still available.
5. **Given** I tapped "Retry Save" and the second write succeeds, **When** the write completes, **Then** I am navigated to SCR-10 (Plan Detail) for the saved plan.
6. **Given** the Save Failure state is shown, **When** I edit a field value and then tap "Retry Save", **Then** the retry uses the current (updated) form values — the form remains live and editable between the original failure and the retry.

---

### Edge Cases

- What happens when the plan name is exactly 100 characters? → Accepted as valid; the field enforces the 100-character limit at the keyboard level (no more characters can be typed).
- What happens when the plan name is exactly 101 characters entered programmatically? → Treated as invalid; the save is blocked and the error "Plan name can't be blank." applies only to empty/whitespace — a 101-char name is a separate validation that trims or blocks (assume: input enforces the cap, so this cannot occur at runtime).
- What happens when the user adds 0 exercises and the Save Plan button is dim, but they type a valid name? → Save stays blocked; disabled state clears only when both a valid name AND at least one exercise are present.
- What happens when the user presses the back gesture during the discard dialog? → Same as tapping "Keep Editing" — the dialog dismisses and the user returns to the form.
- What happens if the user rapidly taps "Save Plan" multiple times? → Only one database write is initiated; the first tap triggers the saving state (which disables all form interaction), so subsequent taps have no effect.
- What happens if the user returns from SCR-07 (Picker) without selecting an exercise? → The exercise list is unchanged; no new card is added.
- What happens when a plan is saved in create mode and SCR-09 is popped off the stack? → The Plans list (SCR-08) re-reads Drift on tab visit and displays the new plan; SCR-09 is no longer in the back stack.
- What happens if all exercises in edit mode are removed and then the user taps Save? → Save button is disabled when the exercise list is empty — no save is possible.
- What happens on very small screens (iPhone SE, 375 pt) with three 1fr target field columns? → Fields are slightly narrower but remain on a single row; content remains readable.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The screen MUST operate in two modes — Create mode ("New Workout Plan" app bar title, blank form) and Edit mode ("Edit Workout Plan" app bar title, pre-filled form) — determined by the navigation argument passed from the calling screen.
- **FR-002**: In Create mode, the plan name field MUST be empty with the placeholder "e.g., Push Day"; the exercise list MUST be empty showing the "No exercises added yet" empty well; the Save Plan button MUST be disabled (dim, not tappable).
- **FR-003**: In Edit mode, the plan name field MUST be pre-filled with the existing plan name; the exercise list MUST show one card per existing exercise with all target values pre-filled.
- **FR-004**: Each exercise card MUST display the exercise name and its type badge (dot colour: cyan for Weighted, lime for Time-based, muted for Bodyweight). The card MUST show type-appropriate target fields:
  - **Weighted**: Sets, Reps, Weight (with "kg" suffix label), Rest (full-width, own row) — 3+1 layout.
  - **Time-based**: Sets, Duration (`mm:ss` display), Rest — 3-column single-row layout.
  - **Bodyweight**: Sets, Reps, Rest — 3-column single-row layout.
- **FR-005**: The Save Plan button MUST be active (lime, tappable) only when ALL of the following are true: the plan name is non-empty and non-whitespace, at least one exercise is in the list, and no validation errors have been triggered. In all other conditions the button MUST be disabled (dim, non-tappable).
- **FR-006**: Tapping "Add Exercise" (dashed button in empty state, or "Add Exercise" button at the bottom of the populated list) MUST navigate to SCR-07 (Exercise Catalogue) in Picker mode. On return, if an exercise was selected, it MUST be appended to the exercise list with all target fields defaulting to 0.
- **FR-007**: The "Add Exercise" button MUST always be visible at the bottom of the exercise list in both create and edit modes, including when the list already has exercises.
- **FR-008**: Tapping the Remove (×) button on an exercise card MUST remove that card from the list immediately with no confirmation dialog. If the last exercise is removed, the empty well MUST reappear and the Save Plan button MUST become disabled.
- **FR-009**: When "Save Plan" is tapped with a valid form, the screen MUST transition to the saving state: the button shows a spinner with "Saving…" text (lime background); the entire form content becomes non-interactive (dimmed); the back icon becomes dim and its tap has no effect.
- **FR-010**: On a successful database write, the screen MUST navigate to the Plan Detail screen (SCR-10) for the saved plan. SCR-09 MUST be removed from the navigation stack so back from SCR-10 does not return to the form.
- **FR-011**: When "Save Plan" is tapped with one or more invalid fields, the screen MUST show inline validation errors without any navigation or database write. The Save Plan button MUST become disabled (dim). Validation rules:
  - Plan name is empty or whitespace-only → error below name field: "Plan name can't be blank."
  - Sets ≤ 0 on any exercise card → danger `.field-box` on Sets; error below card: "Sets must be greater than 0."
  - Reps ≤ 0 on any weighted or bodyweight exercise card → danger `.field-box` on Reps; error below card includes: "Reps must be greater than 0."
  - Weight ≤ 0 on any weighted exercise card → danger `.field-box` on Weight; error below card includes: "Weight must be greater than 0."
  - Duration = 00:00 on any time-based exercise card → danger `.field-box` on Duration; error below card: "Duration must be greater than 00:00."
  - `exerciseId` not found in the exercise catalogue → danger border on the card; error below: "This exercise is no longer available."
  - Multiple errors per card MUST be combined into one message below the card.
- **FR-012**: Validation MUST run only on a save attempt (not on keystroke or blur). Inline errors MUST clear immediately once the user corrects the associated field.
- **FR-013**: The plan name field MUST enforce a maximum of 100 characters at the keyboard level.
- **FR-014**: When the database write fails, the screen MUST transition to the Save Failure state: an error banner appears below the app bar reading "Couldn't save your changes" (bold header) with the body "Something went wrong writing to local storage. Your edits below are kept — tap Retry to try again."; the form MUST be fully editable and interactive again; the footer button MUST change to "Retry Save" (lime).
- **FR-015**: Tapping "Retry Save" MUST re-attempt the database write (returning to the saving state) using the current form data without re-running validation. Multiple failed retries MUST repeat the Save Failure state with identical copy.
- **FR-016**: When the user taps the back icon or triggers a back gesture and the form has unsaved changes, the screen MUST show a discard confirmation dialog with: title "Discard changes?"; subtitle "You have unsaved changes to this workout plan. Leaving now will discard them."; "Discard" button (left, dim fill — destructive); "Keep Editing" button (right, lime fill — safe). Tapping "Keep Editing" or the scrim MUST dismiss the dialog and return to the form. Tapping "Discard" MUST navigate back to SCR-08 discarding all form data.
- **FR-017**: If the form has no unsaved changes, the back icon MUST navigate back immediately without showing the discard dialog. A clean form exists when: in create mode, no name has been entered and no exercises have been added; in edit mode, no fields have been changed from their loaded values.
- **FR-018**: The Duration field for time-based exercises MUST accept input as `mm:ss` using a numeric keyboard with leading-zero enforcement; the stored value MUST be total seconds as an integer.
- **FR-018b**: The Weight field for weighted exercises MUST use a numeric keyboard with a 1-decimal-place input formatter. The formatter MUST block any digit typed after the first decimal place — the field never silently rounds; the stored value is a decimal number with at most 1dp.
- **FR-019**: The Rest field for all exercise types MUST accept input as a positive integer representing seconds; display appends an "s" suffix (e.g., "90s").
- **FR-020**: The screen is a secondary screen — no bottom navigation bar is shown in any state.

### Key Entities

- **WorkoutPlan (create/edit target)**: `planId: String` (UUID, generated on create), `name: String` (1–100 non-whitespace characters), `planExercises: List<PlanExerciseRecord>` (ordered, at least 1 for save to succeed), `createdAt: DateTime` (set on create, unchanged on edit), `updatedAt: DateTime` (updated on every save).
- **PlanExerciseRecord**: `exerciseId: String` (must exist in exercise catalogue table), `exerciseName: String`, `type: ExerciseType` (Weighted / TimeBased / Bodyweight), `targetSets: int` (> 0), `targetRepetitions: int?` (> 0 for Weighted / Bodyweight; null for TimeBased), `targetWeight: double?` (> 0.0 for Weighted; null otherwise), `targetDurationSec: int?` (> 0 for TimeBased; null otherwise), `restPeriodSec: int` (≥ 0).
- **ExerciseType** (enum): Weighted, TimeBased, Bodyweight — determines which target fields are shown on the exercise card.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can reach a valid saveable state (non-empty name + at least one exercise with all targets filled) from a blank create form in under 2 minutes under normal usage.
- **SC-002**: The saving state transition (spinner, dimmed form) appears within 1 frame of tapping "Save Plan" — the user never sees a frozen screen without feedback.
- **SC-003**: A successful plan save completes the database write and navigates to SCR-10 within 2 seconds of tapping "Save Plan" under normal conditions (local write is fast).
- **SC-004**: Inline validation errors appear without any screen navigation — the user remains on the form and can correct errors without losing any other inputs.
- **SC-005**: The discard confirmation dialog appears within 1 frame of tapping the back icon when unsaved changes are present — there is no navigation delay.
- **SC-006**: All 6 screen states (Create, Edit, Validation Errors, Saving, Save Failure, Discard Dialog) are reachable, display the correct UI, and do not crash or produce blank screens.
- **SC-007**: All interactive touch targets (plan name field, exercise card field boxes, "Add Exercise" button, Remove (×) button, Save Plan / Retry Save / Discard / Keep Editing buttons, back icon) meet a minimum touch size of 44 × 44 pt or the touch area is extended to that minimum.
- **SC-008**: The plan name field rejects input beyond 100 characters — no more than 100 characters can be entered at runtime.

---

## Assumptions

- **Offline only**: All reads and writes use the local tables (`workout_plans`, `exercises`). No network call is made at any point. This is a constitutional constraint.
- **Presentation style**: SCR-09 is a secondary screen pushed (slide-left) from SCR-10 (edit) or SCR-08 (create, via the "+" FAB or empty-state CTA). The bottom navigation bar is not shown.
- **Navigation stack on save**: On a successful save, SCR-09 is removed from the back stack. Back from SCR-10 (Plan Detail) returns to SCR-10 (if editing) or the Plans list (if creating) — not to SCR-09.
- **Validation timing**: Validation runs only on a save attempt. Fields are not validated on every keystroke or on blur. This matches the design spec and constitution rule VII.3.
- **Default target values**: When an exercise is first added from SCR-07 Picker, all numeric target fields (Sets, Reps/Duration, Weight, Rest) default to 0. The user must explicitly enter valid values before saving.
- **Rest period minimum**: Rest = 0 is allowed (no rest required between sets). Validation only blocks negative values; 0 is a valid rest period.
- **Units**: Weight is displayed and stored as kg for V1 (OQ-3). A future ADR may add unit switching.
- **Exercise ordering**: Exercises are displayed in the order they were added. There is no drag-to-reorder in V1.
- **Duplicate exercises**: The same exercise may be added more than once to a single plan (valid for drop sets or repeated movements at different intensities). No uniqueness constraint is enforced on `exerciseId` within a plan's exercise list.
- **Save failure idempotency**: A failed write MUST NOT commit a partial record to the database. Retrying after failure is safe to repeat.
- **Invalid exercise reference handling**: An exercise whose `exerciseId` is no longer in the catalogue table is flagged at save time. The card remains editable in the Save Failure state.
- **Edit mode change detection**: A form is considered "dirty" (has unsaved changes) as soon as the user modifies any field or adds/removes any exercise from the initial loaded state. The clean/dirty check is in-memory only; no deep-equality comparison to the database is performed on every keystroke.
- **Portrait orientation only**: Landscape is out of scope for this POC.
- **Dark theme only**: Single fixed dark theme per ADR-037; no light mode.
- **No autosave / draft persistence**: If the user force-kills the app while filling in the form, unsaved changes are lost. No local draft is saved between sessions.
