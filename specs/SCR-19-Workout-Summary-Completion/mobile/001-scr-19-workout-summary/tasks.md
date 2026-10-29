# Tasks: SCR-19 Workout Summary & Completion

**Input**: Design documents from `specs/SCR-19-Workout-Summary-Completion/mobile/001-scr-19-workout-summary/`

**Prerequisites**: SCR-16 (Active Workout) must be fully implemented before any SCR-19 task can be executed. SCR-19 depends on `WorkoutSession.startedAt`, `ActualSet.skipped`, and the amended `ActiveWorkoutBloc` from SCR-16.

**Tests**: Bloc unit tests and widget tests are explicitly required per spec (US1 and US2 Independent Test criteria and quickstart.md).

**Organization**: Tasks are grouped by user story. US1 (save + summary) → US2 (error + retry) → US3 (back-blocked). The foundational phase wires all shared infrastructure before any story work begins.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to
- All paths relative to `forge/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the tokens, strings, and DI wiring that every user story depends on. No user story feature files are created here.

- [X] T001 Add `AppColors.successBg = const Color(0xFF1E2A12)` to `lib/core/theme/app_colors.dart`
- [X] T002 Add SCR-19 string constants to `lib/core/strings/app_strings.dart` (`workoutSummaryLoadingButton`, `workoutSummaryDoneButton`, `workoutSummaryViewHistoryButton`, `workoutSummarySetsLabel`, `workoutSummaryExercisesLabel`, `workoutSummaryDurationSuffix`, `workoutSummarySkippedPill`, `workoutSummaryErrorTitle`, `workoutSummaryErrorMessage`, `workoutSummaryRetryButton`)
- [X] T003 Register `WorkoutSummaryBloc` as `registerFactory` in `lib/config/di/get_it_setup.dart`

**Checkpoint**: Color token, string constants, and DI entry exist. No Bloc or screen files yet.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the Bloc files and amend `ActiveWorkoutBloc` so that both US1 and US2 have their full state machine available. The route amendment also belongs here because it gates navigation from SCR-16.

**⚠️ CRITICAL**: No user story screen work can begin until this phase is complete.

### WorkoutSummaryBloc (new — US1 and US2 both depend on this)

- [X] T004 Create `lib/features/workout_session/application/bloc/workout_summary_event.dart` with sealed class `WorkoutSummaryEvent`, `WorkoutSummaryStarted({required WorkoutSession session})`, and `WorkoutSummaryRetryRequested()`
- [X] T005 Create `lib/features/workout_session/application/bloc/workout_summary_state.dart` with sealed class `WorkoutSummaryState` and subtypes `WorkoutSummaryInitial`, `WorkoutSummaryLoading({required String planName})`, `WorkoutSummarySuccess({required WorkoutSession session})`, `WorkoutSummaryError({required String planName, required String sessionId})`
- [X] T006 Create `lib/features/workout_session/application/bloc/workout_summary_bloc.dart` implementing `WorkoutSummaryBloc extends Bloc<WorkoutSummaryEvent, WorkoutSummaryState>` with `_onStarted`, `_onRetryRequested`, and `_attemptSave` (dedup check via `getSessionById` then `saveSession` on miss) per `contracts/workout-summary-bloc.md`

### ActiveWorkoutBloc amendments (supersedes SCR-16 Finish path per `contracts/active-workout-bloc-amendments.md`)

- [X] T007 Amend `lib/features/workout_session/application/bloc/active_workout_state.dart`: remove `writeError: String?`; add `completedSession: WorkoutSession?`; update `copyWith` and `props`
- [X] T008 Amend `lib/features/workout_session/application/bloc/active_workout_event.dart`: remove `ActiveWorkoutRetryFinishRequested`; add `ActiveWorkoutPostWorkoutNavigated`
- [X] T009 Amend `lib/features/workout_session/application/bloc/active_workout_bloc.dart`: remove `SaveWorkoutSessionUseCase` constructor param and private field; rename `_triggerFinish` → `_prepareFinish` (synchronous, builds session, emits `navigateToPostWorkout: true, completedSession: session`); add `_onPostWorkoutNavigated` handler; remove `_onRetryFinishRequested` handler

### Route amendment

- [X] T010 Replace the SCR-19 stub in `lib/config/routes/app_routes.dart` with a real `GoRoute(path: RoutePaths.postWorkout)` builder that casts `state.extra as WorkoutSession`, provides `WorkoutSummaryBloc` via `BlocProvider`, and dispatches `WorkoutSummaryStarted`

**Checkpoint**: `WorkoutSummaryBloc` compiles, `ActiveWorkoutBloc` amendments compile, route wired. `flutter analyze` passes on amended files.

---

## Phase 3: User Story 1 — Save and View Workout Summary (Priority: P1) 🎯 MVP

**Goal**: User sees loading while save is in progress, then a full summary of their completed session. They can exit to Home or go to Workout History.

**Independent Test**: Complete SCR-16 active workout with ≥2 exercises, ≥1 set logged, ≥1 set skipped. Tap Finish. Verify loading indicator appears → save completes → summary shows correct plan name, date/time (start time), duration min, set count (non-skipped), exercise count, and exercise breakdown with set pills in correct format.

### Implementation for User Story 1

- [X] T011 [P] [US1] Create `lib/features/workout_session/presentation/widgets/set_pill.dart` — `SetPill extends StatelessWidget` with `set: ActualSet` and `exerciseType: ExerciseType`; renders weighted `{reps}×{weight}kg`, bodyweight `{reps} reps`, time-based `MM:SS`, skipped "Skipped" with muted strikethrough (`AppColors.textDim`, `TextDecoration.lineThrough`)
- [X] T012 [P] [US1] Create `lib/features/workout_session/presentation/widgets/exercise_breakdown_card.dart` — `ExerciseBreakdownCard extends StatelessWidget` with `exercise: SessionExercise`; shows exercise name, coloured type indicator chip (lime/cyan/muted per `ExerciseType`), and a `Wrap` of `SetPill` widgets
- [X] T013 [US1] Create `lib/features/workout_session/presentation/screens/workout_summary_screen.dart` — `WorkoutSummaryScreen extends StatefulWidget`; `_isRetrying: bool` local state; `PopScope(canPop: false)` wrapper; `BlocBuilder` with three branches: `WorkoutSummaryLoading` → loading body, `WorkoutSummarySuccess` → summary body (plan name, formatted `session.startedAt` as `EEE, MMM d · h:mm a`, `session.sessionDurationSec ~/ 60` min, sets count, exercises count, `ListView` of `ExerciseBreakdownCard`), `WorkoutSummaryError` → error body (plan name, `AppStrings.workoutSummaryErrorTitle`, `AppStrings.workoutSummaryErrorMessage`, Retry button); `BlocListener` resets `_isRetrying = false` when `WorkoutSummaryLoading` is emitted; `_handleDone` calls `context.go(RoutePaths.home)`; `_handleViewHistory` calls `context.push(RoutePaths.workoutHistory)`; uses `theme.textTheme.*` and `AppColors.*` only; no hardcoded strings or colors

### Amendment to SCR-16 screen (enables navigation entry point for US1)

- [X] T014 [US1] Amend `lib/features/workout_session/presentation/screens/active_workout_screen.dart` BlocListener: replace `navigateToPostWorkout` stub branch with `context.go(RoutePaths.postWorkout, extra: state.completedSession)` + dispatch `ActiveWorkoutPostWorkoutNavigated`; add `context.mounted` guard after the async gap

### Bloc unit tests for US1

- [X] T015 [P] [US1] Create `test/features/workout_session/application/bloc/workout_summary_bloc_test.dart` — test `WorkoutSummaryStarted` with dedup miss + save OK → emits `[Loading, Success]`; test `WorkoutSummaryStarted` with `getSessionById` returning existing session → emits `[Loading, Success]` (no second write); mock `WorkoutSessionRepository` with `mocktail`

### Widget tests for US1

- [X] T016 [P] [US1] Create `test/features/workout_session/presentation/screens/workout_summary_screen_test.dart` — test Loading state shows plan name, "Saving Workout…", loading indicator, `PopScope` blocks back; test Success state shows plan name, formatted start date, duration suffix "min", sets count (non-skipped), exercises count, exercise cards with set pills; test Done tap calls `context.go(RoutePaths.home)`; test View History tap calls `context.push(RoutePaths.workoutHistory)`

**Checkpoint**: Run `flutter test test/features/workout_session/application/bloc/workout_summary_bloc_test.dart` and `test/features/workout_session/presentation/screens/workout_summary_screen_test.dart`. All US1 tests pass. Manual golden path from SCR-16 works end-to-end.

---

## Phase 4: User Story 2 — Handle Save Failure and Retry (Priority: P2)

**Goal**: User sees a named error state with reassurance and a Retry button. Retry re-attempts the save. On retry success the summary appears. A prior successful write (detected by dedup guard) also takes the user to the summary without a duplicate write.

**Independent Test**: Mock `WorkoutSessionRepository.saveSession` to return `Left(CacheException(...))` on the first call. Tap Finish on SCR-16. Verify error state with plan name, failure title, reassurance message, and Retry button. Tap Retry — verify loading state reappears, save succeeds on second call, summary shown, one record in history. Also verify seeded-table dedup path: seed session in the `workout_sessions` table before retry → verify no second write and success state emitted.

### Implementation for User Story 2

The `WorkoutSummaryScreen` error branch and `_handleRetry` are already in T013. This phase adds the Retry guard and amends the screen if needed.

- [X] T017 [US2] Verify `_handleRetry` in `WorkoutSummaryScreen` (T013): confirm `if (_isRetrying) return;` guard is in place; confirm `setState(() => _isRetrying = true)` precedes the `add(WorkoutSummaryRetryRequested())` call; confirm `BlocListener` resets `_isRetrying = false` on `WorkoutSummaryLoading` entry; no further code changes needed if T013 implemented correctly

### Bloc unit tests for US2

- [X] T018 [P] [US2] Add to `workout_summary_bloc_test.dart`: test `WorkoutSummaryStarted` with dedup miss + save fail → emits `[Loading, Error]`; test `WorkoutSummaryRetryRequested` from Error → dedup miss + save OK → emits `[Loading, Success]`; test `WorkoutSummaryRetryRequested` from Error → dedup miss + save fail → emits `[Loading, Error]`; test `WorkoutSummaryRetryRequested` from Error → dedup finds existing → emits `[Loading, Success]` (no write); test `_session` retained across retry (same session ID)

### Widget tests for US2

- [X] T019 [P] [US2] Add to `workout_summary_screen_test.dart`: test Error state shows plan name, error title, error message, Retry button; test `PopScope` blocks back on Error state; test Retry tap dispatches `WorkoutSummaryRetryRequested` and sets button non-interactive; test double-tap Retry only dispatches one event

**Checkpoint**: All US2 bloc and widget tests pass. Manual flow: trigger mocked save failure → verify error UI → Retry → summary shown → confirm one record in the `workout_sessions` table.

---

## Phase 5: User Story 3 — Back Navigation Is Blocked (Priority: P3)

**Goal**: Back gesture and hardware back have no effect from the summary or error state. SCR-16 is absent from the navigation stack.

**Independent Test**: From summary screen, swipe back (iOS) or press hardware back (Android). Verify summary remains the current route. Navigate to SCR-20 via View History. Navigate back from SCR-20. Verify summary (not SCR-16) is shown. Attempt back from summary again — verify blocked.

### Implementation for User Story 3

`PopScope(canPop: false)` is already included in `WorkoutSummaryScreen` (T013). `context.go` (not `push`) in T014 ensures SCR-16 is removed from the stack. This phase verifies and adds any missing coverage.

- [X] T020 [US3] Verify `WorkoutSummaryScreen` uses `PopScope(canPop: false)` wrapping the entire scaffold body; confirm `onPopInvokedWithResult` callback is a no-op; no additional code changes if T013 implemented correctly
- [X] T021 [US3] Verify `active_workout_screen.dart` BlocListener (T014) uses `context.go` (not `context.push`) so SCR-16 is removed from the stack; confirm this is present from T014

### Widget tests for US3

- [X] T022 [US3] Add to `workout_summary_screen_test.dart`: test that `PopScope.canPop` is `false` in Success state; test that `PopScope.canPop` is `false` in Error state; simulate pop invoked and verify no navigation fires

**Checkpoint**: All US3 tests pass. All quickstart.md Scenarios 3, 4, 8, and 9 pass manually.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Analyzer, formatting, integration, and cross-story validation.

- [X] T023 Run `dart format lib/features/workout_session/ lib/core/theme/app_colors.dart lib/core/strings/app_strings.dart lib/config/routes/app_routes.dart lib/config/di/get_it_setup.dart` and resolve any formatting issues
- [X] T024 Run `flutter analyze lib/features/workout_session/ lib/config/routes/app_routes.dart lib/core/` and resolve every warning or error introduced by SCR-19 changes
- [X] T025 Run `flutter test test/features/workout_session/` (full suite) and confirm no regressions in SCR-16/17/18 tests from the `ActiveWorkoutBloc` amendments
- [ ] T026 [P] Run quickstart.md Scenario 1 (happy path) manually end-to-end from SCR-16 Finish tap through summary
- [ ] T027 [P] Run quickstart.md Scenario 6 (retry succeeds) manually end-to-end
- [ ] T028 [P] Run quickstart.md Scenario 7 (dedup guard) manually end-to-end
- [ ] T029 [P] Verify `AppColors.successBg` renders correctly in dark theme on iOS Simulator and Android Emulator (hero icon fill)
- [X] T030 Verify `SetPill` skipped style (muted color, strikethrough) matches design spec tokens — no hardcoded colors; uses `AppColors.textDim` and `TextDecoration.lineThrough`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No prerequisites — start immediately after SCR-16 is implemented.
- **Phase 2 (Foundational)**: Depends on Phase 1 (T001–T003 must be done for DI to compile). Blocks all user story screen work.
- **Phase 3 (US1)**: Depends on Phase 2 complete (Bloc files and route must exist). T011 and T012 can start in parallel once Phase 2 is done. T013 depends on T011 and T012 completing first. T014 depends on T013 (needs PostWorkoutNavigated event from T008). T015/T016 can start as soon as T006 (Bloc) is done.
- **Phase 4 (US2)**: T017 depends on T013. T018 depends on T006. T019 depends on T013. Can start as soon as Phase 3's screen (T013) is done.
- **Phase 5 (US3)**: T020–T022 depend on T013 and T014 being complete (screen and navigation entry point). No new files created here.
- **Phase 6 (Polish)**: Depends on all prior phases complete.

### User Story Dependencies

- **US1 (P1)**: Depends on Foundational phase only. No dependency on US2 or US3.
- **US2 (P2)**: Depends on US1 screen being complete (T013) — shares the same screen file (error branch).
- **US3 (P3)**: Depends on US1 screen (T013) and route navigation amendment (T014). No new code — verification tasks only.

### Within Each Phase

- T004 → T005 → T006 (events before states before Bloc — Bloc file imports both)
- T007, T008, T009 can run in any order (different files within `active_workout_bloc/`)
- T011 and T012 are parallel (different files)
- T013 depends on T011 and T012 (imports `SetPill` and `ExerciseBreakdownCard`)
- T014 depends on T008 (needs `ActiveWorkoutPostWorkoutNavigated` event to exist)
- T015 and T016 can run in parallel (different test files, both depend on T006)
- T018 and T019 can run in parallel (different test files, both depend on T013 being merged into the screen)

### Parallel Opportunities

| Phase | Parallel group |
|---|---|
| Phase 2 | T007, T008, T009 (different files in `active_workout_bloc/`) |
| Phase 3 | T011, T012 (new widget files); T015, T016 (new test files) |
| Phase 4 | T018, T019 (test additions) |
| Phase 6 | T026, T027, T028, T029 (independent manual validation runs) |

---

## Parallel Example: User Story 1

```
# Phase 2 — run together (different files):
T007 amend active_workout_state.dart
T008 amend active_workout_event.dart
T009 amend active_workout_bloc.dart

# Phase 3 — once Phase 2 done, run widget files in parallel:
T011 create set_pill.dart
T012 create exercise_breakdown_card.dart

# Phase 3 — once T011 + T012 done:
T013 create workout_summary_screen.dart

# Phase 3 — can run in parallel with T013 implementation (different files):
T015 create workout_summary_bloc_test.dart
T016 create workout_summary_screen_test.dart
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational (T004–T010)
3. Complete Phase 3: User Story 1 (T011–T016)
4. **STOP and VALIDATE**: Run `flutter test` for US1 files. Run quickstart.md Scenario 1 manually.
5. If passing: proceed to US2.

### Incremental Delivery

1. Phase 1 + Phase 2 → Bloc and route wired, analyzer clean
2. Phase 3 (US1) → Happy path works end-to-end; summary visible
3. Phase 4 (US2) → Error path and retry work; dedup guard verified
4. Phase 5 (US3) → Back-blocked verified (likely zero new code)
5. Phase 6 (Polish) → Analyzer, format, regression suite, manual scenarios

---

## Notes

- **No new packages**: All dependencies (`flutter_bloc`, `equatable`, `fpdart`, `go_router`, `get_it`, `Drift`, `mocktail`, `bloc_test`) are already in `pubspec.yaml`. Do not add any package.
- **No new tables**: `WorkoutSummaryBloc` calls `saveSession` and `getSessionById` on the existing `WorkoutSessionRepository`; no schema change or `build_runner` run is needed.
- **No new feature directory**: All new files live inside `forge/lib/features/workout_session/` and `forge/test/features/workout_session/`.
- **SCR-16 dependency**: T007–T009 amend files that are scheduled to be created by SCR-16. If SCR-16 is not yet implemented, defer Phase 2 until SCR-16 implementation is complete.
- **`context.mounted` guard**: T014 amends `active_workout_screen.dart` BlocListener — the `context.go` call is inside a listener callback (sync), so no `mounted` check is needed here. However, any `async` gap introduced must be followed by a `context.mounted` check per CLAUDE.md rule 63.
- **`PopScope` note**: `PopScope` replaced `WillPopScope` in Flutter 3.12+. Use `PopScope(canPop: false)` only.
- **`[P]` tasks** = different files, no dependencies on incomplete sibling tasks in the same phase.
- **`[Story]` label** maps each task to its user story for traceability to spec.md acceptance criteria.
