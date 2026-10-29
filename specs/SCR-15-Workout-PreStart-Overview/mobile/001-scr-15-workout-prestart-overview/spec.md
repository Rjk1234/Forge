# Feature Specification: Workout Pre-Start / Overview (SCR-15)

**Feature Branch**: `001-scr-15-workout-prestart-overview`

**Created**: 2026-09-19

**Status**: Draft

**Input**: User description: "mobile spec for SCR-15"

**Source references**: `specs/SCR-15-Workout-PreStart-Overview/design/spec.md` (Design Specification), `specs/SCR-15-Workout-PreStart-Overview/QA/SCR-15-qa-spec.md` (QA Specification), `specs/SCR-12-View-Weekly-Schedule/mobile/001-scr-12-view-weekly-schedule/spec.md` (SCR-12, one entry point)

## Clarifications

### Session 2026-09-23

- Q: When the blocked (plan unavailable) or load-failure state is shown and the user taps the offered navigation action, what is the destination if this overview was opened from the plan detail screen rather than from the weekly schedule? → A: Both blocked and failure "back" actions always navigate to the weekly schedule, regardless of entry point. FR-006 is narrowed accordingly.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Review a plan and begin the workout (Priority: P1)

A user about to start a workout wants to see exactly which exercises are planned and at what targets before committing, then begin with a single action.

**Why this priority**: This is the entire purpose of the screen — a moment to orient before an active workout session begins. Without it, users would launch directly into a session with no chance to review it first.

**Independent Test**: From either entry point, with a valid plan that has at least one exercise, open the overview, verify every exercise and its type-appropriate targets are shown, and tap "Begin Workout" to confirm it proceeds into the active workout — independently of the blocking or failure states.

**Acceptance Scenarios**:

1. **Given** the user opens the overview for a valid plan, **When** the plan data is loading, **Then** a loading indication is shown and no "Begin Workout" action is available yet.
2. **Given** the plan has loaded successfully, **When** the user views the screen, **Then** every exercise in the plan is listed in its configured order, each showing its type-appropriate targets (a weighted exercise shows sets/reps/weight; a bodyweight exercise shows sets/reps; a time-based exercise shows sets/duration).
3. **Given** the plan has loaded successfully, **When** the user views the screen, **Then** a "Begin Workout" action is available.
4. **Given** the "Begin Workout" action is available, **When** the user taps it, **Then** the active workout session begins for that plan.
5. **Given** the user navigates back before or after the plan loads, **When** they do so, **Then** they return to wherever they came from, and nothing is written or started.

---

### User Story 2 - Get blocked when the plan can't be started (Priority: P1)

A user who opens the overview for a plan that no longer exists, or that has no exercises configured, wants a clear explanation that they can't proceed — not a broken or empty-looking screen.

**Why this priority**: Preventing a user from starting a workout session against invalid data is essential to the app's data integrity and to avoiding a confusing dead-end mid-session; this is equally foundational to the screen's purpose as the happy path.

**Independent Test**: Open the overview for a plan that has been deleted since it was scheduled (or that has zero exercises), and verify a clear blocking message appears with no way to proceed except returning — independently of the happy path or load-failure recovery.

**Acceptance Scenarios**:

1. **Given** the plan referenced by this overview no longer exists, **When** the screen finishes loading, **Then** a message explains the plan is no longer available, no "Begin Workout" action is offered, and the only action is to return to the schedule.
2. **Given** the plan still exists but has no exercises configured, **When** the screen finishes loading, **Then** it is treated the same as a plan that no longer exists — blocked, with the same explanation and single way forward.
3. **Given** the blocking message is shown, **When** the user takes the offered action, **Then** they return to the weekly schedule view.

---

### User Story 3 - Recover from a load failure (Priority: P2)

A user whose plan data fails to load due to a local storage problem wants to understand that this is different from the plan being gone, and be able to retry.

**Why this priority**: A resilience path for an infrequent failure condition — the screen delivers its core value (Stories 1–2) without it ever triggering, but a storage hiccup must never be mistaken for "this plan doesn't exist" or leave the user stuck.

**Independent Test**: Force the plan data load to fail and verify a distinctly-worded failure state appears (different from the "plan unavailable" message), offering both a retry and a way back — independently of the happy path or the unavailable-plan state.

**Acceptance Scenarios**:

1. **Given** the plan data fails to load due to a storage problem, **When** the failure occurs, **Then** a message distinct from the "plan unavailable" message explains that something went wrong reading local data and that the user's data is safe, and both a retry action and a way back to the schedule are offered.
2. **Given** the failure message is shown, **When** the user retries, **Then** the load is attempted again and may resolve to the reviewable plan, the blocking state, or the failure state again.
3. **Given** the failure message is shown, **When** the user chooses to go back instead of retrying, **Then** they return to the weekly schedule view without the load ever succeeding.

---

### Edge Cases

- What happens if the user navigates back while the plan is still loading? The in-progress load is abandoned; the user returns to wherever they came from with no error and no partial state shown.
- What happens with a plan that has ten or more exercises? All exercises are shown in a scrollable list; none are hidden or truncated.
- What happens with a plan name or exercise name that's unusually long? Names wrap onto additional lines rather than being cut off, so the full name is always readable.
- What happens if a weighted exercise has no weight configured? Its weight target shows a clear "not set" indication rather than a blank or misleading zero.
- What happens on rapid repeated taps of Retry? Only one load attempt is in flight at a time; extra taps while a load is already running have no additional effect.
- What happens after the user begins a workout and later navigates back from the active session? They return to wherever they came from before this overview, not back to this overview screen.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST show a loading indication while the plan's data is being read, during which no "Begin Workout" action is available.
- **FR-002**: Once loaded successfully, the system MUST display every exercise in the plan, in its configured order, each with its type-appropriate targets (weighted: sets/reps/weight; bodyweight: sets/reps; time-based: sets/duration).
- **FR-003**: Once loaded successfully, the system MUST offer a "Begin Workout" action that proceeds into the active workout session for that plan.
- **FR-004**: The system MUST block starting a workout — offering no "Begin Workout" action — when the referenced plan no longer exists or has no exercises configured, and MUST explain this to the user with a single way back to the weekly schedule.
- **FR-005**: The system MUST show a load-failure state, worded distinctly from the plan-unavailable message, when the plan's data fails to load due to a local storage problem; this state MUST offer both a retry and a way back to the weekly schedule.
- **FR-006**: Back navigation from the loading and reviewable (loaded) states MUST return the user to whichever screen opened this overview, without writing any data or starting a workout session. The offered navigation action in the blocked (plan unavailable) and load-failure states MUST always navigate to the weekly schedule, regardless of which screen opened this overview.
- **FR-007**: The system MUST NOT create, modify, or otherwise write any workout session or history record as a result of viewing this screen; only tapping "Begin Workout" transitions the user toward starting a session.
- **FR-008**: When this overview was opened for a specific scheduled day, its display MUST indicate which day the plan is scheduled for, showing a "today" qualifier only when that day is the current day; when opened without a specific scheduled day (e.g., directly from a plan's own details), the display MUST show only the exercise count, with no scheduling reference.
- **FR-009**: Repeated Retry taps while a load is already in progress MUST NOT trigger a second, concurrent load attempt.

### Key Entities

- **Plan Overview**: A read-only projection of a workout plan for pre-start review — plan name, exercise count, optional scheduling context (a specific day, and whether that day is today), and the ordered list of exercises with their type-appropriate targets. Never written to; exists only to inform the decision to begin.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can review a plan's full exercise list and targets and begin the workout in a single action once the screen has loaded.
- **SC-002**: 100% of attempts to open this overview for an unavailable plan (deleted, or with no exercises) are blocked before any workout session can start.
- **SC-003**: 100% of load failures are recoverable via a single retry, without the user ever needing to navigate away and back.
- **SC-004**: 100% of the time, a user can tell whether a plan is genuinely gone versus a storage problem occurred, because the two states use distinctly different wording.

## Assumptions

- **Zero-exercise plan is treated as unavailable**: A plan that still exists but has no exercises configured is blocked exactly like a deleted plan (User Story 2), rather than shown as an empty, startable plan — there is no meaningful workout to begin. This resolves a tension between the design mockup (which reaches the same conclusion) and the QA spec (which left this open); the design's reasoning — no valid workout exists — is adopted.
- **Back navigation always returns to the actual caller**: Whether opened from a plan's own detail view or from the weekly schedule, every back action (app-bar back, or the blocking/failure state's "back to schedule" action) returns the user to that same originating screen, treated uniformly rather than special-casing the weekly schedule as a fixed destination.
- **No timeout on loading**: Since all data comes from local storage with no network involved, there is no explicit loading timeout; a load either resolves or fails.
- **Exercise order is fixed**: The exercise list always renders in the plan's configured order; this screen offers no reordering.
- **Starting a workout leaves this screen behind**: Once a workout session begins, returning from the active session does not revisit this overview — the user lands back at whatever screen opened this overview in the first place.
