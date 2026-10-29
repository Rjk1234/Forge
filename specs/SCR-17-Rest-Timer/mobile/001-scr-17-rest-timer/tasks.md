# Tasks: SCR-17 Rest Timer

**Input**: Design documents from `specs/SCR-17-Rest-Timer/mobile/001-scr-17-rest-timer/`

**Prerequisites**: SCR-16 (Active Workout) application/ and presentation/ layers must be implemented first. `ActiveWorkoutBloc`, `ActiveWorkoutRunning`, `ActiveWorkoutEvent`, and `ActiveWorkoutScreen` are created by SCR-16 tasks and MUST exist before Phase 2 of this plan can begin. If SCR-17 is being implemented concurrently with SCR-16, coordinate the contract amendments in Phase 2 with the SCR-16 implementor.

**Reference contracts**:
- `contracts/rest-timer-bloc.md` — `RestTimerBloc` full state machine and test scenarios
- `contracts/active-workout-bloc-amendments.md` — additive changes to SCR-16 state/event/Bloc/screen

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add SCR-17 strings and route before writing any Bloc or screen code.

- [X] T001 Add SCR-17 AppStrings section to `forge/lib/core/strings/app_strings.dart`: `restTimerSkipRestButton = 'Skip Rest'`, `restTimerRestingLabel = 'Resting'`, `restTimerSecondsUnit = 's'`; verify no name conflicts with existing SCR-16 constants (`activeWorkoutSkipButton = 'Skip'` is SCR-16's set-skip — `restTimerSkipRestButton` must be distinct)
- [X] T002 [P] Add route constants to `RoutePaths` in `forge/lib/config/routes/app_routes.dart`: `static const String restTimer = '/workout/rest'` and `static const String restTimerName = 'restTimer'`

---

## Phase 2: Foundational (SCR-16 Contract Amendments)

**Purpose**: Amend the existing (SCR-16-created) `ActiveWorkoutRunning`, `ActiveWorkoutEvent`, `ActiveWorkoutBloc`, and `ActiveWorkoutScreen` to support SCR-17 navigation. All four files MUST be modified before Phase 3 work is valid.

**⚠️ CRITICAL**: These are additive changes to SCR-16 files. Do NOT alter existing SCR-16 fields, events, or logic — only ADD the rest-timer-specific extensions.

- [X] T004 [P] Add `navigateToRestTimer: bool` (default `false`) and `restPeriodSec: int` (default `0`) to `ActiveWorkoutRunning` in `forge/lib/features/workout_session/application/bloc/active_workout_state.dart`; add both to the `props` list (now 14 items); add both to `copyWith`; preserve all existing 12 fields unchanged (per `contracts/active-workout-bloc-amendments.md`)
- [X] T005 [P] Add `ActiveWorkoutRestTimerNavigated extends ActiveWorkoutEvent` class to `forge/lib/features/workout_session/application/bloc/active_workout_event.dart`; this event is fired by the screen immediately after pushing SCR-17 to reset the navigation flags
- [X] T006 Update `forge/lib/features/workout_session/application/bloc/active_workout_bloc.dart`: (a) in the `ActiveWorkoutCompleteSetRequested` handler, capture the completed exercise's `restPeriodSec` BEFORE advancing the exercise/set index; after advancing, if `restSec > 0` AND a next set or exercise still exists in `_plan` (i.e., the completed set is NOT the last set of the last exercise), emit `nextRunningState.copyWith(navigateToRestTimer: true, restPeriodSec: restSec)`, otherwise emit `nextRunningState` directly (Finish path or zero-rest); (b) add `on<ActiveWorkoutRestTimerNavigated>` handler that emits `copyWith(navigateToRestTimer: false, restPeriodSec: 0)` — see `contracts/active-workout-bloc-amendments.md` for the exact code pattern; depends on T004, T005
- [X] T007 Update `forge/lib/features/workout_session/presentation/screens/active_workout_screen.dart`: extend the existing `BlocListener` to handle `state.navigateToRestTimer == true` — call `context.push(RoutePaths.restTimer, extra: state.restPeriodSec)` then immediately dispatch `ActiveWorkoutRestTimerNavigated()` to reset the flag; do not remove existing `navigateToPostWorkout` / `navigateToCancel` listener branches; depends on T006
- [X] T008 [P] Register `RestTimerBloc` in `forge/lib/app/get_it_setup.dart`: `getIt.registerFactory<RestTimerBloc>(() => RestTimerBloc())`; use `registerFactory` (not singleton) so each rest period gets a fresh Bloc instance
- [X] T020 Update existing SCR-16 `bloc_test` scenarios in `forge/test/features/workout_session/application/bloc/active_workout_bloc_test.dart` to account for the amended `ActiveWorkoutRunning` state shape (two new fields from T004): any scenario that previously asserted a set-completion emission must now include `navigateToRestTimer` and `restPeriodSec` in the expected state; for exercises with `restPeriodSec > 0` this means asserting the intermediate `navigateToRestTimer: true` emission followed by an `ActiveWorkoutRestTimerNavigated` reset emission; for exercises with `restPeriodSec == 0` or the Finish path, assert `navigateToRestTimer: false` directly; this is a foundational correctness task — all existing SCR-16 scenarios must pass before Phase 3 work is valid

**Checkpoint**: `ActiveWorkoutBloc` now emits `navigateToRestTimer: true` after set completions where `restPeriodSec > 0`. `ActiveWorkoutScreen` pushes `/workout/rest` with the duration as `extra`. SCR-17 files do not yet exist, so the app would crash navigating to the route — proceed to Phase 3.

---

## Phase 3: User Story 1 — View Countdown and Skip Rest (Priority: P1) 🎯 MVP

**Goal**: Auto-starting rest timer screen with MM:SS countdown, Skip Rest button, and natural expiry — the complete US1 feature.

**Independent Test**: Complete a set in SCR-16 on a plan with `restPeriodSec > 0`; verify SCR-17 opens automatically with a running MM:SS countdown; tap Skip Rest; verify SCR-16 returns showing the next set. Allow the timer to expire naturally (use a 5-second rest for speed) and verify auto-advance. No manual start tap should be required at any point.

- [X] T009 [P] [US1] Create `forge/lib/features/workout_session/application/bloc/rest_timer_event.dart`: sealed `RestTimerEvent extends Equatable` hierarchy with three subclasses — `RestTimerStarted({required int restPeriodSec})`, `RestTimerTicked()`, `RestTimerSkipped()` — each with the correct `props`
- [X] T010 [P] [US1] Create `forge/lib/features/workout_session/application/bloc/rest_timer_state.dart`: sealed `RestTimerState extends Equatable` hierarchy — `RestTimerInitial()` and `RestTimerRunning({required int totalSec, required int remainingSec, bool navigateBack = false})` with `props` list and `copyWith` method — per `data-model.md` RestTimerRunning specification
- [X] T011 [US1] Create `forge/lib/features/workout_session/application/bloc/rest_timer_bloc.dart`: `RestTimerBloc extends Bloc<RestTimerEvent, RestTimerState>` with private `Timer? _timer`; implement `_onStarted` (cancel any prior timer, emit `RestTimerRunning(totalSec, remainingSec: totalSec)`, start `Timer.periodic(Duration(seconds: 1), (_) => add(const RestTimerTicked()))`); implement `_onTicked` (decrement `remainingSec`; if reaches 1: cancel timer and emit `copyWith(remainingSec: 0, navigateBack: true)`, else decrement only); implement `_onSkipped` (cancel timer, emit `copyWith(navigateBack: true)` if `state is RestTimerRunning`); override `close()` to call `_timer?.cancel()` before `super.close()` — per `contracts/rest-timer-bloc.md`; depends on T009, T010
- [X] T012 [US1] Create `forge/lib/features/workout_session/presentation/screens/rest_timer_screen.dart`: `StatelessWidget` body structure: (1) `PopScope(canPop: false, onPopInvokedWithResult: (_, __) => context.read<RestTimerBloc>().add(const RestTimerSkipped()))` as outermost wrapper; (2) `BlocListener` with `listenWhen: (prev, curr) => curr is RestTimerRunning && curr.navigateBack` that calls `context.pop()` when `navigateBack` is true; (3) `BlocBuilder<RestTimerBloc, RestTimerState>` rendering: when `RestTimerRunning` — countdown in MM:SS format (`'${(s.remainingSec ~/ 60).toString().padLeft(2, '0')}:${(s.remainingSec % 60).toString().padLeft(2, '0')}'`), resting label (`AppStrings.restTimerRestingLabel`), and a **Skip Rest** button (`AppStrings.restTimerSkipRestButton`) that dispatches `RestTimerSkipped()`; use `Theme.of(context).textTheme` and `AppColors` — no hardcoded colors or strings; depends on T011
- [X] T003 Add `GoRoute(path: RoutePaths.restTimer, name: RoutePaths.restTimerName, builder: ...)` to the router configuration in `forge/lib/config/routes/app_routes.dart`; the builder reads `state.extra as int` for `restPeriodSec`, creates `BlocProvider<RestTimerBloc>` using `getIt<RestTimerBloc>()..add(RestTimerStarted(restPeriodSec: restPeriodSec))`, and returns `const RestTimerScreen()`; must execute AFTER T012 (RestTimerScreen) and T011 (RestTimerBloc) are created — Dart does not support forward declarations and importing non-existent classes causes a compile error; depends on T002, T011, T012
- [X] T013 [US1] Write `forge/test/features/workout_session/application/bloc/rest_timer_bloc_test.dart`: use `bloc_test` to cover all 5 scenarios from `contracts/rest-timer-bloc.md`: (a) natural expiry with 3-second rest (`Started(3)`, 3 `Ticked` events → `Running(3,2)`, `Running(3,1)`, `Running(3,0,true)`); (b) skip immediately (`Started(90)`, `Skipped` → `Running(90,90,false)`, `Running(90,90,true)`); (c) skip mid-countdown (`Started(90)`, 5 `Ticked`, `Skipped` → verify `navigateBack: true` at current `remainingSec: 85`); (d) `close()` cancels timer (no emit after close); (e) `RestTimerTicked` when `state is RestTimerInitial` is a no-op (guard test); depends on T011
- [X] T014 [US1] Write `forge/test/features/workout_session/presentation/screens/rest_timer_screen_test.dart`: widget tests pumping `BlocProvider<RestTimerBloc>` with a mock or fake Bloc; verify: (a) countdown renders in MM:SS format (e.g., `'1:30'` for 90s, `'0:05'` for 5s); (b) `AppStrings.restTimerSkipRestButton` ('Skip Rest') label is visible; (c) tapping Skip Rest dispatches `RestTimerSkipped`; (d) when `navigateBack: true` emitted, `context.pop()` is called (verify via navigator observer); (e) OS back gesture dispatches `RestTimerSkipped` via `PopScope`; depends on T012

**Checkpoint**: `flutter test forge/test/features/workout_session/application/bloc/rest_timer_bloc_test.dart` and `rest_timer_screen_test.dart` both pass. Running the app end-to-end: complete a set with `restPeriodSec > 0` → SCR-17 opens automatically → countdown visible in MM:SS → Skip Rest returns to SCR-16 → timer expiry also returns to SCR-16.

---

## Phase 4: User Story 2 — Zero Rest Period Bypass (Priority: P2)

**Goal**: Ensure exercises with `restPeriodSec = 0` bypass SCR-17 entirely; SCR-16 advances directly to the next set.

**Independent Test**: Configure a plan with `restPeriodSec = 0` on an exercise with 2+ sets. Complete Set 1; verify SCR-17 never appears and SCR-16 advances directly to Set 2. Independent of US1 — SCR-17 simply should not be invoked.

- [X] T015 [US2] Add two `bloc_test` scenarios to `forge/test/features/workout_session/application/bloc/active_workout_bloc_test.dart`: (a) "set completion with `restPeriodSec = 0` emits next-set state with `navigateToRestTimer: false`" (zero-rest bypass — FR-006); (b) "last set of last exercise completion with `restPeriodSec > 0` emits `navigateToPostWorkout: true` and `navigateToRestTimer: false`" (Finish path takes precedence — FR-008); use `bloc_test` + `mocktail`
- [X] T016 [US2] Add zero-bypass widget test to `forge/test/features/workout_session/presentation/screens/active_workout_screen_test.dart` (create if SCR-16 T020 not yet executed): verify that when `ActiveWorkoutRunning` emits with `navigateToRestTimer: false` and `restPeriodSec: 0` (zero-rest scenario), the BlocListener does NOT call `context.push(RoutePaths.restTimer, ...)`; mock the navigator and assert no push occurs

**Checkpoint**: `flutter test forge/test/features/workout_session/application/bloc/active_workout_bloc_test.dart` and `active_workout_screen_test.dart` both pass including the new US2 bypass scenarios.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Format, analyze, and verify the full test suite.

- [X] T017 [P] Run `dart format forge/lib/features/workout_session/application/bloc/rest_timer_event.dart forge/lib/features/workout_session/application/bloc/rest_timer_state.dart forge/lib/features/workout_session/application/bloc/rest_timer_bloc.dart forge/lib/features/workout_session/presentation/screens/rest_timer_screen.dart` — verify zero formatter suggestions
- [X] T018 [P] Run `flutter analyze forge/lib/features/workout_session/ forge/lib/core/strings/app_strings.dart forge/lib/config/routes/app_routes.dart forge/lib/app/get_it_setup.dart` — resolve every warning or info message introduced by SCR-17 changes; no existing warnings should be suppressed
- [X] T019 Run `flutter test forge/test/features/workout_session/` — all tests pass (including SCR-16 tests, SCR-17 bloc tests, and SCR-17 screen tests); zero failures, zero errors

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately; T001 and T002 can run in parallel
- **Foundational (Phase 2)**: Requires Phase 1 complete AND SCR-16 `active_workout_state.dart`, `active_workout_event.dart`, `active_workout_bloc.dart`, `active_workout_screen.dart` to exist; T004, T005, T008 can run in parallel; T006 depends on T004+T005; T007 depends on T006; T020 depends on T006 (updates test expectations for the amended Bloc)
- **US1 (Phase 3)**: Requires Phase 2 complete; T009 and T010 can run in parallel; T011 depends on T009+T010; T012 depends on T011; T003 depends on T011+T012 (GoRoute registration requires both classes to exist — Dart does not support forward declarations); T013 depends on T011; T014 depends on T012
- **US2 (Phase 4)**: Requires Phase 2 complete (the Bloc amendment from T006 must exist for the bypass test to be meaningful); T015 and T016 can run in parallel
- **Polish (Phase 5)**: Requires Phases 3 and 4 complete; T017 and T018 can run in parallel; T019 depends on T017+T018

### User Story Dependencies

- **US1 (P1)**: Core rest timer functionality — must be complete for any SCR-17 behavior to exist
- **US2 (P2)**: Zero-bypass — depends on Phase 2 Bloc amendments (T006) but not on US1 Bloc/screen files

### Parallel Opportunities

Within Phase 3 (US1):
- T009 (event file) and T010 (state file) run in parallel
- T013 (Bloc tests) can begin once T011 is done, concurrently with T012 (screen)
- T014 (screen tests) begins once T012 is done

Within Phase 4 (US2):
- T015 (Bloc tests) and T016 (screen tests) are independent files — run in parallel

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 (Setup) — 3 tasks
2. Complete Phase 2 (SCR-16 Amendments) — 5 tasks; requires SCR-16 to already be implemented
3. Complete Phase 3 (US1) — 6 tasks
4. **STOP and VALIDATE**: Run end-to-end quickstart Scenarios 1, 2, 3
5. All critical rest-timer behavior is now shippable

### Incremental Delivery

1. Phases 1–3 → US1 complete → rest timer works for exercises with `restPeriodSec > 0`
2. Phase 4 → US2 complete → zero-rest-period exercises confirmed to bypass SCR-17 cleanly
3. Phase 5 → code quality gates pass → feature ready for SCR-17 `/speckit-analyze`

---

## Notes

- [P] tasks = different files, no blocking dependencies — safe to run in parallel
- SCR-17 introduces **zero domain layer changes** and **zero Drift changes** — entirely application and presentation layer work
- The backgrounded-timer behavior (SRS-NFR-2A, PD-007) is deliberately excluded from these tasks — it is an open product decision that must not be defaulted silently
- The `active_workout_bloc_test.dart` and `active_workout_screen_test.dart` are planned by SCR-16 tasks (T019, T020 in SCR-16 tasks.md). If those files already exist when Phase 4 executes, UPDATE them; if not, CREATE them here
- After implementing SCR-17, the SCR-16 `data-model.md` should be updated by the user to reflect the two new `ActiveWorkoutRunning` fields added in T004 (the contracts amendment file in SCR-17 is the authoritative record; updating SCR-16 data-model.md is optional housekeeping)
