# QA Specification — SCR-13: Assign / Edit Schedule

**Story ID:** US-SCR13  
**Feature:** Assign / Edit Schedule  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-13-Assign-Edit-Schedule.md` + constitution

---

## 1. Purpose & Scope

Verify schedule assignment and editing: blank state for new assignments with save disabled, pre-filled state in edit mode, one-plan-per-day conflict detection and rejection, invalid/unavailable plan detection, loading state during save, successful save routing to SCR-12, and save-failure error state. Recurrence is weekly-only (always-on, not a user toggle). No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Entry modes:** (a) New assignment — from SCR-12 "Schedule a plan" CTA or SCR-10 Schedule action. (b) Edit — from SCR-12 day edit affordance.
- **Conflict setup:** To test EC-2, pre-assign a plan to a weekday before opening SCR-13 for the same weekday with a different plan.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | New assignment — no days selected | Open SCR-13 in new-assignment mode. | No days selected; save action disabled (FR-1 / AC-1). |
| HP-02 | Edit — pre-filled | Open SCR-13 from SCR-12 day edit. | Current day(s) and recurrence setting pre-filled (FR-2 / AC-2). |
| HP-03 | Select a valid day and enable save | In new mode, tap a weekday with no conflict. | Save action becomes enabled. |
| HP-04 | Recurrence toggle is weekly-only | View recurrence control. | Recurrence shows "Repeats weekly" (or similar fixed display); no user-accessible alternative options (Decisions Log §4). |
| HP-05 | Save — loading state | Tap Save with valid configuration. | Loading state shown (FR-5 / NFR-1 / EC-3). |
| HP-06 | Successful save — navigates to SCR-12 | Save succeeds. | App navigates to SCR-12 with updated schedule; history unaffected (FR-6 / FR-7 / AC-3). |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Save disabled with no days selected | New assignment mode; no day selected; tap Save (if enabled). | Save remains disabled until at least one day is chosen (FR-1 / AC-1). |
| NV-02 | Conflict — day already has a different plan (EC-2) | Day X already has Plan A; attempt to schedule Plan B on Day X. Tap Save. | Inline conflict error shown; save blocked (FR-4 / EC-2). Message references "one plan per day" rule. |
| NV-03 | Conflict — self-assignment (edit same plan same day) | Edit the existing schedule for Plan A on Day X; keep Day X selected. | No conflict; save allowed. *[QA-derived — editing the same assignment should not self-conflict]* |
| NV-04 | Invalid/unavailable plan (EC-1) | Open SCR-13 with a plan ID that has been deleted since the screen was opened (test stub). | Explanatory message shown; save blocked (FR-3 / EC-1). |
| NV-05 | Save failure — error state (EC-4) | Force Drift write failure during save. | Error state with retry shown (EC-4). |
| NV-06 | Retry after save failure succeeds | Trigger EC-4; tap Retry; restore database access. | Schedule saved; navigates to SCR-12. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Select all 7 days | Tap all weekdays (Mon–Sun) in new mode. | All days selected; save enabled; conflict errors shown for any days already occupied. *[QA-derived]* |
| EC-02 | Deselect the only selected day | Select one day; then deselect it. | Save disabled again (no days selected). *[QA-derived]* |
| EC-03 | Multiple conflicting days | Plan B selected on Mon and Tue; Mon has Plan A already (conflict), Tue does not. Tap Save. | Only Mon shows conflict; save blocked until Mon conflict resolved or deselected. *[QA-derived]* |
| EC-04 | Cancel without saving | Make selections; tap back. | Returns to previous screen (SCR-12 or SCR-10) without writing to Drift. *[QA-derived]* |
| EC-05 | Workout history unaffected after schedule edit | Previously completed workouts exist. Edit the schedule. | SCR-20/SCR-21 history records unchanged (FR-7 / SEC-2). *[QA-derived — verifies cross-story data integrity]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Back from save loading | Pressing back during loading state — confirm whether back is disabled or allowed (not specified). *[Flag as OQ-01]* |
| SN-02 | Return to SCR-12 after successful save | SCR-12 shows the newly assigned/updated schedule without a manual refresh. |
| SN-03 | Return to SCR-12 on cancel | No Drift changes written. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Save writes to Drift exactly once | On successful save, schedule entry created or updated without duplicates. |
| DI-02 | Edit updates, does not duplicate | Editing an existing schedule entry updates it in-place; no second entry created for the same day. |
| DI-03 | Workout history not modified | After saving a schedule (new or edit), SCR-20/SCR-21 history records are unchanged. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Conflict check is immediate | Tapping a conflicting day highlights the conflict inline without a round-trip to Drift (client-side check). |
| PR-02 | Loading state blocks double-save | During save loading, the save button is disabled/inaccessible. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Day selection accessible | Mon–Sun weekday circles announced as toggles; selected state communicated. |
| AC-02 | Conflict error announced | Inline conflict error announced to screen reader on conflicting day. |
| AC-03 | Save button state announced | "Save disabled" announced when no days selected; "Save" when enabled. |
| AC-04 | Recurrence label accessible | "Repeats weekly" text readable by screen reader. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Schedule changes apply to this device's schedule only | No other device/user's data modified (single local user). |

---

## 11. Regression Flags

- Any change to conflict detection logic must re-run NV-02, NV-03, EC-01–EC-03.
- Any change to save flow must re-run HP-05, HP-06, NV-05, DI-01–DI-02.
- Any change to recurrence model must re-run HP-04.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Back during loading** — not specified. SN-01 cannot pass/fail without confirmation. |
| OQ-02 | **Plan selector UI** — when SCR-13 is entered from SCR-12 (not SCR-10), does the user select which plan to assign? Inventory is ambiguous. Confirm flow. |
| OQ-03 | **Exact conflict error copy** — not specified. Tests verify it appears; cannot assert exact string. |
| OQ-04 | **Multi-day editing** — when editing an existing single-day assignment to add a second day, is this a create of a second entry or an update of the existing one? Confirm data model. |
