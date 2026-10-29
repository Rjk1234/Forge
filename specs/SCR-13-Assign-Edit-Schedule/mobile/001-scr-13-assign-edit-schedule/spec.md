# Feature Specification: Assign / Edit Schedule (SCR-13)

**Feature Branch**: `001-scr-13-assign-edit-schedule`

**Created**: 2026-09-19

**Status**: Draft

**Input**: User description: "mobile spec for SCR-13"

**Source references**: `specs/SCR-13-Assign-Edit-Schedule/design/spec.md` (Design Specification), `specs/SCR-13-Assign-Edit-Schedule/QA/SCR-13-qa-spec.md` (QA Specification), `specs/SCR-12-View-Weekly-Schedule/mobile/001-scr-12-view-weekly-schedule/spec.md` (SCR-12, the screen this feature reads from and returns to)

## Clarifications

### Session 2026-09-19

- Q: When a user taps "Schedule a plan" from SCR-12's empty state (no specific plan already in context), how should the plan being scheduled be determined? → A: Route the user to the Plans List (SCR-08) first to choose a plan; this screen is only reached once a plan has been chosen there.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Schedule a plan to one or more days (Priority: P1)

A user who has a workout plan they want to follow on a recurring basis wants to assign it to one or more days of the week, so that it appears on their weekly schedule and can be started from there.

**Why this priority**: This is the only way a plan ever gets onto the weekly schedule in the first place — without it, SCR-12's "Schedule a plan" call-to-action and the Plan Detail screen's "Schedule" action both lead nowhere. It is the foundational capability every other story in this feature builds on.

**Independent Test**: Starting from a plan with no existing schedule assignment, open the assignment screen, select one or more currently-unoccupied days, and save. Can be fully tested by verifying the plan now appears on those days when the weekly schedule is viewed — independent of editing, conflict handling, or failure recovery.

**Acceptance Scenarios**:

1. **Given** the user opens the assignment screen for a plan with no days selected, **When** the screen loads, **Then** no day is pre-selected and saving is not yet possible.
2. **Given** no day is selected, **When** the user selects at least one currently-unoccupied day, **Then** saving becomes possible.
3. **Given** at least one day is selected with no conflicts, **When** the user saves, **Then** the plan is scheduled on each selected day and the user is returned to the weekly schedule view showing the change.
4. **Given** the user has selected some days, **When** the user deselects all of them, **Then** saving becomes unavailable again.

---

### User Story 2 - Edit an existing day's assignment (Priority: P1)

A user who already has a plan scheduled on one or more days wants to change which days it's scheduled on, so their weekly schedule stays accurate as their routine changes.

**Why this priority**: Equally foundational to User Story 1 — without it, SCR-12's per-day edit affordance has no destination, and a user's schedule can never be corrected once created, only replaced by deleting and recreating it elsewhere.

**Independent Test**: Starting from a plan already assigned to specific days, open the assignment screen for that assignment, verify its current days are pre-selected, change the selection, and save. Testable independently of the new-assignment flow, conflict handling, or failure recovery.

**Acceptance Scenarios**:

1. **Given** an existing assignment for a plan on specific days, **When** the user opens the assignment screen to edit it, **Then** the plan and its currently assigned day(s) are pre-selected and saving is immediately possible (no change required to enable it).
2. **Given** the pre-filled assignment, **When** the user adds or removes days and saves, **Then** the updated day selection is reflected on the weekly schedule upon return.
3. **Given** the pre-filled assignment, **When** the user makes no changes and saves, **Then** the assignment is saved unchanged and the user returns to the weekly schedule view.

---

### User Story 3 - Get blocked from double-booking a day (Priority: P2)

A user selecting days for a plan wants to be clearly told when a day they tap is already taken by a different plan, so they don't accidentally overwrite an existing commitment without realizing it.

**Why this priority**: Protects schedule data integrity (at most one plan per day), but depends on User Story 1/2 existing first — there is nothing to conflict with until assignments can be created.

**Independent Test**: With one day already assigned to Plan A, open the assignment screen for Plan B and attempt to select that same day. Verify the conflict is clearly flagged, names the conflicting plan, and blocks saving until resolved — independently of any other day's selection state.

**Acceptance Scenarios**:

1. **Given** a day is already assigned to a different plan, **When** the user selects that day for the plan being scheduled, **Then** that day is visibly flagged as conflicting, an explanation naming the existing plan is shown, and saving is blocked while any conflict remains.
2. **Given** a day is flagged as conflicting, **When** the user deselects that day, **Then** the conflict clears for that day, and saving becomes possible again if no other conflicts remain.
3. **Given** multiple days are each individually conflicting, **When** the user views the selection, **Then** each conflicting day is flagged independently and saving remains blocked until every conflict is resolved.
4. **Given** the user is editing an existing assignment, **When** the user selects a day that assignment already owns, **Then** it is never treated as a conflict against itself.

---

### User Story 4 - Recover from a failed save (Priority: P2)

A user who taps Save and hits a local storage failure wants reassurance that nothing was lost and an easy way to try again, rather than having to re-enter their day selection from scratch.

**Why this priority**: A resilience path for an infrequent failure condition — important for trust, but the feature delivers its core value (Stories 1–3) without it ever triggering.

**Independent Test**: Force the save operation to fail and verify an error state appears explaining nothing was changed, the user's plan and day selection are retained exactly as entered, and a retry re-attempts the save — independent of the happy-path or conflict-detection behavior.

**Acceptance Scenarios**:

1. **Given** the user taps Save, **When** the save operation fails, **Then** an error message explains nothing was changed and the user's current plan and day selection remain visible and unchanged.
2. **Given** the error message is shown, **When** the user taps Retry, **Then** the same save operation is re-attempted without requiring the user to re-select anything.
3. **Given** a save is in progress, **When** the user attempts to navigate away, **Then** navigation is blocked until the save completes or fails.

---

### User Story 5 - Get guided when the plan being edited no longer exists (Priority: P3)

A user who opens an existing assignment to edit it, where the underlying plan was deleted elsewhere in the app, wants to understand that the plan is gone and be guided to pick a different one, rather than being able to silently save a broken assignment.

**Why this priority**: An edge condition (a plan deleted after being scheduled) that matters for correctness and trust but occurs rarely relative to the primary create/edit flows.

**Independent Test**: Delete the plan referenced by an existing assignment, then open that assignment for editing. Verify a clear explanatory message replaces the plan selection, day selection is disabled, and saving is blocked until a different plan is chosen — independently of any other story.

**Acceptance Scenarios**:

1. **Given** the assignment being edited references a plan that no longer exists, **When** the screen loads, **Then** the plan selection is replaced with a message explaining the plan is no longer available, day selection is disabled, and saving is blocked.
2. **Given** the "plan no longer available" message is shown, **When** the user chooses a different, valid plan, **Then** the screen behaves as a new assignment for that plan (Story 1) with no days pre-selected.

---

### Edge Cases

- What happens if the user selects all 7 days at once? All are allowed to be selected; any day already occupied by a different plan is flagged as a conflict exactly as a single conflicting day would be, independently of the others.
- What happens if the user cancels (navigates back without saving, and not while a save is in progress)? No change is made — any existing assignment remains exactly as it was, and no new assignment is created.
- What happens to previously recorded workout history when an assignment is created, edited, or its save fails and is retried? Workout history is never affected by any operation on this screen, under any outcome.
- What happens if the user changes which plan is being scheduled partway through (Story 5's recovery path, or any other point at which the plan changes) and the new plan's inherited day selection now conflicts with existing assignments? Each conflicting day is flagged exactly as in User Story 3, and saving is blocked until resolved.
- What happens if two rapid Save taps occur? Only one save attempt proceeds at a time; the control that triggers a save is unavailable again until the in-flight attempt completes or fails.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST let the user create a new assignment for a workout plan by selecting one or more days of the week.
- **FR-002**: The system MUST prevent saving when zero days are selected.
- **FR-003**: The system MUST let the user edit an existing assignment, pre-filling the plan and its currently assigned day(s) so that saving is immediately possible without requiring a change first.
- **FR-004**: The system MUST prevent a single day from being assigned to more than one plan at a time. Selecting a day already assigned to a different plan MUST visibly flag that day, explain which plan currently occupies it, and block saving until the conflict is resolved (by deselecting the day or removing the existing assignment elsewhere).
- **FR-005**: When editing an existing assignment, the days that assignment already owns MUST NOT be treated as conflicting with themselves.
- **FR-006**: The system MUST show a loading indication while a save is in progress and MUST prevent a duplicate save from being triggered during that time.
- **FR-007**: On a successful save, the system MUST return the user to the weekly schedule view with the change reflected.
- **FR-008**: On a save failure, the system MUST show an explanatory error stating that nothing was changed, MUST retain the user's current plan and day selection exactly as entered, and MUST offer a retry that re-attempts the same save without requiring re-entry.
- **FR-009**: If the plan referenced by an assignment being edited no longer exists, the system MUST replace the plan selection with an explanatory message, disable day selection, and block saving until the user selects a different, valid plan.
- **FR-010**: The system MUST block back navigation away from this screen while a save is in progress; back navigation MUST be available at all other times and MUST NOT save or change anything when used.
- **FR-011**: The system MUST NOT modify previously recorded workout history as a result of any operation on this screen, regardless of outcome.
- **FR-012**: The system MUST always treat an assignment's recurrence as weekly; it MUST NOT expose any other recurrence option, consistent with the current one-plan-per-weekday scheduling model.
- **FR-013**: The system MUST arrive at this screen with a specific plan already identified — from the plan's own detail view, from an existing assignment being edited, or (when entered from the weekly schedule's empty-state prompt with no plan already in context) from the Plans List, where the user chooses a plan before this screen is reached (Clarification, 2026-09-19). This screen MUST NOT be reachable with no plan identified.

### Key Entities

- **Schedule Assignment**: Represents a workout plan scheduled on one or more days of the week. Attributes: referenced plan, the set of days it occupies, recurrence (always weekly). Relationship: references a Workout Plan; may become invalid if that plan is deleted (User Story 5).
- **Workout Plan**: The plan being assigned. Represented here only by name and identity; full detail lives outside this feature's scope.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can schedule a plan to one or more days and see it reflected on the weekly schedule in a single save action, with no additional steps.
- **SC-002**: 100% of attempts to assign a day already occupied by a different plan are caught before save, with a clear explanation of which plan currently occupies that day.
- **SC-003**: 100% of failed saves leave the user's in-progress plan and day selection fully intact, recoverable via a single retry with no re-entry required.
- **SC-004**: 100% of edit attempts against a since-deleted plan surface an explanatory message before any save is possible — no assignment can be silently saved against a plan that no longer exists.

## Assumptions

- **Plan context on entry**: This screen always starts with a specific plan already identified. When entered from a plan's own detail view or from editing an existing assignment, that plan is used directly. When entered from the weekly schedule's empty-state prompt (no specific plan in context), the user is first routed to the Plans List to choose a plan, and only reaches this screen once one is chosen (FR-013, Clarification 2026-09-19). This screen itself never presents a plan-picking step or a silent default.
- **Recurrence**: Only weekly recurrence exists in the current scope; there is no bi-weekly or custom-interval option, consistent with SCR-12's assumptions.
- **One assignment slot per day**: Each day of the week holds at most one plan at a time. Assigning a plan to multiple days schedules it independently on each of those days — each day is its own commitment, not a single multi-day record with special semantics.
- **Day ordering**: Days are always presented Monday through Sunday, consistent with SCR-12.
- **No history impact**: Nothing on this screen ever reads or modifies workout history records; the scheduling relationship is entirely separate from execution/history data.

## Out of Scope

- A dedicated flow for browsing and picking a different workout plan from within this screen. This screen consumes a plan already identified by its entry point — including, for the no-plan-in-context case, the existing Plans List screen reused for that purpose (Clarification, 2026-09-19) — rather than building any new picker UI itself.
- Any recurrence pattern other than weekly.
- Any change to workout history as a result of scheduling activity.
