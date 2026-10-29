# Quickstart Validation Guide: SCR-23 Statistics Dashboard

**Purpose**: Prove the feature works end-to-end across all four UI states.  
**Prerequisite**: `flutter run` on a simulator/device with ForgeApp installed and Drift seeded.

---

## Prerequisites

1. App compiles with zero analyzer warnings: `flutter analyze`
2. All existing tests green: `flutter test`
3. Simulator/device booted with a fresh app or cleared Drift tables

---

## Scenario 1: Loading State (US1 — SC-001)

**Setup**: Tab not yet visited in this session.

**Steps**:
1. Launch app → navigate to Stats tab (6th tab)

**Expected**:
- Skeleton appears immediately: 2×2 grid of four 88px shimmer boxes, three 56px row shimmer boxes below
- Shimmer lerps between `AppColors.cardAlt` and `AppColors.shimmerDark` (no translate animation)
- Screen does NOT flicker between loading and populated if data loads under ~300 ms
- `StatsLoading` state logged by Bloc

---

## Scenario 2: Empty State (US1 — SC-002, FR-006, FR-007)

**Setup**: All Drift workout sessions are either incomplete (`completedAt == null`) or have every set skipped.

**Steps**:
1. Ensure Drift has 0 valid sessions (see note below)
2. Navigate to Stats tab

**Expected**:
- Four stat tiles visible but dimmed (reduced opacity per design spec)
- Each tile shows placeholder dashes, not real values
- "No stats yet" heading displayed
- "Complete a workout to start building your statistics." body text displayed
- "Start a Workout" CTA button visible → tapping navigates to `/plans` tab
- No exercise breakdown section visible
- Records section (Personal Bests link) is still shown

**Note**: To seed empty state, run a workout session but skip every set, or clear the `workout_sessions` table.

---

## Scenario 3: Main State — Single Valid Session (US1 — SC-001, SC-003, SC-005)

**Setup**: Drift has exactly 1 valid session with:
- 2 weighted sets: 50kg×10, 60kg×8
- 1 time-based set: 45 seconds
- 1 bodyweight set: 15 reps
- `sessionDurationSec` = 3600 (1 hour)
- `completedAt` non-null

**Steps**:
1. Navigate to Stats tab

**Expected tiles**:
- Workouts Completed: `1`
- Total Volume: `980 kg` (50×10 + 60×8 = 500+480 = 980)
- Total Duration: `1h 0m`
- Avg. Duration: `1h 0m`

**Expected exercise breakdown** (FR-013–FR-016):
- 3 exercise rows (one per unique exercise name)
- Weighted exercise row: type dot = lime, best = `60 kg`
- TimeBased row: type dot = cyan, best = `45s`
- Bodyweight row: type dot = muted, best = `15`
- Rows sorted by sessionCount desc (all = 1 here → alpha order)

**Expected records section**:
- "RECORDS" section header
- Personal Bests link row with trophy icon (successFill wrap)
- "Personal Bests" title + "Your all-time top performances" subtitle
- Right chevron; tapping pushes to `/stats/personal-bests`

---

## Scenario 4: Valid-Session Filter (US1 — FR-003, SC-003)

**Setup**: Drift has 3 sessions:
- Session A: valid (1 non-skipped set)
- Session B: incomplete (`completedAt == null`)
- Session C: every set skipped

**Expected**:
- Workouts Completed = `1` (only Session A)
- Total Volume = Session A's weighted volume only
- Exercise breakdown contains only exercises from Session A

---

## Scenario 5: Avg. Duration ≥ 60 min formatting (US1 — FR-011)

**Setup**: 2 valid sessions with `sessionDurationSec` = 7200 (2h) and 3600 (1h).

**Expected**:
- Total Duration: `3h 0m`
- Avg. Duration: `1h 30m`

---

## Scenario 6: Error State & Retry (US2 — SC-004, FR-017–FR-018)

**Setup**: Force an exception from `GetStatisticsUseCase` (e.g., mock the use case in a widget test to throw).

**Expected**:
- Error card displayed:
  - Title: "Couldn't load your stats"
  - Body: "Something went wrong calculating your statistics.\nYour workout history is unaffected."
  - "Retry" button
- Tapping Retry dispatches `StatsLoadRequested` and shows skeleton again
- Retry button disabled until Bloc returns a non-Loading state (debounce guard)

---

## Scenario 7: On-Entry Recalculation (US3 — SC-007, FR-019)

**Steps**:
1. Navigate to Stats tab → note Workouts Completed = N
2. Navigate away (e.g., to Workout tab) → complete a valid workout
3. Return to Stats tab

**Expected**:
- Stats tab re-dispatches `StatsLoadRequested` on screen entry (via `initState`)
- Skeleton shown briefly, then updated count = N + 1
- No manual refresh required

---

## Scenario 8: Personal Bests Navigation (US3 — SC-007, FR-020)

**Steps**:
1. Navigate to Stats tab (main state)
2. Tap "Personal Bests" row

**Expected**:
- Pushes to `/stats/personal-bests`
- Placeholder or stub screen shown (SCR-24 not yet implemented)
- Back navigation returns to Stats screen with state intact

---

## Widget Test Reference

For automated coverage of Scenarios 6 and the bloc state machine, the task list (`tasks.md`) includes unit tests for `StatsBloc` and `GetStatisticsUseCase`. Key test cases:

- `StatsBloc`: emits `[StatsLoading, StatsLoaded]` on `StatsLoadRequested` success
- `StatsBloc`: emits `[StatsLoading, StatsError]` on `StatsLoadRequested` exception
- `GetStatisticsUseCase`: excludes sessions where `completedAt == null`
- `GetStatisticsUseCase`: excludes sessions where all sets are skipped
- `GetStatisticsUseCase`: volumes include only weighted non-skipped sets
- `GetStatisticsUseCase`: exercises sorted by sessionCount desc, alpha tie-break
