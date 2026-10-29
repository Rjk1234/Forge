# Feature Specification: SCR-21 — Workout History Detail

**Feature Branch**: `001-scr-21-workout-history-detail`

**Created**: 2026-09-23

**Status**: Draft

**Design reference**: `specs/SCR-21-Workout-History-Detail/design/spec.md`

**QA reference**: `specs/SCR-21-Workout-History-Detail/QA/SCR-21-qa-spec.md`

---

## Clarifications

### Session 2026-09-23

- Q: Should the spec define the Initial Bloc state (shows skeleton) and explicitly rule out an Empty state? → A: Yes — `Initial` state exists and MUST render the skeleton widget; `Empty` state is not applicable (a zero-exercise session renders as Success, not Empty).

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View Full Workout Detail (Priority: P1)

A user taps a session row on the Workout History screen (SCR-20) and is taken to a detail view showing the complete recorded performance for that session. While data is being read, a skeleton loading state prevents any blank-screen flash. On success, the screen shows the workout name, the session date and time, a three-stat summary (duration, exercise count, set count), and a per-exercise breakdown — each exercise displayed as a card with a type indicator, a set count label, and individual set pills showing the logged value in type-appropriate format.

**Why this priority**: This is the primary purpose of the screen — showing recorded session detail. All other stories are ancillary to this happy path. Without it, the screen delivers no value.

**Independent Test**: Can be fully tested by seeding a completed `WorkoutSession` record with at least two exercises of different types (weighted, bodyweight, time-based), navigating from SCR-20, and verifying the skeleton appears then resolves to full detail.

**Acceptance Scenarios**:

1. **Given** the user is on the history list (SCR-20), **When** they tap any session row, **Then** the detail screen is pushed and a skeleton loading state is shown immediately with no blank frame between navigation and skeleton appearance.

2. **Given** the skeleton is visible, **When** the session data is read successfully, **Then** the skeleton transitions to the populated Main state.

3. **Given** the Main state, **Then** the hero section shows the recorded workout name (as stored in the session snapshot) and the session date/time formatted as `"Ddd, Mon D, YYYY · H:MM AM/PM"` (e.g., `"Mon, Sep 7, 2026 · 6:42 PM"`) using the session's `startedAt` field (falling back to `completedAt` if `startedAt` is absent).

4. **Given** the Main state, **Then** the stat row shows three boxes: "DURATION" (session duration in whole minutes), "EXERCISES" (total exercise card count), "SETS LOGGED" (total set slots including skipped sets).

5. **Given** the Main state, **Then** a "Performance" section label appears above the exercise cards.

6. **Given** an exercise of type **weighted**, **Then** each non-skipped set pill shows `{reps}×{weight}kg` (e.g., `"8×60kg"`); each skipped set shows `"Skipped"` rendered with a strikethrough and dim styling.

7. **Given** an exercise of type **bodyweight**, **Then** each non-skipped set pill shows `{reps} reps` (e.g., `"15 reps"`).

8. **Given** an exercise of type **time**, **Then** each non-skipped set pill shows `MM:SS` (e.g., `"00:45"`); for durations ≥ 60 minutes, the format upgrades to `H:MM:SS`.

9. **Given** the Main state, **Then** the appbar title is "Workout Detail", the back arrow is visible, and no edit or delete controls appear anywhere on the screen.

10. **Given** the Main state with many exercise cards, **When** the content overflows the viewport, **Then** the content area scrolls while the appbar remains fixed.

---

### User Story 2 — Error State with Retry (Priority: P2)

When local data read fails, the user sees a distinct error card explaining that the current session could not be loaded, reassuring them their history as a whole is intact, and offering a Retry button. Tapping Retry re-triggers the data read, showing the skeleton again. If the retry succeeds, the Main state is shown; if it fails, the error state reappears. The error state is never shown when the read succeeds (not even for an empty session), and the empty state from SCR-20 is not reused here.

**Why this priority**: Error state is a constitutional requirement — every screen must handle failure explicitly (ADR-027). Without it, a Drift read failure leaves the screen in an ambiguous state, violating the architecture contract.

**Independent Test**: Can be fully tested by injecting a mock `WorkoutSessionRepository` that returns `Left(CacheException)`, navigating to the detail screen, observing the error card, and tapping Retry.

**Acceptance Scenarios**:

1. **Given** the session data read fails, **When** the screen is in Loading state, **Then** the error card is shown with title "Couldn't load this workout", body "Something went wrong reading local data. Your workout history is unaffected.", and a "Retry" button.

2. **Given** the error state, **When** the user taps Retry, **Then** the loading skeleton reappears and a fresh data read is triggered.

3. **Given** a Retry in progress, **When** the read succeeds, **Then** the Main state is shown.

4. **Given** a Retry in progress, **When** the read fails again, **Then** the error state reappears; no crash or frozen state.

5. **Given** the error state, **When** the user double-taps Retry, **Then** only one Retry cycle is triggered (debounce guard prevents concurrent reads).

---

### User Story 3 — Historical Data Integrity (Priority: P3)

The detail view always shows the performance data exactly as recorded at the time the session was completed, regardless of any subsequent changes to the workout plan or exercise catalogue. If the plan has since been renamed, the original name is shown. If an exercise was removed from the plan after the session was logged, it still appears in the detail. No reads from the workout plan are performed at display time.

**Why this priority**: Historical integrity is a key design guarantee of the app. It can be validated independently of the UI by examining the data source; the screen's correct behaviour depends only on reading from the `workout_sessions` snapshot, not from `workout_plans`.

**Independent Test**: Can be tested by completing a workout, editing the plan name and removing one exercise, then reopening the session detail and verifying the original plan name and the removed exercise still appear.

**Acceptance Scenarios**:

1. **Given** a `WorkoutSession` snapshot was captured with plan name "Push Day A", **When** the plan is subsequently renamed to "Push Day", **Then** the detail screen shows "Push Day A" (the snapshotted name).

2. **Given** a `WorkoutSession` snapshot was captured including exercise "Tricep Pushdown", **When** that exercise is subsequently removed from the plan, **Then** the detail screen still shows "Tricep Pushdown" with all its recorded sets.

3. **Given** a `WorkoutSession` snapshot was captured for a plan that is subsequently deleted, **Then** the detail screen still shows the full session detail.

4. **Given** the detail screen is open, **Then** no reads or writes are made to the `workout_plans` or `exercises` Drift tables at any point during the screen's lifecycle.

---

### Edge Cases

- What happens when a session has zero exercises (e.g., saved empty)? → Stat row shows `0 exercises` and `0 sets`; the "Performance" section label appears with no exercise cards below it.
- What happens with a very long exercise name? → The `ex-name` flex-fills and wraps; card height grows to accommodate.
- What happens when a session has 20+ exercises or 15+ sets per exercise? → Content scrolls; no pagination in v1.
- What happens when `startedAt` is null (SCR-16 prerequisite not yet merged)? → Fall back to `completedAt` for both the hero date/time and the duration calculation.
- What happens when the Drift read returns a valid session ID but with a partially corrupt exercise entry? → Silently omit the corrupt exercise; show whatever data loaded successfully. If the whole record is unreadable, show the Error state.
- What happens when the user taps the back arrow while still in Loading state? → Screen pops immediately; any in-progress data read is abandoned (Bloc closed, stream disposed).

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: On screen entry, the Loading (skeleton) state MUST appear immediately — no blank frame between navigation push and skeleton display.
- **FR-002**: The screen MUST show the workout name, formatted date/time, duration stat, exercise count stat, set count stat, a "Performance" section label, and per-exercise cards on successful load.
- **FR-003**: Each exercise card MUST show a type-indicator dot (weighted=lime, bodyweight=muted, time=cyan), the exercise name, a set count label ("N sets"), and individual set pills.
- **FR-004**: Set pill format MUST vary by exercise type: weighted → `{reps}×{weight}kg`; bodyweight → `{reps} reps`; time → `MM:SS` (upgrade to `H:MM:SS` for ≥ 60 minutes); skipped → "Skipped" (strikethrough, dim).
- **FR-005**: Date/time MUST be formatted as `"Ddd, Mon D, YYYY · H:MM AM/PM"` using the session's `startedAt` field (or `completedAt` if `startedAt` is absent). Pure Dart static arrays MUST be used; the `intl` package MUST NOT be introduced.
- **FR-006**: Duration stat MUST display whole minutes rounded to nearest minute.
- **FR-007**: "SETS LOGGED" stat MUST count all set slots including skipped sets.
- **FR-008**: Historical integrity MUST be preserved: all displayed data is sourced exclusively from the `WorkoutSession` snapshot; no reads from `workout_plans` or `exercises` at display time.
- **FR-009**: On Drift read failure, an Error state MUST be shown with title "Couldn't load this workout", body "Something went wrong reading local data. Your workout history is unaffected.", and a "Retry" button. This Error state MUST NOT be shown when the read succeeds.
- **FR-010**: Tapping Retry MUST re-trigger the data read, showing the Loading skeleton again.
- **FR-011**: Retry MUST be debounced — a second tap while a read is already in progress is ignored.
- **FR-012**: The appbar MUST show "Workout Detail" as title and a back arrow (chevron-left) as the only interactive control. No edit or delete controls may appear on this screen.
- **FR-013**: Back navigation (appbar back arrow or Android system back) MUST pop the screen and return to SCR-20 without triggering a re-fetch on SCR-20.
- **FR-014**: The content area MUST be scrollable when exercise cards overflow the viewport; the appbar MUST remain fixed during scroll.
- **FR-015**: No Drift writes of any kind MUST occur during the lifecycle of this screen.
- **FR-016**: The Bloc MUST define an `Initial` state that renders the skeleton widget identically to the Loading state. If the widget tree renders while the Bloc is in `Initial` (before the first event has fired), the skeleton MUST be shown — no blank screen is ever acceptable.
- **FR-017**: An `Empty` Bloc state is NOT applicable for this screen. A session with zero recorded exercises is a valid `Success` state: the stat row shows `0 exercises` and `0 sets`, the "Performance" label is present, and no exercise cards appear. The absence of exercises is not an error and is not an empty state.

### Key Entities *(feature involves data)*

- **WorkoutSession**: The immutable snapshot written at session completion. Provides `planName`, `startedAt`, `completedAt`, `sessionDurationSec`, and `sessionExercises`. SCR-21 reads this entity directly; no derived or joined data.
- **SessionExercise**: Nested in `WorkoutSession`. Provides `exerciseName`, `type` (weighted / bodyweight / time — stored as `ExerciseType.timeBased` in code, not `.time`), and `actualSets`.
- **ActualSet**: Nested in `SessionExercise`. Provides `repetitions`, `weight`, `durationSec`, and `skipped` (SCR-16 prerequisite). If `skipped` is absent (pre-SCR-16 data), treat as non-skipped.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Loading skeleton appears within one frame of screen push — no blank frame is ever visible between navigation and skeleton (QA HP-01, PR-01).
- **SC-002**: Populated state shows all required data for each exercise type (weighted, bodyweight, time) as per acceptance scenarios in US1 (QA HP-02 through HP-05).
- **SC-003**: Session detail is identical before and after editing or deleting the parent plan — verified by the data-integrity test cases (QA DI-01, DI-02, EC-01, EC-02, EC-03).
- **SC-004**: Drift read failure produces the Error state (not a blank or partial render); Retry successfully re-enters Loading (QA NV-01, NV-02, NV-03).
- **SC-005**: Screen lifecycle produces zero Drift writes (QA DI-03, SC-01).
- **SC-006**: Record with 20+ exercises and many sets loads and displays without application hang (QA PR-02).

---

## Assumptions

- `WorkoutSession.startedAt` (added by SCR-16) is the preferred date/time source. Until SCR-16 is merged, `completedAt` is used as the fallback for both date display and duration calculation — no SCR-21 UI changes are required when SCR-16 lands, only the fallback guard can be removed.
- `ActualSet.skipped` (added by SCR-16) distinguishes skipped sets. Until SCR-16 is merged, all `ActualSet` entries are treated as non-skipped. "SETS LOGGED" counts total set slots including any that are skipped.
- `WorkoutSession` is a complete, self-contained snapshot — it stores `planName` and `exerciseName` as strings captured at completion time. No lookup into `workout_plans` or `exercises` is needed or permitted.
- The `intl` package is NOT available (ADR-030 governed set). All date/time formatting uses pure Dart static arrays (same approach as SCR-20).
- Navigation passes `session.sessionId` (String) as go_router `extra` from SCR-20 (research D-01 — overrides the earlier draft assumption). SCR-21 reads the full `WorkoutSession` via `GetWorkoutHistoryDetailUseCase.call(sessionId)` — a real Drift read via `WorkoutSessionRepository.getSessionById`. This gives the Loading skeleton authentic duration and enables a genuine Error state on Drift read failure. The Bloc transitions: `Initial` → `Loading` → `Success | Error`.
- Retry button touch target must meet 44pt minimum — `padding:13px 22px` applied to the button achieves this (design OQ-11 resolution).
- Bottom safe area: `MediaQuery.of(context).padding.bottom` is added to the base `14px` bottom padding on home-indicator devices to prevent content from being clipped (design OQ-2).
- Skipped sets are displayed as "Skipped" pills (dim, strikethrough, weight:600) — they are not omitted (design OQ-1 / QA OQ-01 resolution).
- The Duration stat is rounded to the nearest minute (design OQ-3).
- "SETS LOGGED" counts all set slots including skipped (design OQ-6).
- Time exercise pill format: `MM:SS` for durations under 60 minutes; `H:MM:SS` for 60 minutes or more (design OQ-4).
- Weights are stored and displayed in kg; unit localisation is out of scope for v1 (design OQ-5).
- SCR-21 has no sub-screens. Scroll position resets to top on each entry (design OQ-7).
- The Loading-state appbar dims both the title and the back arrow to `var(--dim)` — this is an intentional design decision (design OQ-8).
