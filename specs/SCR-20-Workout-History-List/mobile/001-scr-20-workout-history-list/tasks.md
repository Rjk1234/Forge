# Tasks: SCR-20 Workout History List

**Input**: Design documents from `specs/SCR-20-Workout-History-List/mobile/001-scr-20-workout-history-list/`

**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓, quickstart.md ✓

**Tests**: Included — Constitution XI.3 mandates unit tests for use-cases and all Bloc state transitions; XI.4 mandates widget tests for all loading/success/empty/error states.

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

**Analyze remediation applied (2026-09-23)**:
- C1: Added T014 (`get_workout_history_use_case_test.dart`) — use-case unit tests required by Constitution XI.3
- D1: T010 updated — `WorkoutHistoryInitial` collapses to skeleton branch (Constitution VII.1); T015 updated to assert skeleton visible for Initial state
- D2: T011 updated — verify/add `RoutePaths.workoutHistoryDetail` constant before wiring screen
- I1: T006 updated — DOW abbreviations are explicitly **uppercase**; T013 updated — adds DOW uppercase assertion

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story the task belongs to
- All paths are relative to the repo root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add string constants that every phase depends on. No code files, no imports.

- [X] T001 Add 6 SCR-20 AppStrings constants (`historyScreenTitle`, `historyEmptyTitle`, `historyEmptySubtitle`, `historyErrorTitle`, `historyErrorBody`, `historyRetryLabel`) to `forge/lib/core/strings/app_strings.dart` using the exact copy from data-model.md §6

**Checkpoint**: `app_strings.dart` compiles; all 6 constants are accessible via `AppStrings.*`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain-adjacent value class, use-case, and Bloc scaffolding. All are independent of each other and can run in parallel. No user story work begins until this phase is complete.

**⚠️ CRITICAL**: Phase 3 (US1) cannot begin until ALL of T002–T005 are complete.

- [X] T002 [P] Create `HistoryMonthGroup` value class (`label String`, `sessions List<WorkoutSession>`, `Equatable`) in `forge/lib/features/workout_session/application/models/history_month_group.dart` per data-model.md §2
- [X] T003 [P] Create `GetWorkoutHistoryUseCase` (`call()` returns `Future<Either<AppException, List<WorkoutSession>>>`, sorts newest-first by `startedAt ?? completedAt`) in `forge/lib/features/workout_session/application/use_cases/get_workout_history_use_case.dart` per data-model.md §3
- [X] T004 [P] Create `WorkoutHistoryEvent` sealed class with single event `WorkoutHistoryLoadRequested extends WorkoutHistoryEvent` in `forge/lib/features/workout_session/application/bloc/workout_history_event.dart` per data-model.md §4
- [X] T005 [P] Create `WorkoutHistoryState` sealed class with five concrete states (`WorkoutHistoryInitial`, `WorkoutHistoryLoading`, `WorkoutHistorySuccess({required List<HistoryMonthGroup> groups})`, `WorkoutHistoryEmpty`, `WorkoutHistoryError({required String message})`) in `forge/lib/features/workout_session/application/bloc/workout_history_state.dart` per data-model.md §5

**Checkpoint**: `flutter analyze` reports zero errors on T002–T005. All classes are importable.

---

## Phase 3: User Story 1 — Browse Completed Workout History (Priority: P1) 🎯 MVP

**Goal**: Users can open the History tab and see a reverse-chronological, month-grouped list of completed workout sessions. Each row shows day, day-of-week, plan name, and summary line. Tapping any row navigates to SCR-21.

**Independent Test** (quickstart.md Scenario 1): Seed two sessions in different calendar months. Open the History tab. Verify the loading skeleton appears, then the populated list with two month-group headers, sessions newest-first, each row showing the correct fields.

### Implementation for User Story 1

- [X] T006 [US1] Create `WorkoutHistoryBloc` with `_onLoadRequested` handler (emit Loading → call use-case → emit Success/Empty/Error), private `_buildGroups` helper (static array month names, static array **uppercase** DOW abbreviations `['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']` per FR-003(b), zero-padded day via `date.day.toString().padLeft(2, '0')`, no `intl` package), and date fallback `startedAt ?? completedAt` in `forge/lib/features/workout_session/application/bloc/workout_history_bloc.dart` per contracts/workout-history-bloc.md (depends on T002–T005)
- [X] T007 [P] [US1] Create `HistoryCard` public widget (params: `dayNumber String`, `dayOfWeek String`, `planName String`, `summaryLine String`, `onTap VoidCallback`; renders date-badge column + body column + trailing chevron; all colors from `AppColors`; all text styles from `theme.textTheme`) in `forge/lib/features/workout_session/presentation/widgets/history_card.dart` per data-model.md §8
- [X] T008 [P] [US1] Create `HistoryMonthLabel` public widget (param: `label String`; renders section header in `AppColors.textMuted` with `theme.textTheme.labelMedium`) in `forge/lib/features/workout_session/presentation/widgets/history_month_label.dart` per data-model.md §8
- [X] T009 [P] [US1] Create `HistorySkeleton` public `StatefulWidget` (owns `AnimationController` with `repeat()`; renders 4 placeholder card containers with sweeping `LinearGradient` from `AppColors.cardAlt` to `AppColors.shimmerDark`; disposes controller in `dispose()`) in `forge/lib/features/workout_session/presentation/widgets/history_skeleton.dart` per research.md D-05
- [X] T010 [US1] Create `WorkoutHistoryScreen` `StatefulWidget` with `didChangeDependencies` firing `context.read<WorkoutHistoryBloc>().add(const WorkoutHistoryLoadRequested())` on every call; `BlocBuilder` switch over all 5 states where **both `WorkoutHistoryInitial` and `WorkoutHistoryLoading` collapse to the same `HistorySkeleton()` branch** (ensures skeleton appears within one frame of tab activation per SC-003 and Constitution VII.1 — no blank screen); `WorkoutHistorySuccess` builds `ListView` interleaving `HistoryMonthLabel` + `HistoryCard` items; card `onTap` calls `context.go(RoutePaths.workoutHistoryDetail, extra: session)` in `forge/lib/features/workout_session/presentation/screens/workout_history_screen.dart` (depends on T001, T005, T007–T009)
- [X] T011 [US1] Amend `forge/lib/config/routes/app_routes.dart`: (a) **first, verify `RoutePaths.workoutHistoryDetail` exists as a route path constant** — if absent, add `static const String workoutHistoryDetail = '/history/detail';` to `RoutePaths` (no handler required; SCR-21 will add the handler); (b) in `StatefulShellRoute` Branch 3 builder, replace `const PlaceholderTabScreen(label: 'History')` with `BlocProvider(create: (_) => getIt<WorkoutHistoryBloc>(), child: const WorkoutHistoryScreen())` per research.md D-01 (depends on T010)
- [X] T012 [US1] Register `GetWorkoutHistoryUseCase` as `registerLazySingleton` and `WorkoutHistoryBloc` as `registerFactory` in `forge/lib/app/get_it_setup.dart` per research.md D-10 (depends on T003, T006)
- [X] T013 [US1] Create `workout_history_bloc_test.dart` covering: (a) `WorkoutHistoryLoadRequested` → emits `[WorkoutHistoryLoading, WorkoutHistorySuccess(groups)]`; (b) sessions spanning two months → `groups.length == 2`, labels are `"September 2026"` / `"August 2026"` format; (c) sessions in same month → `groups.length == 1`, sessions newest-first in `groups[0].sessions`; (d) `sessionDurationSec ~/ 60` drives the minute value in the summary line; **(e) DOW for a known Monday `DateTime` → 'MON' (uppercase, not 'Mon')** (FR-003b fix, finding I1); **(f) two `HistoryMonthGroup` instances with identical `label` and `sessions` are equal** (Equatable props verification, finding A1) in `forge/test/features/workout_session/application/bloc/workout_history_bloc_test.dart` (depends on T006; use `mocktail` to mock `GetWorkoutHistoryUseCase`)
- [X] T014 [P] [US1] Create `get_workout_history_use_case_test.dart` covering: (a) `call()` on `Right([sessionB_older, sessionA_newer])` → returns `Right([sessionA_newer, sessionB_older])` (sort newest-first); (b) `call()` on `Right([])` → returns `Right([])`; (c) `call()` on `Left(CacheException)` → returns `Left(CacheException)` unchanged; **(d) when `session.startedAt` is null, sort falls back to `session.completedAt`** in `forge/test/features/workout_session/application/use_cases/get_workout_history_use_case_test.dart` (depends on T003; use `mocktail` to mock `WorkoutSessionRepository`) — **required by Constitution XI.3 (C1 fix)**
- [X] T015 [US1] Create `workout_history_screen_test.dart` covering: (a) `WorkoutHistoryLoading` → `HistorySkeleton` is visible; **(b) `WorkoutHistoryInitial` → `HistorySkeleton` is also visible** (D1 fix — Initial collapses to skeleton branch, no blank screen); (c) `WorkoutHistorySuccess` → `HistoryCard` and `HistoryMonthLabel` widgets are visible; (d) tapping a `HistoryCard` fires `onTap` with the **correct `WorkoutSession` object** (verify the session passed to the callback matches the session in the state, not just that onTap fires — SC-004 coverage, finding U1) in `forge/test/features/workout_session/presentation/screens/workout_history_screen_test.dart` (depends on T010; use `mocktail` to mock `WorkoutHistoryBloc`)

**Checkpoint**: App builds. History tab shows populated list. All US1 tests pass. `flutter analyze` reports zero new errors.

---

## Phase 4: User Story 2 — Handle Empty History and Load Failures (Priority: P2)

**Goal**: When no sessions exist the user sees the exact empty-state copy (FR-006). When a read fails the user sees the exact error-state copy with a Retry button (FR-007–FR-010). These two states are NEVER confused — constitutionally enforced by sealed class variants.

**Independent Test** (quickstart.md Scenarios 2, 3, 6): (a) Fresh install → empty state shows "No workout history yet" with no Retry button. (b) Injected read failure → error state shows correct title, body, and Retry button; tapping Retry re-triggers the read; multiple failures show error state each time.

### Implementation for User Story 2

- [X] T016 [US2] Add US2 Bloc test scenarios to `forge/test/features/workout_session/application/bloc/workout_history_bloc_test.dart`: (a) Right([]) → emits `[WorkoutHistoryLoading, WorkoutHistoryEmpty]`, NOT `WorkoutHistoryError`; (b) Left(CacheException) → emits `[WorkoutHistoryLoading, WorkoutHistoryError(message: AppStrings.historyErrorTitle)]`, NOT `WorkoutHistoryEmpty`; (c) retry cycle: Error → LoadRequested → `[WorkoutHistoryLoading, WorkoutHistoryError]`; (d) retry succeeds: Error → LoadRequested → `[WorkoutHistoryLoading, WorkoutHistorySuccess]`
- [X] T017 [US2] Add US2 widget test scenarios to `forge/test/features/workout_session/presentation/screens/workout_history_screen_test.dart`: (a) `WorkoutHistoryEmpty` → shows `AppStrings.historyEmptyTitle` and `AppStrings.historyEmptySubtitle`; Retry button is NOT present; (b) `WorkoutHistoryError` → shows `AppStrings.historyErrorTitle`, `AppStrings.historyErrorBody`, and `AppStrings.historyRetryLabel` button; empty-state text is NOT present; (c) tapping Retry button → `WorkoutHistoryLoadRequested` is added to Bloc

**Checkpoint**: All US2 tests pass. `WorkoutHistoryEmpty` and `WorkoutHistoryError` are never interchangeable. `flutter analyze` remains clean.

---

## Phase 5: User Story 3 — Newly Completed Session Appears at Top on Re-entry (Priority: P3)

**Goal**: Every tab-switch entry to the History tab triggers a fresh data read, so any session saved since the last visit appears at the top. Back-navigation from SCR-21 does NOT re-trigger the read (FR-011/FR-012).

**Independent Test** (quickstart.md Scenarios 4, 5): Complete a workout. Switch to History tab — new session appears. Switch away and back — skeleton shows, then updated list. Navigate to SCR-21 and back — no skeleton, same list.

### Implementation for User Story 3

- [X] T018 [US3] Verify `workout_history_screen.dart` `didChangeDependencies` fires `WorkoutHistoryLoadRequested` unconditionally (no guard condition needed — `StatefulShellRoute`'s tab navigator does not call `didChangeDependencies` on back-navigation from a pushed sub-route, so FR-011 is satisfied automatically per research.md D-09). If the implementation has a guard, remove it.
- [X] T019 [US3] Add US3 widget test to `forge/test/features/workout_session/presentation/screens/workout_history_screen_test.dart`: pumping the screen and calling `didChangeDependencies` causes `WorkoutHistoryLoadRequested` to be added to the Bloc (verify via `verify(() => bloc.add(const WorkoutHistoryLoadRequested())).called(1)`)

**Checkpoint**: All US3 tests pass. Switching to History tab triggers skeleton → fresh list on every entry.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Format, analyze, test, and manually validate all 8 quickstart scenarios.

- [X] T020 [P] Run `dart format .` from `forge/` and confirm zero formatting changes remain on all SCR-20 files
- [X] T021 [P] Run `flutter analyze` from `forge/` and resolve every warning or info message introduced by SCR-20
- [X] T022 Run `flutter test` from `forge/` and verify all SCR-20 tests pass with zero failures; confirm no pre-existing tests were broken
- [ ] T023 Run quickstart.md Scenarios 1–8 manually on the iOS simulator or Android emulator and confirm all pass
- [X] T024 Verify domain layer purity and offline invariant: (a) confirm `forge/lib/features/workout_session/domain/` contains no new imports from `application/`, `presentation/`, Drift, or Flutter framework packages; (b) confirm no SCR-20 file imports `dart:io HttpClient`, `http`, `dio`, or any network package (FR-013 offline invariant)

**Checkpoint**: All 24 tasks complete. Zero analyzer warnings. All tests green. All 8 quickstart scenarios pass.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: No dependencies — can start immediately in parallel with Phase 1; T002–T005 can all run concurrently
- **Phase 3 (US1)**: Depends on Phase 1 (T001 for AppStrings) + Phase 2 (T002–T005 for events/states/use-case)
  - Within Phase 3: T007, T008, T009, T014 can run in parallel; T010 depends on T007–T009; T011 depends on T010; T012 depends on T003 and T006; T013/T015 depend on T006/T010
- **Phase 4 (US2)**: Depends on Phase 3 (T013, T015 must exist to extend)
- **Phase 5 (US3)**: Depends on Phase 3 (T010, T015 must exist to verify and extend)
- **Phase 6 (Polish)**: Depends on all prior phases

### User Story Dependencies

- **US1 (P1)**: Can start after Phase 2 completes — no dependency on US2 or US3
- **US2 (P2)**: Can start after US1 Bloc (T006) and screen (T010) exist — adds test scenarios, no new source files
- **US3 (P3)**: Can start after US1 screen (T010) exists — verification + one test, no new source files

### Parallel Opportunities

- T002, T003, T004, T005 can all run concurrently (different files, no cross-dependencies)
- T007, T008, T009, T014 can all run concurrently (different files, no cross-dependencies)
- T020, T021 can run concurrently (formatting + analysis)

---

## Parallel Example: Phase 2 (Foundational)

```text
Parallel batch — start all at once:
  Task T002: Create history_month_group.dart
  Task T003: Create get_workout_history_use_case.dart
  Task T004: Create workout_history_event.dart
  Task T005: Create workout_history_state.dart
```

## Parallel Example: Phase 3 (US1)

```text
Parallel batch — start all at once after T006 is written:
  Task T007: Create history_card.dart
  Task T008: Create history_month_label.dart
  Task T009: Create history_skeleton.dart
  Task T014: Create get_workout_history_use_case_test.dart

Then sequentially (depends on T007–T009):
  Task T010: Create workout_history_screen.dart
  Task T013: Create workout_history_bloc_test.dart  (after T006)
  Task T015: Create workout_history_screen_test.dart (after T010)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only — T001–T015)

1. Complete Phase 1 (T001): AppStrings
2. Complete Phase 2 (T002–T005): value class, use-case, events, states — all in parallel
3. Complete Phase 3 US1 (T006–T015): Bloc, use-case test, widgets, screen, route, DI, US1 tests
4. **STOP and VALIDATE**: History tab shows populated list; all US1 tests pass
5. Demo-ready MVP

### Incremental Delivery

1. Phase 1 + 2 → Foundation ready
2. Phase 3 (US1) → Populated list + skeleton → testable MVP
3. Phase 4 (US2) → Error/empty state invariant verified by tests
4. Phase 5 (US3) → Re-fetch on tab-switch confirmed
5. Phase 6 (Polish) → Shippable increment

---

## Notes

- `[P]` tasks have different target files and no cross-dependencies — they can safely run concurrently
- `[Story]` label maps each implementation task to the user story that verifies it
- Constitution XI.3 mandates use-case tests and Bloc state-transition tests; XI.4 mandates widget tests for all states — tests are not optional
- **DOW abbreviations MUST be uppercase** (`'MON'`…`'SUN'`) per FR-003(b); FR takes precedence over AC narrative examples that use title case
- **`WorkoutHistoryInitial` MUST render `HistorySkeleton`** (same branch as `WorkoutHistoryLoading`) — blank Initial state violates Constitution VII.1
- **`RoutePaths.workoutHistoryDetail`** must exist as a constant before T010 compiles; add stub in T011 if absent (SCR-21 adds the route handler)
- No `intl` package: use static array month names and DOW abbreviations (research.md D-04)
- `AppColors.shimmerDark` already exists — no new color token needed (research.md D-05)
- SCR-16 prerequisite: if `WorkoutSession.startedAt` or `ActualSet.skipped` are absent, use `completedAt` fallback and count all sets, then file a follow-up (research.md D-07, D-08)
- No Git operations in any task (Constitution Mandatory Rule)
