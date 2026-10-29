# Contract: LoginScreen (SCR-03)

**Feature**: `specs/001-scr-03-login/`  
**Layer**: Presentation  
**File**: `lib/features/auth/presentation/screens/login_screen.dart`

---

## Purpose

The sole entry point for the locked state of the app. Collects email and password, validates emptiness, submits credentials to `AppLockCubit`, and reflects the result (navigation to SCR-06 or error banner).

---

## Widget Type

`StatefulWidget` — required for local UI state (button enabled flag, password obscure flag, TextEditingControllers).

---

## Dependencies (injected via GetIt)

| Dependency | Type | Usage |
|------------|------|-------|
| `AppLockCubit` | Application Cubit | Wrapped in `BlocProvider.value`; provides state stream and login/clearError methods |

---

## Local State

| Variable | Type | Initial Value | Purpose |
|----------|------|---------------|---------|
| `_emailController` | `TextEditingController` | empty | Email field text |
| `_passwordController` | `TextEditingController` | empty | Password field text |
| `_obscurePassword` | `bool` | `true` | Password masking |
| `_isButtonEnabled` | `bool` | `false` | Login button enabled/disabled |

`_isButtonEnabled` is recomputed on every `onChanged` event:
```dart
_isButtonEnabled = _emailController.text.trim().isNotEmpty
    && _passwordController.text.trim().isNotEmpty;
```

---

## UI States (driven by AppLockState)

| AppLockState | UI rendering |
|-------------|-------------|
| `AppLockLocked` | Default: fields editable, error banner hidden, button enabled/disabled per local flag |
| `AppLockLoginError` | Error banner "Email or password is incorrect" visible above button |
| `AppLockUnlocked` | go_router redirect fires → screen is replaced by SCR-06 (no manual navigation in widget) |

---

## Interaction Contract

| User Action | Widget Behaviour | Cubit Call |
|-------------|-----------------|------------|
| Type in email field | `setState` updates `_isButtonEnabled`; if error visible, `clearError()` | `clearError()` if error state |
| Type in password field | same as email | `clearError()` if error state |
| Tap eye icon | `setState` toggles `_obscurePassword` | none |
| Tap Login (enabled) | calls `login(trimmedEmail, trimmedPassword)` | `login()` |
| Tap Login (disabled) | no-op (button is not tappable) | none |

---

## Navigation

- `LoginScreen` does NOT call `context.go()` or `GoRouter.of(context).go()`.
- Navigation to SCR-06 is handled entirely by the go_router `redirect` callback reacting to `AppLockUnlocked`.
- `LoginScreen` MUST NOT appear in the back stack after unlock (go_router `redirect` removes it).

---

## Screen Structure (layout contract)

```
Column
├── Heading: "Welcome back"
├── Subtitle: "Sign in to continue"
├── Email TextField
│     label: "Email"
│     keyboardType: emailAddress
│     autocorrect: false
│     textInputAction: TextInputAction.next
├── Password TextField
│     label: "Password"
│     obscureText: _obscurePassword
│     suffixIcon: eye IconButton
│     textInputAction: TextInputAction.done
├── [Conditional] Error banner: "Email or password is incorrect"
│     visible when state is AppLockLoginError
└── Login ElevatedButton
      enabled: _isButtonEnabled
      label: "Sign In"
```

---

## Constraints

- Fields MUST be empty on initial open (no pre-fill).
- Error message text MUST match exactly: `"Email or password is incorrect"` (FR-006, QA NV-01–03).
- Button MUST be disabled on screen open (both fields empty).
- Password field MUST be masked by default.
- Show/hide toggle MUST NOT change field value or cursor position.
- Screen MUST follow the single dark theme (Principle VIII.5); no hardcoded hex colors.
- Minimum tap target: 44pt for interactive elements (Principle VIII.4).
