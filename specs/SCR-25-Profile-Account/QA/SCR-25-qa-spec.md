# QA Specification — SCR-25: Profile / Account

**Story ID:** US-SCR25  
**Feature:** Profile / Account  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-25-Profile-Account.md` + constitution

---

## 1. Purpose & Scope

Verify the profile/account screen: skeleton during load, editable fields (display name, fitness goal, experience level, height, weight), save action with inline validation (invalid height/weight blocked), error state for Drift read or save failure, and the Logout action routing to SCR-26. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Entry:** Profile tab from the main navigation.
- **Data states:** (a) Valid profile → skeleton then populated. (b) Drift read error → error state. (c) Save failure → error state.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Skeleton during load | Open SCR-25 with simulated slow Drift read. | Skeleton visible until profile loads (AC-1). |
| HP-02 | Populated profile fields | Profile exists in Drift. | Display name, fitness goal, experience level, height, and weight shown pre-filled (AC-2). |
| HP-03 | Edit display name and save | Update display name; tap Save. | Profile updated in Drift; success state shown. |
| HP-04 | Edit fitness goal and save | Change fitness goal; tap Save. | Profile updated in Drift. |
| HP-05 | Edit experience level and save | Change experience level; tap Save. | Profile updated in Drift. |
| HP-06 | Edit valid height and save | Enter a valid height value; tap Save. | Profile saved. |
| HP-07 | Edit valid weight and save | Enter a valid weight value; tap Save. | Profile saved. |
| HP-08 | Logout action visible | Profile loaded. | Logout button/action visible on screen (AC-3). |
| HP-09 | Logout tap → SCR-26 | Tap Logout. | Navigates to SCR-26 Confirm Logout modal (AC-3). |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Invalid height — blocked (UC-SCR25-04) | Enter an invalid height (e.g., `0`, negative, non-numeric). Tap Save. | Save blocked; inline validation error shown (UC-SCR25-04). |
| NV-02 | Invalid weight — blocked (UC-SCR25-04) | Enter an invalid weight (e.g., `0`, negative, non-numeric). Tap Save. | Save blocked; inline validation error shown. |
| NV-03 | Empty display name | Clear display name field; tap Save. | Either blocked with validation error, or confirm expected behaviour for blank name (OQ-01). |
| NV-04 | Read failure — error state (UC-SCR25-06) | Force Drift read error on SCR-25 open. | Error state shown (UC-SCR25-06). |
| NV-05 | Save failure — error state (UC-SCR25-06) | Make valid edits; tap Save; force Drift write failure. | Error state shown; profile edit preserved in-memory; retry offered (UC-SCR25-06). |
| NV-06 | Retry after save failure — success | Trigger NV-05; restore Drift; tap Retry. | Profile saved; success state shown. |
| NV-07 | Retry after read failure | Trigger NV-04; restore Drift; tap Retry. | Profile loads correctly. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Edit multiple fields, then save | Change display name, goal, and height simultaneously; tap Save. | All changes persisted atomically. *[QA-derived]* |
| EC-02 | Save with no changes | Open profile; tap Save without editing. | No error; profile written back (or save no-op). *[QA-derived]* |
| EC-03 | Height/weight boundary values | Enter the extreme valid values for height and weight. | Accepted and saved without error. *[QA-derived — boundary values TBD per product owner]* |
| EC-04 | Special characters in display name | Enter display name with emoji or special chars. | Accepted if no restriction specified; or blocked if restricted. Confirm OQ-01. *[QA-derived]* |
| EC-05 | Rapid double-tap Save | Tap Save twice quickly. | Save executes once; no duplicate Drift write. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Unsaved changes — navigation away | Edit a field; tap another tab before saving. | Either changes discarded (no prompt) or discard-changes confirmation. Confirm OQ-02. |
| SN-02 | Logout → SCR-26 routing | HP-09; after logout confirmed (SCR-26), app navigates to SCR-01/SCR-03 with login flag set to locked. User data in Drift untouched. |
| SN-03 | Back from SCR-25 | Back gesture from profile. | Returns to the previous tab or appropriate destination. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Saved values persist across app restart | Save profile; force-close and relaunch app. Profile fields unchanged. |
| DI-02 | Invalid save does not corrupt existing profile | Trigger NV-01 (invalid height); cancel without saving. Existing profile intact in Drift. |
| DI-03 | Workout history unaffected by profile edit | Edit profile and save; verify SCR-20 history unchanged. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Skeleton immediate | No blank frame between navigation and skeleton. |
| PR-02 | Save completes without indefinite spinner | Drift write completes in normal operation; loading state does not hang. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | All fields labelled | Each editable field (display name, goal, experience level, height, weight) has an accessible label. |
| AC-02 | Validation errors announced | Inline height/weight errors announced to screen reader. |
| AC-03 | Save and Logout accessible | Both ≥44pt; screen reader announces each. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Logout sets login flag to locked | After confirming logout (SCR-26), app shows login screen on next launch. |
| SC-02 | User data not cleared on logout | After logout, Drift workout history and plans still present (login flag only is changed). |

---

## 11. Regression Flags

- Any change to height/weight validation must re-run NV-01, NV-02, EC-03.
- Any change to save/Drift write logic must re-run NV-05–NV-06, DI-01.
- Any change to Logout flow must re-run HP-09, SN-02, SC-01–SC-02.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Display name validation** — NV-03 and EC-04 depend on whether display name has constraints (min length, allowed chars). Not specified. Confirm with product owner. |
| OQ-02 | **Unsaved changes guard** — SN-01 behaviour not specified. Does navigating away discard silently or show a confirmation? Confirm. |
| OQ-03 | **Height/weight valid ranges** — EC-03 boundary values not specified. Confirm min/max for height (cm/ft?) and weight (kg/lb?). |
| OQ-04 | **Fitness goal / experience level options** — valid values for the dropdowns/pickers not enumerated in the story. Must be confirmed before testing NV inputs. |
