# QA Specification — SCR-14: Remove From Schedule Confirmation

**Story ID:** US-SCR14  
**Feature:** Remove From Schedule Confirmation  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-14-Remove-From-Schedule.md` + constitution

---

## 1. Purpose & Scope

Verify the remove-from-schedule confirmation flow: modal shown from SCR-12, loading state on confirm, successful removal routes to SCR-12 without the entry, history unaffected, and local Drift write failure shows a retry error state. Failure uses the SCR-27 Write-Error template (err-note: "Nothing was recorded — retrying won't create a duplicate"). No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Entry:** From SCR-12 Weekly Schedule View, tap remove on a scheduled entry.
- **Pre-condition:** At least one schedule entry exists for a weekday.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Confirmation modal shown | From SCR-12, tap Remove on a scheduled day. | Confirmation modal displayed identifying which day/plan is being removed (FR-1 / AC-1). |
| HP-02 | Loading state on confirm | Tap Confirm in modal. | Loading state shown on confirm action (NFR-1 / AC-2). |
| HP-03 | Successful removal — entry gone from SCR-12 | Removal succeeds. | Navigates to SCR-12; the removed day shows "Rest day" or equivalent; plan no longer on that day (FR-2 / FR-3 / AC-3). |
| HP-04 | Historical records unaffected | A completed workout used the now-removed schedule plan. Check history. | SCR-20/SCR-21 show that historical workout unchanged (FR-2 / implied from domain rules). |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Removal failure — error state (EC-1) | Force Drift write failure during removal. | Error state shown; schedule entry still in Drift; retry offered (NFR-2 / EC-1). |
| NV-02 | Error state includes err-note | In error state (NV-01). | "Nothing was recorded — retrying won't create a duplicate." visible per Write-Error template (SCR-27). |
| NV-03 | Retry after failure succeeds | Trigger EC-1; tap Retry; restore database access. | Entry removed; navigates to SCR-12. |
| NV-04 | Retry after failure still fails | Trigger EC-1; tap Retry; Drift still fails. | Error state re-shown; no crash; entry still intact. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Cancel on confirmation modal | Tap Cancel on the modal. | Returns to SCR-12 with the schedule entry intact. *[QA-derived]* |
| EC-02 | Tap scrim behind modal | Tap outside the modal. | Either dismissed (entry intact) or no-op. Confirm behaviour with product owner. *[QA-derived]* |
| EC-03 | Remove the only scheduled entry | Only one day has a plan. Remove it. | SCR-12 shows full empty state after removal. *[QA-derived]* |
| EC-04 | Remove today's scheduled workout | Today has a plan. Remove it. | SCR-12 no longer shows Start action for today. Home Dashboard also no longer shows today's workout (if read from Drift). *[QA-derived]* |
| EC-05 | Rapid double-tap Confirm | Tap Confirm twice quickly. | Removal executes only once; no duplicate Drift delete; no crash. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Modal over dimmed SCR-12 | SCR-12 dimmed behind the modal. |
| SN-02 | Successful removal back-stack | After removal, back from SCR-12 goes to the tab root, not back to the modal. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Entry fully removed from Drift | After successful removal, the schedule entry is not found in Drift. |
| DI-02 | Only the targeted entry removed | Removing Mon's plan does not remove other days' plans. |
| DI-03 | No duplicate removal on retry | Retrying a failed removal does not attempt to delete a record that was already deleted. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Loading state blocks double-confirm | During loading, Confirm button disabled/inaccessible. |
| PR-02 | Error state shown promptly | Drift write failure surfaces error state without indefinite spinner. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Modal content announced | Screen reader reads which day/plan is being removed. |
| AC-02 | err-note accessible (on failure) | "Nothing was recorded — retrying won't create a duplicate." read by screen reader in error state. |
| AC-03 | Cancel and Confirm accessible | Both ≥44pt; distinct labels; Confirm not mistakable for Cancel. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Removal applies only to this device's schedule | Single local user; only this device's `schedule_entries` table modified. |

---

## 11. Regression Flags

- Any change to schedule-delete Drift operation must re-run HP-03, DI-01–DI-03.
- Any change to Write-Error template must re-run NV-02.
- Any change to today's-workout surfacing must re-run EC-04.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Modal copy not specified** — tests verify modal appears; cannot assert exact text. |
| OQ-02 | **Cancel/scrim dismiss behaviour** — EC-01/EC-02 both need confirmation from product owner. |
