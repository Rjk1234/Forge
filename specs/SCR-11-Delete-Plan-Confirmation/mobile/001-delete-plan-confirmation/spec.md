# Feature Specification: Delete Plan Confirmation (SCR-11)

**Feature Branch**: `SCR-11-Delete-Plan-Confirmation`

**Created**: 2026-09-19

**Status**: Draft

**Input**: User description: "mobile spec for SCR-11"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Confirm or Cancel Deletion (Priority: P1)

A user taps the Delete icon on SCR-10 Plan Detail. A modal confirmation dialog appears over SCR-10, naming the plan and clearly stating what will be removed (the plan and its schedule assignments) and what will be preserved (past workout sessions). The user can either confirm deletion (tap Delete) or back out (tap Cancel or the scrim outside the dialog). Cancelling leaves the plan untouched and returns focus to SCR-10.

**Why this priority**: The confirmation dialog is the sole safety gate before an irreversible local data deletion. Without it, a single accidental tap permanently removes a plan. This is the core reason SCR-11 exists.

**Independent Test**: Can be fully tested by seeding Drift with a plan and triggering the dialog. Verify that the dialog title, subtitle (including the plan name), Cancel, and Delete buttons are present; that tapping Cancel dismisses the dialog with the plan still in storage; and that tapping the scrim outside the dialog also dismisses it as a Cancel.

**Acceptance Scenarios**:

1. **Given** the user is on SCR-10 for a plan named "Push Day", **When** they tap the Delete icon button, **Then** a modal dialog appears with the title "Delete this workout plan?" and a subtitle containing "Push Day" and mentioning that schedule assignments will be removed and past sessions are unaffected.
2. **Given** the confirmation dialog is open, **When** the user taps Cancel, **Then** the dialog is dismissed and the plan detail (SCR-10) is still visible with no changes to the plan.
3. **Given** the confirmation dialog is open, **When** the user taps the scrim (outside the dialog card), **Then** the dialog is dismissed — same outcome as Cancel.
4. **Given** the confirmation dialog is open, **When** the user taps Delete, **Then** the dialog transitions to the Deleting (loading) state.
5. **Given** the confirmation dialog is open, **When** the user swipes back (iOS) or presses the system back button (Android), **Then** the dialog is dismissed — same outcome as Cancel.

---

### User Story 2 — Deletion In Progress (Priority: P2)

Once the user confirms deletion, the dialog locks into a loading state. The Delete button changes to a spinner with "Deleting…" text. The Cancel button is visually dimmed and non-interactive. The background scrim becomes non-dismissible. This prevents the user from triggering a duplicate delete or issuing a Cancel mid-write, which would leave the data in an unknown state.

**Why this priority**: The loading state prevents a mid-deletion cancel that could corrupt local storage or leave orphaned schedule entries. It also gives clear visual feedback that work is in progress.

**Independent Test**: Can be fully tested by holding the Bloc in `DeletePlanDeleting` state and verifying the spinner renders, the Cancel button is non-interactive (disabled), and neither the scrim tap nor a back gesture dismisses the dialog.

**Acceptance Scenarios**:

1. **Given** the user has tapped Delete and the dialog is in the Deleting state, **Then** the Delete button shows a spinner and the label "Deleting…".
2. **Given** the dialog is in the Deleting state, **When** the user taps the Cancel button, **Then** nothing happens — Cancel is disabled and the dialog remains open.
3. **Given** the dialog is in the Deleting state, **When** the user taps the scrim, **Then** nothing happens — the scrim is non-dismissible.
4. **Given** the dialog is in the Deleting state, **When** the Drift write completes successfully, **Then** the dialog is dismissed and the app navigates to the Plans List (SCR-08), where the deleted plan no longer appears.

---

### User Story 3 — Delete Failure and Retry (Priority: P3)

If the local Drift write fails, the dialog transitions to an error state. An inline error message appears below the subtitle, confirming that nothing was removed. The Cancel button is restored to fully interactive. The Delete button is replaced by a lime Retry button. The user can either retry the deletion or cancel and return to SCR-10 with the plan intact.

**Why this priority**: Drift failures are rare but possible (e.g., storage corruption or insufficient device storage). Without an error state, the user would have no feedback and might believe the plan was deleted when it was not.

**Independent Test**: Can be fully tested by simulating a Drift write exception in the Bloc and verifying the inline error message appears, the plan is unchanged in storage, the Retry button is lime (not red), the Cancel button is re-enabled, and tapping Retry re-enters the Deleting state.

**Acceptance Scenarios**:

1. **Given** the Drift write fails during the Deleting state, **Then** the dialog transitions to the Delete Failure state with an inline error message reading "Couldn't delete the plan — something went wrong writing to local storage. Nothing was removed."
2. **Given** the dialog is in the Delete Failure state, **Then** the error message appears below the subtitle and above the action row; the Cancel button is fully enabled; the Retry button is shown in lime (not danger red).
3. **Given** the dialog is in the Delete Failure state, **When** the user taps Cancel, **Then** the dialog is dismissed and the plan detail (SCR-10) is still visible with the plan unchanged.
4. **Given** the dialog is in the Delete Failure state, **When** the user taps Retry, **Then** the dialog transitions back to the Deleting state and the Drift write is re-attempted.
5. **Given** the dialog is in the Delete Failure state, **When** the user taps Retry multiple times quickly, **Then** only one Drift write is in flight at a time — duplicate taps before the first attempt is registered are debounced.

---

### Edge Cases

- What happens when the plan name in the subtitle is very long (80+ characters)? The dialog subtitle wraps freely; the dialog card grows in height. No truncation.
- What happens if the plan is already gone from Drift when the delete is attempted (concurrent deletion from elsewhere)? Treat as success — navigate to SCR-08.
- What happens if the app is backgrounded during the Deleting state? The Drift write continues; on foreground return the dialog shows the result (success → navigate away; failure → error state).
- What happens if the Drift write removes the plan entry but then fails when removing schedule entries? The deletion must be treated atomically. If non-atomic, both writes must succeed or the plan entry must not be removed. Data integrity must be preserved.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-1**: The system MUST present a modal confirmation dialog — not a pushed route — when the user requests plan deletion from SCR-10.
- **FR-2**: The dialog MUST display the plan name and explicitly state that the plan and its schedule assignments will be removed.
- **FR-3**: The dialog MUST explicitly state that past workout sessions using the plan are unaffected.
- **FR-4**: While deletion is in progress, the dialog MUST prevent all user dismissal: Cancel is disabled, the scrim is non-dismissible, and back navigation (swipe/system back) is blocked.
- **FR-5**: On successful deletion, the dialog MUST dismiss and navigate to the Plans List (SCR-08); SCR-10 MUST NOT remain in the navigation stack.
- **FR-6**: Historical `workout_sessions` rows that reference the deleted `planId` MUST NOT be removed by the delete operation.
- **FR-7**: On Drift write failure, the dialog MUST transition to an error state, preserve the plan in storage, and offer a Retry action.
- **FR-8**: The error state MUST display an inline message confirming that nothing was removed.
- **FR-9**: The Retry action MUST re-attempt the same deletion without requiring the user to re-confirm.
- **FR-10**: The Delete button MUST be visually distinct from all other primary actions — danger red fill, not lime — to signal an irreversible destructive action.
- **FR-11**: The Retry button MUST use lime fill (not danger red) — it is a neutral re-attempt, not a new destructive decision.

### Key Entities

- **WorkoutPlanDetail**: The plan being deleted — identified by `planId`; name shown in dialog subtitle; removed from Drift on successful deletion.
- **ScheduleEntry**: Any schedule assignment referencing the deleted `planId`; removed from Drift as part of the same atomic deletion operation.
- **WorkoutSession**: Historical session records referencing the deleted `planId`; explicitly preserved — not touched by the delete operation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-1**: A user who intentionally taps Delete and whose Drift write succeeds completes the full flow — confirmation dialog → deletion → Plans List — without any ambiguity about what was deleted or what was preserved.
- **SC-2**: After successful deletion, the deleted plan does not appear in SCR-08 and any associated schedule entries are also removed; past workout sessions that referenced the plan are still present in storage.
- **SC-3**: While deletion is in progress, no user interaction can produce a duplicate delete, a concurrent cancel, or a navigation event that bypasses the Bloc state machine.
- **SC-4**: On a Drift write failure, the user can reach the error state, read a clear non-technical explanation of what happened, and either retry or cancel — within the same dialog, without restarting the flow.
- **SC-5**: The confirmation dialog renders correctly on all supported phone widths (375 px–430 px) without layout overflow, truncated text, or touch targets below 44 pt.

## Assumptions

- SCR-11 is presented via Flutter `showDialog`, not as a `go_router` pushed route. It does not appear in the navigation history; the back gesture cannot pop it unless explicitly handled.
- On successful deletion, the router pops SCR-10 and navigates to SCR-08 — SCR-10 is not retained in the stack with a stale plan.
- ForgeApp is fully offline. The only failure mode is a local Drift write error; there is no network condition to handle.
- The delete operation is treated as atomic: both the `workout_plans` row and all associated `schedule_entries` for the `planId` must succeed or both must be rolled back. A partial success must surface as a failure.
- ForgeApp is portrait-only; landscape layout is out of scope.
- The `onDanger` color token (`#2a1414`) and `dangerBg` token (`#2a1f1f`) must be added to `AppColors` before implementation; they are referenced by the Delete button text and the inline error background respectively.
- `blocTest` and `mocktail` are NOT in `pubspec.yaml`. Tests use plain `flutter_test` with fake implementations.
- The `DeletePlanBloc` uses `registerFactory` in GetIt — a fresh instance is created each time the dialog opens.
- Scrim tap during Confirmation and Delete Failure states is treated as Cancel (dismisses the dialog).
- Back gesture (iOS swipe / Android system back) during Confirmation and Delete Failure states is treated as Cancel. During Deleting state it is blocked entirely.
