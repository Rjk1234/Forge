# Tasks: SCR-15 Workout Pre-Start / Overview

**Input**: Design documents from `specs/SCR-15-Workout-PreStart-Overview/mobile/001-scr-15-workout-prestart-overview/`

**Prerequisites**: [plan.md](plan.md) · [spec.md](spec.md) · [data-model.md](data-model.md) · [research.md](research.md) · [contracts/pre-start-bloc.md](contracts/pre-start-bloc.md) · [quickstart.md](quickstart.md)

**Organization**: Tasks grouped by user story — each story is independently implementable and testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Task can run in parallel with other [P] tasks in the same phase (different files, no in-phase dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths included in all task descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Cross-cutting changes required before any user story can be implemented. No user story work begins until this phase is complete.

- [X] T001 Add SCR-15 strings section to `forge/lib/core/strings/app_strings.dart` — `preStartScreenTitle`, `preStartExercisesSectionLabel`, `preStartBeginButton`, `preStartWeightNotSet`, `preStartMetaToday`, `preStartUnavailableTitle`, `preStartUnavailableBody`, `preStartBackToScheduleButton`, `preStartErrorTitle`, `preStartErrorBody`, `preStartRetryButton`, `preStartLoadingSemantics`
- [X] T002 Update `forge/lib/config/routes/app_routes.dart`: change `workoutPreStart` constant value from `'/plans/pre-start'` to `'/plans/:planId/start'`; add `workoutPreStartName = 'workoutPreStart'`; add `activeWorkout = '/workout/active'` and `activeWorkoutName = 'activeWorkout'` stub constants; add `GoRoute(path: 'start', name: RoutePaths.workoutPreStartName, builder: ...)` as a child of the existing `:planId` `ShellRoute`, wiring `BlocProvider<PreStartBloc>` with `planId` from path params and `scheduledWeekday` from `state.extra`; add a stub `GoRoute` for `activeWorkout` rendering a placeholder `Scaffold`
- [X] T003 Register `PreStartBloc` as a factory in `forge/lib/app/get_it_setup.dart`: `sl.registerFactory<PreStartBloc>(() => PreStartBloc(getWorkoutPlanById: sl()))`
- [X] T004 Update `forge/lib/features/schedule/presentation/widgets/day_row.dart`: change `onStartTap` callback from `VoidCallback` / `void Function(String planId)` to `void Function(String planId, int weekday)` and pass `day.weekday` alongside `planId` at the call site
- [X] T005 Update `forge/lib/features/schedule/presentation/widgets/week_schedule_list.dart`: update `OnStartDayCallback` typedef (or equivalent) from `void Function(String planId)` to `void Function(String planId, int weekday)`; propagate the updated signature through any intermediate wiring
- [X] T006 Update `forge/lib/features/schedule/presentation/screens/weekly_schedule_screen.dart`: complete the `TODO(SCR-15)` navigation stub — replace it with `context.push('/plans/$planId/start', extra: {'scheduledWeekday': weekday})` inside the `onStartDay` handler, using the `planId` and `weekday` received from the callback

**Checkpoint**: Infrastructure ready — strings, routes, DI, and schedule navigation all wired. User story phases may now begin.

---

## Phase 2: Foundational (PreStartBloc — Blocks All User Stories)

**Purpose**: The Bloc state machine must exist before any screen widget can compile. All three events and five states must be present.

**⚠️ CRITICAL**: No user story screen or test work can begin until T009 is complete.

- [X] T007 [P] Create `forge/lib/features/workout_plan/application/bloc/pre_start_event.dart` — define `sealed class PreStartEvent`, `PreStartRequested({required String planId, int? scheduledWeekday})`, and `PreStartRetried({required String planId, int? scheduledWeekday})`; all classes extend `Equatable`
- [X] T008 [P] Create `forge/lib/features/workout_plan/application/bloc/pre_start_state.dart` — define `sealed class PreStartState`, and the five concrete states: `PreStartInitial`, `PreStartLoading`, `PreStartLoaded({required WorkoutPlanDetail plan, int? scheduledWeekday, required bool isScheduledForToday})`, `PreStartUnavailable`, `PreStartError({required String message})`; `PreStartLoaded` and `PreStartError` override `props`
- [X] T009 Create `forge/lib/features/workout_plan/application/bloc/pre_start_bloc.dart` — implement `PreStartBloc extends Bloc<PreStartEvent, PreStartState>` with constructor `PreStartBloc({required GetWorkoutPlanByIdUseCase getWorkoutPlanById})`; register handlers for `PreStartRequested` and `PreStartRetried` using the shared `_onLoad` helper; guard concurrent loads (`if (state is PreStartLoading) return;`); fold `Either` result: `Left` → `PreStartError`, `Right(null)` or `Right(plan with empty exercises)` → `PreStartUnavailable`, `Right(plan)` → `PreStartLoaded` with `isScheduledForToday` computed as `scheduledWeekday != null && scheduledWeekday == DateTime.now().weekday` (depends on T007, T008)
- [X] T010 [P] Add `formatDuration(int seconds) → String` utility to `forge/lib/core/utils/` (create `format_utils.dart` if it does not already exist, or append to the existing utils file): formats as `MM:SS` using `padLeft(2, '0')` — e.g., 45 → `'00:45'`, 90 → `'01:30'`

**Checkpoint**: `PreStartBloc`, both event classes, all five states, and `formatDuration` exist. User story implementation can begin.

---

## Phase 3: User Story 1 — Review a Plan and Begin the Workout (Priority: P1) 🎯 MVP

**Goal**: A user can open the pre-start overview for a valid plan, see every exercise with type-appropriate targets, and tap "Begin Workout" to proceed.

**Independent Test**: Open the overview for a plan with at least one exercise from each `ExerciseType`. Verify: (A) shimmer skeleton appears immediately, (B) plan name + meta line + exercise cards with correct dot colors and field grids render after load, (C) "Begin Workout" button is visible and navigates to the active-workout stub.

- [X] T011 [P] [US1] Create `forge/test/features/workout_plan/application/bloc/pre_start_bloc_test.dart` — write all Bloc unit tests using `bloc_test` and `mocktail`: (1) happy path, no weekday → `[Loading, Loaded(isScheduledForToday: false)]`; (2) today weekday → `[Loading, Loaded(isScheduledForToday: true)]`; (3) non-today weekday → `[Loading, Loaded(isScheduledForToday: false)]`; (4) use case returns `Right(null)` → `[Loading, Unavailable]`; (5) plan with empty exercises → `[Loading, Unavailable]`; (6) use case returns `Left(CacheException)` → `[Loading, Error]`; (7) retry after error → `[..., Loading, Loaded]`; (8) rapid retry while loading (FR-009) → second event is no-op, only one load; (9) **FR-007 negative assertion** — verify `GetWorkoutPlanByIdUseCase` is the only use case invoked across all scenarios (use `verifyNever` on any mock write use case) confirming no Drift write is ever triggered by this Bloc
- [X] T012 [P] [US1] Create `forge/lib/features/workout_plan/presentation/widgets/pre_start_skeleton.dart` — implement `PreStartSkeleton` (`StatelessWidget`) that renders exactly 3 shimmer placeholder cards; accept an `Animation<double> animation` parameter; use `AnimatedBuilder` with a shimmer gradient sweep using `AppColors.card` and `AppColors.cardAlt`; cards use `14px` border radius, `AppColors.border` border; no actual content rendered
- [X] T013 [P] [US1] Create `forge/lib/features/workout_plan/presentation/widgets/exercise_preview_card.dart` — implement `ExercisePreviewCard({required PlanExercise exercise})` (`StatelessWidget`); card: `AppColors.card` fill, `1px` `AppColors.border` border, `14px` radius; header row: `8×8` type dot (lime=weighted, cyan=timeBased, textMuted=bodyweight), exercise name in `textTheme.titleSmall` with `softWrap: true` and **no `maxLines` or `overflow` constraint** (long names must wrap to additional lines, never be ellipsized — spec edge case); field grid below: weighted → 3-col (Sets / Reps / Weight), bodyweight → 2-col (Sets / Reps), timeBased → 2-col (Sets / Duration); weight null/zero → display `AppStrings.preStartWeightNotSet` (`"—"`); duration → `formatDuration(targetDurationSec!)` from `format_utils.dart`; field labels use `textTheme.labelSmall` in `AppColors.textMuted`, values use `textTheme.bodyMedium`
- [X] T014 [US1] Create `forge/lib/features/workout_plan/presentation/screens/pre_start_screen.dart` — implement `WorkoutPreStartScreen({required String planId, int? scheduledWeekday})` as `StatefulWidget`; `initState` creates `AnimationController` (repeating, 1200ms) and dispatches `PreStartRequested`; `dispose` disposes controller; `build` uses `BlocBuilder<PreStartBloc, PreStartState>` with branches for `PreStartLoading` (renders `PreStartSkeleton(animation: _controller)`), `PreStartLoaded` (renders `CustomScrollAppBar` with plan name hero + meta line per FR-008, `"EXERCISES"` section label, `ListView` of `ExercisePreviewCard`s, pinned `"Begin Workout"` lime pill footer that calls `context.pushReplacement(RoutePaths.activeWorkout)` — **use `pushReplacement`, not `push`**, so the pre-start screen is removed from the back-stack and returning from the active workout lands on the original caller, not back here (spec edge case)); app-bar back uses `go_router`'s default pop (returns to caller for Loading and Loaded states); use `Theme.of(context)` stored in a local variable; use `AppStrings.*` for all strings; check `context.mounted` after any async gap (depends on T012, T013)
- [X] T015 [US1] Create `forge/test/features/workout_plan/presentation/screens/pre_start_screen_test.dart` — write widget tests for State A (skeleton visible, no begin button) and State B (plan name visible, exercise cards present, correct dot rendered for each type, begin-button visible and tappable, FR-008 meta-line variants: null weekday shows count only, today weekday shows "Today", non-today weekday shows weekday name); use `MockPreStartBloc` via `mocktail`

**Checkpoint**: User Story 1 is fully functional. A valid plan can be reviewed and "Begin Workout" fires. Bloc tests pass. Widget tests for States A and B pass.

---

## Phase 4: User Story 2 — Plan Unavailable Blocking State (Priority: P1)

**Goal**: When the referenced plan has been deleted or has no exercises, the user sees a clear blocked state with a single way back to the weekly schedule. No "Begin Workout" action is available.

**Independent Test**: Open the overview for a deleted plan (use-case returns `Right(null)`) and for a zero-exercise plan. Verify State C renders with alert-circle icon, blocked copy, and "Back to Schedule" button. Confirm tapping "Back to Schedule" navigates to the weekly schedule regardless of entry point (FR-006 clarification).

- [X] T016 [P] [US2] Create `forge/lib/features/workout_plan/presentation/widgets/pre_start_unavailable_state.dart` — implement `PreStartUnavailableState({required VoidCallback onBack})` (`StatelessWidget`); full-screen centred column: `30×30` `Icons.error_outline` (or equivalent alert-circle icon) in `AppColors.danger`; `AppStrings.preStartUnavailableTitle` in `textTheme.titleMedium`; `AppStrings.preStartUnavailableBody` in `textTheme.bodyMedium` in `AppColors.textMuted`; `ElevatedButton`/`OutlinedButton` with `AppStrings.preStartBackToScheduleButton` label that calls `onBack`; button fills `AppColors.cardAlt`
- [X] T017 [US2] Update `forge/lib/features/workout_plan/presentation/screens/pre_start_screen.dart` — add `PreStartUnavailable` branch to the `BlocBuilder`: render `PreStartUnavailableState(onBack: () => context.go(RoutePaths.weeklySchedule))` (always navigates to weekly schedule per FR-006 clarification, not `context.pop()`); ensure app bar is still present with the screen title
- [X] T018 [US2] Update `forge/test/features/workout_plan/presentation/screens/pre_start_screen_test.dart` — add State C widget tests: unavailable state renders, "Back to Schedule" button present and tappable, "Begin Workout" button absent in State C

**Checkpoint**: User Story 2 works independently. Both null-plan and zero-exercise-plan produce State C. "Back to Schedule" always goes to weekly schedule.

---

## Phase 5: User Story 3 — Load Failure and Retry (Priority: P2)

**Goal**: When the Drift read fails, the user sees a distinct error state (not the "plan unavailable" message), with a Retry button and a secondary "Back to Schedule" button. Rapid Retry taps do not cause concurrent loads.

**Independent Test**: Inject a failing use case (returns `Left(CacheException)`). Verify State D renders calendar-error icon, error title/body (wording distinct from State C), and both buttons. Tap Retry — verify loading skeleton reappears. Tap "Back to Schedule" — verify navigation to weekly schedule.

- [X] T019 [P] [US3] Create `forge/lib/features/workout_plan/presentation/widgets/pre_start_error_state.dart` — implement `PreStartErrorState({required VoidCallback onRetry, required VoidCallback onBack})` (`StatelessWidget`); full-screen centred column: `30×30` calendar-error icon (`Icons.calendar_month` or `Icons.event_busy`) in `AppColors.danger`; `AppStrings.preStartErrorTitle` in `textTheme.titleMedium`; `AppStrings.preStartErrorBody` in `textTheme.bodyMedium` in `AppColors.textMuted`; two buttons: primary lime pill `AppStrings.preStartRetryButton` → `onRetry`, secondary `AppStrings.preStartBackToScheduleButton` with `AppColors.cardAlt` fill → `onBack`
- [X] T020 [US3] Update `forge/lib/features/workout_plan/presentation/screens/pre_start_screen.dart` — add `PreStartError` branch to the `BlocBuilder`: render `PreStartErrorState(onRetry: () => context.read<PreStartBloc>().add(PreStartRetried(planId: widget.planId, scheduledWeekday: widget.scheduledWeekday)), onBack: () => context.go(RoutePaths.weeklySchedule))`; raw error message MUST NOT be displayed to the user (screen always shows `AppStrings.preStartErrorTitle`/`Body`)
- [X] T021 [US3] Update `forge/test/features/workout_plan/presentation/screens/pre_start_screen_test.dart` — add State D widget tests: error state renders, title/body text distinct from State C copy, Retry button dispatches `PreStartRetried`, Back button present, "Begin Workout" absent in State D; add FR-009 test: mock Bloc stays in `PreStartLoading` while Retry is tapped multiple times and verify only one load attempt is tracked

**Checkpoint**: All three user stories work independently. All Bloc tests and screen widget tests pass.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, formatting, and analyzer clean-up across all modified files.

- [X] T022 Run `dart format .` from `forge/` and commit formatted changes to all new and modified source files
- [X] T023 Run `flutter analyze` from `forge/` and resolve every warning or error introduced by SCR-15 changes (unused imports, missing `const`, unnecessary casts, etc.)
- [X] T024 Run `flutter test` from `forge/` — confirm all tests pass including SCR-15 Bloc tests, SCR-15 screen tests, and pre-existing SCR-12 tests (which must continue to pass after the `onStartDay` callback signature change in T004–T006)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — begin immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion — BLOCKS all user story work
- **US1 (Phase 3)**: Depends on Phase 2 completion
- **US2 (Phase 4)**: Depends on Phase 3 completion (extends `pre_start_screen.dart` built in T014)
- **US3 (Phase 5)**: Depends on Phase 4 completion (extends `pre_start_screen.dart` again in T020)
- **Polish (Phase 6)**: Depends on all user story phases complete

### User Story Dependencies

- **US1 (P1)**: Can start after Phase 2 — no dependency on US2 or US3
- **US2 (P1)**: Extends `pre_start_screen.dart` (T014) — must follow US1 completion
- **US3 (P2)**: Extends `pre_start_screen.dart` (T017) — must follow US2 completion

### Within Phase 1

T001–T003 are independent files; T004–T006 must run sequentially (typedef change must precede usage update in schedule screen).

### Within Phase 2

T007, T008, T010 can run in parallel — all produce different files with no interdependencies. T009 depends on T007 and T008 (imports both event and state files).

### Within Phase 3

T011, T012, T013 can run in parallel — each produces a different file. T014 depends on T012 and T013 (imports skeleton and exercise card). T015 depends on T014 (tests the screen).

### Within Phase 4

T016 can run in parallel with T017 write-prep, but T017 (editing screen) must follow T016 (the widget it renders). T018 depends on T017.

### Within Phase 5

T019 can run in parallel with T020 write-prep, but T020 (editing screen) must follow T019 (the widget it renders). T021 depends on T020.

---

## Parallel Opportunities

### Phase 2 (maximum parallelism)

```
Parallel:
  T007 — pre_start_event.dart
  T008 — pre_start_state.dart
  T010 — format_utils.dart

Sequential after both complete:
  T009 — pre_start_bloc.dart
```

### Phase 3 (maximum parallelism)

```
Parallel:
  T011 — pre_start_bloc_test.dart (bloc tests)
  T012 — pre_start_skeleton.dart
  T013 — exercise_preview_card.dart

Sequential after T012 + T013 complete:
  T014 — pre_start_screen.dart

Sequential after T014 complete:
  T015 — pre_start_screen_test.dart (States A/B)
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational — CRITICAL, blocks all stories
3. Complete Phase 3: User Story 1 (shimmer + plan preview + Begin Workout)
4. **STOP and VALIDATE**: Run quickstart.md Scenarios 1, 2, 3, 9 — shimmer, plan display, FR-008 meta, begin-workout stub
5. US1 is the complete, independently valuable MVP

### Incremental Delivery

1. Phase 1 + Phase 2 → infrastructure ready
2. Phase 3 → US1 MVP: plan review and begin workout
3. Phase 4 → US2: blocked state for unavailable plan (equal P1 priority)
4. Phase 5 → US3: load-failure recovery (P2, additive)
5. Phase 6 → polish and full test confirmation

---

## Notes

- `[P]` tasks touch different files with no in-phase dependencies — safe to implement concurrently
- `[US#]` label maps each task to a user story for traceability back to spec.md acceptance criteria
- SCR-12 tests MUST still pass after T004–T006 (schedule callback signature update) — run them as part of T024
- Bloc raw error message MUST NOT be surfaced in UI (use `AppStrings.preStartErrorBody`) — verified in T021
- `context.mounted` check required in `WorkoutPreStartScreen` after any `async` gap (T014)
- All new color references MUST use `AppColors.*` or `theme.colorScheme.*` — never hardcoded hex
- All new strings MUST use `AppStrings.*` — verified by T022–T024 analyzer pass
- `PreStartBloc` MUST be registered as `registerFactory` (not singleton) so each screen push gets a fresh Bloc instance
