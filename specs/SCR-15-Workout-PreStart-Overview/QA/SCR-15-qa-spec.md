# QA Specification — SCR-15: Workout Pre-Start / Overview

**Story ID:** US-SCR15  
**Feature:** Workout Pre-Start / Overview  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-15-Workout-PreStart-Overview.md` + constitution

---

## 1. Purpose & Scope

Verify the pre-start overview: skeleton loading, populated display of exercises and targets with "Begin Workout" action, blocking state when plan is invalid/unavailable, and load-failure error state with retry when Drift read fails. No network calls. The distinction between "invalid/unavailable plan" (stale reference) and "Drift read failure" (storage error) must be tested separately.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Entry points:** SCR-10 (Start Workout) or SCR-12 (Start today's scheduled workout).
- **Data states:** (a) Valid plan → populated. (b) Plan deleted since entry → invalid/unavailable. (c) Drift read error → load-failure state.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Skeleton during load | Open SCR-15 with a simulated slow Drift read. | Skeleton visible until plan loads (FR-1 / AC-1). |
| HP-02 | Populated — exercises and targets shown | Open SCR-15 for a valid plan. | Exercise names, types, and configured targets displayed (FR-2 / AC-2). |
| HP-03 | Begin Workout action present | Plan loaded successfully. | "Begin Workout" button visible and enabled (FR-3 / AC-2). |
| HP-04 | Begin Workout navigates to SCR-16 | Tap "Begin Workout." | Opens SCR-16 Active Workout (FR-5). |
| HP-05 | Type-appropriate targets shown | Plan has all three exercise types. | `weighted`: sets/reps/weight/rest. `time-based`: sets/duration/rest. `bodyweight`: sets/reps/rest. No cross-type fields. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Invalid/unavailable plan (EC-1) | Open SCR-15 for a plan that was deleted between tap and load. | Blocking state shown; Begin Workout not available; cannot proceed (FR-4 / EC-1). |
| NV-02 | Drift read failure (EC-2) | Force Drift read error on SCR-15 open. | Error state shown with retry action (EC-2). |
| NV-03 | Retry after read failure succeeds | Trigger NV-02; tap Retry; restore database access. | Plan loads correctly. |
| NV-04 | Retry after read failure still fails | Trigger NV-02; tap Retry; Drift still fails. | Error state re-shown; no crash. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Plan with zero exercises | If such a plan can be saved (OQ-01 from SCR-09), SCR-15 should show it without crashing. | Exercise list is empty; Begin Workout may still be shown (spec does not block it at this screen — flag for OQ-01). *[QA-derived]* |
| EC-02 | Plan with many exercises | Plan has 10+ exercises. | List scrollable; no truncation of exercise count. *[QA-derived]* |
| EC-03 | Back from SCR-15 | Tap back before starting workout. | Returns to SCR-10 or SCR-12 (entry point). No workout session started, nothing written to Drift. *[QA-derived]* |
| EC-04 | Begin Workout from SCR-12 then back from SCR-15 | Enter SCR-15 via today's Start on SCR-12; back out. | Returns to SCR-12; schedule unchanged. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Blocking state back action | In invalid/unavailable state, back action returns to entry screen (SCR-10 or SCR-12). |
| SN-02 | Error state back action | In load-failure state, back action available and returns to entry screen. |
| SN-03 | Begin Workout does not add SCR-15 to back stack of SCR-16 | After entering SCR-16, pressing back returns to SCR-10/SCR-12, not to SCR-15 overview. *[QA-derived — confirm routing intent]* |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | SCR-15 is read-only | Viewing pre-start does not create any Drift record. No workout session starts until "Begin Workout" is tapped. |
| DI-02 | Targets shown match Drift values | Values on SCR-15 (sets, reps, weight, duration) match the plan saved on SCR-09. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Skeleton renders immediately | No blank frame between entry and skeleton. |
| PR-02 | Begin Workout tap is immediate | No delay between tap and navigation to SCR-16. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Exercise names and targets announced | Screen reader announces each exercise and its targets. |
| AC-02 | Begin Workout button accessible | ≥44pt tap target; announced as primary action. |
| AC-03 | Blocking state announced | Screen reader announces that the plan is unavailable. |
| AC-04 | Error state retry accessible | Error card and Retry button announced. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Cannot start a workout for an invalid plan | Blocking state (NV-01) prevents any navigation to SCR-16 when plan is unavailable. |

---

## 11. Regression Flags

- Any change to exercise type-flag field rendering must re-run HP-05.
- Any change to plan validity check must re-run NV-01, SC-01.
- Any change to Drift read error handling must re-run NV-02–NV-04.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Zero-exercise plan pre-start** — EC-01 depends on whether SCR-09 allows saving a plan with no exercises (unresolved from SCR-09 OQ-01). |
| OQ-02 | **Back-stack from SCR-16** — SN-03 is QA-derived; confirm whether SCR-15 stays in back stack or is popped. |
| OQ-03 | **Invalid/unavailable vs. Drift read failure distinction** — EC-1 and EC-2 must be distinguishable to the user. Confirm that the blocking state (EC-1) and the error-with-retry state (EC-2) are visually different. |
