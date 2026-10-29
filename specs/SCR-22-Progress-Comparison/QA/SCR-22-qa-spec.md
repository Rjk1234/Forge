# QA Specification — SCR-22: Progress Comparison

**Story ID:** US-SCR22  
**Feature:** Progress Comparison  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-22-Progress-Comparison.md` + constitution

---

## 1. Purpose & Scope

Verify the progress comparison screen: skeleton during load, empty/placeholder state when fewer than 2 sessions exist, comparison view with weight/reps/volume/duration metrics when ≥2 sessions are available, silent exclusion of invalid or incomplete sessions from the comparison, and load-failure error state with retry. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Data states:** (a) 0 completed sessions → empty/placeholder. (b) Exactly 1 session → still empty/placeholder (< 2 required). (c) ≥2 sessions → comparison view. (d) Drift read error → load-failure state.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Skeleton during load | Open SCR-22 with simulated slow Drift read. | Skeleton/placeholder chart visible during load (FR-1 / AC-1). |
| HP-02 | Empty / placeholder state — <2 sessions | ≤1 completed session in Drift. | Empty/placeholder state shown; no comparison chart rendered (FR-2 / AC-2). |
| HP-03 | Comparison view with ≥2 sessions | ≥2 completed sessions for the same exercise. | Comparison chart rendered with weight, reps, volume, and/or duration as available (FR-3 / AC-3). |
| HP-04 | Weight metric shown | Sessions include weighted exercise data. | Weight values compared across sessions. |
| HP-05 | Reps metric shown | Sessions include reps data. | Reps values compared across sessions. |
| HP-06 | Volume metric shown | Sessions include sets × reps × weight data. | Volume (aggregated) compared across sessions. |
| HP-07 | Duration metric shown | Sessions include time-based exercise data. | Duration compared across sessions. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Load failure — error state | Force Drift read error on SCR-22 open. | Error state shown with retry action (FR-4 / AC-4). |
| NV-02 | Retry after failure — success | Trigger NV-01; restore Drift; tap Retry. | Data loads; appropriate state rendered. |
| NV-03 | Retry after failure — still fails | Trigger NV-01; tap Retry with Drift still failing. | Error state re-shown; no crash. |
| NV-04 | Exactly 1 session — empty state | Only one completed workout in Drift. | Empty/placeholder shown (not comparison view). |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Invalid session silently excluded | A session record is invalid (corrupt or missing required fields). | Invalid session excluded from comparison; no error; valid sessions shown. *[QA-derived]* |
| EC-02 | Incomplete session silently excluded | A session without a Finish (none should exist per invariant, but guard). | Excluded from comparison silently. *[QA-derived]* |
| EC-03 | Sessions for different exercises | Comparing an exercise that only appears in one session. | Exercise absent from the other session handled gracefully; no crash. *[QA-derived]* |
| EC-04 | All sessions invalid | All records have corrupt data. | Empty/placeholder state shown; no crash. *[QA-derived]* |
| EC-05 | Many sessions | 20+ completed sessions. | Comparison scrolls or paginates; no truncation error. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Navigation back from SCR-22 | Back returns to the Progress section entry point (bottom nav stays visible). |
| SN-02 | Comparison view is read-only | No edit/delete controls visible. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Comparison uses stored history values | Metric values in comparison match the raw logged values in SCR-21 history detail. |
| DI-02 | Read-only — no Drift writes | Opening or interacting with SCR-22 makes no Drift writes. |
| DI-03 | Silent exclusion does not remove records | Invalid/incomplete exclusion is display-only; underlying stored records are untouched. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Chart renders without ANR | Comparison chart renders smoothly on API 29. |
| PR-02 | 20+ sessions perform acceptably | Large session set loads and renders within acceptable time on API 29. *[QA-derived threshold]* |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Comparison data announced | Screen reader can read metric values (weight, reps, volume, duration) for comparison sessions. |
| AC-02 | Empty state announced | Screen reader reads the placeholder/empty message. |
| AC-03 | Error state accessible | Error card and Retry button announced. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Read-only access confirmed | DI-02 confirms no Drift write from viewing comparison. |

---

## 11. Regression Flags

- Any change to session validity criteria must re-run EC-01–EC-04.
- Any change to the <2 sessions threshold must re-run HP-02, NV-04.
- Any change to metric calculation (volume, duration) must re-run HP-06–HP-07, DI-01.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Comparison scope** — story does not specify whether comparison is per-exercise, per-workout, or both. Tests cover both; confirm intended scope. |
| OQ-02 | **"Invalid session" definition** — what constitutes invalid is not defined. EC-01 is QA-derived; clarify with product owner what makes a session invalid for comparison purposes. |
| OQ-03 | **Personal Best relationship** — SCR-24 Personal Bests are DEFERRED; confirm whether SCR-22 comparison influences or is separate from PB calculation. |
