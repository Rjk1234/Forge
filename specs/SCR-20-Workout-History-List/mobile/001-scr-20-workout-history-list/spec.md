# Feature Specification: SCR-20 Workout History List

**Feature Branch**: `001-scr-20-workout-history-list`

**Created**: 2026-09-23

**Status**: Draft

**Input**: User description: "mobile spec for SCR-20"

**Design reference**: `specs/SCR-20-Workout-History-List/design/spec.md`

## Overview

SCR-20 is the Workout History screen — a root-level tab that gives the user a complete, readable view of every workout session they have ever completed on this device. Without this screen the user cannot verify that a workout was saved, review past performance, or navigate to a session's full detail (SCR-21).

The screen has four states: Loading (skeleton shown while data is being read), Main (populated list), Empty (no sessions recorded yet), and Error (local read failed). These states must be entirely distinct — the error state must never be silently replaced by the empty state.

**ForgeApp context**: The app is fully offline. All session data is read from the device's local workout history storage. No network call occurs. The History screen is one of six permanent tabs and is reachable from any tab at any time, as well as directly from the Workout Summary screen (SCR-19) via a "View History" button.

---

## User Scenarios & Testing

### User Story 1 — Browse Completed Workout History (Priority: P1)

After completing workouts over time, the user wants to see everything they have logged — in reverse-chronological order, grouped by month — so they can track training volume and identify what they did when. Each row gives enough summary information (date, plan name, duration, exercise count, set count) to be useful without having to open a detail view.

**Why this priority**: This is the primary purpose of the screen. Without a populated list, every other feature on this screen (empty state, error state, detail navigation) has no context. This is the core value delivered by SCR-20.

**Independent Test**: Record at least two completed workout sessions across two different calendar months. Navigate to the History tab. Verify: the loading skeleton appears briefly; then the populated list appears with one month-group section label per calendar month, sessions in reverse-chronological order within each group, and each row showing the correct day, day-of-week, plan name, duration in minutes, exercise count, and set count.

**Acceptance Scenarios**:

1. **Given** the user taps the History tab (from any tab), **When** the screen loads, **Then** a skeleton loading state is immediately shown, with placeholder rows indicating that data is being retrieved.
2. **Given** the loading state is active and at least one completed session exists in local history, **When** the data read completes, **Then** the populated list is displayed with sessions grouped by calendar month (label: "Month YYYY" — e.g. "September 2026") and ordered newest-first within each group.
3. **Given** the populated list is displayed, **When** the user reviews each session row, **Then** each row shows: a zero-padded day number, a 3-letter day-of-week abbreviation (e.g. "Mon", "Sat"), the workout plan name, and a summary line in the format "{N} min · {N} exercises · {N} sets".
4. **Given** the populated list is displayed, **When** the user taps a session row, **Then** the app navigates to the Workout History Detail screen (SCR-21) for that session.
5. **Given** the user has opened a session detail (SCR-21) from the history list and navigates back, **When** the history list is visible again, **Then** the list content is the same as before opening the detail — no re-fetch occurs on back-navigation from SCR-21.

---

### User Story 2 — Handle Empty History and Load Failures (Priority: P2)

When the user has never completed a workout or when the local read fails, the screen must surface a clear, non-blank state. The empty state tells the user there is no history yet; the error state explains the failure, reassures the user that other app data is unaffected, and offers a retry.

**Why this priority**: A blank screen or misleading state (showing "no history" when the real cause is a read failure) damages user trust and may cause the user to believe sessions were lost. These states are essential for production confidence but are fallback flows — the happy path in US1 occurs far more frequently.

**Independent Test**: (a) On a fresh install with no completed workouts, open the History tab. Verify the empty state appears with title "No workout history yet" and body "Your completed workouts will appear here." (b) Simulate a local read failure (e.g. via test-level injection). Open the History tab. Verify the error state appears with its title, message, and Retry button — not the empty state. Tap Retry. Verify the skeleton reappears and the outcome state matches the simulated result.

**Acceptance Scenarios**:

1. **Given** the user opens the History tab and no completed sessions exist in local history, **When** the data read completes successfully, **Then** the empty state is displayed with the title "No workout history yet" and the body "Your completed workouts will appear here."
2. **Given** the user opens the History tab and the local read fails, **When** the read error is caught, **Then** the error state is displayed — the empty state is NOT shown; the error state includes the title "Couldn't load your history", the message "Something went wrong reading local data. Your plans and schedule are unaffected.", and a "Retry" button.
3. **Given** the error state is displayed, **When** the user taps Retry, **Then** the loading skeleton reappears and the read is re-attempted.
4. **Given** the user taps Retry and the re-attempt also fails, **Then** the error state is shown again; the user can retry as many times as needed.
5. **Given** the user taps Retry and the re-attempt succeeds with sessions present, **Then** the populated list is displayed.
6. **Given** the user taps Retry and the re-attempt succeeds with no sessions, **Then** the empty state is displayed.

---

### User Story 3 — Newly Completed Session Appears at Top on Re-entry (Priority: P3)

When the user completes a workout on SCR-19 and taps "View History", they expect to see the session they just finished at the top of the list. Switching to the History tab from any other tab should also always show fresh data.

**Why this priority**: This is a correctness/freshness requirement — the data shown must be up-to-date on every tab-switch entry. It is lower priority because it is about staleness rather than a new user flow.

**Independent Test**: Complete a workout via SCR-19. On the Workout Summary screen, tap "View History". Verify the History tab opens with the newly completed session appearing at the top of the list (most recent date, top of the newest month group). Then switch to the Home tab and back to History — verify the list is freshly read and the session still appears.

**Acceptance Scenarios**:

1. **Given** the user taps "View History" on SCR-19 (Workout Summary), **When** the History tab opens, **Then** the data is re-fetched and the newly completed session appears at the top of the list.
2. **Given** the user switches from any tab to the History tab, **When** the History tab becomes active, **Then** the data is re-fetched from local history; any sessions completed since the last visit are now visible.

---

### Edge Cases

- **No sessions ever (first launch)**: Empty state displayed — distinct from error state.
- **Retry fails repeatedly**: Error state re-shown after each failure; there is no retry limit.
- **Session with a very long plan name**: The plan name wraps to additional lines within the card; card height grows; no truncation is applied.
- **Session with missing or corrupt data fields**: Shown with fallback values — "Unknown Plan" for a missing name; "—" for missing duration, exercise count, or set count. The row is not omitted.
- **Very large history (100+ sessions)**: The full list is loaded; the scrollable list handles display. Pagination is not required in this version.
- **Back from SCR-21 to SCR-20**: List is preserved in memory — no re-fetch occurs.
- **Tab switch to History while already on History**: No re-fetch; screen is already active; behaviour is a no-op.
- **App backgrounded on History tab**: On foreground resume, no automatic refresh; data displayed is preserved.

---

## Requirements

### Functional Requirements

- **FR-001**: On screen entry (tab tap or arrival from SCR-19 "View History"), the system MUST immediately display a loading skeleton while local history data is being retrieved.
- **FR-002**: If the local history read succeeds and at least one session exists, the system MUST display all completed sessions grouped by calendar month in reverse-chronological order (newest month first, newest session first within each month).
- **FR-003**: Each session row MUST display: (a) a zero-padded 2-digit day number (e.g. "07"), (b) a 3-letter day-of-week abbreviation in uppercase (e.g. "MON"), (c) the workout plan name, and (d) a summary line in the format "{N} min · {N} exercises · {N} sets" where N is the actual count for that session.
- **FR-004**: Month section headers MUST appear above each group in the format "{Full Month Name} {Year}" (e.g. "September 2026").
- **FR-005**: Tapping any session row MUST navigate to the Workout History Detail screen (SCR-21) for that specific session.
- **FR-006**: If the local history read succeeds and zero sessions exist, the system MUST display the empty state with the title "No workout history yet" and the body "Your completed workouts will appear here."
- **FR-007**: If the local history read fails for any reason, the system MUST display the error state. The empty state MUST NOT be displayed as a fallback for a read failure — the two states MUST be entirely distinct.
- **FR-008**: The error state MUST display: (a) the title "Couldn't load your history", (b) the body "Something went wrong reading local data. Your plans and schedule are unaffected.", and (c) a "Retry" button.
- **FR-009**: Tapping Retry MUST re-display the loading skeleton and re-attempt the local history read.
- **FR-010**: If a retry attempt fails, the error state MUST be shown again; the user can retry indefinitely.
- **FR-011**: On navigating back from SCR-21 to SCR-20, the history list MUST be preserved in memory — no re-fetch occurs on back-navigation from the detail screen.
- **FR-012**: On every tab-switch entry to the History tab (including arrival from SCR-19 "View History"), the local history MUST be re-fetched so that newly completed sessions are visible.
- **FR-013**: Only sessions stored in this device's local history are shown. No network call is made.

### Key Entities

- **WorkoutSession** (completed): A saved session record with: session ID, workout plan name, session start time, session duration in minutes, count of exercises performed, count of sets logged (non-skipped). Used to populate each history row.

---

## Success Criteria

### Measurable Outcomes

- **SC-001**: 100% of completed sessions stored in local history appear in the list, in correct reverse-chronological order, with no omissions or ordering errors.
- **SC-002**: The error state and empty state are always distinct in 100% of cases — a read failure never silently displays the empty state; the error state is always shown with its Retry button.
- **SC-003**: The loading skeleton appears within one frame of the History tab becoming active — the user always sees an immediate visual response on screen entry.
- **SC-004**: Tapping any session row always navigates to SCR-21 with the correct session — no tap is silently dropped and no wrong session is opened.

---

## Assumptions

- Session data is stored locally on the device. There is no backend, no cloud sync, and no connectivity requirement. This feature is fully offline.
- The sets count shown in the summary line reflects non-skipped sets only (consistent with SCR-19's "Sets Logged" definition). If this assumption is incorrect, the implementation must be updated to match the agreed definition.
- The day-of-week abbreviation displayed in each row (e.g. "Mon", "Sat") is derived from the session start date, not the session completion date. For sessions that started and ended on the same calendar day, these are identical.
- Month grouping uses the session start date's calendar month, not the completion timestamp.
- The History tab is one of six permanent bottom-navigation tabs. SCR-20 is a root-level screen — it is not pushed onto a navigation stack and does not have a back button.
- Pull-to-refresh is not included in the initial version. Data is re-fetched on tab entry and on Retry; no manual refresh gesture is provided.
- Long-press on a history row does not trigger any action in the initial version.
- Sessions with missing or corrupt field values (e.g. no plan name recorded) are shown with fallback display values rather than hidden.
- No pagination is applied in the initial version. All sessions are loaded in a single read.
- Data re-fetch occurs on every tab-switch entry (including arrival from SCR-19) but not on back-navigation from SCR-21. This is the v1 refresh model.
