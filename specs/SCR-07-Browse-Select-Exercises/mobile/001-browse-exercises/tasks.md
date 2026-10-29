# Tasks: SCR-07 Browse & Select Exercises

**Input**: Design documents from `specs/SCR-07-Browse-Select-Exercises/mobile/001-browse-exercises/`

**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ui-contract.md ✅ | quickstart.md ✅

**Tests**: Included per constitution XI.3 (tests are mandatory feature work; manual fakes used — `bloc_test`/`mocktail` are not in the governed dependency set; see SCR-06 precedent).

**Organization**: Tasks grouped by user story. US1→US4 in spec priority order (P1→P4).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: Which user story (US1–US4)
- Paths are relative to repo root

---

## Phase 1: Setup

**Purpose**: Create missing directory structure for the exercise feature's new layers.

- [X] T001 Create directories: `forge/lib/features/exercise/domain/{entities,repositories,usecases}`, `forge/lib/features/exercise/application/bloc`, `forge/lib/features/exercise/data/{mappers,repositories}`, `forge/lib/features/exercise/presentation/{screens,widgets}`, `forge/test/features/exercise/{domain/entities,application/{bloc,usecases},data/{mappers,repositories},presentation/screens}`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, repository interface, use case, mapper, repo impl, Bloc skeleton, DI registration, and route — must all exist before any screen or test can run.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 [P] Create `Exercise` domain entity (id, name, type; Equatable; no Drift import) in `forge/lib/features/exercise/domain/entities/exercise.dart`
- [X] T003 [P] Create `PickerContext` value object (planName; Equatable) in `forge/lib/features/exercise/domain/entities/picker_context.dart`
- [X] T004 [P] Create `ExerciseRepository` abstract interface (`Future<Either<AppException, List<Exercise>>> getExercises()`) in `forge/lib/features/exercise/domain/repositories/exercise_repository.dart`
- [X] T005 Create `GetExercisesUseCase` (delegates to `ExerciseRepository.getExercises()`) in `forge/lib/features/exercise/domain/usecases/get_exercises_usecase.dart`
- [X] T006 [P] Create `ExerciseMapper` (static `Exercise fromRecord(ExerciseRecord)` method) in `forge/lib/features/exercise/data/mappers/exercise_mapper.dart`
- [X] T007 Create `ExerciseRepositoryImpl` (reads `ExerciseLocalDataSource.getAllExercises()`, maps with `ExerciseMapper`, catches database exceptions → `Left(CacheException(...))`) in `forge/lib/features/exercise/data/repositories/exercise_repository_impl.dart`
- [X] T008 [P] Create `ExerciseCatalogueEvent` sealed class (`ExerciseCatalogueLoadRequested`, `ExerciseCatalogueSearchChanged(String query)`, `ExerciseCatalogueFilterChanged(ExerciseType? type)`) in `forge/lib/features/exercise/application/bloc/exercise_catalogue_event.dart`
- [X] T009 [P] Create `ExerciseCatalogueState` sealed class (`Initial`, `Loading`, `Populated(displayedExercises, query, activeFilter)`, `Empty(query, activeFilter)`, `Error(message)`; all Equatable) in `forge/lib/features/exercise/application/bloc/exercise_catalogue_state.dart`
- [X] T010 Create `ExerciseCatalogueBloc` skeleton (constructor takes `GetExercisesUseCase`; registers `ExerciseCatalogueLoadRequested` handler with idempotent guard; emits Loading → Populated/Empty/Error; `_allExercises` internal list) in `forge/lib/features/exercise/application/bloc/exercise_catalogue_bloc.dart`
- [X] T011 Register `ExerciseRepository`, `GetExercisesUseCase`, `ExerciseCatalogueBloc` in `forge/lib/app/get_it_setup.dart` (registerLazySingleton for repo + usecase; registerFactory for Bloc)
- [X] T012 Add `RoutePaths.planExercises = '/plans/exercises'` constant and GoRoute under the Plans branch in `forge/lib/config/routes/app_routes.dart` (builder casts `state.extra as PickerContext?`, provides `ExerciseCatalogueBloc` via `BlocProvider`)

**Checkpoint**: `flutter analyze` passes with no new errors; DI and routing compile cleanly.

---

## Phase 3: User Story 1 — View Exercise Catalogue (Priority: P1) 🎯 MVP

**Goal**: User navigates to `/plans/exercises` in browse mode, sees the skeleton loading state while the database is read, then the full exercise list. Each row shows name, type-coloured dot, type label, and a decorative chevron. A database error shows the error card.

**Independent Test**: Navigate to the screen; confirm skeleton renders during load (6 rows, 4 chips, non-interactive search); confirm full list renders with correct row anatomy; confirm a tapped browse-mode row produces no action (FR-014); confirm error card appears on database failure.

### Tests for User Story 1

- [X] T013 [P] [US1] Write `Exercise` entity unit tests (equality, value semantics) in `forge/test/features/exercise/domain/entities/exercise_test.dart`
- [X] T014 [P] [US1] Write `ExerciseMapper` unit tests (all three ExerciseTypes map correctly; name/id preserved) in `forge/test/features/exercise/data/mappers/exercise_mapper_test.dart`
- [X] T015 [P] [US1] Write `GetExercisesUseCase` unit tests (delegates to repo, returns Right/Left unchanged) in `forge/test/features/exercise/application/usecases/get_exercises_usecase_test.dart`
- [X] T016 [P] [US1] Write `ExerciseRepositoryImpl` unit tests (success returns mapped list; database exception returns `Left(CacheException)`) in `forge/test/features/exercise/data/repositories/exercise_repository_impl_test.dart`
- [X] T017 [US1] Write `ExerciseCatalogueBloc` unit tests for load scenarios: initial state, `LoadRequested` → [Loading, Populated], `LoadRequested` → [Loading, Empty] (0 exercises), `LoadRequested` → [Loading, Error] on failure, idempotent guard (second `LoadRequested` while Loading is ignored) in `forge/test/features/exercise/application/bloc/exercise_catalogue_bloc_test.dart`

### Implementation for User Story 1

- [X] T018 [US1] Create `ExerciseSkeletonList` widget (6 shimmer skeleton rows + 4 skeleton chip placeholders; `AnimationController` via `TickerProviderStateMixin` on parent or own `StatefulWidget`; gradient `const Color(0xFF2A2A2C)` → `const Color(0xFF35342F)` → `const Color(0xFF2A2A2C)`, 1.4 s) in `forge/lib/features/exercise/presentation/widgets/exercise_skeleton_list.dart`
- [X] T019 [US1] Create `ExerciseListItem` widget (browse mode: plain `Container` with no `InkWell` — name in `textTheme.bodyMedium` weight 700 `AppColors.white`, 7 px type dot, type label `AppColors.textMuted`, trailing `Icon(Icons.chevron_right)` in `AppColors.textDim`; picker mode stubbed as TODO — implemented in T029) in `forge/lib/features/exercise/presentation/widgets/exercise_list_item.dart`
- [X] T020 [US1] Create `ExerciseCatalogueScreen` (StatefulWidget with `AnimationController` for shimmer; `BlocBuilder` mapping `ExerciseCatalogueState` → skeleton / list / error; browse mode only; app bar "Exercise Catalogue" with back icon; `SafeArea`, `AppColors.bg` background; no bottom nav) in `forge/lib/features/exercise/presentation/screens/exercise_catalogue_screen.dart`
- [X] T021 [US1] Write widget tests for `ExerciseCatalogueScreen` (US1 scenarios: shows skeleton during load; shows exercise list rows with name + type label; browse-mode row produces no navigation on tap; `ErrorCard` renders on `ExerciseCatalogueError`) in `forge/test/features/exercise/presentation/screens/exercise_catalogue_screen_test.dart`

**Checkpoint**: Run `flutter test test/features/exercise/` — all T013–T021 tests pass. Navigate to `/plans/exercises` in browse mode and confirm VS-01 quickstart scenario.

---

## Phase 4: User Story 2 — Search and Filter Exercises (Priority: P2)

**Goal**: User can type in the search bar to filter exercises by name substring; tap filter chips to narrow by type; combined search+filter works; empty state appears when zero results match.

**Independent Test**: Type `"bench"` → list narrows to bench exercises; tap "Weighted" chip → only weighted exercises; type "zzz" with any filter → empty state renders; clear search → list restores.

### Tests for User Story 2

- [X] T022 [P] [US2] Extend `ExerciseCatalogueBloc` unit tests (search narrows correctly; filter by type; combined search+filter; clearing search restores; `FilterChanged(null)` = All; empty state emitted when 0 results) in `forge/test/features/exercise/application/bloc/exercise_catalogue_bloc_test.dart`
- [X] T023 [P] [US2] Write widget tests for search + filter UI (search field visible when populated; typing dispatches `SearchChanged`; chip tap dispatches `FilterChanged`; empty state widget visible when `ExerciseCatalogueEmpty`; lime border on search bar when query non-empty) in `forge/test/features/exercise/presentation/screens/exercise_catalogue_screen_test.dart`

### Implementation for User Story 2

- [X] T024 [P] [US2] Create `ExerciseSearchBar` widget (`TextEditingController` param; `AppColors.card` fill, `AppColors.border` default border; `AppColors.lime` border + icon when `isActive`; magnifier icon; placeholder "Search exercises"; `AppColors.textDim`) in `forge/lib/features/exercise/presentation/widgets/exercise_search_bar.dart`
- [X] T025 [P] [US2] Create `ExerciseFilterChips` widget (4 chips: All / Weighted / Time-based / Bodyweight; `ExerciseType?` active filter; lime bg+dark text when active; `AppColors.card` bg+`AppColors.textMuted` text when inactive; horizontal `SingleChildScrollView` for small screens) in `forge/lib/features/exercise/presentation/widgets/exercise_filter_chips.dart`
- [X] T026 [P] [US2] Create `ExerciseCatalogueEmptyState` widget (centred column; `Icons.search_off` 52 px `AppColors.textDim`; title "No exercises match your search" 16 px 800 `AppColors.white`; subtitle "Try a different name or clear the filter." 13 px `AppColors.textMuted`) in `forge/lib/features/exercise/presentation/widgets/exercise_catalogue_empty_state.dart`
- [X] T027 [US2] Add `ExerciseCatalogueSearchChanged` + `ExerciseCatalogueFilterChanged` handlers to `ExerciseCatalogueBloc` (`SearchChanged` with `transformer: restartable()` + 300 ms `Future.delayed`; `FilterChanged` synchronous; `_applyFilter` private method; `_activeFilter` stored in Bloc) in `forge/lib/features/exercise/application/bloc/exercise_catalogue_bloc.dart`
- [X] T028 [US2] Integrate `ExerciseSearchBar`, `ExerciseFilterChips`, `ExerciseCatalogueEmptyState` into `ExerciseCatalogueScreen`; wire `TextEditingController` to dispatch `SearchChanged`; wire chip callback to dispatch `FilterChanged`; hide search+chips in `ExerciseCatalogueError` state (FR-010) in `forge/lib/features/exercise/presentation/screens/exercise_catalogue_screen.dart`

**Checkpoint**: Run `flutter test test/features/exercise/` — all tests pass. Confirm VS-02 through VS-05 quickstart scenarios.

---

## Phase 5: User Story 3 — Add Exercise to Workout Plan / Picker Mode (Priority: P3)

**Goal**: When screen is entered with a `PickerContext` extra, a picker banner shows the plan name, each row shows a circular "+" button instead of a chevron, and tapping "+" pops the screen returning the `exerciseId` to the caller.

**Independent Test**: Push `/plans/exercises` with `extra: PickerContext(planName: 'Push Day')`; verify picker banner "Adding an exercise to Push Day" visible; verify each row has circular "+" button; tap "+" → `context.pop(exerciseId)` called; back without "+" → `context.pop()` with no value.

### Tests for User Story 3

- [X] T029 [US3] Extend widget tests for `ExerciseCatalogueScreen` (picker mode: banner visible with plan name; "+" button visible per row; tapping "+" pops with exerciseId; back with no selection pops with no value; search+filter still works in picker mode) in `forge/test/features/exercise/presentation/screens/exercise_catalogue_screen_test.dart`

### Implementation for User Story 3

- [X] T030 [US3] Create `PickerBanner` widget ("Adding an exercise to **[Plan Name]**"; `AppColors.cardAlt` fill, `AppColors.border` border, 12 px radius; `Icons.list` 16 px `const Color(0xFF7DF4FF)` cyan; 12 px `AppColors.textMuted` text with bold `AppColors.white` plan name) in `forge/lib/features/exercise/presentation/widgets/picker_banner.dart`
- [X] T031 [US3] Complete `ExerciseListItem` picker mode (replace chevron with 28×28 px `AppColors.lime` circular `InkWell` + `Icon(Icons.add)` in `AppColors.bg`; `onAddTap` callback; 44 px min-tap-target via `Material`/`InkWell` padding) in `forge/lib/features/exercise/presentation/widgets/exercise_list_item.dart`
- [X] T032 [US3] Integrate picker mode into `ExerciseCatalogueScreen`: read `pickerContext` from constructor; show `PickerBanner` when non-null; pass `isPickerMode` and `onAddTap: () => context.pop(exercise.id)` to `ExerciseListItem`; validate `exercise.id` via `_allExercises` before pop (silent reject if not found) in `forge/lib/features/exercise/presentation/screens/exercise_catalogue_screen.dart`

**Checkpoint**: Run `flutter test test/features/exercise/` — all tests pass. Confirm VS-07 through VS-09 quickstart scenarios.

---

## Phase 6: User Story 4 — Error Recovery (Priority: P4)

**Goal**: Tapping Retry in the error state re-triggers the load cycle (Loading → Populated or Error again). The back icon is available in all states including error.

**Independent Test**: Drive Bloc into `ExerciseCatalogueError`; tap Retry button; Bloc emits `Loading` → `Populated` or `Error`. Back icon visible and tappable in error state.

### Tests for User Story 4

- [X] T033 [US4] Extend `ExerciseCatalogueBloc` unit tests (retry: `LoadRequested` from `Error` starts new cycle: [Loading, Populated] or [Loading, Error]; loading-idempotent guard does NOT block retry from Error state) in `forge/test/features/exercise/application/bloc/exercise_catalogue_bloc_test.dart`
- [X] T034 [US4] Extend widget tests for `ExerciseCatalogueScreen` (Retry button tap dispatches `LoadRequested`; screen returns to loading skeleton after retry; back icon visible and functional from error state; error card copy matches spec: "Couldn't load the exercise catalogue") in `forge/test/features/exercise/presentation/screens/exercise_catalogue_screen_test.dart`

### Implementation for User Story 4

- [X] T035 [US4] Verify `ExerciseCatalogueBloc` `LoadRequested` handler allows retry from `Error` state (idempotent guard only blocks when `state is ExerciseCatalogueLoading`; all other states including `Error` proceed normally) in `forge/lib/features/exercise/application/bloc/exercise_catalogue_bloc.dart`
- [X] T036 [US4] Wire Retry button in `ExerciseCatalogueScreen` error state to dispatch `ExerciseCatalogueLoadRequested`; verify back icon uses `context.pop()` in `forge/lib/features/exercise/presentation/screens/exercise_catalogue_screen.dart`

**Checkpoint**: Run `flutter test test/features/exercise/` — all tests pass. Confirm VS-10 quickstart scenario.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Format, analyze, test suite verification, and manual quickstart validation.

- [X] T037 [P] Run `dart format .` in `forge/` and resolve any formatting changes across all new and modified files
- [X] T038 [P] Run `flutter analyze` in `forge/` and resolve every new analyzer warning or error introduced by this feature (2 pre-existing `prefer_initializing_formals` info items on `exercise_seed_service.dart` and `theme_persistence_service.dart` are acceptable)
- [X] T039 Run `flutter test` in `forge/` and confirm all new tests pass; confirm pre-existing passing tests still pass; document final pass count
- [ ] T040 Validate quickstart scenarios VS-01 through VS-10 manually on iOS Simulator or Android Emulator per `quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — run immediately.
- **Foundational (Phase 2)**: Depends on Phase 1 — blocks all user story phases.
- **US1 (Phase 3)**: Depends on Phase 2. MVP increment — validate independently before proceeding.
- **US2 (Phase 4)**: Depends on Phase 3 (`ExerciseCatalogueScreen` scaffold must exist to integrate search/filter).
- **US3 (Phase 5)**: Depends on Phase 3 (`ExerciseListItem` browse mode must exist to extend to picker mode).
- **US4 (Phase 6)**: Depends on Phase 3 (error state must already render; retry is a wiring task).
- **Polish (Phase 7)**: Depends on all user story phases being complete.

### Within Foundational Phase (Phase 2)

```
T002 [P] ──┐
T003 [P] ──┤
T004 [P] ──┤──► T005 ──► T010 ──► T011
T006 [P] ──┤──► T007 ──┘          T012 (independent; depends only on T003)
T008 [P] ──┤
T009 [P] ──┘
```

### Within US1 Phase (Phase 3)

```
T013–T016 [P] (tests — no implementation deps)
T017 [P]  ──┐
T018      ──┤──► T020 ──► T021
            ┘
T017 (skeleton) and T019 (list item) are independent; T020 (screen) depends on both.
```

### Within US2 Phase (Phase 4)

```
T024 [P] ──┐
T025 [P] ──┤──► T028 (screen integration)
T026 [P] ──┘
T027 (bloc) — independent of T024–T026 but must complete before T028 is fully testable
T022–T023 (tests) — can be written before or after implementation
```

---

## Parallel Opportunities

### Phase 2 — Foundational

```
# Run simultaneously:
T002 (Exercise entity)
T003 (PickerContext entity)
T004 (ExerciseRepository interface)
T006 (ExerciseMapper)
T008 (ExerciseCatalogueEvent)
T009 (ExerciseCatalogueState)
# Then sequentially:
T005 (depends on T004)
T007 (depends on T004, T006)
T010 (depends on T008, T009, T005)
T011 (depends on T010, T007)
T012 (depends on T003)
```

### Phase 3 — US1

```
# Run simultaneously:
T013 (Exercise entity tests)
T014 (ExerciseMapper tests)
T015 (UseCase tests)
T016 (RepositoryImpl tests)
T017 (ExerciseCatalogueBloc load tests)
T018 (ExerciseSkeletonList widget)
# Then:
T019 (ExerciseListItem — depends on Exercise entity being stable)
T020 (ExerciseCatalogueScreen — depends on T018, T019)
T021 (Screen widget tests — depends on T020)
```

### Phase 4 — US2

```
# Run simultaneously:
T024 (ExerciseSearchBar)
T025 (ExerciseFilterChips)
T026 (ExerciseCatalogueEmptyState)
T027 (Bloc search/filter handlers)
# Then:
T028 (Screen integration — depends on T024, T025, T026, T027)
T022, T023 (tests — can run alongside implementation)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup (T001)
2. Phase 2: Foundational (T002–T012)
3. Phase 3: US1 (T013–T021)
4. **STOP and VALIDATE**: Run `flutter test`, confirm VS-01 scenario on simulator.

### Incremental Delivery

1. Setup + Foundational → compile-clean scaffolding
2. US1 → browseable exercise catalogue (no search/filter, no picker)
3. US2 → add search + filter
4. US3 → add picker mode (enable plan-building flow)
5. US4 → confirm error recovery is wired
6. Polish → format, analyze, full test suite, manual quickstart

---

## Notes

- All `[P]` tasks write to different files; they can run in parallel.
- Browse-mode rows (`ExerciseListItem`) have **no `InkWell`** — FR-014 mandates fully static rows.
- `AppColors._cyan` (#7DF4FF) is used for the weighted-type dot via its hex literal `const Color(0xFF7DF4FF)` (private field; see research.md Decision 8).
- Search debounce: `transformer: restartable()` + `await Future<void>.delayed(const Duration(milliseconds: 300))` — no new packages needed.
- Test fakes follow the `_FakeRepo implements ExerciseRepository` pattern established in the home feature (SCR-06).
- Two pre-existing analyzer info items (`prefer_initializing_formals`) are acceptable and must not be introduced by this feature.
- Target: 0 new analyzer errors; all new tests green; pre-existing 50/51 test pass rate maintained or improved.
