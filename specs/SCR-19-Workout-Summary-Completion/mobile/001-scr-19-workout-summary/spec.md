# Feature Specification: SCR-19 Workout Summary & Completion

**Feature Branch**: `001-scr-19-workout-summary`

**Created**: 2026-09-23

**Status**: Draft

**Input**: User description: "mobile spec for SCR-19"

**Design reference**: `specs/SCR-19-Workout-Summary-Completion/design/spec.md`

## Overview

SCR-19 is the screen the user sees immediately after tapping "Finish" on SCR-16 (Active Workout). It serves three purposes in sequence: (1) acknowledging the save in progress so the user knows the app is working, (2) presenting a full summary of the completed session on success, and (3) giving the user a clear recovery path if the local save fails. Without this screen, a failed save is silent and the user's workout data is lost with no recourse.

**ForgeApp context**: The Drift write is a purely local I/O operation. No network call occurs. The data being saved is the in-memory session held by `ActiveWorkoutBloc` from SCR-16. The active workout stack is cleared after the save — the user cannot navigate back to SCR-16 from SCR-19.

---

## User Scenarios & Testing

### User Story 1 — Save and View Workout Summary (Priority: P1)

After tapping Finish, the user sees the screen transition to a loading state while their workout is being saved. On success, a summary screen appears showing what they accomplished: the workout name, when it happened, how long it took, and a breakdown of every exercise with the exact sets, reps, and weights they logged (including any skipped sets, shown distinctly). From the summary, the user can exit to the home screen or go directly to their workout history.

**Why this priority**: This is the core value delivery of completing a workout. Without the loading confirmation and summary, the user has no feedback that their session was recorded. This is the primary reason SCR-19 exists.

**Independent Test**: Complete an active workout on SCR-16 with at least one set logged across at least two exercises (including at least one skipped set). Tap Finish. Verify the loading indicator appears, the save completes, and the summary screen shows the correct plan name, date/time, duration in minutes, set count (excluding skipped), exercise count, and each exercise card with the correct set pills in the correct format per exercise type.

**Acceptance Scenarios**:

1. **Given** the user has logged at least one set on SCR-16, **When** they tap Finish, **Then** the Finish button immediately transforms into a loading indicator ("Saving Workout…") and the Cancel link becomes non-interactive — no navigation occurs yet.
2. **Given** the loading state is active, **When** the local save succeeds, **Then** the summary screen appears showing the workout plan name, session date and time, duration in minutes, exercise count, and sets logged count (non-skipped sets only).
3. **Given** the summary screen is displayed, **When** the user reviews the exercise breakdown, **Then** each exercise shows its name, a coloured type indicator, and a pill for every logged set formatted correctly: `{reps}×{weight}kg` for weighted exercises, `{reps} reps` for bodyweight exercises, `{MM:SS}` for time-based exercises, and "Skipped" (with strikethrough styling) for skipped sets.
4. **Given** the summary screen is displayed, **When** the user taps "Done", **Then** they are navigated to the Home screen (SCR-06) and the in-memory session is cleared; no back gesture returns them to the completed workout.
5. **Given** the summary screen is displayed, **When** the user taps "View History", **Then** they are navigated to the Workout History screen (SCR-20); the summary screen remains on the navigation stack below SCR-20 so the user can return to it.

---

### User Story 2 — Handle Save Failure and Retry (Priority: P2)

If the local save fails, the screen transitions to an error state that names the failed workout, reassures the user their logged sets are still in memory, and offers a single "Retry" button. Tapping Retry re-attempts the save. On retry success, the summary screen appears. If the retry finds the session was already saved (e.g., a prior attempt succeeded but the UI showed failure), the user is taken directly to the summary without duplicating the record.

**Why this priority**: A silently lost workout is a critical product failure — users may lose significant effort. The retry path must work correctly and must never create duplicate history records. This is blocking for production confidence, but it is a fallback path (the happy path in US1 occurs far more frequently).

**Independent Test**: Simulate a Drift write failure on the first attempt (e.g., via test mocking). Verify the error state appears with the correct plan name and messaging. Tap Retry. Verify the save succeeds on the second attempt and the summary screen appears. Verify only one session record exists in workout history. Optionally: simulate a duplicate by marking the session as already saved before a retry — verify the user reaches the summary directly without a second write.

**Acceptance Scenarios**:

1. **Given** the loading state is active, **When** the local save fails, **Then** the error state is displayed showing the plan name, a message that the save failed, a reassurance that logged sets are preserved, and a "Retry" button as the sole action.
2. **Given** the error state is displayed, **When** the user taps "Retry", **Then** the loading state is shown again and the save is re-attempted.
3. **Given** a retry is attempted, **When** the session ID is already present in local storage (a prior attempt actually succeeded), **Then** no second write occurs and the user is taken directly to the summary screen.
4. **Given** the error state is displayed, **When** the user triggers the OS back gesture, **Then** nothing happens — the error state remains; the user must tap Retry or force-quit the app.
5. **Given** a retry write fails again, **When** the failure is caught, **Then** the error state is shown again with the same content — the retry cycle can repeat indefinitely.
6. **Given** the error state is displayed and the "Retry" button is tapped, **When** the first tap is processed, **Then** the Retry button immediately becomes non-interactive to prevent double-fire.

---

### User Story 3 — Back Navigation Is Blocked (Priority: P3)

After reaching the summary screen, the user cannot navigate backwards to the active workout. The back gesture and hardware back button are intercepted on the summary screen and have no effect. SCR-16 has been removed from the navigation stack.

**Why this priority**: This is a correctness requirement (the active workout state no longer exists after the save), but it is a lower priority because it is a constraint on existing behaviour rather than a new user flow. The happy path (US1) and error path (US2) both ship without requiring this to be independently validated.

**Independent Test**: From the summary screen, trigger the OS back gesture (iOS swipe-back or Android hardware back). Verify nothing happens — the summary remains the current screen.

**Acceptance Scenarios**:

1. **Given** the summary screen (Main state) is active, **When** the user triggers the OS back gesture or Android hardware back, **Then** the navigation does not change — the summary screen remains visible.
2. **Given** the user has navigated from the summary to SCR-20 (View History), **When** they navigate back from SCR-20, **Then** they return to the summary screen (SCR-19 is below SCR-20 on the stack); from the summary, back gesture is still blocked.

---

### Edge Cases

- **All sets skipped**: The summary is shown. "Sets Logged" stat = 0. Every exercise card shows only "Skipped" pills. The session is still saved — completion is determined by the Finish tap, not the set count.
- **Single set logged, rest skipped**: Minimum valid session. Summary shows the one non-skipped set alongside the skipped pills. Sets Logged = 1.
- **App backgrounded during loading**: The local save continues. On foreground: if still writing, the loading state is shown; if already completed, the correct outcome state (summary or error) is shown. The write is never restarted.
- **Long plan name**: The plan name in the hero title and the error message wraps to additional lines. No truncation is applied.
- **Retry double-tap**: The Retry button becomes non-interactive on first tap. No second write is initiated.
- **Returning to summary from SCR-20**: If the user navigates back from SCR-20 to the summary, the summary is displayed as a read-only screen — its content remains unchanged.
- **Zero exercises in session (theoretical)**: Cannot be reached via the normal flow (SCR-16 requires at least one exercise in the plan). If somehow reached with an empty session, the error state is displayed as a defensive fallback.

---

## Requirements

### Functional Requirements

- **FR-001**: On Finish tap from SCR-16, the system MUST immediately display a loading state. The Finish button MUST transform to show a loading indicator and the text "Saving Workout…". The Cancel link MUST become visually suppressed and non-interactive. No navigation occurs yet.
- **FR-002**: The loading state's Finish button MUST be non-interactive — no additional taps or presses during the save operation must trigger any action.
- **FR-003**: On successful local save, the system MUST navigate to the summary screen. SCR-16 MUST be removed from the navigation stack — the user cannot navigate back to the active workout.
- **FR-004**: The summary screen MUST display: (a) the workout plan name, (b) the session start time formatted as `{Day}, {Mon} {D} · {h:mm AM/PM}` (e.g. "Mon, Sep 7 · 6:42 PM"), (c) workout duration in minutes, (d) total exercise count (all exercises in the plan, regardless of completion), and (e) total sets logged count (non-skipped sets only).
- **FR-005**: The summary screen MUST include a breakdown section showing one exercise entry per exercise in the workout, in the order they appeared during the session.
- **FR-006**: Each exercise entry MUST display: the exercise name, a coloured type indicator (weighted: lime, time-based: cyan, bodyweight: muted), the set count, and a pill for every logged or skipped set.
- **FR-007**: Set pills MUST use the correct format per exercise type: weighted → `{reps}×{weight}kg`; bodyweight → `{reps} reps`; time-based → `{MM:SS}`; skipped → "Skipped" with visually distinct muted strikethrough styling.
- **FR-008**: On local save failure, the system MUST navigate to the error state. The in-memory session data MUST be fully preserved so that retry can re-attempt the write.
- **FR-009**: The error state MUST display: the workout plan name embedded in the error message, a human-readable description of the failure, and a reassurance that logged sets are still in memory and have not been recorded to history yet.
- **FR-010**: The error state MUST provide exactly one action: "Retry". Tapping Retry MUST show the loading state and re-attempt the local save.
- **FR-011**: Before each write attempt, the system MUST check whether a record with the session's stable ID already exists in local storage. If it does, the system MUST navigate to the summary instead of writing again. This prevents duplicate history records on retry.
- **FR-012**: The summary screen MUST provide two navigation actions: "Done" (navigates to the Home screen, clears the in-memory session) and "View History" (navigates to the Workout History screen, SCR-20).
- **FR-013**: The summary screen MUST block all back navigation — OS back gesture and Android hardware back MUST have no effect while the summary is the active screen.
- **FR-014**: The error state MUST block all back navigation — OS back gesture and Android hardware back MUST have no effect while the error state is active.
- **FR-015**: The Retry button MUST become non-interactive immediately on first tap to prevent double-fire initiating a second concurrent write.

### Key Entities

- **WorkoutSession** (completed): The persisted session record written to the local `workout_sessions` store on a successful save. Attributes: stable session ID (generated when the workout begins on SCR-16), workout plan ID, plan name, session start time, session end time (Finish tap time), duration, and an ordered list of exercise entries. Each exercise entry contains: exercise name, exercise type (weighted/bodyweight/time), and an ordered list of set records (reps, weight or duration, skipped flag).

No new entities are introduced by SCR-19. The `WorkoutSession` entity is written for the first time by this feature.

---

## Success Criteria

### Measurable Outcomes

- **SC-001**: 100% of successful saves produce a summary screen where the displayed data (plan name, date/time, duration, set counts, and per-exercise set pills) matches the data the user entered during the workout.
- **SC-002**: Zero duplicate records exist in workout history after any number of retries following a save failure. The deduplication guard prevents a second write in 100% of retry scenarios where the first write silently succeeded.
- **SC-003**: The loading indicator appears within one frame of the Finish tap — the user sees immediate feedback before the save operation completes.
- **SC-004**: After "Done" is tapped, the user cannot reach SCR-16 or any in-progress workout state via any navigation gesture. The navigation stack is clean in 100% of cases.

---

## Assumptions

- The session ID is generated when the workout begins on SCR-16, not when Finish is tapped. This ID is stable through any number of retry attempts.
- Duration displayed on the summary screen is total elapsed time from session start to Finish tap, including rest periods. It is not "net active time" (pause-aware).
- The date/time shown in the summary is the session start time, not the Finish tap time.
- "Exercises" stat counts all exercises present in the plan, regardless of whether any sets were completed. It is not a count of exercises that had ≥1 non-skipped set.
- "Sets Logged" stat counts only non-skipped (completed) sets. Skipped sets are displayed but not counted in the stat.
- There is no "Discard Workout" or "Give Up" option on the error state. The only action is Retry. Users who cannot save must force-quit the app. This is the v1 product decision.
- The error state on Android blocks the hardware back button — the user cannot navigate away from the error state using back.
- Once on the summary screen, the user can navigate to SCR-20 (View History) and then back to the summary — the summary remains on the navigation stack below SCR-20 as a read-only screen.
- SCR-19 covers only the case of ≥1 set logged + explicit Finish tap. The design spec has confirmed that "incomplete workout" (FR-3) and "connectivity" (FR-5) states are removed — they are not within the scope of this feature.
- The visual design (colours, spacing, typography tokens, icon shapes) is governed by the design spec (`design/spec.md`). The new `successFill` colour token (`#1e2a12`) required by the hero icon is a design system change that will be confirmed when the feature is implemented.

## Clarifications

### Session 2026-09-23

- OQ-1 (Session ID strategy): Session ID generated at workout start on SCR-16; stable through all retries. FR-011 (deduplication guard) is predicated on this assumption.
- OQ-2 (App backgrounded during loading): Loading state shown on foreground resume if write still in progress; correct outcome state (summary or error) shown if write completed while backgrounded. The write is never restarted. Captured in Edge Cases.
- OQ-3 (Date/time timestamp): Session start time (not Finish tap time). Captured in FR-004 and Assumptions.
- OQ-4 (Sets Logged definition): Non-skipped (completed) sets only. Captured in FR-004 and Assumptions.
- OQ-5 (Exercises stat definition): All exercises in the plan (regardless of completion). Captured in FR-004 and Assumptions.
- OQ-6 (Android back from Error): Blocked — user must retry or force-quit. Captured in FR-014.
- OQ-7 (SCR-19 on stack after View History): SCR-19 stays below SCR-20; user can navigate back to summary from SCR-20. Captured in FR-012 and US3 AC-2.
- OQ-8 (Discard from Error): No discard option in v1 — artboard is canonical. Captured in Assumptions.
- OQ-9 (Duration): Total elapsed time (start to Finish tap), including rest periods. Captured in FR-004 and Assumptions.
- OQ-10 (successFill token): New token required; design system change to be confirmed during implementation. Captured in Assumptions.
