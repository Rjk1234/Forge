# Tasks: SCR-18 Cancel Active Workout Confirmation

**Input**: Design documents from `specs/SCR-18-Cancel-Active-Workout-Confirmation/mobile/001-scr-18-cancel-workout/`

**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ ✅ | quickstart.md ✅

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies between marked tasks)
- **[Story]**: Which user story this task belongs to (US1 = P1 Cancel Modal, US2 = P2 OS Back Guard)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: String constants that the new screen depends on. No blocking dependencies — can start immediately.

- [X] T001 [P] Add 4 SCR-18 string constants in a `// SCR-18: Cancel Active Workout Confirmation` section in `forge/lib/core/strings/app_strings.dart`: `cancelWorkoutTitle = 'Cancel this workout?'`, `cancelWorkoutSubtitle` (two-sentence no-save warning), `cancelWorkoutKeepGoingButton = 'Keep Going'`, `cancelWorkoutDiscardButton = 'Discard Workout'` (see data-model.md §AppStrings)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Bloc events and handlers that BOTH user stories depend on. The `ActiveWorkoutCancelRequested` event is the single entry point for all cancel paths (Cancel button + OS back gesture). Must be complete before any US phase begins.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 [P] Add two event classes (`ActiveWorkoutCancelRequested` and `ActiveWorkoutCancelNavigated`, both `const` with no fields) to `forge/lib/features/workout_session/application/bloc/active_workout_event.dart` (see contracts/active-workout-bloc-amendments.md §New Events)
- [X] T003 Add `on<ActiveWorkoutCancelRequested>(_onCancelRequested)` and `on<ActiveWorkoutCancelNavigated>(_onCancelNavigated)` registrations in the constructor, and implement `_onCancelRequested` (guard: `if (state is! ActiveWorkoutRunning) return;` → emit `copyWith(navigateToCancel: true)`) and `_onCancelNavigated` (guard same → emit `copyWith(navigateToCancel: false)`) in `forge/lib/features/workout_session/application/bloc/active_workout_bloc.dart` (depends on T002; see contracts/active-workout-bloc-amendments.md §New Handlers)
- [X] T004 [P] Add 4 Bloc unit test scenarios to `forge/test/features/workout_session/application/bloc/active_workout_bloc_test.dart`: (a) `CancelRequested` when running → `navigateToCancel: true`; (b) `CancelRequested` then `CancelNavigated` → `navigateToCancel: false`; (c) `CancelRequested` when NOT `ActiveWorkoutRunning` → state unchanged; (d) repeated cancel/keep-going cycle → flag alternates correctly (depends on T003; see quickstart.md §Bloc Unit Test Checklist)

**Checkpoint**: Bloc cancel path is implemented and tested. US story phases can now begin.

---

## Phase 3: User Story 1 — Cancel Confirmation Modal (Priority: P1) 🎯 MVP

**Goal**: When the user taps Cancel in the SCR-16 app bar, the SCR-18 transparent overlay appears with "Keep Going" and "Discard Workout" options. Keep Going restores SCR-16 unchanged. Discard Workout navigates to SCR-06 with the stack cleared.

**Independent Test**: Quickstart scenarios 1–3 (Cancel button → modal appears; Keep Going → state preserved; Discard → home, no back path). Widget test checklist items 1–7.

### Implementation for User Story 1

- [X] T005 [US1] Create `CancelWorkoutScreen` as a `StatefulWidget` with required `final String planName` constructor parameter and `bool _isDiscarding = false` local state. Widget body: transparent `Scaffold`, full-screen `GestureDetector` for scrim taps calling `_handleKeepGoing()`, bottom-anchored modal card (`AppColors.card`), warning icon (`AppColors.dangerBg`), `Text(AppStrings.cancelWorkoutTitle, style: theme.textTheme...)`, `Text(widget.planName, style: theme.textTheme...)` (FR-003 — plan name MUST be shown), `Text(AppStrings.cancelWorkoutSubtitle)`, danger-style `Discard Workout` button (`AppColors.danger`/`AppColors.onDanger`, disabled when `_isDiscarding`, calls `_handleDiscard()`), secondary `Keep Going` button (`AppColors.cardAlt`/`AppColors.border`, calls `_handleKeepGoing()`), `PopScope(canPop: false, onPopInvokedWithResult: (_, __) => _handleKeepGoing())`; `_handleKeepGoing` = `context.pop()`; `_handleDiscard` = `setState(() => _isDiscarding = true)` then `context.go(RoutePaths.home)` — NOTE: `_handleDiscard` requires NO try/catch or Drift error handling because no Drift operation occurs on discard (research D-04; FR-012 is vacuously satisfied) in `forge/lib/features/workout_session/presentation/screens/cancel_workout_screen.dart` (depends on T001; see contracts/cancel-workout-screen.md)
- [X] T006 [US1] Replace the stub `GoRoute` at `RoutePaths.cancelWorkout` in `forge/lib/config/routes/app_routes.dart` with a `pageBuilder` that extracts `final planName = state.extra as String? ?? ''` and returns `CustomTransitionPage(key: state.pageKey, opaque: false, barrierColor: AppColors.scrimBarrier, child: CancelWorkoutScreen(planName: planName), transitionsBuilder: FadeTransition)` (depends on T005; see data-model.md §Route Amendment)
- [X] T007 [US1] Add `navigateToCancel` branch to the `BlocListener` in `ActiveWorkoutScreen`: `if (state.navigateToCancel) { context.push(RoutePaths.cancelWorkout, extra: state.planName); context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelNavigated()); }` positioned alongside the existing `navigateToRestTimer` and `navigateToPostWorkout` branches in `forge/lib/features/workout_session/presentation/screens/active_workout_screen.dart` — the `extra: state.planName` forwards the plan name to `CancelWorkoutScreen` (FR-003) (depends on T003, T006; see contracts/active-workout-bloc-amendments.md §Screen Amendments point 1 and data-model.md §BlocListener)
- [X] T008 [US1] Change the Cancel button `onPressed` in `ActiveWorkoutScreen` from the SCR-16 stub `() => context.push(RoutePaths.cancelWorkout)` to `() => context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelRequested())` in `forge/lib/features/workout_session/presentation/screens/active_workout_screen.dart` (depends on T007 — same file, edit sequentially; see contracts/active-workout-bloc-amendments.md §Screen Amendments point 2)
- [X] T009 [P] [US1] Write 8 widget test scenarios for `CancelWorkoutScreen` in `forge/test/features/workout_session/presentation/screens/cancel_workout_screen_test.dart`: (a) screen renders title, subtitle, both buttons, AND the passed `planName` string (FR-003); (b) Keep Going tap calls `context.pop()`; (c) Discard Workout tap calls `context.go('/')`; (d) after Discard tap, button is disabled; (e) OS back while screen open calls `_handleKeepGoing` (no discard); (f) scrim tap calls `_handleKeepGoing`; (g) double-tap on Discard triggers navigation only once; (h) empty `planName` renders without error (depends on T005; see quickstart.md §Widget Test Checklist)

**Checkpoint**: US1 fully functional. Run Quickstart scenarios 1–3 and 7–9. **SC-001 is partially satisfied at this point** — 100% of Cancel button taps pass through SCR-18; OS back interception (FR-002, T010) ships with US2 and completes SC-001 in full.

---

## Phase 4: User Story 2 — OS Back Gesture Guard (Priority: P2)

**Goal**: The OS back gesture on SCR-16 (iOS swipe-back, Android hardware back) triggers the same SCR-18 confirmation modal instead of silently popping the workout screen.

**Independent Test**: Quickstart scenarios 4–6 (OS back on SCR-16 → modal; scrim tap = Keep Going; OS back while SCR-18 open = Keep Going).

**Prerequisite**: US1 complete (T001–T009). The `PopScope` in `ActiveWorkoutScreen` already has `canPop: false` (SCR-16 design); only the `onPopInvokedWithResult` callback changes.

### Implementation for User Story 2

- [X] T010 [US2] Change `PopScope.onPopInvokedWithResult` in `ActiveWorkoutScreen` from the SCR-16 stub `(_, __) => context.push(RoutePaths.cancelWorkout)` to `(_, __) => context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelRequested())` in `forge/lib/features/workout_session/presentation/screens/active_workout_screen.dart` (depends on T008 — same file, edit sequentially; see contracts/active-workout-bloc-amendments.md §Screen Amendments point 3)
- [X] T011 [US2] Write 2 test scenarios in `forge/test/features/workout_session/presentation/screens/active_workout_screen_test.dart`: (a) OS back gesture on SCR-16 dispatches `ActiveWorkoutCancelRequested` (not a direct `context.push`); (b) OS back gesture while SCR-18 is open (PopScope in `CancelWorkoutScreen`) calls `_handleKeepGoing` and does not discard (depends on T010; see quickstart.md scenarios 4 and 6)

**Checkpoint**: US2 functional. All 9 quickstart scenarios pass.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Dead code removal, formatting, and analysis gate. No functionality changes.

- [X] T012 [P] Remove the `cancelWorkoutStubLabel` constant from `forge/lib/core/strings/app_strings.dart` and delete the stub screen file at `forge/lib/features/workout_session/presentation/screens/cancel_workout_stub_screen.dart` (or equivalent stub filename) if it exists — the real `CancelWorkoutScreen` now replaces it (depends on T006; dead code per CLAUDE.md rule 7)
- [X] T013 Run `dart format forge/lib/features/workout_session/ forge/lib/config/routes/app_routes.dart forge/lib/core/strings/app_strings.dart` and commit any formatting-only changes (depends on T012)
- [X] T014 Run `flutter analyze forge/lib/features/workout_session/ forge/lib/config/routes/app_routes.dart forge/lib/core/strings/app_strings.dart` and resolve every warning or error introduced by SCR-18 changes (depends on T013)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: No dependencies on Phase 1 — T002 and T004 can run in parallel with T001
- **US1 (Phase 3)**: T005 depends on T001 (AppStrings); T006 depends on T005; T007+T008 depend on T003+T006; T009 depends on T005
- **US2 (Phase 4)**: Depends on T008 (same file chain)
- **Polish (Phase 5)**: Depends on all prior phases complete

### User Story Dependencies

- **US1 (P1)**: Depends on Phase 2 (Bloc events + handlers) and T001 (AppStrings). No dependency on US2.
- **US2 (P2)**: Depends on US1 complete (T008 — same file, sequential amendment)

### Same-File Edit Chain (`active_workout_screen.dart`)

T007 → T008 → T010 must be done sequentially (all amend the same file). No `[P]` markers on these tasks.

### Parallel Opportunities

Within Phase 2: T002 and T004 are `[P]` — but note T004 depends on T003, which depends on T002. T002 can run in parallel with T001 (Phase 1).

Within Phase 3: T009 `[P]` can run alongside T006/T007/T008 since it only touches the test file for `CancelWorkoutScreen`.

---

## Parallel Execution Example

```
# Phase 1 + Phase 2 start together:
[P] T001: Add AppStrings constants
[P] T002: Add Bloc event classes

# After T002 completes:
T003: Add Bloc handlers (depends on T002)
[P] T004: Add Bloc unit tests (depends on T003)

# After T001 + T003 complete:
T005: Create CancelWorkoutScreen (depends on T001)
T006: Update app_routes.dart (depends on T005)

# After T003 + T006 complete:
T007: Amend BlocListener (depends on T003, T006)
[P] T009: Write CancelWorkoutScreen widget tests (depends on T005)

# After T007 completes:
T008: Amend Cancel button (same file — sequential)

# After T008 completes:
T010: Amend PopScope (same file — sequential)

# After T010 completes:
T011: Write OS back tests
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (T001) + Phase 2 (T002–T004)
2. Complete Phase 3 US1 (T005–T009)
3. **STOP and VALIDATE**: Run quickstart scenarios 1–3, 7–9; run widget tests; run Bloc tests
4. Confirm no SCR-16 regressions (existing `active_workout_bloc_test.dart` passes)

### Full Delivery (Both User Stories)

1. MVP above (US1)
2. Complete Phase 4 US2 (T010–T011) — one `PopScope` line change + 2 test scenarios
3. Complete Phase 5 Polish (T012–T014)
4. Run all tests: `flutter test forge/test/features/workout_session/`
5. Run `flutter analyze` — zero warnings introduced

### Task Count by Story

| Phase | Tasks | Count |
|-------|-------|-------|
| Setup | T001 | 1 |
| Foundational | T002–T004 | 3 |
| US1 (P1 MVP) | T005–T009 | 5 |
| US2 (P2) | T010–T011 | 2 |
| Polish | T012–T014 | 3 |
| **Total** | **T001–T014** | **14** |

---

## Notes

- `[P]` tasks operate on different files and have no unresolved inter-dependencies at the time they are marked parallel
- `active_workout_screen.dart` receives 3 sequential amendments (T007, T008, T010) — read the current file state before each edit
- `cancelWorkoutStubLabel` removal (T012) is a cleanup task; verify no other file references it before deleting
- After T006, the stub screen file (if any) is no longer referenced by the router — it is safe to delete in T012
- All string references in `CancelWorkoutScreen` must use `AppStrings.*` — never inline strings (CLAUDE.md rule 36)
- All color references must use `AppColors.*` — never `Colors.*` or hardcoded hex (CLAUDE.md rule 28–29)
- `context.mounted` check is NOT needed before `context.pop()` or `context.go()` in `_handleKeepGoing`/`_handleDiscard` because these are called from synchronous button callbacks with no `async` gap (CLAUDE.md rule 63 applies after `async` gaps only)
