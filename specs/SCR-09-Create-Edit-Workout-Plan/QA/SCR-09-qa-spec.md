# QA Specification — SCR-09: Create / Edit Workout Plan

**Story ID:** US-SCR09  
**Feature:** Create / Edit Workout Plan  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-09-Create-Edit-Workout-Plan.md` + constitution

---

## 1. Purpose & Scope

Verify create and edit modes for a workout plan: blank initial state, pre-fill from the database in edit mode, exercise addition via picker (SCR-07), per-exercise field set driven by type flag (`weighted`/`time-based`/`bodyweight`), all validation rules, loading state during save, write-failure error with in-memory preservation, and unsaved-changes confirmation. No network calls. All saves go to the database.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15, phone form factors only.
- **Create mode:** Entered from SCR-08 with no plan ID.
- **Edit mode:** Entered from SCR-10 with an existing plan ID; plan data pre-filled.
- **Exercise seed data:** At least one of each type (`weighted`, `time-based`, `bodyweight`) in the catalogue (Drift).
- **Auth:** App unlocked.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Create mode — blank initial state | Open SCR-09 in create mode. | Plan name field is blank, exercise list is empty, "Add exercise" action is visible (FR-1 / AC-1). |
| HP-02 | Edit mode — pre-filled | Open SCR-09 in edit mode. | All fields pre-filled with existing plan data (FR-2 / AC-2). |
| HP-03 | Add weighted exercise | Create mode; tap "Add exercise"; select a `weighted` exercise from SCR-07. | Exercise appears in the list with Sets, Reps, Weight, Rest fields (FR-4a). No Duration field. |
| HP-04 | Add time-based exercise | Add a `time-based` exercise. | Exercise shows Sets, Duration (mm:ss), Rest fields (FR-4a). No Reps or Weight fields. |
| HP-05 | Add bodyweight exercise | Add a `bodyweight` exercise. | Exercise shows Sets, Reps, Rest fields (FR-4a). No Weight field. |
| HP-06 | Save valid plan — create mode | Fill name, add exercise, fill valid targets. Tap Save. | Loading indicator shown (NFR-1 / EC-6). On success, navigates to SCR-10 with new plan (FR-10 / AC-3). |
| HP-07 | Save valid plan — edit mode | Modify name or targets. Tap Save. | Same as HP-06; SCR-10 shows updated data. |
| HP-08 | Duration entered and stored as seconds | For a `time-based` exercise, enter `01:30` (1 min 30 sec). | UI shows `01:30`; internal storage is `90` seconds (FR-9). |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Blank plan name (EC-1) | Leave plan name empty. Tap Save. | Inline validation error shown; save blocked (FR-5 / EC-1). |
| NV-02 | Whitespace-only plan name | Enter `"   "` as name. Tap Save. | Treated as blank; inline error shown; save blocked (FR-5). |
| NV-03 | Non-positive reps — weighted (EC-3) | Enter `0` for reps on a weighted exercise. Tap Save. | Inline field error; save blocked (FR-7 / EC-3). |
| NV-04 | Non-positive reps — bodyweight (EC-3) | Enter `-1` for reps on a bodyweight exercise. Tap Save. | Inline field error; save blocked (FR-7 / EC-3). |
| NV-05 | Non-positive sets (EC-3) | Enter `0` for sets on any exercise. Tap Save. | Inline field error; save blocked (FR-7 / EC-3). |
| NV-06 | Zero weight — weighted (EC-4) | Enter `0` for weight on a weighted exercise. Tap Save. | Inline field error; save blocked (FR-8 / EC-4). 0 is not a valid weight. |
| NV-07 | Negative weight — weighted (EC-4) | Enter `-5` for weight. Tap Save. | Inline field error; save blocked (FR-8 / EC-4). |
| NV-08 | Non-positive duration — time-based (EC-5) | Enter `00:00` duration. Tap Save. | Inline field error; save blocked (FR-9 / EC-5). |
| NV-09 | Negative duration — time-based | Enter a negative duration (if UI permits). | Inline field error; save blocked (FR-9). |
| NV-10 | Invalid exercise reference (EC-2) | (Via test stub) Force an exercise reference to be invalid at save time. | Invalid reference flagged/rejected; plan not saved (FR-6 / EC-2). |
| NV-11 | Weight field not shown for bodyweight | Add a bodyweight exercise. | No weight field rendered in the UI (FR-4a). Attempting to type a weight value is impossible. |
| NV-12 | Duration field not shown for weighted | Add a weighted exercise. | No duration field rendered (FR-4a). |
| NV-13 | Multiple simultaneous validation errors | Leave name blank AND enter 0 reps. Tap Save. | Both errors shown simultaneously; save blocked. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Save plan with no exercises | Create plan with a name but no exercises. Tap Save. | **Not specified in Inventory (OQ-01).** Test whether save is blocked or allowed. Record actual behaviour. *[QA-derived]* |
| EC-02 | Reorder exercises (if supported) | Drag to reorder exercises in the list. | **Not specified in Inventory.** If reordering is not in scope, no drag affordance visible. *[QA-derived]* |
| EC-03 | Remove exercise from plan | Tap delete/remove on an exercise row. | Exercise removed from list. Plan can still be saved if remaining exercises are valid. *[QA-derived]* |
| EC-04 | Duration display round-trip | Enter `00:90` (overflow format). | UI coerces to `01:30` or rejects overflow; does not crash. *[QA-derived]* |
| EC-05 | Very large reps/sets values | Enter `9999` for sets. | Accepted without crash, or maximum enforced with a clear error. *[QA-derived — max not specified, see OQ-02]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Leave with unsaved changes — confirm dialog | Make edits; tap back. | Discard-changes confirmation displayed (NFR-4 / AC-4). |
| SN-02 | Confirm discard — navigates away | On confirm dialog, tap Discard/Yes. | Navigates away without saving; plan not written to the database. |
| SN-03 | Cancel discard — remains on screen | On confirm dialog, tap Cancel. | Remains on SCR-09 with edits intact. |
| SN-04 | No discard dialog if no changes | Open edit mode; make no changes; tap back. | No confirmation dialog. Navigates directly back. |
| SN-05 | Add exercise navigates to SCR-07 | Tap "Add exercise." | Opens SCR-07 picker mode. Selecting an exercise returns to SCR-09 with that exercise added. |
| SN-06 | Save failure preserves edits (EC-7/EC-8) | Trigger database write failure. | Write-failure error shown (NFR-2 / EC-7). Edits remain in memory; no data loss. Can retry. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Save writes to the database exactly once | On successful save, exactly one database write occurs. No duplicate record created. |
| DI-02 | Edit does not create a second plan | Save in edit mode updates the existing plan record, not creates a new one. |
| DI-03 | Duration stored as seconds | `01:30` mm:ss input stored as `90` (seconds) in the database; displayed as `01:30` when re-opened. |
| DI-04 | Plan name trimming | Plan name `" MyPlan "` saved and retrieved; stored with or without whitespace trim consistently. *[Note: FR-5 says blank/whitespace-only is blocked, but does not specify trimming of padded-valid names — flag for OQ-03]* |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Loading indicator shown during save | Save action shows loading state until database write completes (NFR-1 / EC-6). |
| PR-02 | Save failure does not clear form | After a write failure, all form fields retain their values for the retry. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Plan name field labelled | Screen reader announces "Plan name" or equivalent for the text field. |
| AC-02 | Validation errors announced | Inline errors announced by screen reader when they appear. |
| AC-03 | Type-specific fields labelled | Sets, Reps, Weight, Duration, Rest fields each have accessible labels. |
| AC-04 | Duration field format hint | Time-based duration field indicates expected mm:ss format to screen reader. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Edit mode shows only the target plan | Edit mode loads only the plan whose ID was passed; no access to other plans' data via route manipulation. |

---

## 11. Regression Flags

- Any change to exercise type-flag rendering logic must re-run HP-03–HP-05, NV-11–NV-12.
- Any change to plan-name validation must re-run NV-01, NV-02.
- Any change to save flow (Bloc → Drift) must re-run HP-06, HP-07, SN-06, DI-01–DI-02.
- Any change to the discard-changes guard must re-run SN-01–SN-04.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Minimum exercise count for save** — Inventory does not specify whether a plan with 0 exercises can be saved. EC-01 is a must-test but cannot be pass/failed without confirmation. |
| OQ-02 | **Max values for sets, reps, weight, duration** — not specified. EC-05 and DI-04 are informational until confirmed. |
| OQ-03 | **Plan name whitespace trimming** — FR-5 blocks whitespace-only; does not define trimming of padded-valid names. DI-04 to be confirmed. |
| OQ-04 | **Exact inline error messages** — not specified in Inventory. Test cases verify the error appears but cannot assert the exact string. |
