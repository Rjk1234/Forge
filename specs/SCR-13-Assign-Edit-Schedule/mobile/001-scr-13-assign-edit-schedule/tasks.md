# Tasks: SCR-13 Assign / Edit Schedule

**Input**: Design documents from `specs/SCR-13-Assign-Edit-Schedule/mobile/001-scr-13-assign-edit-schedule/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Included as mandatory (Constitution Principle XI — tests are part of feature work, not optional polish).

**Organization**: Tasks are grouped by user story from `spec.md` (US1–US5). All file paths are relative to the repository root; the Flutter project lives under `forge/`.

**Build-order note**: This feature extends the same `schedule` feature module (and the same `ScheduleRepository` interface) as SCR-12. Several Foundational tasks say "create or extend" because SCR-12 may or may not have been implemented first — if a file already exists from SCR-12's work, add to it; if not, create it fresh with only what this feature needs (see [plan.md](plan.md)'s Cross-plan coordination notes).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Maps the task to US1–US5 from spec.md
- Setup, Foundational, and Polish tasks carry no Story label

---

## Phase 1: Setup

- [X] T001 [P] Create (if not already present from SCR-12) directories `forge/lib/features/schedule/domain/entities/`, `forge/lib/features/schedule/domain/repositories/`, `forge/lib/features/schedule/domain/usecases/`, `forge/lib/features/schedule/application/bloc/`, `forge/lib/features/schedule/presentation/screens/`, `forge/lib/features/schedule/presentation/widgets/`
- [X] T002 [P] Create (if not already present) test directories `forge/test/features/schedule/data/repositories/`, `forge/test/features/schedule/application/bloc/`, `forge/test/features/schedule/presentation/screens/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The `AssignScheduleBloc` every user story renders a different state of, plus its repository/use-case/DI/route wiring. No user story is reachable in the running app until this phase (specifically T014–T015) is done.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T003 [P] Create `ScheduleFormContext` entity in `forge/lib/features/schedule/domain/entities/schedule_form_context.dart` per [data-model.md](data-model.md) (fields: planId, planName?, currentDays, occupiedDays; no Flutter/Drift imports)
- [X] T004 Create-or-extend the `ScheduleRepository` abstract contract in `forge/lib/features/schedule/domain/repositories/schedule_repository.dart`, adding `loadAssignmentContext(String planId)` and `saveAssignment({planId, planName, previousWeekdays, newWeekdays})` per [contracts/schedule-repository.md](contracts/schedule-repository.md) — leave `getWeeklySchedule()` untouched if SCR-12 already added it (depends on T003)
- [X] T005 [P] Write/extend `ScheduleRepositoryImpl` unit tests for the two new methods in `forge/test/features/schedule/data/repositories/schedule_repository_impl_test.dart` per the contract test table in [contracts/schedule-repository.md](contracts/schedule-repository.md) (load new/edit/self-exclusion/invalid-plan/throws; save pure-addition/pure-removal/mixed-diff/throws) — write first, expect failure until T006 (depends on T004)
- [X] T006 Create-or-extend `ScheduleRepositoryImpl` in `forge/lib/features/schedule/data/repositories/schedule_repository_impl.dart`, implementing `loadAssignmentContext` and `saveAssignment` by composing the existing `ScheduleLocalDataSource` and `WorkoutPlanLocalDataSource`, per [research.md](research.md) Decisions 2, 3, and 8 (computed-grouping mode detection, no rollback on partial write failure) — make T005 pass (depends on T005)
- [X] T007 [P] Create `LoadAssignmentContextUseCase` in `forge/lib/features/schedule/domain/usecases/load_assignment_context_usecase.dart`, a thin wrapper around `ScheduleRepository.loadAssignmentContext()` (depends on T004)
- [X] T008 [P] Create `SaveScheduleAssignmentUseCase` in `forge/lib/features/schedule/domain/usecases/save_schedule_assignment_usecase.dart`, a thin wrapper around `ScheduleRepository.saveAssignment()` (depends on T004)
- [X] T009 [P] Create `AssignScheduleEvent` (`AssignScheduleInitialized`, `DayToggled`, `SaveRequested`, `RetrySaveRequested`) in `forge/lib/features/schedule/application/bloc/assign_schedule_event.dart` per [contracts/assign-schedule-bloc.md](contracts/assign-schedule-bloc.md)
- [X] T010 [P] Create `AssignScheduleState` (`Initial`, `Loading`, `Ready` with `canSave`/`isEditMode` getters, `InvalidPlan`, `Saving`, `Saved`, `SaveFailure`) in `forge/lib/features/schedule/application/bloc/assign_schedule_state.dart` per [contracts/assign-schedule-bloc.md](contracts/assign-schedule-bloc.md) and [data-model.md](data-model.md)
- [X] T011 Write `AssignScheduleBloc` unit tests in `forge/test/features/schedule/application/bloc/assign_schedule_bloc_test.dart` using `bloc_test`, per the contract test table in [contracts/assign-schedule-bloc.md](contracts/assign-schedule-bloc.md) (new/edit/invalid-plan init, toggle-introduces/clears-conflict, save success, save-failure-then-retry, save-ignored-when-not-canSave) — write first, expect failure until T012 (depends on T007, T008, T009, T010)
- [X] T012 Implement `AssignScheduleBloc` in `forge/lib/features/schedule/application/bloc/assign_schedule_bloc.dart` (Bloc, not Cubit; mode derived from `originalDays.isNotEmpty`; `RetrySaveRequested` no-ops unless current state is `SaveFailure`, mirroring `CreateEditWorkoutPlanBloc`) — make T011 pass (depends on T011)
- [X] T013 Register `LoadAssignmentContextUseCase`, `SaveScheduleAssignmentUseCase`, and `AssignScheduleBloc` (and `ScheduleRepository`, if not already registered by SCR-12) in `forge/lib/app/get_it_setup.dart`, following the existing `workout_plan` block's `registerLazySingleton`/`registerFactory` pattern (depends on T006, T007, T008, T012)
- [X] T014 Create `AssignScheduleScreen` shell in `forge/lib/features/schedule/presentation/screens/assign_schedule_screen.dart`: accepts a `planId`, dispatches `AssignScheduleInitialized(planId)` in `initState`, wraps its `Scaffold` in `PopScope(canPop: true, ...)` (tightened to the Saving-aware guard in US4), and renders a `BlocBuilder<AssignScheduleBloc, AssignScheduleState>` switch stub (bodies filled in by later phases) with a loading indicator for `Initial`/`Loading` (depends on T012)
- [X] T015 Add a nested `GoRoute(path: 'schedule', ...)` under the existing `:planId` branch in `forge/lib/config/routes/app_router.dart` (alongside the already-coded `edit` sibling), building `BlocProvider(create: (_) => getIt<AssignScheduleBloc>(), child: AssignScheduleScreen(planId: state.pathParameters['planId']!))` — this activates Plan Detail's already-implemented `_onSchedule` button (`context.push('/plans/${planId}/schedule')`) (depends on T014, T013)

**Checkpoint**: Foundation ready — the existing "Schedule" button on Plan Detail now navigates to a real (loading-only) screen. User story implementation can now begin.

---

## Phase 3: User Story 1 - Schedule a plan to one or more days (Priority: P1) 🎯 MVP

**Goal**: A plan with no existing assignment can be scheduled on one or more days and saved.

**Independent Test**: From a plan with no existing schedule assignment, open the assignment screen, select one or more currently-unoccupied days, and save; verify the plan now appears on those days when the weekly schedule is viewed.

### Implementation for User Story 1

- [X] T016 [P] [US1] Create `PlanSelectorDisplay` widget (static, non-tappable plan-name card — no picker per [research.md](research.md) Decision 4) in `forge/lib/features/schedule/presentation/widgets/plan_selector_display.dart` per design spec §3.1
- [X] T017 [P] [US1] Create `DayChip` widget (single circular chip; unselected/selected visual states only — conflict state added in US3) in `forge/lib/features/schedule/presentation/widgets/day_chip.dart` per design spec §3.1
- [X] T018 [US1] Create `DayChipRow` widget assembling 7 `DayChip` entries with a per-day tap callback in `forge/lib/features/schedule/presentation/widgets/day_chip_row.dart` (depends on T017)
- [X] T019 [P] [US1] Create `RecurrenceRow` widget (static "Repeats weekly" display, no New/Edit visual distinction per [research.md](research.md) Decision 5) in `forge/lib/features/schedule/presentation/widgets/recurrence_row.dart`
- [X] T020 [US1] Create `SaveScheduleButton` widget (enabled/disabled/saving visual states, ≥44pt tap target) in `forge/lib/features/schedule/presentation/widgets/save_schedule_button.dart` per design spec §3.1/§3.5
- [X] T021 [US1] Wire `AssignScheduleScreen`'s `BlocBuilder`: `AssignScheduleReady` → `PlanSelectorDisplay` + `DayChipRow` (dispatching `DayToggled` on tap) + `RecurrenceRow` + `SaveScheduleButton(enabled: state.canSave)` (dispatching `SaveRequested` on tap) in `forge/lib/features/schedule/presentation/screens/assign_schedule_screen.dart` (depends on T014, T016, T018, T019, T020)
- [X] T022 [US1] Wire `AssignScheduleScreen`: `AssignScheduleSaved` → `context.pop()` (no visible rendering for this state) in `forge/lib/features/schedule/presentation/screens/assign_schedule_screen.dart` (depends on T021)
- [X] T023 [P] [US1] Widget tests for the new-assignment flow (no days selected → Save disabled; selecting an unoccupied day → Save enabled; reaching `Saved` → screen pops) in `forge/test/features/schedule/presentation/screens/assign_schedule_screen_test.dart` (depends on T021, T022)

**Checkpoint**: User Story 1 is fully functional and testable independently.

---

## Phase 4: User Story 2 - Edit an existing day's assignment (Priority: P1) 🎯 MVP

**Goal**: A plan with an existing assignment opens pre-filled and immediately savable, and the app bar reflects Edit vs. New mode.

**Independent Test**: Starting from a plan already assigned to specific days, open the assignment screen, verify its current days are pre-selected and the app bar reads "Edit Schedule", change the selection, and save.

### Implementation for User Story 2

- [X] T024 [US2] Extend `AssignScheduleScreen`'s `AssignScheduleReady` rendering to set the app bar title from `state.isEditMode` ("Edit Schedule" when true, "New Schedule" when false) in `forge/lib/features/schedule/presentation/screens/assign_schedule_screen.dart` (depends on T021)
- [X] T025 [P] [US2] Widget tests: a `Ready` state seeded with non-empty `originalDays` renders those days pre-selected, Save is already enabled, and the app bar reads "Edit Schedule" in `forge/test/features/schedule/presentation/screens/assign_schedule_screen_test.dart` (depends on T024)

**Checkpoint**: User Stories 1 AND 2 both work independently — the two P1 stories together form the MVP.

---

## Phase 5: User Story 3 - Get blocked from double-booking a day (Priority: P2)

**Goal**: Selecting a day already occupied by a different plan is clearly flagged and blocks saving; a plan's own days never self-conflict.

**Independent Test**: With one day already assigned to Plan A, open the assignment screen for Plan B and select that same day; verify it's flagged, names Plan A, and blocks Save — independent of any other day's state.

### Implementation for User Story 3

- [X] T026 [US3] Extend `DayChip` with a third (conflict) visual state and add an inline conflict-message area below `DayChipRow` in `forge/lib/features/schedule/presentation/widgets/day_chip.dart` and `forge/lib/features/schedule/presentation/widgets/day_chip_row.dart` per design spec §3.3 (depends on T017, T018)
- [X] T027 [US3] Wire `AssignScheduleScreen` to pass `state.conflicts` into `DayChipRow` (driving each chip's tri-state and the conflict message naming the occupying plan) and keep `SaveScheduleButton` disabled whenever `state.conflicts.isNotEmpty` in `forge/lib/features/schedule/presentation/screens/assign_schedule_screen.dart` (depends on T021, T026)
- [X] T028 [P] [US3] Widget tests: selecting an occupied day shows conflict style + names the conflicting plan + disables Save; deselecting it clears the conflict; a plan's own existing days never render as conflicting, in `forge/test/features/schedule/presentation/screens/assign_schedule_screen_test.dart` (depends on T027)

**Checkpoint**: User Stories 1–3 all work independently.

---

## Phase 6: User Story 4 - Recover from a failed save (Priority: P2)

**Goal**: A save failure shows an explanatory error, retains the user's selection exactly, offers a retry, and blocks back navigation while saving.

**Independent Test**: Force the save operation to fail; verify the error state, retained selection, and working retry — independent of the happy-path or conflict-detection behavior.

### Implementation for User Story 4

- [X] T029 [P] [US4] Create `ScheduleSaveFailureBanner` widget (top-of-screen error banner) in `forge/lib/features/schedule/presentation/widgets/schedule_save_failure_banner.dart`, shaped after (not imported from) `forge/lib/features/workout_plan/presentation/widgets/save_failure_banner.dart` per [research.md](research.md)'s mirror-not-import decision
- [X] T030 [US4] Wire `AssignScheduleScreen`: `AssignScheduleSaveFailure` → render the same `Ready`-shaped layout as `state.readyState` plus `ScheduleSaveFailureBanner` above the content, with `SaveScheduleButton`'s label switched to "Retry Save" dispatching `RetrySaveRequested` in `forge/lib/features/schedule/presentation/screens/assign_schedule_screen.dart` (depends on T021, T029)
- [X] T031 [US4] Wrap `AssignScheduleScreen`'s `Scaffold` in `PopScope(canPop: state is! AssignScheduleSaving)` per [research.md](research.md) Decision 6, and render `AssignScheduleSaving` as the dimmed `readyState` layout with a spinner + "Saving…" on the button, in `forge/lib/features/schedule/presentation/screens/assign_schedule_screen.dart` (depends on T021)
- [X] T032 [P] [US4] Widget tests: `SaveFailure` shows the banner and retains the prior day selection exactly; tapping "Retry Save" dispatches `RetrySaveRequested`; back navigation is blocked while `Saving`, in `forge/test/features/schedule/presentation/screens/assign_schedule_screen_test.dart` (depends on T030, T031)

**Checkpoint**: User Stories 1–4 all work independently.

---

## Phase 7: User Story 5 - Get guided when the plan being edited no longer exists (Priority: P3)

**Goal**: Opening an assignment whose plan was deleted shows a clear explanatory message, disables day selection, and blocks saving.

**Independent Test**: Delete the plan referenced by an existing assignment, then open that assignment for editing; verify the banner, disabled days, and disabled Save — independent of any other story.

### Implementation for User Story 5

- [X] T033 [P] [US5] Create `InvalidPlanBanner` widget (in-field banner replacing the plan selector) in `forge/lib/features/schedule/presentation/widgets/invalid_plan_banner.dart` per design spec §3.4
- [X] T034 [US5] Wire `AssignScheduleScreen`: `AssignScheduleInvalidPlan` → `InvalidPlanBanner` in place of `PlanSelectorDisplay`, day-selection area dimmed and non-interactive, `SaveScheduleButton` disabled, in `forge/lib/features/schedule/presentation/screens/assign_schedule_screen.dart` (depends on T014, T033)
- [X] T035 [P] [US5] Widget test: `InvalidPlan` state renders the banner, disables day selection, and disables Save, in `forge/test/features/schedule/presentation/screens/assign_schedule_screen_test.dart` (depends on T034)

**Checkpoint**: All five user stories are independently functional.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [X] T036 [P] Verify/adjust touch targets (day chips, Save/Retry Save button) meet the ≥44pt guidance in design spec §7 across `forge/lib/features/schedule/presentation/widgets/`
- [X] T037 Run `dart format .`, `flutter analyze`, and `flutter test` from `forge/` and resolve every error/warning introduced by this feature
- [ ] T038 Execute [quickstart.md](quickstart.md) Scenarios 1–7 manually on one Android and one iOS device/emulator and record results

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories (no story is reachable in the app until T014–T015 land)
- **User Stories (Phase 3–7)**: All depend on Foundational completion
  - US1 and US2 are both P1 and together form the MVP; US2 (T024) only extends the `Ready` rendering built in US1 (T021), so it starts as soon as T021 lands
  - US3 extends the `DayChip`/`DayChipRow` widgets from US1 (T017/T018) but is otherwise independent of US2/US4/US5
  - US4 and US5 each only add one widget plus one `BlocBuilder` branch on top of the Foundational shell (T014/T021) — independent of each other and of US2/US3
- **Polish (Phase 8)**: Depends on all five user stories being complete

### Within Each User Story

- Widgets before wiring them into the screen's `BlocBuilder`
- Screen wiring before that story's widget test
- Story complete before moving to the next priority (if working sequentially)

### Parallel Opportunities

- T001, T002 (Setup) run in parallel
- T007, T008 (use cases) run in parallel; T009, T010 (event/state) run in parallel
- Once Foundational (Phase 2) completes, US4 (Phase 6) and US5 (Phase 7) can be worked fully in parallel with each other and with US2/US3, since each only touches its own new widget file plus one independent `BlocBuilder` branch
- Within US1: T016, T017, T019 run in parallel

---

## Parallel Example: Foundational Phase

```bash
# Launch in parallel — different files, no interdependencies:
Task: "Create LoadAssignmentContextUseCase in forge/lib/features/schedule/domain/usecases/load_assignment_context_usecase.dart"
Task: "Create SaveScheduleAssignmentUseCase in forge/lib/features/schedule/domain/usecases/save_schedule_assignment_usecase.dart"
```

## Parallel Example: User Story 1

```bash
# Launch in parallel — different files, no interdependencies:
Task: "Create PlanSelectorDisplay widget in forge/lib/features/schedule/presentation/widgets/plan_selector_display.dart"
Task: "Create RecurrenceRow widget in forge/lib/features/schedule/presentation/widgets/recurrence_row.dart"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 — both P1)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: User Story 1
4. Complete Phase 4: User Story 2
5. **STOP and VALIDATE**: Run quickstart.md Scenarios 1–2 against the running app
6. Demo the MVP (create + edit an assignment, no conflict/failure/invalid-plan handling yet)

### Incremental Delivery

1. Setup + Foundational → the existing Plan Detail "Schedule" button now leads to a real (loading-only) screen
2. Add US1 → new assignments work → validate against quickstart Scenario 1
3. Add US2 → editing works, correct app bar title → validate against Scenario 2 (MVP complete)
4. Add US3 → conflict detection works → validate against Scenario 3
5. Add US4 → save failure/retry and save-lock work → validate against Scenarios 4 and 7
6. Add US5 → invalid-plan recovery works → validate against Scenario 5
7. Phase 8 Polish → full `flutter analyze`/`flutter test` pass + manual quickstart run (including Scenario 6, cancel-without-saving, which needs no dedicated implementation task)

---

## Notes

- [P] tasks touch different files with no unfinished dependency between them
- [Story] label maps each task to its user story for traceability back to spec.md
- No task performs a Git operation, per the project's Mandatory Rule
- This feature shares the `schedule` module and `ScheduleRepository` interface with SCR-12 — see the "Build-order note" above and plan.md's Cross-plan coordination notes before starting Phase 2
- SCR-12's own edit-icon and empty-state-CTA navigation (not part of this feature) are expected to await this screen's pop and reload themselves, per research.md Decision 7 — not something this feature's tasks build
