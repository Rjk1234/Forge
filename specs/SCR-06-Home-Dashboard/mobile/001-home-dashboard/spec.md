# Feature Specification: SCR-06 Home Dashboard

**Feature Branch**: `001-home-dashboard`

**Created**: 2026-09-16

**Status**: Draft

**Input**: User description: "mobile app for user story SCR-6 home dashboard."

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Today's Workout at a Glance (Priority: P1)

After logging in, the user opens the Home Dashboard and immediately sees today's workout — the plan they scheduled for today — along with a summary of what it involves. They tap the workout card to go straight to the pre-workout overview and begin training.

**Why this priority**: This is the primary daily use of the app. Getting the user from "app open" to "start workout" in the fewest steps is the core value of the dashboard.

**Independent Test**: Can be tested by assigning a workout plan to today's weekday in the schedule, then opening Home and verifying the workout card appears with the correct plan name, exercise count, and a working tap-to-start.

**Acceptance Scenarios**:

1. **Given** the user has at least one workout plan and it is assigned to today's weekday in the schedule, **When** the Home Dashboard loads successfully, **Then** a workout card appears showing the plan name, exercise count, dominant exercise type, and representative rest period, and the card is tappable.
2. **Given** the workout card is shown, **When** the user taps it, **Then** the app navigates to the Workout Pre-Start screen (SCR-15) for that plan.
3. **Given** the app just launched, **When** the Drift data is being read, **Then** a loading indicator is visible and the dashboard content is not yet shown.

---

### User Story 2 — Navigate to Any Major App Area (Priority: P2)

The user is on the Home Dashboard and wants to jump to Plans, Schedule, History, Progress, or Stats. They either tap one of the 5 quick-link tiles in the content area or use the persistent bottom navigation bar to switch to their destination tab.

**Why this priority**: The dashboard is the persistent navigation root. Every major area of the app should be reachable in one tap from here.

**Independent Test**: Can be tested on a populated dashboard (any data present) by tapping each of the 5 quick links and all 6 bottom nav tabs, verifying each navigates to the correct destination.

**Acceptance Scenarios**:

1. **Given** the dashboard is in a populated state (any data present), **When** the user taps the "Plans" quick link, **Then** the app navigates to the Workout Plans List (SCR-08).
2. **Given** the dashboard is in a populated state, **When** the user taps the "Schedule" quick link, **Then** the app navigates to the Weekly Schedule (SCR-12).
3. **Given** the dashboard is in a populated state, **When** the user taps the "History" quick link, **Then** the app navigates to the Workout History List (SCR-20).
4. **Given** the dashboard is in a populated state, **When** the user taps the "Progress" quick link, **Then** the app navigates to the Progress Comparison screen (SCR-22).
5. **Given** the dashboard is in a populated state, **When** the user taps the "Stats" quick link, **Then** the app navigates to the Statistics Dashboard (SCR-23).
6. **Given** any dashboard state (loading excepted), **When** the user taps any bottom navigation tab, **Then** the app navigates to the corresponding root screen and that tab becomes the active selection.
7. **Given** the dashboard is in the loading state, **When** the data is still being read, **Then** the non-Home bottom navigation tabs are visible but not interactive until loading completes.

---

### User Story 3 — First-Time Use and Rest Day (Priority: P3)

The user has either never created a workout plan, or has plans but nothing scheduled for today. In the first case they see an empty state with a direct prompt to get started. In the second case they see a rest-day message and retain full access to the quick links and navigation.

**Why this priority**: Both states still need to be clear and non-confusing, but they are less frequent than the daily populated use case.

**Independent Test**: Can be tested by (a) opening the app with no plans or schedule data at all — verifying the empty state with CTA appears; and (b) having plans but none assigned to today's weekday — verifying the rest-day card appears alongside quick links.

**Acceptance Scenarios**:

1. **Given** the user has no workout plans, no schedule entries, and no workout history, **When** the Home Dashboard loads successfully, **Then** the empty state is shown with the prompt "Create your first workout plan" and no quick links section.
2. **Given** the empty state is shown, **When** the user taps the "Create your first workout plan" button, **Then** the app switches to the Plans tab and navigates to the Create Workout Plan screen (SCR-09) within the Plans tab stack, making Plans the active bottom navigation tab.
3. **Given** the user has data (plans or history exist) but no plan is assigned to today's weekday, **When** the Home Dashboard loads successfully, **Then** a rest-day card is shown alongside the 5 quick links; the rest-day card itself is not tappable.

---

### User Story 4 — Error Recovery (Priority: P4)

The local data store fails to read when the user opens the Home Dashboard. The user sees an error card explaining that something went wrong, with a "Retry" button. Crucially, the bottom navigation remains usable so the user is not trapped — they can still navigate to Plans, Schedule, or any other area.

**Why this priority**: Errors are exceptional. When they occur, the user must be able to recover or navigate away without being stuck.

**Independent Test**: Can be tested by simulating a database read failure, verifying the error state with retry button appears, verifying the bottom nav tabs are tappable, tapping Retry and verifying a new loading + data cycle begins.

**Acceptance Scenarios**:

1. **Given** the Drift data read fails on mount, **When** the Home Dashboard is shown, **Then** an error state appears with the message "Couldn't load your dashboard" and a "Retry" button.
2. **Given** the error state is shown, **When** the user taps "Retry", **Then** the loading state is shown and a new database read attempt begins.
3. **Given** the error state is shown, **When** the user taps any bottom navigation tab, **Then** the app navigates to the selected tab's screen; the bottom nav remains fully interactive.
4. **Given** the retry attempt also fails, **When** the new database read completes with an error, **Then** the error state is re-shown; the app does not crash.

---

### Edge Cases

- What happens when the user has plans but today's weekday (e.g. Sunday) has no plan in the schedule? → Rest-day card (variant B) shown alongside quick links.
- What happens if Drift returns an empty collection but the table exists? → Same as no-data condition — empty state or rest-day card depending on whether any plans exist.
- What happens when the user returns to Home from a deeper screen after adding a plan or editing the schedule? → Dashboard re-reads Drift and reflects the updated state; stale data is not shown.
- What happens when the user completes a workout (from SCR-19) and returns to Home? → Dashboard re-reads Drift; schedule is unchanged; workout history count is updated but not displayed on Home.
- What happens when no data but the loading state takes time? → Loading spinner is visible; no blank frame or empty flash before data arrives.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When the Home Dashboard is first displayed, the system MUST show a loading indicator while reading data from local storage.
- **FR-002**: When the local data read succeeds and the user has no plans, schedule entries, or workout history, the system MUST display the empty state with a single call-to-action to create a first workout plan.
- **FR-003**: When the local data read succeeds and today's weekday has an assigned workout plan in the schedule, the system MUST display that plan's name, exercise count, dominant exercise type, and the rest period of the plan's first exercise on a tappable workout card. If the plan has no exercises, the rest period chip is omitted.
- **FR-004**: Tapping the today's workout card MUST navigate to the Workout Pre-Start screen for that plan.
- **FR-005**: When the local data read succeeds and data exists but no workout plan is assigned to today's weekday, the system MUST display a rest-day card (not tappable) alongside the quick links section.
- **FR-006**: Both populated states (today's workout scheduled AND rest day) MUST show a quick links section with 5 tiles: Plans, Schedule, History, Progress, Stats — each navigating to its designated screen.
- **FR-007**: When the local data read fails, the system MUST display an error state with a message and a "Retry" button that re-triggers the data read.
- **FR-008**: The bottom navigation bar (6 tabs: Home, Plans, Schedule, History, Progress, Stats) MUST be present and interactive in all states except during the initial loading phase, where non-Home tabs MUST be visible but non-interactive.
- **FR-009**: The Home Dashboard MUST NOT write any data to local storage; it is a read-only view.
- **FR-010**: The empty-state CTA MUST switch the active tab to Plans and navigate to the Create Workout Plan screen (SCR-09) within the Plans tab stack, making the Plans tab the active bottom navigation selection.
- **FR-011**: The screen MUST NOT make any network calls; all data comes from local storage only.
- **FR-012**: The dashboard MUST re-read local storage every time the Home tab is activated, including returns from sub-screens or from another tab, so that the displayed data always reflects the current state of the local data store.

### Key Entities *(include if feature involves data)*

- **DashboardSnapshot**: A read-only view assembled on mount from local storage. Contains: whether any plans/schedule/history exist (the "has data" flag), and the plan assigned to today's weekday (if any). This is not a stored entity — it is derived at read time.
- **WorkoutPlan**: Existing entity. The dashboard uses: plan name, list of exercises (count and types), and representative rest period per exercise set.
- **ScheduleEntry**: Existing entity. Maps a weekday (1 = Monday … 7 = Sunday) to a workout plan. The dashboard looks up today's weekday to find today's assigned plan.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The user can identify today's workout — or confirm there is none — within 3 seconds of the Home Dashboard loading on a standard phone.
- **SC-002**: The user can reach any of the 5 major app areas (Plans, Schedule, History, Progress, Stats) in exactly 1 tap from the Home Dashboard in any populated or error state.
- **SC-003**: A first-time user with no data sees a clear next step; 100% of test sessions result in the user tapping the "Create your first workout plan" CTA without needing assistance.
- **SC-004**: In the error state, the user can tap Retry or navigate away via the bottom nav without the app crashing or freezing; recovery returns to the normal loading → data cycle.
- **SC-005**: All 4 states (loading, empty, populated/scheduled, populated/rest-day) and the error state are visually distinct and correctly triggered by their respective data conditions; no state is shown in place of another.

---

## Assumptions

- The screen is only reachable when the app is in the "unlocked" state (post-login). The route guard on SCR-01/SCR-03 prevents access when locked; this spec does not re-define that guard.
- "Today" is determined by the device's local date and time (`DateTime.now().weekday`). There is no server time synchronization.
- The "has data" check for the empty vs. populated decision reads all three local tables: workout plans, schedule entries, and workout history sessions. If any contains at least one entry, the populated path is taken.
- The rest period displayed in the today's workout card is the rest period of the first exercise in the plan's exercise list. If the plan has no exercises, the rest period chip is omitted.
- Quick links use the same icons as the corresponding bottom navigation tabs, but they are a separate, redundant shortcut — not the navigation tabs themselves.
- The bottom navigation bar is part of the shared app shell (persistent across all root tabs). Its implementation is shared infrastructure; this spec only defines its behavior for the Home tab context.
- The dashboard re-reads Drift every time the Home tab is activated — on initial mount and on every return from a sub-screen or from another tab. It does not subscribe to live Drift stream updates while open; the read is triggered by tab activation, not by data-change events.

---

## Clarifications

### Session 2026-09-16

- Q: When the user returns to the Home tab from a deeper screen, should the dashboard re-read data automatically? → A: Yes — re-read Drift every time the Home tab is activated (Option A). Affected: Assumptions (last bullet updated), FR-012 added.
- Q: Which rest period value is shown on the today's workout card — first exercise, mode, or max? → A: First exercise's rest period in the plan's exercise list; chip omitted if plan has no exercises (Option A). Affected: Assumptions (rest period bullet updated), FR-003 updated.
- Q: Does the empty-state CTA navigate via the Plans tab or push SCR-09 on top of Home? → A: Switch to Plans tab and push SCR-09 within the Plans tab stack; Plans tab becomes active (Option A). Affected: US-3 AC-2 updated, FR-010 updated.
