# Research: SCR-25 Profile / Account

**Feature**: SCR-25 Profile / Account  
**Date**: 2026-09-24

---

## D-01 — Route Placement: Top-Level GoRoute at `/profile`

**Decision**: Add a top-level `GoRoute(path: '/profile', ...)` outside the `StatefulShellRoute.indexedStack`, at the end of the root `routes:` list in `app_routes.dart`.

**Rationale**: The profile screen is a pushed detail screen with no bottom navigation bar (FR-017). Placing it outside the `StatefulShellRoute` ensures the `AppShell` (with its `BottomNavigationBar`) is never part of the profile route's widget tree. Any route inside the shell's branches would inherit the bottom nav.

**Alternatives considered**:
- Nested under the home branch: would inherit the shell's bottom nav unless explicitly hidden — fragile and non-idiomatic for pushed screens in this codebase.
- New shell branch (tab): out of scope; the profile screen is not a root tab per the design spec.

**Entry point**: `context.go(RoutePaths.profile)` called from `HomeHeader` widget when user taps the profile icon. `context.go` (not `context.push`) so the user presses back to return, not adds to a stack that mishandles the shell.

Actually — `context.go('/profile')` replaces the current location, which is wrong for a detail screen. Use `context.push('/profile')` so the user can pop back to the home screen with the back arrow. Using `context.push` for a detail screen launched from within a `StatefulShellRoute` is the correct go_router pattern.

**Corrected entry**: `context.push(RoutePaths.profile)` from `HomeHeader`.

---

## D-02 — DI Registration Order

**Decision**: Register in `get_it_setup.dart` after the existing `ProfileLocalDataSource` block (already registered):
1. `registerLazySingleton<ProfileRepository>` → `ProfileRepositoryImpl`
2. `registerLazySingleton<GetProfileUseCase>`
3. `registerLazySingleton<SaveProfileUseCase>`
4. `registerFactory<ProfileBloc>` (fresh instance per route push → on-entry re-load)

**Rationale**: `ProfileLocalDataSource` is already registered as `lazySingleton`. `ProfileRepository` depends on it, so it must be registered after. Use cases depend on the repository. `ProfileBloc` uses `registerFactory` so each route push creates a fresh Bloc that auto-fires `ProfileLoadRequested` on creation, ensuring the form always reflects the latest saved values on entry.

**Alternatives considered**: `registerLazySingleton<ProfileBloc>` — would reuse a single bloc instance across route pushes, requiring explicit state-reset logic and risking stale data. Rejected in favour of `registerFactory` (consistent with `HomeBloc`, `PbBloc` patterns already in the codebase).

---

## D-03 — Profile Domain Entity: `UserProfile`

**Decision**: Create a pure Dart class `UserProfile` in `forge/lib/features/profile/domain/entities/user_profile.dart` with fields:
- `displayName: String` — editable text; empty string = unset/blank
- `fitnessGoal: String` — one of `'Build Muscle' | 'Lose Weight' | 'General Fitness' | ''` (empty = no selection for first-time user)
- `experienceLevel: String` — one of `'Beginner' | 'Intermediate' | 'Advanced'`; defaults to `'Beginner'` for new users
- `heightCm: double` — 0.0 = unset (blank field); positive value otherwise
- `weightKg: double` — 0.0 = unset (blank field); positive value otherwise

No equatable. Pure Dart.

**Rationale**: Matches the `UserProfileRecord` field set. `String` is used for `fitnessGoal` and `experienceLevel` (rather than enums) to match the existing storage record storage format and avoid an extra enum layer in the domain for MVP. Empty string for `fitnessGoal` represents "no goal selected" for first-time users.

**First-time user defaults**: When Drift returns `null` (no profile record), the repository returns a `UserProfile` with `displayName: ''`, `fitnessGoal: ''`, `experienceLevel: 'Beginner'`, `heightCm: 0.0`, `weightKg: 0.0`. The mapper at the `ProfileRepositoryImpl` layer applies these defaults.

**Alternatives considered**: Enums for `fitnessGoal`/`experienceLevel` — cleaner type-safety but adds two more files and requires Drift string ↔ enum conversion logic. Deferred to a future refactor.

---

## D-04 — Mapper Layer

**Decision**: Create `UserProfileMapper` in `forge/lib/features/profile/data/mappers/user_profile_mapper.dart` with two static methods:
- `static UserProfile fromRecord(UserProfileRecord model)` — maps `UserProfileRecord` to `UserProfile`
- `static UserProfileRecord toRecord(UserProfile entity, {DateTime? createdAt})` — maps `UserProfile` to `UserProfileRecord`; preserves `createdAt` from existing record (or uses `DateTime.now()` for first save); always sets `updatedAt = DateTime.now()`

**Rationale**: Constitution Principle I.4 requires storage records to be mapped explicitly to Domain entities via a Mapper and MUST NOT leak into Domain or Presentation. The existing `ProfileLocalDataSource` returns/accepts `UserProfileRecord`. The repository uses the mapper to convert to/from the domain entity.

---

## D-05 — ProfileRepository Interface and Implementation

**Decision**: 
- Abstract: `ProfileRepository` in `forge/lib/features/profile/domain/repositories/profile_repository.dart`
  ```dart
  abstract class ProfileRepository {
    Future<Either<AppException, UserProfile?>> getProfile();
    Future<Either<AppException, void>> saveProfile(UserProfile profile);
  }
  ```
- Implementation: `ProfileRepositoryImpl` in `forge/lib/features/profile/data/repositories/profile_repository_impl.dart`

**Rationale**: `getProfile()` returns `UserProfile?` — `null` means no profile record exists yet (first-time user). The caller (`GetProfileUseCase`) converts `null` to the first-time default `UserProfile`. The repository wraps the data source calls in try-catch and maps exceptions to `AppException` (const Principle II.5 — raw Drift exceptions terminate in the Data layer).

**`saveProfile` implementation**: Reads the existing storage record (if any) to preserve `createdAt`, then writes via `ProfileLocalDataSource.saveProfile(model)`. If no existing model, sets `createdAt = DateTime.now()`.

---

## D-06 — Use Cases

**Decision**:
- `GetProfileUseCase` in `forge/lib/features/profile/application/use_cases/get_profile_use_case.dart`
  - Calls `ProfileRepository.getProfile()`
  - On `Right(null)`: returns `Right(UserProfile.firstTimeDefaults())` or equivalent default value
  - On `Right(UserProfile)`: returns the profile
  - On `Left(AppException)`: propagates the exception (Bloc catches and emits `ProfileLoadError`)

- `SaveProfileUseCase` in `forge/lib/features/profile/application/use_cases/save_profile_use_case.dart`
  - Calls `ProfileRepository.saveProfile(UserProfile profile)`
  - Returns `Either<AppException, void>` — success or typed failure

**Rationale**: Thin use cases consistent with the rest of the codebase (`GetDashboardSnapshotUseCase`, `GetWorkoutPlansUseCase` pattern). No business logic — delegates to the repository.

---

## D-07 — ProfileBloc Events and States

**Decision**:

**Events** (`profile_event.dart`):
```dart
sealed class ProfileEvent {}
final class ProfileLoadRequested extends ProfileEvent {}
final class ProfileSaveRequested extends ProfileEvent {
  final UserProfile profile;
  const ProfileSaveRequested({required this.profile});
}
```

**States** (`profile_state.dart`):
```dart
sealed class ProfileState {}
final class ProfileInitial extends ProfileState {}
final class ProfileLoading extends ProfileState {}
final class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  const ProfileLoaded({required this.profile});
}
final class ProfileSaving extends ProfileState {
  final UserProfile profile;
  const ProfileSaving({required this.profile});
}
final class ProfileSaveError extends ProfileState {
  final UserProfile profile;      // held for retry
  const ProfileSaveError({required this.profile});
}
final class ProfileLoadError extends ProfileState {}
```

**Rationale**:
- `ProfileLoadRequested` serves both initial load and retry after load failure (no separate retry event needed).
- `ProfileSaveRequested` serves both initial save and retry after save failure (the screen re-dispatches with the saved `profile` from `ProfileSaveError` state).
- `ProfileSaving` holds `profile` so the form can remain visible with the in-flight values and the save button is disabled (FR-024).
- `ProfileSaveError` holds `profile` so the screen's Retry can dispatch `ProfileSaveRequested(profile: state.profile)` without the user re-entering the form (FR-023).
- `ProfileLoaded` holds `profile` so the screen can populate/update form controllers when state arrives. `profile` represents a first-time user when all fields are at defaults.
- No separate `ProfileSaveSuccess` state — success is signalled by the transition from `ProfileSaving` to `ProfileLoaded`. The screen's `BlocListener` detects `prev is ProfileSaving && curr is ProfileLoaded` to show the local success toast.

---

## D-08 — Success Toast Implementation

**Decision**: The success toast ("Profile saved") is a local UI concern owned by the `ProfileScreen` `StatefulWidget`. It is NOT a Bloc state.

Implementation in `ProfileScreen`:
- `bool _showToast = false`
- `Timer? _toastTimer`
- `BlocListener` detects `prev is ProfileSaving && current is ProfileLoaded` → `setState(() { _showToast = true; _toastTimer = Timer(const Duration(milliseconds: 2500), () => setState(() => _showToast = false)); })`
- `dispose()` cancels `_toastTimer`
- `ProfileSuccessToast` widget is shown conditionally inside a `Stack` when `_showToast == true`

**Two new color tokens required**:
- `AppColors.successFill = const Color(0xFF1E2A12)` — toast background
- `AppColors.successBorder = const Color(0xFF4A5C22)` — toast border

**Rationale**: The toast is not application state — it is a transient UI feedback element. Bloc emitting a `ProfileSaveSuccess` state just to drive a 2.5s UI animation would pollute the state machine. Local `StatefulWidget` state is the correct mechanism per CLAUDE.md rule 45 and flutter_bloc best practices.

---

## D-09 — Form Local State in ProfileScreen

**Decision**: `ProfileScreen` is a `StatefulWidget` owning:
- `TextEditingController _nameController`
- `String _fitnessGoal` (current selection; `''` = unset)
- `String _experienceLevel` (current segment; defaults to `'Beginner'`)
- `TextEditingController _heightController`
- `TextEditingController _weightController`
- `bool _heightError` — true when height fails validation
- `bool _weightError` — true when weight fails validation
- `bool _showToast` — success toast visibility
- `Timer? _toastTimer` — toast auto-dismiss timer
- `bool _retrying` — debounce guard for Retry button

Controllers are initialized and populated in `BlocListener` when `ProfileLoaded` is received. They persist across `ProfileSaving` states (not re-initialized).

**Validation function** `_isValidPositiveNumber(String text)`:
- Returns `true` if `text.isEmpty` (unset field — allowed)
- Returns `false` if `text` cannot be parsed as `double`, or parsed value ≤ 0
- Returns `true` if parsed value > 0

This allows first-time users to save with empty height/weight fields (stored as 0.0). An entered but invalid value (negative, zero, non-numeric) is blocked (FR-010).

**Rationale**: Consistent with the clarification decision (Q2: first-time user with empty fields is not blocked). Empty = unset = allowed; non-empty + invalid = error.

---

## D-10 — ProfileSkeleton Design

**Decision**: `ProfileSkeleton` is a `StatefulWidget` owning an `AnimationController` (repeat, `vsync: this`). Renders:
- `sk-avatar`: 64×64 circle `ShimmerBox`
- 4 `field-group` skeleton rows: each with a `sk-label` (35% width, 11px tall `ShimmerBox`) + `sk-field` (44px tall, full-width `ShimmerBox`)

Uses translate-shimmer animation (same as SCR-21/22/23/24 — `ShimmerBox` already implements this via `AppColors.cardAlt` + `AppColors.shimmerDark`).

**Rationale**: Follows established skeleton pattern in the codebase. `ShimmerBox` handles the animation entirely; `ProfileSkeleton` just owns the controller and lays out the boxes.

---

## D-11 — Profile Error Card

**Decision**: Create `ProfileErrorCard` in `forge/lib/features/profile/presentation/widgets/profile_error_card.dart` (feature-specific, not the core `ErrorCard`). Accepts:
- `title: String` — "Couldn't load your profile" or "Couldn't save your profile"
- `body: String` — descriptive body copy
- `onRetry: VoidCallback`

Renders:
- `Container` with `AppColors.dangerBg` fill, `AppColors.dangerBorder` border, `border-radius: 16px`, `padding: 26px 20px`
- `Column`: alert-triangle icon (40×40, `AppColors.danger`), title text (16px/800), body text (13px/muted, lineHeight:1.5), `ElevatedButton` (lime bg, `#131315`, 800/13px, `border-radius:10px`, `padding:11px 22px`, `minimumSize:Size(168, 44)`)

**Rationale**: The existing core `ErrorCard` uses `OutlinedButton` and a different layout ("Retry" label only, no separate title+body). The design spec for SCR-25 matches the SCR-24 `PbErrorCard` pattern (ElevatedButton with lime bg). A feature-specific card is needed. Future consolidation into a core `AppErrorCard` is recommended when SCR-24 is also implemented.

---

## D-12 — AppStrings: Profile Section (23 constants)

New constants to add to `forge/lib/core/strings/app_strings.dart` under a `// SCR-25 Profile` comment block:

| Constant | Value |
|----------|-------|
| `profileScreenTitle` | `'Profile'` |
| `profileDisplayNameLabel` | `'DISPLAY NAME'` |
| `profileFitnessGoalLabel` | `'FITNESS GOAL'` |
| `profileExperienceLevelLabel` | `'EXPERIENCE LEVEL'` |
| `profileHeightLabel` | `'HEIGHT (CM)'` |
| `profileWeightLabel` | `'WEIGHT (KG)'` |
| `profileSegBeginner` | `'Beginner'` |
| `profileSegIntermediate` | `'Intermediate'` |
| `profileSegAdvanced` | `'Advanced'` |
| `profileFitnessGoalBuildMuscle` | `'Build Muscle'` |
| `profileFitnessGoalLoseWeight` | `'Lose Weight'` |
| `profileFitnessGoalGeneralFitness` | `'General Fitness'` |
| `profileFitnessGoalHint` | `'Select a goal'` |
| `profileSaveButton` | `'Save Changes'` |
| `profileLogoutLabel` | `'Log Out'` |
| `profileSaveSuccessToast` | `'Profile saved'` |
| `profileSaveNote` | `'Fix the highlighted fields to save.'` |
| `profileFieldError` | `'Enter a valid positive number.'` |
| `profileLoadErrorTitle` | `'Couldn\'t load your profile'` |
| `profileLoadErrorBody` | `'Something went wrong reading local data.\nRetry to try again — your saved profile is unaffected.'` |
| `profileSaveErrorTitle` | `'Couldn\'t save your profile'` |
| `profileSaveErrorBody` | `'Something went wrong saving your profile.\nRetry to try again — your edited values are preserved.'` |
| `profileRetryButton` | `'Retry'` |

---

## D-13 — Color Tokens: successFill and successBorder

**Decision**: Add two new color tokens to `forge/lib/core/theme/app_colors.dart`:
```dart
static const Color successFill = Color(0xFF1E2A12);
static const Color successBorder = Color(0xFF4A5C22);
```

**Rationale**: The `ProfileSuccessToast` (design spec §3D) requires `#1e2a12` background and `#4a5c22` border. These don't exist in the current `AppColors`. Adding them as named tokens ensures future reuse (e.g., any other success feedback widget) and avoids hardcoded hex values in widgets (constitution Principle VIII.5 and CLAUDE.md rule 28).

---

## D-14 — Home Header Profile Entry Point

**Decision**: Modify `forge/lib/features/home/presentation/widgets/home_header.dart` to add a tappable profile icon in the app bar area. The icon uses `AppColors.textDim` (dim) at 22×22, tapping calls `context.push(RoutePaths.profile)`.

**Rationale**: SCR-25 design spec §2 states entry is from SCR-06 (Home Dashboard) via a profile entry point. The `HomeHeader` widget is the most natural place. The icon should be an `Icons.person_outline` or similar, semantically labelled "Profile" for accessibility.

**Note**: The exact design of the home screen's profile entry point is owned by SCR-06, not SCR-25. This change is minimal (add one `IconButton` to the header's row). The SCR-06 specification (if one exists separately) may refine this later.

---

## D-15 — Fitness Goal Picker Mechanism

**Decision**: For MVP, implement the fitness goal selection as a `showModalBottomSheet` presenting three `ListTile` options. This avoids platform-specific native picker complexity while providing a clear, accessible selection UX.

**Rationale**: OQ-1 from the design spec deferred the picker mechanism. `showModalBottomSheet` works identically on iOS and Android, is already available via Flutter Material, and requires no additional packages. A native `CupertinoPicker` or `DropdownButton` could be used in future — the `ProfileFieldSelect` widget abstracts the trigger so the picker mechanism can be swapped without changing the screen.

**Implementation**: `ProfileFieldSelect` widget's `onTap` callback opens `showModalBottomSheet` with three `ListTile` options (Build Muscle, Lose Weight, General Fitness). Selecting an option calls `setState(() => _fitnessGoal = selected)` in the screen.

---

## Constitution Check: 12/12 PASS

| # | Check | Status |
|---|-------|--------|
| 1 | No network calls; all reads/writes via Drift | PASS |
| 2 | Drift is sole persistence; no second store | PASS |
| 3 | No new packages (flutter_bloc, Drift, get_it, go_router — all governed) | PASS |
| 4 | `Bloc` only — no `Cubit` introduced by SCR-25 | PASS |
| 5 | `go_router` only — no second router | PASS |
| 6 | `GetIt` only — no Riverpod/Provider | PASS |
| 7 | Single dark theme; AppColors tokens only; no hardcoded hex in widgets | PASS |
| 8 | AppStrings for all user-facing copy | PASS |
| 9 | All 6 states explicitly defined (Initial, Loading, Loaded, Saving, SaveError, LoadError) | PASS |
| 10 | Drift exceptions mapped to `AppException` in data layer; UI sees typed states only | PASS |
| 11 | Clean architecture — domain has no Flutter/Drift imports; storage record never leaks to domain/presentation | PASS |
| 12 | No Git operations | PASS |
