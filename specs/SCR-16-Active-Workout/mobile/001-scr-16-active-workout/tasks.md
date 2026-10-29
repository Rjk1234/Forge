# Tasks: SCR-16 Active Workout

**Input**: Design documents from `specs/SCR-16-Active-Workout/mobile/001-scr-16-active-workout/`

**Prerequisites**: spec.md, plan.md, research.md, data-model.md, contracts/active-workout-bloc.md, quickstart.md

**Tests**: Included — required by constitution (Application 80%+, Domain 90%+ coverage targets; ADR-027 all states must be tested).

**Organization**: Tasks grouped by user story phase. Phase 1 (Setup) and Phase 2 (Foundational) MUST complete before any user-story phase begins.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no shared dependency)
- **[Story]**: Which user story (US1–US4) — omitted for Setup/Foundational/Polish phases

---

## Phase 1: Setup — Entity and Schema Changes

**Purpose**: Additive domain entity changes and storage record/table column additions. These are backward-compatible modifications to existing files; they block all user story phases because the Bloc and use case depend on the updated entities.

**⚠️ CRITICAL**: Phase 2 cannot begin until T005 (build_runner) succeeds with zero errors.

- [X] T001 [P] Modify `forge/lib/features/workout_session/domain/entities/actual_set.dart` — add `final bool skipped;` field with default `false`; update constructor to `const ActualSet({this.repetitions, this.weight, this.durationSec, this.skipped = false})`; add `skipped` to `props` list

- [X] T002 [P] Modify `forge/lib/features/workout_session/domain/entities/workout_session.dart` — add `final DateTime startedAt;` field; add `required this.startedAt` to constructor; add `startedAt` to `props` list; add doc-comment noting `sessionDurationSec = completedAt.difference(startedAt).inSeconds`

- [X] T003 Modify `forge/lib/features/workout_session/data/models/actual_set_record.dart` — add `final bool skipped;` and the `skipped` boolean column (default `false`) on the `ActualSets` table in `AppDatabase`; update constructor to include `this.skipped = false`; MUST mirror the entity change in T001

- [X] T004 Modify `forge/lib/features/workout_session/data/models/workout_session_record.dart` — add `final DateTime? startedAt;` and a nullable `started_at` column on the `WorkoutSessions` table in `AppDatabase` (nullable so rows without a start timestamp return null); update constructor to include `this.startedAt`; MUST mirror the entity change in T002

- [X] T005 Regenerate Drift code — run `cd forge && flutter pub run build_runner build --delete-conflicting-outputs` from repo root; verify `app_database.g.dart` regenerates without errors; fix any conflicts before proceeding

- [X] T006 Update `forge/lib/features/workout_session/data/mappers/workout_session_mapper.dart` — in `_actualSetToDomain`: add `skipped: model.skipped`; in `_actualSetToRecord`: add `skipped: set.skipped`; in `toDomain` (WorkoutSession): add `startedAt: model.startedAt ?? model.completedAt` (fallback for old records); in `toRecord` (WorkoutSession): add `startedAt: session.startedAt`; follow existing mapper style exactly

**Checkpoint**: `flutter analyze` must report zero issues before Phase 2.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: AppStrings, route constants, GoRoutes, SaveWorkoutSessionUseCase, full ActiveWorkoutBloc (events + state + bloc), and GetIt registrations. ALL must be complete before any user-story phase can begin.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T007 [P] Add SCR-16 strings section to `forge/lib/core/strings/app_strings.dart` — add all keys from data-model.md §New AppStrings: `activeWorkoutCompleteSetButton`, `activeWorkoutSkipButton`, `activeWorkoutPauseButton`, `activeWorkoutResumeButton`, `activeWorkoutCancelButton`, `activeWorkoutRepsLabel`, `activeWorkoutWeightLabel`, `activeWorkoutDurationLabel`, `activeWorkoutRepErrorZero`, `activeWorkoutWeightErrorNegative`, `activeWorkoutDurationErrorZero`, `activeWorkoutWriteErrorTitle`, `activeWorkoutWriteErrorBody`, `activeWorkoutRetryButton`, `activeWorkoutPausedTitle`, `cancelWorkoutStubLabel`, `postWorkoutStubLabel`; follow the existing `// SCR-XX:` comment-header convention

- [X] T008 [P] Add route path constants to `forge/lib/config/routes/app_routes.dart` — add to the `RoutePaths` class: `static const String activeWorkout = '/workout/active'`, `static const String activeWorkoutName = 'activeWorkout'`, `static const String cancelWorkout = '/workout/cancel'`, `static const String cancelWorkoutName = 'cancelWorkout'`, `static const String postWorkout = '/workout/summary'`, `static const String postWorkoutName = 'postWorkout'`; follow existing constant-pair naming pattern

- [X] T009 Add GoRoutes to `forge/lib/config/routes/app_routes.dart` — add three top-level `GoRoute` entries (not nested under `/plans/:planId`): (1) `activeWorkout` route at `/workout/active`: reads `state.extra as WorkoutPlanDetail`, wraps in `BlocProvider(create: (_) => sl<ActiveWorkoutBloc>()..add(ActiveWorkoutStarted(plan: plan)))`, child is `const ActiveWorkoutScreen()`; (2) `cancelWorkout` stub at `/workout/cancel`: plain `Scaffold(body: Center(child: Text(AppStrings.cancelWorkoutStubLabel)))`; (3) `postWorkout` stub at `/workout/summary`: plain `Scaffold(body: Center(child: Text(AppStrings.postWorkoutStubLabel)))`; MUST be sequential after T008 (same file)

- [X] T009a [P] Create `forge/lib/features/workout_plan/workout_plan.dart` barrel file — export `WorkoutPlanDetail` and `PlanExercise` from their respective domain entity files; this barrel is the ONLY path through which `workout_session` (or any other feature) may import these types (constitution §I §5 requires cross-feature imports to go through published feature barrel files, not direct internal paths); verify no existing code imports these types via a direct internal path (grep `workout_plan/domain/entities` in `workout_session/`) — if found, update those imports to the barrel

- [X] T010 [P] Create `forge/lib/features/workout_session/domain/usecases/save_workout_session_usecase.dart` — `class SaveWorkoutSessionUseCase`; constructor takes `WorkoutSessionRepository repository`; single `call(WorkoutSession session) → Future<Either<AppException, void>>` method; validates that `session.sessionExercises` contains at least one `SessionExercise` with at least one `ActualSet` where `skipped == false`; if criterion fails: return `Left(CacheException('Session has no logged sets'))` without calling repository; otherwise: delegate to `_repository.saveSession(session)`; follow the style of `forge/lib/features/workout_plan/domain/usecases/save_workout_plan_usecase.dart`

- [X] T011 [P] Create `forge/lib/features/workout_session/application/bloc/active_workout_event.dart` — declare sealed class `ActiveWorkoutEvent extends Equatable`; concrete events (all extend `ActiveWorkoutEvent`): `ActiveWorkoutStarted({required WorkoutPlanDetail plan})`, `ActiveWorkoutCompleteSetRequested({int? reps, double? weight, int? durationSec})`, `ActiveWorkoutSkipSetRequested`, `ActiveWorkoutPauseRequested`, `ActiveWorkoutResumeRequested`, `ActiveWorkoutFieldChanged({required ActiveWorkoutField field, required String value})`, `ActiveWorkoutRetryFinishRequested`; each must have `props`; `ActiveWorkoutField` enum (`reps, weight, duration`) lives in this file

- [X] T012 [P] Create `forge/lib/features/workout_session/application/bloc/active_workout_state.dart` — declare sealed class `ActiveWorkoutState extends Equatable`; concrete states: `ActiveWorkoutInitial` (empty props); `ActiveWorkoutRunning` with fields: `currentExercise: PlanExercise`, `exerciseIndex: int`, `exerciseCount: int`, `currentSetIndex: int`, `setStatuses: List<SetStatus>`, `repError: String?`, `weightError: String?`, `durationError: String?`, `isPaused: bool` (defaults false), `writeError: String?`, `navigateToPostWorkout: bool` (defaults false), `navigateToCancel: bool` (defaults false); full `props` including all fields; full `copyWith` method; `SetStatus` enum (`pending, logged, skipped`) lives in this file

- [X] T013 Create `forge/lib/features/workout_session/application/bloc/active_workout_bloc.dart` — `class ActiveWorkoutBloc extends Bloc<ActiveWorkoutEvent, ActiveWorkoutState>`; private fields: `late WorkoutPlanDetail _plan`, `late DateTime _startedAt`, `late List<List<_SetEntry>> _loggedSets`, `WorkoutSession? _completedSession`, `int _exerciseIdx = 0`, `int _setIdx = 0`; inner class `_SetEntry` with `status: SetStatus`, `actualReps?`, `actualWeight?`, `actualDurationSec?`; handlers (register all in constructor): `_onStarted`, `_onCompleteSet` (validate per ExerciseType, log set, advance or trigger finish/discard), `_onSkipSet` (mark skipped, advance or trigger discard if last-of-last with 0 logged), `_onPause` (copyWith isPaused:true), `_onResume` (copyWith isPaused:false), `_onFieldChanged` (clear the matching error field only), `_onRetryFinish` (reuse `_completedSession`, call use case again); `_triggerFinish` private helper: assemble `WorkoutSession` from `_loggedSets`, store in `_completedSession`, call `SaveWorkoutSessionUseCase`, on success emit copyWith(navigateToPostWorkout:true), on failure emit copyWith(writeError:...); `_buildRunning()` helper: constructs `ActiveWorkoutRunning` from current private state; `_loggedCount` helper: counts non-skipped sets across all exercises; MUST NOT import any data/ or presentation/ layer; MUST depend on T010+T011+T012

- [X] T014 Register new components in `forge/lib/app/get_it_setup.dart` — in the workout_session section: add `sl.registerLazySingleton<SaveWorkoutSessionUseCase>(() => SaveWorkoutSessionUseCase(repository: sl()))` and `sl.registerFactory<ActiveWorkoutBloc>(() => ActiveWorkoutBloc(saveWorkoutSession: sl()))`; follow the existing registration order and grouping style; MUST be sequential after T013

**Checkpoint**: `flutter analyze` must report zero issues before Phase 3. The Bloc tests in Phase 3 exercise all Bloc logic independently of the UI.

---

## Phase 3: User Story 1 — Log Sets and Complete the Workout (Priority: P1) 🎯 MVP

**Goal**: Fully functional set-by-set logging flow for all three exercise types (weighted, bodyweight, time-based), advancing through sets and exercises, triggering Finish on the last set (with ≥1 logged set), handling write failure with Retry, and write Bloc unit tests for all scenarios.

**Independent Test**: Run `flutter test test/features/workout_session/application/bloc/active_workout_bloc_test.dart` — all 11 scenarios pass. Then run the app, navigate to `/workout/active` with a test plan, log all sets, verify SCR-19 stub appears, verify Drift record exists.

- [X] T015 [P] [US1] Create `forge/lib/features/workout_session/presentation/widgets/set_progress_row.dart` — `class SetProgressRow extends StatelessWidget`; constructor: `const SetProgressRow({required List<SetStatus> statuses, required int currentSetIndex})`; renders a `Wrap` of circular indicator widgets (8×8 pt); colors sourced from `AppColors.*` or `colorScheme`: `SetStatus.logged` → lime accent, `SetStatus.skipped` → `textMuted` (dim), `SetStatus.pending` → `surface` (dim outline); the current set (`index == currentSetIndex`) gets a distinct border ring or slightly larger size; wraps to additional lines automatically via `Wrap`; `const` constructor where possible; no magic numbers — use design token constants

- [X] T016 [P] [US1] Create `forge/lib/features/workout_session/presentation/widgets/set_field_row.dart` — `class SetFieldRow extends StatelessWidget`; constructor: `const SetFieldRow({required ExerciseType type, required TextEditingController repsController, required TextEditingController weightController, required TextEditingController durationController, this.repError, this.weightError, this.durationError, required VoidCallback onCompleteSet, required VoidCallback onSkip})`; renders field layout per type: `ExerciseType.weighted` → 2-column Row (Reps + Weight (kg)); `ExerciseType.bodyweight` → 1-column (Reps only); `ExerciseType.timeBased` → 1-column (Duration only); each field uses an existing `AppTextField` or equivalent project text-field widget; field labels from `AppStrings.activeWorkout*Label`; each field gets `onChanged: (v) => onChanged(field, v)` parameter (add `ValueChanged<(ActiveWorkoutField, String)>? onFieldChanged` to signature); inline error text below field when the corresponding error is non-null (use `textTheme.bodySmall` in danger color); "Complete Set" lime-pill button and "Skip" secondary button at the bottom; `softWrap: true` on all Text — no maxLines or overflow clip; no hardcoded colors or strings

- [X] T017 [US1] Create `forge/lib/features/workout_session/presentation/screens/active_workout_screen.dart` — `class ActiveWorkoutScreen extends StatefulWidget`; `_ActiveWorkoutScreenState` owns three `TextEditingController` (reps, weight, duration) and disposes them in `dispose()`; `initState` adds listeners to each controller: `_repsController.addListener(() { context.read<ActiveWorkoutBloc>().add(ActiveWorkoutFieldChanged(field: ActiveWorkoutField.reps, value: _repsController.text)); })`; when `BlocBuilder` emits a new `exerciseIndex` or `currentSetIndex` (i.e., set advanced), reset controllers to new target values using `SchedulerBinding.instance.addPostFrameCallback`; build: top-level `PopScope(canPop: false, onPopInvokedWithResult: (_, __) { if (context.mounted) context.push(RoutePaths.cancelWorkout); })`; inside: `BlocListener` that checks `navigateToPostWorkout` flag → `context.go(RoutePaths.postWorkout)` and `navigateToCancel` flag → `context.push(RoutePaths.cancelWorkout)` (check `context.mounted` before each); `BlocBuilder` renders: exercise counter text ("Exercise N / M"), exercise name (`textTheme.headlineSmall`, `softWrap: true`), `SetProgressRow`, `SetFieldRow` (passes controllers, errors from state, onCompleteSet dispatches `ActiveWorkoutCompleteSetRequested`, onSkip dispatches `ActiveWorkoutSkipSetRequested`, onFieldChanged dispatches `ActiveWorkoutFieldChanged`), Cancel button (text, routes to SCR-18 via `context.push(RoutePaths.cancelWorkout)`), Pause button (dispatches `ActiveWorkoutPauseRequested`); **Complete Set button must be disabled (not just tappable-but-blocked) when any error is currently showing**: `enabled: state.repError == null && state.weightError == null && state.durationError == null && state.writeError == null` — this satisfies spec US2 independent test ("Complete Set is disabled"); write-error banner (visible when `state.writeError != null`): shows `AppStrings.activeWorkoutWriteErrorTitle`, `activeWorkoutWriteErrorBody`, and "Retry" button that dispatches `ActiveWorkoutRetryFinishRequested`; no hardcoded colors, strings, or dimensions; MUST depend on T015+T016

- [X] T018 [P] [US1] Create `forge/test/features/workout_session/application/bloc/active_workout_bloc_test.dart` — write 11 `blocTest` scenarios using `bloc_test` + `mocktail`; mock `SaveWorkoutSessionUseCase`; build a helper `_makePlan({exerciseTypes})` that creates a `WorkoutPlanDetail` with the requested exercise types (1 set each for simplicity); scenarios: (1) Started → emits Running at ex:0 set:0 all-pending; (2) CompleteSet(reps:10) on weighted → emits Running at ex:0 set:1 dot[0]=logged; (3) CompleteSet(reps:0) invalid → emits Running with repError non-null; (4) CompleteSet(weight:-1.0) invalid → emits Running with weightError non-null; (5) CompleteSet(durationSec:0) invalid → emits Running with durationError non-null; (6) FieldChanged(reps,'5') after repError → emits Running with repError null; (7) Skip → emits Running with dot[0]=skipped, set:1; (8) Pause → emits Running isPaused:true; (9) Resume → emits Running isPaused:false; (10) Complete last set, ≥1 logged, use case returns Right(unit) → emits Running with navigateToPostWorkout:true; (11) Complete last set, 0 logged, → emits Running with navigateToCancel:true; (12) Use case fails on Finish → emits Running with writeError non-null; (13) RetryFinish, use case returns Right → emits Running with navigateToPostWorkout:true (same sessionId reused — verify via captured arg to mock)

**Checkpoint**: All 13 Bloc test scenarios pass. US1 is fully functional end-to-end: open screen → log sets → Finish → SCR-19 stub.

---

## Phase 4: User Story 2 — Inline Validation Blocks Invalid Entries (Priority: P1)

**Goal**: Confirm that field validation errors appear on Complete Set tap and clear in real time as the user corrects values. The Bloc logic already exists (T013); this phase adds a widget test to verify the screen-level rendering and controller-listener wiring.

**Independent Test**: Run `flutter test test/features/workout_session/presentation/screens/active_workout_screen_test.dart` — error-display and real-time-clear scenarios pass.

- [X] T019 [P] [US2] Create `forge/test/features/workout_session/presentation/screens/active_workout_screen_test.dart` — widget tests using a mocked `ActiveWorkoutBloc` (via `MockBloc` from bloc_test); scenarios: (1) when state has `repError: 'Reps must be greater than 0'`, verify error text visible on screen; (2) when state has no errors, verify no error text visible; (3) when state advances `currentSetIndex`, verify `TextEditingController.text` is reset to new target value; (4) when `navigateToPostWorkout: true`, verify `GoRouter` navigates to `postWorkout` route; (5) when `writeError` non-null, verify write-error banner visible and Retry button present; follow the widget test patterns from `forge/test/features/workout_plan/presentation/screens/` for mock router setup

- [X] T020 [US2] Update `forge/lib/features/workout_session/presentation/widgets/set_field_row.dart` — review T016 implementation and confirm: (a) each `TextField`/`AppTextField` has an `onChanged` wired to `onFieldChanged` callback with the correct `ActiveWorkoutField` value; (b) error text renders below the field using `textTheme.bodySmall` in danger/error color token; (c) no `maxLines` or `overflow` set on exercise-name `Text` anywhere in the widget; (d) all strings sourced from `AppStrings`; if any gap found, fix inline; this task is complete when T019 widget tests pass

**Checkpoint**: US2 fully verified. Error appears on invalid tap; clears on field edit before next tap.

---

## Phase 5: User Story 3 — Pause and Resume Mid-Workout (Priority: P2)

**Goal**: Paused overlay appears on Pause tap, obscures workout content with opacity + desaturation (no scrim), Cancel and Resume available in overlay; Resume restores execution state.

**Independent Test**: Run app, log one set, tap Pause — overlay visible with reduced-opacity content below. Tap Resume — workout resumes at same position. Tap Cancel in overlay — routes to SCR-18 stub.

- [X] T021 [P] [US3] Create `forge/lib/features/workout_session/presentation/widgets/paused_workout_overlay.dart` — `class PausedWorkoutOverlay extends StatelessWidget`; constructor: `const PausedWorkoutOverlay({required VoidCallback onResume, required VoidCallback onCancel})`; renders a centered `Card` or `Container` with the pause icon (`Icons.pause_circle_outline`), `AppStrings.activeWorkoutPausedTitle` in `textTheme.titleLarge`, a "Resume" lime-pill button (calls `onResume`), and a "Cancel" secondary button (calls `onCancel`); no background scrim; `const` where possible; all colors from `colorScheme`/`AppColors`; all strings from `AppStrings`

- [X] T022 [US3] Update `forge/lib/features/workout_session/presentation/screens/active_workout_screen.dart` — wrap the main workout content (`Column` with exercise counter, exercise name, `SetProgressRow`, `SetFieldRow`, buttons) in a `Stack`; when `isPaused == true`: apply `ColorFiltered(colorFilter: ColorFilter.matrix([grayscale matrix values]), child: Opacity(opacity: 0.35, child: mainContent))` and overlay `PausedWorkoutOverlay(onResume: () => bloc.add(ActiveWorkoutResumeRequested()), onCancel: () => context.push(RoutePaths.cancelWorkout))` centered in the Stack; when `isPaused == false`: render main content normally with no filter; `Pause` button remains visible and tappable only in the non-paused state; MUST depend on T021

**Checkpoint**: Pause/Resume fully functional. Cancel in Paused state routes to SCR-18 stub.

---

## Phase 6: User Story 4 — Cancel or Discard the Workout (Priority: P2)

**Goal**: Verify all cancel and discard paths: Cancel button (Active state), Cancel button (Paused overlay — T022), OS back gesture, and FR-009 zero-logged-sets discard. All confirmed by widget tests.

**Independent Test**: Run widget tests — all cancel/discard paths produce navigation to SCR-18 or SCR-18 stub. No Drift write on any cancel path.

- [X] T023 [P] [US4] Add cancel/discard widget test scenarios to `forge/test/features/workout_session/presentation/screens/active_workout_screen_test.dart` — add to the existing test file: (1) verify `PopScope` blocks direct pop and routes to `cancelWorkout` on OS back simulation (`tester.binding.handlePopRoute()`); (2) verify Cancel button tap routes to `cancelWorkout` via `context.push`; (3) when Bloc emits `navigateToCancel: true`, verify navigation goes to `cancelWorkout` route (FR-009 discard path); (4) verify that after Cancel tap, no Drift `saveSession` is called (verify on mock use case); test scenarios must not require T021/T022 to be merged in order to pass — mock the Bloc state directly

- [X] T024 [US4] Verify `PopScope` in `forge/lib/features/workout_session/presentation/screens/active_workout_screen.dart` — manually confirm (by reading the implementation from T017) that: `canPop: false` is set, `onPopInvokedWithResult` routes to `RoutePaths.cancelWorkout` via `context.push`, and `context.mounted` is checked before navigation; if any of these are missing, fix in the screen file; this task is complete when T023 tests pass

**Checkpoint**: All cancel/discard paths verified. No partial Drift record on any cancel flow.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Analysis, formatting, and final test run across all touched files.

- [X] T025 [P] Run `cd forge && dart format lib/features/workout_session/ lib/core/strings/app_strings.dart lib/config/routes/app_routes.dart lib/app/get_it_setup.dart test/features/workout_session/` — fix any formatting issues; re-run analyze afterward

- [X] T026 [P] Run `cd forge && flutter analyze` — resolve every warning or error introduced by this feature; pay particular attention to: unused imports in modified files, missing `const` constructors, `dynamic` casts in the route builder for `state.extra as WorkoutPlanDetail` (add a type-check guard if needed)

- [X] T027 Run `cd forge && flutter test` — verify all pre-existing tests still pass (no regressions in `workout_plan`, `schedule`, or other features); fix any breakage caused by the `ActualSet.skipped` or `WorkoutSession.startedAt` field additions (update existing mocks and test data to supply the new fields with safe defaults)

**Checkpoint**: All tests pass, analyzer clean. Feature ready for `/speckit-analyze`.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 completion (T005 must succeed first) — **BLOCKS all user story phases**
- **Phase 3 (US1)**: Depends on Phase 2 completion
- **Phase 4 (US2)**: Depends on Phase 3 completion (T016 must be implemented before T020 can verify it)
- **Phase 5 (US3)**: Depends on Phase 3 completion (T017 must exist before T022 can modify it)
- **Phase 6 (US4)**: Depends on Phase 5 completion (T022 must exist so T023 widget tests include the Paused overlay cancel path)
- **Phase 7 (Polish)**: Depends on all user story phases

### User Story Dependencies

- **US1 (P1)**: Starts immediately after Foundational
- **US2 (P1)**: Starts after US1 (T016 must be implemented for T020 to verify it)
- **US3 (P2)**: Starts after US1 (T017 must exist for T022 to modify it); independent of US2
- **US4 (P2)**: Starts after US3 (T022 must exist for T023 full coverage)

### Within Each Phase

- Parallelizable tasks [P] touch different files and have no intra-phase dependency
- Sequential tasks in the same phase share a file or depend on a prior task's output

### Parallel Opportunities Per Phase

**Phase 1**: T001 ‖ T002 → T003 → T004 → T005 → T006

**Phase 2**: T007 ‖ T008 ‖ T010 ‖ T011 ‖ T012 → T009 → T013 → T014

**Phase 3**: T015 ‖ T016 ‖ T018 → T017 → T019

**Phase 4**: T019 (already done) → T020

**Phase 5**: T021 → T022

**Phase 6**: T023 ‖ T024

**Phase 7**: T025 ‖ T026 → T027

---

## Parallel Example: Phase 2

```
Parallel launch (different files, no shared dependency):
  Task T007: Add AppStrings in app_strings.dart
  Task T008: Add route constants in app_routes.dart
  Task T010: Create SaveWorkoutSessionUseCase
  Task T011: Create active_workout_event.dart
  Task T012: Create active_workout_state.dart

Sequential (same file as T008 or depends on T011+T012+T010):
  Task T009: Add GoRoutes (same file as T008 — must follow T008)
  Task T013: Create active_workout_bloc.dart (depends on T010+T011+T012)
  Task T014: Register in get_it_setup.dart (depends on T013)
```

---

## Implementation Strategy

### MVP First (US1 + US2 — complete logging flow with validation)

1. Complete Phase 1: Setup (entity + Drift changes)
2. Complete Phase 2: Foundational (Bloc, use case, routes, DI)
3. Complete Phase 3: US1 (widgets + screen + Bloc tests)
4. Complete Phase 4: US2 (validation widget tests)
5. **STOP and VALIDATE**: All 13 Bloc tests pass; manual happy-path run produces Drift record
6. US1+US2 together = a viable MVP (workout can be completed with data integrity)

### Incremental Delivery

1. Phase 1 + Phase 2 → Bloc and routes wired (no visible UI yet)
2. Phase 3 → Full logging flow testable end-to-end (MVP!)
3. Phase 4 → Validation confirmed by tests
4. Phase 5 → Pause/Resume added (user convenience)
5. Phase 6 → Cancel/discard paths verified
6. Phase 7 → Polish and cleanup

### Notes

- All `[P]` tasks touch different files — safe to run concurrently or in parallel agents
- After T005 (build_runner), verify `flutter analyze` before continuing — a broken generated file blocks Phase 2
- `context.mounted` check is required after every `async` gap that uses `context` (rule 63 in CLAUDE.md)
- The `state.extra as WorkoutPlanDetail` cast in the route builder should be guarded: if extra is not a `WorkoutPlanDetail`, redirect to the plans list rather than crash
- All `const` constructors must be used where possible per CLAUDE.md rule 25
- No `setState()` for business state — all execution state owned by `ActiveWorkoutBloc`
