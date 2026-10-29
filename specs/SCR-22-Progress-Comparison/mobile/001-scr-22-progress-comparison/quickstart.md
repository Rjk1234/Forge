# Quickstart Validation Guide: SCR-22 Progress Comparison

**Date**: 2026-09-23 | **Branch**: `001-scr-22-progress-comparison`

---

## Prerequisites

- App running on simulator or device with the Progress tab visible in the bottom nav
- `WorkoutSessionRepository` seeded with the appropriate test data (see each scenario)
- The `ProgressBloc` is dispatching `ProgressLoadRequested` on tab entry

---

## Scenario 1 — Skeleton on entry, then Main state (US1, SC-001, SC-002)

**Setup**: Seed 2+ completed `WorkoutSession` records sharing at least one exercise (e.g., "Bench Press", `ExerciseType.weighted`, with 3 sets each).

**Steps**:
1. Tap the Progress tab (5th tab).

**Expected**:
- Skeleton appears immediately — 3 chip placeholders, 1 chart placeholder, 3 stat tile placeholders. No blank frame.
- Skeleton resolves to Main state.
- Chip row shows at least "Bench Press"; it is pre-selected.
- Chart shows 2 data points connected by a lime trend line; 3 horizontal grid lines visible.
- Latest dot is larger (r:5) than regular dots (r:4).
- "Latest Session" label appears below chart.
- 3 stat tiles: "TOP WEIGHT", "BEST REPS", "VOLUME" — each with a value and a delta indicator.
- Positive delta: lime color; negative delta: danger/red color.

---

## Scenario 2 — Chip selection updates chart and stats (US1 AS-9)

**Setup**: Seed 3+ sessions with "Bench Press" (weighted) and 2+ sessions with "Pull-up" (bodyweight).

**Steps**:
1. Open Progress tab → Main state on "Bench Press".
2. Scroll chip row; tap "Pull-up" chip.

**Expected**:
- "Pull-up" chip becomes active (lime background).
- Chart and stat tiles update immediately — no loading flash, no Drift read.
- Stat tiles show **TOTAL SETS / BEST REPS / TOTAL REPS** (bodyweight variant, not TOP WEIGHT/VOLUME).
- "Bench Press" chip returns to inactive appearance.

---

## Scenario 3 — Empty state per exercise (US2, FR-013)

**Setup**: Seed 2+ sessions with "Bench Press" (weighted), and 1 session with "Plank" (timeBased).

**Steps**:
1. Open Progress tab → "Bench Press" pre-selected (Main state).
2. Tap "Plank" chip.

**Expected**:
- Chart and stat tiles replaced by empty state: title "Not enough data yet", subtitle "Complete a few more workouts to see your progress."
- Chip row remains visible and interactive.
- Tapping "Bench Press" again returns to Main state with chart.

---

## Scenario 4 — All exercises in Group 2 (US2 AS-5)

**Setup**: Seed 1 session with 3 different exercises (each appears only once).

**Steps**:
1. Open Progress tab.

**Expected**:
- All 3 chips visible; first chip pre-selected.
- Empty state shown for first chip immediately (no Main state).
- Tapping any chip shows empty state.
- No crash or blank screen.

---

## Scenario 5 — timeBased exercise stat tiles (US1 AS-8, FR-017)

**Setup**: Seed 3+ sessions each containing "Plank" (`ExerciseType.timeBased`) with 3 sets of durationSec values.

**Steps**:
1. Open Progress tab; tap "Plank" chip.

**Expected**:
- Stat tiles: "BEST DURATION" (longest single set, formatted `m:ss`), "TOTAL TIME" (sum, formatted `m:ss`), "SETS" (count of completed sets).
- Chart trend line plots best duration per session (max durationSec).
- Delta indicators use danger color for negative change, lime for positive.

---

## Scenario 6 — Error state and retry (US3, SC-004)

**Setup**: Mock `WorkoutSessionRepository.getAllSessions()` to return `Left(CacheException)`.

**Steps**:
1. Open Progress tab.
2. Observe skeleton, then error state.
3. Tap "Retry".
4. Observe skeleton reappears.
5. Restore mock to return valid sessions.
6. Observe Main state.

**Expected**:
- Error card: title "Couldn't load your progress", body "Your workout history is unaffected.", "Retry" button.
- No chip row visible during error state.
- After Retry: skeleton → Main state.
- Raw exception message NOT shown to user.

---

## Scenario 7 — Double-tap Retry debounce (US3 AS-5)

**Setup**: Mock with slow `getAllSessions()` (simulated delay).

**Steps**:
1. Error state → Retry rapidly tapped twice.

**Expected**:
- Only one Drift read triggered; no duplicate state emissions or flickering.

---

## Scenario 8 — 12-session chart cap (SC-006, FR-007)

**Setup**: Seed 15 completed sessions with the same exercise (e.g., "Squat", weighted).

**Steps**:
1. Open Progress tab; select "Squat" chip.

**Expected**:
- Chart shows exactly 12 data points (most recent 12 sessions), not 15.
- Stat tiles show latest session values (from session 15, unaffected by the cap).
- Delta shows change between session 15 and session 14.
- No crash or layout overflow.

---

## Scenario 9 — Tab switch preserves state (US1, D-04 from research)

**Setup**: Main state with "Bench Press" selected.

**Steps**:
1. Tap another tab (e.g., Home).
2. Return to Progress tab.

**Expected**:
- Progress tab shows the same "Bench Press" chip selected with the same chart — no re-loading, no skeleton flash.
- Bloc is not re-created on tab return (provided at branch level).

---

## Unit Test Checklist (ProgressBloc)

- [ ] Initial state is `ProgressInitial`
- [ ] `ProgressLoadRequested` emits `[ProgressLoading, ...]` — Loading always first
- [ ] Use case returns `Right([...])` → emits `ProgressLoaded` with first exercise pre-selected
- [ ] Use case returns `Right([])` (no sessions) → emits `ProgressLoaded(exercises: [], selectedExerciseName: '')`
- [ ] Use case returns `Left(exception)` → emits `ProgressError`; raw exception NOT in message
- [ ] `ProgressExerciseSelected` when `ProgressLoaded` → emits new `ProgressLoaded` with updated name; no use-case call
- [ ] `ProgressExerciseSelected` when NOT `ProgressLoaded` → no emission (guard respected)
- [ ] Retry: second `ProgressLoadRequested` resets to Loading then resolves
- [ ] `LoggingService.logError` called on exception path

## Unit Test Checklist (GetExerciseProgressDataUseCase)

- [ ] Empty session list → `Right([])` (not an error)
- [ ] Sessions with no valid sets for any exercise → `Right([])` (all filtered out)
- [ ] Repository `Left(exception)` → `Left(exception)` (pass-through)
- [ ] Chip ordering: Group 1 (≥2 valid sessions) precedes Group 2 (<2 valid sessions)
- [ ] Within Group 1: most recently logged exercise first
- [ ] Within same session: alphabetical tie-break
- [ ] Chart cap: exercises with 15 sessions produce exactly 12 `sessionDataPoints`
- [ ] Stat tiles: weighted `latestMetrics` matches WeightedMetrics
- [ ] Stat tiles: timeBased `latestMetrics` matches TimedMetrics
- [ ] Stat tiles: bodyweight `latestMetrics` matches BodyweightMetrics
- [ ] Delta: correct signed change from previous session
- [ ] Skipped sets excluded from all metric calculations

## Widget Test Checklist (ProgressScreen)

- [ ] `ProgressInitial` → `ProgressSkeleton` visible; chip row NOT visible
- [ ] `ProgressLoading` → `ProgressSkeleton` visible; chip row NOT visible
- [ ] `ProgressLoaded` with selected exercise having ≥2 valid sessions → chip row visible, chart visible, 3 stat tiles visible
- [ ] `ProgressLoaded` with selected exercise having <2 valid sessions → chip row visible, `ProgressEmptyState` shown, no chart
- [ ] `ProgressError` → `ProgressErrorCard` shown; chip row NOT visible; Retry button present
- [ ] Tapping Retry → `ProgressLoadRequested` event fired
- [ ] Tapping chip → `ProgressExerciseSelected(name)` event fired with correct exercise name
- [ ] Active chip has lime background; inactive chips have card-alt background
- [ ] Positive delta tile: lime color; negative delta tile: danger color
- [ ] timeBased exercise: stat tiles show BEST DURATION / TOTAL TIME / SETS (not TOP WEIGHT / BEST REPS / VOLUME)
- [ ] bodyweight exercise: stat tiles show TOTAL SETS / BEST REPS / TOTAL REPS
