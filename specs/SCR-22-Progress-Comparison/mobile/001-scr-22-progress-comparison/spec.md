# Feature Specification: SCR-22 — Progress Comparison

**Feature Branch**: `001-scr-22-progress-comparison`

**Created**: 2026-09-23

**Status**: Draft

**Design reference**: `specs/SCR-22-Progress-Comparison/design/spec.md`

**QA reference**: `specs/SCR-22-Progress-Comparison/QA/SCR-22-qa-spec.md`

---

## Clarifications

### Session 2026-09-23

- Q: In what order should exercise chips appear in the chip row? (OQ-3) → A: Two-group sort, computed once on load: (1) exercises with ≥2 valid completed sessions, ordered by most-recent valid session date, newest first; (2) exercises with <2 valid sessions, same recency order. Tie-break within the same session: alphabetical by exercise name. Order is stable for the lifetime of the screen; no reordering while the user is on screen.
- Q: How is volume calculated for a session? (OQ-5) → A: **Weighted exercises**: Volume = Σ (weight × reps) across all non-skipped, completed sets of the exercise in the session; display rounded to whole numbers. **Bodyweight exercises**: The VOLUME tile is replaced by "TOTAL REPS" (Σ reps across non-skipped completed sets), because tonnage would always be 0 and is misleading.
- Q: What stat tiles should appear for time-based exercises? (OQ-14) → A: Replace the three tiles: TOP WEIGHT → "BEST DURATION" (longest single completed set); BEST REPS → "TOTAL TIME" (Σ durationSec across completed sets, formatted as `m:ss` under 1 hour / `h:mm:ss` at or above 1 hour); VOLUME → "SETS" (count of completed sets). Chart trend line for timeBased exercises plots **best duration per session** (max durationSec across non-skipped sets). Deltas compare against the previous valid session as with weighted exercises.
- Q: For a bodyweight exercise, what do the 3 stat tile slots show? → A: Option B — [TOTAL SETS (count of completed non-skipped sets) | BEST REPS (max reps in latest session) | TOTAL REPS (Σ reps in latest session)]. TOP WEIGHT is replaced by TOTAL SETS; VOLUME tile is replaced by TOTAL REPS. All 3 tile slots remain visible and carry meaningful data for bodyweight exercises.
- Q: When a delta value is negative (regression from last session), does the delta indicator render in a different color? → A: Yes — negative delta uses `AppColors.danger`; positive or zero delta uses `AppColors.lime`. Direction is communicated by both color and a +/− prefix on the value.
- Q: Is there a maximum number of sessions displayed on the chart? → A: Yes — the chart plots the most recent 12 sessions maximum for the selected exercise. Sessions beyond 12 are excluded from the chart only; stat tile calculations (latest value and delta) always use the two most recent sessions regardless of the cap.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View Exercise Progress Chart (Priority: P1)

A user opens the Progress tab (5th root tab) and, after a brief loading skeleton, sees a horizontal row of exercise chips. Tapping a chip selects an exercise and displays a line chart of their performance across sessions, a "Latest Session" label, and three stat tiles (Top Weight, Best Reps, Volume) each showing the current value and a delta indicator comparing against the previous session.

**Why this priority**: This is the screen's sole purpose. Without the chart and stats, the tab delivers zero value. All other stories are degraded or error paths. The chip row and chart are the core UI and must function before any other story can be assessed.

**Independent Test**: Can be fully tested by seeding ≥ 2 completed `WorkoutSession` records that share at least one exercise, navigating to the Progress tab, and verifying the skeleton resolves to the chip row and chart with stat tiles and delta indicators.

**Acceptance Scenarios**:

1. **Given** the user taps the Progress tab, **Then** a skeleton (3 chip placeholders, one chart placeholder, 3 stat placeholders) is shown immediately — no blank frame.

2. **Given** the skeleton is visible, **When** all session history is read from local storage, **Then** the skeleton transitions to the populated Main state.

3. **Given** the Main state, **Then** a horizontally scrollable chip row displays one chip per unique exercise found across all completed sessions; the first chip is pre-selected.

4. **Given** a chip is selected, **Then** a line chart is shown with one data point per completed session that contains the selected exercise; the x-axis represents sessions in chronological order; the y-axis represents the primary metric.

5. **Given** the chart, **Then** each regular data point is rendered as a filled circle; the most recent session's data point is rendered distinctly (larger, different fill) to draw attention.

6. **Given** the chart, **Then** three horizontal grid lines are drawn at equal intervals to provide visual reference for the y-axis scale.

7. **Given** the Main state, **Then** a "Latest Session" section label appears below the chart.

8. **Given** the Main state, **Then** three stat tiles appear: "TOP WEIGHT", "BEST REPS", and "VOLUME"; each tile shows a label, a value from the latest session, and a delta indicator showing the change since the previous session with a positive/negative sign.

9. **Given** the user taps a different chip in the chip row, **Then** the chart, "Latest Session" label, and stat tiles all update immediately to reflect the newly selected exercise, without re-reading from local storage.

10. **Given** the Main state, **Then** no navigation exits occur from this screen — no back arrow, no push routes. The screen remains at its tab position in the navigation bar.

---

### User Story 2 — Handle Insufficient Data Per Exercise (Priority: P2)

When the user selects an exercise chip that appears in fewer than 2 completed sessions, the screen shows an empty state message in place of the chart and stat tiles, while keeping the chip row visible so the user can select a different exercise that may have more data.

**Why this priority**: A per-exercise empty state is an expected and common early-use condition (most exercises will have only 1 session for new users). Without it, a blank or crashed chart would appear. The chip row must remain active so users can discover exercises with sufficient data.

**Independent Test**: Can be fully tested by seeding sessions where exercise A appears in ≥ 2 sessions (Main state) and exercise B appears in only 1 session (Empty state), then tapping between chips A and B and verifying the correct state renders for each.

**Acceptance Scenarios**:

1. **Given** the selected exercise appears in fewer than 2 completed sessions, **Then** an empty state is shown with title "Not enough data yet" and subtitle "Complete a few more workouts to see your progress." — no chart or stat tiles are shown.

2. **Given** the empty state is shown, **Then** the chip row remains visible and interactive; the user can tap a different chip.

3. **Given** the user taps a chip for an exercise with ≥ 2 sessions, **When** that chip is selected, **Then** the Main state (chart + stat tiles) is shown for the newly selected exercise.

4. **Given** the user taps a chip for an exercise with < 2 sessions, **Then** the empty state is shown again without a loading flash.

5. **Given** all exercises across all sessions have fewer than 2 sessions, **Then** the chip row is still shown with all exercise chips; tapping any chip shows the empty state.

---

### User Story 3 — Error State with Retry (Priority: P3)

When the local data read fails entirely, the user sees an error card explaining that progress could not be loaded and reassuring them that their workout history is unaffected. A Retry button re-triggers the data read, showing the skeleton again. If retry succeeds, the Main or Empty state is shown; if it fails again, the error state reappears.

**Why this priority**: Error state is a constitutional requirement for every screen (ADR-027). Without it, a Drift read failure leaves the Progress tab in an indeterminate state. It is independently testable by injecting a read failure.

**Independent Test**: Can be fully tested by injecting a mock `WorkoutSessionRepository` that returns `Left(CacheException)`, opening the Progress tab, observing the error card, tapping Retry, and verifying the skeleton reappears.

**Acceptance Scenarios**:

1. **Given** the local data read fails, **Then** an error card is shown with title "Couldn't load your progress" and body "Your workout history is unaffected.", and a "Retry" button. No chip row is shown.

2. **Given** the error state, **When** the user taps Retry, **Then** the loading skeleton reappears and a fresh data read is triggered.

3. **Given** a Retry in progress, **When** the read succeeds, **Then** the Main or Empty state is shown (depending on data availability).

4. **Given** a Retry in progress, **When** the read fails again, **Then** the error state reappears; no crash or frozen state.

5. **Given** the error state, **When** the user double-taps Retry, **Then** only one Retry cycle is triggered (debounce guard prevents concurrent reads).

---

### Edge Cases

- What happens when a session contains an exercise that has not appeared before? → It appears as a new chip; if it has only 1 session, the empty state is shown for that chip.
- What happens when the user rapidly taps multiple chips? → Each tap is handled; the last selected chip determines the displayed data. No concurrent reads are triggered.
- What happens when an exercise name is very long? → The chip text truncates with an ellipsis; the full name is not wrapped.
- What happens when there are many unique exercises (e.g., 30+)? → The chip row scrolls horizontally; no pagination in v1.
- What happens when an exercise has more than 12 completed sessions? → The chart shows the 12 most recent only; older sessions are excluded from the chart. Stat tiles always use the 2 most recent sessions (unaffected by the cap).
- What happens when a session record is corrupt or has missing fields? → The corrupt session is silently excluded from the exercise data; valid sessions are shown. If the whole read fails, the Error state appears.
- What happens when `ActualSet.skipped` is absent (pre-SCR-16 data)? → Treat as non-skipped (same guard as SCR-21).
- What happens when the Progress tab is revisited after backgrounding? → The existing loaded state is preserved in the Bloc (root tab — Bloc is not disposed on tab switch).

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: On Progress tab entry, a skeleton (3 chip placeholders, one chart placeholder, 3 stat tile placeholders) MUST appear immediately — no blank frame between tab activation and skeleton display.
- **FR-002**: The screen MUST read all completed `WorkoutSession` records from local storage exactly once per entry (or Retry); subsequent chip selections MUST NOT trigger additional reads.
- **FR-003**: The chip row MUST display one chip per unique exercise name found across all completed sessions, in a horizontally scrollable row.
- **FR-004**: Chips MUST have two visual states: selected (lime background, white text) and unselected (card-alt background, default text). Only one chip is selected at a time.
- **FR-005**: The first chip MUST be pre-selected on load. Chip order is computed once when data loads and is stable for the screen's lifetime. Sort rule: (1) exercises with ≥ 2 valid completed sessions, ordered by most-recent valid session date, newest first; (2) exercises with < 2 valid sessions, same recency order. Tie-break within the same session: alphabetical by exercise name. The pre-selected chip is always in Group 1 when any Group 1 chip exists, ensuring the default view shows a real chart rather than the empty state.
- **FR-006**: Tapping a chip MUST update the chart and stat tiles to reflect the selected exercise's data without triggering a new data read.
- **FR-007**: The chart MUST be a line chart rendered via Flutter's `CustomPainter` at logical dimensions 320 × 150 (scaled to fit the card width). Three horizontal grid lines MUST be drawn at equal vertical intervals as reference markers. The chart MUST plot at most the 12 most recent sessions containing the selected exercise; sessions beyond 12 are excluded from the chart. Stat tile values and deltas are always derived from the 2 most recent valid sessions regardless of this cap.
- **FR-008**: The chart trend line MUST connect all data points in chronological session order with a lime-colored stroke.
- **FR-009**: Each regular data point on the chart MUST be rendered as a circle (r:4, lime fill). The most recent session's data point MUST be rendered distinctly (r:5, white fill with lime border).
- **FR-010**: Below the chart, a "Latest Session" label MUST appear followed by three stat tiles.
- **FR-011**: Stat tile layout varies by exercise type. All layouts use 3 tiles with consistent visual treatment (label 9px/uppercase/dim, value 15px/weight-800, delta 10px/weight-700). **Weighted**: [TOP WEIGHT (max weight across non-skipped sets) | BEST REPS (max reps across non-skipped sets) | VOLUME (calculated per FR-012)]. **Bodyweight**: [TOTAL SETS (count of completed non-skipped sets) | BEST REPS (max reps across non-skipped sets) | TOTAL REPS (Σ reps across non-skipped sets)]. **timeBased**: [BEST DURATION (max durationSec, formatted `m:ss` / `h:mm:ss`) | TOTAL TIME (Σ durationSec) | SETS (count of completed non-skipped sets)]. Each tile MUST show a delta indicator showing the signed change from the equivalent tile value in the previous valid session. A positive or zero delta MUST render in `AppColors.lime`; a negative delta (regression) MUST render in `AppColors.danger`. Direction is communicated by both color and a +/− prefix on the value.
- **FR-012**: Volume calculation for **weighted** exercises: Volume = Σ (weight × reps) across all non-skipped completed sets of the selected exercise in the session, rounded to the nearest whole number. Skipped sets contribute 0 and are excluded. For bodyweight exercises, the VOLUME tile is replaced by "TOTAL REPS" (per FR-011) — tonnage is not calculated because weight is 0.
- **FR-013**: When the selected exercise has fewer than 2 completed sessions, the Empty state MUST be shown in place of the chart and stat tiles, with title "Not enough data yet" and subtitle "Complete a few more workouts to see your progress." The chip row MUST remain visible and interactive.
- **FR-014**: When the data read fails, an Error state MUST be shown with title "Couldn't load your progress" and body "Your workout history is unaffected.", and a "Retry" button. The chip row MUST NOT be shown in the Error state.
- **FR-015**: Tapping Retry MUST re-trigger the full data read, showing the Loading skeleton again. Retry MUST be debounced — a second tap while a read is in progress is ignored.
- **FR-016**: No Drift writes of any kind MUST occur during the lifecycle of this screen.
- **FR-017**: For `ExerciseType.timeBased` exercises, the stat tile substitutions and chart y-axis MUST follow the OQ-14 resolution: tile substitutions are specified in FR-011; the chart trend line plots **best duration per session** (max durationSec across non-skipped sets for the selected exercise in each session). Deltas for all timeBased tiles compare against the equivalent value from the previous valid session.
- **FR-018**: The Bloc MUST define an `Initial` state that renders the skeleton widget identically to the Loading state. No blank screen is ever acceptable.
- **FR-019**: The screen is a root tab — no back navigation, no appbar back arrow. The bottom navigation bar MUST remain visible at all times.

### Key Entities *(feature involves data)*

- **WorkoutSession**: The immutable snapshot written at session completion. SCR-22 reads all sessions from the `workout_sessions` table to compute per-exercise progress data. Provides `sessionId`, `completedAt`, and `sessionExercises`.
- **SessionExercise**: Nested in `WorkoutSession`. Provides `exerciseName`, `type` (stored as `ExerciseType.timeBased` / `.weighted` / `.bodyweight` in code), and `actualSets`.
- **ActualSet**: Nested in `SessionExercise`. Provides `repetitions`, `weight`, `durationSec`, and `skipped`. If `skipped` is absent (pre-SCR-16 data), treat as non-skipped.
- **ExerciseProgressData** (computed, not persisted): Derived from all sessions for a single exercise name. Contains: `exerciseName`, `type`, `sessionDataPoints` (ordered list of per-session metric values for the chart), `latestTopWeight`, `latestBestReps`, `latestVolume`, `deltaWeight`, `deltaReps`, `deltaVolume`.
- **ProgressChip** (display model): `exerciseName` (String), `isSelected` (bool). Represents one chip in the chip row.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Loading skeleton appears within one frame of tab activation — no blank frame is ever visible between tab tap and skeleton display (QA HP-01, PR-01).
- **SC-002**: Chart, stat tiles, and delta indicators are shown for any exercise present in ≥ 2 completed sessions, with values matching the raw logged data (QA HP-03–HP-07, DI-01).
- **SC-003**: Tapping a chip updates displayed data within one frame — no re-read from storage, no loading flash (QA chip interaction scenarios).
- **SC-004**: Drift read failure produces the Error state with correct copy; Retry re-enters Loading and resolves to the correct outcome state (QA NV-01, NV-02, NV-03).
- **SC-005**: Screen lifecycle produces zero Drift writes (QA DI-02, SC-01).
- **SC-006**: 20+ exercise chips and 20+ sessions load and render without application hang or ANR (QA PR-02).

---

## Assumptions

- All completed `WorkoutSession` records in the `workout_sessions` table are used for progress calculation; incomplete (in-progress) sessions are excluded.
- A session "contains an exercise" if that exercise name appears in `sessionExercises` with at least one non-skipped `ActualSet`.
- The initial chip selection on load is always the first chip in Group 1 (exercises with ≥ 2 valid sessions, most-recently-logged first). If no Group 1 chips exist, the first Group 2 chip is pre-selected and the empty state is shown. This ordering rule is resolved (OQ-3).
- A delta of zero (no change) is shown as `+0`; the sign is always explicit for positive and zero changes.
- The `intl` package is NOT available (ADR-030 governed set). All date/time or number formatting uses pure Dart.
- The Progress screen is the 5th root tab under `StatefulShellRoute` in go_router. The Bloc is provided at the shell-branch level so it persists across tab switches without re-reading Drift on each return.
- Retry button touch target must meet 44pt minimum.
- The chart SVG is rendered inline as a Flutter `CustomPainter` or equivalent — no web view or SVG package is introduced (ADR-030). The logical canvas is 320 × 150 units scaled to the available card width via `LayoutBuilder`.
- Weights are stored and displayed in kg; unit localisation is out of scope for v1.
- SCR-24 (Personal Bests) is deferred; SCR-22 progress values are independent of any PB calculation.
- `ActualSet.skipped` (added by SCR-16): if absent in pre-SCR-16 data, treat the set as non-skipped.
