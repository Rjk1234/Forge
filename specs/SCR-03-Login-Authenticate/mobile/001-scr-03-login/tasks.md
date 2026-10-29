# Tasks: SCR-03 Login / Authenticate

**Input**: Design documents from `specs/001-scr-03-login/`

**Feature**: Static local login screen — in-memory credential check, go_router app-lock guard, no database writes, no network.

**Tech stack**: Flutter / flutter_bloc / GetIt / go_router (see [plan.md](plan.md))  
**Entities**: `AppLockState`, `DemoCredentials` (see [data-model.md](data-model.md))  
**Contracts**: [AppLockCubit](contracts/app-lock-cubit.md), [LoginScreen](contracts/login-screen.md)  
**Validation**: [quickstart.md](quickstart.md)

---

## Phase 1: Setup

**Purpose**: Create the `auth` feature directory structure. No logic yet — just the scaffolding that all subsequent tasks write into.

- [X] T001 Create auth feature directory tree: `lib/features/auth/{domain/entities,domain/constants,application/cubit,presentation/screens,presentation/widgets}` and `test/features/auth/{application/cubit,presentation/screens}`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, compile-time credentials, Cubit skeleton, GetIt registration, and go_router route + guard. ALL user story work blocks on this phase.

**⚠️ CRITICAL**: No user story implementation can begin until this phase is complete.

- [X] T002 Create `AppLockState` sealed class with `AppLockLocked`, `AppLockUnlocked`, `AppLockLoginError(message)` states in `lib/features/auth/domain/entities/app_lock_state.dart`
- [X] T003 [P] Create `DemoCredentials` const class (`email: "user@forge.app"`, `password: "Forge@123"`) in `lib/features/auth/domain/constants/demo_credentials.dart`
- [X] T004 Create `AppLockCubit` skeleton extending `Cubit<AppLockState>` with initial state `AppLockLocked()` and stub methods `login()`, `clearError()`, `logout()` in `lib/features/auth/application/cubit/app_lock_cubit.dart`
- [X] T005 Register `AppLockCubit` as a lazySingleton in GetIt in `lib/app/di/service_locator.dart` (or the project's DI registration file)
- [X] T006 [P] Add `/login` route name and path constants in `lib/config/routes/app_routes.dart`
- [X] T007 Wire go_router `refreshListenable: GoRouterRefreshStream(appLockCubit.stream)` and `redirect` callback (locked → `/login`; unlocked on `/login` → `/home`) in `lib/config/routes/app_router.dart`

**Checkpoint**: `flutter analyze` passes. App launches and go_router redirect sends to `/login` (screen not yet built — expect a 404/error page, not a crash).

---

## Phase 3: User Story 1 — Successful Login (P1) 🎯 MVP

**Goal**: A user with the correct demo credentials taps Sign In and reaches SCR-06 instantly.

**Independent Test**: Launch app → type `user@forge.app` / `Forge@123` → tap Sign In → confirm SCR-06 appears and back does not return to login. See [quickstart.md VS-01](quickstart.md).

### Tests — User Story 1

- [X] T008 [P] [US1] Write `bloc_test` unit test: initial state is `AppLockLocked` in `test/features/auth/application/cubit/app_lock_cubit_test.dart`
- [X] T009 [P] [US1] Write `bloc_test` unit test: `login("user@forge.app", "Forge@123")` emits `[AppLockUnlocked]` in `test/features/auth/application/cubit/app_lock_cubit_test.dart`
- [X] T010 [P] [US1] Write widget test: correct credentials → BlocListener receives `AppLockUnlocked` (navigation side effect mocked) in `test/features/auth/presentation/screens/login_screen_test.dart`

### Implementation — User Story 1

- [X] T011 [US1] Implement `login(String email, String password)` in `AppLockCubit`: trim fields, compare against `DemoCredentials`, emit `AppLockUnlocked` on match in `lib/features/auth/application/cubit/app_lock_cubit.dart`
- [X] T012 [US1] Create `LoginScreen` `StatefulWidget` with: heading "Welcome back", subtitle "Sign in to continue", email `TextField`, password `TextField` with eye-icon toggle (`_obscurePassword`), and a "Sign In" `ElevatedButton` (always enabled at this phase); use `Theme.of(context)` tokens only — no hardcoded hex in `lib/features/auth/presentation/screens/login_screen.dart`
- [X] T013 [US1] Wrap `LoginScreen` in `BlocProvider.value(appLockCubit)` and add `BlocListener` that reacts to `AppLockUnlocked` (go_router redirect fires automatically; no manual `context.go()` needed) in `lib/features/auth/presentation/screens/login_screen.dart`
- [X] T014 [US1] Register `/login` route pointing to `LoginScreen` in go_router routes list in `lib/config/routes/app_router.dart`
- [X] T015 [US1] Run `flutter test test/features/auth/application/cubit/app_lock_cubit_test.dart` — T008 and T009 MUST pass

**Checkpoint**: Launch app → enter correct credentials → reaches SCR-06. Back does not return to login. VS-01 passes.

---

## Phase 4: User Story 2 — Wrong Credentials Error (P1)

**Goal**: A user with wrong credentials sees the error banner "Email or password is incorrect" and it clears on the next keystroke.

**Independent Test**: Enter wrong password → tap Sign In → confirm error banner → type any character → confirm banner disappears. See [quickstart.md VS-02](quickstart.md).

### Tests — User Story 2

- [X] T016 [P] [US2] Write `bloc_test` unit test: `login("user@forge.app", "WrongPass")` emits `[AppLockLoginError("Email or password is incorrect")]` in `test/features/auth/application/cubit/app_lock_cubit_test.dart`
- [X] T017 [P] [US2] Write `bloc_test` unit test: `clearError()` when state is `AppLockLoginError` emits `[AppLockLocked]` in `test/features/auth/application/cubit/app_lock_cubit_test.dart`
- [X] T018 [P] [US2] Write widget test: wrong credentials → error banner with text "Email or password is incorrect" visible in `test/features/auth/presentation/screens/login_screen_test.dart`
- [X] T019 [P] [US2] Write widget test: when error visible, typing in email field → error banner disappears in `test/features/auth/presentation/screens/login_screen_test.dart`

### Implementation — User Story 2

- [X] T020 [US2] Implement mismatch path in `login()`: emit `AppLockLoginError("Email or password is incorrect")` when trimmed fields are non-empty but credentials do not match in `lib/features/auth/application/cubit/app_lock_cubit.dart`
- [X] T021 [US2] Implement `clearError()`: if current state is `AppLockLoginError`, emit `AppLockLocked` in `lib/features/auth/application/cubit/app_lock_cubit.dart`
- [X] T022 [P] [US2] Create `LoginErrorBanner` widget that renders the error message string inside a styled container in `lib/features/auth/presentation/widgets/login_error_banner.dart`
- [X] T023 [US2] Add `BlocBuilder` to `LoginScreen` that shows `LoginErrorBanner` when state is `AppLockLoginError`; add `clearError()` call in `onChanged` for both TextField controllers in `lib/features/auth/presentation/screens/login_screen.dart`
- [X] T024 [US2] Run `flutter test test/features/auth/` — T016, T017, T018, T019 MUST pass

**Checkpoint**: Wrong password → error banner. Type a character → banner gone. Correct password after error → SCR-06. VS-02 passes.

---

## Phase 5: User Story 3 — Button Disable Guard (P2)

**Goal**: The Login button is disabled while either field is empty after trimming; it enables live as the user types.

**Independent Test**: Open app → confirm button disabled → type spaces-only in both fields → confirm still disabled → type real content in each field → confirm button enables. See [quickstart.md VS-03](quickstart.md).

### Tests — User Story 3

- [X] T025 [P] [US3] Write widget test: on screen open, Login button is disabled in `test/features/auth/presentation/screens/login_screen_test.dart`
- [X] T026 [P] [US3] Write widget test: email empty, password non-empty → button disabled in `test/features/auth/presentation/screens/login_screen_test.dart`
- [X] T027 [P] [US3] Write widget test: email whitespace-only (`"   "`), password non-empty → button disabled in `test/features/auth/presentation/screens/login_screen_test.dart`
- [X] T028 [P] [US3] Write widget test: both fields non-empty after trim → button enabled in `test/features/auth/presentation/screens/login_screen_test.dart`

### Implementation — User Story 3

- [X] T029 [US3] Add `_isButtonEnabled` local bool (initial `false`) and `_updateButtonState()` helper (`trim().isNotEmpty` on both controllers) to `LoginScreen`; call `_updateButtonState()` inside both `onChanged` callbacks in `lib/features/auth/presentation/screens/login_screen.dart`
- [X] T030 [US3] Bind `ElevatedButton.onPressed` to `null` when `!_isButtonEnabled` (disables the button) in `lib/features/auth/presentation/screens/login_screen.dart`
- [X] T031 [US3] Run `flutter test test/features/auth/presentation/screens/login_screen_test.dart` — T025, T026, T027, T028 MUST pass

**Checkpoint**: All three user stories functional. Run VS-01 through VS-05 in quickstart.md.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Accessibility, security constraints, route guard verification, and final validation.

- [X] T032 [P] Verify password show/hide toggle (eye icon): `_obscurePassword` initial `true`; toggles on press; field value and cursor position unchanged — manually validate VS-04 from [quickstart.md](quickstart.md) in `lib/features/auth/presentation/screens/login_screen.dart`
- [X] T033 [P] Write widget test: EC-02 password toggle — obscureText starts true, toggles to false on eye tap, back to true on second tap in `test/features/auth/presentation/screens/login_screen_test.dart`
- [X] T034 [P] Verify back-stack exclusion: after login, system back does not return to SCR-03 — confirm go_router does not include `/login` in the history stack for the unlocked state (SN-01/SN-02 in QA spec)
- [X] T035 [P] Verify no credential in logs: confirm `login()` does not call `print`/`debugPrint` with the password value (SC-01 in QA spec); add log-gate comment if needed in `lib/features/auth/application/cubit/app_lock_cubit.dart`
- [X] T036 Run full test suite: `flutter test` — all tests pass; check Application layer coverage ≥ 80%
- [X] T037 Run `flutter analyze` — zero analysis issues
- [X] T038 Manual validation: run all VS-01 through VS-06 scenarios from [quickstart.md](quickstart.md)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — **BLOCKS Phases 3, 4, 5**
- **Phase 3 (US-1)**: Depends on Phase 2 — no dependency on US-2 or US-3
- **Phase 4 (US-2)**: Depends on Phase 2 + Phase 3 complete (error path needs `login()` base)
- **Phase 5 (US-3)**: Depends on Phase 2 + Phase 3 (button sits on the same screen)
- **Phase 6 (Polish)**: Depends on Phases 3, 4, 5 complete

### User Story Dependencies

- **US-1 (P1)**: Foundational only. 🎯 Minimum viable feature.
- **US-2 (P1)**: US-1 complete (same `login()` method, adds mismatch branch).
- **US-3 (P2)**: US-1 complete (same `LoginScreen`, adds button-state local logic).
- US-2 and US-3 are **independent of each other** and can proceed in parallel after US-1.

### Within Each User Story

1. Write tests first (they MUST fail before implementation)
2. Domain / Cubit logic before Presentation
3. Story complete and tested before moving to next

### Parallel Opportunities

| Tasks | Parallelizable because |
|-------|----------------------|
| T002 + T003 | Different files, no dependency |
| T006 + T003 | Different files, no dependency |
| T008 + T009 + T010 | Different test cases, same file is safe to write independently |
| T016 + T017 + T018 + T019 | Different test cases |
| T025 + T026 + T027 + T028 | Different test cases |
| T022 + T023 | Widget creation vs screen integration |

---

## Parallel Example: User Story 1

```
# Tests (write together, all MUST fail first):
T008 — cubit initial state test
T009 — cubit login success test
T010 — widget test: BlocListener on AppLockUnlocked

# Then implementation in order:
T011 — login() success path in cubit
T012 — LoginScreen skeleton
T013 — BlocProvider + BlocListener wiring
T014 — /login route registration
T015 — run flutter test (T008, T009 pass)
```

---

## Implementation Strategy

### MVP: User Story 1 Only

1. Complete Phase 1 + Phase 2
2. Complete Phase 3 (US-1)
3. Validate: VS-01 from quickstart.md
4. Feature is minimally functional — user can log in

### Incremental Delivery

1. Phase 1 + 2 → Foundation ready
2. Phase 3 (US-1) → Happy-path login works. Test VS-01.
3. Phase 4 (US-2) → Error handling works. Test VS-02.
4. Phase 5 (US-3) → Button guard works. Test VS-03 + VS-05.
5. Phase 6 → Polish, full validation suite VS-01–VS-06.

---

## Notes

- `[P]` = parallelizable (different files, no inter-task dependency)
- `[USn]` = belongs to User Story n (maps to spec.md user stories)
- Tests MUST be written before implementation and MUST fail first
- No database writes anywhere in this feature (DI-01, research decision 3)
- No `context.go()` in `AppLockCubit` — navigation is entirely via go_router redirect (Principle I.2)
- Password MUST NOT appear in any log output (Principle X.2, SC-01)
- All colors via `Theme.of(context)` tokens — no hardcoded hex (Principle VIII.5)

**Total tasks**: 38  
**By story**: Setup=1, Foundational=6, US-1=8, US-2=9, US-3=7, Polish=7  
**Parallel opportunities**: 19 tasks marked [P]  
**MVP scope**: Phases 1–3 (T001–T015) = 15 tasks
