# Data Model: SCR-03 Login / Authenticate

**Feature**: `specs/001-scr-03-login/`  
**Date**: 2026-09-16  
**Layer**: Domain (no storage records — auth flag is in-memory)

---

## Entities

### 1. AppLockState

**Type**: Enum (Domain entity)  
**Location**: `lib/features/auth/domain/entities/app_lock_state.dart`  
**Persistence**: In-memory only — never written to the database.  
**Owner**: `AppLockCubit`

| Value | Meaning |
|-------|---------|
| `locked` | App requires login. SCR-03 is shown. All protected routes redirect here. Default state on app launch / after logout. |
| `unlocked` | User has logged in with valid credentials. SCR-06 and all other protected routes are accessible. |

**Transitions**:
```
locked  --[login with correct credentials]--> unlocked
unlocked --[logout action (SCR-26)]-----------> locked
```

**Spec reference**: FR-005, FR-009, QA DI-01, QA DI-02, Design §3.5/§3.7

---

### 2. DemoCredential

**Type**: Compile-time constants (Domain layer)  
**Location**: `lib/features/auth/domain/constants/demo_credentials.dart`  
**Persistence**: None — compile-time values baked into the binary.

| Constant | Value |
|----------|-------|
| `email` | `user@forge.app` |
| `password` | `Forge@123` |

**Usage**: Compared against trimmed user input in `AppLockCubit.login()`. Not logged (Principle X.2). Not stored in the database (Principle IV.3).

**Spec reference**: FR-003, FR-004, QA HP-01, Design §3.1

---

## Application State (Cubit States)

**Owner**: `AppLockCubit` in `lib/features/auth/application/cubit/app_lock_cubit.dart`

| State Class | Fields | Meaning |
|-------------|--------|---------|
| `AppLockLocked` | — | App is locked. Login screen shown. |
| `AppLockUnlocked` | — | Login succeeded. Home Dashboard accessible. |
| `AppLockLoginError` | `message: String` | Wrong credentials submitted. Error banner shown. |

**Notes**:
- `AppLockLoginError` is a transient state — it clears when the user types in either field (`clearError()` or equivalent method called from `onChanged`).
- `AppLockLocked` is the initial state of `AppLockCubit`.
- No database write occurs on any state transition.
- All state classes extend the sealed `AppLockState` base type and MUST be immutable (Principle II.1).

---

## What Is NOT in This Model

| Item | Why Excluded |
|------|-------------|
| Persisting the auth flag in a Drift table | Auth flag is in-memory only (FR-005, QA DI-01) |
| Session token / refresh token | No backend exists (Principle IV.1, FR-010) |
| User ID field | Single local user, no identity concept (Principle IV.1) |
| Login attempt counter / lockout | Not specified; POC has no rate-limiting (spec Assumptions §8) |
| Loading state | No async work — credential comparison is synchronous in-memory (FR-002, PR-02) |

---

## State Transition Diagram

```
App Launch
    │
    ▼
AppLockLocked (initial)
    │
    ├─[login(email, password) — credentials match]──────► AppLockUnlocked
    │                                                              │
    ├─[login(email, password) — credentials mismatch]──► AppLockLoginError
    │       │                                                      │
    │       └─[user types in either field]──────────────► AppLockLocked
    │
    └─[logout() called from SCR-26]◄──────────────────── AppLockUnlocked
```
