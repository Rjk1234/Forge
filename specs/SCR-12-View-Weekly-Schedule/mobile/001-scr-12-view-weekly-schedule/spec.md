# Feature Specification: View Weekly Workout Schedule (SCR-12)

**Feature Branch**: `001-scr-12-view-weekly-schedule`

**Created**: 2026-09-19

**Status**: Draft

**Input**: User description: "mobile spec for SCR-12"

**Source references**: `specs/SCR-12-View-Weekly-Schedule/design/spec.md` (Design Specification), `specs/SCR-12-View-Weekly-Schedule/QA/SCR-12-qa-spec.md` (QA Specification)

## Clarifications

### Session 2026-09-19

- Q: If the app stays open across midnight while the user is on the Schedule tab, should "today" update live, or only re-evaluate on screen open/resume? → A: Re-evaluate "today" only on screen open/resume (no live clock listener).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See the current week's plan at a glance (Priority: P1)

A user who has assigned workout plans to specific days wants to open the Schedule tab and immediately see all seven days of the current week, with each day showing either the assigned plan (including recurring "Weekly" assignments) or a clear "Rest day" label.

**Why this priority**: This is the core value of the screen — without it, the user has no reason to visit the Schedule tab at all. It is the foundation every other story depends on.

**Independent Test**: Assign a plan to at least one weekday via the schedule-editing flow, then open the Schedule tab. Can be fully tested by verifying all 7 days render with correct plan/rest labeling, independent of the Start action or empty/error states.

**Acceptance Scenarios**:

1. **Given** the app is unlocked and one or more days have an assigned plan, **When** the user opens the Schedule tab, **Then** all 7 days (Monday–Sunday) are shown in order, each displaying either the assigned plan's name with a "Weekly" recurrence label, or a "Rest day" label if unscheduled.
2. **Given** the same plan is assigned to recur on multiple days (e.g., Monday, Wednesday, Friday), **When** the user views the schedule, **Then** all three days display that plan.
3. **Given** the schedule data is being read, **When** the user opens the Schedule tab, **Then** a skeleton loading view of 7 placeholder rows is shown until the data resolves.

---

### User Story 2 - Start today's workout in one tap (Priority: P1)

A user with a plan assigned to today wants to start that workout directly from the Schedule tab without navigating through the Plans list.

**Why this priority**: This is the screen's primary conversion action and directly reduces friction to starting a workout, which is central to the app's purpose.

**Independent Test**: With a plan assigned to today's weekday, open the Schedule tab and tap the Start action on today's row; verify it opens the workout pre-start flow for that plan. Testable independently of the rest of the week's rows.

**Acceptance Scenarios**:

1. **Given** today has an assigned plan, **When** the user views the Schedule tab, **Then** today's row is visually distinguished from other rows and shows a "Start" action instead of an edit icon.
2. **Given** today's row shows the Start action, **When** the user taps it, **Then** the app navigates to the workout pre-start overview for that plan.
3. **Given** today has no assigned plan, **When** the user views the Schedule tab, **Then** today's row shows a "Rest day" label and an edit affordance, consistent with other unscheduled days.

---

### User Story 3 - Get guided to create a schedule when none exists (Priority: P2)

A first-time or lapsed user who has not assigned any plans to any day wants a clear next step rather than a confusing blank week.

**Why this priority**: Without this, new users hit a dead end with no explanation of how to populate their schedule, harming onboarding and adherence.

**Independent Test**: With zero schedule entries, open the Schedule tab and verify the empty state with its call-to-action appears and navigates correctly, independent of populated or error behavior.

**Acceptance Scenarios**:

1. **Given** no day of the week has an assigned plan, **When** the user opens the Schedule tab, **Then** an empty state is shown with explanatory copy and a "Schedule a plan" action.
2. **Given** the empty state is shown, **When** the user taps "Schedule a plan", **Then** the app navigates to the schedule-assignment flow.

---

### User Story 4 - Recover from a failed schedule load (Priority: P3)

A user whose local schedule data fails to load wants to understand that their data is safe and be able to retry, rather than seeing a blank or broken screen.

**Why this priority**: This is a resilience path for an infrequent failure condition; it matters for trust but does not block the primary weekly-view or start-workout value.

**Independent Test**: Force the local schedule read to fail and verify the error state renders with retry, independent of the populated/empty paths, and that retry re-attempts the load.

**Acceptance Scenarios**:

1. **Given** the local schedule data fails to load, **When** the Schedule tab attempts to render, **Then** an error state is shown stating the schedule couldn't load and that plans and history are unaffected.
2. **Given** the error state is shown, **When** the user taps "Retry", **Then** the app re-attempts the load and transitions to the loading, populated, or empty state based on the outcome.

---

### Edge Cases

- What happens when a scheduled day references a plan that has since been deleted? The day is treated as unscheduled and shown as "Rest day"; the orphaned schedule entry is silently discarded so it does not reappear on the next load.
- What happens when a plan name is too long to fit on one line? The plan name truncates with an ellipsis on a single line; the recurrence/today label remains fully visible on its own line.
- What happens if the current date cannot be determined (e.g., system clock unavailable)? No day is highlighted as "today"; all rows render using the standard non-today layout.
- What happens if the user returns to the Schedule tab after completing today's workout? The Start action remains visible and unchanged; completion status is tracked in workout history, not reflected on this screen.
- What happens if the user retries the load multiple times in quick succession? Only one load may be in flight at a time; additional retry taps while a load is in progress are ignored.
- What happens if the user is on the Schedule tab when the load is still in progress and switches to another tab and back? The load continues in the background; the result (populated, empty, or error) is shown when the user returns.
- What happens if the app is left open across midnight while the Schedule tab is visible? "Today" is not updated live; the previous day's row remains highlighted as today until the user next opens or returns to the Schedule tab, at which point it re-evaluates and highlights the new current day.
- How does the system handle a week where every day is a rest day (no assignments at all)? This is treated identically to having zero schedule entries and shows the empty state.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display a loading state showing placeholders for all 7 days while schedule data is being read.
- **FR-002**: The system MUST display an empty state with a "Schedule a plan" action when no day of the week has an assigned plan.
- **FR-003**: The system MUST display all 7 days of the current week (Monday through Sunday) at all times when at least one day has an assignment, showing each day's assigned plan (including recurring weekly assignments) or a "Rest day" label if unscheduled.
- **FR-004**: The system MUST provide a one-tap "Start" action on today's row when today has an assigned plan, which navigates to the workout pre-start flow for that plan.
- **FR-005**: The system MUST visually distinguish today's row from other days.
- **FR-006**: The system MUST provide an edit affordance on every non-today row (scheduled or rest) that navigates to the schedule-assignment flow for that day.
- **FR-007**: The system MUST display an error state with a retry action when the schedule data fails to load, and MUST communicate that existing plans and workout history are unaffected.
- **FR-008**: The system MUST re-read schedule data and re-evaluate which day is "today" each time the Schedule tab is opened or resumed, so changes made elsewhere (e.g., assigning or removing a day) and day-boundary crossings are reflected on the next visit; the system is NOT required to update "today" live while the screen remains open and in the foreground (e.g., across a midnight rollover).
- **FR-009**: The system MUST treat a schedule entry that references a deleted plan as unscheduled ("Rest day") rather than showing an error or a stale reference.
- **FR-010**: The system MUST NOT allow the Schedule tab's data to be viewed while the app is locked; access is gated by the app-level lock check.

### Key Entities

- **Schedule Entry**: Represents a plan assigned to a specific day of the week. Attributes: day of week, referenced plan, recurrence (weekly). Relationship: references a Workout Plan; may become orphaned if the referenced plan is deleted.
- **Workout Plan**: The plan a schedule entry points to. Represented here only by name; full detail lives outside this feature's scope.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user with an assigned schedule can identify today's workout and begin it in one tap, in under 5 seconds from opening the app.
- **SC-002**: A user can see their entire week's workout structure in a single screen without needing to scroll horizontally or switch views.
- **SC-003**: A new user with no schedule sees a clear next action (not a blank or confusing screen) 100% of the time.
- **SC-004**: When the schedule fails to load, the user is not left believing their data is lost — 100% of failure states reassure the user their plans and history are unaffected and offer a retry.

## Assumptions

- The week always displays exactly 7 rows in fixed Monday–Sunday order; day numbers reflect the actual current calendar week.
- "Weekly" recurrence is the only assignment type supported; there is no bi-weekly or custom-interval recurrence.
- Only one plan may be assigned per day; this is enforced by the schedule-assignment flow, not by this screen.
- Tapping a day row's body (outside the edit icon or Start action) has no effect; only the named controls are interactive.
- Re-tapping the Schedule tab while already on it scrolls the list to the top rather than performing any other action.
- This screen is read-only with respect to schedule data; it never writes to local storage.
