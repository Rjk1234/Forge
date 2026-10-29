# QA Specification — SCR-21: Workout History Detail

**Story ID:** US-SCR21  
**Feature:** Workout History Detail  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-21-Workout-History-Detail.md` + constitution

---

## 1. Purpose & Scope

Verify the history detail view: skeleton during load, full detail rendering (date/time + per-exercise sets/reps/weight/duration), historical data integrity independent of subsequent plan changes or deletions, and load-failure error state with retry. The record is read-only; no editing occurs here. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Entry:** From SCR-20, tap a history record.
- **Data states:** (a) Valid record → full detail. (b) Drift read error → load-failure state.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Skeleton during load | Open SCR-21 with simulated slow Drift read. | Skeleton visible until detail loads (FR-1 / AC-1). |
| HP-02 | Full detail rendered | Open a completed workout record. | Date, time, and per-exercise breakdown shown: exercise name, sets logged, reps, weight, duration — as applicable per exercise type (FR-2 / AC-2). |
| HP-03 | Weighted exercise detail | Record contains a weighted exercise. | Sets/reps/weight per set shown. |
| HP-04 | Time-based exercise detail | Record contains a time-based exercise. | Sets/duration per set shown. |
| HP-05 | Bodyweight exercise detail | Record contains a bodyweight exercise. | Sets/reps per set shown; no weight column. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Load failure — error state | Force Drift read error when opening SCR-21. | Error state shown with retry action (FR-4 / AC-4). |
| NV-02 | Retry after failure — success | Trigger NV-01; restore Drift; tap Retry. | Record loads correctly. |
| NV-03 | Retry after failure — still fails | Trigger NV-01; tap Retry with Drift still failing. | Error state re-shown; no crash. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Plan edited after workout | Edit the plan (change reps target); view the history record from before the edit. | Historical data shows the original logged values — not the updated plan values (FR-3). *[QA-derived]* |
| EC-02 | Plan deleted after workout | Delete the plan; view the history record for that workout. | History record still accessible; full detail displayed (FR-3 + Decisions Log §2). *[QA-derived]* |
| EC-03 | Exercise deleted from plan | An exercise was removed from the plan post-workout. | Historical detail still shows that exercise with its logged data. *[QA-derived]* |
| EC-04 | Single-set workout detail | Workout had exactly one set logged. | Detail renders without error for minimal data. *[QA-derived]* |
| EC-05 | Many sets per exercise | Exercise has 10+ sets logged. | All sets listed; scrollable; no truncation. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Back from SCR-21 → SCR-20 | Back returns to SCR-20 history list. |
| SN-02 | SCR-21 is read-only | No edit or delete controls visible on the detail view. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Historical independence from plan edits | Per EC-01: logged values are stored at write-time; plan mutations after Finish do not retroactively change history. |
| DI-02 | Historical independence from plan deletion | Per EC-02: deleting a plan does not cascade-delete history records. |
| DI-03 | Read-only view does not mutate Drift | Opening, scrolling, and closing SCR-21 makes no Drift writes. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Skeleton immediate | No blank frame between navigation and skeleton. |
| PR-02 | Large record load | Record with 20+ exercises and many sets loads without ANR. *[QA-derived threshold]* |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Date and time announced | Screen reader announces the workout date and time. |
| AC-02 | Per-exercise data announced | Each exercise name and its set details readable by screen reader. |
| AC-03 | Error state accessible | Error card and Retry button announced. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Read-only access confirmed | DI-03 confirms no Drift write from viewing. |

---

## 11. Regression Flags

- Any change to workout record schema must re-run HP-02–HP-05, DI-01.
- Any change to Drift read error handling must re-run NV-01–NV-03.
- Any change to plan-deletion cascading must re-run EC-02, DI-02.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Skipped sets in detail** — story does not specify how skipped sets are displayed in the history detail. Are they shown as "Skipped" or omitted entirely? Confirm. |
| OQ-02 | **Record unavailable state** — if a stored record ID is valid but the data is corrupt, what state is shown? Not specified — should there be a separate "corrupted record" case? |
