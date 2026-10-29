# Quickstart Validation Guide: SCR-25 Profile / Account

**Feature**: SCR-25 Profile / Account  
**Date**: 2026-09-24  
**References**: [spec.md](spec.md) | [data-model.md](data-model.md) | [contracts/profile-bloc.md](contracts/profile-bloc.md)

---

## Prerequisites

- Flutter app running on a simulator or device (Android API 29+ or iOS 15+)
- The `user_profiles` table is defined in `AppDatabase`
- SCR-06 Home Dashboard is implemented; `HomeHeader` has a tappable profile icon (`context.push('/profile')`)
- SCR-26 Logout Confirmation route exists (or a placeholder route at `/logout`)

> If `HomeHeader` profile entry point is not yet wired, call `context.push('/profile')` directly from a debug entry point or by tapping a temporary debug button on the home screen.

---

## Setup Commands

```bash
cd forge
flutter run
```

To clear the profile Drift table (simulate first-time user):

```dart
// In a debug/dev entry point or the database inspector:
await database.delete(database.userProfiles).go();
```

---

## Validation Scenarios

### VS-01: Loading Skeleton Appears Immediately

**Seed**: Any state (profile may or may not exist).

**Steps**:
1. Navigate to the Profile screen (tap profile icon in `HomeHeader`)

**Expected**:
- Screen pushes immediately with no bottom navigation bar visible
- Loading skeleton appears immediately (no blank frame):
  - Circular 64×64 avatar skeleton (shimmer)
  - 4 field-group skeletons (sk-label + sk-field rows with shimmer)
- Skeleton resolves to the form (or error state if Drift fails)

**Validates**: FR-001, SC-001, US1 AC-1

---

### VS-02: Populated Form — Existing Profile

**Seed**: Drift table contains a `UserProfileRecord` with `displayName:'Alex Rivera'`, `fitnessGoal:'Build Muscle'`, `experienceLevel:'Intermediate'`, `heightCm:178.0`, `weightKg:76.0`.

**Steps**:
1. Navigate to the Profile screen

**Expected**:
- Form displays after skeleton
- Display name field shows `'Alex Rivera'`
- Fitness Goal shows `'Build Muscle'` (not the hint text)
- Experience Level: `'Intermediate'` segment is lime-highlighted; `'Beginner'` and `'Advanced'` are inactive
- Height field shows `'178.0'` (or `'178'` — implementation detail)
- Weight field shows `'76.0'`
- "Save Changes" button is active (lime bg)
- "Log Out" row is visible below the save button
- No bottom navigation bar visible

**Validates**: FR-002, US1 AC-1, US1 AC-4

---

### VS-03: First-Time User — Empty Form with Defaults

**Seed**: The `user_profiles` table is empty (no row with id 0).

**Steps**:
1. Clear the `user_profiles` table (see Setup Commands)
2. Navigate to the Profile screen

**Expected**:
- Display Name field: empty
- Fitness Goal: shows hint text `'Select a goal'` (no option selected)
- Experience Level: `'Beginner'` segment is lime-highlighted (default)
- Height and Weight fields: empty
- "Save Changes" button is active (enabled — even with empty height/weight)
- All other UI identical to VS-02

**Validates**: Q2 clarification (Beginner default, empty fields allowed), US1 AC-1

---

### VS-04: Edit and Save — Success Toast

**Seed**: Existing profile (VS-02 seed) or empty (VS-03).

**Steps**:
1. Navigate to Profile screen
2. Tap the Display Name field; change to `'Jordan Lee'`
3. Tap `'Advanced'` segment; it becomes lime-highlighted
4. Tap "Save Changes"

**Expected**:
- Save button becomes disabled momentarily (write in flight)
- A success toast appears at the bottom: lime checkmark icon + `'Profile saved'`
- Toast auto-dismisses after ~2.5 seconds
- Form stays visible with updated values (`'Jordan Lee'`, `'Advanced'` active)
- No navigation away from the screen

**Validates**: FR-007, FR-008, FR-009, FR-024, SC-002, US2 AC-1, US2 AC-5

---

### VS-05: Saved Values Persist Across Re-Entry

**Prerequisite**: VS-04 completed successfully.

**Steps**:
1. After save, tap the back arrow → returns to SCR-06
2. Tap the profile icon again → navigates to Profile screen

**Expected**:
- Skeleton resolves to form showing `'Jordan Lee'` and `'Advanced'` (values from VS-04)
- No stale values from a previous session

**Validates**: FR-009, SC-006, US1 AC-4

---

### VS-06: Invalid Height — Blocks Save

**Seed**: Any existing profile.

**Steps**:
1. Navigate to Profile screen (form loaded)
2. Clear the Height field and type `'-50'`
3. Tap "Save Changes"

**Expected**:
- Height field border turns danger-colored; background changes to `dangerFill`; text color is `danger`
- Inline error `'Enter a valid positive number.'` appears below the height field
- Save button switches to disabled appearance
- Helper note `'Fix the highlighted fields to save.'` appears below the disabled save button
- Weight field is unaffected (no error)
- No save dispatched to Bloc

**Validates**: FR-010, FR-011, US3 AC-1

---

### VS-07: Both Fields Invalid Simultaneously

**Seed**: Any existing profile.

**Steps**:
1. Navigate to Profile screen
2. Set Height to `'abc'`, Weight to `'0'`
3. Tap "Save Changes"

**Expected**:
- Both height AND weight fields show the danger highlight + inline error
- Save button disabled; save note shown

**Validates**: FR-010, US3 AC-3

---

### VS-08: Correct Invalid Field → Save Succeeds

**Prerequisite**: VS-06 or VS-07 (validation error shown).

**Steps**:
1. Fix the height field: type `'178'`
2. Fix weight if needed
3. Tap "Save Changes"

**Expected**:
- Validation error clears on both fields
- Save executes; success toast appears
- Saved values are persisted

**Validates**: FR-010, US3 AC-4, SC-003

---

### VS-09: Save Button Non-Interactive When Disabled

**Steps**:
1. Trigger a validation error (VS-06)
2. With the button in disabled state, tap the "Save Changes" button area

**Expected**:
- Nothing happens; no Bloc event dispatched; no navigation

**Validates**: FR-011, US3 AC-5

---

### VS-10: Fitness Goal Picker

**Steps**:
1. Navigate to Profile screen (form loaded)
2. Tap the Fitness Goal field

**Expected**:
- A bottom sheet or picker opens with three options: `'Build Muscle'`, `'Lose Weight'`, `'General Fitness'`
3. Select `'Lose Weight'`

**Expected**:
- Bottom sheet dismisses; Fitness Goal field now shows `'Lose Weight'`
4. Tap "Save Changes"

**Expected**:
- Toast appears; re-opening the screen shows `'Lose Weight'` persisted

**Validates**: FR-004, US2 AC-4

---

### VS-11: Navigate to Log Out

**Steps**:
1. Navigate to Profile screen (any loaded state)
2. Tap "Log Out"

**Expected**:
- Navigation to SCR-26 (Logout Confirmation) occurs
- No logout, no data clearing, no profile change on this screen

**Validates**: FR-013, US4 AC-1

---

### VS-12: Profile Load Error and Retry

**Setup**: Inject a read failure — e.g., mock `ProfileLocalDataSource.getProfile()` to throw.

**Steps**:
1. Navigate to Profile screen
2. Observe error state
3. Tap "Retry"

**Expected — error state**:
- Alert-triangle icon (40×40, danger color)
- Title: `'Couldn\'t load your profile'`
- Body: descriptive error message
- Retry button (lime bg, ≥44pt tap target)
- Back arrow functional; no bottom nav bar

**Expected — after Retry**:
- Skeleton reappears
- Resolves to form (or error again on repeated failure)

**Validates**: FR-014, FR-015, SC-005, US5 AC-1–AC-4

---

### VS-13: Retry Debounce (Load Error)

**Setup**: Same as VS-12; slow down the use case artificially.

**Steps**:
1. Navigate to error state
2. Tap Retry twice rapidly

**Expected**:
- Only one load cycle fires (one skeleton transition)
- No duplicate `ProfileLoadRequested` events

**Validates**: FR-016, US5 AC-5

---

### VS-14: Profile Save Error and Retry

**Setup**: Inject a write failure — mock `ProfileLocalDataSource.saveProfile()` to throw.

**Steps**:
1. Navigate to Profile screen; form loads
2. Edit display name; tap "Save Changes"
3. Observe save error state
4. Tap "Retry"

**Expected — save error state**:
- Full-screen error card: `'Couldn\'t save your profile'` title, descriptive body, Retry button
- Form is NOT visible (hidden by error card)
- Edited values are NOT lost (held in `ProfileSaveError.profile`)

**Expected — after Retry**:
- Bloc re-attempts write with same profile values
- On success: toast appears + form returns with saved values
- On repeated failure: error card shown again

**Validates**: FR-022, FR-023, US2 AC-6

---

### VS-15: Back Arrow in All States

**Steps**:
1. Navigate to Profile screen while Loading → press back
2. Navigate again; wait for form → press back
3. Navigate again; trigger load error → press back

**Expected (all three)**:
- App returns to SCR-06 (Home Dashboard)
- No crash; no bottom nav bar visible in any state

**Validates**: FR-018, US1 AC-2, US5 AC-6

---

## Zero Drift Writes Verification (Read-Only States)

After loading the profile and NOT tapping "Save Changes", navigate away. Verify via debug tooling that zero `user_profiles` writes occurred during the read-only visit.

**Validates**: FR-019 (Drift-only; no side effects on read)
