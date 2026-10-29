# Tasks: SCR-08 Workout Plans List

**Input**: Design documents from `specs/SCR-08-Workout-Plans-List/mobile/001-workout-plans-list/`

**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | quickstart.md ✅

**Tests**: Included per constitution rule 87 (tests are mandatory for business logic, state transitions, and critical flows; manual fakes used — `bloc_test`/`mocktail` are not in the governed dependency set; same pattern as SCR-06 and SCR-07).

**Organization**: Tasks grouped by user story (US1–US5) in spec priority order (P1→P5).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: Which user story (US1–US5)
- Paths are relative to repo root

---

## Phase 1: Setup

**Purpose**: Create directory structure for all new feature layers.

- [X] T001 Create directories: `forge/lib/core/navigation/`, `forge/lib/features/workout_plan/domain/{entities,repositories,usecases}`, `forge/lib/features/workout_plan/application/bloc`, `forge/lib/features/workout_plan/data/{mappers,repositories}`, `forge/lib/features/workout_plan/presentation/{screens,widgets}`, `forge/test/features/workout_plan/{domain/entities,application/bloc,data/{mappers,repositories},presentation/screens}`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure — reload notifier, domain entity, repository interface, use case, mapper, repo impl, Bloc skeleton, DI registration, route update, AppShell modification — must all exist before any screen or test can compile.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 [P] Create `WorkoutPlansReloadNotifier` (`extends ChangeNotifier`; single `notify()` method that calls `notifyListeners()`) in `forge/lib/core/navigation/workout_plans_reload_notifier.dart`
- [X] T003 [P] Create `WorkoutPlan` domain entity (`id: String`, `name: String`, `exerciseCount: int`, `createdAt: DateTime`; `extends Equatable`; no Drift import) in `forge/lib/features/workout_plan/domain/entities/workout_plan.dart`
- [X] T004 [P] Create `WorkoutPlanRepository` abstract interface (`Future<Either<AppException, List<WorkoutPlan>>> getAllPlans()`) in `forge/lib/features/workout_plan/domain/repositories/workout_plan_repository.dart`
- [X] T005 Create `GetWorkoutPlansUseCase` (constructor-injected `WorkoutPlanRepository`; single `call()` that delegates to `repository.getAllPlans()`) in `forge/lib/features/workout_plan/domain/usecases/get_workout_plans_usecase.dart`
- [X] T006 [P] Create `WorkoutPlanMapper` (static `WorkoutPlan fromRecord(WorkoutPlanRecord model)` mapping `planId→id`, `name→name`, `planExercises.length→exerciseCount`, `createdAt→createdAt`) in `forge/lib/features/workout_plan/data/mappers/workout_plan_mapper.dart`
- [X] T007 Create `WorkoutPlanRepositoryImpl` (implements `WorkoutPlanRepository`; constructor-injected `WorkoutPlanLocalDataSource`; `getAllPlans()` calls `dataSource.getAllPlans()`, sorts by `createdAt` descending with `..sort((a, b) => b.createdAt.compareTo(a.createdAt))`, maps with `WorkoutPlanMapper.fromRecord`, wraps exceptions in `Left(CacheException(...))`) in `forge/lib/features/workout_plan/data/repositories/workout_plan_repository_impl.dart`
- [X] T008 [P] Create `WorkoutPlansEvent` sealed class (`WorkoutPlansLoadRequested` — single event, no fields) in `forge/lib/features/workout_plan/application/bloc/workout_plans_event.dart`
- [X] T009 [P] Create `WorkoutPlansState` sealed class (`WorkoutPlansInitial`, `WorkoutPlansLoading`, `WorkoutPlansPopulated(plans: List<WorkoutPlan>)`, `WorkoutPlansEmpty`, `WorkoutPlansError(message: String)`; all `extends Equatable`) in `forge/lib/features/workout_plan/application/bloc/workout_plans_state.dart`
- [X] T010 Create `WorkoutPlansBloc` (`extends Bloc<WorkoutPlansEvent, WorkoutPlansState>`; constructor-injected `GetWorkoutPlansUseCase`; registers `_onLoadRequested` handler; optimistic re-read: skip emitting `WorkoutPlansLoading` when current state is `WorkoutPlansPopulated` or `WorkoutPlansEmpty`; emit Loading from Initial or Error; emit Populated/Empty/Error after read) in `forge/lib/features/workout_plan/application/bloc/workout_plans_bloc.dart`
- [X] T011 Register in `forge/lib/app/get_it_setup.dart`: `WorkoutPlanRepository` as `registerLazySingleton<WorkoutPlanRepository>(() => WorkoutPlanRepositoryImpl(getIt()))`, `GetWorkoutPlansUseCase` as `registerLazySingleton`, `WorkoutPlansBloc` as `registerFactory`, `WorkoutPlansReloadNotifier` as `registerLazySingleton`
- [X] T012 Update `forge/lib/config/routes/app_routes.dart`: replace `PlaceholderTabScreen` builder at `RoutePaths.plans` (`/plans`) with `BlocProvider(create: (_) => getIt<WorkoutPlansBloc>(), child: const WorkoutPlansScreen())`; add `RoutePaths.planDetail = '/plans/:planId'` constant and stub `GoRoute(path: RoutePaths.planDetail, builder: (context, state) => PlaceholderTabScreen(label: 'Plan Detail: ${state.pathParameters['planId']}'))`
- [X] T013 Update `forge/lib/features/home/presentation/screens/app_shell.dart`: call `getIt<WorkoutPlansReloadNotifier>().notify()` whenever `navigationShell.currentIndex` changes to 1 (Plans tab), using `didUpdateWidget` or wrapping the `goBranch` call in an `onDestinationSelected`-style callback

**Checkpoint**: `flutter analyze` passes with no new errors; DI and routing compile cleanly.

---

## Phase 3: User Story 1 — View Plans: Loading & Populated (Priority: P1) 🎯 MVP

**Goal**: User taps Plans tab, sees 4-card skeleton immediately, then a scrollable newest-first plan list where each row shows name, exercise count, and chevron. App bar shows "Workout Plans" title and a lime "+" FAB in the populated state.

**Independent Test**: Seed Drift with 2+ plans (different `createdAt` values). Navigate to Plans tab. Verify skeleton renders first; after read, list shows plans newest-first with correct name, exercise count, and chevron per row. Verify `flutter test test/features/workout_plan/` passes.

### Tests for User Story 1

- [X] T014 [P] [US1] Write `WorkoutPlan` entity unit tests (equality, `props`, distinct field values) in `forge/test/features/workout_plan/domain/entities/workout_plan_test.dart`
- [X] T015 [P] [US1] Write `WorkoutPlanMapper` unit tests (`planId→id`, `planExercises.length→exerciseCount` including 0 and 1, `createdAt` preserved) in `forge/test/features/workout_plan/data/mappers/workout_plan_mapper_test.dart`
- [X] T016 [P] [US1] Write `WorkoutPlanRepositoryImpl` unit tests (success: returns newest-first sorted list; database exception returns `Left(CacheException)`) using manual fake `FakeWorkoutPlanLocalDataSource` in `forge/test/features/workout_plan/data/repositories/workout_plan_repository_impl_test.dart`
- [X] T017 [P] [US1] Write `WorkoutPlansBloc` unit tests: (a) Initial→LoadRequested emits Loading then Populated; (b) Initial→LoadRequested emits Loading then Empty when list is empty; (c) Populated→LoadRequested does NOT emit Loading (optimistic re-read stays on Populated); (d) Empty→LoadRequested does NOT emit Loading (optimistic re-read stays on Empty); (e) Error→LoadRequested emits Loading (retry shows skeleton); (f) LoadRequested with database error emits Error. Use manual fake `FakeGetWorkoutPlansUseCase` in `forge/test/features/workout_plan/application/bloc/workout_plans_bloc_test.dart`

### Implementation for User Story 1

- [X] T018 [P] [US1] Create `PlansSkeletonList` widget (4 skeleton plan cards using `AppColors.card` fill, `AppColors.border` border, 16 pt radius; each card has two shimmer lines at 65% / 15 pt and 32% / 11 pt; shimmer `AnimationController` 1.4 s ease infinite; skeleton FAB placeholder 38 × 38 pt `AppColors.card` fill 12 pt radius in app bar area) in `forge/lib/features/workout_plan/presentation/widgets/plans_skeleton_list.dart`
- [X] T019 [US1] Create `PlanCard` widget (takes `WorkoutPlan plan` and `VoidCallback? onTap`; displays `plan.name` in `textTheme.bodyLarge` 800-weight `AppColors.white` truncated 1 line ellipsis; displays `_exerciseLabel(plan.exerciseCount)` helper `count == 1 ? '1 exercise' : '$count exercises'` in `textTheme.bodySmall` `AppColors.textMuted`; trailing `Icon(Icons.chevron_right, color: AppColors.textDim)`; `InkWell` wrapping full card) in `forge/lib/features/workout_plan/presentation/widgets/plan_card.dart`
- [X] T020 [US1] Create `WorkoutPlansScreen` as `StatefulWidget` (subscribes to `getIt<WorkoutPlansReloadNotifier>()` in `initState`, removes listener in `dispose`; `_onTabActivated` guards with `mounted` check before dispatching `WorkoutPlansLoadRequested`; dispatches `WorkoutPlansLoadRequested` immediately in `initState`; app bar title "Workout Plans" via `textTheme.headlineSmall`; no leading back button) in `forge/lib/features/workout_plan/presentation/screens/workout_plans_screen.dart`
- [X] T021 [US1] Add `BlocBuilder<WorkoutPlansBloc, WorkoutPlansState>` to `WorkoutPlansScreen` body: `WorkoutPlansLoading` → `PlansSkeletonList()`; `WorkoutPlansPopulated` → `ListView.builder` of `PlanCard` widgets (no onTap yet — added in T024); `WorkoutPlansEmpty` → placeholder `SizedBox.shrink()` (replaced in T023); `WorkoutPlansError` → placeholder `SizedBox.shrink()` (replaced in T028); in `forge/lib/features/workout_plan/presentation/screens/workout_plans_screen.dart`

**Checkpoint**: Plans tab shows skeleton → populated list; newest-first sort confirmed; tests pass.

---

## Phase 4: User Story 2 — Empty State: Create First Plan (Priority: P2)

**Goal**: When `workout_plans` table is empty, show centred icon + "No workout plans yet" + subtitle + lime "Create a workout plan" button. No "+" FAB visible.

**Independent Test**: Launch with empty `workout_plans` table. Navigate to Plans tab. Verify empty state renders with correct icon, title, subtitle, and lime CTA button. Verify no "+" FAB in app bar.

### Tests for User Story 2

- [X] T022 [P] [US2] Write `WorkoutPlansScreen` widget test for `WorkoutPlansEmpty` state: verifies `PlansEmptyState` renders (icon, "No workout plans yet" title, "Build your first workout plan to see it listed here." subtitle, "Create a workout plan" button); verifies no "+" FAB visible in `forge/test/features/workout_plan/presentation/screens/workout_plans_screen_test.dart`

### Implementation for User Story 2

- [X] T023 [US2] Create `PlansEmptyState` widget (centred column: 60 pt list `Icon(Icons.list_alt_outlined, color: AppColors.textMuted, size: 60)`; `Text('No workout plans yet', style: textTheme.titleMedium)` `AppColors.white`; `Text('Build your first workout plan to see it listed here.', style: textTheme.bodyMedium)` `AppColors.textMuted` centered; `ElevatedButton` lime fill "Create a workout plan" with `onPressed` callback; no "+" FAB) in `forge/lib/features/workout_plan/presentation/widgets/plans_empty_state.dart`; replace `SizedBox.shrink()` placeholder for `WorkoutPlansEmpty` in `WorkoutPlansScreen` with `PlansEmptyState(onCreateTap: () => context.push(RoutePaths.plansCreate))`

**Checkpoint**: Empty state renders correctly; CTA button exists; no "+" FAB; tests pass.

---

## Phase 5: User Story 3 — Navigate to Plan Detail (Priority: P3)

**Goal**: Tapping any part of a plan card navigates to SCR-10 (Plan Detail) at `/plans/:planId` via `context.go`. Back gesture returns to Plans list.

**Independent Test**: Tap a plan card in the populated list. Verify `context.go('/plans/${plan.id}')` fires and the stub Plan Detail screen opens. Verify back navigation returns to Plans list.

### Tests for User Story 3

- [X] T024 [P] [US3] Write `PlanCard` widget test: verify `onTap` callback fires when card is tapped anywhere on the row in `forge/test/features/workout_plan/presentation/screens/workout_plans_screen_test.dart`

### Implementation for User Story 3

- [X] T025 [US3] Update `PlanCard.onTap` to call `context.go('/plans/${plan.id}')` — pass `onTap: () => context.go('/plans/${plan.id}')` from the `ListView.builder` in `WorkoutPlansScreen` in `forge/lib/features/workout_plan/presentation/screens/workout_plans_screen.dart` and `forge/lib/features/workout_plan/presentation/widgets/plan_card.dart`

**Checkpoint**: Tapping a plan card navigates to stub Plan Detail screen; back returns to Plans list.

---

## Phase 6: User Story 4 — Create a New Plan (FAB) (Priority: P4)

**Goal**: Lime "+" FAB appears in app bar only in `WorkoutPlansPopulated` state. Tapping it navigates to SCR-09 (Create Plan) via `context.push(RoutePaths.plansCreate)`. FAB is absent in Loading, Empty, and Error states.

**Independent Test**: In populated state, verify lime "+" FAB renders and tapping it pushes `RoutePaths.plansCreate`. Verify FAB is absent in all other states.

### Tests for User Story 4

- [X] T026 [P] [US4] Write `WorkoutPlansScreen` widget tests for FAB visibility: FAB present when `WorkoutPlansPopulated`; FAB absent when `WorkoutPlansLoading`, `WorkoutPlansEmpty`, `WorkoutPlansError` in `forge/test/features/workout_plan/presentation/screens/workout_plans_screen_test.dart`

### Implementation for User Story 4

- [X] T027 [US4] Add lime "+" FAB to `WorkoutPlansScreen` app bar: conditionally show `IconButton` or custom 38 × 38 pt container (`AppColors.lime` fill, `AppColors.bg` icon, `Icons.add`, 12 pt radius) in `actions` only when `state is WorkoutPlansPopulated`; `onPressed: () => context.push(RoutePaths.plansCreate)` in `forge/lib/features/workout_plan/presentation/screens/workout_plans_screen.dart`

**Checkpoint**: Lime "+" FAB visible only in Populated state; tapping pushes to Plans Create screen; tests pass.

---

## Phase 7: User Story 5 — Recover from Plan Load Failure (Priority: P5)

**Goal**: On database read failure, show `ErrorCard` with warning icon, "Couldn't load your workout plans" title, "Something went wrong reading local data.\nYour history is unaffected." body, and lime Retry button. Tapping Retry emits `WorkoutPlansLoadRequested` → transitions to Loading → re-runs read.

**Independent Test**: Simulate database read exception via fake data source. Verify error card renders with correct copy and danger-bordered container. Tap Retry; verify skeleton loading state appears and a fresh read runs.

### Tests for User Story 5

- [X] T028 [P] [US5] Write `WorkoutPlansScreen` widget test for `WorkoutPlansError` state: verifies `ErrorCard` renders with correct message; verifies Retry tap dispatches `WorkoutPlansLoadRequested` (transitions to Loading); verifies FAB absent in error state in `forge/test/features/workout_plan/presentation/screens/workout_plans_screen_test.dart`

### Implementation for User Story 5

- [X] T029 [US5] Replace `SizedBox.shrink()` placeholder for `WorkoutPlansError` in `WorkoutPlansScreen` `BlocBuilder` with `ErrorCard(message: "Couldn't load your workout plans", onRetry: () => context.read<WorkoutPlansBloc>().add(const WorkoutPlansLoadRequested()))` (reuse existing widget from `forge/lib/features/home/presentation/widgets/error_card.dart`) in `forge/lib/features/workout_plan/presentation/screens/workout_plans_screen.dart`

**Checkpoint**: Error card renders with correct copy; Retry transitions to Loading; FAB absent in Error; tests pass.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Format, analyze, test, and manually validate all 11 quickstart scenarios.

- [X] T030 [P] Run `dart format .` in `forge/` and fix any formatting issues introduced by this feature
- [X] T031 Run `flutter analyze` in `forge/` and resolve every new warning or error introduced by this feature
- [X] T032 Run `flutter test` in `forge/` and verify all new and existing tests pass (no regressions in SCR-07 exercise catalogue or home feature tests)
- [ ] T033 Run quickstart.md manual validation VS-01 through VS-11 on iOS Simulator (see `specs/SCR-08-Workout-Plans-List/mobile/001-workout-plans-list/quickstart.md`)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **User Stories (Phase 3–7)**: All depend on Foundational phase completion
  - Proceed sequentially P1→P2→P3→P4→P5 (each story builds on previous screen state)
- **Polish (Phase 8)**: Depends on all user stories being complete

### Within Phase 2 (Foundational)

- T002–T004, T006, T008–T009 can run in parallel (different files, no shared dependencies)
- T005 depends on T003, T004
- T007 depends on T003, T004, T006
- T010 depends on T005, T008, T009
- T011 depends on T002, T003, T004, T005, T006, T007, T010
- T012 depends on T010, T011
- T013 depends on T002, T011

### Within Phase 3 (US1)

- T014–T017 (tests) and T018 (PlansSkeletonList) can run in parallel
- T019 (PlanCard) depends on T003 (WorkoutPlan entity)
- T020 (WorkoutPlansScreen) depends on T002, T010, T012
- T021 (BlocBuilder wiring) depends on T018, T019, T020

### Within Phases 4–7

- Tests [P] can run in parallel with (or before) the implementation tasks in each story
- Implementation tasks within a story must run sequentially

---

## Parallel Opportunities

### Phase 2 parallel batch

```
T002 WorkoutPlansReloadNotifier
T003 WorkoutPlan entity
T004 WorkoutPlanRepository interface
T006 WorkoutPlanMapper
T008 WorkoutPlansEvent
T009 WorkoutPlansState
```

### Phase 3 parallel batch

```
T014 WorkoutPlan entity tests
T015 WorkoutPlanMapper tests
T016 WorkoutPlanRepositoryImpl tests
T017 WorkoutPlansBloc tests
T018 PlansSkeletonList widget
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: User Story 1 (Loading + Populated states)
4. **STOP and VALIDATE**: `flutter test`, manual VS-01 and VS-02
5. Proceed to P2→P5 incrementally

### Incremental Delivery

1. Setup + Foundational → Plans tab route compiles
2. US1 (P1) → Plans tab shows real data; skeleton + populated working
3. US2 (P2) → Empty state CTA navigates to plan creation
4. US3 (P3) → Plan card tap navigates to detail
5. US4 (P4) → "+" FAB accessible in populated state
6. US5 (P5) → Error recovery; retry works

---

## Notes

- [P] tasks = different files, no shared dependencies
- `WorkoutPlansBloc` is registered as `registerFactory` (new instance per route) — do NOT register as `registerLazySingleton`
- `WorkoutPlansReloadNotifier` is registered as `registerLazySingleton` — shared singleton across `AppShell` and `WorkoutPlansScreen`
- `ErrorCard` is reused from `forge/lib/features/home/presentation/widgets/error_card.dart` — do NOT create a new error widget
- Exercise count label: `count == 1 ? '1 exercise' : '$count exercises'` — test VS-08 covers the singular case
- Optimistic re-read: Bloc skips `WorkoutPlansLoading` when state is already `WorkoutPlansPopulated` or `WorkoutPlansEmpty` — test T017(c) and T017(d) cover this
- AppStrings: add any new user-facing string ("Workout Plans", "No workout plans yet", "Build your first workout plan to see it listed here.", "Create a workout plan", "Couldn't load your workout plans", "Something went wrong reading local data.\nYour history is unaffected.") to `AppStrings` before use in widgets
