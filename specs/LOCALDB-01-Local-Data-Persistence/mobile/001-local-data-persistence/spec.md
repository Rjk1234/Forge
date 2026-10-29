# Feature Specification: Local Data Persistence

**Feature Branch**: `LOCALDB-01-local-data-persistence`

**Created**: 2026-09-19

**Status**: Draft

**Input**: User description: "create mobile spec for LOCALDB-01"

## Clarifications

### Session 2026-09-19

- Q: Should the spec include measurable read/write timing targets for persistence operations? → A: Yes — individual write (plan or record) under 1 second; read of 50 workout records under 2 seconds (aligns with QA spec PR-01/PR-02).
- Q: When a persistence write fails, what is the required user-visible response? → A: The user sees a clear error message; the operation can be retried without data loss (inline or dialog error state).

## Overview

ForgeApp stores all user data — workout plans, completed workout records, weekly schedule assignments, and the user profile — exclusively on the device. There is no cloud, no backend, and no network connection. Every piece of data the user creates stays on their device and is available the next time they open the app.

This story defines the persistence contract: what data is saved, when it is saved, what can never be lost, and what is explicitly never written (cancelled workouts). It is a cross-cutting foundational capability that every data-producing and data-consuming screen depends on.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Data Survives App Restarts (Priority: P1)

A user creates workout plans, completes workouts, and assigns plans to days of the week. When they close the app — or when the OS kills it — and reopen it later, everything they created is still there. Nothing is lost between sessions.

**Why this priority**: This is the foundational promise of any persistence layer. Without it, no other feature is usable. A user who loses their plans on restart will immediately stop using the app.

**Independent Test**: Create a workout plan and complete one workout. Force-close the app. Reopen it. Both the plan and the workout record appear exactly as created, with no data loss. The schedule assignment (if made) is also intact.

**Acceptance Scenarios**:

1. **Given** the user has created one or more workout plans, **When** the app is closed and reopened, **Then** all plans appear in the workout plans list exactly as they were created.
2. **Given** the user has completed one or more workouts, **When** the app is closed and reopened, **Then** all completed workout records appear in workout history with their full performance data intact.
3. **Given** the user has assigned plans to days of the week, **When** the app is closed and reopened, **Then** all schedule assignments are intact.
4. **Given** the app is force-closed by the OS mid-session (not during a workout), **When** the user relaunches, **Then** all previously saved data is still present and uncorrupted.

---

### User Story 2 — Workout History Is Never Corrupted by Plan Changes (Priority: P2)

A user completes a workout using a plan. Later, they edit the plan (change exercises, sets, or targets) or delete it entirely. The historical record of the workout they already completed must remain exactly as it was at the time of completion — it must never be retroactively changed or removed when the plan changes.

**Why this priority**: This is the core data-integrity guarantee. Progress and statistics features are only meaningful if the historical record is an accurate snapshot of what was actually done. Retrospective mutation would silently corrupt all statistics.

**Independent Test**: Complete a workout using Plan A. Edit Plan A (change an exercise). Check workout history — the record shows the original plan values, not the edited ones. Then delete Plan A. Check history again — the record is still present.

**Acceptance Scenarios**:

1. **Given** a workout has been completed and recorded, **When** the associated workout plan is subsequently edited, **Then** the historical workout record retains the performance data captured at the time of completion, unchanged.
2. **Given** a workout has been completed and recorded, **When** the associated workout plan is subsequently deleted, **Then** the historical workout record remains fully accessible in workout history.
3. **Given** multiple completed workout records exist, **When** any plan is deleted, **Then** only the plan is removed — no history records are affected.

---

### User Story 3 — Only Completed Workouts Are Saved (Priority: P3)

A user starts a workout but cancels it, or taps Finish without having logged any sets. In both cases, nothing is written to storage. The workout history, progress charts, and statistics must reflect only workouts where at least one set was actually performed and the user explicitly tapped Finish.

**Why this priority**: The completion criterion defines the boundary between a real workout record and noise. Getting this wrong silently inflates statistics and history counts. It is a clear, testable rule with a binary outcome.

**Independent Test**: Start a workout and cancel it — check history (no new record). Start a workout, log zero sets, tap Finish — check history (no new record). Start a workout, log one set, tap Finish — check history (new record present).

**Acceptance Scenarios**:

1. **Given** the user starts a workout and then cancels it via the Cancel confirmation, **When** the session ends, **Then** no workout record is written to storage and history count is unchanged.
2. **Given** the user starts a workout, skips all sets, and taps Finish, **When** the session ends, **Then** no workout record is written (zero sets logged = discard, same as cancel).
3. **Given** the user starts a workout, logs at least one set for at least one exercise, and taps Finish, **When** the session ends, **Then** exactly one completed workout record is written to storage with full performance data.
4. **Given** the app is force-killed while a workout is in progress, **When** the user relaunches, **Then** no partial or incomplete workout record exists in storage — the in-progress session is silently discarded.

---

### User Story 4 — Data Is Consistently Available to History, Progress, and Statistics (Priority: P4)

A user's completed workout records are the shared data source for three features: Workout History (SCR-20/21), Progress Comparison (SCR-22), and Statistics/Personal Bests (SCR-23/24). All three features must read from the same underlying records — there is no per-feature copy or filtered subset. Every record available in History is also the input for Progress and Statistics.

**Why this priority**: Consistency across features is a correctness requirement. Divergence — where History shows 10 workouts but Statistics only calculates from 8 — would be confusing and erode trust. This story establishes that the persistence layer makes no per-consumer filtering decisions.

**Independent Test**: Complete 5 workouts. Verify that History shows 5 records, that Progress has all 5 to draw from, and that Statistics calculations are based on all 5.

**Acceptance Scenarios**:

1. **Given** completed workout records exist in storage, **When** the user opens Workout History, **Then** the feature reads and displays all persisted records — no records are hidden or excluded by the persistence layer.
2. **Given** completed workout records exist in storage, **When** the user opens Progress Comparison, **Then** the feature draws from the same complete set of persisted records used by History.
3. **Given** completed workout records exist in storage, **When** the user opens Statistics or Personal Bests, **Then** the feature draws from the same complete set of persisted records used by History.
4. **Given** a new workout record is added, **When** the user subsequently views History, Progress, or Statistics in any order, **Then** all three features reflect the newly added record.

---

### Edge Cases

- What happens when a write to local storage fails mid-operation? The previously saved data must remain intact, the user must see a clear error message, and the user must be able to retry the operation — no silent failure, no partial state, no blank screen (FR-011, FR-013, SC-006, SC-011).
- What happens if the app is restarted many times in succession? All data must survive any number of restarts without accumulating errors or corruption.
- What happens when the user has a large number of plans and workout records (e.g., 20 plans, 50+ workout records)? All data must load and save without truncation or imposed limits.
- What happens when a plan is assigned to a weekday that already has a plan assigned? The system must enforce one plan per weekday — the second assignment replaces or blocks the first (not both stored).
- What happens when storage fails during the Finish of a workout that meets the completion criterion? The write must be retried or clearly fail — it must not produce a duplicate record on success.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST persist every workout plan the user creates, in full, so it is available after the app is closed and reopened.
- **FR-002**: The app MUST persist every workout plan's full content (name, exercises, sets, reps, weight or duration targets) so the plan can be fully reconstructed on retrieval.
- **FR-003**: The app MUST persist a completed workout record only when the user logs at least one set for at least one exercise and explicitly taps Finish.
- **FR-004**: A cancelled workout session or a Finish with zero sets logged MUST NOT produce any record in storage — nothing is written, nothing appears in history.
- **FR-005**: Each persisted workout record MUST contain the complete performance data captured during that session: date, time, duration, and per-exercise per-set actuals (reps, weight or duration as applicable).
- **FR-006**: A workout record once written MUST remain unchanged regardless of subsequent edits or deletion of the associated workout plan.
- **FR-007**: When a workout plan is deleted, all previously recorded workout history associated with that plan MUST remain fully accessible.
- **FR-008**: All persisted completed workout records MUST be available as the data source for Workout History, Progress Comparison, and Statistics — the persistence layer applies no per-consumer filtering.
- **FR-009**: The app MUST persist weekly schedule assignments (which plan is assigned to which day of the week), with exactly one plan allowed per weekday.
- **FR-010**: All persisted data (plans, workout records, schedule assignments, user profile) MUST survive app restarts, force-closes, and OS-triggered terminations.
- **FR-011**: A write failure MUST NOT corrupt or remove previously persisted data — each write operation must be safe to fail without side effects on existing records.
- **FR-012**: The app MUST NOT make any network call as part of any persistence operation — all reads and writes are entirely local.
- **FR-013**: When a persistence write fails (saving a plan, finishing a workout, or updating a schedule assignment), the app MUST display a clear error message to the user and preserve the ability to retry the failed operation without data loss — no silent failure, no partial state left behind.

### Key Entities

- **Workout Plan**: A named collection of exercises with target sets, reps, and weight or duration values. Created and edited by the user. Can be assigned to weekdays. Can be deleted.
- **Completed Workout Record**: An immutable snapshot of a single workout session. Captures the date, duration, and actual performance for each exercise and set logged. Written once at Finish; never modified thereafter.
- **Schedule Assignment**: A mapping of a workout plan to a specific day of the week. At most one plan per day. Independent of workout records.
- **User Profile**: The user's account data (name, profile settings). Persisted locally; not coupled to workout data.
- **Exercise Catalogue**: A read-only set of available exercises seeded at install. Not user-created; not subject to the persistence lifecycle described here.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of workout plans created by the user are retrievable after an app restart — zero plans lost between sessions under normal operation.
- **SC-002**: 100% of completed workout records (those meeting the completion criterion) are retrievable after an app restart — zero records lost.
- **SC-003**: Zero completed workout records exist in storage for any cancelled or zero-set session — the completion criterion is enforced with no exceptions.
- **SC-004**: Editing or deleting a workout plan produces zero changes to any pre-existing workout record — historical data integrity is maintained in 100% of plan-modification scenarios.
- **SC-005**: All three downstream features (History, Progress, Statistics) read from the same set of workout records — no record visible in History is absent from the inputs to Progress or Statistics.
- **SC-006**: A local write failure leaves all previously persisted data intact — no data loss occurs as a side effect of a failed write.
- **SC-007**: The app produces no network traffic of any kind during any persistence operation.
- **SC-008**: The app loads up to 20 plans and 50 completed workout records without imposing a hard limit or data truncation.
- **SC-009**: Any single persistence write (saving a plan or a completed workout record) completes in under 1 second under normal operating conditions.
- **SC-010**: Reading up to 50 completed workout records (as required by History, Progress, or Statistics) completes in under 2 seconds on the minimum supported device specifications (Android API 29 / iOS 15).
- **SC-011**: When a write operation fails, the user is shown a visible error message within the same screen interaction — the failure is never silent, and the screen never enters a blank or undefined state.

---

## Assumptions

- The app operates in a fully offline, single-user environment — there is no syncing, no cloud backup, and no multi-device access to design for.
- The exercise catalogue is seeded at install time and is read-only; it is not part of the user-created data lifecycle described here.
- "Force-close" and OS-terminated app scenarios are treated equivalently — in both cases, any in-progress (not yet finished) workout session is silently discarded; only previously saved data (plans, records, schedule) must survive.
- "One plan per weekday" is the enforced schedule constraint; the behaviour when a second plan is assigned to an occupied day (block or replace) is defined by the schedule management feature (SCR-13), not by this story.
- Profile data (user name and settings) follows the same persistence rules (survives restarts, no network) but its specific schema is owned by the Profile feature (SCR-25).
- Data migration between versions of the data schema is out of scope for this story.
- Local data encryption at rest is out of scope for this POC; data is stored in plain form on the device.
- No backup or restore mechanism is in scope; users accept that uninstalling the app removes all local data.
