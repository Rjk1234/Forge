# Feature Specification: SCR-16 Active Workout

**Feature Branch**: `001-scr-16-active-workout`

**Created**: 2026-09-23

**Status**: Draft

**Input**: User description: "mobile spec for SCR-16"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Log Sets and Complete the Workout (Priority: P1)

A user enters the Active Workout screen from the Pre-Start Overview (SCR-15), logs actual values for each set across their exercises (weighted, bodyweight, or time-based), and completes the workout. Completing the last set of the last exercise — when at least one set has been logged — triggers a Finish: the session is persisted to local storage and the user is taken to the post-workout summary (SCR-19).

**Why this priority**: This is the entire purpose of the screen. Every other story augments this one. Without it, no workout data is ever produced.

**Independent Test**: Can be tested end-to-end by creating a plan with at least one exercise of each type, entering SCR-16, logging one set per exercise, completing the last set, verifying SCR-19 is shown, and confirming the session record appears in workout history.

**Acceptance Scenarios**:

1. **Given** the user arrives from SCR-15 with a plan containing a weighted exercise as the first exercise, **When** the screen opens, **Then** the first exercise is shown in the Active state with two fields — Reps and Weight — pre-populated with the plan's target values; no data is written to local storage at this point.

2. **Given** the user has entered valid values for the current set, **When** they tap Complete Set (and it is not the last set of the last exercise), **Then** the view advances to the next set within the same exercise, or to the first set of the next exercise if all sets of the current exercise are done.

3. **Given** the user is on the last set of the last exercise and has previously logged at least one set, **When** they tap Complete Set with valid values, **Then** the session is written to local storage and the user is navigated to SCR-19 (post-workout summary).

4. **Given** the user has a time-based exercise in their plan, **When** that exercise is the current exercise, **Then** only the Duration field is shown (single column); the field accepts a duration value and validates that it is a positive number.

5. **Given** the user has a bodyweight exercise in their plan, **When** that exercise is the current exercise, **Then** only the Reps field is shown (single column); Weight is not displayed.

---

### User Story 2 - Inline Validation Blocks Invalid Entries (Priority: P1)

A user attempts to log a set with an invalid value (non-positive reps, negative weight, or non-positive duration). The screen shows an inline error on the offending field and prevents logging until the value is corrected. The error clears automatically as the user fixes it.

**Why this priority**: Invalid data reaching the session record is a data integrity failure. This guardrail is inseparable from logging and must ship together with US1.

**Independent Test**: Can be tested by entering a value of 0 or negative into each field type and verifying the error state appears, Complete Set is disabled, and the error clears when a valid value is entered — without navigating away.

**Acceptance Scenarios**:

1. **Given** the Reps field for any exercise type that shows it contains a value ≤ 0, **When** the user taps Complete Set, **Then** an inline error appears on the Reps field and the set is not logged.

2. **Given** the Weight field for a weighted exercise contains a negative value, **When** the user taps Complete Set, **Then** an inline error appears on the Weight field and the set is not logged.

3. **Given** the Duration field for a time-based exercise contains a value ≤ 0, **When** the user taps Complete Set, **Then** an inline error appears on the Duration field and the set is not logged.

4. **Given** an inline validation error is visible on a field, **When** the user edits that field and the value becomes valid, **Then** the error clears immediately (before the next Complete Set tap).

5. **Given** multiple fields have invalid values simultaneously, **When** the user taps Complete Set, **Then** errors appear on all invalid fields at once.

---

### User Story 3 - Pause and Resume Mid-Workout (Priority: P2)

A user needs to take a break mid-workout. They pause the workout, which holds all execution state in memory and shows a Paused overlay. When ready, they resume and continue from exactly where they left off. The Cancel action is also available in the Paused state.

**Why this priority**: Pause is a common real-world need but is not blocking for core logging. A user can technically complete a workout without pause; logging and validation ship first.

**Independent Test**: Can be tested by logging one set, tapping Pause, verifying the paused overlay appears (with active content visible beneath at reduced opacity and no scrim), tapping Resume, and confirming the workout continues from the same set position.

**Acceptance Scenarios**:

1. **Given** the workout is in the Active state, **When** the user taps Pause, **Then** the Paused overlay appears centered on screen; the underlying workout content is visible at reduced opacity with a desaturated tint (no solid scrim); no execution state is lost.

2. **Given** the workout is in the Paused state, **When** the user taps Resume, **Then** the Paused overlay is dismissed and the workout resumes at the same set position with all logged values intact.

3. **Given** the workout is in the Paused state, **When** the user taps Cancel (within the Paused overlay), **Then** the user is routed to the cancel-confirmation screen (SCR-18), identical to tapping Cancel in the Active state.

---

### User Story 4 - Cancel or Discard the Workout (Priority: P2)

A user decides they do not want to finish the workout. They tap Cancel (in Active or Paused state) or use the OS back gesture. They are routed to a cancel-confirmation screen (SCR-18). Only after confirming is the session discarded — no partial record is written to local storage. If the user had not logged any sets, Finish is also treated as a discard.

**Why this priority**: Cancellation safety is a user-trust feature. Users must be able to exit without accidentally polluting their history with incomplete sessions.

**Independent Test**: Can be tested by starting a workout without logging any sets, tapping Cancel, confirming in SCR-18, and verifying no entry appears in workout history.

**Acceptance Scenarios**:

1. **Given** the workout is in the Active state, **When** the user taps Cancel, **Then** the user is routed to SCR-18 (cancel confirmation); the session is NOT discarded at this point.

2. **Given** the workout is active, **When** the user performs the OS back gesture (swipe back or hardware back), **Then** the app routes to SCR-18, identical to tapping Cancel; the workout screen is NOT dismissed directly.

3. **Given** the user is on SCR-18 and cancels confirmation (chooses to continue the workout), **When** they return to the workout screen, **Then** the workout resumes exactly where it was with all logged values intact.

4. **Given** the user is on the last set of the last exercise and has zero logged sets (all were skipped), **When** they tap Complete Set, **Then** no data is written; the session is discarded and the user is routed to SCR-18 (not to SCR-19).

5. **Given** the app is killed or crashes while a workout is in progress, **When** the app is relaunched, **Then** no partial workout record appears in history; the in-memory session is fully discarded.

6. **Given** the user is on the last set of the last exercise and has zero logged sets across the entire workout, **When** they tap Skip, **Then** no data is written and the user is routed to SCR-18 (identical to the FR-009 Complete Set path).

---

### Edge Cases

- What happens when the Finish write to local storage fails? A write-error state is shown, the in-memory session is preserved, and the user can retry. No navigation to SCR-19 occurs until the write succeeds. The retry attempt must not produce a duplicate record.
- What happens when all sets in a workout are skipped and the user taps Complete Set on the last set? Zero logged sets triggers the discard path — no data is written; the user routes to SCR-18.
- What happens when the user rapid-taps Complete Set? Only the first tap is processed; subsequent taps while the view is advancing are ignored.
- What happens when a plan has only one exercise with one set? Completing that set immediately triggers Finish if the set was logged (or discard if it was skipped).
- What happens when an exercise name is very long? The name wraps to additional lines; it is never truncated or ellipsized.
- What happens when an exercise has 15 or more sets? The set-indicator row wraps to a second line; all set indicators remain visible.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The screen MUST open in the Active state showing the first exercise's first set; no data MUST be written to local storage at entry.
- **FR-002**: Users MUST be able to enter actual values (reps, weight, or duration) for the current set; fields MUST be pre-populated with the plan's target values as a starting point.
- **FR-003**: A non-positive rep count (≤ 0) MUST show an inline validation error on the Reps field and MUST prevent logging the set.
- **FR-004**: A negative weight value MUST show an inline validation error on the Weight field and MUST prevent logging the set.
- **FR-005**: A non-positive duration value (≤ 0) MUST show an inline validation error on the Duration field and MUST prevent logging the set.
- **FR-006**: Validation errors MUST clear automatically in real time as the user corrects the invalid field value; errors MUST NOT persist until the next Complete Set tap.
- **FR-007**: Completing a valid set MUST advance the view to the next set within the current exercise, or to the first set of the next exercise when all sets of the current exercise are done.
- **FR-008**: Completing the last set of the last exercise with at least one set logged MUST trigger a Finish: persist the session to local storage and navigate to the post-workout summary (SCR-19).
- **FR-009**: If Finish is triggered with zero logged sets, the session MUST be discarded without writing any data; the user MUST be routed to the cancel-confirmation screen (SCR-18), not to SCR-19.
- **FR-010**: Users MUST be able to skip the current set; a skipped set MUST be visually distinct from a logged set and MUST NOT count toward the ≥ 1 logged-set criterion for Finish.
- **FR-011**: Users MUST be able to pause the workout; the Paused state MUST hold all execution state in memory; users MUST be able to resume and continue from the same set position.
- **FR-012**: Cancel (tapped in Active or Paused state) MUST route to SCR-18; the session MUST NOT be discarded until the user confirms cancellation in SCR-18.
- **FR-013**: The OS back gesture (swipe back or hardware back) MUST behave identically to Cancel — routing to SCR-18, not dismissing the screen directly.
- **FR-014**: If the app is killed or crashes while a workout is in progress, the in-memory session MUST be discarded; no partial record MUST appear in workout history.
- **FR-015**: If the local-storage write fails on Finish, a write-error state MUST be shown; the in-memory session MUST be preserved for retry; the user MUST be able to retry; navigation to SCR-19 MUST NOT occur until the write succeeds; a successful retry MUST NOT produce a duplicate record.

### Key Entities *(include if feature involves data)*

- **Active Workout Session**: The in-memory record of the workout in progress — plan reference, ordered exercises, per-set entries (actual values and status), and session start timestamp. Written to local storage only on a successful Finish. Discarded on cancel or app kill. When persisted, the stored record MUST include: a unique session ID (UUID), the plan ID and plan name, the session start timestamp, and the full ordered list of all sets (logged and skipped).
- **Logged Set**: One entry within the session for a single set — the actual values the user entered (reps, weight, or duration depending on exercise type), the exercise it belongs to, and its completion status (pending → logged or skipped). The `skipped` flag MUST be stored on every set in the final record; skipped sets are NOT omitted from the persisted history entry.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can log at least one set for each supported exercise type (weighted, bodyweight, time-based) and complete a workout in a single session, producing a persisted history record — verifiable immediately after the first complete happy-path run.
- **SC-002**: 100% of invalid field values (non-positive reps, negative weight, non-positive duration) are blocked at the moment of logging — no invalid data can reach the session record.
- **SC-003**: 0% of cancel or discard flows produce a partial workout history entry — a cancelled session leaves no trace in history.
- **SC-004**: A Finish write failure is always recoverable without data loss — the user can retry and complete the workout without re-entering any set data.

## Assumptions

- Skip is always active, including on the last set of the last exercise — it is never disabled or hidden. Tapping Skip on the last-of-last set marks it as skipped, then: if zero sets were logged across the entire workout, FR-009 fires immediately (discard path to SCR-18); if at least one set was logged elsewhere, the view remains at the last (now-skipped) set and Complete Set is still available to trigger Finish.
- Completing the last set (Complete Set tap) is the sole Finish trigger; there is no separate "Finish Workout" button (OQ-4 resolved).
- OS back gesture routes to SCR-18, not a direct pop (OQ-5 resolved).
- Cancel is tappable in the Paused state and routes to SCR-18 (OQ-6 resolved).
- Bodyweight exercises show a single-column field layout (Reps only) — no Weight field (OQ-1 resolved).
- The field layout for each exercise type is: Weighted = 2-column (Reps + Weight); Time-based = 1-column (Duration); Bodyweight = 1-column (Reps).
- Validation fires on Complete Set tap (on-attempt) and clears in real time as values are corrected; there is no on-blur validation.
- Fields are pre-populated with plan target values; the logged value is whatever is in the field at the time of the Complete Set tap.
- The Paused state renders the underlying workout content at reduced opacity with a desaturated tint and no solid scrim background; the Pause overlay is centred on screen.
- Workout timer starts when SCR-16 is entered; timer behavior when the app is backgrounded is deferred (OQ-EC9 deferred).
- Finish write failure follows the project's standard write-error template (SCR-27 pattern); the retry is idempotent — no duplicate record is produced.
- Navigation after a successful Finish goes to SCR-19; navigating back from SCR-19 does NOT return to SCR-16.
- This screen is entered via pushReplacement from SCR-15, so the OS back gesture from SCR-16 goes to SCR-18, not back to SCR-15.
- All workout execution state is held in memory for the lifetime of the screen; there is no draft persistence or session-recovery mechanism in this version.
- SCR-16 does NOT include a countdown rest timer between sets. After a set is logged or skipped, the screen advances directly to the next set; the rest period target stored on the exercise is informational only and is not displayed as an active countdown in this screen. A dedicated rest-timer screen is a separate feature outside SCR-16's scope.

## Clarifications

### Session 2026-09-23

- Q: Is a countdown rest timer (counting down from the exercise's configured rest period) part of SCR-16's scope, or is it a separate screen / deferred feature? → A: No rest timer in SCR-16 — rest period is informational only; the screen advances directly to the next set without a countdown.
- Q: What must the stored session record include — unique ID, timestamps, and skipped sets? → A: Full record — unique session ID (UUID), mandatory start timestamp, ALL sets stored including skipped ones (with a `skipped` flag); no data is omitted.
- Q: When the user is on the last set of the last exercise, does the Skip button remain active, become disabled, or hidden? → A: Skip stays active — tapping it marks the set as skipped; if zero sets were logged, FR-009 fires (discard to SCR-18); if ≥1 sets were logged, the view remains at the last set with Complete Set still available.
