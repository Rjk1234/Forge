# Tasks: SCR-12 View Weekly Workout Schedule

**Input**: Design documents from `specs/SCR-12-View-Weekly-Schedule/mobile/001-scr-12-view-weekly-schedule/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Included as mandatory (Constitution Principle XI — tests are part of feature work, not optional polish; `bloc_test`/`mocktail`/`flutter_test` are governed dependencies already in use for this exact shape of feature).

**Organization**: Tasks are grouped by user story from `spec.md` (US1–US4) to enable independent implementation and testing of each story. All file paths are relative to the repository root; the Flutter project itself lives under `forge/`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Maps the task to US1/US2/US3/US4 from spec.md
- Setup, Foundational, and Polish tasks carry no Story label

---

## Phase 1: Setup

**Purpose**: Scaffold the new layers on the existing `schedule` feature module (which currently has only `data/`).

- [X] T001 [P] Create empty directories `forge/lib/features/schedule/domain/entities/`, `forge/lib/features/schedule/domain/repositories/`, `forge/lib/features/schedule/domain/usecases/`, `forge/lib/features/schedule/application/bloc/`, `forge/lib/features/schedule/presentation/screens/`, `forge/lib/features/schedule/presentation/widgets/`
- [X] T002 [P] Create empty directories `forge/test/features/schedule/data/repositories/`, `forge/test/features/schedule/application/bloc/`, `forge/test/features/schedule/presentation/screens/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The single `WeekScheduleBloc` that all four user stories render different states of, plus its repository/use-case/DI wiring and the screen's route entry point. No user story is independently visible in the running app until this phase (specifically T014–T015) is done.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T003 [P] Create `ScheduleDay` and `ScheduledPlanRef` entities in `forge/lib/features/schedule/domain/entities/schedule_day.dart` per [data-model.md](data-model.md) (fields: weekday, date, isToday, assignedPlan; no Flutter/Drift imports)
- [X] T004 [P] Create `WeeklySchedule` entity in `forge/lib/features/schedule/domain/entities/weekly_schedule.dart` per [data-model.md](data-model.md) (7-item `days` list, Monday→Sunday)
- [X] T005 Create the `ScheduleRepository` abstract contract in `forge/lib/features/schedule/domain/repositories/schedule_repository.dart` per [contracts/schedule-repository.md](contracts/schedule-repository.md) (single `getWeeklySchedule()` method returning `Future<Either<AppException, WeeklySchedule>>`) (depends on T003, T004)
- [X] T006 [P] Write `ScheduleRepositoryImpl` unit tests in `forge/test/features/schedule/data/repositories/schedule_repository_impl_test.dart` per the contract test table in [contracts/schedule-repository.md](contracts/schedule-repository.md) (all-resolve, orphaned-entry, no-entries, Drift-throws, today-resolution cases; hand-written fake `_FakeScheduleDataSource` and `_FakePlanDataSource`) — write first, expect these to fail to compile/run until T007 exists (depends on T005)
- [X] T007 Implement `ScheduleRepositoryImpl` in `forge/lib/features/schedule/data/repositories/schedule_repository_impl.dart`, composing the existing `ScheduleLocalDataSource` and `WorkoutPlanLocalDataSource` (mirroring `HomeDashboardLocalDataSourceImpl`'s composition in `forge/lib/features/home/data/datasources/home_local_data_source.dart`), including the orphaned-entry cleanup (`deleteEntry`) from [research.md](research.md) Decision 2 and `CacheException` failure mapping matching `WorkoutPlanRepositoryImpl` — make T006 pass (depends on T006)
- [X] T008 Create `GetWeeklyScheduleUseCase` in `forge/lib/features/schedule/domain/usecases/get_weekly_schedule_usecase.dart`, a thin wrapper around `ScheduleRepository.getWeeklySchedule()` (depends on T005)
- [X] T009 [P] Create `WeekScheduleEvent` (`WeekScheduleRequested`, `WeekScheduleRetried`) in `forge/lib/features/schedule/application/bloc/week_schedule_event.dart` per [contracts/week-schedule-bloc.md](contracts/week-schedule-bloc.md)
- [X] T010 [P] Create `WeekScheduleState` (`WeekScheduleInitial`, `WeekScheduleLoading`, `WeekSchedulePopulated`, `WeekScheduleEmpty`, `WeekScheduleError`) in `forge/lib/features/schedule/application/bloc/week_schedule_state.dart` per [contracts/week-schedule-bloc.md](contracts/week-schedule-bloc.md) (depends on T004)
- [X] T011 Write `WeekScheduleBloc` unit tests in `forge/test/features/schedule/application/bloc/week_schedule_bloc_test.dart` using `bloc_test`, per the contract test table in [contracts/week-schedule-bloc.md](contracts/week-schedule-bloc.md) (populated path, empty path, error path, retry-recovers, retry-debounce-while-loading) — write first, expect failure until T012 exists (depends on T008, T009, T010)
- [X] T012 Implement `WeekScheduleBloc` in `forge/lib/features/schedule/application/bloc/week_schedule_bloc.dart` (Bloc, not Cubit; `on<WeekScheduleRequested>` and `on<WeekScheduleRetried>` handlers; retry ignored while already `Loading`) — make T011 pass (depends on T011)
- [X] T013 Register `ScheduleRepository`, `GetWeeklyScheduleUseCase`, and `WeekScheduleBloc` (`registerLazySingleton`/`registerFactory`, matching the existing `workout_plan` block's pattern) in `forge/lib/app/get_it_setup.dart` (depends on T007, T008, T012)
- [X] T014 Create `WeeklyScheduleScreen` shell in `forge/lib/features/schedule/presentation/screens/weekly_schedule_screen.dart`: `StatefulWidget` with `SingleTickerProviderStateMixin`, shimmer animation, `didChangeDependencies` dispatches `WeekScheduleRequested`, app bar titled "Schedule", `BlocBuilder<WeekScheduleBloc, WeekScheduleState>` with a `switch` stub (bodies filled in by later phases) (depends on T012)
- [X] T015 Wire `WeeklyScheduleScreen` into `forge/lib/config/routes/app_routes.dart`: replace the Branch 2 (Schedule) `GoRoute` builder's `PlaceholderTabScreen(label: 'Schedule')` with `BlocProvider(create: (_) => getIt<WeekScheduleBloc>(), child: const WeeklyScheduleScreen())` (depends on T014, T013)

**Checkpoint**: Foundation ready — the Schedule tab is reachable in the running app and shows the loading state, but no populated/empty/error UI exists yet. User story implementation can now begin.

---

## Phase 3: User Story 1 - See the current week's plan at a glance (Priority: P1) 🎯 MVP

**Goal**: All 7 days render with correct plan/rest labeling once data loads, with a skeleton shown while loading.

**Independent Test**: Assign a plan to at least one weekday (seed `schedule_entries` table directly per [quickstart.md](quickstart.md) Scenario 1 until SCR-13 exists), open the Schedule tab, and verify all 7 days render with correct plan/rest labeling — independent of the Start action or empty/error states.

### Implementation for User Story 1

- [X] T016 [P] [US1] Create `ScheduleSkeletonList` widget (7× `ShimmerBox`-based skeleton rows, reusing `forge/lib/core/widgets/shimmer_box.dart`) in `forge/lib/features/schedule/presentation/widgets/schedule_skeleton_list.dart` per design spec §3.1
- [X] T017 [P] [US1] Create `DayBadge` widget (day name + day number column) in `forge/lib/features/schedule/presentation/widgets/day_badge.dart` per design spec §3.3
- [X] T018 [US1] Create `DayRow` widget (non-today default variant: plan name + "Weekly" meta, or italic "Rest day" label; trailing edit icon wrapped in a 44×44 tap target) in `forge/lib/features/schedule/presentation/widgets/day_row.dart` per design spec §3.3 (depends on T017)
- [X] T019 [US1] Create `WeekScheduleList` widget assembling 7 `DayRow` entries from a `WeeklySchedule` in `forge/lib/features/schedule/presentation/widgets/week_schedule_list.dart` (depends on T018)
- [X] T020 [US1] Wire `WeeklyScheduleScreen`'s `BlocBuilder`: `WeekScheduleInitial`/`WeekScheduleLoading` → `ScheduleSkeletonList`, `WeekSchedulePopulated` → `WeekScheduleList` in `forge/lib/features/schedule/presentation/screens/weekly_schedule_screen.dart` (depends on T014, T016, T019)
- [X] T021 [US1] Add edit-icon tap handling on `DayRow` (navigates toward the SCR-13 Assign/Edit Schedule route per [research.md](research.md) Decision 5 — route-constant placeholder callback, not a hardcoded path string) (depends on T018)
- [X] T022 [P] [US1] Widget tests for the loading-skeleton and populated-rows cases in `forge/test/features/schedule/presentation/screens/weekly_schedule_screen_test.dart` (depends on T020)

**Checkpoint**: User Story 1 is fully functional and testable independently — the week renders correctly once data loads.

---

## Phase 4: User Story 2 - Start today's workout in one tap (Priority: P1) 🎯 MVP

**Goal**: Today's row is visually distinguished and, when a plan is assigned, offers a one-tap Start action into the workout pre-start flow.

**Independent Test**: With a plan assigned to today's weekday, open the Schedule tab and tap the Start action on today's row; verify it navigates toward the workout pre-start flow for that plan — testable independently of the rest of the week's rows.

### Implementation for User Story 2

- [X] T023 [P] [US2] Create `StartWorkoutButton` widget (lime pill, ≥44pt tap target per design spec §7) in `forge/lib/features/schedule/presentation/widgets/start_workout_button.dart` per design spec §3.3
- [X] T024 [US2] Extend `DayRow` with the today-highlighted variant (lime border/background, "Weekly · Today" meta when a plan is assigned) and conditional trailing control — `StartWorkoutButton` when today has an assigned plan, otherwise the same rest-label + edit-icon treatment as a non-today rest row (Edge Case: today unscheduled) — in `forge/lib/features/schedule/presentation/widgets/day_row.dart` (depends on T018, T023)
- [X] T025 [US2] Add Start-button tap handling (navigates toward the SCR-15 Workout Pre-Start route per [research.md](research.md) Decision 5 — route-constant placeholder callback, not a hardcoded path string) in `forge/lib/features/schedule/presentation/widgets/day_row.dart` (depends on T024)
- [X] T026 [P] [US2] Widget tests: today's row is highlighted, shows Start when a plan is assigned, and shows rest label + edit icon when today is unscheduled, in `forge/test/features/schedule/presentation/screens/weekly_schedule_screen_test.dart` (depends on T024, T025)

**Checkpoint**: User Stories 1 AND 2 both work independently — the two P1 stories together form the MVP.

---

## Phase 5: User Story 3 - Get guided to create a schedule when none exists (Priority: P2)

**Goal**: A first-time or fully-rest week shows a clear empty state with a call to action instead of a confusing blank week.

**Independent Test**: With zero schedule entries, open the Schedule tab and verify the empty state with its call-to-action appears and navigates correctly — independent of populated or error behavior.

### Implementation for User Story 3

- [X] T027 [P] [US3] Create `ScheduleEmptyState` widget ("No workouts scheduled" title, subtitle, "Schedule a plan" CTA) in `forge/lib/features/schedule/presentation/widgets/schedule_empty_state.dart` per design spec §3.2, shaped after `forge/lib/features/workout_plan/presentation/widgets/plans_empty_state.dart`
- [X] T028 [US3] Wire `WeeklyScheduleScreen`'s `BlocBuilder`: `WeekScheduleEmpty` → `ScheduleEmptyState`, with the CTA navigating toward the SCR-13 route (same placeholder approach as T021) in `forge/lib/features/schedule/presentation/screens/weekly_schedule_screen.dart` (depends on T020, T027)
- [X] T029 [P] [US3] Widget test: empty state renders when the schedule has zero assignments and the CTA triggers navigation, in `forge/test/features/schedule/presentation/screens/weekly_schedule_screen_test.dart` (depends on T028)

**Checkpoint**: User Stories 1–3 all work independently.

---

## Phase 6: User Story 4 - Recover from a failed schedule load (Priority: P3)

**Goal**: A failed local read shows an error state with retry, and communicates that plans/history are unaffected.

**Independent Test**: Force the local schedule read to fail (or drive the Bloc directly to `WeekScheduleError` in a widget test) and verify the error state renders with retry, and that retry re-attempts the load — independent of the populated/empty paths.

### Implementation for User Story 4

- [X] T030 [P] [US4] Create `ScheduleErrorCard` widget (warning-triangle icon, "Couldn't load your schedule" + reassurance copy, Retry button) in `forge/lib/features/schedule/presentation/widgets/schedule_error_card.dart` per design spec §3.4, shaped after `forge/lib/features/home/presentation/widgets/error_card.dart`
- [X] T031 [US4] Wire `WeeklyScheduleScreen`'s `BlocBuilder`: `WeekScheduleError` → `ScheduleErrorCard`, with Retry dispatching `WeekScheduleRetried` in `forge/lib/features/schedule/presentation/screens/weekly_schedule_screen.dart` (depends on T020, T030)
- [X] T032 [P] [US4] Widget test: error state renders on `WeekScheduleError` and tapping Retry dispatches `WeekScheduleRetried`, in `forge/test/features/schedule/presentation/screens/weekly_schedule_screen_test.dart` (depends on T031)

**Checkpoint**: All four user stories are independently functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Cross-cutting quality passes that touch multiple stories' widgets.

- [X] T033 [P] Touch targets verified: edit icon (44×44 SizedBox), Start button (44pt minimumSize), empty-state CTA (44pt minimumSize), Retry button (44pt minimumSize) — all meet ≥44pt guidance across `forge/lib/features/schedule/presentation/widgets/`
- [X] T034 Run `dart format .`, `flutter analyze`, and `flutter test` from `forge/` — zero errors/warnings introduced by SCR-12; 22/22 schedule tests pass
- [ ] T035 Execute [quickstart.md](quickstart.md) Scenarios 1–6 manually on one Android and one iOS device/emulator and record results — deferred to simulator validation session

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories (in particular, no story is visible in the app until T014–T015 land)
- **User Stories (Phase 3–6)**: All depend on Foundational phase completion
  - US1 and US2 are both P1 and together form the MVP; US2 depends on `DayRow` from US1 (T018) but adds its own today-variant behavior on top
  - US3 and US4 are independent of US1/US2 and of each other — each only adds one `BlocBuilder` branch and one widget
- **Polish (Phase 7)**: Depends on all four user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational — no dependency on other stories
- **User Story 2 (P1)**: Can start after Foundational; T024 extends the `DayRow` widget created in T018 (US1), so in practice US2 starts once T018 lands, not necessarily all of US1
- **User Story 3 (P2)**: Can start after Foundational — no dependency on US1/US2/US4 beyond the shared `BlocBuilder` switch stub (T014)
- **User Story 4 (P3)**: Can start after Foundational — no dependency on US1/US2/US3 beyond the shared `BlocBuilder` switch stub (T014)

### Within Each User Story

- Widgets before wiring them into the screen's `BlocBuilder`
- Screen wiring before that story's widget test
- Story complete before moving to the next priority (if working sequentially)

### Parallel Opportunities

- T001, T002 (Setup) run in parallel
- T003, T004 (entities) run in parallel; T009, T010 (event/state) run in parallel
- Once Foundational (Phase 2) completes, US3 (Phase 5) and US4 (Phase 6) can be worked fully in parallel with US1/US2 and with each other, since each only touches its own new widget file plus one independent `BlocBuilder` branch
- Within US1: T016 and T017 run in parallel; within US2: T023 runs in parallel with US1's remaining tasks

---

## Notes

- [P] tasks touch different files with no unfinished dependency between them
- [Story] label maps each task to its user story for traceability back to spec.md
- No task in this feature performs a Git operation, per the project's Mandatory Rule — commits, if any, are the user's own manual step
- SCR-13 (Assign/Edit Schedule) and SCR-15 (Workout Pre-Start) do not exist yet; T021, T025, and T028's navigation calls are implemented against route-constant placeholders per research.md Decision 5, not hardcoded path strings — update only the route constant once those features ship
