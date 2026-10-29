# Feature Specification: Remove From Schedule Confirmation (SCR-14)

**Feature Branch**: `001-scr-14-remove-from-schedule`

**Created**: 2026-09-19

**Status**: Draft

**Input**: User description: "mobile spec for SCR-14"

**Source references**: `specs/SCR-14-Remove-From-Schedule/design/spec.md` (Design Specification), `specs/SCR-14-Remove-From-Schedule/QA/SCR-14-qa-spec.md` (QA Specification), `specs/SCR-12-View-Weekly-Schedule/mobile/001-scr-12-view-weekly-schedule/spec.md` (SCR-12, the screen this confirmation overlays and returns to), `specs/SCR-13-Assign-Edit-Schedule/mobile/001-scr-13-assign-edit-schedule/spec.md` (SCR-13, the sibling write-capable schedule screen)

## Clarifications

### Session 2026-09-19

- Q: How does the user trigger this removal confirmation from the weekly schedule view? → A: A dedicated "Remove" icon on each scheduled day row, alongside the existing edit icon (not a menu or swipe gesture).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Confirm removal of a day's scheduled plan (Priority: P1)

A user viewing their weekly schedule wants to remove a plan from a specific day, and wants to see clearly which plan and day will be affected before it's actually removed.

**Why this priority**: This is the entire reason the feature exists — without it, there is no way to undo a schedule assignment short of the destructive act of deleting the underlying plan itself.

**Independent Test**: From a day with an assigned plan, trigger removal, confirm on the dialog, and verify that day now shows as unscheduled while every other day is unaffected — independently of the cancel path or failure recovery.

**Acceptance Scenarios**:

1. **Given** a day has an assigned plan, **When** the user triggers removal for that day, **Then** a confirmation dialog appears naming the specific plan and day, states that workout history is unaffected, and does not remove anything yet.
2. **Given** the confirmation dialog is shown, **When** the user confirms, **Then** a brief loading indication is shown, after which only that one day's assignment is removed and the weekly schedule view reflects the change immediately.
3. **Given** the same plan is also assigned to other days, **When** one day's assignment is removed, **Then** the plan remains assigned on every other day exactly as before.

---

### User Story 2 - Cancel out and keep the entry unchanged (Priority: P1)

A user who opens the removal confirmation — intentionally or by mistake — wants a safe, unambiguous way to back out without anything being removed.

**Why this priority**: A confirmation step that doesn't reliably allow backing out isn't a real safeguard — this is equally essential to the feature's purpose as completing a removal.

**Independent Test**: Open the confirmation dialog for a day, back out via each available cancel path (the Cancel control, dismissing outside the dialog, and a back navigation gesture), and verify the assignment remains completely untouched after each — independently of the confirm or failure-recovery paths.

**Acceptance Scenarios**:

1. **Given** the confirmation dialog is shown, **When** the user taps Cancel, **Then** the dialog closes and the day's assignment remains exactly as it was.
2. **Given** the confirmation dialog is shown, **When** the user dismisses it by tapping outside the dialog or using a back gesture, **Then** the dialog closes and nothing changes.
3. **Given** a removal attempt has failed and the dialog now shows an error, **When** the user cancels from that state, **Then** the dialog closes and the assignment remains present, exactly as it was before the attempt.

---

### User Story 3 - Recover from a failed removal (Priority: P2)

A user whose removal attempt fails due to a local storage problem wants reassurance that nothing was lost or duplicated, and a straightforward way to try again.

**Why this priority**: A resilience path for an infrequent failure condition — the feature delivers its core value (Stories 1–2) without it ever triggering, but trust in the confirm action depends on failures being handled honestly.

**Independent Test**: Force the removal operation to fail and verify the dialog shows an explanation that nothing was removed and retrying is safe, that the assignment is still intact, and that retrying re-attempts the same removal — independently of the happy-path or cancel behavior.

**Acceptance Scenarios**:

1. **Given** the user confirms removal, **When** the removal operation fails, **Then** the dialog explains that nothing was removed and that retrying will not create a duplicate, and the assignment remains present.
2. **Given** the failure explanation is shown, **When** the user taps Retry, **Then** the same removal is re-attempted.
3. **Given** the failure explanation is shown, **When** the user taps Retry and it fails again, **Then** the failure explanation is shown again without crashing and the assignment remains present.

---

### Edge Cases

- What happens if the day being removed is the only remaining scheduled day in the entire week? After removal, the weekly schedule view shows its fully-empty state, exactly as if no day had ever been assigned.
- What happens if the day being removed is today's scheduled workout? After removal, today's row no longer offers a way to start that workout, consistent with an unscheduled day.
- What happens if the plan name is very long? The dialog text wraps to fit the dialog; the plan name is never truncated, so the user can always confirm exactly which plan is being removed.
- What happens on rapid repeated taps of Confirm or Retry? Only one removal attempt proceeds at a time; the control is unavailable again until that attempt completes or fails.
- What happens to previously recorded workout history when a removal succeeds, fails, or is retried? Workout history is never affected by any operation in this flow, under any outcome.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST show a confirmation step, naming the specific plan and day that will be affected, before removing a day's scheduled plan.
- **FR-002**: The system MUST NOT remove anything until the user explicitly confirms.
- **FR-003**: The confirmation step's copy MUST state that workout history is unaffected by the removal.
- **FR-004**: Canceling — via a Cancel control, dismissing outside the confirmation, or a back navigation gesture — MUST close the confirmation without changing anything, except while a removal is actively in progress (FR-006).
- **FR-005**: The system MUST show a loading indication while a removal is in progress and MUST prevent a duplicate removal attempt from being triggered during that time.
- **FR-006**: The system MUST block dismissal (Cancel, outside-tap, back gesture) while a removal is in progress.
- **FR-007**: On confirmation, the system MUST remove only the single day the user is acting on; any other day's assignment — including other days assigned to the same plan — MUST remain completely unaffected.
- **FR-008**: On successful removal, the system MUST return the user to an immediately updated weekly schedule view that no longer shows that day's assignment.
- **FR-009**: On a removal failure, the system MUST explain that nothing was removed and that retrying will not create a duplicate, MUST keep the assignment fully intact, and MUST offer a retry that re-attempts the same removal; Cancel MUST remain available in this state.
- **FR-010**: The system MUST NOT modify previously recorded workout history as a result of any operation in this flow, regardless of outcome.

### Key Entities

- **Schedule Assignment (single day)**: The specific day-and-plan pairing being removed. Attributes: which day, which plan. This flow acts on exactly one day at a time, independent of whether the same plan is also assigned elsewhere in the week.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can review which plan and day will be affected and complete a removal in a single confirm action, with the change visible immediately on return.
- **SC-002**: 100% of cancel, outside-dismiss, and back-gesture attempts leave the schedule completely unchanged.
- **SC-003**: 100% of failed removals leave the assignment intact and clearly communicate that nothing was lost or duplicated, recoverable via a single retry.
- **SC-004**: 100% of single-day removals leave every other day — including other days assigned to the same plan — completely unaffected.

## Assumptions

- **Per-day removal, not whole-plan removal**: Removal acts on exactly one day at a time. This deviates from the design mockup's own assumption of removing "the entire scheduleEntry (all days in the recurrence)" — that assumption does not match how schedule assignments actually work in this app (established while specifying SCR-12 and SCR-13): each day of the week holds its own independent assignment slot, and a plan scheduled on multiple days occupies multiple independent slots, not one multi-day record. Since this flow is triggered from a specific day on the weekly schedule view, removing exactly that day — and leaving the plan's other days untouched — is both the behavior consistent with the real data shape and the least surprising outcome for the user. This resolves the design doc's own flagged open question about removal scope (its OQ-3) in favor of the simpler, data-consistent behavior.
- **Entry point**: This confirmation is triggered by a dedicated "Remove" icon on each scheduled day row in the weekly schedule view, shown alongside that row's existing edit icon (Clarification, 2026-09-19) — not a menu, not a swipe gesture. It is not reachable from the assignment/editing screen. Adding this icon is a small amendment to the weekly schedule view's own scope, since that screen was previously specified with only an edit affordance per row.
- **No undo**: There is no undo after a successful removal; re-adding a day's assignment is done through the existing assignment flow.
- **Single-user, offline**: No concurrent process can modify the schedule; an assignment present when removal was confirmed will still be present if a retry is needed after a failure.
- **Not a destructive irreversible action**: Removing a day's assignment is low-stakes and easily redone (unlike deleting a plan itself) — it does not warrant the heavier irreversible-action treatment used elsewhere in the app for permanent deletions.
