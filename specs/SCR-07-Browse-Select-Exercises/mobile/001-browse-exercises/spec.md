# Feature Specification: SCR-07 Browse & Select Exercises

**Feature Branch**: `SCR-07-browse-exercises`

**Created**: 2026-09-17

**Status**: Draft

**Design Reference**: [SCR-07 Design Spec](../../design/spec.md) — 5 artboards: Loading, Main (Browse), PickerMode, Empty, Error

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View Exercise Catalogue (Priority: P1)

As a user who has unlocked the app, I want to see all available exercises in the catalogue so that I can discover what exercises are available in ForgeApp.

When I open the exercise catalogue screen the app immediately shows a skeleton loading state while reading data from local storage. Once loaded, I see a scrollable list of all seeded exercises, each showing the exercise name, its type (Weighted, Time-based, or Bodyweight), and a type-coloured dot for quick visual recognition. If the catalogue cannot be loaded, I see a clear error message and a Retry button.

**Why this priority**: The catalogue list is the foundational state that all other user stories depend on. Without a working populated list, search, filter, and picker mode cannot be tested.

**Independent Test**: Can be tested by navigating to the exercise catalogue in browse mode with no search text and no active filter, verifying the full list renders with correct exercise names and type labels.

**Acceptance Scenarios**:

1. **Given** I open the exercise catalogue screen, **When** the data is still loading from local storage, **Then** I see 6 skeleton exercise rows with a shimmer animation and 4 skeleton filter chip placeholders, and the search bar is visible but not interactive.
2. **Given** the catalogue has loaded successfully, **When** I view the default screen, **Then** I see a scrollable list of all seeded exercises, each with name, type dot, and type label; the "All" filter chip is active; no search text is entered.
3. **Given** I am in the loaded catalogue, **When** I tap the Back icon, **Then** I am returned to the previous screen.

---

### User Story 2 — Search and Filter Exercises (Priority: P2)

As a user viewing the exercise catalogue, I want to search by name and filter by exercise type so that I can quickly find the specific exercise I am looking for.

I can type in a search field at the top of the screen and the list updates on every keystroke to show only exercises whose names contain my text. I can also tap one of four filter chips — All, Weighted, Time-based, or Bodyweight — to narrow the list to that type. Search and filter work together: if I have a filter active and then type in the search field, only exercises matching both the type and the search text appear. When my combination returns no results, I see a friendly empty state message.

**Why this priority**: Search and filter dramatically reduce the friction of finding a specific exercise, especially as the catalogue grows. Builds directly on the populated list (US1).

**Independent Test**: Can be tested by typing a known exercise name into the search field and confirming the list filters to matching exercises only; and by tapping a type chip and confirming only that type is shown.

**Acceptance Scenarios**:

1. **Given** the catalogue is loaded and showing all exercises, **When** I type a partial exercise name into the search field, **Then** the list immediately filters to exercises whose names contain my text (case-insensitive).
2. **Given** the catalogue is loaded, **When** I tap the "Weighted" filter chip, **Then** the list narrows to weighted exercises only and the "Weighted" chip becomes visually active (lime background).
3. **Given** I have an active type filter and I also type in the search field, **When** no exercises match both conditions, **Then** I see the empty state: "No exercises match your search" with subtitle "Try a different name or clear the filter."
4. **Given** I have typed a search query, **When** I clear the search field, **Then** the full list for the currently active filter chip is restored.
5. **Given** only one chip can be active at a time, **When** I tap a different chip while one is already active, **Then** the previously active chip becomes inactive and the newly tapped chip becomes active.

---

### User Story 3 — Add Exercise to Workout Plan (Picker Mode) (Priority: P3)

As a user editing a workout plan on the Create/Edit Plan screen, I want to browse the exercise catalogue and select an exercise to add to my in-progress plan so that I can build my workout.

When the Create/Edit Plan screen opens the exercise catalogue in picker mode, I see a banner at the top showing the name of the plan I am building. Each exercise row has a circular "+" button instead of a chevron. When I tap "+" on an exercise, it is immediately added to my plan and I am returned to the plan editor. If I decide not to add anything, I tap Back and return to the plan editor with the plan unchanged.

**Why this priority**: Picker mode is the primary way users add exercises to plans — it is the core workout-building flow. Depends on US1 (catalogue loading) and US2 (search/filter to find the right exercise).

**Independent Test**: Can be tested by navigating from the Create/Edit Plan screen to the exercise catalogue in picker mode, tapping "+" on one exercise, and verifying the exercise appears in the plan editor's exercise list upon return.

**Acceptance Scenarios**:

1. **Given** I am editing a plan and the catalogue opens in picker mode, **When** the screen loads, **Then** I see a banner saying "Adding an exercise to [Plan Name]" and each exercise row shows a circular "+" button instead of a chevron.
2. **Given** I am in picker mode, **When** I tap the "+" button on an exercise row, **Then** the exercise is immediately added to my in-progress plan and I am returned to the plan editor screen showing the newly added exercise.
3. **Given** I am in picker mode, **When** I tap the Back icon without selecting any exercise, **Then** I am returned to the plan editor with no changes to the plan.
4. **Given** I am in picker mode and use search/filter, **When** I find and tap "+" on an exercise, **Then** the exercise is added and I return to the plan editor (search/filter state does not block the add action).

---

### User Story 4 — Recover from Catalogue Load Failure (Priority: P4)

As a user who encounters a local data read failure, I want to see a clear error message and be able to retry loading so that the failure does not leave me stuck.

If the exercise catalogue cannot be read from local storage, I see an error card with a human-readable message and a Retry button. Tapping Retry takes me back to the skeleton loading state and attempts to reload the catalogue. The Back button remains available so I can exit the screen even in the error state.

**Why this priority**: Error recovery is essential for a resilient user experience but is a lower priority than the core catalogue and picker flows. Depends on US1 (loading foundation).

**Independent Test**: Can be tested by simulating a database read failure and confirming the error card renders with the correct copy and that tapping Retry triggers a fresh load attempt.

**Acceptance Scenarios**:

1. **Given** the Drift catalogue read fails, **When** the screen finishes the load attempt, **Then** I see an error card with the title "Couldn't load the exercise catalogue" and a Retry button; the search bar and filter chips are not shown.
2. **Given** I see the error state, **When** I tap Retry, **Then** the screen returns to the skeleton loading state and attempts to reload the catalogue.
3. **Given** the retry succeeds, **When** the catalogue loads, **Then** the screen transitions to the populated state with all exercises visible.
4. **Given** I am in the error state in picker mode, **When** I tap the Back icon, **Then** I am returned to the plan editor screen (the error does not trap me).

---

### Edge Cases

- What happens when the search query returns no results for the currently active filter chip? → Show empty state (US2 AC-3).
- What happens if the exercise catalogue table has zero records (seed did not run)? → Use the same empty state as no-search-results; the message "No exercises match your search" may be misleading but is acceptable for the POC scope.
- What happens if the user taps "+" on an exercise in picker mode whose ID is not found in the catalogue (stale in-memory reference)? → Silently reject the selection; no navigation occurs; the exercise is not added.
- What happens if the user adds the same exercise twice in picker mode? → Allow duplicates; the user may want the same exercise with different targets.
- What happens with very long exercise names? → Truncate at 1 line with an ellipsis.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The screen MUST display a skeleton loading state (6 shimmer rows, 4 skeleton chips, non-interactive search bar) while the exercise catalogue is being read from local storage.
- **FR-002**: The screen MUST display the full seeded exercise catalogue as a scrollable list once loaded, with each row showing exercise name, type-coloured dot, and type label.
- **FR-003**: The screen MUST support a live-search text field that filters the exercise list by case-insensitive substring match on exercise name, updating on each keystroke.
- **FR-004**: The screen MUST provide four filter chips — "All", "Weighted", "Time-based", "Bodyweight" — where exactly one chip is active at a time; default is "All".
- **FR-005**: Search and filter MUST work in combination: when a type filter is active, search narrows only within that type's exercises.
- **FR-006**: When the active search + filter combination yields zero exercises, the screen MUST display an empty state with the message "No exercises match your search" and subtitle "Try a different name or clear the filter."
- **FR-007**: The screen MUST support two modes — browse mode (default, chevron trailing affordance per row) and picker mode (circular "+" button per row, picker banner visible).
- **FR-008**: In picker mode, the screen MUST show a banner displaying the name of the in-progress plan being built.
- **FR-009**: In picker mode, tapping "+" on an exercise row MUST immediately add the exercise to the in-progress plan and return the user to the plan editor screen.
- **FR-010**: If the exercise catalogue cannot be read from local storage, the screen MUST display an error card with the message "Couldn't load the exercise catalogue" and a Retry button; the search bar and filter chips MUST NOT be shown in this state.
- **FR-011**: Tapping Retry from the error state MUST re-trigger the catalogue load and return the screen to the skeleton loading state.
- **FR-012**: The Back icon MUST be visible and functional in all states (loading, populated, empty, error) in both modes.
- **FR-013**: The exercise catalogue is read-only — no creation, editing, or deletion of exercises is permitted from this screen.
- **FR-014**: In browse mode, exercise rows MUST be rendered as non-interactive elements — no tap handler, no ink ripple, and no touch feedback. The chevron-right icon is purely decorative and does not trigger any action.

### Key Entities

- **Exercise**: A seeded, read-only catalogue entry with a unique identifier, a display name, and an exercise type (Weighted, Time-based, or Bodyweight).
- **Exercise Type**: An enum with three values — Weighted, Time-based, Bodyweight — each associated with a distinct colour token for the type dot (cyan, lime, muted respectively).
- **Picker Context**: In-memory state passed from the plan editor identifying the in-progress plan by name; used only during a single picker session and not persisted.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can navigate to the exercise catalogue and see the full list of exercises within 2 seconds of screen entry on a device with existing Drift data.
- **SC-002**: A user can find a specific exercise by partial name search within 2 interactions from entering the catalogue (one tap to focus the search field, one type action).
- **SC-003**: A user can add an exercise to a plan in picker mode within 3 interactions from entering the catalogue (focus search or tap chip → locate exercise → tap "+").
- **SC-004**: The catalogue screen correctly reflects all 5 states — Loading, Populated (Browse), Populated (Picker), Empty, Error — with zero blank or unhandled transitions between states.
- **SC-005**: Tapping Retry in the error state consistently re-attempts the catalogue load with no additional user action required.

---

## Assumptions

- The exercise catalogue is fully seeded at app launch by the existing `ExerciseSeedService`; the catalogue screen never writes to the catalogue table.
- Picker mode is entered exclusively from the Create/Edit Workout Plan screen (SCR-09) via a push navigation with the plan name as a parameter; no other screen enters picker mode.
- Browse mode is entered from the Plans tab (SCR-08) or any future "Browse exercises" entry point; the SCR-06 Quick Links grid does not currently have a direct browse-exercises tile.
- In picker mode, the exercise is appended to the in-progress plan's exercise list in memory; persistence does not occur until the user saves the plan on the plan editor screen.
- The seeded exercise catalogue is non-empty under normal operation; a zero-record catalogue is treated as an application data error, not a normal empty state.
- Exercise name search uses a 300 ms debounce as a standard default for live filtering.
- Duplicate exercises in a plan are permitted (user may want the same movement twice with different rep/weight targets).
- The screen is portrait-only; no landscape or tablet layout is required for ForgeApp v1.0.
- All data reads are from the database only — no network call is made at any point during catalogue display.

---

## Clarifications

### Session 2026-09-17

- Q: In browse mode, when a user taps an exercise row, what should happen? → A: Row is completely static — no tap handler, no ink ripple, no visual feedback on touch. Reflected in FR-014.
