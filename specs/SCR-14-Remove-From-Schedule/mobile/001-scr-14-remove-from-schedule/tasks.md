# Tasks: SCR-14 Remove From Schedule Confirmation

**Input**: Design documents from `specs/SCR-14-Remove-From-Schedule/mobile/001-scr-14-remove-from-schedule/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Included as mandatory (Constitution Principle XI — tests are part of feature work, not optional polish).

**Organization**: Tasks are grouped by user story from `spec.md` (US1–US3). All file paths are relative to the repository root; the Flutter project lives under `forge/`.

**Build-order note**: This feature is the third to extend the shared `schedule` feature and its `ScheduleRepository` interface (after SCR-12 and SCR-13). Foundational tasks say "create or extend" to handle any build order — see [plan.md](plan.md)'s Cross-plan coordination notes. This feature also structurally mirrors the already-implemented `workout_plan` feature's `DeletePlanBloc`/`DeletePlanDialog` (research.md Decision 1) — reference those files directly while implementing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Maps the task to US1–US3 from spec.md
- Setup, Foundational, and Polish tasks carry no Story label

---

## Phase 1: Setup

- [X] T001 [P] Create (if not already present from SCR-12/SCR-13) directories `forge/lib/features/schedule/domain/usecases/`, `forge/lib/features/schedule/application/bloc/`, `forge/lib/features/schedule/presentation/widgets/`
- [X] T002 [P] Create (if not already present) test directories `forge/test/features/schedule/data/repositories/`, `forge/test/features/schedule/application/bloc/`, `forge/test/features/schedule/presentation/widgets/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The `RemoveScheduleEntryBloc` every user story renders a different state of, plus its repository/use-case/DI wiring. No user story can be demonstrated until this phase is done.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T003 Create-or-extend the `ScheduleRepository` abstract contract in `forge/lib/features/schedule/domain/repositories/schedule_repository.dart`, adding `removeEntry(int weekday)` per [contracts/schedule-repository.md](contracts/schedule-repository.md) — leave `getWeeklySchedule()`/`loadAssignmentContext()`/`saveAssignment()` untouched if SCR-12/13 already added them
- [X] T004 [P] Write/extend `ScheduleRepositoryImpl` unit tests for `removeEntry` in `forge/test/features/schedule/data/repositories/schedule_repository_impl_test.dart` per the contract test table in [contracts/schedule-repository.md](contracts/schedule-repository.md) (success, Drift-throws, already-absent-key) — write first, expect failure until T005 (depends on T003)
- [X] T005 Create-or-extend `ScheduleRepositoryImpl` in `forge/lib/features/schedule/data/repositories/schedule_repository_impl.dart`, implementing `removeEntry` by calling the existing `ScheduleLocalDataSource.deleteEntry(weekday)` and mapping exceptions to `CacheException`, matching `WorkoutPlanRepositoryImpl`'s pattern — make T004 pass (depends on T004)
- [X] T006 [P] Create `RemoveScheduleEntryUseCase` in `forge/lib/features/schedule/domain/usecases/remove_schedule_entry_usecase.dart`, a thin wrapper around `ScheduleRepository.removeEntry()`, mirroring `forge/lib/features/workout_plan/domain/usecases/delete_workout_plan_usecase.dart` exactly (depends on T003)
- [X] T007 [P] Create `RemoveScheduleEntryConfirmed` event (the single event used for both initial confirm and retry) in `forge/lib/features/schedule/application/bloc/remove_schedule_entry_event.dart` per [contracts/remove-schedule-entry-bloc.md](contracts/remove-schedule-entry-bloc.md), mirroring `forge/lib/features/workout_plan/application/bloc/delete_plan_event.dart`
- [X] T008 [P] Create `RemoveScheduleEntryState` (`Confirmation`, `Removing`, `Success`, `Failure(message)`) in `forge/lib/features/schedule/application/bloc/remove_schedule_entry_state.dart` per [contracts/remove-schedule-entry-bloc.md](contracts/remove-schedule-entry-bloc.md), mirroring `forge/lib/features/workout_plan/application/bloc/delete_plan_state.dart`
- [X] T009 Write `RemoveScheduleEntryBloc` unit tests in `forge/test/features/schedule/application/bloc/remove_schedule_entry_bloc_test.dart` using `bloc_test`, per the contract test table in [contracts/remove-schedule-entry-bloc.md](contracts/remove-schedule-entry-bloc.md) (confirm success, confirm failure, retry-succeeds, retry-fails-again) — write first, expect failure until T010 (depends on T006, T007, T008)
- [X] T010 Implement `RemoveScheduleEntryBloc` in `forge/lib/features/schedule/application/bloc/remove_schedule_entry_bloc.dart`, mirroring `delete_plan_bloc.dart`'s exact structure (single `on<RemoveScheduleEntryConfirmed>` handler: emit `Removing`, await the use case, fold to `Failure`/`Success`) — make T009 pass (depends on T009)
- [X] T011 Register `RemoveScheduleEntryUseCase` and `RemoveScheduleEntryBloc` (and `ScheduleRepository`, if not already registered by SCR-12/13) in `forge/lib/app/get_it_setup.dart`, mirroring the existing `DeleteWorkoutPlanUseCase`/`DeletePlanBloc` registration block exactly (depends on T005, T006, T010)

**Checkpoint**: Foundation ready — the Bloc and repository method exist and are tested, but there is no dialog UI yet.

---

## Phase 3: User Story 1 - Confirm removal of a day's scheduled plan (Priority: P1) 🎯 MVP

**Goal**: Tapping Remove shows a dialog naming the plan/day, and confirming removes only that day.

**Independent Test**: From a day with an assigned plan, trigger removal, confirm on the dialog, and verify that day now shows as unscheduled while every other day is unaffected.

### Implementation for User Story 1

- [X] T012 [P] [US1] Create `RemoveScheduleEntryDialog` widget shell (`weekday`, `planName`, `dayName` constructor params; icon, title "Remove from schedule?", sub-text naming the plan/day and stating history is unaffected; `BlocConsumer<RemoveScheduleEntryBloc, RemoveScheduleEntryState>` whose `listener` calls `Navigator.pop(context, true)` on `Success`; `PopScope(canPop: state is! RemoveScheduleEntryRemoving)`) in `forge/lib/features/schedule/presentation/widgets/remove_schedule_entry_dialog.dart`, mirroring `forge/lib/features/workout_plan/presentation/widgets/delete_plan_dialog.dart`'s structure per design spec §3 (shared structure) (depends on T010)
- [X] T013 [US1] Add the `Confirmation`-state action row (Cancel + lime "Remove" button dispatching `RemoveScheduleEntryConfirmed(weekday)`) to `RemoveScheduleEntryDialog`, using `AppColors.lime`/`AppColors.onLime` per design spec §3.1 and research.md Decision 3 (depends on T012)
- [X] T014 [US1] Add the `Removing`-state action row (Cancel dimmed with `onPressed: null` via `Opacity`; right button shows a 15×15 spinner + "Removing…", `onPressed: null`, lime background at `opacity: 0.85`) to `RemoveScheduleEntryDialog` per design spec §3.2 (depends on T012)
- [X] T015 [P] [US1] Widget tests: `Confirmation` state renders the plan/day/history-unaffected copy with active Cancel/Remove; tapping Remove dispatches `RemoveScheduleEntryConfirmed` and the `Removing` state shows the spinner with both buttons disabled; reaching `Success` pops `true`, in `forge/test/features/schedule/presentation/widgets/remove_schedule_entry_dialog_test.dart` (depends on T013, T014)

**Checkpoint**: User Story 1 is fully functional and testable independently (the dialog can be opened standalone in a test harness with a seeded Bloc/mock use case).

---

## Phase 4: User Story 2 - Cancel out and keep the entry unchanged (Priority: P1) 🎯 MVP

**Goal**: Cancel, outside-tap, and back-gesture dismissal all safely close the dialog with zero changes, in every state except while removing.

**Independent Test**: Open the dialog, back out via each cancel path (Cancel button, outside-dialog dismiss, back gesture), and verify the assignment remains untouched after each.

### Implementation for User Story 2

- [X] T016 [US2] Wire the Cancel button's `onPressed` to `Navigator.pop(context, false)` whenever `state is! RemoveScheduleEntryRemoving`, and ensure the caller-facing `showDialog` usage documented in [research.md](research.md) Decision 2 is `barrierDismissible: true` (back-gesture/outside-tap dismissal is otherwise handled by `PopScope` from T012), in `forge/lib/features/schedule/presentation/widgets/remove_schedule_entry_dialog.dart` (depends on T012)
- [X] T017 [P] [US2] Widget tests: tapping Cancel in `Confirmation` pops `false` with no Bloc event dispatched; simulating a barrier/back dismissal behaves the same way; both are no-ops while `Removing`, in `forge/test/features/schedule/presentation/widgets/remove_schedule_entry_dialog_test.dart` (depends on T016)

**Checkpoint**: User Stories 1 AND 2 both work independently — the two P1 stories together form the MVP.

---

## Phase 5: User Story 3 - Recover from a failed removal (Priority: P2)

**Goal**: A failed removal shows an inline error explaining nothing was lost, keeps Cancel active, and offers a working Retry.

**Independent Test**: Force the removal to fail; verify the error message, that Cancel still works, and that Retry re-attempts and can itself succeed or fail again without crashing.

### Implementation for User Story 3

- [X] T018 [P] [US3] Add `InlineDialogError(message: state.message)` rendering between the sub-text and the action row when `state is RemoveScheduleEntryFailure`, reusing `forge/lib/core/widgets/inline_dialog_error.dart` (no new widget), in `forge/lib/features/schedule/presentation/widgets/remove_schedule_entry_dialog.dart`
- [X] T019 [US3] Add the `Failure`-state action row (Cancel fully active — no dimming; right button reads "Retry" and dispatches the same `RemoveScheduleEntryConfirmed(weekday)`) to `RemoveScheduleEntryDialog` per design spec §3.3 (depends on T012, T018)
- [X] T020 [P] [US3] Widget tests: `Failure` state shows the error message and keeps Cancel active; tapping Retry dispatches `RemoveScheduleEntryConfirmed` again; a second failure re-shows the error without crashing, in `forge/test/features/schedule/presentation/widgets/remove_schedule_entry_dialog_test.dart` (depends on T019)

**Checkpoint**: All three user stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T021 [P] Verify/adjust touch targets (Cancel/Remove/Retry buttons) meet the ≥44pt guidance in design spec §7 (increase button padding to 14px if needed) in `forge/lib/features/schedule/presentation/widgets/remove_schedule_entry_dialog.dart`
- [X] T022 Run `dart format .`, `flutter analyze`, and `flutter test` from `forge/` and resolve every error/warning introduced by this feature
- [ ] T023 Execute [quickstart.md](quickstart.md) Scenarios 1–7 manually on one Android and one iOS device/emulator and record results

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **User Stories (Phase 3–5)**: All depend on Foundational completion
  - US1 and US2 are both P1 and together form the MVP; US2 (T016) only extends the dialog shell built in US1 (T012), so it can start as soon as T012 lands
  - US3 also only extends the shared dialog shell from T012 — independent of US2, can be built in parallel with it
- **Polish (Phase 6)**: Depends on all three user stories being complete

### Within Each User Story

- The dialog shell (T012) before any state-specific action row
- State-specific wiring before that story's widget test
- Story complete before moving to the next priority (if working sequentially)

### Parallel Opportunities

- T001, T002 (Setup) run in parallel
- T006 (use case), T007 (event), T008 (state) run in parallel
- Once T012 (dialog shell) lands, US2 (T016) and US3 (T018) can be worked fully in parallel with each other, since each only adds its own state-specific rendering branch

---

## Parallel Example: Foundational Phase

```bash
# Launch in parallel — different files, no interdependencies:
Task: "Create RemoveScheduleEntryConfirmed event in forge/lib/features/schedule/application/bloc/remove_schedule_entry_event.dart"
Task: "Create RemoveScheduleEntryState in forge/lib/features/schedule/application/bloc/remove_schedule_entry_state.dart"
```

## Parallel Example: After the dialog shell (T012)

```bash
# Launch in parallel — different state branches of the same file, no interdependencies:
Task: "Wire Cancel's onPressed to Navigator.pop(context, false) in remove_schedule_entry_dialog.dart"
Task: "Add InlineDialogError rendering for the Failure state in remove_schedule_entry_dialog.dart"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 — both P1)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: User Story 1
4. Complete Phase 4: User Story 2
5. **STOP and VALIDATE**: Run quickstart.md Scenarios 1–3 against the running app
6. Demo the MVP (confirm-and-remove plus safe cancel, no failure/retry handling yet)

### Incremental Delivery

1. Setup + Foundational → `RemoveScheduleEntryBloc`/repository method exist and are tested, no UI yet
2. Add US1 → confirming and removing works → validate against quickstart Scenario 1
3. Add US2 → all cancel paths work → validate against Scenarios 2, 3, 6 (MVP complete)
4. Add US3 → failure/retry works → validate against Scenarios 4, 5
5. Phase 6 Polish → full `flutter analyze`/`flutter test` pass + manual quickstart run (Scenario 7 covered incidentally once US1 is complete)

---

## Notes

- [P] tasks touch different files, or clearly separable branches of the same file, with no unfinished dependency between them
- [Story] label maps each task to its user story for traceability back to spec.md
- No task performs a Git operation, per the project's Mandatory Rule
- This feature shares the `schedule` module and `ScheduleRepository` interface with SCR-12 and SCR-13 — see the "Build-order note" above and plan.md's Cross-plan coordination notes before starting Phase 2
- SCR-12's own Remove-icon handler (not part of this feature) is expected to call `showDialog` and reload inline on a `true` result, mirroring `plan_detail_screen.dart`'s existing `_onDelete` pattern — not something this feature's tasks build. SCR-12 also still needs a small scope amendment (a dedicated Remove icon per row) from this feature's own Clarification — flagged, not addressed here.
