# QA Specification — SCR-08: Workout Plans List

**Story ID:** US-SCR08  
**Feature:** Workout Plans List  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-08-Workout-Plans-List.md` + constitution

---

## 1. Purpose & Scope

Verify the Workout Plans List: skeleton loading state, empty state with "Create a workout plan" CTA, populated list with plan name and summary, navigation to create/edit (SCR-09) and plan detail (SCR-10), and error state with retry when database read fails. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15, phone form factors only.
- **Auth:** App unlocked; navigated to Plans tab.
- **Data states:** (a) No plans → empty state. (b) One or more plans → populated. (c) Drift forced to fail → error state.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Skeleton shown during load | Open Plans list before database read completes (mock delay). | Skeleton loading UI visible (FR-1 / AC-1). |
| HP-02 | Empty state shown | No plans in the database. Open Plans. | Empty state with "Create a workout plan" CTA displayed (FR-2 / AC-2). |
| HP-03 | Populated list | At least one plan saved. Open Plans. | Each plan card shows plan name and summary (FR-3 / AC-3). |
| HP-04 | Navigate to create | Tap the "Create a workout plan" CTA or the create/add action. | Navigates to SCR-09 in create mode (FR-4 / AC-4). |
| HP-05 | Navigate to plan detail | Tap an existing plan card. | Navigates to SCR-10 Plan Detail for the selected plan (FR-5 / AC-4). |
| HP-06 | Navigate to edit | Tap the edit affordance on a plan card. | Navigates to SCR-09 in edit mode for the selected plan (FR-4 / AC-4). |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Load failure — error state (EC-1) | Force database read failure for the plans table. | Error state displayed with retry action (FR-6 / EC-1). |
| NV-02 | Retry after failure succeeds | Trigger EC-1, tap Retry, restore the database. | Plans load correctly after retry. |
| NV-03 | Retry after failure still fails | Trigger EC-1, tap Retry, Drift still fails. | Error state re-shown without crash. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Plans list after creating then deleting all plans | Create plan; delete it via SCR-11; return to list. | Empty state re-appears correctly. *[QA-derived]* |
| EC-02 | Very long plan name | Create a plan with a name exceeding typical card width. | Name truncates or wraps without overflow or layout breakage. *[QA-derived]* |
| EC-03 | Many plans (stress) | Create 20+ plans. | List scrolls smoothly; no performance regression; all plans visible via scroll. *[QA-derived]* |
| EC-04 | Return to list after editing plan | Edit a plan name on SCR-09, save, return to list. | Updated plan name is shown on the list without a manual refresh. *[QA-derived]* |
| EC-05 | List order | Create plans in sequence. | Plans appear in a consistent order (spec does not define exact ordering; flag for confirmation — see OQ-01). *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Bottom nav visible in all states | Empty, loading, error, and populated states all show the bottom nav shell correctly. |
| SN-02 | Back from SCR-09 (create, cancel) returns to list | Cancel on SCR-09 create mode returns to Plans list without adding a plan. |
| SN-03 | Back from SCR-10 returns to list | Back navigation from Plan Detail returns to Plans list. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | List reflects current Drift state | After adding a plan (SCR-09), list includes the new plan. After deleting (SCR-11), list excludes it. No caching artefacts. |
| DI-02 | List is read-only | Opening Plans list does not write to the database. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Skeleton renders before data | No blank frame between splash/tab switch and skeleton; transition is smooth. |
| PR-02 | Error state does not block nav shell | Tabs in bottom nav remain tappable during error state. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Plan cards accessible | Screen reader announces each plan's name and summary. |
| AC-02 | Empty state CTA accessible | "Create a workout plan" CTA announced and tappable. |
| AC-03 | Error state accessible | Error state announced; retry action has accessible label. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Plans list not accessible when locked | Route guard prevents SCR-08 access if login state is locked. |

---

## 11. Regression Flags

- Any change to plan list query or table name must re-run HP-03, DI-01.
- Any change to skeleton/loading logic must re-run HP-01.
- Any change to routing from list must re-run HP-04, HP-05, HP-06, SN-02, SN-03.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Plan list ordering not specified** — Inventory does not define creation-order, alphabetical, or last-modified ordering. EC-05 cannot pass/fail without this. |
| OQ-02 | **Plan summary content not specified** — FR-3 says "name and summary" but exact summary fields (exercise count, last-modified date) are not defined. Confirm for HP-03 pass condition. |
