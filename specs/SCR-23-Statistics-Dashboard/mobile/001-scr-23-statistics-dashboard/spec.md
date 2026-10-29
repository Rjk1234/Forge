# Feature Specification: SCR-23 — Statistics Dashboard

**Feature Branch**: `001-scr-23-statistics-dashboard`

**Created**: 2026-09-23

**Status**: Draft

**Design reference**: `specs/SCR-23-Statistics-Dashboard/design/spec.md`

**QA reference**: `specs/SCR-23-Statistics-Dashboard/QA/SCR-23-qa-spec.md`

---

## Clarifications

### Session 2026-09-23

- Q: Which screen does the "Start a Workout" CTA in the empty state navigate to? (OQ-1) → A: Navigates to the Plans tab (`/plans`) via `context.go('/plans')`. The workout-start flow (FLOW-07) is initiated from a plan; directing the user to Plans is the correct entry point available at POC scope. Confirm if a more direct route is desired.
- Q: Avg. Duration format when ≥60 min? (OQ-3) → A: `"{N}h {N}m"` — consistent with Total Duration format. No `"h"` prefix added; same pattern as `sessionDurationSec` formatting used in SCR-21.
- Q: Bodyweight exercise right-column in breakdown? (OQ-4) → A: `ex-right-value = "{N}"` (best reps as integer), `ex-right-label = "Best reps"`. Consistent with the type system; artboard shows only weighted and time examples.
- Q: Exercise breakdown ordering rule? (OQ-5) → A: Session count descending. Tie-break: alphabetical by exercise name. Ordering is stable for the screen lifetime.
- Q: "Exercise Breakdown" section hidden or shown when no exercises qualify? (OQ-7) → A: Section hidden entirely when the exercise list is empty (no orphaned section-label).
- Q: Is the "Records" section (pb-link) always shown in Main state? (OQ-12) → A: Yes — shown whenever valid history exists, regardless of whether the user has any personal bests. SCR-24 (Personal Bests) handles its own empty state.
- Q: AC-4 recalculation — reactive stream or on-entry? (OQ-13) → A: On screen entry only (not a live reactive subscription). The Bloc emits `StatsLoadRequested` when the screen is first entered and on each Retry. This matches POC scope and avoids Drift watch streams.
- Q: Total Volume definition — same as SCR-22? (OQ-14) → A: Yes — Volume = Σ (weight × reps) across all non-skipped completed sets of weighted exercises only, across all valid sessions. Bodyweight exercise sets contribute 0 to total volume (tonnage is 0 and is excluded). This is the same definition resolved in SCR-22 OQ-5.
- Q: Should the "valid session" filter (≥1 non-skipped set) apply to all aggregate stats or only to the exercise breakdown? → A: All four aggregate stats (Workouts Completed, Total Volume, Total Duration, Avg. Duration) use the same valid-session filter (≥1 non-skipped ActualSet). Workouts Completed may therefore be lower than the History tab total; this is intentional — accuracy over raw count, and a single uniform filter makes computation and tests unambiguous.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View Populated Statistics Dashboard (Priority: P1)

A user opens the Stats tab (6th root tab) and, after a brief loading skeleton, sees four aggregate stat tiles (Workouts Completed, Total Volume, Total Duration, Avg. Duration) followed by a per-exercise breakdown listing session counts and best performance values, and a "Personal Bests" navigation row at the bottom. Tapping the Personal Bests row pushes to SCR-24.

**Why this priority**: This is the screen's sole purpose. All four stat tiles, the exercise breakdown, and the Personal Bests link constitute the core populated state. Without these, the Stats tab delivers zero value. All other stories are degraded or error paths.

**Independent Test**: Can be fully tested by seeding ≥1 completed `WorkoutSession` records, navigating to the Stats tab, and verifying the skeleton resolves to: (a) four correct aggregate tiles, (b) an exercise breakdown section with correct exercise rows, and (c) a tappable Personal Bests link that pushes to SCR-24.

**Acceptance Scenarios**:

1. **Given** the user taps the Stats tab, **Then** a loading skeleton (4 stat-tile placeholders + 3 exercise-row placeholders) is shown immediately — no blank frame between tab activation and skeleton display.

2. **Given** the skeleton is visible, **When** all session history has been read and statistics calculated, **Then** the skeleton transitions to the populated Main state.

3. **Given** the Main state, **Then** four stat tiles are displayed in a 2×2 grid: "Workouts Completed" (integer count), "Total Volume" (`{N} kg` with comma thousands-separator), "Total Duration" (`{N}h {N}m`), and "Avg. Duration" (`{N} min` if <60 min; `{N}h {N}m` if ≥60 min).

4. **Given** the Main state, **Then** each stat tile shows a lime-coloured icon in a `card-alt` icon-wrap, the value in `19px/weight-800` text, and a label in `11px/muted` text.

5. **Given** the Main state and ≥1 exercises in session history, **Then** an "Exercise Breakdown" section label appears followed by one exercise card per unique exercise found across all valid sessions, ordered by session count descending (alphabetical tie-break).

6. **Given** an exercise card, **Then** it shows: a type dot (lime for weighted, cyan for time-based, muted for bodyweight), the exercise name in `13px/weight-700`, a meta line "{N} sessions" in `11px/muted`, and a right-aligned best-performance value with a type-specific label below it.

7. **Given** a weighted exercise card, **Then** the right column shows best weight as `"{N} kg"` with label `"Best weight"`.

8. **Given** a time-based exercise card, **Then** the right column shows best duration as `"MM:SS"` (with leading zeros) with label `"Best time"`.

9. **Given** a bodyweight exercise card, **Then** the right column shows best reps as `"{N}"` with label `"Best reps"`.

10. **Given** the Main state, **Then** a "Records" section label appears followed by a full-width "Personal Bests" link row containing a trophy icon, title "Personal Bests", subtitle "Your all-time top performances", and a chevron-right indicator.

11. **Given** the user taps the Personal Bests row, **Then** the app pushes to SCR-24 (Personal Bests); tapping the back arrow on SCR-24 returns to the Stats screen.

12. **Given** the Main state, **Then** the content area is scrollable (`overflow-y:auto`) — the appbar and bottom navbar remain fixed while the stat grid and exercise cards scroll.

13. **Given** the Main state, **Then** stat tiles are read-only (no tap action, no disclosure indicator). Exercise cards are read-only (no drill-down).

14. **Given** the Main state, **Then** the bottom navbar is visible with the Stats tab (6th) highlighted in lime. No back arrow is shown in the appbar.

---

### User Story 2 — Handle Empty State (No Completed Workouts) (Priority: P2)

When no valid completed workouts exist, the screen shows four dimmed stat tiles with zeroed/placeholder values and a prompt beneath them inviting the user to start their first workout. The Personal Bests link and exercise breakdown are not shown.

**Why this priority**: A first-time user with no session history is a guaranteed early-use state. Without a defined empty state, the screen would appear broken. The dimmed tile grid communicates that stats will appear here; the CTA drives engagement.

**Independent Test**: Can be fully tested with an empty `workout_sessions` table: navigate to Stats tab and verify the skeleton resolves to the dimmed 2×2 tile grid with zeroed values followed by the prompt wrap, with no exercise breakdown and no Personal Bests row visible.

**Acceptance Scenarios**:

1. **Given** no valid completed workouts exist, **Then** the screen shows the Empty state after the loading skeleton.

2. **Given** the Empty state, **Then** four stat tiles are shown in a 2×2 grid at `opacity:.55` with dim icons; values are "0" (Workouts Completed), "0 kg" (Total Volume), "0h 0m" (Total Duration), and "—" (Avg. Duration; em dash U+2014 because average of zero sessions is undefined).

3. **Given** the Empty state, **Then** below the stat grid a prompt wrap is shown with: a 44×44 dim bar-chart icon, title "No stats yet" (`16px/weight-800`), subtitle "Complete a workout to start building your statistics." (`13px/muted`), and a "Start a Workout" CTA button (`lime bg; #131315 text; weight-800/13px; border-radius:10px; padding:12px 22px`).

4. **Given** the user taps "Start a Workout", **Then** the app navigates to the Plans tab (`/plans`).

5. **Given** the Empty state, **Then** the "Exercise Breakdown" section and the "Records"/"Personal Bests" row are NOT visible.

6. **Given** the Empty state, **Then** the bottom navbar is visible with the Stats tab (6th) highlighted. No back arrow shown.

---

### User Story 3 — Error State with Retry (Priority: P3)

When the Drift read or statistics calculation fails, the user sees an error card explaining that stats could not be loaded and reassuring them their workout history is unaffected. A Retry button re-triggers the data read.

**Why this priority**: Error state is a constitutional requirement for every screen (ADR-027). Without it, a Drift failure leaves the Stats tab in an indeterminate state. It is independently testable by injecting a read failure.

**Independent Test**: Can be fully tested by providing a mock `WorkoutSessionRepository` that throws on `getAllSessions()`, navigating to the Stats tab, observing the error card, tapping Retry, and verifying the skeleton reappears.

**Acceptance Scenarios**:

1. **Given** the Drift read or statistics calculation fails, **Then** an error card is shown with title "Couldn't load your stats" and body "Something went wrong calculating your statistics.\nYour workout history is unaffected.", and a "Retry" button. No stat tiles, no exercise breakdown, no Personal Bests row.

2. **Given** the error state, **When** the user taps Retry, **Then** the loading skeleton reappears and a fresh read + calculation is triggered.

3. **Given** a Retry in progress, **When** the read succeeds, **Then** the Main state (if valid history) or Empty state (if no history) is shown.

4. **Given** a Retry in progress, **When** the read fails again, **Then** the error state reappears; no crash or frozen state.

5. **Given** the error state, **When** the user double-taps Retry, **Then** only one Retry cycle is triggered (debounce guard prevents concurrent reads).

6. **Given** the error state, **Then** the bottom navbar is present and interactive; the user may switch to another tab without retrying.

---

### Edge Cases

- What happens when only bodyweight sessions exist? → Total Volume = 0 kg (bodyweight sets contribute 0 to weighted tonnage). Workouts Completed and Duration stats calculate normally.
- What happens when all sessions have no `sessionDurationSec` (e.g., 0)? → Total Duration = "0h 0m"; Avg. Duration = "0 min". No division-by-zero.
- What happens when an exercise appears in all sessions but all its sets are skipped? → That exercise is excluded from the breakdown (no valid sessions with ≥1 non-skipped set for that exercise).
- What happens when there are 50+ completed workouts? → Stats calculated correctly; no ANR (QA PR-01). The `overflow-y:auto` content area scrolls if the exercise breakdown is long.
- What happens when a session is partially completed (in-progress)? → Excluded from stats calculation. Only sessions with a `completedAt` timestamp are used.
- What happens when an exercise name is very long? → The `ex-name` text truncates at one line with ellipsis.
- What happens when Total Volume is very large (e.g., `1,234,567 kg`)? → Value wraps to two lines within the stat tile. No K/M suffix abbreviation.
- What happens when the Stats tab is revisited after backgrounding? → The existing loaded state is preserved in the Bloc (root tab — Bloc is not disposed on tab switch). No re-read on return.
- What happens when a session record has missing or corrupt fields? → That session is silently excluded; valid sessions are used. If the entire read fails, the Error state appears.
- What happens when `ActualSet.skipped` is absent (pre-SCR-16 data)? → Treat as non-skipped (same guard as SCR-21/22).
- What happens when a user completes a workout but skips every set? → That session has `completedAt` but fails the valid-session filter (no non-skipped ActualSets). It is excluded from all four aggregate stats and does not contribute to any exercise breakdown row. The History tab may show a higher total session count than Workouts Completed — this difference is intentional (FR-003).

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: On Stats tab entry, a loading skeleton (4 stat-tile placeholders at `height:88px` + 3 exercise-row placeholders at `height:56px`) MUST appear immediately with a translate-based shimmer animation — no blank frame between tab activation and skeleton display.
- **FR-002**: The screen MUST read all `WorkoutSession` records from the `workout_sessions` table exactly once per entry (or Retry); no Drift reads are triggered by any interaction after data is loaded.
- **FR-003**: All statistics — aggregate tiles (Workouts Completed, Total Volume, Total Duration, Avg. Duration) and the exercise breakdown — MUST be computed from **valid completed sessions only**. A session is valid if it has a non-null `completedAt` timestamp AND contains ≥1 `SessionExercise` with ≥1 non-skipped `ActualSet`. Sessions where every set was skipped are excluded from all stats. If `ActualSet.skipped` is absent (pre-SCR-16 data), treat the set as non-skipped. Note: the Workouts Completed count may therefore be lower than the History tab total, which lists all `completedAt` sessions — this is intentional.
- **FR-004**: The screen MUST show four aggregate stat tiles in a 2×2 grid:
  - **Workouts Completed**: integer count of valid completed sessions; no unit suffix.
  - **Total Volume**: Σ (weight × reps) across all non-skipped completed sets of weighted exercises, rounded to the nearest whole integer, displayed as `"{N} kg"` with comma thousands-separator.
  - **Total Duration**: Σ of `sessionDurationSec` across all valid sessions, formatted as `"{N}h {N}m"` (no leading zeros on hours; minutes always 2 digits when hours > 0; e.g., `"0h 5m"` or `"17h 24m"`).
  - **Avg. Duration**: Total Duration ÷ Workouts Completed, formatted as `"{N} min"` when <60 min, or `"{N}h {N}m"` when ≥60 min. Shown as `"—"` (em dash) when Workouts Completed = 0.
- **FR-005**: In the Main state (valid history exists), each stat tile MUST render with a lime-coloured icon in a `card-alt` icon-wrap (`width:28px; height:28px; border-radius:8px`), a `19px/weight-800` value (white text), and an `11px/muted` label. No `opacity` modifier.
- **FR-006**: In the Empty state (no valid history), the stat tile grid MUST still be shown at `opacity:.55` with dim icons and zeroed/placeholder values (`0`, `0 kg`, `0h 0m`, `—`).
- **FR-007**: In the Empty state, a prompt wrap MUST appear below the stat grid containing: a `44×44 dim` bar-chart icon (`Semantics(excludeSemantics: true)`), title "No stats yet" (`16px/weight-800`), subtitle "Complete a workout to start building your statistics." (`13px/muted; line-height:1.5; max-width:250px`), and a "Start a Workout" ElevatedButton (`lime bg; #131315 text; weight-800/13px; border-radius:10px; padding:12px 22px`).
- **FR-008**: Tapping "Start a Workout" MUST navigate to the Plans tab (`context.go('/plans')`). This is a root-tab switch; no push occurs.
- **FR-009**: In the Main state, the "Exercise Breakdown" section MUST appear below the stat grid (preceded by a section-label `"Exercise Breakdown"` in `12px/weight-800/uppercase/.06em letter-spacing/dim`) with one exercise card per unique exercise found across all valid sessions. If the exercise list is empty after filtering, the entire "Exercise Breakdown" section (including section-label) MUST be hidden.
- **FR-010**: Each exercise card MUST display: a type dot (`width:8px; height:8px; border-radius:50%`; lime for `weighted`, cyan for `timeBased`, muted for `bodyweight`), exercise name (`13px/weight-700`, one-line ellipsis truncation), meta line (`"{N} sessions"` where N is count of valid sessions for that exercise; `11px/muted`), and a right-aligned best-performance value with a type-specific label below it (`13px/weight-800` value; `10px/dim` label; `text-align:right`).
- **FR-011**: Best-performance right-column values MUST be computed as:
  - **weighted**: best weight (max weight across all non-skipped completed sets of the exercise, across all valid sessions), displayed as `"{N} kg"`. Label: `"Best weight"`.
  - **timeBased**: best duration (max `durationSec` across all non-skipped completed sets of the exercise, across all valid sessions), displayed as `"MM:SS"` with leading zeros (e.g., `"01:10"`). Label: `"Best time"`.
  - **bodyweight**: best reps (max `repetitions` across all non-skipped completed sets of the exercise, across all valid sessions), displayed as `"{N}"`. Label: `"Best reps"`.
- **FR-012**: Exercise cards MUST be ordered by session count descending. Alphabetical by exercise name is the tie-break. This ordering is computed once on load and is stable for the screen's lifetime.
- **FR-013**: In the Main state, a "Records" section MUST appear below the exercise breakdown (preceded by a section-label `"Records"` in `12px/weight-800/uppercase/.06em/dim`), containing a full-width "Personal Bests" link row. The row MUST show: a `32×32` trophy-icon-wrap (`border-radius:8px; background:#1e2a12`), trophy SVG icon (`16×16; color:lime`), title `"Personal Bests"` (`13px/weight-700`), subtitle `"Your all-time top performances"` (`11px/muted`), and a chevron-right icon (`16×16; color:dim; M9 18l6-6-6-6`). The chevron is decorative (`Semantics(excludeSemantics: true)`).
- **FR-014**: Tapping the Personal Bests row MUST push to SCR-24 (`context.push('/stats/personal-bests')` or the equivalent registered route). The entire row is the tap target. Back navigation from SCR-24 returns to the Stats screen.
- **FR-015**: In the Error state, an error card MUST be shown (centred in the content area) with: alert-triangle icon (`40×40; color:AppColors.danger`), title `"Couldn't load your stats"` (`16px/weight-800`), body `"Something went wrong calculating your statistics.\nYour workout history is unaffected."` (`13px/muted; line-height:1.5; text-align:center`), and a `"Retry"` ElevatedButton (`lime bg; #131315; weight-800/13px; border-radius:10px; padding:11px 22px`). Error card border: `AppColors.dangerBorder`; background: `AppColors.dangerBg`.
- **FR-016**: Tapping Retry MUST re-trigger the full data read, showing the loading skeleton again. Retry MUST be debounced — a second tap while a read is in progress is ignored.
- **FR-017**: No Drift writes of any kind MUST occur during the lifecycle of this screen. The screen is purely read-only.
- **FR-018**: Statistics are recalculated on each screen entry (initial and post-Retry). AC-4 (workout edited/deleted) is handled by the fact that the user must navigate away and return to see updated stats — no reactive live subscription is required at POC scope.
- **FR-019**: The screen is a root tab — no back navigation arrow. The bottom navbar (`6 tabs; Stats = 6th`) MUST remain visible and interactive in all four states (Loading, Empty, Main, Error). In the Loading state, inactive navbar items render at `opacity:.5`; in all other states, no opacity modifier.
- **FR-020**: The Bloc MUST define an `Initial` state that renders the skeleton identically to the Loading state. No blank screen is ever acceptable.

### Key Entities *(feature involves data)*

- **WorkoutSession**: Immutable snapshot written at session completion. SCR-23 reads all sessions from the `workout_sessions` table. Provides `completedAt`, `sessionDurationSec`, and `sessionExercises`.
- **SessionExercise**: Nested in `WorkoutSession`. Provides `exerciseName`, `type` (`ExerciseType.weighted` / `.timeBased` / `.bodyweight`), and `actualSets`.
- **ActualSet**: Nested in `SessionExercise`. Provides `repetitions`, `weight`, `durationSec`, and `skipped`. Absent `skipped` → treated as non-skipped.
- **StatsData** (computed, not persisted): Aggregate figures across all valid sessions — `totalWorkoutsCompleted`, `totalVolumeKg`, `totalDurationSec`, `avgDurationSec` (nullable — null when 0 sessions).
- **ExerciseStatRow** (computed, not persisted): Per-exercise summary — `exerciseName`, `type`, `sessionCount`, `bestValue` (type-specific: weight in kg / duration in seconds / reps as integer).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Loading skeleton appears within one frame of Stats tab activation — no blank frame is ever visible (QA HP-01, PR-02).
- **SC-002**: Populated state shows correct values for all four aggregate stats, matching manual calculation from raw session records (QA HP-03–HP-05, DI-01–DI-03).
- **SC-003**: Exercise breakdown shows correct best-performance values per exercise type, matching manual spot-check against session records (QA HP-06, DI-02).
- **SC-004**: Drift read failure produces the Error state with correct copy; Retry re-enters Loading and resolves to the correct outcome state (QA NV-01, NV-02, NV-03).
- **SC-005**: Screen lifecycle produces zero Drift writes (QA DI-04, SC-01).
- **SC-006**: 50+ completed workout sessions compute all statistics without ANR on API 29 (QA PR-01).
- **SC-007**: Stats reflect changes from workout edits or deletions after the user navigates away and returns to the Stats tab (QA EC-01–EC-03, SN-02).

---

## Assumptions

- All completed `WorkoutSession` records in the `workout_sessions` table are candidates for statistics calculation; in-progress sessions (no `completedAt` timestamp) are excluded. Within completed sessions, the valid-session filter (≥1 non-skipped ActualSet) is applied uniformly to all four aggregate stats and the exercise breakdown. A completed session where every set was skipped does not count toward any stat — this means Workouts Completed may be lower than the History tab's session list total, which is intentional.
- `SessionExercise.type` carries the exercise type (`ExerciseType.weighted`, `.timeBased`, `.bodyweight`). No second Drift table read is required to determine exercise type for the breakdown.
- Recalculation is on-entry only (not a live reactive Drift stream). If a workout is edited or deleted while the Stats tab is not visible, the user will see updated stats on their next visit to the tab (OQ-13 resolved).
- "Start a Workout" CTA navigates to the Plans tab (`/plans`) — the entry point to FLOW-07 workout execution at current POC scope (OQ-1 resolved).
- The Stats screen is the 6th root tab under `StatefulShellRoute` in go_router. The Bloc is provided at the shell-branch level so it persists across tab switches without re-loading Drift on each return.
- SCR-24 (Personal Bests) is a child route of the Stats branch (e.g., `/stats/personal-bests`). The "Personal Bests" row push navigates to SCR-24 without leaving the Stats branch's navigator.
- `#1e2a12` (successFill) is an existing design token established in SCR-21. No new color tokens are introduced by SCR-23.
- `font-size:19px` for stat values (`stat-value`) is a new size in the design system. It is used only for the stat tiles in SCR-23. Pending design token naming confirmation (`text.statValue`).
- The `intl` package is NOT available (ADR-030 governed set). All number and duration formatting uses pure Dart.
- Weights are stored and displayed in kg; unit localisation is out of scope for v1.
- Retry button touch target must meet 44pt minimum.
- `ActualSet.skipped` (added by SCR-16): if absent in pre-SCR-16 data, treat the set as non-skipped.
- Stats for deleted plans' workouts are included in totals (historical integrity — once logged, a session's contribution persists regardless of whether the originating plan is later deleted). Aligns with the data independence principle of the `workout_sessions` table.
