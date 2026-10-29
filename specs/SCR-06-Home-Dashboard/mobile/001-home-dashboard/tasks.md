# Tasks: SCR-06 Home Dashboard

**Input**: Design documents from `specs/SCR-06-Home-Dashboard/mobile/001-home-dashboard/`

**Branch**: `001-home-dashboard` | **Date**: 2026-09-16

**Prerequisites**: plan.md ✓ · spec.md ✓ · research.md ✓ · data-model.md ✓ · contracts/ ✓ · quickstart.md ✓ · constitution.md ✓

**Tests**: Included in Polish phase (constitution XI mandates coverage targets: Domain 90%+, Application 80%+, Data 70%+, Presentation critical flows).

**Organization**: Grouped by phase → user story to enable independent delivery. Every task has an exact file path.

## Format: `[ID] [P?] [Story] Description — file path`

- **[P]**: Parallelizable (different files, no dependency on an incomplete sibling task)
- **[US1]–[US4]**: Maps to user story from spec.md
- Setup and Foundational tasks carry no story label (shared infrastructure)

---

## Phase 1: Setup — Remove Stale Scaffold

**Purpose**: Delete the constitutional violations and placeholder stubs that block clean implementation. No new code is written here.

**⚠️ Must complete before any other task.**

- [X] T001 Delete file `forge/lib/features/home/data/models/home_model.dart` (placeholder JSON model with no backend; violates Drift-only principle)
- [X] T002 Delete directory `forge/lib/features/home/presentation/bloc/` and all its files (home_bloc.dart, home_event.dart, home_state.dart misplaced in presentation layer; Bloc moves to application/bloc/ per constitution Principle I)
- [X] T003 Delete file `forge/lib/features/home/data/datasources/home_remote_data_source.dart` (Dio-based; constitutional violation — ForgeApp must remain fully offline)

**Checkpoint**: Three stale/violating files removed. Repository compiles (or has expected missing-reference errors — that is expected and will be fixed in Phase 2).

---

## Phase 2: Foundational — Core Infrastructure

**Purpose**: Domain entities, data layer, Bloc, and app shell route that ALL user stories depend on. No user story work begins until this phase is complete.

**⚠️ CRITICAL: No user story phase can start until this phase is complete.**

### 2A. Domain Layer

- [X] T004 [P] Write domain entity `DashboardSnapshot` in `forge/lib/features/home/domain/entities/dashboard_snapshot.dart` — fields: `bool hasData`, `TodayWorkout? todayWorkout`; extends `Equatable`; replaces `home_entity.dart`
- [X] T005 [P] Write domain entity `TodayWorkout` in `forge/lib/features/home/domain/entities/today_workout.dart` — fields: `String planId`, `String planName`, `int exerciseCount`, `ExerciseType dominantType`, `int? firstExerciseRestSec`; extends `Equatable`
- [X] T006 Rewrite `forge/lib/features/home/domain/repositories/home_repository.dart` — single method `Future<Either<Failure, DashboardSnapshot>> getDashboardSnapshot()`; remove old `getHomeData()` signature

### 2B. Data Layer

- [X] T007 Write `forge/lib/features/home/data/datasources/home_local_data_source.dart` — abstract interface `HomeDashboardLocalDataSource` with method `Future<DashboardSnapshot> getDashboardSnapshot()`; implementation class `HomeDashboardLocalDataSourceImpl` reads three existing tables via `WorkoutPlanLocalDataSource`, `ScheduleLocalDataSource`, `WorkoutSessionLocalDataSource`; derives `hasData` and `todayWorkout` per data-model.md derivation rules (weekday = `DateTime.now().weekday`; dominantType = mode with tie-break weighted > bodyweight > timeBased; firstExerciseRestSec = first exercise's `restPeriodSec` or null if empty)
- [X] T008 Rewrite `forge/lib/features/home/data/repositories/home_repository_impl.dart` — `HomeRepositoryImpl implements HomeRepository`; injects `HomeDashboardLocalDataSource`; wraps call in try/catch; maps exceptions to typed `Failure`; returns `Either<Failure, DashboardSnapshot>`

### 2C. Application Layer — Use Case

- [X] T009 Rewrite `forge/lib/features/home/application/usecases/get_dashboard_snapshot_usecase.dart` — `GetDashboardSnapshotUseCase`; injects `HomeRepository`; `call()` delegates to `repository.getDashboardSnapshot()`; returns `Either<Failure, DashboardSnapshot>`

### 2D. Application Layer — Bloc

- [X] T010 Write `forge/lib/features/home/application/bloc/home_event.dart` — single sealed event `HomeLoadRequested extends HomeEvent`; extends `Equatable`
- [X] T011 Write `forge/lib/features/home/application/bloc/home_state.dart` — five states: `HomeInitial`, `HomeLoading`, `HomeEmpty`, `HomePopulated(DashboardSnapshot snapshot)`, `HomeError(String message)`; all extend `HomeState extends Equatable`
- [X] T012 Write `forge/lib/features/home/application/bloc/home_bloc.dart` — `HomeBloc extends Bloc<HomeEvent, HomeState>`; injects `GetDashboardSnapshotUseCase`; `on<HomeLoadRequested>` handler: idempotent guard (return if already `HomeLoading`), emit `HomeLoading`, call use case, fold result to `HomeEmpty` / `HomePopulated` / `HomeError`

### 2E. Dependency Injection

- [X] T013 Update `forge/lib/app/get_it_setup.dart` — remove `HomeRemoteDataSource` registration (replace `UnimplementedError` stub); add registrations: `HomeDashboardLocalDataSource` (factory), `HomeRepository`/`HomeRepositoryImpl` (factory), `GetDashboardSnapshotUseCase` (factory), `HomeBloc` (factory)

### 2F. App Shell & Routes

- [X] T014 Write `forge/lib/features/home/presentation/screens/placeholder_tab_screen.dart` — `PlaceholderTabScreen({required String label})`; centers `Text(label)` using `theme.textTheme.bodyLarge` with `AppColors.textMuted`; used as root for unimplemented tab branches
- [X] T015 Write `forge/lib/features/home/presentation/screens/app_shell.dart` — `AppShell({required StatefulNavigationShell navigationShell})`; `Scaffold` with `body: navigationShell` and `bottomNavigationBar: NavigationBar` with 6 `NavigationDestination` items: Home (index 0), Plans, Schedule, History, Progress, Stats; `onDestinationSelected: navigationShell.goBranch`; `selectedIndex: navigationShell.currentIndex`; uses `AppColors.*` tokens for active/inactive colors
- [X] T016 Rewrite `forge/lib/config/routes/app_routes.dart` — replace single `GoRoute('/')` with `StatefulShellRoute.indexedStack` having 6 branches (each `StatefulShellBranch` with a `GlobalKey<NavigatorState>`): branch 0 → `/` → `HomeScreen`, branches 1–5 → `/plans`, `/schedule`, `/history`, `/progress`, `/stats` → `PlaceholderTabScreen(label: '...')`; shell builder returns `AppShell(navigationShell: shell)`; preserve existing `GoRouter` instance name `router`

**Checkpoint**: App boots, shows 6-tab shell, Home tab renders (with Bloc errors if not yet wired — expected). Foundation is complete.

---

## Phase 3: User Story 1 — Today's Workout at a Glance (Priority: P1) 🎯 MVP

**Goal**: User opens Home and immediately sees today's workout card (plan name, exercise count, dominant type, rest period) or the loading indicator while data is being read. Tapping the card navigates to SCR-15.

**Independent Test** (VS-03 in quickstart.md): Seed a `WorkoutPlanRecord` with exercises and a `ScheduleEntryRecord` for today's weekday. Launch app. Verify: loading indicator appears briefly, then a workout card shows plan name, correct exercise count, correct dominant type chip, correct rest period chip. Tap card → navigates to SCR-15.

### Implementation for User Story 1

- [X] T017 [P] [US1] Write `forge/lib/features/home/presentation/widgets/home_header.dart` — `HomeHeader`; renders greeting "Good [morning/afternoon/evening], Athlete" derived from `DateTime.now().hour` (<12→morning, <17→afternoon, else→evening); uses `theme.textTheme.headlineMedium` with `AppColors.white`
- [X] T018 [P] [US1] Write `forge/lib/features/home/presentation/widgets/loading_indicator.dart` — `LoadingIndicator`; centers `CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.lime))`; fills available body space via `SizedBox.expand`
- [X] T019 [P] [US1] Write `forge/lib/features/home/presentation/widgets/today_workout_card.dart` — `TodayWorkoutCard({required TodayWorkout workout, required VoidCallback onTap})`; tappable `Card(color: AppColors.card)` with 12dp radius; shows plan name (`theme.textTheme.titleLarge`, `AppColors.white`), exercise count chip, dominant type chip, rest period chip (omitted when `workout.firstExerciseRestSec == null`), "Tap to start" label (`AppColors.lime`); all chip text uses `AppColors.textMuted`
- [X] T020 [US1] Write `forge/lib/features/home/presentation/screens/home_screen.dart` — `HomeScreen` as `StatefulWidget`; `BlocProvider<HomeBloc>` wrapping `BlocBuilder<HomeBloc, HomeState>`; `didChangeDependencies()` dispatches `HomeLoadRequested` (covers initial mount and tab re-activation per FR-012); `BlocBuilder` maps: `HomeInitial`/`HomeLoading` → `LoadingIndicator`, `HomePopulated` (todayWorkout ≠ null) → `Column(HomeHeader, TodayWorkoutCard(onTap: () => context.go('/plans/${w.planId}/pre-start')))`, other states → placeholder (to be wired in later phases); `Scaffold` body is scrollable `SingleChildScrollView`; uses `AppColors.bg` as background

**Checkpoint (US1 complete)**: App shows loading indicator on Home tab activation, then today's workout card with correct data. Tapping card navigates. Hot-reload changes to `WorkoutPlanRecord` are reflected on next tab activation.

---

## Phase 4: User Story 2 — Navigate to Any Major App Area (Priority: P2)

**Goal**: Bottom nav tabs and the 5 quick-link tiles each navigate to the correct destination in one tap from any populated state.

**Independent Test** (VS-07 in quickstart.md): With any data in the database, tap each of the 5 bottom nav tabs in sequence — verify each switches without error. Tap each quick link tile from the Home populated state — verify navigation to the correct tab root.

**Note**: `StatefulShellRoute` and `AppShell` (T015, T016) are already complete from Phase 2. US2 only adds the `QuickLinksGrid` widget and wires it into `HomeScreen`.

### Implementation for User Story 2

- [X] T021 [P] [US2] Write `forge/lib/features/home/presentation/widgets/quick_links_grid.dart` — `QuickLinksGrid`; `GridView` with 5 `_QuickLinkTile` items (Plans → `context.go('/plans')`, Schedule → `context.go('/schedule')`, History → `context.go('/history')`, Progress → `context.go('/progress')`, Stats → `context.go('/stats')`); each tile: `Card(color: AppColors.cardAlt)` with centered icon + label (`theme.textTheme.labelMedium`, `AppColors.textMuted`); icons: fitness_center, calendar_today, history, trending_up, bar_chart
- [X] T022 [US2] Update `forge/lib/features/home/presentation/screens/home_screen.dart` — in `BlocBuilder`, add `QuickLinksGrid` below `TodayWorkoutCard` in the `HomePopulated` (todayWorkout ≠ null) branch; `QuickLinksGrid` also appears in rest-day branch (stubbed now; completed in US3)

**Checkpoint (US2 complete)**: All 6 bottom nav tabs switch correctly. Quick link tiles appear below today's workout card and navigate correctly. US1 behavior is unchanged.

---

## Phase 5: User Story 3 — First-Time Use and Rest Day (Priority: P3)

**Goal**: A user with no data sees the empty state with a working CTA. A user with data but no scheduled workout today sees the rest-day card alongside quick links.

**Independent Test** (VS-02 + VS-04 in quickstart.md): (a) Clear all Drift data → verify empty state with "Create your first workout plan" button; tapping switches to Plans tab and opens SCR-09. (b) Seed plans/history but no schedule entry for today → verify rest-day card + quick links appear.

### Implementation for User Story 3

- [X] T023 [P] [US3] Write `forge/lib/features/home/presentation/widgets/empty_state_view.dart` — `EmptyStateView({required VoidCallback onCreatePlan})`; centered `Column` with icon (`Icons.fitness_center`, `AppColors.textDim`, size 64), title "No workouts yet" (`theme.textTheme.titleLarge`, `AppColors.white`), subtitle "Create your first plan to get started" (`theme.textTheme.bodyMedium`, `AppColors.textMuted`), `ElevatedButton` "Create your first workout plan" (`AppColors.lime` bg, `AppColors.bg` text) that calls `onCreatePlan`
- [X] T024 [P] [US3] Write `forge/lib/features/home/presentation/widgets/rest_day_card.dart` — `RestDayCard`; non-tappable `Card(color: AppColors.card)` with icon, title "Rest Day" (`theme.textTheme.titleMedium`, `AppColors.white`), subtitle "No workout scheduled for today — enjoy the recovery." (`theme.textTheme.bodyMedium`, `AppColors.textMuted`)
- [X] T025 [US3] Update `forge/lib/features/home/presentation/screens/home_screen.dart` — wire remaining `BlocBuilder` state branches: `HomeEmpty` → `EmptyStateView(onCreatePlan: () => context.go('/plans/create'))`; `HomePopulated` (todayWorkout == null) → `Column(HomeHeader, RestDayCard, QuickLinksGrid)`

**Checkpoint (US3 complete)**: Three of four states (loading, empty, populated/scheduled, rest day) all render correctly and independently. US1 and US2 behavior unchanged.

---

## Phase 6: User Story 4 — Error Recovery (Priority: P4)

**Goal**: When database read fails, user sees an error card with a Retry button. Bottom nav remains interactive. Retry triggers a new loading → data cycle.

**Independent Test** (VS-05 in quickstart.md): Inject a mock `HomeDashboardLocalDataSource` that throws. Verify error card appears with "Couldn't load your dashboard" message and Retry button. Verify bottom nav tabs are still tappable. Tap Retry → loading indicator → resolves to data state.

### Implementation for User Story 4

- [X] T026 [P] [US4] Write `forge/lib/features/home/presentation/widgets/error_card.dart` — `ErrorCard({required String message, required VoidCallback onRetry})`; `Card(color: AppColors.dangerBg)` with `Border.all(color: AppColors.dangerBorder)` decoration; `Icon(Icons.error_outline, color: AppColors.danger)`; message text (`theme.textTheme.bodyMedium`, `AppColors.white`); `OutlinedButton` "Retry" with `AppColors.danger` foreground
- [X] T027 [US4] Update `forge/lib/features/home/presentation/screens/home_screen.dart` — add `HomeError` branch in `BlocBuilder`: renders `ErrorCard(message: state.message, onRetry: () => context.read<HomeBloc>().add(const HomeLoadRequested()))`

**Checkpoint (US4 complete)**: All 5 UI states (loading, empty, populated/scheduled, rest day, error) render correctly and independently. All user stories functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Tests, static analysis, and validation run against the complete implementation.

- [X] T028 [P] Write `forge/test/features/home/application/bloc/home_bloc_test.dart` — `blocTest` cases covering every state transition in contracts/home-bloc.md: initial load empty, initial load rest-day, initial load scheduled, initial load failure, retry after error, idempotent guard (duplicate HomeLoadRequested while loading), tab re-activation from HomePopulated; use `mocktail` to mock `GetDashboardSnapshotUseCase`
- [X] T029 [P] Write `forge/test/features/home/application/usecases/get_dashboard_snapshot_usecase_test.dart` — test that `call()` delegates to `HomeRepository.getDashboardSnapshot()` and returns its result unchanged (success and failure cases); mock `HomeRepository` via `mocktail`
- [X] T030 [P] Write `forge/test/features/home/data/datasources/home_local_data_source_test.dart` — unit tests for `HomeDashboardLocalDataSourceImpl`: `hasData=false` when all tables empty; `hasData=true` when `workout_plans` is non-empty; `todayWorkout=null` when no schedule entry for today; `todayWorkout` populated correctly when schedule entry matches today; `firstExerciseRestSec=null` when plan has no exercises; `dominantType` derived correctly (mode + tie-break); mock `WorkoutPlanLocalDataSource`, `ScheduleLocalDataSource`, `WorkoutSessionLocalDataSource` via `mocktail`
- [X] T031 [P] Write `forge/test/features/home/presentation/screens/home_screen_test.dart` — widget tests covering critical state rendering: `HomeLoading` → `LoadingIndicator` present; `HomeEmpty` → "Create your first workout plan" button present; `HomePopulated` (todayWorkout ≠ null) → plan name text present, `TodayWorkoutCard` present; `HomePopulated` (todayWorkout == null) → `RestDayCard` present; `HomeError` → "Retry" button present; pump `HomeScreen` with mock `HomeBloc` (via `BlocProvider`)
- [X] T032 Run `cd forge && dart format .` — apply consistent formatting to all changed files; confirm zero formatting issues
- [X] T033 Run `cd forge && flutter analyze` — resolve every analyzer warning or error introduced by this implementation; zero new issues permitted
- [X] T034 Run `cd forge && flutter test` — all 27+ pre-existing tests must still pass; new tests in T028–T031 must pass; report final test count
- [X] T035 Manually validate quickstart.md scenarios VS-01 through VS-07 on simulator or device — document results (pass/fail) in a comment on this task

**Checkpoint (Polish complete)**: All tests pass, analyzer clean, all 7 validation scenarios verified. Feature is implementation-complete.

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup)
    │
    ▼
Phase 2 (Foundational) — BLOCKS all user story phases
    │
    ├──▶ Phase 3 (US1 - P1) 🎯 MVP
    │          │
    │          ▼
    │    Phase 4 (US2 - P2) — adds QuickLinksGrid; wires into HomeScreen started in US1
    │          │
    │          ▼
    │    Phase 5 (US3 - P3) — adds EmptyStateView + RestDayCard; completes HomeScreen wiring
    │          │
    │          ▼
    │    Phase 6 (US4 - P4) — adds ErrorCard; completes final HomeScreen state
    │          │
    └──────────▼
         Phase 7 (Polish & Tests)
```

### Within Phase 2

Tasks marked [P] (T004, T005) can run in parallel. Execution order within Phase 2:

1. T004 + T005 in parallel (domain entities)
2. T006 (repository interface — depends on DashboardSnapshot from T004)
3. T007 (local data source — depends on entities T004, T005)
4. T008 (repository impl — depends on T006, T007)
5. T009 (use case — depends on T006)
6. T010 + T011 in parallel (event + state)
7. T012 (Bloc — depends on T010, T011, T009)
8. T013 (GetIt update — depends on T007, T008, T009, T012)
9. T014 in parallel with T015 (widgets; no dependencies on each other)
10. T016 (routes — depends on T014, T015)

### Within Phase 3

T017, T018, T019 are fully parallel (different widget files). T020 (HomeScreen) depends on T017–T019.

### Within Phase 7

T028–T031 are fully parallel (different test files). T032–T034 are sequential (format → analyze → test). T035 is last.

---

## Parallel Execution Examples

### Phase 2 — Domain layer (can start together)

```
Task T004: Write DashboardSnapshot entity
Task T005: Write TodayWorkout entity
```

### Phase 3 — Widget layer (can start together after T016 complete)

```
Task T017: Write HomeHeader widget
Task T018: Write LoadingIndicator widget
Task T019: Write TodayWorkoutCard widget
```

### Phase 7 — Test layer (can start together after T027 complete)

```
Task T028: Write home_bloc_test.dart
Task T029: Write get_dashboard_snapshot_usecase_test.dart
Task T030: Write home_local_data_source_test.dart
Task T031: Write home_screen_test.dart
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup — delete stale files)
2. Complete Phase 2 (Foundational — all infrastructure)
3. Complete Phase 3 (US1 — loading + today's workout card)
4. **STOP and VALIDATE**: Use VS-01 and VS-03 from quickstart.md
5. Home tab shows loading indicator and today's workout card ✓

### Incremental Delivery

1. Setup + Foundational → foundation ready, app boots with 6-tab shell
2. + US1 → loading state + today's workout card functional (MVP)
3. + US2 → quick links + all tab navigation functional
4. + US3 → empty state + rest-day card functional (all populated states complete)
5. + US4 → error recovery functional (all 5 states complete)
6. Polish → tests pass, analyzer clean, scenarios verified

---

## Task Summary

| Phase | Tasks | Story | Parallel Opportunities |
|---|---|---|---|
| Phase 1: Setup | T001–T003 | — | T001–T003 can run in parallel |
| Phase 2: Foundational | T004–T016 | — | T004+T005, T010+T011, T014+T015 |
| Phase 3: US1 (P1) 🎯 | T017–T020 | US1 | T017+T018+T019 |
| Phase 4: US2 (P2) | T021–T022 | US2 | T021 before T022 |
| Phase 5: US3 (P3) | T023–T025 | US3 | T023+T024 before T025 |
| Phase 6: US4 (P4) | T026–T027 | US4 | T026 before T027 |
| Phase 7: Polish | T028–T035 | — | T028+T029+T030+T031 |
| **Total** | **35 tasks** | | |

| User Story | Tasks | Files |
|---|---|---|
| US1 — Today's Workout (P1) | T017–T020 (4 tasks) | HomeHeader, LoadingIndicator, TodayWorkoutCard, HomeScreen |
| US2 — Navigation (P2) | T021–T022 (2 tasks) | QuickLinksGrid, HomeScreen (update) |
| US3 — Empty + Rest Day (P3) | T023–T025 (3 tasks) | EmptyStateView, RestDayCard, HomeScreen (update) |
| US4 — Error Recovery (P4) | T026–T027 (2 tasks) | ErrorCard, HomeScreen (update) |

**Suggested MVP scope**: Complete Phase 1 + Phase 2 + Phase 3 (tasks T001–T020) for a functional loading + today's workout state.

---

## Notes

- All tasks reference exact file paths per project convention (`forge/lib/…`)
- table access is **read-only** throughout — `HomeScreen` writes nothing (FR-009)
- `flutter analyze` must produce zero new warnings; existing baseline warnings are pre-existing and not part of this feature's scope
- No Git operations — all tasks are filesystem operations only (constitution: Mandatory Rule)
- `home_screen.dart` is updated across US1–US4 phases; each update adds one state branch to the `BlocBuilder` without altering previous branches
