# QA Specification — SCR-20: Workout History List

**Story ID:** US-SCR20  
**Feature:** Workout History List  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-20-Workout-History-List.md` + constitution

---

## 1. Purpose & Scope

Verify the workout history list: skeleton during load, empty state with the mandated message when no history exists, reverse-chronological populated list, item tap navigates to SCR-21, and load failure shows an error with retry. Only completed workout records appear — no incomplete or cancelled sessions. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Data states:** (a) Drift has no completed records → empty state. (b) ≥1 completed records → populated. (c) Drift read error → load-failure state.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Skeleton during load | Open SCR-20 with a simulated slow Drift read. | Skeleton visible until records load (FR-1 / AC-1). |
| HP-02 | Empty state | No completed workouts in Drift. | Empty state shown with "Your completed workouts will appear here" (FR-2 / AC-2). |
| HP-03 | Populated list — reverse-chronological | Multiple completed workouts. | Records displayed newest-first (FR-3 / AC-3). |
| HP-04 | List item shows name + summary | Populated. | Each card shows workout name and a summary (date, sets, duration, etc.) as specified. |
| HP-05 | Select record → SCR-21 | Tap a history list item. | Navigates to SCR-21 Workout History Detail for that record (FR-4 / AC-4). |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Load failure — error state | Force Drift read error on SCR-20 open. | Error state shown with retry action (FR-5 / AC-5). |
| NV-02 | Retry after failure — success | Trigger NV-01; restore Drift; tap Retry. | List loads correctly. |
| NV-03 | Retry after failure — still fails | Trigger NV-01; tap Retry with Drift still failing. | Error state re-shown; no crash. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Cancelled workout not in list | Complete one workout, cancel two. | Only the completed workout appears; cancelled sessions absent. *[QA-derived]* |
| EC-02 | Large history list | Many completed workouts (20+). | List scrollable; no truncation or overflow. *[QA-derived]* |
| EC-03 | History updates after new completion | SCR-19 writes a new record; return to SCR-20. | New record appears at top (reverse-chronological order maintained). *[QA-derived]* |
| EC-04 | History after plan deletion | A plan referenced by a history entry was deleted. | History entry still appears; SCR-21 detail still accessible (per historical integrity rule). *[QA-derived]* |
| EC-05 | Empty message exact text | Open with empty history. | "Your completed workouts will appear here" must match exactly (FR-2). *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Back from SCR-21 returns to SCR-20 | After viewing a history detail, back navigates to SCR-20. |
| SN-02 | Scroll position preserved on back | Return from SCR-21 to SCR-20. | List scroll position is preserved (or restored to the tapped item). *[QA-derived — confirm intent]* |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Only completed records shown | Verify no incomplete or in-progress records appear (none should exist per Decisions Log §2). |
| DI-02 | Records from deleted plan present | Per domain rule (LOCALDB-01 / FR-4 of SCR-11): deleting a plan does not remove history entries. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Skeleton renders immediately | No blank frame between navigation and skeleton. |
| PR-02 | Large list performance | 50+ records: list renders without janky scrolling or ANR on API 29. *[QA-derived threshold]* |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Each list item announced | Screen reader announces workout name and key summary data for each item. |
| AC-02 | Empty state announced | Screen reader reads the empty state message. |
| AC-03 | Error state accessible | Error card and Retry button announced. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Read-only list | Viewing SCR-20 does not modify any stored records. |

---

## 11. Regression Flags

- Any change to Drift read for history must re-run HP-03, NV-01–NV-03.
- Any change to ordering logic must re-run HP-03, EC-03.
- Any change to empty-state copy must re-run HP-02, EC-05.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **List card summary fields** — exact fields shown per card (beyond name) not fully specified. Tests verify something appears; cannot assert specific layout. |
| OQ-02 | **Scroll position on back** — SN-02 behaviour not specified; confirm with product owner. |
