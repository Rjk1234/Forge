# Feature Specification: SCR-24 — Personal Bests

**Feature Branch**: `001-scr-24-personal-bests`

**Created**: 2026-09-23

**Status**: Draft

**Design reference**: `specs/SCR-24-Personal-Bests/design/spec.md`

**QA reference**: `specs/SCR-24-Personal-Bests/QA/SCR-24-qa-spec.md`

---

## Clarifications

### Session 2026-09-23

- Q: Which metric defines a "personal best" for each exercise type? (OQ-1) → A: Per-type best performance — consistent with SCR-23's `ExerciseStatRow`: weighted exercises use best weight (max kg across non-skipped sets), time-based exercises use best duration (max durationSec), bodyweight exercises use best reps (max repetitions). This is a per-type definition already computed in SCR-23; SCR-24 surfaces the same values with the date they were achieved.
- Q: What badge label appears per exercise type on the badge? (OQ-2) → A: Same labels as SCR-23 best-performance right column: weighted → "Best weight", timeBased → "Best time", bodyweight → "Best reps". Labels are displayed in the pb-badge below the metric value.
- Q: Sort order for the pb-card list? (OQ-14) → A: Alphabetical by exercise name ascending. Simple, stable, consistent with SCR-23's tie-break rule. No secondary sort needed.
- Q: pb-meta date format for "date the PB was set"? (OQ-3) → A: "Set {Mon} {D}, {YYYY}" in fixed English — e.g. "Set Aug 31, 2026". No intl package (ADR-030); formatted with pure Dart using a month-name constant array.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View Personal Bests List (Priority: P1)

A user arrives on the Personal Bests screen (pushed from SCR-23's Personal Bests link row) and, after a brief loading skeleton, sees a scrollable list of exercise cards. Each card shows the exercise's all-time best performance — its metric value in a right-side badge — and the date that best was achieved. The list is read-only and ordered alphabetically by exercise name.

**Why this priority**: This is the screen's entire purpose. Without the populated list, the screen delivers zero value. The loading skeleton and back navigation are prerequisites for any state. All other stories cover degraded states.

**Independent Test**: Seed ≥1 valid `WorkoutSession` with at least two different exercise types (weighted + bodyweight, or weighted + timeBased). Navigate from SCR-23's Personal Bests row to SCR-24. Verify: (a) skeleton flashes briefly (5 rows), (b) list resolves with correct per-type metric values, (c) date shown matches the session in which the best was recorded, (d) list is in alphabetical order, (e) pb-cards are not tappable (no navigation), (f) back arrow returns to SCR-23.

**Acceptance Scenarios**:

1. **Given** the user taps the Personal Bests row on SCR-23, **Then** SCR-24 pushes with a loading skeleton (5 pb-row placeholders) visible immediately — no blank frame on entry.

2. **Given** the skeleton is visible, **When** the PB calculation completes, **Then** the list resolves to one pb-card per unique exercise that has ≥1 non-skipped, completed set across all valid sessions.

3. **Given** the Main state, **Then** each pb-card shows: a type-dot (lime for weighted, cyan for timeBased, muted for bodyweight), the exercise name (one line; truncated with ellipsis if long), a "Set {Mon} {D}, {YYYY}" date line, and a right-side badge containing the metric value and type-specific label.

4. **Given** a weighted exercise pb-card, **Then** the badge shows the highest weight recorded across all non-skipped completed sets of that exercise, formatted as `"{N} kg"`, with badge label "Best weight".

5. **Given** a time-based exercise pb-card, **Then** the badge shows the longest duration recorded, formatted as `"MM:SS"` (e.g. `"01:10"`), with badge label "Best time".

6. **Given** a bodyweight exercise pb-card, **Then** the badge shows the highest rep count recorded, formatted as `"{N}"`, with badge label "Best reps".

7. **Given** the Main state, **Then** the pb-card list is sorted alphabetically ascending by exercise name.

8. **Given** the Main state and a long list of exercises, **Then** the list is scrollable; the appbar (title + back arrow) remains fixed while cards scroll below it.

9. **Given** a pb-card, **When** the user taps it, **Then** nothing happens — pb-cards are read-only (no drill-down, no disclosure chevron).

10. **Given** the user taps the back arrow, **Then** SCR-24 pops and the user returns to SCR-23 (Stats Dashboard) with its state preserved.

11. **Given** SCR-24 is shown in any state, **Then** no bottom navigation bar is visible — this is a pushed detail screen, not a root tab.

12. **Given** the Main state, **Then** the screen title "Personal Bests" is shown at 18px/weight-800 in the appbar with a back arrow.

---

### User Story 2 — Handle Empty State (No Personal Bests) (Priority: P2)

When the user has no valid completed workout sessions (or none with trackable sets), the screen shows a centred empty-state prompt with a trophy icon and explanatory copy. There is no CTA button — the screen is purely informational.

**Why this priority**: Any new user or user who has never completed a valid workout reaches this state. Without it, the screen would appear broken. The empty state communicates that personal bests will appear as workouts are completed.

**Independent Test**: Clear all Drift workout sessions (or seed sessions where every set is skipped). Navigate to SCR-24. Verify: skeleton resolves to the empty state with trophy icon, "No personal bests yet" heading, "Complete a workout to start setting personal bests." sub-copy. Confirm no list, no CTA button, back arrow present and functional.

**Acceptance Scenarios**:

1. **Given** no valid workout sessions exist (empty Drift table or all sets skipped), **Then** the Empty state is shown after the loading skeleton.

2. **Given** the Empty state, **Then** a centred layout shows: a 52×52 dim trophy icon (decorative, excluded from accessibility tree), heading "No personal bests yet", and subtitle "Complete a workout to start setting personal bests."

3. **Given** the Empty state, **Then** there is NO CTA button — the screen is read-only and informational only. (Contrast: SCR-23's empty state has a "Start a Workout" button.)

4. **Given** the Empty state, **Then** the appbar with "Personal Bests" title and back arrow is present; back arrow returns to SCR-23.

5. **Given** the Empty state, **Then** no bottom navigation bar is visible.

6. **Given** the Empty state, **Then** a screen reader announces the empty-state heading and subtitle without announcing the decorative icon.

---

### User Story 3 — Error State with Retry (Priority: P3)

When the Drift read or PB calculation fails, the user sees an error card with reassuring copy and a Retry button that re-triggers the data read.

**Why this priority**: Error handling is a constitutional requirement for every screen (ADR-027). Without it, a Drift failure leaves the screen in an indeterminate state. It is independently testable by injecting a read failure.

**Independent Test**: Inject a read failure into the use case, navigate to SCR-24, observe the error card, tap Retry, observe the skeleton, then observe either the Main or Empty state depending on Drift content.

**Acceptance Scenarios**:

1. **Given** the Drift read or PB calculation fails, **Then** an error card is shown centred on screen with: alert-triangle icon, title "Couldn't load your personal bests", body "Something went wrong calculating this data.\nYour workout history is unaffected.", and a "Retry" button.

2. **Given** the error state, **When** the user taps Retry, **Then** the loading skeleton reappears and a fresh read + calculation is triggered.

3. **Given** a Retry in progress, **When** the read succeeds, **Then** the Main state (if records exist) or Empty state (if no records) is shown.

4. **Given** a Retry in progress, **When** the read fails again, **Then** the error state reappears; no crash or frozen state.

5. **Given** the error state, **When** the user double-taps Retry, **Then** only one Retry cycle is triggered (debounce guard prevents concurrent reads).

6. **Given** the error state, **Then** the back arrow is present; the user may return to SCR-23 without retrying.

---

### Edge Cases

- What happens when only one exercise exists in history? → Main state with a single pb-card; no minimum card count required.
- What happens when an exercise appears across multiple sessions and the best value changes? → The badge shows the highest value found across ALL valid sessions; date shows the session that achieved that value. If tie on value, most recent date wins.
- What happens when a session's sets are all skipped? → That session is excluded from PB computation (same valid-session filter as SCR-23: `completedAt != null` AND ≥1 non-skipped `ActualSet`). However, PB computation considers ALL non-skipped sets individually, not at session level — see FR-004.
- What happens when the originating plan is deleted but the session was already recorded? → PB record remains (data independence of `workout_sessions` table; EC-05 from QA spec).
- What happens when a user sets a new PB after viewing? → The PB badge updates on next visit to SCR-24 (on-entry read; no reactive stream).
- What happens when exercise name is very long? → Truncated to one line with ellipsis.
- What happens when a time-based set has `durationSec = 0`? → Show `"00:00"` (OQ-8 default).
- What happens when `ActualSet.skipped` is absent (pre-SCR-16 data)? → Treat as non-skipped (same guard as SCR-21/22/23).
- What happens when the list has 20+ exercises? → List scrolls; appbar remains fixed; no pagination.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: On push entry to SCR-24, a loading skeleton MUST appear immediately — 5 skeleton rows, each with a dot placeholder, an animated shimmer line, and a static badge placeholder. No blank frame between push and skeleton display.
- **FR-002**: The screen MUST read all `WorkoutSession` records from the `workout_sessions` table exactly once per entry (or Retry); no Drift reads are triggered after data is loaded.
- **FR-003**: No Drift writes of any kind MUST occur during the lifecycle of this screen. The screen is purely read-only.
- **FR-004**: Personal bests MUST be computed per exercise name per exercise type as follows:
  - **Valid set rule**: A set qualifies if its parent session has a non-null `completedAt` AND `skipped != true` (absent `skipped` field → treat as non-skipped; consistent with SCR-21/22/23).
  - **weighted**: PB value = max `weight` (kg, double) across all qualifying sets of that exercise name. Date = `completedAt` of the session containing that set. Tie on value → most recent `completedAt`.
  - **timeBased**: PB value = max `durationSec` (int) across all qualifying sets. Date = same tie-break rule.
  - **bodyweight**: PB value = max `repetitions` (int) across all qualifying sets. Date = same tie-break rule.
  - An exercise with qualifying sets in at least one session produces one pb-card. Exercises where all sets are skipped produce no pb-card.
- **FR-005**: In the Main state, the pb-card list MUST be sorted alphabetically ascending by `exerciseName`.
- **FR-006**: Each pb-card MUST display:
  - A type-dot: `width:8px; height:8px; border-radius:50%`; lime for `weighted`, cyan for `timeBased`, muted for `bodyweight`.
  - Exercise name (`14px/weight-700`; 1 line; ellipsis overflow).
  - Date line: `"Set {Mon} {D}, {YYYY}"` (e.g. `"Set Aug 31, 2026"`); `11px/muted`.
  - A pb-badge (right-aligned): card-alt background, border, `border-radius:10px`, `padding:8px 12px`; contains: metric value (`14px/weight-800; white`) and badge label (`9px/dim; uppercase; letter-spacing:0.03em`).
- **FR-007**: Metric value display format per type:
  - **weighted**: `"{N} kg"` where N is `bestWeight` formatted as an integer if whole number (e.g. `"65 kg"`) or one decimal (e.g. `"62.5 kg"`).
  - **timeBased**: `"MM:SS"` with leading zeros (e.g. `"01:10"`, `"00:45"`).
  - **bodyweight**: `"{N}"` as integer (e.g. `"18"`).
- **FR-008**: Badge label per type: weighted → `"BEST WEIGHT"`; timeBased → `"BEST TIME"`; bodyweight → `"BEST REPS"` (uppercase per 9px/badge-label style).
- **FR-009**: pb-cards are read-only — no tap action, no disclosure chevron, no navigation from a card tap.
- **FR-010**: In the Empty state (no qualifying sets found across all sessions), a centred prompt MUST appear with: a 52×52 dim trophy icon (`Semantics(excludeSemantics: true)`), heading `"No personal bests yet"` (`16px/weight-800`), subtitle `"Complete a workout to start setting personal bests."` (`13px/muted`). No CTA button.
- **FR-011**: In the Error state, an error card MUST be shown centred in the content area with: alert-triangle icon (`40×40; AppColors.danger`), title `"Couldn't load your personal bests"` (`16px/weight-800`), body `"Something went wrong calculating this data.\nYour workout history is unaffected."` (`13px/muted; line-height:1.5; text-align:center`), and a `"Retry"` ElevatedButton. Error card uses `AppColors.dangerBg` background and `AppColors.dangerBorder` border.
- **FR-012**: Tapping Retry MUST re-trigger the full data read, showing the loading skeleton again. Retry MUST be debounced — a second tap while a read is in progress is ignored.
- **FR-013**: The screen appbar MUST show title `"Personal Bests"` (`18px/weight-800`) and a back arrow (`22×22; white; stroke-width:2; M15 18l-6-6 6-6`) in all four states. Tapping the back arrow (or using Android back gesture) pops the pushed route and returns to SCR-23.
- **FR-014**: No bottom navigation bar is shown in any state — SCR-24 is a pushed detail screen, not a root tab.
- **FR-015**: The Bloc MUST define an `Initial` state that renders the skeleton identically to the Loading state. No blank screen is ever acceptable.
- **FR-016**: PBs are recalculated on each screen push (initial entry) and on Retry. No reactive Drift watch stream is required.

### Key Entities *(feature involves data)*

- **WorkoutSession**: Read from `workout_sessions` table. Provides `completedAt: DateTime?`, `sessionExercises: List<SessionExercise>`.
- **SessionExercise**: Nested in `WorkoutSession`. Provides `exerciseName: String`, `type: ExerciseType`, `actualSets: List<ActualSet>`.
- **ActualSet**: Nested in `SessionExercise`. Provides `weight: double`, `repetitions: int`, `durationSec: int`, `skipped: bool?`.
- **PersonalBestRecord** (computed, not persisted): `exerciseName: String`, `type: ExerciseType`, `bestValue` (type-specific; see FR-004), `bestDate: DateTime` (session's `completedAt` when the PB was set).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Loading skeleton appears within one frame of SCR-24 push — no blank frame is ever visible (QA HP-01, AC-1).
- **SC-002**: pb-cards display correct per-type metric values matching manual calculation from raw session records for all three exercise types — weighted, timeBased, bodyweight (QA HP-03, EC-01–EC-04).
- **SC-003**: pb-card date matches the `completedAt` of the session in which the personal best was recorded (QA DI-02).
- **SC-004**: Drift read failure produces the Error state with the correct error copy; Retry re-enters Loading and resolves to the correct outcome state (QA NV-01–NV-03, AC-4–AC-5).
- **SC-005**: Screen lifecycle produces zero Drift writes (QA DI-01, SC-01).
- **SC-006**: 20+ completed workout sessions with multiple exercises compute all personal bests without ANR on API 29 (QA PR-01).
- **SC-007**: After the user completes a new workout that beats an existing PB, navigating back to SCR-24 shows the updated (higher) value (QA SN-02).

---

## Assumptions

- Personal bests are computed per exercise name and per exercise type. An exercise appearing in both `weighted` and `bodyweight` form (same name, different type) would produce two separate pb-cards — this is an edge case not designed for; assume exercise names are unique per type in practice.
- The per-type best-metric definition (FR-004) is consistent with the `ExerciseStatRow.bestWeight/bestReps/bestDurationSec` already computed in SCR-23. SCR-24 surfaces the same values plus the date dimension.
- `completedAt` on `WorkoutSession` is used as the "date the PB was set". Drift stores it as a `DateTime`; the PB date is the `completedAt` of the session whose set produced the best value.
- Date format is fixed English: `"Set {Mon} {D}, {YYYY}"` using a hard-coded 3-letter month name array (no `intl` package, ADR-030).
- The design spec's amber design-note banner in the artboard is a designer annotation and MUST NOT ship in the production UI.
- pb-cards are fully read-only — no drill-down, no deletion, no editing.
- No bottom navigation bar in any state (SCR-24 is a pushed screen, not a root tab).
- Empty state has no CTA button — intentional product decision per design spec §3B.
- PB computation is on-entry only (not a reactive Drift stream). Users see updated PBs by navigating away from and back to SCR-24.
- The `intl` package is not available (ADR-030). All date and number formatting uses pure Dart.
- Weights are stored and displayed in kg; unit localisation is out of scope for v1.
- Retry button must meet 44pt minimum touch target (OQ-10 note: padding alone may give ~40px — engineering must add `minimumSize` constraint).
- `font-size:14px` for pb-name (`text.cardTitle`) is a new design token; implementation uses literal `14.0` as a named constant until token naming is confirmed.
- `letter-spacing:0.03em` on pb-badge-label is a new design token (`tracking.badgeLabel`); implementation uses a named constant.
- Sort order is alphabetical by exercise name ascending (OQ-14 resolved). No secondary sort is defined.
- PBs based on sessions where the originating plan has since been deleted are still included (historical independence of `workout_sessions` table).
- `ActualSet.skipped` absent (pre-SCR-16 data) → treat as non-skipped.
