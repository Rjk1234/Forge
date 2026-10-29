# QA Specification — SCR-03: Login / Authenticate

**Story ID:** US-SCR03  
**Feature:** Login / Authenticate  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-03-Login-Authenticate.md` + constitution

---

## 1. Purpose & Scope

Verify the static local login screen: fields are empty on open, non-empty validation gates the attempt, matching the hardcoded credential sets the unlocked flag, non-matching shows an error message, and the app routes to SCR-06 on success. There is no network call, no remote auth service, no session token, and no connectivity case.

**Resolved (2026-09-16):** Email validation is non-empty-only. No format check (no `@` or domain requirement). A malformed but non-empty email passes the field check and reaches credential comparison, where it fails with the mismatch banner. OQ-01 is closed.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15, phone form factors only.
- **Auth mechanism:** Static local flag comparison against hardcoded credentials in `AppLockCubit`. No network.
- **Precondition:** App is in locked state (reached SCR-03 via SCR-01 routing).
- **Fields:** Email field + Password field, both empty on open (FR-1/AC-1).

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Correct credentials unlock app | Enter the correct hardcoded email and password. Tap submit. | Login flag set to unlocked. App navigates to SCR-06 Home Dashboard (AC-4 / FR-4). |
| HP-02 | Fields empty on open | Navigate to SCR-03 from splash. | Both email and password fields are empty (FR-1 / AC-1). No pre-filled values. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Wrong password | Enter correct email, wrong password. Tap submit. | Error message displayed: "Email or password is incorrect" (FR-6). Login flag NOT set to unlocked. Stays on SCR-03. |
| NV-02 | Wrong email | Enter wrong email, correct password. Tap submit. | Same error message. No unlock. |
| NV-03 | Both wrong | Enter wrong email and wrong password. Tap submit. | Same error message. No unlock. |
| NV-04 | Login button disabled when email empty | Leave email empty, enter password. | Login button remains disabled (not tappable); no inline error shown — button-disable prevents submission. *(Updated 2026-09-16 — button-disable model adopted; OQ-4 closed.)* |
| NV-05 | Login button disabled when password empty | Enter email, leave password empty. | Login button remains disabled. |
| NV-06 | Login button disabled when both fields empty | App opens; no input entered. | Login button disabled on open; no error state displayed. |
| NV-07 | Whitespace-only email — button stays disabled | Enter `"   "` (spaces only) into email; enter valid content into password. | Button remains disabled (whitespace-only is treated as empty after trim); no submit possible. *(Resolved 2026-09-16.)* |
| NV-09 | Whitespace-only password — button stays disabled | Enter valid email; enter `"   "` (spaces only) as password. | Button remains disabled (whitespace-only treated as empty after trim); no submit possible. *(Resolved 2026-09-16.)* |
| NV-10 | Login button enables when both fields non-empty | Type one character in email field, then one in password field. | Button transitions from disabled to enabled state. *(QA-derived — button-enable live check.)* |
| NV-08 | Malformed email format | Enter `"notanemail"` as email with a valid password. Tap submit. | Non-empty-only policy applies: field passes validation, credential comparison runs, fails → "Email or password is incorrect" banner shown. No inline format error. *(Resolved 2026-09-16 — OQ-01 closed.)* |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Paste credentials into fields | Paste email and password from clipboard. | Fields accept paste; validation and login behave identically to typed input. *[QA-derived]* |
| EC-02 | Password field masking and show/hide toggle | Type password. Verify default state. Then tap the show/hide (eye) icon. | Default: characters masked. After toggle: plain text visible. After second toggle: re-masked. Field value and cursor position unchanged by toggling. *(Show/hide toggle confirmed mandatory 2026-09-16.)* |
| EC-03 | Caps Lock / autocorrect on email field | Keyboard suggests autocorrect for email value. | Credential comparison is exact; autocorrected email that differs from hardcoded value correctly shows error. *[QA-derived]* |
| EC-04 | Rapid double-tap on submit | Tap submit twice very quickly with correct credentials. | Only one navigation to SCR-06; no duplicate database writes; no duplicate login events. *[QA-derived]* |
| EC-05 | App backgrounded then resumed on SCR-03 | Background the app mid-typing, return. | Fields retain typed values on resume; no crash; no automatic login. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | No back navigation from SCR-03 to main app | On SCR-03, pressing system back does not navigate to SCR-06 or any protected route. Exits app (or goes to splash, then back to SCR-03). |
| SN-02 | After successful login, back does not return to SCR-03 | After routing to SCR-06, pressing back does not return to SCR-03 login. Back stack must exclude SCR-03 post-login. |
| SN-03 | Error state is inline, not modal | After wrong credentials, the error "Email or password is incorrect" appears inline on the screen without blocking navigation. Fields remain editable. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Auth flag set in memory on success | After one successful login, the in-memory app-lock flag is set to UNLOCKED exactly once. **No database write occurs on login** — the flag is runtime state only. *(Updated 2026-09-16 — design spec §3.5/§3.7 confirms in-memory flag, not persisted to the database.)* |
| DI-02 | Login failure does not mutate flag | After a failed login attempt, the in-memory auth flag remains LOCKED. No database write occurs. |
| DI-03 | Workout and plan data not touched by login | Existing workout plans and records in the database are unaffected by the login action. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | App-lock flag is set before navigation | After a correct login, the in-memory unlocked flag is set before navigation fires; app does not navigate to SCR-06 before the flag is set. |
| PR-02 | No loading state shown on submit | Tap Login with correct credentials. | No loading indicator appears — transition to SCR-06 is immediate (in-memory comparison, no database write on login). *(Resolved 2026-09-16 — loading state confirmed absent.)* |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Field labels announced | TalkBack/VoiceOver reads email and password field labels correctly. |
| AC-02 | Error message announced | When "Email or password is incorrect" appears, the screen reader announces it without requiring a focus change by the user. |
| AC-03 | Password field role | Password field is identified as a password-type field (assistive tech does not announce characters). |
| AC-04 | Submit button accessible | Submit button has a meaningful label; tappable without fine motor precision (min 44pt target). |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Credential not logged or printed | Login attempt (success or failure) does not write the password to device logs or crash reports. |
| SC-02 | No route bypass | Directly navigating (go_router) to SCR-06 while locked does not succeed without actually calling the login action. |
| SC-03 | Flag cannot be set by manipulating UI state | The auth flag is set only through the login bloc action, not by manipulating widget state. |

---

## 11. Regression Flags

- Any change to hardcoded credentials or `AppLockCubit` logic must re-run HP-01, NV-01–NV-03, DI-01–DI-02.
- Any change to go_router route guards must re-run SN-01, SN-02, SC-02.
- Any change to email-format validation must re-run NV-04, NV-07, NV-08 and resolve OQ-01.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| ~~OQ-01~~ | **Resolved 2026-09-16** — Non-empty-only applies. No format check. NV-08 updated accordingly. |
| ~~OQ-02~~ | **Resolved 2026-09-16** — Confirmed: "Email or password is incorrect" is the approved mismatch banner copy (design spec §3.4). NV-01–NV-03 can assert against this string. |
| ~~OQ-03~~ | **Resolved 2026-09-16** — No loading state. The credential comparison is a local in-memory string match (instantaneous); no database write occurs on login (flag is in-memory only per design spec §3.5/§3.7). PR-02 removed as a watch item. |
| OQ-04 | **No rate-limiting or lockout specified** — for a static local credential, no lockout after N failures is defined. QA cannot test for it; note as informational. |
