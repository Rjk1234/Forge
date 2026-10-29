# Feature Specification: Plan Detail (SCR-10)

**Feature Branch**: `SCR-10-Plan-Detail`

**Created**: 2026-09-19

**Status**: Draft

**Input**: User description: "mobile spec for SCR-10"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View Plan Details (Priority: P1)

A user taps a plan card on the Plans List (SCR-08), or is redirected there after creating or editing a plan (SCR-09). They see a read-only screen that displays the plan's name, total exercise count, and the complete target parameters for every exercise in the plan — sets, reps or duration, weight (for weighted exercises), and rest period. All values are displayed in a clean, scannable layout. Nothing on this screen is editable.

**Why this priority**: Viewing the plan is the primary reason a user opens this screen. It is the single most important piece of functionality — the user needs to know what their workout consists of before they can take any further action.

**Independent Test**: Can be fully tested by seeding Drift with a plan containing exercises of all three types (Weighted, Time-based, Bodyweight) and verifying that the screen displays correct values for each field without any interactive controls.

**Acceptance Scenarios**:

1. **Given** a plan named "Push Day" with 3 exercises exists, **When** the user opens the plan detail, **Then** they see "Push Day" as the screen title and "3 exercises" as the subtitle.
2. **Given** a Weighted exercise with 4 sets, 8 reps, 60 kg, and 90s rest, **When** the exercise card is displayed, **Then** all four fields — Sets (4), Reps (8), Weight (60 kg), Rest (90s) — are visible and read-only.
3. **Given** a Time-based exercise with 3 sets, 00:45 duration, and 60s rest, **When** the exercise card is displayed, **Then** Sets (3), Duration (00:45), and Rest (60s) are shown; no weight field appears.
4. **Given** a Bodyweight exercise with 3 sets, 15 reps, and 60s rest, **When** the exercise card is displayed, **Then** Sets (3), Reps (15), and Rest (60s) are shown; no weight or duration field appears.
5. **Given** a plan with many exercises that exceed the screen height, **When** the user scrolls the exercise list, **Then** the app bar and action footer remain fixed while the exercise list scrolls.
6. **Given** an exercise whose ID no longer exists in the exercise catalogue (deleted exercise), **When** the plan detail opens, **Then** a placeholder card reading "Exercise unavailable" appears in place of that exercise; the other exercises display correctly.
7. **Given** a plan with 0 exercises, **When** the plan detail opens, **Then** the exercise section shows the "EXERCISES" label with no exercise cards; the "Start Workout" button is visually disabled.

---

### User Story 2 — Navigate to Downstream Actions (Priority: P2)

From the populated plan detail, the user can proceed to four downstream actions: editing the plan, requesting deletion, scheduling the plan, or starting a workout. Each action is accessible from a clearly labelled button. After completing or cancelling a child screen, the plan detail reflects any changes made (e.g. plan name or exercise list updated via edit, or plan still present after a cancelled deletion).

**Why this priority**: The plan detail screen is also a hub for all plan-level actions. Without navigation to Edit, Delete, Schedule, and Start Workout, the screen has no actionability beyond reading — the user would be stuck.

**Independent Test**: Can be fully tested by tapping each of the four action controls and verifying the correct destination screen is reached with the correct `planId` passed through. The data-freshness aspect (re-reading on return) can be tested separately by returning from a child screen and confirming updated data is shown.

**Acceptance Scenarios**:

1. **Given** the populated plan detail, **When** the user taps the Edit icon button, **Then** the Create/Edit Plan screen (SCR-09) opens in edit mode with the current `planId`.
2. **Given** the populated plan detail, **When** the user taps the Delete icon button, **Then** the Delete Plan Confirmation screen (SCR-11) opens with the current `planId`.
3. **Given** the populated plan detail, **When** the user taps "Start Workout", **Then** the Workout Pre-Start Overview screen (SCR-15) opens with the current `planId`.
4. **Given** the populated plan detail, **When** the user taps "Schedule", **Then** the Assign/Edit Schedule screen (SCR-13) opens with the current `planId`.
5. **Given** the user opened SCR-09 from the plan detail and edited the plan name, **When** they return to the plan detail, **Then** the updated plan name is displayed.
6. **Given** the user opened SCR-11 and cancelled deletion, **When** they return to the plan detail, **Then** the plan is still shown unchanged.
7. **Given** the user confirmed deletion in SCR-11, **When** the deletion completes, **Then** they are returned directly to the Plans List (SCR-08); the plan detail is no longer visible.
8. **Given** the populated plan detail, **When** the user taps the back chevron, **Then** they return to the Plans List (SCR-08).

---

### User Story 3 — Loading Skeleton (Priority: P3)

While the app fetches the plan from local storage, the user sees a skeleton placeholder that mirrors the layout of the populated screen — including a skeleton app bar (with a live back chevron), two shimmer title lines, three shimmer exercise cards, and two skeleton footer buttons. When the data loads, the skeleton is replaced with the populated layout.

**Why this priority**: The skeleton prevents a jarring blank screen or abrupt content pop-in. It communicates that the app is working and sets layout expectations. Although database reads are typically fast, skeleton coverage is important on older devices or large plan data.

**Independent Test**: Can be fully tested by simulating a delayed database read and verifying the skeleton layout is rendered before the data arrives, the back chevron is tappable during loading (returning to SCR-08), and the skeleton is replaced by the populated view once data is available.

**Acceptance Scenarios**:

1. **Given** the plan detail is opened, **When** the database read has not yet completed, **Then** a skeleton layout is displayed containing shimmering placeholder lines and cards.
2. **Given** the skeleton is showing, **When** the user taps the back chevron, **Then** the app navigates back to the Plans List (SCR-08) immediately.
3. **Given** the database read completes successfully, **When** the data arrives, **Then** the skeleton is replaced by the populated plan detail without a blank intermediate state.
4. **Given** the database read completes before the skeleton has rendered (sub-frame completion), **When** the screen appears, **Then** the populated layout is shown directly with no skeleton flash.

---

### User Story 4 — Error and Not-Found State (Priority: P4)

If the requested plan cannot be found (e.g. it was deleted by another flow) or the local storage read fails for any reason, the user sees a clear, non-technical message explaining the plan is unavailable. They are offered a single recovery action: return to the Plans List. There is no retry option on this screen.

**Why this priority**: Robustness against stale navigation links and read failures is necessary for a trustworthy app experience. Without this, the user could be stranded on a blank or crashed screen.

**Independent Test**: Can be fully tested by providing a `planId` that does not exist in storage, and a separate scenario where the storage read throws an exception, then verifying both cases display the same error UI with the "Back to Plans" button navigating to SCR-08.

**Acceptance Scenarios**:

1. **Given** the user navigates to a `planId` that does not exist in local storage, **When** the screen loads, **Then** the error state is displayed with the message "This plan is no longer available".
2. **Given** the local storage read throws an exception, **When** the screen loads, **Then** the same error state is displayed with identical copy.
3. **Given** the error state is shown, **When** the user taps "Back to Plans", **Then** they navigate to the Plans List (SCR-08).
4. **Given** the error state is shown, **When** the user taps the back chevron in the app bar, **Then** they also navigate to the Plans List (SCR-08).
5. **Given** the error state is shown, **Then** no Edit or Delete icon buttons are visible.

---

### Edge Cases

- What happens when a `planId` in the exercise list references an exercise that was deleted from the catalogue? → A placeholder card "Exercise unavailable" appears; the plan still opens and other exercises display normally.
- How does the screen handle a plan with 0 exercises? → The "EXERCISES" label is shown with no cards; "Start Workout" is visually disabled.
- How does the system handle a very long plan name? → The title wraps to a maximum of 2 lines; additional text is truncated with an ellipsis.
- What if both the plan and exercise catalogue tables are unavailable? → Falls through to the Error/Not-Found state.
- What happens if the user returns from SCR-09 (Edit) and the plan was renamed? → The screen re-reads from local storage on return and reflects the updated name.
- How are exercise type colours assigned? → Weighted → cyan, Time-based → lime, Bodyweight → muted (grey). These colours are design-token values shared with SCR-09.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The screen MUST display the plan name, exercise count, and all exercises with their target parameters in a read-only layout.
- **FR-002**: Each exercise card MUST show the correct fields for its type: Weighted shows Sets + Reps + Weight + Rest; Time-based shows Sets + Duration + Rest; Bodyweight shows Sets + Reps + Rest.
- **FR-003**: All field values MUST be formatted correctly: weight as "N kg", rest as "Ns", duration as "mm:ss", sets and reps as plain integers.
- **FR-004**: The screen MUST show a skeleton placeholder while local data is being fetched.
- **FR-005**: The back chevron MUST be tappable during the loading skeleton state and MUST navigate to SCR-08.
- **FR-006**: The screen MUST show a clear error/not-found state when the plan cannot be retrieved, covering both a missing `planId` and a storage read failure.
- **FR-007**: The error state MUST display "Back to Plans" as the sole recovery action, navigating to SCR-08.
- **FR-008**: The populated screen MUST provide an Edit icon button that navigates to SCR-09 with the current `planId`.
- **FR-009**: The populated screen MUST provide a Delete icon button that navigates to SCR-11 with the current `planId`.
- **FR-010**: The populated screen MUST provide a "Start Workout" button that navigates to SCR-15 with the current `planId`.
- **FR-011**: The populated screen MUST provide a "Schedule" button that navigates to SCR-13 with the current `planId`.
- **FR-012**: The screen MUST re-read plan data from local storage when the user returns from a child screen (SCR-09 or SCR-11) so the displayed data is always current.
- **FR-013**: When a plan has 0 exercises, the "Start Workout" button MUST be visually disabled and non-interactive.
- **FR-014**: When an exercise in the plan cannot be resolved from the exercise catalogue, a placeholder card MUST be shown for that exercise; other exercises MUST still display correctly.
- **FR-015**: The exercise list area MUST scroll while the app bar and footer remain fixed.
- **FR-016**: The screen MUST NOT make any network call. All data comes from local storage only.

### Key Entities

- **WorkoutPlanDetail**: A workout plan and its ordered list of exercises, identified by `planId`. Attributes: plan name, exercise count, list of `PlanExercise`.
- **PlanExercise**: A single exercise entry within a plan. Attributes: `exerciseId`, exercise name (resolved from catalogue), exercise type (Weighted / Time-based / Bodyweight), target sets, target reps or duration, target weight (Weighted only), rest period.
- **ExerciseType**: An enumeration — Weighted, Time-based, Bodyweight — that determines which fields are shown on an exercise card.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user who taps a plan card can read all target values for all exercises within 2 seconds on a representative device.
- **SC-002**: 100% of navigation taps (Edit, Delete, Start Workout, Schedule, Back) reach the correct destination screen with the correct `planId` on the first tap.
- **SC-003**: The loading skeleton appears immediately (within one frame) with no blank screen flash when the database read is in progress.
- **SC-004**: The error state is displayed correctly for both known error causes (missing plan, read exception) with identical user-facing copy.
- **SC-005**: No data staleness: after returning from SCR-09 (edit) or SCR-11 (cancel delete), the plan detail always reflects the latest stored data.
- **SC-006**: Zero network calls are made for any path through this screen, measurable by monitoring outbound connections during any user flow.

## Assumptions

- The `planId` is always passed into the screen from the calling screen (SCR-08 or SCR-09); the plan detail screen does not discover or select its own `planId`.
- Drift is the only data source; there is no network fallback and none is needed (fully offline app).
- The exercise catalogue is a read-only, seeded table; plan exercises reference it by `exerciseId`.
- Both "plan missing" and "read failure" resolve to the same Error/Not-Found UI because the recovery action (return to SCR-08) is identical for both. No distinction is shown to the user.
- After a confirmed deletion in SCR-11, the deletion flow pops both SCR-11 and SCR-10, landing on SCR-08. SCR-10 is not responsible for detecting its own plan's deletion.
- The plan detail screen is pushed onto the navigation stack (not presented modally), consistent with SCR-09.
- The skeleton always shows 3 placeholder exercise cards regardless of the actual plan exercise count, because the count is unknown before the database read completes.
- "Start Workout" is always rendered in the footer (visible) for all valid plans, and is only disabled when the plan has 0 exercises.
- The exercise type colour coding (cyan = Weighted, lime = Time-based, muted = Bodyweight) is consistent with the design token set shared across SCR-09 and SCR-10.
