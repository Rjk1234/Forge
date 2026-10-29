# Feature Specification: SCR-25 Profile / Account

**Feature Branch**: `001-scr-25-profile-account`

**Created**: 2026-09-24

**Status**: Draft

**Input**: User description: "mobile spec for SCR-25"

**Design Reference**: `specs/SCR-25-Profile-Account/design/spec.md`  
**Entry**: SCR-06 Home Dashboard → profile entry point  
**Exit**: Back → SCR-06 · Log Out → SCR-26 (Logout Confirmation)

---

## Clarifications

### Session 2026-09-24

- Q: When the Drift write fails on "Save Changes", what does the user see? → A: Full-screen error card (same layout as read-failure — title "Couldn't save your profile", descriptive body, Retry button); form is hidden; Retry re-attempts the write using the in-flight profile data.
- Q: For a first-time user with no saved profile record, what does the form show? → A: Display name and height/weight fields are empty; fitness goal shows no option selected (placeholder/hint state); experience level defaults to "Beginner" pre-selected. No distinct Bloc state needed — same `ProfileLoaded` state with empty/default values.
- Q: Should the "Save Changes" button be guarded against double-tap while a Drift write is in flight? → A: Yes — the Save button MUST be disabled while the write is in progress; it re-enables when the write resolves (success or error). A distinct saving-in-progress state drives this in the Bloc.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Profile Loading & Display (Priority: P1)

When the user opens the Profile screen, the app immediately shows an animated loading skeleton while it reads their saved profile data locally. Once the read completes successfully, the four profile fields (display name, fitness goal, experience level, and height/weight) appear pre-filled with the user's stored values, ready for editing.

**Why this priority**: Without data loading, the screen cannot function at all. This story delivers the baseline populated form from which all edit/save interactions originate.

**Independent Test**: Open the Profile screen with at least one previously saved profile record in local storage. The loading skeleton must appear immediately (no blank frame), then resolve to the form with all four fields pre-filled. Back arrow must return to SCR-06. No bottom navigation bar is visible.

**Acceptance Scenarios**:

1. **Given** the user has a saved profile in local storage, **When** they open the Profile screen, **Then** a skeleton loading animation appears immediately and transitions to a populated, editable form showing display name, fitness goal, experience level, and height/weight.
2. **Given** the profile form is visible, **When** the user taps the back arrow, **Then** they are returned to SCR-06 with no changes applied.
3. **Given** the Profile screen is open in any state, **Then** no bottom navigation bar is visible.
4. **Given** the profile was saved in a prior session, **When** the user reopens the Profile screen, **Then** the fields reflect the values from the last successful save.

---

### User Story 2 — Edit and Save Profile (Priority: P2)

The user edits one or more profile fields and taps "Save Changes". If all fields are valid, the changes are saved to local storage and a brief confirmation toast appears. The form stays visible with the updated values.

**Why this priority**: Editing and saving is the primary purpose of this screen. Without it, the screen is read-only with no utility.

**Independent Test**: Open the profile form (US1 complete), modify the display name and experience level, tap "Save Changes". Confirm the toast "Profile saved" appears briefly. Navigate away and re-open the Profile screen; verify the updated values are still present.

**Acceptance Scenarios**:

1. **Given** the profile form is populated, **When** the user edits the display name and taps "Save Changes", **Then** local storage is updated, the confirmation toast "Profile saved" appears, and the form fields reflect the new values.
2. **Given** the profile form is populated, **When** the user changes the experience level segment and taps "Save Changes", **Then** the selected segment is saved; re-opening the screen shows the saved level.
3. **Given** the profile form is populated, **When** the user taps "Save Changes" without making any changes, **Then** local storage is written with the same values and the toast appears (no change-detection block for MVP).
4. **Given** the fitness goal field, **When** the user opens the goal picker and selects a different option, **Then** the selection is reflected in the field and saved on next "Save Changes".
5. **Given** the confirmation toast is visible, **Then** it auto-dismisses after approximately 2–3 seconds; the screen remains in the editable Main state with updated field values.
6. **Given** a Drift write failure occurs on "Save Changes", **Then** the form is replaced by a full-screen error card with title "Couldn't save your profile", a descriptive body, and a Retry button; tapping Retry re-attempts the write with the same edited values without requiring the user to re-enter the form.

---

### User Story 3 — Invalid Height or Weight Blocks Save (Priority: P3)

If the user enters a negative number or non-numeric text in the height or weight field and taps "Save Changes", the save is blocked. The invalid field is visually highlighted, an inline error message appears below it, and the Save button switches to a disabled appearance with a helper note. The error clears when the user corrects the value and saves successfully.

**Why this priority**: Prevents corrupted profile data from being stored. Height and weight are the only fields with a defined validation rule in the design.

**Independent Test**: On the populated form, type "-50" in the height field and tap "Save Changes". Confirm: height field is danger-highlighted with error message, Save button is disabled-styled, helper note appears. Type "178" to correct it, tap "Save Changes" again. Confirm: form returns to normal and toast appears.

**Acceptance Scenarios**:

1. **Given** the profile form, **When** the user enters a negative number in the height field and taps "Save Changes", **Then** the height field is visually highlighted as invalid, an inline error message "Enter a valid positive number." appears below it, the Save button appears disabled, and the save is not executed.
2. **Given** the profile form, **When** the user enters non-numeric text in the weight field and taps "Save Changes", **Then** the same inline error pattern applies to the weight field.
3. **Given** the height and weight fields are both invalid, **When** the user taps "Save Changes", **Then** both fields show the invalid highlight and inline error simultaneously.
4. **Given** an invalid field is shown, **When** the user corrects it and taps "Save Changes" with all valid values, **Then** the validation error clears, the save executes, and the toast appears.
5. **Given** the save button is in disabled state, **When** the user taps it, **Then** nothing happens (button is non-interactive).
6. **Given** a height or weight value of zero, **When** the user taps "Save Changes", **Then** the zero value is treated as invalid (same error as a negative number).

---

### User Story 4 — Navigate to Logout Confirmation (Priority: P4)

The user taps "Log Out" on the profile screen and is navigated to the Logout Confirmation screen (SCR-26). No logout action occurs inline on this screen.

**Why this priority**: Logout is an important exit path but depends on a confirmation screen that is a separate feature (SCR-26). This story is a navigation handoff only.

**Independent Test**: On the populated profile form, tap "Log Out". Confirm navigation to SCR-26 occurs. No logout or data-clearing operation happens before the confirmation screen.

**Acceptance Scenarios**:

1. **Given** the profile Main state, **When** the user taps "Log Out", **Then** the app navigates to SCR-26 (Logout Confirmation) without logging the user out or clearing any data.
2. **Given** the user cancels logout on SCR-26 and returns, **Then** the profile screen is still in the state it was left in.

---

### User Story 5 — Profile Load Error with Retry (Priority: P5)

When local data cannot be read on screen entry, the screen shows an error state with a Retry button instead of the skeleton resolving to a form. Tapping Retry re-triggers the load. If the retry succeeds, the form appears; if it fails again, the error state returns.

**Why this priority**: Provides a graceful degradation path that prevents a blank or stuck screen if local storage is unavailable or corrupted.

**Independent Test**: Inject a read failure into the profile data source. Open the Profile screen. Confirm the error state appears (no skeleton resolution to form). Tap Retry. Confirm skeleton re-appears, then resolves to the form (or error again on repeated failure).

**Acceptance Scenarios**:

1. **Given** local storage is unavailable or read fails, **When** the user opens the Profile screen, **Then** an error state is shown with an error title, descriptive body, and Retry button; no partially-populated form is shown.
2. **Given** the error state, **When** the user taps Retry, **Then** the loading skeleton reappears and the profile read is re-attempted.
3. **Given** the retry succeeds, **Then** the editable profile form appears with pre-filled data.
4. **Given** the retry fails again, **Then** the error state is shown again.
5. **Given** double-tapping Retry rapidly, **Then** only one read cycle is triggered (debounce guard prevents duplicate events).
6. **Given** the error state, **When** the user taps the back arrow, **Then** they are returned to SCR-06.

---

### Edge Cases

- What happens when the user enters a decimal value in height or weight (e.g. "76.5")? → Treated as valid; decimal keyboard is shown.
- What happens when the display name field is left empty? → For MVP, an empty string is accepted (no validation on display name length or emptiness).
- What happens when the user taps the back arrow while the form has unsaved edits? → Silent discard; the user navigates away without a confirmation dialog (MVP assumption).
- What happens if the Drift write fails (save fails)? → For MVP, show the same error-state pattern as a read failure ("Couldn't save your profile"); no separate artboard exists for this state.
- What happens when the user taps Save with no edits? → Values are re-written to local storage and the toast appears (no change-detection optimization for MVP).
- What happens on first launch with no saved profile? → Display name and height/weight fields are empty; fitness goal shows no option selected (placeholder/hint); experience level defaults to "Beginner" pre-selected. The same `ProfileLoaded` state is used — no separate Bloc state for a new profile.
- What happens if the profile read succeeds but returns a structurally incomplete record (missing fields)? → Display available values; missing fields render as empty inputs.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Screen MUST display an animated loading skeleton immediately on entry while local profile data is being read.
- **FR-002**: Screen MUST display all four confirmed profile fields — display name, fitness goal, experience level, and height/weight — pre-filled from local storage once the read succeeds.
- **FR-003**: User MUST be able to edit the display name via a text input field.
- **FR-004**: User MUST be able to select a fitness goal from a defined option set (Build Muscle, Lose Weight, General Fitness) via a `showModalBottomSheet` presenting three `ListTile` options.
- **FR-005**: User MUST be able to select an experience level from exactly three options (Beginner, Intermediate, Advanced) via a single-select segmented control.
- **FR-006**: User MUST be able to enter height (in centimetres) and weight (in kilograms) as numeric values in side-by-side input fields.
- **FR-007**: User MUST be able to tap "Save Changes" to persist all four profile fields to local storage.
- **FR-008**: On successful save, the screen MUST display a brief confirmation toast ("Profile saved") that auto-dismisses after approximately 2–3 seconds; the form remains visible with updated values.
- **FR-009**: Saved values MUST be reflected in the form fields immediately after save and MUST persist to the next screen open.
- **FR-010**: If height or weight contains a negative number, zero, or non-numeric text, the save action MUST be blocked and the invalid field(s) MUST be visually highlighted with an inline error message "Enter a valid positive number." directly below the field.
- **FR-011**: The "Save Changes" button MUST appear in a disabled visual state (and be non-interactive) when any height or weight validation error is active; a helper note "Fix the highlighted fields to save." MUST appear below the button in this state.
- **FR-012**: Decimal numeric values in height/weight (e.g. 76.5) MUST be accepted as valid.
- **FR-013**: Tapping "Log Out" MUST navigate the user to SCR-26 (Logout Confirmation) without performing any logout action inline.
- **FR-014**: When local storage cannot be read on entry, the screen MUST display an error state with an error title, descriptive body, and a Retry button instead of resolving the skeleton to the form.
- **FR-015**: Tapping Retry after a read failure MUST re-trigger the local storage read and return the screen to the loading skeleton state.
- **FR-016**: Only one Retry event may be in flight at a time; rapid double-taps MUST NOT dispatch duplicate read or write events (debounce guard applies to both read-retry and save-retry).
- **FR-017**: Screen MUST NOT display a bottom navigation bar; it is a pushed detail screen.
- **FR-018**: Screen MUST display a back arrow that pops the screen and returns the user to SCR-06.
- **FR-019**: All data reads and writes MUST use local storage only; no network calls occur on this screen.
- **FR-020**: The user avatar is a read-only decorative icon; photo upload is not in scope.
- **FR-021**: Display name, fitness goal, and experience level do NOT have defined invalid states; only height and weight have documented validation rules.
- **FR-022**: When a Drift write fails on "Save Changes", the screen MUST display the same full-screen error card layout as a read failure, with title "Couldn't save your profile" and a descriptive body; the form is hidden and the user's edited values are held in memory.
- **FR-023**: Tapping Retry after a write failure MUST re-attempt the Drift write with the same edited profile values that were in flight at the time of failure; no re-entry of the form is required.
- **FR-024**: While a Drift write is in progress (between "Save Changes" tap and write resolution), the "Save Changes" button MUST be disabled and non-interactive; it re-enables when the write resolves to success (toast shown) or failure (error card shown). This prevents duplicate write events from rapid double-taps.

### Key Entities

- **UserProfile**: Represents the user's saved personal identity and reference metrics. Key fields: display name (text), fitness goal (one of three options), experience level (Beginner / Intermediate / Advanced), height in cm (positive number), weight in kg (positive number). Stored in local storage; read and written by this screen.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Loading skeleton appears within the same frame as the screen push (no blank state visible between navigation and skeleton appearance).
- **SC-002**: User successfully saves at least one edited profile field; the confirmation toast appears and the updated value is present on the next screen open.
- **SC-003**: An invalid height or weight entry correctly blocks the save action on 100% of attempts; re-entering a valid value and tapping Save clears the error and executes the save.
- **SC-004**: Tapping "Log Out" navigates to SCR-26 without any data change on the Profile screen; back navigation from all states (Loading, Main, Validation, Error) returns the user to SCR-06.
- **SC-005**: A profile read failure correctly shows the error state; tapping Retry re-enters the loading cycle; a successful retry transitions to the populated form.
- **SC-006**: Saved profile values are visible on re-entry without requiring any additional user action (persistence verified across screen open/close cycles).

---

## Assumptions

- All data is stored and read from local storage only; no network connectivity is required or used on this screen.
- Height and weight units are metric only for MVP: height in centimetres (cm), weight in kilograms (kg). Imperial units are out of scope.
- The fitness goal option set is: Build Muscle, Lose Weight, General Fitness. The picker mechanism (native iOS/Android picker vs. bottom-sheet) is to be decided at implementation time.
- An empty string for display name is accepted for MVP (no length or non-empty validation on display name).
- Decimal height/weight values (e.g. 76.5 kg) are valid; a numeric keyboard with decimal support is shown for these fields.
- Zero values for height or weight are treated as invalid and show the same inline error as a negative number.
- Toast auto-dismisses after approximately 2–3 seconds (standard mobile convention; exact duration is an implementation detail).
- Re-validation of height and weight occurs on save-tap only, not on keystroke or blur; fields return to the valid appearance once the user corrects them and taps Save successfully.
- Tapping Save with no changes re-writes the same values and shows the toast (no change-detection or "nothing to save" optimisation for MVP).
- Back arrow with unsaved changes silently discards edits and returns to SCR-06; no discard-confirmation dialog for MVP.
- Drift write failure (save fails) shows a full-screen error card identical in layout to the read-failure card, with copy "Couldn't save your profile"; Retry re-attempts the write with the in-memory edited values (FR-022, FR-023).
- The user avatar is a decorative static icon for MVP; no tap action, no photo-upload affordance.
- A first-time user with no saved profile sees: display name and height/weight as empty text inputs; fitness goal in a no-selection (placeholder/hint) state; experience level with "Beginner" pre-selected by default. The same `ProfileLoaded` Bloc state covers both new and existing profiles.
- The `avatar-name` CSS class in the artboard is intentionally absent from the rendered layout; the display name appears only in the text input below the avatar.
