# Tasks: SCR-25 Profile / Account

**Input**: Design documents from `specs/SCR-25-Profile-Account/mobile/001-scr-25-profile-account/`

**Prerequisites**: [plan.md](plan.md) · [spec.md](spec.md) · [data-model.md](data-model.md) · [contracts/profile-bloc.md](contracts/profile-bloc.md) · [research.md](research.md) · [quickstart.md](quickstart.md)

**Tests**: Included — required by Constitution XI (Domain 90%+, Application 80%+; unit tests MUST cover use cases, mappers, and all Bloc state transitions using `bloc_test` and `mocktail`).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on each other)
- **[Story]**: Which user story this task belongs to (US1–US5)
- Exact file paths are given in every description

## Path Conventions

All source code lives under `forge/` (the Flutter app module). Tests mirror source under `forge/test/`.

---

## Phase 1: Setup (Global Tokens & Strings)

**Purpose**: Add the two new AppColors tokens and 23 AppStrings constants that all subsequent feature files depend on. Must be complete before any feature file is written.

- [X] T00 Add `successFill` (`Color(0xFF1E2A12)`) and `successBorder` (`Color(0xFF4A5C22)`) tokens to `forge/lib/core/theme/app_colors.dart`
- [X] T00 Add 23 `profile*` string constants (screen title, field labels, hints, button labels, toast, error titles/bodies, fitness goal options) to `forge/lib/core/strings/app_strings.dart`

**Checkpoint**: T001 and T002 complete; `flutter analyze` passes with zero new errors.

---

## Phase 2: Foundational (Domain → Data → Application → DI → Route)

**Purpose**: Core infrastructure — domain entity, repository contract, mapper, repository impl, Bloc events/states/use cases/bloc, DI registration, route registration, and all unit tests. MUST be complete before any user story phase begins.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Domain Layer

- [X] T00 Create `UserProfile` pure-Dart domain entity (5 fields: displayName, fitnessGoal, experienceLevel, heightCm, weightKg; all non-nullable; no Drift/Flutter imports) in `forge/lib/features/profile/domain/entities/user_profile.dart`
- [X] T00 Create `ProfileRepository` abstract interface (`getProfile() → Either<AppException, UserProfile?>`, `saveProfile(UserProfile) → Either<AppException, void>`) in `forge/lib/features/profile/domain/repositories/profile_repository.dart`

### Data Layer

- [X] T00 [P] Create `UserProfileMapper` with `static fromRecord(UserProfileRecord)` and `static toRecord(UserProfile, {DateTime? existingCreatedAt})` in `forge/lib/features/profile/data/mappers/user_profile_mapper.dart`
- [X] T00 Create `ProfileRepositoryImpl` implementing `ProfileRepository` using `ProfileLocalDataSource` and `UserProfileMapper`; wrap all Drift exceptions in `AppException` in `forge/lib/features/profile/data/repositories/profile_repository_impl.dart`

### Application Layer

- [X] T00 [P] Create `ProfileEvent` sealed class hierarchy (`ProfileLoadRequested`, `ProfileSaveRequested({required UserProfile profile})`) in `forge/lib/features/profile/application/bloc/profile_event.dart`
- [X] T00 [P] Create `ProfileState` sealed class hierarchy (6 states: `ProfileInitial`, `ProfileLoading`, `ProfileLoaded({required UserProfile profile})`, `ProfileSaving({required UserProfile profile})`, `ProfileSaveError({required UserProfile profile})`, `ProfileLoadError`) in `forge/lib/features/profile/application/bloc/profile_state.dart`
- [X] T00 [P] Create `GetProfileUseCase` (`call() → Either<AppException, UserProfile>`; maps null from repository to first-time defaults: experienceLevel='Beginner', other fields empty/0.0) in `forge/lib/features/profile/application/use_cases/get_profile_use_case.dart`
- [X] T01 [P] Create `SaveProfileUseCase` (`call(UserProfile) → Either<AppException, void>`; delegates to repository) in `forge/lib/features/profile/application/use_cases/save_profile_use_case.dart`
- [X] T01 Create `ProfileBloc` with `on<ProfileLoadRequested>` (emit Loading → getProfile → emit Loaded or LoadError) and `on<ProfileSaveRequested>` (emit Saving → saveProfile → emit Loaded or SaveError) in `forge/lib/features/profile/application/bloc/profile_bloc.dart`

### DI & Route Registration

- [X] T01 Register `ProfileRepository` (lazySingleton), `GetProfileUseCase` (lazySingleton), `SaveProfileUseCase` (lazySingleton), and `ProfileBloc` (registerFactory) in `forge/lib/app/get_it_setup.dart` (after existing `ProfileLocalDataSource` block)
- [X] T01 Add `RoutePaths.profile = '/profile'` constant and top-level `GoRoute(path: RoutePaths.profile, builder: BlocProvider → ProfileScreen)` — outside `StatefulShellRoute` — auto-fires `ProfileLoadRequested` in `create`; in `forge/lib/config/routes/app_routes.dart`

### Tests (Constitution XI — Required)

- [X] T01 [P] Write `GetProfileUseCase` unit tests: null from repo → default UserProfile (Beginner, empty fields); error from repo → propagated; existing record → mapped correctly; in `forge/test/features/profile/application/use_cases/get_profile_use_case_test.dart`
- [X] T01 [P] Write `SaveProfileUseCase` unit tests: success path → Right(void); repo failure → Left(AppException); in `forge/test/features/profile/application/use_cases/save_profile_use_case_test.dart`
- [X] T01 Write `ProfileBloc` unit tests covering all 6 state transitions: Initial→Loading→Loaded (load success), Initial→Loading→LoadError (load fail), Loaded→Saving→Loaded (save success), Loaded→Saving→SaveError (save fail), retry load (LoadError→Loading→Loaded), retry save (SaveError→Saving→Loaded); using `bloc_test` + `mocktail` in `forge/test/features/profile/application/bloc/profile_bloc_test.dart`

**Checkpoint**: All foundational files compile; all 3 test files pass; `flutter analyze` zero warnings; `flutter test test/features/profile/` green.

---

## Phase 3: User Story 1 — Profile Loading & Display (Priority: P1) 🎯 MVP

**Goal**: Screen entry shows animated skeleton immediately; Drift read resolves to a pre-filled editable form; back arrow returns to SCR-06; no bottom nav bar visible.

**Independent Test**: VS-01, VS-02, VS-03, VS-05 from [quickstart.md](quickstart.md) — open screen with existing profile; confirm skeleton → form; tap back → SCR-06.

### Implementation

- [X] T01 [P] [US1] Create `ProfileSkeleton` `StatefulWidget` owning `AnimationController` for shimmer; renders 64×64 circular avatar skeleton + 4 field-group shimmer rows using `ShimmerBox` in `forge/lib/features/profile/presentation/widgets/profile_skeleton.dart`
- [X] T01 [P] [US1] Create `ProfileAvatarWrap` stateless widget: 64×64 lime-tinted circle with generic person icon (decorative, no tap target) in `forge/lib/features/profile/presentation/widgets/profile_avatar_wrap.dart`
- [X] T01 [P] [US1] Create `ProfileFieldGroup` stateless widget: label (AppStrings, textTheme) above a contained child slot (used for field-input, field-select, seg-row, field-row-2) in `forge/lib/features/profile/presentation/widgets/profile_field_group.dart`
- [X] T02 [P] [US1] Create `ProfileFieldInput` stateless widget: `TextEditingController controller`, `String label`, `String hint`, `TextInputType keyboardType`, `bool hasError` (defaults false), `bool enabled` (defaults true) — token-based border/fill; inline error text slot below the field in `forge/lib/features/profile/presentation/widgets/profile_field_input.dart`
- [X] T02 [P] [US1] Create `ProfileFieldSelect` stateless widget: `String? value`, `String hint`, `VoidCallback onTap` — renders as a tappable tile showing value or hint; lime chevron icon in `forge/lib/features/profile/presentation/widgets/profile_field_select.dart`
- [X] T02 [P] [US1] Create `ProfileSegRow` stateless widget: `String value`, `List<String> options`, `ValueChanged<String> onChanged` — 3-segment single-select; active segment lime-filled; inactive segments outlined in `forge/lib/features/profile/presentation/widgets/profile_seg_row.dart`
- [X] T02 [P] [US1] Create `ProfileFieldRow2` stateless widget: two equal-width children side by side with a gap; used for height+weight in `forge/lib/features/profile/presentation/widgets/profile_field_row_2.dart`
- [X] T02 [P] [US1] Create `ProfileLogoutRow` stateless widget: `VoidCallback onTap` — danger-colored "Log Out" label with logout icon; ≥44pt tap target; uses `AppStrings.profileLogOut` and `AppColors.*` in `forge/lib/features/profile/presentation/widgets/profile_logout_row.dart`
- [X] T02 [US1] Create `ProfileScreen` `StatefulWidget`: `BlocConsumer<ProfileBloc, ProfileState>`; local state for 5 controllers + `_fitnessGoal` + `_experienceLevel`; skeleton on Initial/Loading; populated form on Loaded/Saving; `_populateControllers` helper; app bar with back arrow and `AppStrings.profileScreenTitle`; no `BottomNavigationBar`; in `forge/lib/features/profile/presentation/screens/profile_screen.dart`
- [X] T02 [US1] Add profile icon `IconButton` to `HomeHeader` calling `context.push(RoutePaths.profile)` using a person icon and `AppColors.*`; no hardcoded colors or strings; in `forge/lib/features/home/presentation/widgets/home_header.dart`

**Checkpoint**: VS-01, VS-02, VS-03 pass; back arrow functional; no bottom nav bar; skeleton appears with no blank frame on entry.

---

## Phase 4: User Story 2 — Edit and Save Profile (Priority: P2)

**Goal**: User edits fields and taps "Save Changes"; valid data writes to Drift; success toast appears ~2.5s and auto-dismisses; Save button disabled during in-flight write; fitness goal picker opens bottom sheet.

**Independent Test**: VS-04, VS-05, VS-10 from [quickstart.md](quickstart.md) — edit display name + experience level, tap Save, see toast, navigate away and back, confirm values persisted.

### Implementation

- [X] T02 [P] [US2] Create `ProfileSaveButton` stateless widget: `VoidCallback? onPressed`, `bool isLoading`, `String label` — lime ElevatedButton when active; muted disabled appearance when `onPressed == null`; ≥44pt height; uses `AppStrings.profileSaveChanges` in `forge/lib/features/profile/presentation/widgets/profile_save_button.dart`
- [X] T02 [P] [US2] Create `ProfileSuccessToast` stateless widget: `bool visible` — absolutely positioned bottom overlay; lime `successFill` background, `successBorder` border; lime checkmark icon + `AppStrings.profileSaved` text; animates in/out in `forge/lib/features/profile/presentation/widgets/profile_success_toast.dart`
- [X] T02 [US2] Extend `ProfileScreen`: add `_onSaveTap()` (builds `UserProfile` from controllers, dispatches `ProfileSaveRequested`); add `ProfileSaving` form rendering (Save button disabled); add `_showToast` / `_toastTimer` local state; add `BlocListener` detection of `ProfileSaving → ProfileLoaded` to call `_showSuccessToast()` (sets `_showToast = true`, starts 2.5s `Timer`); add fitness goal `showModalBottomSheet` with 3 `ListTile` options (Build Muscle, Lose Weight, General Fitness); integrate `ProfileSaveButton` and `ProfileSuccessToast` into scaffold; in `forge/lib/features/profile/presentation/screens/profile_screen.dart`

**Checkpoint**: VS-04, VS-05, VS-10 pass; toast appears and auto-dismisses; Save button disabled during write; fitness goal picker works.

---

## Phase 5: User Story 3 — Invalid Height or Weight Blocks Save (Priority: P3)

**Goal**: Negative, zero, or non-numeric height/weight blocks save; danger highlight + inline error appear on invalid fields; Save button switches to disabled with helper note; correcting and re-saving succeeds.

**Independent Test**: VS-06, VS-07, VS-08, VS-09 from [quickstart.md](quickstart.md).

### Implementation

- [X] T03 [P] [US3] Add `hasError: bool` parameter to `ProfileFieldInput`: when `true`, apply `AppColors.danger`/`dangerFill` border and fill; show inline error text from `AppStrings.profileInvalidNumber` below the field; in `forge/lib/features/profile/presentation/widgets/profile_field_input.dart`
- [X] T03 [US3] Add to `ProfileScreen`: `_heightError` / `_weightError` boolean flags; `_isValidPositiveNumber(String text) → bool` (empty=true, parsed ≤0 or non-numeric=false); update `_onSaveTap()` to set flags and early-return when invalid; add helper note `AppStrings.profileFixFields` below `ProfileSaveButton` when either error is active; pass `hasError` to the height/weight `ProfileFieldInput` instances; in `forge/lib/features/profile/presentation/screens/profile_screen.dart`

**Checkpoint**: VS-06, VS-07, VS-08, VS-09 pass; zero input blocked; decimal input accepted; double-tap of disabled Save does nothing.

---

## Phase 6: User Story 4 — Navigate to Logout Confirmation (Priority: P4)

**Goal**: Tapping "Log Out" navigates to SCR-26 (Logout Confirmation) via `context.push`; no logout or data clear occurs on this screen.

**Independent Test**: VS-11 from [quickstart.md](quickstart.md) — tap Log Out from loaded form, confirm navigation to SCR-26 (or placeholder route).

### Implementation

- [X] T03 [US4] Wire `ProfileLogoutRow.onTap` to `context.push(RoutePaths.logoutConfirmation)` in `ProfileScreen._buildForm()`; if `RoutePaths.logoutConfirmation` is not yet defined (SCR-26 not implemented), use `context.push('/logout')` with a TODO comment; in `forge/lib/features/profile/presentation/screens/profile_screen.dart`
- [X] T03 [US4] Add a `GoRoute(path: '/logout', builder: ...)` stub in `forge/lib/config/routes/app_routes.dart`; if `RoutePaths.logoutConfirmation` is already declared in the file, use that constant as the path instead of `'/logout'` and remove any duplicate stub

**Checkpoint**: VS-11 passes; tapping Log Out navigates; no crash; profile data unchanged on return.

---

## Phase 7: User Story 5 — Profile Load Error and Save Error with Retry (Priority: P5)

**Goal**: Both read-failure and write-failure render the full-screen `ProfileErrorCard`; Retry re-attempts the operation; `_retrying` guard prevents duplicate events.

**Independent Test**: VS-12, VS-13, VS-14, VS-15 from [quickstart.md](quickstart.md) — inject read failure, confirm error card, tap Retry, confirm skeleton re-appears; inject write failure, confirm save error card, tap Retry, confirm re-attempt.

### Implementation

- [X] T03 [US5] Create `ProfileErrorCard` stateless widget: `String title`, `String body`, `VoidCallback onRetry`, `bool isRetrying` — full-screen centered layout; alert-triangle icon (40×40, `AppColors.danger`); title (`textTheme`); body text; lime `ElevatedButton` for Retry (disabled when `isRetrying`); uses `AppStrings.profileLoadErrorTitle` / `profileSaveErrorTitle` / `profileErrorBody` / `profileRetry`; in `forge/lib/features/profile/presentation/widgets/profile_error_card.dart`
- [X] T03 [US5] Add to `ProfileScreen`: `ProfileLoadError` branch in `BlocBuilder` renders `ProfileErrorCard(title: AppStrings.profileLoadErrorTitle, onRetry: _onLoadRetry)`; `ProfileSaveError` branch renders `ProfileErrorCard(title: AppStrings.profileSaveErrorTitle, onRetry: () => _onSaveRetry(state.profile))`; `_onLoadRetry()` guard (`if (_retrying) return; setState(() => _retrying = true); context.read<ProfileBloc>().add(ProfileLoadRequested())`); `_onSaveRetry(UserProfile)` same pattern dispatching `ProfileSaveRequested`; reset `_retrying = false` in `BlocListener` on `ProfileSaveError` / `ProfileLoadError` / `ProfileLoaded`; in `forge/lib/features/profile/presentation/screens/profile_screen.dart`

**Checkpoint**: VS-12, VS-13, VS-14, VS-15 pass; back arrow functional from error state; double-tap Retry does not dispatch duplicate events.

---

## Phase 8: Polish & Validation

**Purpose**: Format, analyze, test, and manually validate all 15 quickstart scenarios.

- [X] T03 Run `dart format .` from `forge/` and commit any formatting changes
- [X] T03 Run `flutter analyze` from `forge/` and resolve every new warning or error introduced by this feature (zero new warnings acceptable)
- [X] T03 Run `flutter test` from `forge/` and confirm all new and pre-existing tests pass
- [X] T03 Perform manual validation per [quickstart.md](quickstart.md) — complete VS-01 through VS-15 in order; mark each passed or document any deviation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately; T001 and T002 can run in parallel
- **Phase 2 (Foundational)**: Depends on Phase 1 — BLOCKS all user story phases
  - T003 and T004 must complete before T005/T006
  - T005, T007, T008, T009, T010 can run in parallel (different files)
  - T006 depends on T003, T004, T005
  - T011 depends on T007, T008, T009, T010
  - T012 depends on T011 (and T009, T010)
  - T013 depends on T012
  - T014, T015, T016 can run in parallel after their respective source files exist
- **Phase 3 (US1)**: Depends on Phase 2 completion — T017–T024 can run in parallel; T025 depends on all widgets (T017–T024); T026 independent
- **Phase 4 (US2)**: Depends on Phase 3; T027/T028 parallel; T029 depends on T027 + T028
- **Phase 5 (US3)**: Depends on Phase 3; T030 independent; T031 depends on T030
- **Phase 6 (US4)**: Depends on Phase 3; T032 then T033 (conditional)
- **Phase 7 (US5)**: Depends on Phase 2; T034 independent; T035 depends on T034
- **Phase 8 (Polish)**: Depends on all prior phases

### User Story Dependencies

- **US1 (P1)**: Unblocked after Phase 2 — delivers the baseline populated form
- **US2 (P2)**: Depends on US1 (needs `ProfileScreen` scaffold from T025)
- **US3 (P3)**: Depends on US1 (needs `ProfileFieldInput` from T020)
- **US4 (P4)**: Depends on US1 (needs `ProfileScreen` scaffold and `ProfileLogoutRow` from T024/T025)
- **US5 (P5)**: Depends on Phase 2 only (error branches added to `ProfileScreen`; `ProfileErrorCard` is new); US5 may be worked in parallel with US2–US4

### Within Each User Story

- Widgets (parallel) → screen integration (sequential)
- Tests run after source files exist (Phase 2 tests: after T011, T009, T010 respectively)

---

## Parallel Opportunities

### Phase 1

```
Parallel: T001 (app_colors.dart) + T002 (app_strings.dart)
```

### Phase 2 — Foundational

```
Sequential: T003 → T004
Parallel after T003+T004: T005 + T007 + T008 + T009 + T010
Sequential: T006 (after T003, T004, T005)
Sequential: T011 (after T007, T008, T009, T010)
Sequential: T012 → T013
Parallel (after source exists): T014 + T015 + T016
```

### Phase 3 — US1

```
Parallel: T017 + T018 + T019 + T020 + T021 + T022 + T023 + T024
Sequential: T025 (after all widgets above)
Independent: T026 (home_header.dart — no dependency on T025)
```

### Phase 4 — US2

```
Parallel: T027 + T028
Sequential: T029 (after T027 + T028 + T025)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T016)
3. Complete Phase 3: US1 (T017–T026)
4. **STOP and VALIDATE**: VS-01, VS-02, VS-03 from quickstart.md
5. Screen is navigable, loads from Drift, back arrow works — MVP validated

### Incremental Delivery

1. Phase 1 + Phase 2 → foundation verified (tests green)
2. Phase 3 → US1 done → loading and display validated (VS-01–VS-03, VS-05)
3. Phase 4 → US2 done → save + toast validated (VS-04, VS-05, VS-10)
4. Phase 5 → US3 done → validation errors (VS-06–VS-09)
5. Phase 6 → US4 done → logout navigation (VS-11)
6. Phase 7 → US5 done → full error resilience (VS-12–VS-15)
7. Phase 8 → format + analyze + test + quickstart sign-off

---

## Notes

- `[P]` = different files, no inter-task dependency — can be worked simultaneously
- `[Story]` label maps each task to its spec user story for traceability
- Tests (T014–T016) are required by Constitution XI — not optional
- `UserProfileRecord` and `ProfileLocalDataSource` **already exist** — do NOT recreate them
- `ProfileBloc` uses `registerFactory` (fresh instance per route push); use cases use `lazySingleton`
- Success toast is local `ProfileScreen` state — no `ProfileSaveSuccess` Bloc state exists
- `ProfileSaveError.profile` holds the in-flight data for Retry — do not re-read from controllers
- Empty height/weight text = 0.0 stored (valid); non-empty ≤0 or non-numeric = blocked
- All strings via `AppStrings.profile*`; all colors via `AppColors.*` or `colorScheme`; no hardcoded values
- `/logout` placeholder in T033 is conditional — skip if SCR-26 route is already present
