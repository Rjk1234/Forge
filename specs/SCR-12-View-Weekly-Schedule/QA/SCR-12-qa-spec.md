# QA Specification — SCR-12: View Weekly Schedule

**Story ID:** US-SCR12  
**Feature:** View Weekly Schedule  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-12-View-Weekly-Schedule.md` + constitution

---

## 1. Purpose & Scope

Verify the Weekly Schedule screen: skeleton loading, empty state with "Schedule a plan" CTA, populated weekly view including recurring assignments, today's workout with Start action navigating to SCR-15, and load-failure error state with retry. Decisions Log §4 limits to one plan per day maximum. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked; navigated to Schedule tab.
- **Data states:** (a) No schedule entries. (b) One or more days scheduled. (c) Today has a scheduled plan. (d) Drift read failure.
- **Day boundary test:** Test on a date where today's scheduled workout exists.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Skeleton shown during load | Open Schedule with a simulated slow Drift read. | Skeleton weekly grid visible (FR-1 / NFR-1 / AC-1). |
| HP-02 | Empty state — no schedule | No schedule entries in Drift. | Empty state shown with "Schedule a plan" CTA (FR-2 / AC-2). |
| HP-03 | Populated — scheduled days shown | At least one plan assigned to specific weekday(s). | Weekly view shows which plan is on which day, including recurring assignments (FR-3 / AC-3). |
| HP-04 | Today's workout — Start action visible | Today's weekday has a plan assigned. | Start action visible for today's plan (FR-4 / AC-4). |
| HP-05 | Start action navigates to SCR-15 | Tap Start for today's plan. | Opens SCR-15 Workout Pre-Start for that plan (AC-4). |
| HP-06 | Recurring assignment on multiple days | Assign the same plan to recur Mon, Wed, Fri (weekly). | All three days show the plan; today's row shows Start if today is one of them. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Load failure — error state with retry (EC-1) | Force Drift read failure for the `schedule_entries` table. | Error state with retry action shown (EC-1). |
| NV-02 | Retry after failure succeeds | Trigger EC-1; tap Retry; restore database access. | Schedule loads correctly. |
| NV-03 | One plan per day maximum enforced | Attempt to display a day that somehow has two plans (data integrity test). | Only one plan shown per day (Decisions Log §4). If the data model enforces it at write time, this confirms the read is correct. *[Must be verified at data layer too — see DI-01]* |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Today is unscheduled but other days are | Other days have plans; today does not. | Today's row shows "Rest day" or equivalent (no Start action). Other scheduled days display correctly. *[QA-derived]* |
| EC-02 | Day changes while app is open (midnight) | Leave app open across midnight; schedule view is open. | Today's row updates correctly; previously "yesterday" plan no longer shows Start. *[QA-derived — flag as implementation-risk item]* |
| EC-03 | Schedule viewed after removing an assignment | Remove a schedule entry via SCR-14; return to SCR-12. | Removed day shows "Rest day"; Start action gone if it was today. *[QA-derived]* |
| EC-04 | Plan assigned to today but plan subsequently deleted | Plan deleted (SCR-11); return to SCR-12. | Today's row either shows a recovery state or clears the Start action. Does not crash or show a stale plan reference. *[QA-derived — see OQ-01]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Navigate to SCR-13 from empty state CTA | Tap "Schedule a plan" in empty state. | Opens SCR-13 Assign/Edit Schedule. |
| SN-02 | Navigate to SCR-13 from day edit affordance | Tap edit/pencil icon on a scheduled day. | Opens SCR-13 in edit mode for that assignment. |
| SN-03 | Navigate to SCR-14 from a scheduled day | Tap remove on a scheduled day. | Opens SCR-14 Remove from Schedule. |
| SN-04 | Return to SCR-12 after SCR-13 save | Save a schedule on SCR-13. | Returns to SCR-12 with the updated schedule reflected. |
| SN-05 | Bottom nav visible | In all states. | Bottom nav present and functional. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | One plan per day enforced at data layer | Two plans cannot be stored for the same weekday. (Verify at Drift level during write; SCR-13 enforces this; SCR-12 is the read consequence.) |
| DI-02 | Schedule is read-only on this screen | Viewing SCR-12 does not write to Drift. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Skeleton visible before data | No blank frame; skeleton renders immediately on tab switch. |
| PR-02 | Error state allows other tab navigation | Bottom nav tabs respond during error state. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Schedule rows announced | Screen reader announces each day label and assigned plan name, or "Rest day." |
| AC-02 | Start action labelled | "Start" button has accessible label including the plan name and today's date context. |
| AC-03 | Empty state CTA accessible | "Schedule a plan" CTA meets ≥44pt tap target. |
| AC-04 | Error state announced | Error state announced; Retry accessible. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Schedule not accessible when locked | Route guard prevents access to SCR-12 when login state is locked. |

---

## 11. Regression Flags

- Any change to weekly schedule read logic must re-run HP-01–HP-06, EC-01–EC-04.
- Any change to today's date determination must re-run HP-04, HP-05, EC-01, EC-02.
- Any change to Start action routing must re-run HP-05.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Deleted-plan referenced in schedule** — EC-04 is a QA-derived real risk. Confirm how SCR-12 handles a schedule entry pointing to a deleted plan ID (show error for that day, clear entry, etc.). |
| OQ-02 | **Day-change at midnight** — EC-02 is flagged as implementation-risk. Confirm whether the schedule view uses a clock listener or is only evaluated on screen open. |
| OQ-03 | **Exact empty state presentation** — Inventory allows per-day empty state or overall empty state. Confirm which variant is shipped, for HP-02 pass condition. |
