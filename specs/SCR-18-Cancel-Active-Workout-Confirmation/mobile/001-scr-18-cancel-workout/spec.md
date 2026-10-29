# Feature Specification: SCR-18 Cancel Active Workout Confirmation

**Feature Branch**: `001-scr-18-cancel-workout`

**Created**: 2026-09-23

**Status**: Draft

**Input**: User description: "mobile spec for SCR-18"

**Design reference**: `specs/SCR-18-Cancel-Active-Workout-Confirmation/design/spec.md`

## Overview

SCR-18 is a destructive confirmation modal that appears when a user attempts to leave an active workout session on SCR-16. Without this guard, an accidental tap on the Cancel button or an OS back gesture would silently discard all logged sets from the current session with no recovery path. SCR-18 presents an explicit, unambiguous warning and gives the user a single clear choice: resume the workout or permanently discard the session.

**ForgeApp context**: Discarding a workout session means the in-progress session object is deleted from Drift without being written to the completed workouts history. This is permanent and unrecoverable — there is no trash, undo, or draft state.

---

## User Scenarios & Testing

### User Story 1 — View Cancel Confirmation and Choose an Action (Priority: P1)

When a user taps Cancel in the SCR-16 app bar, a confirmation modal appears over the dimmed workout screen. The modal names the workout plan and explicitly states that the session will not be saved and will not appear in workout history. The user taps "Keep Going" to resume the workout without any state loss, or taps "Discard Workout" to permanently delete the session and return to the home screen.

**Why this priority**: This is the core guard preventing accidental session loss. Without it, any errant tap ends a workout permanently and silently. This is the entire purpose of SCR-18.

**Independent Test**: In an active workout with at least 1 set logged, tap Cancel in the SCR-16 app bar. Verify the confirmation modal appears and the workout state is preserved behind it. Tap "Keep Going" and verify the workout resumes exactly where it was. Repeat, then tap "Discard Workout" and verify the session is gone and the home screen is shown with no back-navigation path to the discarded workout.

**Acceptance Scenarios**:

1. **Given** the user is on SCR-16 with at least one set logged, **When** they tap Cancel in the app bar, **Then** the confirmation modal appears immediately over a dimmed SCR-16 background, displaying the plan name, a warning that progress will not be saved, and both "Keep Going" and "Discard Workout" buttons.
2. **Given** the confirmation modal is visible, **When** the user taps "Keep Going", **Then** the modal is dismissed and SCR-16 resumes showing the exact same exercise, set index, logged field values, and exercise progress bar as before the modal appeared.
3. **Given** the confirmation modal is visible, **When** the user taps "Discard Workout", **Then** the in-progress session is permanently deleted (not written to workout history), and the user is taken to SCR-06 (Home Dashboard) with the navigation stack cleared so no back button returns to the discarded session.
4. **Given** the user taps Cancel with no sets logged yet, **When** the confirmation modal appears and the user taps "Discard Workout", **Then** the empty session is discarded and the user is taken to SCR-06.
5. **Given** the user taps Cancel after completing all sets but before tapping Finish, **When** they tap "Discard Workout", **Then** the session is discarded — the completed sets are NOT written to history; only explicitly finished workouts appear in history.

---

### User Story 2 — OS Back Gesture Triggers the Same Confirmation (Priority: P2)

When the user triggers the OS back gesture (iOS swipe-back or Android hardware back button) while on SCR-16, the same confirmation modal appears instead of silently popping the workout screen. This prevents accidental navigation away from an active workout.

**Why this priority**: The OS back gesture is a common accidental trigger, especially on Android. Routing it to SCR-18 rather than silently discarding the workout is the correct safety-first default, but this interception is a distinct implementation concern from the Cancel button entry path and can be independently shipped.

**Independent Test**: In an active workout, trigger the OS back gesture (swipe from left edge on iOS, hardware back on Android). Verify the same SCR-18 confirmation modal appears — not a direct pop back to a prior screen.

**Acceptance Scenarios**:

1. **Given** the user is on SCR-16, **When** they trigger the OS back gesture, **Then** the SCR-18 confirmation modal appears — the workout is NOT immediately discarded and SCR-16 is NOT silently popped.
2. **Given** the SCR-18 modal is open (triggered by either the Cancel button or back gesture), **When** the user taps outside the modal on the dimmed scrim, **Then** the modal is dismissed and SCR-16 resumes unchanged (same behavior as "Keep Going").
3. **Given** the SCR-18 modal is open, **When** the user triggers the OS back gesture again, **Then** the modal is dismissed and SCR-16 resumes unchanged (same behavior as "Keep Going" — OS back while the modal is open does NOT immediately discard).

---

### Edge Cases

- **Zero sets logged**: Modal appears normally with the same warning copy. Even though no sets have been logged, the user's explicit confirmation is still required before discarding the session.
- **All sets completed, Finish not tapped**: Modal appears. If the user confirms discard, the session is NOT written to history — "cancel always discards" regardless of how many sets were completed.
- **Drift delete fails on discard**: Log the error internally. Still navigate to SCR-06. The orphaned session data will be cleaned up on the next app launch. Do not display the raw error to the user.
- **"Discard Workout" tapped twice rapidly**: The button is disabled after the first tap to prevent double-fire; the discard operation is idempotent by design.
- **App backgrounded while modal is open**: The modal remains when the app is foregrounded. No workout state is lost.
- **Very long plan name in modal body copy**: The plan name is displayed in full; the dialog body grows vertically to accommodate. No truncation.
- **SCR-18 from SCR-17 (Rest Timer)**: SCR-18 is NOT reachable directly from SCR-17. The OS back gesture on SCR-17 dispatches "Skip Rest" (per SCR-17 spec) and dismisses the rest timer, returning to SCR-16. From SCR-16, the user may then trigger SCR-18 via Cancel or OS back.

---

## Requirements

### Functional Requirements

- **FR-001**: The system MUST display a confirmation modal when the user taps the Cancel button in the SCR-16 app bar. The modal MUST appear without any loading delay.
- **FR-002**: The system MUST display the same confirmation modal when the user triggers the OS back gesture while SCR-16 is the active screen. The OS back gesture MUST NOT silently pop SCR-16.
- **FR-003**: The confirmation modal MUST display the name of the active workout plan and explicitly state that (a) the session's progress will not be saved and (b) the session will not appear in workout history.
- **FR-004**: The confirmation modal MUST present exactly two actions: "Keep Going" (resume the workout) and "Discard Workout" (permanently delete the session). No other dismiss path exists as a deliberate action.
- **FR-005**: Tapping "Keep Going" MUST dismiss the modal and return the user to SCR-16 with the workout state identical to what it was when the modal appeared — same exercise, same set index, same logged field values, same progress bar position.
- **FR-006**: Tapping "Discard Workout" MUST permanently delete the in-progress session. The session MUST NOT be written to the `workout_sessions` table. The deletion is irreversible.
- **FR-007**: After "Discard Workout" completes, the system MUST navigate the user to SCR-06 (Home Dashboard). The navigation stack MUST be cleared so that no back button or gesture returns to the discarded workout.
- **FR-008**: Tapping outside the modal (on the dimmed scrim background) MUST dismiss the modal and resume SCR-16 unchanged — identical to tapping "Keep Going".
- **FR-009**: Triggering the OS back gesture while the confirmation modal is open MUST dismiss the modal and resume SCR-16 unchanged — identical to tapping "Keep Going". The OS back while the modal is open MUST NOT discard the session.
- **FR-010**: The "Discard Workout" button MUST use a visually distinct destructive style to communicate the irreversibility of the action. The "Keep Going" button MUST use a neutral/secondary style.
- **FR-011**: The "Discard Workout" button MUST be disabled after the first tap to prevent a double-fire discard.
- **FR-012**: If the Drift delete operation fails during discard, the system MUST log the error internally, still navigate the user to SCR-06, and MUST NOT display a raw exception message to the user.

### Key Entities

- **WorkoutSession** (in-progress): The active session entity held in `ActiveWorkoutBloc` in-memory state during an active workout. It is never persisted to Drift until the user explicitly taps Finish. SCR-18 is the guard before its discard path. On "Discard Workout", the session is abandoned without saving — it ceases to exist when `ActiveWorkoutBloc` is disposed, and no entry is promoted to the completed workouts history.

No new entities are introduced by SCR-18. No new tables are required.

---

## Success Criteria

### Measurable Outcomes

- **SC-001**: 100% of workout cancellation attempts (Cancel button tap or OS back gesture on SCR-16) pass through SCR-18. Zero in-progress sessions are silently discarded without explicit user confirmation.
- **SC-002**: "Keep Going" preserves 100% of in-progress workout state — after dismissing the modal, the user sees the exact same exercise, set, field values, and progress bar as before. No state is reset or lost.
- **SC-003**: After "Discard Workout", 100% of discarded sessions have no entry in workout history. Zero accidental history entries are created by the cancellation path.
- **SC-004**: After "Discard Workout", the user cannot return to the discarded workout via any navigation gesture. The navigation stack is clean in 100% of cases.

---

## Assumptions

- The workout plan name is always available at the point SCR-18 is presented; it is passed in from SCR-16's active state, not re-fetched from Drift.
- The confirmation modal appears as an overlay on top of SCR-16 (not a separate pushed route); the underlying SCR-16 content is visible in a dimmed state behind the modal.
- The OS back gesture on SCR-17 (Rest Timer) dispatches "Skip Rest" and is handled by SCR-17 itself — it does NOT route to SCR-18. SCR-18 is only reachable from SCR-16.
- Tapping outside the modal (scrim tap) and OS back while the modal is open both behave as "Keep Going" — the safe, reversible action. There is no "trap the user" behavior where the modal blocks all dismissal paths.
- "Discard Workout" is always instantaneous from the user's perspective; no loading state or spinner is required. If a Drift delete failure occurs, navigation to SCR-06 still proceeds.
- The modal body copy displays the plan name in full; no character limit or truncation is applied.
- SCR-18 is the interstitial for the "cancel always discards" product decision from SCR-16. There is no "save as incomplete" or "pause and come back later" alternative — this is a deliberate product decision, not a gap.
- This spec covers the mobile implementation only; the design specification (`design/spec.md`) is the authority on visual tokens, layout dimensions, and copy.

## Clarifications

### Session 2026-09-23

- OQ-1 (OS back routing): OS back gesture on SCR-16 routes to SCR-18 (same as Cancel tap) — confirmed assumption from design spec. FR-002 captures this.
- OQ-2 (Modal dismiss without confirming): Tap-outside and OS-back-while-modal-open both act as "Keep Going" — safe dismissal, returns to SCR-16. FR-008 and FR-009 capture this.
- OQ-3 (SCR-18 from SCR-17): SCR-17 OS back = Skip Rest (per SCR-17 spec). SCR-18 is not reachable from SCR-17. Captured in FR-002 scope and Edge Cases.
- OQ-4 (Long plan name): Display in full; dialog grows vertically. Captured in Edge Cases and Assumptions.
