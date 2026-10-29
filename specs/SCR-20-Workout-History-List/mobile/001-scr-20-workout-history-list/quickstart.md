# Quickstart Validation Guide: SCR-20 Workout History List

**Date**: 2026-09-23 | **Branch**: `001-scr-20-workout-history-list`

---

## Prerequisites

- SCR-16 implemented (`WorkoutSession.startedAt`, `ActualSet.skipped` exist)
- SCR-19 implemented (can generate completed sessions via the Finish Workout flow)
- App running on simulator or device

---

## Scenario 1 — Populated list with two months (US1, SC-001)

**Setup**: Two completed sessions exist — one in September 2026, one in August 2026.

**Steps**:
1. Launch the app on a fresh state (or seed two sessions with the given months in Drift).
2. Tap the History tab.

**Expected**:
- Loading skeleton appears immediately (SC-003).
- Skeleton replaces with the populated list.
- Two month-group headers appear: "September 2026" above, "August 2026" below.
- Sessions within each group are newest-first.
- Each row shows: zero-padded day (e.g. "07"), 3-letter uppercase day-of-week (e.g. "MON"), plan name, summary line (`{N} min · {N} exercises · {N} sets`).
- No blank screen at any point.

---

## Scenario 2 — Empty state (US2, FR-006, SC-002)

**Setup**: No completed sessions in local storage.

**Steps**:
1. Fresh install, or clear `workout_sessions` table manually.
2. Tap the History tab.

**Expected**:
- Loading skeleton appears briefly.
- Empty state appears with title "No workout history yet" and body "Your completed workouts will appear here."
- No Retry button visible.
- No error state shown (SC-002 invariant).

---

## Scenario 3 — Error state and retry (US2, FR-007–FR-010, SC-002)

**Setup**: Inject a mock `WorkoutSessionRepository` that returns `Left(CacheException(...))`.

**Steps**:
1. Open the History tab.
2. Observe error state.
3. Tap "Retry".
4. Observe skeleton reappears.
5. Inject success result (one session).
6. Observe populated list.

**Expected**:
- Error state shows: title "Couldn't load your history", body "Something went wrong reading local data. Your plans and schedule are unaffected.", "Retry" button.
- Empty state is NOT shown.
- After Retry: skeleton appears (SC-003), then populated list.
- Raw exception message is not shown to the user.

---

## Scenario 4 — Re-fetch on tab switch (US3, FR-012)

**Setup**: One session in storage.

**Steps**:
1. Open History tab. Verify populated list.
2. Switch to Home tab.
3. Complete a new workout via SCR-19 (adds a second session to Drift).
4. Switch back to History tab.

**Expected**:
- Loading skeleton appears on re-entry.
- Populated list now shows 2 sessions — the newly completed session at the top.

---

## Scenario 5 — No re-fetch on back from SCR-21 (US1 AC5, FR-011)

**Setup**: At least two sessions in storage.

**Steps**:
1. Open History tab. Verify populated list with sessions A and B.
2. Tap session A row → navigates to SCR-21.
3. Press back → returns to History tab.

**Expected**:
- List appears immediately with sessions A and B.
- No loading skeleton appears on return.
- No re-fetch occurs (FR-011 satisfied by `StatefulShellRoute` tab navigator).

---

## Scenario 6 — Retry fails repeatedly (US2, FR-010)

**Setup**: Mock repository always returns `Left(CacheException(...))`.

**Steps**:
1. Open History tab. Error state appears.
2. Tap Retry. Loading skeleton. Error state appears again.
3. Tap Retry again.

**Expected**:
- Each Retry cycle: skeleton → error state.
- No retry limit — the Retry button is always present in the error state.
- No crash or frozen state.

---

## Scenario 7 — Session detail navigation (US1 AC4, SC-004)

**Setup**: Three sessions in storage.

**Steps**:
1. Open History tab. Populated list with 3 rows.
2. Tap the second session row.

**Expected**:
- Navigates to SCR-21 for exactly the session on row 2 (correct `sessionId` passed).
- No wrong session opened; no tap silently dropped.

---

## Scenario 8 — Session with long plan name (Edge Case)

**Setup**: One session with a plan name of ≥ 60 characters.

**Steps**:
1. Open History tab.

**Expected**:
- The plan name wraps to additional lines within the `HistoryCard`.
- Card height grows to accommodate the wrapped text.
- No text is truncated or clipped.
- The summary line still appears below the (wrapped) plan name.
- No layout overflow errors.

---

## Unit Test Checklist (WorkoutHistoryBloc)

- [ ] `WorkoutHistoryLoadRequested` → `WorkoutHistoryLoading` always emits first
- [ ] Right(sessions.isNotEmpty) → `WorkoutHistorySuccess` with correct `groups` count and order
- [ ] Right([]) → `WorkoutHistoryEmpty` (not error)
- [ ] Left(exception) → `WorkoutHistoryError` (not empty)
- [ ] Multiple `WorkoutHistoryLoadRequested` events → each resets to Loading then resolves
- [ ] Sessions spanning two calendar months → `groups.length == 2`, labels correct
- [ ] Sessions in same month → `groups.length == 1`, sessions newest-first within group

## Widget Test Checklist (WorkoutHistoryScreen)

- [ ] `WorkoutHistoryLoading` state → `HistorySkeleton` visible
- [ ] `WorkoutHistorySuccess` state → `HistoryCard` rows and `HistoryMonthLabel` headers visible
- [ ] `WorkoutHistoryEmpty` state → empty title and body text visible; no Retry button
- [ ] `WorkoutHistoryError` state → error title, body, and Retry button visible; no empty title
- [ ] Tapping Retry → `WorkoutHistoryLoadRequested` event fired
- [ ] Tapping a `HistoryCard` → `onTap` callback invoked (navigation to SCR-21)
