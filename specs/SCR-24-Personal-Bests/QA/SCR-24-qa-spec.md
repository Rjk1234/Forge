# QA Specification — SCR-24: Personal Bests

**Story ID:** US-SCR24  
**Feature:** Personal Bests  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-24-Personal-Bests.md` + constitution

---

## 1. Purpose & Scope

Verify the Personal Bests screen: skeleton during load, empty state when no records exist, populated state displaying personal bests per exercise (metric TBD — DEFERRED per Decisions Log §3), and calculation-failure state with retry. The Personal Best metric definition is unresolved; tests are scoped to structural and state behaviours, not specific metric values. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Data states:** (a) No completed workouts → empty state. (b) ≥1 completed workouts → populated (metric TBD). (c) Calculation failure → failure state.
- **Note:** Personal Best metric definition is DEFERRED (Decisions Log §3). Do not assert specific metric logic until resolved.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Skeleton during load | Open SCR-24 with simulated slow Drift read. | Skeleton visible until data loads (FR-1 / AC-1). |
| HP-02 | Empty state — no workouts | No completed workouts in Drift. | Empty state shown; no personal best entries rendered (FR-2 / AC-2). |
| HP-03 | Populated — per-exercise entries shown | ≥1 completed workout with exercises. | At least one personal best entry visible per exercise (FR-3 / AC-3). |
| HP-04 | Multiple exercises listed | Workouts include multiple exercises. | Each exercise has its own personal best entry. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Calculation failure — failure state | Force calculation/Drift read failure. | Failure state shown with retry action (FR-4 / AC-4). |
| NV-02 | Retry after failure — success | Trigger NV-01; restore Drift; tap Retry. | Personal bests load/calculate correctly. |
| NV-03 | Retry after failure — still fails | Trigger NV-01; tap Retry with Drift still failing. | Failure state re-shown; no crash. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Single workout — PB established on first occurrence | Logged one session. | That session's values shown as the personal best (trivially). *[QA-derived]* |
| EC-02 | Multiple sessions for same exercise | Personal best should reflect the best across all sessions. | Best value displayed (specific metric DEFERRED — test structural presence only). *[QA-derived — metric DEFERRED]* |
| EC-03 | Bodyweight exercise PB | Bodyweight exercise has no weight; PB metric differs. | Entry displayed without crashing; metric TBD. *[QA-derived — DEFERRED]* |
| EC-04 | Time-based exercise PB | Duration-based metric for PB. | Entry displayed; metric TBD. *[QA-derived — DEFERRED]* |
| EC-05 | Plan deleted after setting PB | The plan whose exercise set a PB is deleted. | PB entry still shown (historical independence). *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | SCR-24 is read-only | No edit or delete controls. |
| SN-02 | PBs update after new workout | Complete a new workout that beats a PB; re-open SCR-24. | Updated PB shown. *[QA-derived — verify after metric defined]* |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | PB calculation is read-only | Viewing SCR-24 does not write to Drift. |
| DI-02 | PBs based on history records | PB values derivable from data in SCR-21 history detail. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | PB calculation without ANR | Large history (20+ workouts, multiple exercises): PB calculated without ANR on API 29. *[QA-derived]* |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | PB entries announced | Screen reader announces exercise name and PB value (format TBD pending metric resolution). |
| AC-02 | Empty state announced | Screen reader reads the empty state message. |
| AC-03 | Failure state accessible | Failure card and Retry button announced. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Read-only confirmed | DI-01 confirms no Drift write from viewing. |

---

## 11. Regression Flags

- Any resolution of the Personal Best metric (Decisions Log §3) must trigger a full re-specification of EC-02–EC-04 and HP-03–HP-04.
- Any change to PB calculation logic must re-run HP-03, EC-01–EC-02.
- Any change to failure-state handling must re-run NV-01–NV-03.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Personal Best metric — DEFERRED** (Decisions Log §3). All metric-specific tests (EC-02, EC-03, EC-04, SN-02) are blocked until the product owner defines the PB metric for each exercise type. |
| OQ-02 | **Bodyweight PB metric** — EC-03 is entirely gated on OQ-01 resolution. |
| OQ-03 | **Historical independence** — EC-05 assumes PBs survive plan deletion. Confirm whether the calculation layer reads raw history or a derived cache. |
