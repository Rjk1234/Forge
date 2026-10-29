# QA Specification — SCR-10: Plan Detail

**Story ID:** US-SCR10  
**Feature:** Plan Detail  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-10-Plan-Detail.md` + constitution

---

## 1. Purpose & Scope

Verify Plan Detail: skeleton loading, populated display of plan name and exercise targets, presence of all four actions (Edit, Delete, Start Workout, Schedule), and error/not-found state when the plan cannot be loaded (database read failure or plan deleted elsewhere). No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Entry points:** SCR-08 (plan tap) or SCR-09 (after successful save).
- **Data states:** (a) Plan exists → populated. (b) database read fails or plan deleted → error/not-found.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Skeleton while loading | Open a plan that has a simulated slow database read. | Skeleton visible until plan data arrives (FR-1 / AC-1). |
| HP-02 | Plan name and exercises displayed | Open a valid plan. | Plan name and full exercise list with configured targets shown (FR-2 / AC-2). |
| HP-03 | Weighted exercise targets shown | Plan contains a `weighted` exercise. | Sets, Reps, Weight, Rest values displayed. |
| HP-04 | Time-based exercise targets shown | Plan contains a `time-based` exercise. | Sets, Duration (mm:ss), Rest shown; no Reps/Weight. |
| HP-05 | Bodyweight exercise targets shown | Plan contains a `bodyweight` exercise. | Sets, Reps, Rest shown; no Weight. |
| HP-06 | All four actions present | Open any valid plan. | Edit, Delete, Start Workout, and Schedule actions all present (FR-3–FR-6 / AC-3). |
| HP-07 | Edit action navigates to SCR-09 | Tap Edit. | Opens SCR-09 in edit mode for this plan. |
| HP-08 | Delete action navigates to SCR-11 | Tap Delete. | Opens SCR-11 Delete Confirmation for this plan. |
| HP-09 | Start Workout action navigates to SCR-15 | Tap Start Workout. | Opens SCR-15 Workout Pre-Start / Overview for this plan. |
| HP-10 | Schedule action navigates to SCR-13 | Tap Schedule. | Opens SCR-13 Assign / Edit Schedule for this plan. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Plan load failure / not found (EC-1) | Open a plan ID that no longer exists in the database (deleted from another entry point). | Error/not-found state displayed with back action (FR-7 / EC-1). |
| NV-02 | Database read error on open | Force database read failure for plan detail. | Same error/not-found state shown (FR-7 / EC-1). |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Plan deleted while detail is open | Open plan detail; then delete via another entry point (if multi-tab possible on tablet — not applicable; phone-only). | N/A for phone-only. Flag for future iPad consideration. *[QA-derived]* |
| EC-02 | Plan with zero exercises | If SCR-09 allows saving an empty-exercise plan, detail should display plan name with an empty exercise list. | No crash; empty exercise section shown. *[QA-derived — depends on OQ-01 from SCR-09]* |
| EC-03 | Very many exercises in plan | Plan with 10+ exercises. | List scrolls; all exercises visible; no layout overflow. *[QA-derived]* |
| EC-04 | Back from SCR-09 edit (cancel) returns to SCR-10 | On SCR-09, cancel edit without saving. | Returns to SCR-10 with the plan unchanged. *[QA-derived]* |
| EC-05 | Back from SCR-13 returns to SCR-10 | After scheduling, navigate back. | Returns to SCR-10 correctly. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Error/not-found back action | In error/not-found state, back action navigates to SCR-08. |
| SN-02 | After successful edit save, SCR-10 shows updated plan | SCR-09 edit save navigates to SCR-10; plan shows new data without stale cache. |
| SN-03 | After delete (SCR-11 confirmed), navigates to SCR-08 | SCR-11 confirms deletion; app goes to SCR-08, not back to SCR-10 with a now-deleted plan. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Detail is read-only | Opening Plan Detail does not modify any Drift data. |
| DI-02 | Targets displayed match Drift values | Reps, sets, weight, duration values on SCR-10 match the values saved on SCR-09 (including duration as mm:ss). |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | No blank frame between skeleton and content | Skeleton transitions smoothly to content; no flash of empty. |
| PR-02 | Error state reachable on slow device | Even on API 29 with slow I/O, error/not-found state appears rather than indefinite skeleton. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Plan name announced | Screen reader reads the plan name as a heading or prominent label. |
| AC-02 | All four actions reachable | Edit, Delete, Start Workout, Schedule all accessible with ≥44pt tap targets; screen reader announces their roles. |
| AC-03 | Error/not-found state announced | Error content and back action announced to screen reader. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Plan ID not spoofable | Navigating with a fabricated plan ID shows error/not-found, not another user's data (single user — just confirms no cross-plan leakage from ID manipulation). |

---

## 11. Regression Flags

- Any change to plan detail query must re-run HP-01–HP-06, DI-02.
- Any change to exercise type-flag field rendering must re-run HP-03–HP-05.
- Any change to action routing must re-run HP-07–HP-10, SN-01–SN-03.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Exact fields shown per exercise** — Inventory says "exercise list with configured targets" but does not enumerate all displayed fields (e.g., exercise name, type label, sets, reps, weight, rest). Confirm for HP-02–HP-05 pass conditions. |
| OQ-02 | **Error/not-found copy** — not specified in Inventory. Tests verify the state exists but cannot assert the message string. |
