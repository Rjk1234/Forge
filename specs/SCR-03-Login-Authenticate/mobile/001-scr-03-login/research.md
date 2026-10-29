# Research: SCR-03 Login / Authenticate

**Feature**: `specs/001-scr-03-login/`  
**Date**: 2026-09-16  
**Branch**: `001-scr-03-login`

---

## 1. AppLockCubit: Cubit vs. Bloc Decision

**Decision**: Implement auth state as `AppLockCubit` (Cubit), not as a full Bloc with events.

**Rationale**:  
The constitution (Principle II.1) states "`Cubit` MUST NOT be introduced", but `AppLockCubit` is an established entity across all ForgeApp specs, the SDS, and the QA/design spec for SCR-03. Every downstream screen (SCR-06, SCR-26 Logout) references it by name. Renaming to `AppLockBloc` would require revising all specs and would add event-dispatch boilerplate for a two-state flag with only two transitions (login → unlock, logout → lock). Given that this is the only Cubit in ForgeApp, and the auth state carries no complex event sequencing, this is treated as a justified pre-existing exception documented in the Complexity Tracking section of plan.md.

**Alternatives considered**:
- `AppLockBloc` with `LoginRequested` / `LogoutRequested` events — rejected: all specs already say Cubit; would require multi-spec revision with no behavioral benefit.
- `ValueNotifier<AppLockState>` — rejected: outside governed `flutter_bloc` mechanism.

---

## 2. Static Demo Credential Storage

**Decision**: Store the demo credential as compile-time `const` String values directly inside `AppLockCubit` (or a sibling `DemoCredentials` constants file in the `domain/` layer).

**Rationale**:  
The constitution (Principle IV.3) states the credential is "not a real secret and MUST NOT be stored or handled as if it were one." There is no secure-storage ADR (ADR removed as not applicable). Compile-time constants are the simplest compliant option — they are visible in source, not in logs (Principle X.2), and not in the database.

**Alternatives considered**:
- `flutter_secure_storage` — rejected: not in governed dependency set (ADR-030).
- Drift persistence of credential — rejected: credential is fixed/hardcoded, not user-managed; persisting it adds complexity without benefit.

---

## 3. Auth Flag Persistence

**Decision**: The `AppLockState` (locked/unlocked) is **in-memory only**. It is NOT written to the database on login.

**Rationale**:  
The spec (FR-005, DI-01) and design spec (§3.5, §3.7) confirm: the flag is runtime state only. On app restart the flag resets to `locked` (the default Cubit state), which correctly requires re-login — consistent with the SDS app-lock model. Writing a boolean to the database would add read-at-boot complexity for no user benefit in a POC.

**Alternatives considered**:
- Persist the flag to the database → rejected: spec explicitly says in-memory; QA DI-01 confirms "no database write on login".

---

## 4. go_router Route Guard (App-Lock Redirect)

**Decision**: Use go_router's `redirect` callback at the router level. The redirect reads `AppLockCubit` state from GetIt and redirects any protected route to `/login` (SCR-03) when locked, and prevents `/login` from being reached when unlocked (redirects to `/home`).

**Rationale**:  
Constitution Principle III.1 requires all navigation through centralized go_router config. Principle III.2 states "The only guard is the app-lock guard." go_router's `refreshListenable` with the Cubit's `Stream<AppLockState>` triggers route re-evaluation automatically on state change — no manual `context.go()` calls needed in business logic (Principle I.2: "Data, Domain, and use cases MUST NOT navigate").

**Pattern**:
```
GoRouter(
  refreshListenable: GoRouterRefreshStream(appLockCubit.stream),
  redirect: (context, state) {
    final locked = appLockCubit.state == AppLockState.locked;
    final onLogin = state.matchedLocation == '/login';
    if (locked && !onLogin) return '/login';
    if (!locked && onLogin) return '/home';
    return null;
  },
  ...
)
```

**Alternatives considered**:
- `ShellRoute` with guard — rejected: over-engineered for a single flag.
- Manual `context.go('/login')` in logout handler — allowed as the only callsite, but the redirect ensures correctness even without it.

---

## 5. Button Enable/Disable Live Evaluation

**Decision**: Evaluate trim-empty check on every `onChanged` event for both fields. The enabled state is derived from the Cubit/Bloc state (not local widget state) using a `BlocBuilder`. Alternatively, use local `StatefulWidget` state for the button flag since this is purely a UI concern with no domain logic.

**Rationale**:  
FR-008 requires live per-keystroke evaluation. Using a `StatefulWidget` with `_emailController` and `_passwordController` TextEditingControllers and `addListener` callbacks is the Flutter-idiomatic approach for synchronous button-state control without bloc overhead. The credential comparison itself still goes through `AppLockCubit`.

**Decision (adopted)**: `LoginScreen` is a `StatefulWidget`. Button enabled state is local to the widget. `AppLockCubit` is used only for the login action and for rendering the error banner.

**Alternatives considered**:
- Putting button state in Cubit — rejected: button enable is a pure UI concern; putting it in the Cubit couples presentation to domain.

---

## 6. Password Show/Hide Toggle

**Decision**: Use Flutter's `TextField` with `obscureText` bound to a `bool _obscurePassword` local state variable. Toggle on `IconButton` (eye icon) press.

**Rationale**:  
FR-011 requires the toggle. This is a pure UI widget concern — no domain logic, no bloc event. Local state in `StatefulWidget` is the correct level.

**Pattern**:
```dart
TextField(
  controller: _passwordController,
  obscureText: _obscurePassword,
  decoration: InputDecoration(
    suffixIcon: IconButton(
      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
    ),
  ),
)
```

---

## 7. Wrong-Credentials Error Banner Dismissal

**Decision**: The error banner ("Email or password is incorrect") clears when the user types any character in either field. This is implemented by emitting a `clearError` or equivalent state from `AppLockCubit` on `onChanged`, OR by deriving the error visibility from a local flag that resets on `onChanged`.

**Decision (adopted)**: AppLockCubit emits a distinct state (e.g., `AppLockState.error`) on wrong credentials. `LoginScreen` clears the error by calling `appLockCubit.clearError()` (or equivalent) in the `onChanged` callback of both fields.

**Rationale**:  
FR-006 requires the error to clear on first keystroke. Keeping error state in the Cubit (not local widget state) ensures the error is properly owned by application logic — the presentation layer reads it, the application layer owns it.

---

## 8. Clean Architecture Layer Assignment

| Concern | Layer | Location |
|---------|-------|----------|
| AppLockState (enum) | Domain | `lib/features/auth/domain/entities/app_lock_state.dart` |
| DemoCredential (constants) | Domain | `lib/features/auth/domain/constants/demo_credentials.dart` |
| AppLockCubit | Application | `lib/features/auth/application/cubit/app_lock_cubit.dart` |
| LoginScreen | Presentation | `lib/features/auth/presentation/screens/login_screen.dart` |
| Login widgets | Presentation | `lib/features/auth/presentation/widgets/` |
| Auth route constants | Config | `lib/config/routes/app_routes.dart` (existing or created) |
| go_router redirect | Config | `lib/config/routes/app_router.dart` (existing or created) |

No Data layer is needed: auth flag is in-memory; credential is a compile-time constant.
