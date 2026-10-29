# Quickstart Validation Guide: SCR-03 Login / Authenticate

**Feature**: `specs/001-scr-03-login/`  
**Date**: 2026-09-16  
**Purpose**: Manual and automated validation scenarios proving the feature works end-to-end.

---

## Prerequisites

1. Flutter SDK installed via FVM, latest stable.
2. Project dependencies installed: `flutter pub get`
3. App is buildable: `flutter build apk --debug` (Android) or `flutter build ios --debug` (iOS).
4. Simulator/emulator running (Android 10+ / iOS 15+).

No schema or seed step is needed for the auth feature — login state is in-memory only.

---

## Running the App

```bash
flutter run
```

The app launches in locked state and shows SCR-03 (Login screen). No network required.

---

## Running Tests

```bash
# Unit + cubit tests
flutter test test/features/auth/

# All tests
flutter test
```

---

## Validation Scenarios

### VS-01 — Happy Path: Correct Credentials (US-1)

**Goal**: Verify the user can log in with demo credentials and reach SCR-06.

| Step | Action | Expected |
|------|--------|----------|
| 1 | Launch app (cold start) | SCR-03 shown; both fields empty; Login button disabled |
| 2 | Tap Email field, type `user@forge.app` | Button still disabled (password empty) |
| 3 | Tap Password field, type `Forge@123` | Button enables |
| 4 | Tap "Sign In" | App navigates to SCR-06 Home Dashboard; no loading spinner; no error banner |
| 5 | Press system back | Back does NOT return to SCR-03 |

**Pass criteria**: Reaches SCR-06 in < 2 seconds from tap (SC-001). Back stack excludes SCR-03.

---

### VS-02 — Wrong Credentials (US-2)

**Goal**: Verify the mismatch error appears and clears correctly.

| Step | Action | Expected |
|------|--------|----------|
| 1 | Launch app | SCR-03 shown; button disabled |
| 2 | Enter `user@forge.app` / `WrongPass` | Button enables |
| 3 | Tap "Sign In" | Stays on SCR-03; error banner "Email or password is incorrect" appears |
| 4 | Type any character in the Password field | Error banner disappears immediately |
| 5 | Clear and re-enter `Forge@123`; tap "Sign In" | Navigates to SCR-06; no error visible |

**Pass criteria**: 100% of mismatched submissions show the error and do not navigate (SC-002).

---

### VS-03 — Button Disable Guard (US-3)

**Goal**: Verify the Login button stays disabled when fields are empty or whitespace-only.

| Step | Action | Expected |
|------|--------|----------|
| 1 | Launch app | Button disabled |
| 2 | Type `   ` (spaces) into email; `Forge@123` into password | Button stays disabled |
| 3 | Type `user@forge.app` into email (replacing spaces); password still `Forge@123` | Button enables |
| 4 | Clear password field | Button disables again |
| 5 | Type one character into password | Button enables |

**Pass criteria**: No submission is possible while either field is empty after trim (SC-003).

---

### VS-04 — Password Show/Hide Toggle

**Goal**: Verify the eye icon toggles masking without changing the field value.

| Step | Action | Expected |
|------|--------|----------|
| 1 | Type a password into the password field | Characters are masked (dots) |
| 2 | Tap the eye icon | Characters are revealed as plain text |
| 3 | Tap the eye icon again | Characters are re-masked |
| 4 | Tap "Sign In" with correct credentials | Login still succeeds (value unchanged) |

**Pass criteria**: FR-011 — toggling does not alter field value or cursor position.

---

### VS-05 — Route Guard: No Bypass

**Goal**: Verify protected routes cannot be reached while locked.

| Step | Action | Expected |
|------|--------|----------|
| 1 | Launch app (locked) | SCR-03 shown |
| 2 | Programmatically attempt to navigate to `/home` (via test driver or deep link) | Redirect fires; SCR-03 shown instead |

**Pass criteria**: SC-004 — zero authenticated screens reachable while locked.

---

### VS-06 — Whitespace Trimming (Edge Case)

**Goal**: Verify trim is applied before comparison.

| Step | Action | Expected |
|------|--------|----------|
| 1 | Enter `  user@forge.app  ` (with spaces) and `  Forge@123  ` (with spaces) | Button enables (non-empty content) |
| 2 | Tap "Sign In" | Credentials match after trim → navigates to SCR-06 |

**Pass criteria**: FR-004 — trimming applied; leading/trailing spaces do not cause a mismatch.

---

## Automated Test Targets

See [data-model.md](data-model.md) for state definitions and [contracts/app-lock-cubit.md](contracts/app-lock-cubit.md) for cubit contract.

| Test File | What It Covers |
|-----------|---------------|
| `test/features/auth/application/cubit/app_lock_cubit_test.dart` | All cubit states: login success, login error, clearError, logout, initial state |
| `test/features/auth/presentation/screens/login_screen_test.dart` | Button enable/disable, error banner visibility, password toggle, field empty states |

---

## Known Non-Scope Items

- Biometric login — out of scope (spec Assumptions).
- Rate-limiting / lockout after N failures — not specified (QA OQ-04 informational).
- Loading indicator — no loading state (PR-02, research decision 3).
