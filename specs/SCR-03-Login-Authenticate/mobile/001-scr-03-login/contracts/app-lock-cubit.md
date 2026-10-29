# Contract: AppLockCubit

**Feature**: `specs/001-scr-03-login/`  
**Layer**: Application  
**File**: `lib/features/auth/application/cubit/app_lock_cubit.dart`

---

## Purpose

Owns the app-lock state (locked/unlocked/error). Exposed via GetIt to `LoginScreen`, `LogoutScreen` (SCR-26), and go_router's redirect function. The sole authority for transitioning the app-lock state.

---

## States

All states are immutable, extend a sealed base class, and implement `Equatable`.

```dart
sealed class AppLockState extends Equatable {}

class AppLockLocked extends AppLockState {
  @override List<Object?> get props => [];
}

class AppLockUnlocked extends AppLockState {
  @override List<Object?> get props => [];
}

class AppLockLoginError extends AppLockState {
  final String message;
  const AppLockLoginError(this.message);
  @override List<Object?> get props => [message];
}
```

---

## Methods

### `login(String email, String password) → void`

Trims both fields. Compares against `DemoCredentials.email` / `DemoCredentials.password`.

- If both non-empty after trim AND match → emit `AppLockUnlocked`
- If both non-empty after trim AND mismatch → emit `AppLockLoginError("Email or password is incorrect")`
- Precondition: caller (LoginScreen) ensures both fields non-empty before calling; button is disabled otherwise.

**Side effects**: None. No database write. No network call.

### `clearError() → void`

If current state is `AppLockLoginError`, emits `AppLockLocked`.  
Called by `LoginScreen.onChanged` for either field when error is visible.

### `logout() → void`

Emits `AppLockLocked`. Called from SCR-26 Confirm Logout. No Drift data is cleared.

---

## Initial State

`AppLockLocked()` — app starts locked on every launch.

---

## go_router Integration

`AppLockCubit` is registered in GetIt. The router's `refreshListenable` wraps its `Stream<AppLockState>`:

```dart
refreshListenable: GoRouterRefreshStream(getIt<AppLockCubit>().stream)
```

Redirect logic (in `lib/config/routes/app_router.dart`):
- If `AppLockLocked || AppLockLoginError` AND not on `/login` → redirect to `/login`
- If `AppLockUnlocked` AND on `/login` → redirect to `/home`
- Otherwise → no redirect

---

## Constraints

- MUST NOT write to the database.
- MUST NOT make a network call.
- Password value MUST NOT appear in log output.
- Credential constants are accessed from `DemoCredentials` (domain layer), not hardcoded inline.
