# Feature Specification: SCR-08 Workout Plans List

**Feature Branch**: `SCR-08-workout-plans-list`

**Created**: 2026-09-17

**Status**: Draft

**Design Reference**: [SCR-08 Design Spec](../../design/spec.md) — 4 artboards: Loading.dc.html, Main.dc.html, Empty.dc.html, Error.dc.html

---

## Clarifications

### Session 2026-09-17

- Q: Plan list sort order → A: Newest first (most recently created plan appears at the top)
- Q: Loading state when returning from child screen (SCR-09/SCR-10) → A: Keep existing list visible; replace silently when re-read completes (optimistic re-read)
- **Terminology correction (codebase inspection)**: The spec originally referenced `exerciseIds: List<String>` (per design spec OQ-9). Inspection of the existing storage record confirms the field is `planExercises: List<PlanExerciseRecord>`. The exercise count is `planExercises.length`. FR-005 and Key Entities updated accordingly.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View Plans (Loading & Populated) (Priority: P1)

As a user who has unlocked the app, I want to open the Plans tab and immediately see my workout plans so that I can choose which plan to follow today.

When I tap the Plans tab in the bottom navigation bar the screen immediately shows a skeleton loading state while local storage is read. Once the read completes and I have one or more plans, a scrollable list appears. Each plan row shows the plan name in bold and the exercise count below it, with a right-pointing chevron. The bottom navigation bar remains visible in all states.

**Why this priority**: The populated plans list is the root of the Workout Plan Management feature. All downstream screens (plan detail, create/edit plan) depend on arriving from this screen. Without a working list there is no entry point into the feature.

**Independent Test**: Can be tested by seeding Drift with two or more plans and navigating to the Plans tab. The skeleton renders immediately; after the read completes the plan names, exercise counts, and chevrons are visible.

**Acceptance Scenarios**:

1. **Given** I tap the Plans tab, **When** the database read is in progress, **Then** I see 4 skeleton plan cards with a shimmer animation, a skeleton placeholder where the "+" FAB would appear, and the bottom nav remains visible with inactive tabs at reduced opacity.
2. **Given** Drift contains at least one plan, **When** the read completes, **Then** I see a scrollable plan list; each row shows the plan name (16 pt/800), the exercise count ("N exercises" or "1 exercise"), a right chevron; and the lime "+" FAB appears in the app bar.
3. **Given** a plan has zero exercises, **When** the list renders, **Then** that row shows "0 exercises" and is otherwise identical to other rows.
4. **Given** a plan name is very long, **When** the list renders, **Then** the name is truncated at 1 line with a trailing ellipsis.
5. **Given** the Plans tab has already loaded and is showing a plan list, **When** the user returns from SCR-09 or SCR-10 back to the Plans tab, **Then** the existing list remains visible (no skeleton flash) and is silently replaced with the updated list once the Drift re-read completes.

---

### User Story 2 — Empty State: Create First Plan (Priority: P2)

As a user who has not yet created any workout plans, I want to see a helpful prompt with a clear call-to-action so that I can start building my first plan.

When the Plans tab loads and local storage contains no plans, I see a centred empty state: an icon, the title "No workout plans yet", a subtitle prompting me to create my first plan, and a lime "Create a workout plan" button. There is no "+" FAB in this state. Tapping the button takes me to the Create / Edit Workout Plan screen.

**Why this priority**: An empty state with a clear CTA is essential for new users and for users who have deleted all their plans. It directly precedes the Plan creation flow.

**Independent Test**: Can be tested by launching the app with an empty `workout_plans` table and navigating to the Plans tab. The empty state renders with the correct icon, title, subtitle, and lime CTA button.

**Acceptance Scenarios**:

1. **Given** the `workout_plans` table is empty and the read succeeds, **When** the screen resolves, **Then** I see the centred empty state with a 60 pt list icon, the title "No workout plans yet", the subtitle "Build your first workout plan to see it listed here.", and a lime "Create a workout plan" button. No "+" FAB is visible.
2. **Given** I see the empty state, **When** I tap "Create a workout plan", **Then** I am taken to the Create / Edit Workout Plan screen (SCR-09) in create mode.

---

### User Story 3 — Navigate to Plan Detail (Priority: P3)

As a user viewing my list of workout plans, I want to tap a plan and open its detail view so that I can see its exercises and start or edit the workout.

Each plan card is tappable across its full width. Tapping any part of the card navigates to the Plan Detail screen (SCR-10), passing the selected plan's identifier. The navigation is a push transition (slide left). I can return to the Plans list using the back gesture or button on SCR-10.

**Why this priority**: Selecting a plan is the core action on this screen once plans exist. It is the primary bridge into the plan-detail and workout-execution flows.

**Independent Test**: Can be tested by tapping a plan row in the populated state and verifying SCR-10 loads with the correct plan data. Return navigation brings back the Plans list.

**Acceptance Scenarios**:

1. **Given** the populated plan list is shown, **When** I tap anywhere on a plan card, **Then** the Plan Detail screen (SCR-10) opens with that plan's details via a push (slide-left) transition.
2. **Given** I am on SCR-10 (plan detail), **When** I tap the back button or swipe back, **Then** I am returned to the Plans list (SCR-08).

---

### User Story 4 — Create a New Plan (FAB) (Priority: P4)

As a user viewing the Plans tab in any non-empty state, I want to tap the "+" button to start creating a new workout plan so that I can add more plans to my library.

The lime "+" FAB appears in the top-right corner of the app bar in the populated state. Tapping it navigates to the Create / Edit Workout Plan screen (SCR-09) in create mode, exactly the same destination as the empty-state CTA. The FAB does not appear in the loading state or the empty state.

**Why this priority**: The FAB is the primary secondary action for users who already have plans. It keeps the creation entry point accessible once the empty-state CTA is no longer shown.

**Independent Test**: Can be tested by tapping the lime "+" FAB in the populated state and verifying SCR-09 opens in create mode.

**Acceptance Scenarios**:

1. **Given** the populated plan list is shown, **When** I tap the lime "+" FAB in the app bar, **Then** the Create / Edit Workout Plan screen (SCR-09) opens in create mode.
2. **Given** I am on the empty state, **When** I look at the app bar, **Then** no "+" FAB is visible (the CTA button serves the creation entry point in this state).

---

### User Story 5 — Recover from Plan Load Failure (Priority: P5)

As a user who encounters a local storage read failure on the Plans tab, I want to see a clear error message and be able to retry so that the failure does not leave me stuck.

If the `workout_plans` table cannot be read, the screen shows a centred error card with a warning icon, an error title, a reassuring body message, and a lime Retry button. The bottom navigation bar remains visible. Tapping Retry transitions back to the skeleton loading state and attempts a fresh database read.

**Why this priority**: Error recovery is essential for resilience. It is the lowest priority because it handles an abnormal path that most users will never encounter.

**Independent Test**: Can be tested by simulating a database read exception and confirming the error card renders with the correct copy; tapping Retry triggers a fresh read attempt.

**Acceptance Scenarios**:

1. **Given** the `workout_plans` database read throws an exception, **When** the load attempt completes, **Then** I see an error card inside a danger-bordered container: a warning icon, the title "Couldn't load your workout plans", and the body "Something went wrong reading local data.\nYour history is unaffected."
2. **Given** the error state is shown, **When** I tap "Retry", **Then** the screen transitions back to the skeleton loading state and a fresh database read is initiated.
3. **Given** the retry fails again, **When** the second read completes with an error, **Then** the error card is shown again with identical copy (no escalating error message).
4. **Given** the retry succeeds, **When** the read completes, **Then** the screen transitions to either the populated or empty state depending on the current Drift content.
5. **Given** I am in the error state, **When** I tap a non-Plans tab in the bottom nav bar, **Then** I navigate away normally (the error state does not block navigation).

---

### Edge Cases

- What happens when a plan created or deleted in SCR-09 or SCR-10 causes the user to return to SCR-08? → The database read is triggered on every tab visit, so the list auto-refreshes to reflect the updated state.
- What happens when the user rapidly taps multiple plan rows? → Navigate to the first tapped plan; subsequent taps while the navigation is in flight are ignored.
- What happens when the Retry button is tapped while a read is already in progress? → Debounce or ignore redundant taps; only one concurrent database read runs at a time.
- What happens on a very large plan list (e.g., 50+ plans)? → The list scrolls within the content area; the app bar and bottom nav remain fixed; no pagination is applied.
- What happens when a plan exists but its `exerciseIds` list is null or malformed in the database? → Treat it as `0 exercises`; do not crash; display "0 exercises".

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The screen MUST display a skeleton loading state immediately when the Plans tab is tapped, before the database read completes.
- **FR-002**: The skeleton loading state MUST show 4 skeleton plan cards with a shimmer animation and a skeleton FAB placeholder in the app bar.
- **FR-003**: When the database read succeeds and the `workout_plans` table contains one or more plans, the screen MUST display a scrollable list of plan cards sorted newest-first (the most recently created plan appears at the top).
- **FR-004**: Each plan card MUST display the plan name (primary text), the exercise count as "N exercises" or "1 exercise" (secondary text), and a right-pointing chevron (trailing icon).
- **FR-005**: The exercise count MUST be derived from the length of the plan's `planExercises` list at load time, not from a pre-computed field. (The storage record stores exercises as `List<PlanExerciseRecord> planExercises`; there is no separate `exerciseIds` field.)
- **FR-006**: Plan names that exceed the available horizontal space MUST be truncated at 1 line with a trailing ellipsis.
- **FR-007**: Tapping a plan card MUST navigate to the Plan Detail screen (SCR-10), passing the selected plan's identifier.
- **FR-008**: When the database read succeeds and the `workout_plans` table is empty, the screen MUST display the empty state: a 60 pt list icon, title "No workout plans yet", subtitle "Build your first workout plan to see it listed here.", and a lime "Create a workout plan" CTA button.
- **FR-009**: Tapping the "Create a workout plan" CTA button MUST navigate to the Create / Edit Workout Plan screen (SCR-09) in create mode.
- **FR-010**: A lime "+" FAB MUST appear in the app bar when the populated state is active; tapping it MUST navigate to SCR-09 in create mode.
- **FR-011**: The lime "+" FAB MUST NOT appear in the loading state or the empty state.
- **FR-012**: When the database read fails, the screen MUST display an error card containing: a warning icon, the title "Couldn't load your workout plans", and the body "Something went wrong reading local data.\nYour history is unaffected."
- **FR-013**: The error state MUST include a lime Retry button that re-triggers the database read and transitions back to the loading state.
- **FR-014**: The bottom navigation bar MUST remain visible and interactive in all four states (loading, populated, empty, error).
- **FR-015**: The database read MUST be triggered on every tab visit (not only on the first visit) so that changes made in SCR-09 or SCR-10 are reflected when the user returns. On the first visit the skeleton loading state is shown. On subsequent visits (when a plan list has already been displayed) the existing list MUST remain visible while the re-read runs; the list content is replaced silently when the new data arrives (optimistic re-read — no skeleton flash on return).
- **FR-016**: The app bar title "Workout Plans" MUST be visible in all four states.

### Key Entities

- **WorkoutPlan**: Represents a user-created workout plan. Key attributes: unique identifier (`id`), plan name (`name`), ordered list of exercises (`planExercises`), creation timestamp (`createdAt`). The exercise count displayed in the list is `planExercises.length`. Plans are sorted descending by `createdAt` (newest plan first).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The skeleton loading state appears within 1 frame of tapping the Plans tab — the user never sees a blank screen while the database read is in progress.
- **SC-002**: The populated plan list and the empty state both appear within 1 second of tapping the Plans tab under normal conditions (local database read is fast).
- **SC-003**: Tapping a plan card navigates to the plan detail screen within 1 second of the tap.
- **SC-004**: All four states (loading, populated, empty, error) are reachable and display the correct UI without any crash or blank screen.
- **SC-005**: The exercise count label correctly uses singular ("1 exercise") and plural ("N exercises") forms for all values N ≥ 0.
- **SC-006**: Tapping Retry from the error state always transitions back to the loading state and initiates a fresh read — the app never stays stuck in the error state after a successful retry.
- **SC-007**: All interactive touch targets (plan card rows, "+" FAB, CTA button, Retry button, bottom nav tabs) meet a minimum rendered touch size of 44 × 44 pt or the touch area is extended to reach that minimum.

---

## Assumptions

- **Re-read on every tab visit (optimistic)**: The database read is triggered every time the Plans tab becomes active. On the first visit, the skeleton loading state is shown. On subsequent visits where a plan list has already been displayed, the existing list stays visible while the re-read runs; the content is swapped silently when the new data arrives. This avoids a jarring skeleton flash on every return from SCR-09 or SCR-10, while still keeping the list up to date.
- **No pull-to-refresh**: Pull-to-refresh is not implemented in V1; tab re-visit covers the refresh need (OQ-3 from design spec).
- **FAB is non-interactive during loading**: The skeleton FAB placeholder is not tappable. The live "+" FAB only becomes interactive after the populated state is confirmed (OQ-2 from design spec).
- **Offline only**: All data is read from the local `workout_plans` table. No network call is made. This is a constitutional constraint.
- **Navigation**: Push (slide-left) transitions are used for SCR-09 (create plan) and SCR-10 (plan detail). Both are secondary screens (OQ-8 from design spec).
- **No pagination**: All plans are loaded in a single database read; the list scrolls vertically with no lazy pagination.
- **Sort order**: Plans are sorted newest-first by `createdAt` timestamp. A plan created later always appears above an older plan. `WorkoutPlanRecord.createdAt` (`DateTime`) already exists in the data model and is used for this sort.
- **No pull-to-refresh gesture**: Not implemented in V1 per design spec OQ-3.
- **Exercise count source**: Derived from `exerciseIds.length` at load time; no pre-computed counter field is required (OQ-9 from design spec).
- **Singular/plural copy**: "1 exercise" (singular); "0 exercises" and "N exercises" for N ≠ 1 (OQ-6 from design spec).
- **Portrait orientation only**: Landscape is out of scope for this POC.
- **Dark theme only**: Single fixed dark theme per ADR-037; no light mode.
