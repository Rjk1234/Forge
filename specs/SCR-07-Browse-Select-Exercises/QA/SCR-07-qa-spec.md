# QA Specification — SCR-07: Browse / Select Exercises

**Story ID:** US-SCR07  
**Feature:** Browse / Select Exercises  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-07-Browse-Select-Exercises.md` + constitution

---

## 1. Purpose & Scope

Verify the exercise catalogue screen: catalogue loads from the database (developer-seeded, read-only), search filters correctly, empty search shows the correct message, picker mode selects valid exercises and rejects invalid references, and catalogue load failure shows an error state. Exercises are fixed seed data — no user-created exercises in MVP.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15, phone form factors only.
- **Catalogue data:** Developer-seeded table; contains exercises with `type` flags `weighted`, `time-based`, `bodyweight`.
- **Entry modes:** (a) Browse mode — opened independently or from Home. (b) Picker mode — opened from SCR-09 to add an exercise to a plan.
- **Auth:** App unlocked.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Full catalogue displayed | Open SCR-07 with no search query. | All seeded exercises displayed (FR-1 / AC-1). Exercise names, type flags visible. |
| HP-02 | Search filters results | Type a partial exercise name in the search field. | List updates to show only matching exercises (FR-2 / AC-2). |
| HP-03 | Clear search shows full list | Clear search field. | Full catalogue re-displays. |
| HP-04 | Select exercise in picker mode | Open SCR-07 from SCR-09. Tap a valid exercise. | Exercise is added to the plan being edited; returns to SCR-09 with selected exercise appended (FR-4 / AC-4). |
| HP-05 | Each exercise type visible | Navigate catalogue. | At minimum one `weighted`, one `time-based`, one `bodyweight` exercise present with their type labels/dots. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | No results for search term | Type a term that matches no exercise name. | Empty state "No exercises match your search" shown (FR-3 / AC-3). No error, no crash. |
| NV-02 | Invalid exercise reference rejected (EC-1) | Attempt to select an exercise that has been removed or whose stored ID is no longer valid (simulate via test stub). | Invalid reference rejected; not added to plan; error or no-op shown (FR-5 / EC-1). |
| NV-03 | Catalogue load failure (EC-2) | Force database read failure for the catalogue table. | Error state with retry displayed (EC-2). |
| NV-04 | Retry after catalogue failure | Trigger EC-2, tap Retry, restore the database. | Catalogue loads correctly. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Search with special characters | Enter `"("`, `"/"`, emojis, etc., in search. | No crash; no results returned (gracefully); empty state shown. *[QA-derived]* |
| EC-02 | Search with leading/trailing spaces | Enter `" Push "` (spaces around term). | Results match "Push" (spaces trimmed), or no results if trimming not implemented (flag for dev). *[QA-derived]* |
| EC-03 | Very long exercise name | Catalogue contains exercise with a name exceeding typical card width. | Name truncates or wraps correctly; no overflow or clipping outside bounds. *[QA-derived]* |
| EC-04 | Picker mode: duplicate selection | In picker mode, tap the same exercise twice (if possible). | Exercise added only once to plan, or the UI prevents duplicate taps. *[QA-derived]* |
| EC-05 | Picker mode: back without selection | Open picker from SCR-09, press back without selecting any exercise. | Returns to SCR-09 with the plan unchanged. No exercise added. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Back from picker returns to SCR-09 | After selecting an exercise in picker mode, the app returns to SCR-09. Back-stack is correct. |
| SN-02 | Browse mode back | Back from browse mode returns to the calling screen. |
| SN-03 | Search state preserved on scroll | Scroll down the filtered list; the search field retains its input. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Catalogue is read-only | Browsing or searching does not modify any Drift exercise data. |
| DI-02 | Type flag preserved on selection | The exercise added to the plan via picker retains its original `weighted`/`time-based`/`bodyweight` type flag. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Search is responsive | Typing in the search field filters the list without noticeable lag (< 200 ms debounce typical; no SRS-NFR defined). |
| PR-02 | Large catalogue | If seed data grows to 50+ exercises, scroll performance remains smooth (60 fps target). |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Exercise items accessible | Each exercise row is announced by screen reader with name and type. |
| AC-02 | Search field labelled | Screen reader announces the search field label and current value. |
| AC-03 | Empty state announced | "No exercises match your search" is announced when it appears. |
| AC-04 | Touch targets adequate | Exercise list items and the search field meet ≥44pt touch targets. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | User cannot create or edit catalogue exercises | No UI control exists to add, rename, or delete a seeded exercise. Catalogue is strictly read-only to the user. |

---

## 11. Regression Flags

- Any change to exercise seed data schema (type flag, name) must re-run HP-01, HP-05, DI-02.
- Any change to search filtering logic must re-run HP-02, HP-03, NV-01, EC-01, EC-02.
- Any change to picker mode selection logic must re-run HP-04, EC-04, EC-05, NV-02.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Picker vs. browse mode differentiation** — story implies two modes but exact UI difference (e.g., checkboxes vs. tap-to-add) is not specified in Inventory. Confirm mode presentation. |
| OQ-02 | **Invalid reference simulation** — NV-02 requires test infrastructure to produce an invalid stored ID during selection. Confirm testability with engineering. |
| OQ-03 | **Exercise count in seed data** — exact number of seeded exercises not documented. Needed for HP-01 to define a pass condition. |
