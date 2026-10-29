# QA Specification — SCR-23: Statistics Dashboard

**Story ID:** US-SCR23  
**Feature:** Statistics Dashboard  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-23-Statistics-Dashboard.md` + constitution

---

## 1. Purpose & Scope

Verify the statistics dashboard: skeleton during load, empty state with zeroed stats and a prompt when no data exists, populated state showing total workouts/volume/duration/exercise-level stats, stat recalculation after a plan is edited or deleted, and load-failure error state with retry. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Data states:** (a) No completed workouts → empty/zeroed. (b) ≥1 completed workouts → populated. (c) Drift read error → load-failure state.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Skeleton during load | Open SCR-23 with simulated slow Drift read. | Skeleton visible until data loads (FR-1 / AC-1). |
| HP-02 | Empty state — no workouts | No completed workouts in Drift. | Empty state shown with zeroed stats and a prompt to start working out (FR-2 / AC-2). |
| HP-03 | Populated — total workouts count | ≥1 completed workouts. | Total workout count correct. |
| HP-04 | Populated — total volume | Completed workouts with weighted exercises. | Total volume (sum of sets × reps × weight across all history) shown. |
| HP-05 | Populated — total duration | Completed workouts with duration data. | Total cumulative duration shown. |
| HP-06 | Populated — exercise-level stats | Specific exercises done multiple times. | Exercise-level statistics (e.g., most performed exercise, totals per exercise) shown as specified. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Load failure — error state | Force Drift read error on SCR-23 open. | Error state shown with retry action (FR-4 / AC-4). |
| NV-02 | Retry after failure — success | Trigger NV-01; restore Drift; tap Retry. | Stats load correctly. |
| NV-03 | Retry after failure — still fails | Trigger NV-01; tap Retry with Drift still failing. | Error state re-shown; no crash. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Stats recalculate after plan edit | Edit a plan (change exercise targets); re-open SCR-23. | Stats reflect the actual logged history values, not the updated plan targets. *[QA-derived]* |
| EC-02 | Stats recalculate after plan deletion | Delete a plan; re-open SCR-23. | Stats exclude contributions from the deleted plan's workouts? — or include them (historical independence)? Flag as OQ-01. *[QA-derived]* |
| EC-03 | Workout history deletion | If a history record is removed (e.g., from SCR-11 delete), re-open SCR-23. | Stats decrease accordingly. *[QA-derived]* |
| EC-04 | Bodyweight-only workouts | Volume stat when only bodyweight exercises logged. | Volume shown as 0 or N/A; no division-by-zero crash. *[QA-derived]* |
| EC-05 | Single workout, single set | Minimum data state. | All stats calculate without error. *[QA-derived]* |
| EC-06 | Large history | 50+ completed workouts. | Stats calculated correctly; no ANR or overflow. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | SCR-23 is read-only | No edit controls visible. |
| SN-02 | Stats update on return | After completing a new workout, return to SCR-23. | Stats reflect the new workout (FR-3 — recalculate on edit/delete). |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Total workouts count matches history | Count on SCR-23 equals the number of records in SCR-20 history list. |
| DI-02 | Volume calculation accuracy | Spot-check: total volume for a single exercise matches manual calculation (sets × reps × weight per set, summed). |
| DI-03 | Duration accuracy | Cumulative duration matches sum of workout durations from SCR-21 detail records. |
| DI-04 | Read-only — no Drift writes | Viewing SCR-23 makes no Drift writes. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Stats compute without ANR | 50+ workout history: stats calculated on load without ANR on API 29. *[QA-derived threshold]* |
| PR-02 | Skeleton immediate | No blank frame between navigation and skeleton. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Stats values announced | Screen reader announces each stat (total workouts, volume, duration, exercise-level). |
| AC-02 | Empty state announced | Screen reader reads the empty/zeroed prompt. |
| AC-03 | Error state accessible | Error card and Retry button announced. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Read-only confirmed | DI-04 confirms no Drift write from viewing stats. |

---

## 11. Regression Flags

- Any change to stat recalculation logic must re-run EC-01–EC-03, DI-01–DI-03.
- Any change to empty-state criteria must re-run HP-02.
- Any change to exercise-level stat calculation must re-run HP-06, DI-02.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Stats and plan deletion** — EC-02 is ambiguous: do history-based stats include workouts for deleted plans (per historical integrity) or exclude them? Not specified. Confirm. |
| OQ-02 | **Exercise-level stat definition** — "exercise-level" stats are not fully enumerated in the story inventory. What specific per-exercise stats are shown? Confirm before implementation of those test cases. |
| OQ-03 | **Volume for bodyweight exercises** — EC-04 flags ambiguity: volume = 0 or N/A? Confirm display rule. |
