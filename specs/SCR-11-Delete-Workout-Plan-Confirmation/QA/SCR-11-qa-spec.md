# QA Specification — SCR-11: Delete Workout Plan Confirmation

**Story ID:** US-SCR11  
**Feature:** Delete Workout Plan Confirmation  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-11-Delete-Workout-Plan-Confirmation.md` + constitution

---

## 1. Purpose & Scope

Verify the delete confirmation flow: modal shown on entering from SCR-10, loading state on confirm, successful deletion removes the plan and navigates to SCR-08, historical workout sessions using the plan remain unaffected, and local Drift write failure shows a retry error state. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked; a plan must exist that has previously been used in a completed workout (to test history integrity).
- **Entry:** From SCR-10 Plan Detail, tap Delete.
- **Data states:** (a) Normal Drift — deletion succeeds. (b) Drift write forced to fail — delete-failure error state.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Confirmation modal shown | From SCR-10, tap Delete. | Confirmation modal appears explaining plan and schedule assignments will be removed; historical sessions unaffected (FR-1 / AC-1). |
| HP-02 | Loading state on confirm | In the modal, tap Confirm Delete. | Loading indicator shown on the confirmation action while deletion is in progress (FR-2 / AC-2). |
| HP-03 | Successful deletion — plan removed | Complete the deletion. | Plan no longer appears in SCR-08 Workout Plans List (FR-3 / AC-3). |
| HP-04 | Successful deletion — navigates to SCR-08 | After deletion completes. | App navigates to SCR-08 (FR-3 / AC-3). |
| HP-05 | Historical sessions preserved | Plan used for a completed workout is deleted. Open SCR-20 / SCR-21. | Historical workout records for the deleted plan remain visible and intact (FR-4 / SEC-2). |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Delete failure — error state (EC-1) | Force Drift write failure during deletion. | Error state displayed; plan still available; retry action offered (EC-1). |
| NV-02 | Retry after delete failure succeeds | Trigger EC-1; tap Retry; restore database access. | Deletion completes; navigates to SCR-08. |
| NV-03 | Retry after delete failure still fails | Trigger EC-1; tap Retry; Drift still fails. | Error state re-shown; no crash; plan still available. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Cancel on confirmation modal | Tap Cancel on the confirmation modal. | Modal dismissed; returns to SCR-10 with the plan intact. *[QA-derived — cancel behavior not specified beyond exit points]* |
| EC-02 | Tap outside modal to dismiss | Tap the scrim behind the modal. | Either dismissed (returns to SCR-10) or does nothing — confirm behavior with product owner. *[QA-derived]* |
| EC-03 | Delete plan with schedule assignments | Plan has entries on SCR-12 schedule. Delete it. | Plan deleted from list AND schedule assignments for that plan removed from SCR-12 (FR-1). |
| EC-04 | Delete last plan | Only one plan exists; delete it. | Plan removed; SCR-08 shows empty state. |
| EC-05 | Rapid double-tap on confirm | Tap Confirm twice quickly. | Deletion executes only once; no duplicate delete attempts; no crash. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Modal presented over SCR-10 (dimmed) | SCR-10 visible but dimmed behind the modal. |
| SN-02 | After successful delete, back from SCR-08 | From SCR-08 after deletion, back navigates correctly (not back to SCR-10 which no longer has a valid plan). |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Plan fully removed from Drift | After successful delete, the plan record is not found in Drift. Subsequent reads return null/not-found. |
| DI-02 | Historical workout records survive | Completed workouts that referenced the deleted plan ID still exist in the `workout_sessions` table. |
| DI-03 | Schedule assignments removed | After deletion, `schedule_entries` table no longer contains assignments referencing the deleted plan ID. |
| DI-04 | No partial delete on failure | If Drift write fails mid-way through a multi-step delete, previously persisted data (plan, history) is not partially removed. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Loading state during deletion | Confirm button shows loading before deletion completes; no double-action possible during loading. |
| PR-02 | Error state shown promptly | If Drift write fails, error state appears without an indefinite spinner. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Modal content announced | Screen reader announces the confirmation message including history-intact note. |
| AC-02 | Confirm action colour-coded | Delete/confirm button uses danger red (not lime) and is announced as a destructive action. |
| AC-03 | Cancel and confirm both accessible | Both actions ≥44pt tap targets; distinct labels announced. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Delete only the selected plan | Deleting plan A does not delete plan B or any workout history records beyond schedule assignments. |

---

## 11. Regression Flags

- Any change to plan delete Drift operation must re-run HP-03–HP-05, DI-01–DI-04.
- Any change to history-plan relationship (FK/snapshot model) must re-run HP-05, DI-02.
- Any change to schedule cleanup logic must re-run EC-03, DI-03.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Cancel behavior** — Inventory says cancel returns to SCR-10 but does not specify whether the modal closes or the screen transitions. Confirm for EC-01. |
| OQ-02 | **Exact modal copy** — not specified; tests verify modal appears but cannot assert specific text beyond the functional requirement (plan + schedule removed, history intact). |
| OQ-03 | **Multi-step atomicity** — DI-04 assumes the delete (plan + schedule cleanup) is atomic in Drift. Confirm the write strategy (single transaction or sequential writes). |
