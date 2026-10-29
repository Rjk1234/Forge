# QA Specification — SCR-26: Confirm Logout

**Story ID:** US-SCR26  
**Feature:** Confirm Logout  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-26-Confirm-Logout.md` + constitution

---

## 1. Purpose & Scope

Verify the logout confirmation modal: presented when the user taps Logout on SCR-25, confirm sets the local login flag to locked and routes to SCR-01/SCR-03, user data in Drift is untouched, and deny returns to SCR-25. No failure state is defined for this flow. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App currently unlocked (login flag = unlocked).
- **Entry:** From SCR-25 Profile, tap Logout.
- **Pre-condition:** User has workout history and plan data in Drift (to verify data preservation).

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Logout modal shown | From SCR-25, tap Logout. | Confirmation modal appears (AC-1). |
| HP-02 | Confirm logout — flag set, route to login | In modal, tap Confirm. | Local login flag set to locked; routes to SCR-01 (which checks flag and routes to SCR-03) (FR-1 / AC-2). |
| HP-03 | User data preserved after logout | After confirming logout, inspect Drift. | Workout history, plans, and profile data unchanged in Drift (FR-2 / AC-3). |
| HP-04 | Deny logout — return to SCR-25 | In modal, tap Cancel/Deny. | Modal dismissed; returns to SCR-25 with the user still logged in (AC-4). |
| HP-05 | App re-launched after logout | After confirming logout, close and relaunch app. | Splash (SCR-01) detects locked flag; routes to SCR-03 Login. |

---

## 4. Negative / Validation Test Cases

No failure state is defined in the story inventory. Negative tests are limited to the deny path (HP-04).

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Tap scrim behind modal | Tap outside the confirmation modal. | Either dismissed (deny, return to SCR-25) or no-op. Confirm behaviour. *[QA-derived]* |
| EC-02 | Android system back on modal | Press system back on the logout confirmation. | Returns to SCR-25 (modal dismissed, user still logged in). *[QA-derived]* |
| EC-03 | Rapid double-tap Confirm | Tap Confirm twice quickly. | Logout executes once; only one navigation event; login flag not toggled twice. *[QA-derived]* |
| EC-04 | Logout, then log in again | Confirm logout; complete login on SCR-03; navigate to history. | Previous history data still present (user data was untouched by logout). *[QA-derived]* |
| EC-05 | Modal does not trigger in wrong context | Access modal only from SCR-25 Logout action. | No other navigation path surfaces SCR-26. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Modal over dimmed SCR-25 | SCR-25 visible but dimmed behind the confirmation modal. |
| SN-02 | After confirm — back from SCR-03 does not return to authenticated app | Once logged out and on SCR-03, the user cannot navigate back to the protected app without re-authenticating. |
| SN-03 | Deny — SCR-25 state intact | After denying logout, SCR-25 profile fields and any unsaved edits are unchanged. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Login flag only is changed | After confirming logout, only the auth lock flag changes; no workout records, plan records, or profile fields are deleted or modified. |
| DI-02 | History count unchanged after logout/login | After logging out and back in, SCR-20 history count matches pre-logout count. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Logout is instant — no loading state | Story defines no error/loading state; confirm tap fires immediately. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Modal content announced | Screen reader announces the logout confirmation message. |
| AC-02 | Confirm action danger-styled | Confirm/Logout button styled in danger red; screen reader distinguishes it from Cancel. |
| AC-03 | Both actions ≥44pt | Confirm and Cancel meet minimum touch target size. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Login flag set to locked on confirm | After confirming logout and relaunching, SCR-01 detects locked flag and routes to SCR-03. |
| SC-02 | Cannot access authenticated screens after logout | Post-logout, direct navigation attempts to protected screens redirect to SCR-03. *[QA-derived]* |
| SC-03 | User data not cleared | DI-01 confirms data preservation. |

---

## 11. Regression Flags

- Any change to the local login flag mechanism must re-run HP-02, HP-05, SC-01.
- Any change to the deny/cancel flow must re-run HP-04, SN-03.
- Any change to data-preservation guarantee must re-run HP-03, DI-01–DI-02.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Exact modal copy** — not specified; tests verify a confirmation modal appears but cannot assert exact strings. |
| OQ-02 | **Scrim dismiss** — EC-01 behaviour (deny vs no-op) not specified; confirm with product owner. |
| OQ-03 | **Back-stack after logout** — SN-02 asserts the user cannot back into the authenticated app; confirm that go_router fully clears the navigation stack on logout. |
