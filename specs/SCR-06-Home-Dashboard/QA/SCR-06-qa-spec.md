# QA Specification — SCR-06: Home Dashboard

**Story ID:** US-SCR06  
**Feature:** Home Dashboard  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-06-Home-Dashboard.md` + constitution

---

## 1. Purpose & Scope

Verify the Home Dashboard root screen: empty state when no plans exist, loading indicator while data is fetched from the database, today's scheduled workout surface plus 5 quick links in the populated state, and a recoverable error state with retry when database read fails. The bottom navigation shell must remain usable across all states. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15, phone form factors only.
- **Auth:** App must be in the unlocked state (reached SCR-06 from SCR-01 → SCR-03 or SCR-01 directly).
- **Data states:** (a) No plans, no schedule → empty state. (b) At least one plan and today's schedule → populated. (c) Drift forced to fail during read → error state.
- **Navigation shell:** Bottom navigation with all tabs present in all states.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Empty state shown when no plans | Fresh install with no workout plans created. Open Home. | Shows empty state "Create your first workout plan" (FR-1). No stale UI. |
| HP-02 | Loading indicator during data fetch | Open Home on an initial or slow read. | Loading indicator visible before content renders (FR-2). |
| HP-03 | Today's workout + quick links populated | Create plan, assign to today's day on schedule. Open Home. | Today's scheduled workout visible; 5 quick links all present (FR-3, FR-4 / AC-3, AC-4). |
| HP-04 | All 5 quick links navigate correctly | Tap each quick link in turn. | Each quick link navigates to its documented destination. |
| HP-05 | Start today's workout | Tap the "Start" action for today's scheduled workout. | Navigates to appropriate pre-start or active workout screen (SCR-15). |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Database read error — error state with retry | Force database read failure (e.g., mock/stub at test layer). | Error state is shown with retry action (FR-5 / AC-4 / EC-1). Bottom nav remains usable. |
| NV-02 | Retry after error succeeds | Trigger error, tap Retry, restore the database. | Data loads correctly after retry; error state clears. |
| NV-03 | Retry after error still fails | Trigger error, tap Retry, Drift still fails. | Error state re-shown. No crash. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | No workout scheduled for today but plans exist | Plans exist; none assigned to today. | Home shows populated state without today's workout section (or shows "no workout today" placeholder). Does not show empty state. *[QA-derived — story says "today's scheduled workout" is optional]* |
| EC-02 | Multiple plans but only one scheduled today | Several plans exist; only one on today's schedule. | Exactly one today's workout shown, not all plans. *[QA-derived]* |
| EC-03 | App returned to Home from a deeper screen | Navigate away from Home and return via tab or back. | Home re-fetches or reflects current Drift state; stale data not shown if plans were changed. *[QA-derived]* |
| EC-04 | Home opened immediately after completing a workout | Finish workout (SCR-19), navigate to Home. | Home reflects updated state (plan still exists, schedule unchanged). *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Bottom nav always visible | In empty state, loading state, error state, and populated state — bottom nav tabs are all present and tappable. |
| SN-02 | Back from Home exits app | Android back from Home Dashboard exits the app (no back route to splash or login). |
| SN-03 | Quick link 1 — Plans | Tap Plans quick link. | Navigates to SCR-08 Workout Plans List. |
| SN-04 | Quick link — Schedule | Tap Schedule quick link. | Navigates to SCR-12 Weekly Schedule View. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Dashboard reads, not writes | Opening and closing Home Dashboard does not modify any Drift data. |
| DI-02 | Today's workout reflects current schedule | After editing the schedule (SCR-13), returning to Home shows the updated today's workout without a force-refresh. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Loading state visible on cold open | On cold app start navigating to Home, loading indicator appears before data renders; no JANK or blank frame. |
| PR-02 | Error state does not propagate to nav shell | When error state is shown, tabs in the bottom nav still respond to taps. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Empty state announced | Screen reader announces "Create your first workout plan" text. |
| AC-02 | Quick links tappable | Each quick link meets ≥44pt touch target. |
| AC-03 | Today's workout labelled | Today's scheduled workout section announces its content and the Start action to the screen reader. |
| AC-04 | Error state announced | Error state announced as a live region or equivalent so screen reader user knows retry is available. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Dashboard not accessible when locked | If login state is somehow locked, navigating to SCR-06 route redirects to SCR-01/SCR-03 (route guard). |

---

## 11. Regression Flags

- Any change to the dashboard data query must re-run HP-01–HP-05, EC-01–EC-04.
- Any change to the bottom nav configuration must re-run SN-01.
- Any change to go_router guards must re-run SC-01.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Exact 5 quick links not named in story** — FR-4 says "5 quick links" but their labels and destinations are not listed in the Inventory. Confirm the full list with SRS/SDS owner. |
| OQ-02 | **No plan assigned today — empty section vs. hidden section** — EC-01 behavior is not specified. Confirm with product owner. |
| OQ-03 | **Home refresh strategy** — story does not specify whether Home re-fetches on return from a deeper screen or only on initial open. Confirm approach (stream vs. one-shot read) to settle EC-03/DI-02. |
