# QA Specification — SCR-01: Splash / Auth Check

**Story ID:** US-SCR01  
**Feature:** Splash / Auth Check  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-01-Splash-AuthCheck.md` + constitution

---

## 1. Purpose & Scope

Verify that the splash screen correctly reads the local login-state flag, routes to the appropriate screen (SCR-06 if unlocked, SCR-03 if locked), and shows itself only during the check. There is no network call, no authentication service, and no connectivity case. The only credential check is a local flag comparison.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15, phone form factors only.
- **State baseline:** Drift is the sole persistence layer. No backend, no network, no REST client.
- **Login flag states under test:** `locked` (flag absent or false) and `unlocked` (flag true).
- **Test isolation:** Clear app data / reinstall between locked-state tests to guarantee flag is absent.
- **DI:** GetIt must be fully initialised before splash renders; verify no service-locator exceptions surface.
- **Bloc:** `AppLockCubit` (or equivalent) drives the routing decision; state must settle before navigation fires.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Unlocked → routed to Home | Set login flag = unlocked. Launch app. | Splash displays briefly; app navigates to SCR-06 Home Dashboard without user interaction. |
| HP-02 | Locked → routed to Login | Ensure login flag = locked (fresh install or cleared data). Launch app. | Splash displays briefly; app navigates to SCR-03 Login Authenticate. |
| HP-03 | Splash is transient | Launch app in either state. | Splash is not an interactive screen; no buttons visible; disappears once routing is complete. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Local read failure during auth check | Force the auth-flag read to fail before launch (e.g., stub the local state source to throw). | App does not crash. Either falls back to locked route (safe default) or shows a recoverable error. Does NOT silently route to SCR-06 as if unlocked. |
| NV-02 | Empty / null auth-flag value | Write null or absent entry to the auth flag key. Launch. | Treated as locked; routes to SCR-03. Does not crash. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Rapid back-press during splash | User presses back immediately after launch on Android. | Splash handles back correctly (either exits app or ignores; does not navigate to a ghost state). *[QA-derived — not in story]* |
| EC-02 | App killed and relaunched multiple times | Repeatedly kill and relaunch in both flag states. | Auth check is re-evaluated on each launch from the stored flag value; no stale in-memory state persists. *[QA-derived]* |
| EC-03 | GetIt not ready at splash render | Simulate slow DI init (e.g., inject artificial delay in GetIt setup). | Splash waits for DI to complete before reading auth flag; does not read local state before GetIt is ready. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | No back stack entry for splash | After routing to SCR-06 or SCR-03, pressing back must NOT return to splash. go_router back stack must exclude the splash route. |
| SN-02 | Deep-link at launch | If the app is opened via a deep link while locked, splash still evaluates the auth flag first; deep-link is deferred until unlock. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Auth flag not mutated by splash | After splash routes to either screen, read the auth flag again. It must not have changed — splash is read-only. |
| DI-02 | Workout data unaffected by splash cycle | Existing workout data (plans, records) is not touched during the splash auth check. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Splash duration bounded | Splash must not remain visible indefinitely. If the local read hangs for >3 s (no SRS-NFR defined — flag for SRS/SDS owner), the app should surface a failure or fallback, not freeze. *[QA-derived — threshold TBC]* |
| PR-02 | Cold-start on low-end device | On API 29 Android with minimal RAM, splash auth check completes and navigates without ANR. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Screen-reader announcement | TalkBack/VoiceOver announces the splash state (app name or loading status). No silent blank screen. |
| AC-02 | No interactive elements on splash | Accessibility tree contains no tappable controls on the splash screen. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Cannot bypass auth check by navigating directly | Attempt to push SCR-06 route directly (e.g., via deep link or test navigation). If flag is locked, app redirects to SCR-03 or splash; SCR-06 is not accessible. |
| SC-02 | Locked flag is always re-read | After logout (SCR-26 sets flag to locked), relaunching routes to SCR-03, not SCR-06, even if in-memory state says unlocked. |

---

## 11. Regression Flags

- Any change to `AppLockCubit` or table names for the auth flag must re-run HP-01, HP-02, SN-01, SC-01, SC-02.
- Any change to go_router route configuration must re-run SN-01 (no back stack to splash).
- Any change to GetIt registration order must re-run EC-03.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Local read failure fallback not specified** — FR-6 specifies an inline error "Email or password is incorrect" for login, but SCR-01 has no specified error path for a local read failure during the auth check. NV-01 assumes locked fallback; confirm with SRS/SDS owner. |
| OQ-02 | **Splash duration timeout** — no SRS-NFR defines maximum splash duration. PR-01 threshold TBC. |
| OQ-03 | **Deep-link handling at launch** — SN-02 is QA-derived; confirm expected behaviour with product owner. |
