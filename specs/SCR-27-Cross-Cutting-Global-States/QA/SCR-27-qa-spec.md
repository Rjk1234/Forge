# QA Specification — SCR-27: Cross-Cutting Global States

**Story ID:** US-SCR27  
**Feature:** Cross-Cutting Global States (Read-Error and Write-Error templates)  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-27-Cross-Cutting-Global-States.md` + constitution

---

## 1. Purpose & Scope

Verify that the two cross-cutting error templates — Read-Error (Drift read failure) and Write-Error (Drift write failure) — are applied consistently and correctly across all applicable screens. This is a pattern-level specification: individual screen-level error behaviour is already covered in per-screen QA specs; this spec ensures the templates themselves conform to the defined contract, and that removed scenarios (connectivity, invalid-session, cross-user) are absent throughout the app.

**Removed / out-of-scope scenarios (ForgeApp-specific):**
- Connectivity errors — app is fully offline; no network call ever made
- Invalid-session — login is a static local flag; no session token
- Cross-user scenarios — single local user only

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Method:** Force Drift read or write failure on any screen that uses these templates. Verify template anatomy on each.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Read-Error template anatomy | Trigger a Drift read failure on any applicable screen. | Error card shows: alert-triangle icon, error title, error body, Retry action. |
| HP-02 | Write-Error template anatomy | Trigger a Drift write failure on any applicable screen (e.g., SCR-09 save, SCR-14 remove, SCR-16 Finish, SCR-19 Finish). | Error card shows: calendar+exclamation icon, error title, err-note ("Nothing was recorded — retrying won't create a duplicate."), Retry action. |
| HP-03 | Retry action present on both templates | Both error states. | Retry action visible and tappable on both Read-Error and Write-Error cards. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | err-note exact text (Write-Error) | Trigger Write-Error on each applicable screen. | "Nothing was recorded — retrying won't create a duplicate." present verbatim on each. |
| NV-02 | Read-Error does NOT show err-note | Trigger Read-Error on any screen. | err-note copy absent; only alert-triangle, title, body, and Retry shown. |
| NV-03 | No connectivity error state anywhere | Simulate (if possible) a scenario that would trigger a network error in a different app. | No "No internet connection" or similar connectivity state shown — app is fully offline. |
| NV-04 | No invalid-session error state anywhere | Inspect all error states triggered. | No "Session expired" or similar session-related error shown. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Read-Error on every applicable screen | Systematically trigger Drift read errors on all screens that use the Read-Error template: SCR-06, SCR-07, SCR-08, SCR-09, SCR-10, SCR-12, SCR-13, SCR-15, SCR-20, SCR-21, SCR-22, SCR-23, SCR-24, SCR-25. | All show consistent Read-Error template anatomy (HP-01). *[QA-derived]* |
| EC-02 | Write-Error on every applicable screen | Trigger Drift write errors on: SCR-09, SCR-14, SCR-16 (Finish), SCR-19, SCR-25. | All show consistent Write-Error template anatomy including err-note (HP-02). *[QA-derived]* |
| EC-03 | Error card does not obscure navigation | Trigger either error state. | Bottom navigation bar still visible (or accessible via back). App not stuck in a dead end. *[QA-derived]* |
| EC-04 | Error recovered after retry | Trigger error; restore Drift; retry. | Screen transitions to correct loaded state after successful retry. *[QA-derived]* |
| EC-05 | Error card design tokens | Trigger Write-Error. | dangerBorder (#5c3a3a), dangerDark (#2a1010) background, danger (#ff6b6b) border applied as specified. *[QA-derived — verify against design tokens]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Error state does not navigate away | Either error template holds the screen in its current error state; no unsolicited navigation. |
| SN-02 | Back from error state | Back gesture in error state navigates to the entry point, not deeper into error flow. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Write-Error preserves in-memory state | Trigger Write-Error on SCR-09 or SCR-25. User's edits remain in-memory for retry (not lost). |
| DI-02 | No partial Drift write on Write-Error | After Write-Error, Drift does not contain any partial record. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Error state surfaces promptly | Error states do not show an indefinite spinner before displaying the error card. |
| PR-02 | Retry does not deadlock | Rapid Retry taps do not deadlock or cause ANR. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Read-Error announced | Screen reader announces the alert-triangle icon context, error title, and body. |
| AC-02 | Write-Error and err-note announced | Screen reader announces calendar+exclamation context, error title, and err-note "Nothing was recorded — retrying won't create a duplicate." |
| AC-03 | Retry ≥44pt across all screens | Retry action on both templates meets minimum touch target on every applicable screen. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | No data leaked in error messages | Error card text does not expose internal Drift paths, stack traces, or technical implementation details. |

---

## 11. Regression Flags

- Any change to the Write-Error or Read-Error template (icon, copy, err-note) must re-run HP-01, HP-02, NV-01, NV-02, EC-01, EC-02.
- Any new screen that can fail Drift read/write must be added to EC-01/EC-02.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Error title and body copy** — not specified in the story for either template. Tests verify structural elements but cannot assert exact title/body strings. |
| OQ-02 | **Design token verification** — EC-05 lists token values; QA must verify against the implemented widget rather than the story, since the story references design tokens by name only. |
| OQ-03 | **Screens using Read-Error vs. Write-Error** — the complete list of applicable screens was inferred; confirm the authoritative list with engineering to ensure EC-01 and EC-02 cover all relevant screens. |
