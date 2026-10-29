# Tasks: SCR-23 Statistics Dashboard

**Input**: Design documents from `specs/SCR-23-Statistics-Dashboard/mobile/001-scr-23-statistics-dashboard/`

**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/stats-bloc.md ✅ | quickstart.md ✅

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no shared-file dependencies)
- **[Story]**: Which user story this task belongs to (US1 / US2 / US3)
- File paths are relative to `forge/` (the Flutter project root)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Core token and entity additions that every later phase depends on. No Flutter framework code; pure Dart plus constants.

- [X] T001 Add `static const Color successFill = Color(0xFF1E2A12);` to `lib/core/theme/app_colors.dart` (after existing lime/cyan tokens; required for PersonalBestsLinkRow icon-wrap)
- [X] T002 [P] Add 18 `AppStrings.stats*` constants to `lib/core/strings/app_strings.dart`: `statsTitle`, `statsWorkoutsCompleted`, `statsTotalVolume`, `statsTotalDuration`, `statsAvgDuration`, `statsExerciseBreakdownLabel`, `statsRecordsLabel`, `statsPersonalBestsTitle`, `statsPersonalBestsSub`, `statsEmptyTitle`, `statsEmptySub`, `statsEmptyCta`, `statsErrorTitle`, `statsErrorBody`, `statsBestWeight`, `statsBestTime`, `statsBestReps`, `statsSessionsSuffix`
- [X] T003 [P] Create `StatsData` pure-Dart entity in `lib/features/stats/domain/entities/stats_data.dart` — fields: `totalWorkoutsCompleted: int`, `totalVolumeKg: int`, `totalDurationSec: int`, `avgDurationSec: int?` (null when 0 valid sessions); `const` constructor
- [X] T004 [P] Create `ExerciseStatRow` pure-Dart entity in `lib/features/stats/domain/entities/exercise_stat_row.dart` — fields: `exerciseName: String`, `type: ExerciseType`, `sessionCount: int`, `bestWeight: double`, `bestReps: int`, `bestDurationSec: int`; `const` constructor; no Drift annotation

**Checkpoint**: T002, T003, T004 can run in parallel after T001 (no shared-file conflicts)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Bloc events, states, use case, and DI registration. MUST complete before any screen or widget work.

**⚠️ CRITICAL**: No user story widget work can begin until T009 is complete.

- [X] T005 Create `StatsEvent` sealed class in `lib/features/stats/application/bloc/stats_event.dart` — single `final class StatsLoadRequested extends StatsEvent {}` (no payload; used for initial load AND retry)
- [X] T006 [P] Create `StatsState` sealed class in `lib/features/stats/application/bloc/stats_state.dart` — `StatsInitial`, `StatsLoading`, `StatsLoaded({required StatsData stats, required List<ExerciseStatRow> exercises})`, `StatsError`; sealed with `const` constructors
- [X] T007 [P] Implement `GetStatisticsUseCase` in `lib/features/stats/application/use_cases/get_statistics_use_case.dart` — constructor takes `WorkoutSessionRepository`; `call()` returns `Future<(StatsData, List<ExerciseStatRow>)>`; valid-session filter (completedAt != null AND ≥1 non-skipped ActualSet; treat absent `skipped` as false); computes: `totalWorkoutsCompleted`, `totalVolumeKg` (Σ weight×reps for non-skipped weighted sets, rounded), `totalDurationSec` (Σ sessionDurationSec), `avgDurationSec` (integer division; null when 0 sessions); groups exercises by name with sessionCount + bestWeight/bestReps/bestDurationSec; sorts by sessionCount desc then exerciseName asc
- [X] T008 Implement `StatsBloc` in `lib/features/stats/application/bloc/stats_bloc.dart` — extends `Bloc<StatsEvent, StatsState>`; initial state `StatsInitial`; handles `StatsLoadRequested`: emits `StatsLoading` → calls `GetStatisticsUseCase` → emits `StatsLoaded` on success or `StatsError` on exception (depends on T005, T006, T007)
- [X] T009 Register `GetStatisticsUseCase` and `StatsBloc` in `lib/app/get_it_setup.dart` — `registerLazySingleton<GetStatisticsUseCase>(() => GetStatisticsUseCase(getIt<WorkoutSessionRepository>()))` then `registerFactory<StatsBloc>(() => StatsBloc(getStatistics: getIt<GetStatisticsUseCase>()))` (after existing WorkoutSessionRepository registration at line 94)

**Checkpoint**: Foundation complete — all user story widget tasks can now proceed

---

## Phase 3: User Story 1 — View Populated Statistics Dashboard (Priority: P1) 🎯 MVP

**Goal**: User opens Stats tab and sees the loading skeleton resolve to four populated stat tiles, a per-exercise breakdown, and the Personal Bests navigation row. Screen layout is scrollable; stat tiles and exercise cards are read-only.

**Independent Test**: Seed ≥1 valid `WorkoutSession` (non-null `completedAt`, ≥1 non-skipped `ActualSet`), navigate to Stats tab. Verify: (a) skeleton flashes briefly, (b) four aggregate tiles show correct computed values, (c) exercise breakdown shows correct cards in session-count-desc order, (d) "Personal Bests" row is tappable and pushes to `/stats/personal-bests`.

### Implementation for User Story 1

- [X] T010 [P] [US1] Implement `StatTile` widget in `lib/features/stats/presentation/widgets/stat_tile.dart` — public `StatelessWidget`; params: `icon: Widget`, `value: String`, `label: String`, `opacity: double` (default 1.0; used for empty-state dimming in US2); renders `card-alt` icon-wrap (28×28, borderRadius:8) + 19px/weight-800 white value + 11px/muted label; uses `theme.colorScheme`, `AppColors`, `theme.textTheme`; no hardcoded colors or sizes (use design constants or named values)
- [X] T011 [P] [US1] Implement `StatsSkeleton` widget in `lib/features/stats/presentation/widgets/stats_skeleton.dart` — public `StatefulWidget` owning `AnimationController(duration: 1000ms, vsync: this)` with `repeat(reverse: true)`; renders 2×2 grid of 4 `ShimmerBox(height: 88, borderRadius: 14)` + section-label placeholder `ShimmerBox(height: 16, width: 160, borderRadius: 4)` + 3 exercise-row `ShimmerBox(height: 56, borderRadius: 14)`; disposes controller in `dispose()`
- [X] T012 [P] [US1] Implement `ExerciseStatCard` widget in `lib/features/stats/presentation/widgets/exercise_stat_card.dart` — public `StatelessWidget`; params: `row: ExerciseStatRow`; renders 8×8 type dot (lime=weighted, cyan=timeBased, muted=bodyweight per D-04); exercise name (13px/weight-700, maxLines:1, overflow:ellipsis); meta `'${row.sessionCount} ${AppStrings.statsSessionsSuffix}'` (11px/muted); right-aligned best-value + type-specific label per data-model.md best-value display rules (best time as `MM:SS` with leading zeros); no tap action (read-only)
- [X] T013 [P] [US1] Implement `PersonalBestsLinkRow` widget in `lib/features/stats/presentation/widgets/personal_bests_link_row.dart` — public `StatelessWidget`; params: `onTap: VoidCallback`; renders full-width tappable `InkWell`: trophy-icon-wrap (32×32, borderRadius:8, background `AppColors.successFill`), 16×16 trophy SVG (color `AppColors.lime`), title `AppStrings.statsPersonalBestsTitle` (13px/weight-700), subtitle `AppStrings.statsPersonalBestsSub` (11px/muted), decorative chevron-right 16×16 (color `AppColors.textDim`, `Semantics(excludeSemantics: true)`); use `AppColors.cardAlt` for card background and `AppColors.cardBorder` for border
- [X] T014 [US1] Implement `StatsScreen` scaffold in `lib/features/stats/presentation/screens/stats_screen.dart` — `StatefulWidget` with `bool _retrying = false`; `build()` uses `BlocConsumer<StatsBloc, StatsState>`: `listenWhen` clears `_retrying` when non-Loading state arrives; `buildWhen` rebuilds on any state change; `builder` returns `Scaffold` with app bar showing `AppStrings.statsTitle` + `SafeArea` content; `StatsInitial` and `StatsLoading` branches render `StatsSkeleton()`; `StatsLoaded` branch delegates to a `_buildLoadedBody(state)` helper; `StatsError` branch delegates to `_buildErrorBody()`; `_buildErrorBody()` returns centered placeholder text (to be replaced in US3/T020); does NOT dispatch `StatsLoadRequested` itself — BlocProvider.create handles that
- [X] T015 [US1] Implement `_buildLoadedBody` helper in `StatsScreen` — `CustomScrollView` with `SliverPadding`: 2×2 `GridView.count(crossAxisCount:2, shrinkWrap:true, physics:NeverScrollableScrollPhysics)` of 4 `StatTile` widgets (real values + format helpers: duration as `{N}h {N}m`, volume as `{N} kg`, avg as `{N} min`/`{N}h {N}m`/`—`); if `state.exercises.isNotEmpty`: section label `AppStrings.statsExerciseBreakdownLabel` + `ListView` of `ExerciseStatCard`; always: section label `AppStrings.statsRecordsLabel` + `PersonalBestsLinkRow(onTap: () => context.push(RoutePaths.statsPersonalBests))`; check `context.mounted` before push
- [X] T016 [US1] Wire route in `lib/config/routes/app_routes.dart` — add `static const String statsPersonalBests = '/stats/personal-bests'` to `RoutePaths`; replace Branch 5 builder with `BlocProvider(create: (_) => getIt<StatsBloc>()..add(StatsLoadRequested()), child: const StatsScreen())`; add child `GoRoute(path: RoutePaths.statsPersonalBests, builder: (_, __) => const PlaceholderTabScreen(label: 'Personal Bests'))` under Branch 5

**Checkpoint**: US1 fully functional — skeleton resolves to populated main state; Personal Bests row navigates; scrolling works

---

## Phase 4: User Story 2 — Handle Empty State (No Completed Workouts) (Priority: P2)

**Goal**: User with no valid session history sees four dimmed stat tiles with zeroed/placeholder values, a "No stats yet" prompt, and a "Start a Workout" CTA. Exercise breakdown and Personal Bests row are hidden.

**Independent Test**: Clear the `workout_sessions` table (or seed sessions with all sets skipped), navigate to Stats tab. Verify: dimmed 2×2 grid with `0`, `0 kg`, `0h 0m`, `—`; "No stats yet" heading; CTA tapping navigates to Plans tab; no exercise breakdown section; no Personal Bests row.

### Implementation for User Story 2

- [X] T017 [P] [US2] Implement `StatsEmptyState` widget in `lib/features/stats/presentation/widgets/stats_empty_state.dart` — public `StatelessWidget`; params: `onStartWorkout: VoidCallback`; renders `Column`: 44×44 dim bar-chart icon (`Semantics(excludeSemantics: true)`), title `AppStrings.statsEmptyTitle` (16px/weight-800), subtitle `AppStrings.statsEmptySub` (13px/muted, line-height:1.5, maxWidth:250), `ElevatedButton` with `AppStrings.statsEmptyCta` (lime bg, `Color(0xFF131315)` text — use `AppColors.backgroundBase` if it matches `#131315`, else a named constant; weight-800/13px, borderRadius:10, padding:12×22); minimum touch target ≥44pt (SC-005)
- [X] T018 [US2] Update `_buildLoadedBody` in `StatsScreen` to branch on `state.stats.totalWorkoutsCompleted == 0` — Empty branch: wrap 2×2 stat grid in `Opacity(opacity: .55)` with zeroed `StatTile` values (icons at reduced opacity) + `StatsEmptyState(onStartWorkout: () => context.go('/plans'))`; Main branch: existing populated layout from T015; check `context.mounted` before navigation

**Checkpoint**: US2 functional — empty state shows dimmed grid + prompt; CTA navigates to Plans; no breakdown visible

---

## Phase 5: User Story 3 — Error State with Retry (Priority: P3)

**Goal**: Drift read failure shows an error card with explanatory copy and a Retry button. Retry debounce prevents double-dispatch. Retry re-enters the loading skeleton and resolves to the correct outcome state.

**Independent Test**: Provide a `WorkoutSessionRepository` stub that throws on `getAllSessions()` (widget test or manual injection). Navigate to Stats tab; observe error card with correct title/body/button. Tap Retry once; observe skeleton; observe error again. Tap Retry twice rapidly; confirm only one read cycle fires.

### Implementation for User Story 3

- [X] T019 [P] [US3] Implement `StatsErrorCard` widget in `lib/features/stats/presentation/widgets/stats_error_card.dart` — public `StatelessWidget`; params: `onRetry: VoidCallback`; renders `Card` (background `AppColors.dangerBg`, border `AppColors.dangerBorder`): 40×40 alert-triangle icon (`AppColors.danger`), title `AppStrings.statsErrorTitle` (16px/weight-800, textAlign:center), body `AppStrings.statsErrorBody` (13px/muted, line-height:1.5, textAlign:center), `ElevatedButton(onPressed: onRetry)` with label `AppStrings.retryButton` (lime bg, weight-800/13px, borderRadius:10, padding:11×22, minHeight:44)
- [X] T020 [US3] Update `StatsScreen` to replace placeholder error body — replace `_buildErrorBody()` to return `Center(child: Padding(child: StatsErrorCard(onRetry: _onRetry)))`; add `_onRetry()` method: guard `if (_retrying) return;`, `setState(() => _retrying = true)`, `context.read<StatsBloc>().add(StatsLoadRequested())`; update `BlocConsumer.listenWhen` to match any state where `state is! StatsLoading` to reset `_retrying = false`

**Checkpoint**: US3 functional — error card shown on failure; Retry debounce works; Retry resolves to correct state

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Code quality, tests for critical business logic (per CLAUDE.md §87), and validation.

- [X] T021 [P] Write unit tests for `GetStatisticsUseCase` in `test/features/stats/application/use_cases/get_statistics_use_case_test.dart` — test: excludes sessions where `completedAt == null`; excludes sessions where all sets skipped; includes session with ≥1 non-skipped set; `totalVolumeKg` sums only weighted non-skipped sets; `avgDurationSec` is null when 0 valid sessions; exercises sorted by sessionCount desc then alpha; absent `skipped` field treated as non-skipped
- [X] T022 [P] Write unit tests for `StatsBloc` in `test/features/stats/application/bloc/stats_bloc_test.dart` — test: initial state is `StatsInitial`; `StatsLoadRequested` emits `[StatsLoading, StatsLoaded]` on success; `StatsLoadRequested` emits `[StatsLoading, StatsError]` on exception; second `StatsLoadRequested` while loading completes normally (Bloc queues events)
- [X] T023 Run `dart format .` from `forge/` directory and commit any formatting changes
- [X] T024 Run `flutter analyze` from `forge/` directory and resolve every new warning or error introduced by this feature (zero new issues required — SC per CLAUDE.md §91)
- [X] T025 Run `flutter test` from `forge/` directory and confirm all tests green including T021 and T022
- [ ] T026 Manual validation per `quickstart.md` — walk through all 8 scenarios: Loading state, Empty state, Main state (single session), valid-session filter, avg duration ≥60 min formatting, Error + Retry, on-entry recalculation, Personal Bests navigation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — can start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 completion (T003, T004 needed for T006, T007)
- **Phase 3 (US1)**: Depends on Phase 2 completion — BLOCKS all story UI work
- **Phase 4 (US2)**: Depends on Phase 3 completion (updates `StatsScreen`)
- **Phase 5 (US3)**: Depends on Phase 3 completion (updates `StatsScreen`); can run in parallel with Phase 4
- **Phase 6 (Polish)**: Depends on Phases 3–5 all complete

### User Story Dependencies

- **US1 (P1)**: After Phase 2 foundational — no US dependencies
- **US2 (P2)**: After US1 (`StatsScreen` must exist before adding the empty branch)
- **US3 (P3)**: After US1 (`StatsScreen` must exist before adding the error branch); independent of US2

### Within Each Phase

- T001 before T002/T003/T004 (to avoid race on app_colors.dart first edit)
- T005/T006/T007 can run after T001 (parallel)
- T008 after T005, T006, T007 (depends on all three)
- T009 after T008
- T010/T011/T012/T013 can all run in parallel (different new files)
- T014 after T010/T011/T012/T013
- T015 after T014 (same file, sequential edit)
- T016 after T015 (route wiring after screen is functional)
- T017 parallel with T019 (different new files)
- T018 after T017 (updates StatsScreen with StatsEmptyState)
- T020 after T019 (updates StatsScreen with StatsErrorCard)
- T021/T022 can run in parallel (different test files)
- T023 → T024 → T025 (sequential; each depends on the prior passing)

---

## Parallel Opportunities

### Phase 1

```
T001 → T002 T003 T004 (in parallel)
```

### Phase 2

```
T005  T006  T007  (in parallel after Phase 1)
    └─────────┘
         T008  →  T009
```

### Phase 3 (US1)

```
T010  T011  T012  T013  (in parallel after Phase 2)
  └──────────────┘
        T014  →  T015  →  T016
```

### Phases 4 & 5 (after US1)

```
T017  T019  (in parallel — different new files)
T018  T020  (sequential per file — T018 after T017, T020 after T019)
```

### Phase 6

```
T021  T022  (in parallel)
T023  →  T024  →  T025  →  T026
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: US1 (T010–T016)
4. **STOP and validate**: confirm populated main state works end-to-end
5. Run T023/T024/T025 against US1 only

### Incremental Delivery

1. Phase 1 + Phase 2 → Foundation complete
2. Phase 3 (US1) → MVP: Stats tab shows real data ✓
3. Phase 4 (US2) → First-time user and edge cases handled ✓
4. Phase 5 (US3) → Error resilience complete ✓
5. Phase 6 → Quality gate passed; feature shippable ✓

---

## Notes

- `[P]` tasks operate on different files and have no dependency on other incomplete tasks in the same phase — safe to run concurrently
- `StatsScreen` is touched by T014, T015, T018, T020 — these MUST remain sequential
- `app_routes.dart` is touched only by T016 — single edit, no conflict risk
- `get_it_setup.dart` is touched only by T009 — single edit, no conflict risk
- `app_colors.dart` is touched only by T001; `app_strings.dart` is touched only by T002 — no conflict risk with [P] tasks in Phase 1 that create new files
- `AppColors.successFill` is used in T013 (`PersonalBestsLinkRow`) — T001 must complete before T013 can compile
- The `intl` package is not available (ADR-030); all duration/number formatting uses pure Dart (manually format `Duration` from `totalDurationSec`)
- All new public widgets follow `PascalCase`; all new files follow `snake_case.dart`
- `StatsSkeleton` is the only widget that holds an `AnimationController`; all other widgets are `StatelessWidget`
- `StatsScreen` is a `StatefulWidget` only because it holds `bool _retrying`; if `_retrying` is removed in future, convert to stateless
