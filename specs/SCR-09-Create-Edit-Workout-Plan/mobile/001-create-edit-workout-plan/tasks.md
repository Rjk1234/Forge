# Tasks: SCR-09 Create / Edit Workout Plan

**Input**: Design documents from `specs/SCR-09-Create-Edit-Workout-Plan/mobile/001-create-edit-workout-plan/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [data-model.md](data-model.md), [research.md](research.md), [quickstart.md](quickstart.md)

**Tests**: Test tasks are included for all Bloc state transitions and all screen widget tests.

**Organization**: Tasks grouped by user story (US1–US7) within a shared Foundational phase.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no blocking dependencies)
- **[Story]**: Which user story this task belongs to (US1–US7)
- All file paths are project-relative under `forge/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the `DecimalOneDigitInputFormatter` utility — reusable by all numeric decimal fields; needed by Phase 2 widget work.

- [X] T001 Create `DecimalOneDigitInputFormatter extends TextInputFormatter` (regex `^\d*\.?\d{0,1}$` — blocks digits beyond 1dp) in `lib/core/formatters/decimal_one_digit_input_formatter.dart`
- [X] T002 [P] Write unit tests for `DecimalOneDigitInputFormatter` covering: allows integer, allows 1dp, blocks 2dp, allows trailing dot, allows empty in `test/core/formatters/decimal_one_digit_input_formatter_test.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: All domain entities, repository extension, use cases, mapper, Bloc, DI wiring, and picker change. MUST complete before any user story screen work.

**⚠️ CRITICAL**: No user story (Phase 3+) can begin until this entire phase is complete.

### Domain — New Entities

- [X] T003 [P] Create `WorkoutPlanDetail` entity (fields: `id`, `name`, `List<PlanExercise> exercises`, `createdAt`, `updatedAt`; implements `Equatable`) in `lib/features/workout_plan/domain/entities/workout_plan_detail.dart`
- [X] T004 [P] Create `PlanExercise` entity (fields: `exerciseId`, `exerciseName`, `type: ExerciseType`, `targetSets`, `targetRepetitions?`, `targetWeight?`, `targetDurationSec?`, `restPeriodSec`; implements `Equatable`) in `lib/features/workout_plan/domain/entities/plan_exercise.dart`

### Domain — Repository Interface Extension

- [X] T005 Extend `WorkoutPlanRepository` abstract class with two new abstract methods: `Future<Either<AppException, WorkoutPlanDetail>> getPlanById(String planId)` and `Future<Either<AppException, Unit>> savePlan(WorkoutPlanDetail plan)` in `lib/features/workout_plan/domain/repositories/workout_plan_repository.dart`

### Domain — New Use Cases

- [X] T006 [P] Create `SaveWorkoutPlanUseCase` (`call(WorkoutPlanDetail plan)` → `Future<Either<AppException, Unit>>` via `repository.savePlan(plan)`) in `lib/features/workout_plan/domain/usecases/save_workout_plan_usecase.dart`
- [X] T007 [P] Create `GetWorkoutPlanByIdUseCase` (`call(String planId)` → `Future<Either<AppException, WorkoutPlanDetail>>` via `repository.getPlanById(planId)`) in `lib/features/workout_plan/domain/usecases/get_workout_plan_by_id_usecase.dart`

### Data — Mapper Extension

- [X] T008 Extend `WorkoutPlanMapper` with three new static methods: `toDetailFromRecord(WorkoutPlanRecord)` → `WorkoutPlanDetail`, `toRecord(WorkoutPlanDetail)` → `WorkoutPlanRecord`, and `planExerciseFromRecord(PlanExerciseRecord)` → `PlanExercise` in `lib/features/workout_plan/data/mappers/workout_plan_mapper.dart`

### Data — Repository Implementation Extension

- [X] T009 Implement `getPlanById` and `savePlan` on `WorkoutPlanRepositoryImpl`: `getPlanById` calls `dataSource.getPlanById(planId)` and maps via `WorkoutPlanMapper.toDetailFromRecord`; `savePlan` generates a UUID v4 when `plan.id` is empty (create), sets `updatedAt = DateTime.now()`, converts via `WorkoutPlanMapper.toRecord`, and calls `dataSource.savePlan(model)`; both wrap in try/catch returning `Left(CacheException(...))` on failure in `lib/features/workout_plan/data/repositories/workout_plan_repository_impl.dart`

### Data — Tests

- [X] T010 [P] Write unit tests for new `WorkoutPlanMapper` methods (`toDetailFromRecord`, `toRecord`, `planExerciseFromRecord`) covering all three `ExerciseType` variants in `test/features/workout_plan/data/mappers/workout_plan_mapper_test.dart`
- [X] T011 [P] Write unit tests for `WorkoutPlanRepositoryImpl.getPlanById` (found / not-found / exception) and `savePlan` (create with UUID / edit with existing id / exception) in `test/features/workout_plan/data/repositories/workout_plan_repository_impl_test.dart`

### Exercise Picker — Return Type Change

- [X] T012 Update `ExerciseCatalogueScreen._onAddExercise` signature from `void _onAddExercise(String exerciseId)` to `void _onAddExercise(Exercise exercise)` and change `context.pop(exerciseId)` to `context.pop(exercise)` in `lib/features/exercise/presentation/screens/exercise_catalogue_screen.dart`; update all call sites within that file (the `onAddTap` lambda in `_ExerciseContent`)

### Application — Bloc

- [X] T013 Create `PlanExerciseFormEntry` immutable value object (fields: `exerciseId`, `exerciseName`, `type`, `targetSets: int`, `targetRepetitions: int?`, `targetWeight: double?`, `targetDurationSec: int?`, `restPeriodSec: int`; factory constructor `PlanExerciseFormEntry.fromExercise(Exercise)` sets all target fields to their default 0; implements `Equatable`; provides `copyWith`) in `lib/features/workout_plan/application/bloc/plan_exercise_form_entry.dart`
- [X] T014 Create all `CreateEditWorkoutPlanEvent` sealed classes: `CreateEditPlanInitialized({String? planId})`, `PlanNameChanged(String name)`, `ExerciseAdded(Exercise exercise)`, `ExerciseRemoved(int index)`, `ExerciseFieldChanged(int index, ExerciseField field, String rawValue)` (where `ExerciseField` is an enum: `sets`, `reps`, `weight`, `durationSec`, `restSec`), `SaveRequested()`, `RetrySaveRequested()` in `lib/features/workout_plan/application/bloc/create_edit_workout_plan_event.dart`
- [X] T015 Create all `CreateEditWorkoutPlanState` sealed classes: `CreateEditPlanInitial`, `CreateEditPlanLoading`, `CreateEditPlanReady({String? planId, String name, List<PlanExerciseFormEntry> exercises, bool isDirty, bool canSave, String? nameValidationError, Map<int, List<String>> exerciseErrors})`, `CreateEditPlanSaving({String? planId, String name, List<PlanExerciseFormEntry> exercises})`, `CreateEditPlanSaved(String planId)`, `CreateEditPlanLoadError(String message)`, `CreateEditPlanSaveFailure({String? planId, String name, List<PlanExerciseFormEntry> exercises, bool isDirty})` — all implement `Equatable` in `lib/features/workout_plan/application/bloc/create_edit_workout_plan_state.dart`
- [X] T016 Implement `CreateEditWorkoutPlanBloc` handling all events: `CreateEditPlanInitialized` (load plan from `GetWorkoutPlanByIdUseCase` if planId non-null, else emit Ready with empty form); `PlanNameChanged` (update name, clear name error, recompute canSave, set isDirty); `ExerciseAdded` (append `PlanExerciseFormEntry.fromExercise(exercise)`, set isDirty); `ExerciseRemoved` (remove at index, set isDirty); `ExerciseFieldChanged` (update specific field in entry at index, clear that field's error from `exerciseErrors[index]`, recompute canSave, set isDirty); `SaveRequested` (run validation — if errors, emit Ready with errors; if valid, emit Saving then call `SaveWorkoutPlanUseCase` then emit Saved or SaveFailure); `RetrySaveRequested` (emit Saving from SaveFailure, re-attempt save) in `lib/features/workout_plan/application/bloc/create_edit_workout_plan_bloc.dart`
- [X] T017 Write Bloc unit tests covering all state transitions: initial → ready (create); initial → loading → ready (edit); initial → loading → loadError; ready → ready (name changed, canSave recomputed); ready → ready (exercise added/removed); ready → ready (field changed, error cleared); ready → ready (save with validation errors); ready → saving → saved; ready → saving → saveFailure; saveFailure → saving → saved; saveFailure → saving → saveFailure in `test/features/workout_plan/application/bloc/create_edit_workout_plan_bloc_test.dart`

### DI — GetIt Registration

- [X] T018 Register `SaveWorkoutPlanUseCase` (lazySingleton), `GetWorkoutPlanByIdUseCase` (lazySingleton), and `CreateEditWorkoutPlanBloc` (factory via `getIt<SaveWorkoutPlanUseCase>()` + `getIt<GetWorkoutPlanByIdUseCase>()`) in `lib/app/get_it_setup.dart`

**Checkpoint**: All domain, data, Bloc, and DI code is in place. `flutter analyze` passes. `flutter test` is green on all new unit and Bloc tests.

---

## Phase 3: User Story 1 — Create Mode: Blank Form (Priority: P1) 🎯 MVP

**Goal**: Navigating to `/plans/create` renders the "New Workout Plan" screen with blank form, correct placeholder, empty well, and a disabled Save button.

**Independent Test**: VS-01 from [quickstart.md](quickstart.md) — tap "+" FAB from Plans list; verify title "New Workout Plan", empty name field with placeholder "e.g., Push Day", dashed Add Exercise button, "No exercises added yet" empty well, dim Save button.

- [X] T019 [US1] Create `PlanNameField` stateless widget accepting `String value`, `ValueChanged<String> onChanged`, `String? validationError` (pass-through to `TextField` with 100-char max length, danger border when `validationError != null`, error text below when non-null) in `lib/features/workout_plan/presentation/widgets/plan_name_field.dart`
- [X] T020 [US1] Create `CreateEditWorkoutPlanScreen(String? planId)` `StatefulWidget` with `BlocConsumer<CreateEditWorkoutPlanBloc, CreateEditWorkoutPlanState>` that: dispatches `CreateEditPlanInitialized(planId: widget.planId)` in `initState`; wraps `Scaffold` in `PopScope(canPop: false, onPopInvokedWithResult: ...)` with stub `_onBackRequested()` (just calls `context.pop()` for now — fully implemented in US6 phase); renders app bar with mode-correct title ("New Workout Plan" / "Edit Workout Plan"); renders `CreateEditPlanReady` body with `PlanNameField`, empty well ("No exercises added yet") and dashed Add Exercise section, and a disabled "Save Plan" footer button in `lib/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart`
- [X] T021 [US1] Replace `/plans/create` route `PlaceholderTabScreen` with `BlocProvider(create: (_) => getIt<CreateEditWorkoutPlanBloc>(), child: const CreateEditWorkoutPlanScreen(planId: null))` in `lib/config/routes/app_routes.dart`; add `RoutePaths.planEdit = '/plans/:planId/edit'` constant
- [X] T022 [US1] Wire the "+" `IconButton` `onPressed` in `WorkoutPlansScreen` app bar to `context.push(RoutePaths.plansCreate)` and wire `PlansEmptyState.onCreateTap` to `context.push(RoutePaths.plansCreate)` in `lib/features/workout_plan/presentation/screens/workout_plans_screen.dart`
- [ ] T023 [US1] Write widget tests for US1 acceptance scenarios: (1) blank form shows correct title, placeholder, empty well, dim Save; (2) typing name keeps Save dim while exercises is empty; (3) tapping dim Save does nothing in `test/features/workout_plan/presentation/screens/create_edit_workout_plan_screen_test.dart`

**Checkpoint**: Launch app → Plans tab → tap "+" → "New Workout Plan" screen opens with all US1 elements present. VS-01 passes.

---

## Phase 4: User Story 2 — Edit Mode: Pre-filled Form (Priority: P2)

**Goal**: Navigating to `/plans/:planId/edit` renders the "Edit Workout Plan" screen pre-filled with the plan's name and exercise cards using type-specific field layouts.

**Independent Test**: VS-07 from [quickstart.md](quickstart.md) — navigate to a known plan's edit route; verify title "Edit Workout Plan", pre-filled name, and at least two exercise cards with correct type-specific fields.

- [X] T024 [US2] Add `/plans/:planId/edit` child route under the `:planId` GoRoute in `lib/config/routes/app_routes.dart`, providing `BlocProvider(create: (_) => getIt<CreateEditWorkoutPlanBloc>(), child: CreateEditWorkoutPlanScreen(planId: state.pathParameters['planId']))` as builder
- [X] T025 [US2] Update `CreateEditWorkoutPlanScreen` to handle `CreateEditPlanLoading` state (show `LoadingIndicator`) and `CreateEditPlanLoadError` state (show `ErrorCard` with message) in addition to `CreateEditPlanReady`; ensure the BlocConsumer navigates to an error screen / pops on `CreateEditPlanLoadError` if appropriate in `lib/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart`
- [ ] T026 [US2] Write widget tests for US2 acceptance scenarios: (1) edit mode title "Edit Workout Plan"; (2) name field pre-filled; (3) weighted exercise card shows Sets/Reps/Weight/Rest layout; (4) timeBased shows Sets/Duration/Rest; (5) bodyweight shows Sets/Reps/Rest; (6) Save button is lime/active on initial edit-mode render with valid data in `test/features/workout_plan/presentation/screens/create_edit_workout_plan_screen_test.dart`

**Checkpoint**: Navigate to `/plans/:someId/edit` for a seeded plan; form shows pre-filled data with correct exercise card layouts. VS-07 passes.

---

## Phase 5: User Story 3 — Add and Remove Exercises (Priority: P3)

**Goal**: Tapping "Add Exercise" opens the SCR-07 picker; a selected exercise appears as an editable card at the bottom; the Remove (×) button deletes a card; the empty well reappears when all exercises are removed.

**Independent Test**: VS-02–VS-05 from [quickstart.md](quickstart.md) — add one weighted, one timeBased, one bodyweight exercise; verify each card's field layout; remove one; verify it disappears.

- [X] T027 [US3] Create `ExerciseFieldBox` stateless widget (single numeric input cell: `String label`, `String value`, `ValueChanged<String> onChanged`, `bool isDanger = false`; uses `ExerciseFieldBox`-appropriate keyboard type; displays label above value) in `lib/features/workout_plan/presentation/widgets/exercise_field_box.dart`
- [X] T028 [US3] Create `ExerciseCard` stateless widget (`PlanExerciseFormEntry entry`, `int index`, `VoidCallback onRemove`, `ValueChanged<String> Function(ExerciseField) onFieldChanged`, `List<String>? fieldErrors`): renders exercise name, `ExerciseTypeLabel` badge, type-specific field grid (Weighted: Sets+Reps+Weight in a row, Rest full-width; TimeBased: Sets+Duration+Rest in a single row; Bodyweight: Sets+Reps+Rest in a single row), Remove (×) `IconButton`, and combined error text below card when `fieldErrors` is non-empty in `lib/features/workout_plan/presentation/widgets/exercise_card.dart`
- [X] T029 [US3] Implement `_onAddExerciseTapped()` method in `_CreateEditWorkoutPlanScreenState`: `await context.push<Exercise>(RoutePaths.planExercises, extra: PickerContext(planName: _currentName))` and dispatch `ExerciseAdded(exercise)` if result is non-null and widget is mounted in `lib/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart`
- [X] T030 [US3] Render the exercise list in `CreateEditWorkoutPlanScreen` body: when exercises list is empty show the empty well with list icon and "No exercises added yet" text plus a dashed "Add Exercise" button; when non-empty show `ListView` of `ExerciseCard` widgets followed by a regular "Add Exercise" button; connect `ExerciseCard.onRemove` to dispatch `ExerciseRemoved(index)` and `ExerciseCard.onFieldChanged` to dispatch `ExerciseFieldChanged(index, field, rawValue)` in `lib/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart`
- [ ] T031 [US3] Write widget tests for US3 acceptance scenarios: (1) Add Exercise button present in empty state; (2) after adding weighted exercise — card appears with Sets/Reps/Weight/Rest layout; (3) after adding timeBased — Sets/Duration/Rest; (4) after adding bodyweight — Sets/Reps/Rest; (5) tapping Remove removes card; (6) removing last card shows empty well; (7) Add Exercise button always visible at bottom of non-empty list in `test/features/workout_plan/presentation/screens/create_edit_workout_plan_screen_test.dart`

**Checkpoint**: Add three exercises of different types; each card shows correct fields; remove each; empty well returns. VS-02–VS-05 pass.

---

## Phase 6: User Story 4 — Save a Valid Plan (Priority: P4)

**Goal**: Tapping Save with a valid form triggers the saving state (spinner, dimmed form, disabled back), then navigates to SCR-10 on success; back stack is cleared so back from SCR-10 returns to Plans list.

**Independent Test**: VS-06 from [quickstart.md](quickstart.md) — fill name, add one exercise with all fields > 0, tap Save, see spinner, land on Plan Detail.

- [X] T032 [US4] Implement the Save Plan footer button in `CreateEditWorkoutPlanScreen`: a full-width `ElevatedButton` (lime, active) that dispatches `SaveRequested()`; when state is `CreateEditPlanSaving` swap to a lime button with `CircularProgressIndicator` and label "Saving…" (non-tappable); when state is `CreateEditPlanSaveFailure` swap to "Retry Save" (handled in US7); disable back icon during saving state in `lib/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart`
- [X] T033 [US4] Wire `BlocListener` to handle `CreateEditPlanSaved(planId)`: call `context.go('/plans/$planId')` so SCR-09 is replaced on the stack (back from SCR-10 goes to Plans list, not back to this form) in `lib/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart`
- [X] T034 [US4] Implement form dimming during `CreateEditPlanSaving`: wrap the scrollable form content in `IgnorePointer(ignoring: isSaving)` and apply `Opacity(opacity: isSaving ? 0.45 : 1.0)` to the form body in `lib/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart`
- [ ] T035 [US4] Write widget tests for US4 acceptance scenarios: (1) valid form → Save button is lime; (2) tapping Save triggers saving state (spinner visible, form dimmed); (3) on `CreateEditPlanSaved`, navigation goes to `/plans/:planId` via `context.go` (verify route change); (4) back icon is not interactive during saving state in `test/features/workout_plan/presentation/screens/create_edit_workout_plan_screen_test.dart`

**Checkpoint**: End-to-end create flow works. VS-06 passes.

---

## Phase 7: User Story 5 — Inline Validation on Invalid Save Attempt (Priority: P5)

**Goal**: Tapping Save with blank name, zero-value fields, or invalid exercise references shows per-field inline errors; errors clear immediately when the user corrects the field; Save stays disabled until all errors are resolved.

**Independent Test**: VS-08–VS-09 from [quickstart.md](quickstart.md) — tap Save with all zeros; see combined error below exercise card; fix each field; see errors clear; see Save button become active.

- [X] T036 [US5] Update `PlanNameField` to render a danger-red border and error text directly below the field when `validationError` is non-null; re-verify it already clears when error is null (this is a parameter that was added in T019 — verify rendering is correct) in `lib/features/workout_plan/presentation/widgets/plan_name_field.dart`
- [X] T037 [US5] Update `ExerciseCard` to render danger borders on individual `ExerciseFieldBox` cells and a combined error message text block below the card when `fieldErrors` is non-empty (error text styled with danger color); individual field danger state is derived from which error messages are present in `lib/features/workout_plan/presentation/widgets/exercise_card.dart`
- [X] T038 [US5] Connect validation state to screen: in `CreateEditWorkoutPlanScreen` body's `BlocBuilder`, pass `state.nameValidationError` to `PlanNameField.validationError` and `state.exerciseErrors[index]` to each `ExerciseCard.fieldErrors` in `lib/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart`
- [ ] T039 [US5] Write widget tests for US5 acceptance scenarios: (1) save with blank name → name danger border + "Plan name can't be blank." shown; (2) save with Sets=0 → Sets danger border + "Sets must be greater than 0." shown; (3) save with Weight=0 on weighted → Weight danger border + error shown; (4) correcting Sets field → Sets error clears immediately; (5) all errors cleared → Save becomes active in `test/features/workout_plan/presentation/screens/create_edit_workout_plan_screen_test.dart`

**Checkpoint**: VS-08–VS-09 and VS-10–VS-11 (field formatting) pass.

---

## Phase 8: User Story 6 — Unsaved Changes Guard (Priority: P6)

**Goal**: Back navigation (icon tap, swipe, or Android system back) with a dirty form shows the Discard dialog; Keep Editing dismisses safely; Discard navigates away; scrim tap = Keep Editing; clean form navigates immediately.

**Independent Test**: VS-12–VS-13 from [quickstart.md](quickstart.md) — type a name, tap back → dialog appears; tap Keep Editing → form intact; tap back again → dialog; tap Discard → Plans list.

- [X] T040 [US6] Create `DiscardDialog` stateless widget that renders a `showDialog`-compatible `AlertDialog` with: title "Discard changes?", subtitle "You have unsaved changes to this workout plan. Leaving now will discard them.", "Discard" `TextButton` (dim, left — pops dialog with `true`), "Keep Editing" `ElevatedButton` (lime, right — pops dialog with `false`) in `lib/features/workout_plan/presentation/widgets/discard_dialog.dart`
- [X] T041 [US6] Implement `_onBackRequested()` in `_CreateEditWorkoutPlanScreenState`: if state is saving, return early; if form is not dirty, call `context.pop()`; if dirty, show `DiscardDialog` via `showDialog` (with `barrierDismissible: true` so scrim tap = false = Keep Editing); if dialog result is `true`, call `context.pop()` in `lib/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart`
- [X] T042 [US6] Update `AppBar` leading `IconButton` `onPressed` to call `_onBackRequested()` instead of `context.pop()` in `lib/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart`; update `PopScope.onPopInvokedWithResult` to call `_onBackRequested()` when `didPop` is false
- [ ] T043 [US6] Write widget tests for US6 acceptance scenarios: (1) clean form (blank create mode) → back → no dialog; (2) dirty form (name typed) → back → dialog shown; (3) dialog → "Keep Editing" → dialog dismissed, form unchanged; (4) dialog → "Discard" → navigated back; (5) scrim tap on dialog → same as "Keep Editing" in `test/features/workout_plan/presentation/screens/create_edit_workout_plan_screen_test.dart`

**Checkpoint**: VS-12–VS-13 pass. Android back gesture also triggers guard.

---

## Phase 9: User Story 7 — Save Failure and Retry (Priority: P7)

**Goal**: When the database write fails, an error banner appears, the form remains editable, and a "Retry Save" footer button re-attempts the write.

**Independent Test**: VS-14 from [quickstart.md](quickstart.md) — simulate database write failure via fake data source in widget test; verify banner text, form editability, Retry re-enters saving state.

- [X] T044 [US7] Create `SaveFailureBanner` stateless widget: a `Container` below the app bar (danger background color, padding 12/16) showing bold header "Couldn't save your changes" and body "Something went wrong writing to local storage. Your edits below are kept — tap Retry to try again." in `lib/features/workout_plan/presentation/widgets/save_failure_banner.dart`
- [X] T045 [US7] Render `SaveFailureBanner` at the top of the screen body when state is `CreateEditPlanSaveFailure`; swap the footer button to a lime "Retry Save" `ElevatedButton` that dispatches `RetrySaveRequested()`; ensure the form content (`PlanNameField`, exercise list, Add Exercise button) is fully interactive (not dimmed) in the failure state in `lib/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart`
- [ ] T046 [US7] Write widget tests for US7 acceptance scenarios: (1) `CreateEditPlanSaveFailure` state → banner text visible; (2) form fields are interactive in failure state; (3) "Retry Save" button visible and tapping it dispatches `RetrySaveRequested()`; (4) after retry succeeds → `CreateEditPlanSaved` triggers navigation in `test/features/workout_plan/presentation/screens/create_edit_workout_plan_screen_test.dart`

**Checkpoint**: VS-14 passes. All 7 user stories are now implemented and their widget tests are green.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Format, analyze, full test run, and manual iOS Simulator validation.

- [X] T047 Run `dart format .` in `forge/` and fix any formatting issues in all new and modified files
- [X] T048 Run `flutter analyze` in `forge/` and resolve every warning or info-level issue introduced by this feature (zero new issues allowed)
- [X] T049 Run `flutter test` in `forge/` and verify all tests pass: existing 37+ tests from SCR-08 remain green; all new Bloc, mapper, repository, formatter, and screen tests pass
- [ ] T050 [P] Run manual validation scenarios VS-01 through VS-15 from [quickstart.md](quickstart.md) on iOS Simulator; document any deviations found

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately; T001 and T002 can run in parallel
- **Foundational (Phase 2)**: Depends on Phase 1 completion — BLOCKS all user story phases
  - Within Phase 2: T003/T004 first; T005 depends on T003+T004; T006/T007 depend on T005; T008 depends on T003+T004; T009 depends on T005+T008; T013 depends on T003+T004; T015 depends on T013+T014; T016 depends on T006+T007+T013+T014+T015; T018 depends on T016
  - T010, T011, T012, T017 can run in parallel with their preceding tasks targeting different files
- **User Story Phases (3–9)**: All depend on Phase 2 completion
  - US1 (Phase 3) must complete before US2 (Phase 4) — screen shell is built in US1
  - US3–US7 (Phases 5–9) depend on Phase 3 screen shell; can proceed sequentially
- **Polish (Phase 10)**: Depends on all user story phases complete

### User Story Dependencies

- **US1 (P1)**: Depends on Phase 2 — builds the screen shell
- **US2 (P2)**: Depends on US1 (screen shell exists)
- **US3 (P3)**: Depends on US1 (screen shell exists)
- **US4 (P4)**: Depends on US3 (exercise cards rendered, exercises in state)
- **US5 (P5)**: Depends on US3 (exercise cards rendered for error display)
- **US6 (P6)**: Depends on US1 (back icon exists) — can proceed after US1
- **US7 (P7)**: Depends on US4 (saving state infrastructure)

### Within Each Phase

- Domain tasks (T003–T007) before Data tasks (T008–T009)
- Entities before Repository
- Repository before Use Cases
- Use Cases before Bloc
- Bloc before DI registration
- DI registration before Screen
- Screen shell (US1) before advanced screen features (US2–US7)

### Parallel Opportunities (within Phase 2)

```text
# Run together after Phase 1:
T003 WorkoutPlanDetail entity
T004 PlanExercise entity

# Run together after T003+T004:
T005 Repository interface extension  ← blocks T006, T007, T009

# Run together after T005:
T006 SaveWorkoutPlanUseCase
T007 GetWorkoutPlanByIdUseCase
T008 WorkoutPlanMapper extension  (also needs T003+T004)

# Run together after T008:
T009 WorkoutPlanRepositoryImpl extension
T010 WorkoutPlanMapper tests
T011 WorkoutPlanRepositoryImpl tests

# Run independently at any time during Phase 2:
T012 ExerciseCatalogueScreen picker return type change
T013 PlanExerciseFormEntry
T014 CreateEditWorkoutPlanEvent
```

---

## Parallel Example: Phase 3 (US1)

```text
# T019 and T020 target different files — run together:
T019  PlanNameField widget
T020  CreateEditWorkoutPlanScreen shell

# After T020, T021 and T022 target different files — run together:
T021  app_routes.dart route wiring
T022  workout_plans_screen.dart FAB wiring

# After T021+T022:
T023  US1 widget tests
```

---

## Implementation Strategy

### MVP First (US1 Only — T001–T023)

1. Complete Phase 1 (T001–T002)
2. Complete Phase 2 (T003–T018) — all foundational work
3. Complete Phase 3 / US1 (T019–T023) — create mode blank form
4. **STOP AND VALIDATE**: Run VS-01; confirm "New Workout Plan" screen renders correctly with all expected elements; run `flutter test` on new tests
5. Deploy/demo the create mode entry point

### Incremental Delivery

| Increment | Tasks | Feature unlocked |
|---|---|---|
| Foundation | T001–T018 | Bloc, entities, data layer all wired |
| US1 MVP | T019–T023 | Create mode blank form accessible from Plans list |
| US2 | T024–T026 | Edit mode pre-filled form accessible from Plan Detail |
| US3 | T027–T031 | Exercise cards with Add/Remove |
| US4 | T032–T035 | Full save-to-Drift flow with navigation |
| US5 | T036–T039 | Inline validation errors |
| US6 | T040–T043 | Unsaved changes guard |
| US7 | T044–T046 | Save failure + retry |
| Polish | T047–T050 | Ship-ready |

---

## Notes

- `[P]` tasks target different files or have no unresolved dependencies — safe to parallelise
- `[Story]` label maps each task to the user story it delivers
- All screen widget tests use a `_FakeRepository` pattern (same as `workout_plans_screen_test.dart`) and `GoRouter` wrapper so `context.go()`/`context.push()` work in tests
- Constitution reminder: no `Cubit`, no network calls, no hardcoded colors — all new widgets use `AppColors.*` and `theme.textTheme`
- If `flutter analyze` introduces any warning in modified files (e.g., `exercise_catalogue_screen.dart` after the picker return type change), fix immediately before moving to the next task
