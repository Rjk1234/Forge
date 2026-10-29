# Tasks: SCR-22 Progress Comparison

**Input**: Design documents from `specs/SCR-22-Progress-Comparison/mobile/001-scr-22-progress-comparison/`

**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/progress-bloc.md ✅, quickstart.md ✅

**Tests**: Test tasks are included (see Phase 6). Tests cover use-case computation logic, Bloc state transitions, and key widget states.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story. Phases 1 and 2 have no story label.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no blocking dependencies on other in-progress tasks)
- **[Story]**: Which user story this task belongs to ([US1], [US2], [US3])
- Exact file paths are included in each description

---

## Phase 1: Setup

**Purpose**: Create the feature directory structure. No code written here — just scaffolding so later parallel tasks can work without racing on `mkdir`.

- [X] T001 Create feature directory tree `forge/lib/features/progress/` with subdirectories `domain/entities/`, `application/bloc/`, `application/use_cases/`, `presentation/screens/`, `presentation/widgets/` and `forge/test/features/progress/application/use_cases/`, `forge/test/features/progress/application/bloc/`, `forge/test/features/progress/presentation/screens/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared infrastructure that MUST be complete before any user-story implementation begins. All tasks in this phase are independent of each other and can run in parallel.

**⚠️ CRITICAL**: No user-story work begins until this phase is complete.

- [X] T002 Add 14 SCR-22 string constants to `forge/lib/core/strings/app_strings.dart`: `progressErrorTitle` ("Couldn't load your progress"), `progressErrorBody` ("Your workout history is unaffected."), `progressEmptyTitle` ("Not enough data yet"), `progressEmptySubtitle` ("Complete a few more workouts to see your progress."), `progressLatestSessionLabel` ("Latest Session"), `progressTopWeight` ("TOP WEIGHT"), `progressBestReps` ("BEST REPS"), `progressVolume` ("VOLUME"), `progressTotalReps` ("TOTAL REPS"), `progressTotalSets` ("TOTAL SETS"), `progressBestDuration` ("BEST DURATION"), `progressTotalTime` ("TOTAL TIME"), `progressSets` ("SETS"), `progressRetryButton` ("Retry") — check if `retryButton` constant already exists; reuse it if so
- [X] T003 [P] Create `forge/lib/features/progress/domain/entities/exercise_progress_data.dart`: define `ProgressDataPoint(sessionIndex: int, metricValue: double, isLatest: bool)` (Equatable) and `ExerciseProgressData(exerciseName: String, type: ExerciseType, totalValidSessions: int, sessionDataPoints: List<ProgressDataPoint>, latestMetrics: ExerciseMetrics, deltaMetrics: ExerciseMetrics?)` (Equatable) — domain layer; no Drift imports; no Flutter imports
- [X] T004 [P] Create `forge/lib/features/progress/domain/entities/exercise_metrics.dart`: define `sealed class ExerciseMetrics extends Equatable` with three subclasses — `WeightedMetrics(topWeight: double, bestReps: int, volume: double)`, `TimedMetrics(bestDuration: int, totalTime: int, setCount: int)` (durations in seconds), `BodyweightMetrics(totalSets: int, bestReps: int, totalReps: int)` — domain layer; no Drift imports; no Flutter imports
- [X] T005 [P] Create `forge/lib/features/progress/application/bloc/progress_event.dart`: define `sealed class ProgressEvent extends Equatable`, `final class ProgressLoadRequested extends ProgressEvent` (const, no fields), `final class ProgressExerciseSelected extends ProgressEvent` (`exerciseName: String`) — imports domain entities only
- [X] T006 [P] Create `forge/lib/features/progress/application/bloc/progress_state.dart`: define `sealed class ProgressState extends Equatable`, `final class ProgressInitial extends ProgressState` (const), `final class ProgressLoading extends ProgressState` (const), `final class ProgressLoaded extends ProgressState` (`exercises: List<ExerciseProgressData>`, `selectedExerciseName: String`; props = [exercises, selectedExerciseName]), `final class ProgressError extends ProgressState` (const) — imports domain entities only
- [X] T007 [P] Create `forge/lib/features/progress/application/use_cases/get_exercise_progress_data_use_case.dart`: `GetExerciseProgressDataUseCase({required WorkoutSessionRepository repository})` with `Future<Either<AppException, List<ExerciseProgressData>>> call()` — implement 8-step computation from contracts/progress-bloc.md: (1) `getAllSessions()`, (2) propagate Left, (3) group by exerciseName, (4) filter valid sessions (≥1 non-skipped ActualSet), (5) sort by completedAt ascending, (6) compute `latestMetrics` from last session and `deltaMetrics` from last−second-last using `ExerciseMetrics` sealed subclasses, (7) build `sessionDataPoints` from most-recent 12 sessions (capped), (8) apply chip ordering (Group 1: totalValidSessions ≥ 2 newest-first; Group 2: <2 newest-first; alpha tie-break within same completedAt), return `Right(List<ExerciseProgressData>)`; volume for weighted = Σ(weight × reps) rounded; TOTAL REPS for bodyweight; best durationSec for timeBased chart metric; treat absent `skipped` field as false

**Checkpoint**: Foundational layer complete — domain entities, Bloc contracts, and use-case all exist. User-story implementation can begin.

---

## Phase 3: User Story 1 — View Exercise Progress Chart (Priority: P1) 🎯 MVP

**Goal**: User taps the Progress tab, sees a skeleton, then a chip row with pre-selected exercise, a line chart (≤12 sessions), a "Latest Session" label, and 3 stat tiles with signed deltas. Chip taps update the view without re-reading Drift.

**Independent Test**: Seed ≥2 completed `WorkoutSession` records sharing one exercise. Open the Progress tab. Verify: skeleton resolves to chip row; chart renders with correct data points; 3 stat tiles show values and deltas; tapping a different chip updates the view without a loading flash.

- [X] T008 [US1] Create `forge/lib/features/progress/application/bloc/progress_bloc.dart`: `ProgressBloc extends Bloc<ProgressEvent, ProgressState>` — constructor takes `GetExerciseProgressDataUseCase getProgressData`; registers `_onLoadRequested` and `_onExerciseSelected`; `_onLoadRequested` emits `ProgressLoading`, awaits use-case, emits `ProgressLoaded(exercises: exercises, selectedExerciseName: exercises.first.exerciseName)` on non-empty Right or `ProgressLoaded(exercises: [], selectedExerciseName: '')` on empty Right, calls `LoggingService.logError` and emits `ProgressError` on Left; `_onExerciseSelected` guards `if (state is! ProgressLoaded) return;` then emits new `ProgressLoaded` with same exercises and new `selectedExerciseName` — no Drift read in `_onExerciseSelected`; no mutable fields on Bloc (depends on T005, T006, T007)
- [X] T009 [P] [US1] Create `forge/lib/features/progress/presentation/widgets/progress_skeleton.dart`: `ProgressSkeleton extends StatefulWidget` — owns `AnimationController` (repeat, 1400ms duration); passes `animation` to `ShimmerBox` instances: 3 chip placeholders (height 32, borderRadius 20, widthFraction 0.28 each in a Row), 1 chart placeholder (height 150, widthFraction 1.0, borderRadius 12), 3 stat tile placeholders (height 64, widthFraction 0.3 each in a Row); dispose controller; imports `package:forge/core/widgets/shimmer_box.dart`
- [X] T010 [P] [US1] Create `forge/lib/features/progress/presentation/widgets/exercise_chip.dart`: `ExerciseChip extends StatelessWidget` — params: `exerciseName: String`, `isSelected: bool`, `onTap: VoidCallback`; selected state: `AppColors.lime` background, `AppColors.bg` text; unselected: `AppColors.cardAlt` background, `AppColors.textDefault` or white text; text truncates with ellipsis (no wrap); min-height 32, padding `EdgeInsets.symmetric(horizontal: 14, vertical: 6)`; uses `GestureDetector` or `InkWell`; uses `AppStrings` constant or raw exerciseName (chip label = exerciseName directly)
- [X] T011 [US1] Create `forge/lib/features/progress/presentation/widgets/progress_chip_row.dart`: `ProgressChipRow extends StatelessWidget` — params: `exercises: List<ExerciseProgressData>`, `selectedExerciseName: String`, `onChipTap: ValueChanged<String>`; renders `SingleChildScrollView(scrollDirection: Axis.horizontal)` wrapping a `Row` of `ExerciseChip` widgets with `SizedBox(width: 8)` gap between chips; padding `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`; depends on T010
- [X] T012 [P] [US1] Create `forge/lib/features/progress/presentation/widgets/stat_tile.dart`: `StatTile extends StatelessWidget` — params: `label: String`, `value: String`, `delta: String`, `isPositiveDelta: bool`; renders column: label (9px / textTheme.labelSmall, uppercase, `AppColors.textDim`), value (15px / fontWeight w800), delta (`isPositiveDelta ? AppColors.lime : AppColors.danger`, 10px / fontWeight w700); delta string includes explicit +/− prefix — zero delta shows as `+0` (positive); use `Theme.of(context).textTheme` — NO hardcoded text styles; use `AppColors.danger` for negative delta (NOT `AppColors.error` — that token does not exist; see research D-05)
- [X] T013 [US1] Create `forge/lib/features/progress/presentation/widgets/progress_chart_card.dart`: `ProgressChartCard extends StatelessWidget` — params: `dataPoints: List<ProgressDataPoint>`; wraps `LayoutBuilder` to get available width, sizes `CustomPaint` at `Size(constraints.maxWidth, 150)`; defines `ProgressChartPainter extends CustomPainter` — draws 3 horizontal grid lines at 25%, 50%, 75% of canvas height in `AppColors.textDim` at low opacity; normalizes `metricValue` across all points to y-range with top/bottom padding (8px each); draws trend line as `Path` using `canvas.drawPath` with lime stroke (strokeWidth 2); draws regular data points as filled circles (r: 4, `AppColors.lime`); draws latest data point (`isLatest == true`) as circle (r: 5, white fill, lime border, strokeWidth 2); `shouldRepaint` returns true only when dataPoints differ; wraps in a `Card` using `AppColors.card` or `AppColors.surface` background; depends on T003 for `ProgressDataPoint`
- [X] T014 [US1] Create `forge/lib/features/progress/presentation/screens/progress_screen.dart`: `ProgressScreen extends StatefulWidget` — owns `_retrying: bool` local state; `build` returns `Scaffold` (no app bar back arrow, `automaticallyImplyLeading: false`) with `BlocConsumer` — `listenWhen` triggers on transition away from `ProgressLoading`; `listener` resets `_retrying = false` when state becomes `ProgressLoaded` or `ProgressError`; `builder` switches on state: `ProgressInitial | ProgressLoading` → `ProgressSkeleton()`; `ProgressLoaded` → column with `ProgressChipRow` + (if `selectedExercise.totalValidSessions >= 2`: `ProgressChartCard` + `Text(AppStrings.progressLatestSessionLabel)` + `Row` of 3 `StatTile` widgets; else: `ProgressEmptyState`); `ProgressError` → `ProgressErrorCard(onRetry: _onRetry)`; `_onRetry` guards `if (_retrying) return; setState(() => _retrying = true); context.read<ProgressBloc>().add(const ProgressLoadRequested())`; dispatch `ProgressExerciseSelected(name)` on chip tap; context.mounted check after any async gap; bottom nav bar remains visible (Scaffold, no full-screen overlay); depends on T008, T009, T011, T013, T012
- [X] T015 [US1] Register use-case and Bloc in `forge/lib/app/get_it_setup.dart`: add `getIt.registerLazySingleton<GetExerciseProgressDataUseCase>(() => GetExerciseProgressDataUseCase(repository: getIt<WorkoutSessionRepository>()))` and `getIt.registerFactory<ProgressBloc>(() => ProgressBloc(getProgressData: getIt<GetExerciseProgressDataUseCase>()))` — place after the existing WorkoutSessionRepository registration; add required imports (depends on T007, T008)
- [X] T016 [US1] Replace `PlaceholderTabScreen` on Branch 4 (`_progressNavigatorKey`, path `/progress`) in `forge/lib/config/routes/app_routes.dart` with `GoRoute(path: '/progress', builder: (context, state) => BlocProvider(create: (_) => getIt<ProgressBloc>()..add(const ProgressLoadRequested()), child: const ProgressScreen()))` — add imports for `ProgressBloc`, `ProgressScreen`, and `ProgressLoadRequested`; depends on T014, T015

**Checkpoint**: US1 fully functional and independently testable. Skeleton resolves to chip row + chart + stat tiles. Chip taps update view. Weighted exercise stat tiles show TOP WEIGHT / BEST REPS / VOLUME with lime/danger delta colors.

---

## Phase 4: User Story 2 — Handle Insufficient Data Per Exercise (Priority: P2)

**Goal**: When the selected exercise has fewer than 2 valid sessions, an empty state message replaces the chart and stat tiles; the chip row stays visible and interactive.

**Independent Test**: Seed two exercises: A (≥2 sessions) and B (1 session). Open Progress tab. Verify exercise A shows Main state. Tap chip B — verify empty state appears, chip row stays visible. Tap chip A again — verify Main state returns, no loading flash.

- [X] T017 [US2] Create `forge/lib/features/progress/presentation/widgets/progress_empty_state.dart`: `ProgressEmptyState extends StatelessWidget` — no constructor params; renders a centered column with `Text(AppStrings.progressEmptyTitle)` (textTheme.titleMedium) and `Text(AppStrings.progressEmptySubtitle)` (textTheme.bodyMedium, `AppColors.textDim`, textAlign center); no CTA button; padding `EdgeInsets.all(32)`; uses `Theme.of(context).textTheme` — no hardcoded text styles
- [X] T018 [US2] Wire `ProgressEmptyState` into `ProgressScreen` (`forge/lib/features/progress/presentation/screens/progress_screen.dart`): confirm the `ProgressLoaded` branch already contains the `selectedExercise.totalValidSessions < 2` guard from T014; import `ProgressEmptyState` and verify it renders when guard triggers; confirm chip row (`ProgressChipRow`) remains visible above the empty state in all cases; depends on T017

**Checkpoint**: US2 functional. Empty state appears for exercises with <2 sessions; chip row always visible in Loaded state; no loading flash on chip tap.

---

## Phase 5: User Story 3 — Error State with Retry (Priority: P3)

**Goal**: When the Drift read fails, the user sees an error card with a Retry button. Tapping Retry re-triggers the load. Double-tap is debounced. Recovery shows the correct outcome state (Main or Empty).

**Independent Test**: Mock `WorkoutSessionRepository` to return `Left(CacheException)`. Open Progress tab. Verify error card appears with correct title and body. Tap Retry — skeleton reappears. Resolve mock to success — verify Main or Empty state appears.

- [X] T019 [US3] Create `forge/lib/features/progress/presentation/widgets/progress_error_card.dart`: `ProgressErrorCard extends StatelessWidget` — param: `onRetry: VoidCallback`; renders a `Container` with `AppColors.dangerBg` fill, `Border.all(color: AppColors.dangerBorder)`, `borderRadius 12`, padding 20; inside: `Icon(Icons.error_outline, color: AppColors.danger, size: 40)`, `SizedBox(height: 12)`, `Text(AppStrings.progressErrorTitle)` (textTheme.titleSmall, `AppColors.white`, textAlign center), `SizedBox(height: 8)`, `Text(AppStrings.progressErrorBody)` (textTheme.bodySmall, `AppColors.textDim`, textAlign center), `SizedBox(height: 20)`, `OutlinedButton(onPressed: onRetry, style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: BorderSide(color: AppColors.dangerBorder), minimumSize: Size(double.infinity, 44)), child: Text(AppStrings.progressRetryButton))`; wrapped in `SizedBox.expand(child: Center(child: Padding(...)))` for full-screen centering; NOTE: this widget has title + body (two text nodes) which the generic `core/widgets/error_card.dart` does not support — creation is correct; do NOT reuse `core/widgets/error_card.dart` for this widget
- [X] T020 [US3] Wire `ProgressErrorCard` into `ProgressScreen` (`forge/lib/features/progress/presentation/screens/progress_screen.dart`): import `ProgressErrorCard`; confirm the `ProgressError` branch in the BlocConsumer builder renders `ProgressErrorCard(onRetry: _onRetry)`; confirm `_retrying` flag is set in `_onRetry` and reset by `BlocListener` on transition away from `ProgressLoading`; confirm the chip row is NOT shown in the `ProgressError` branch; confirm `context.mounted` is checked before any Bloc access after the async load; depends on T019

**Checkpoint**: US3 functional. Error card appears on Drift failure. Retry shows skeleton → resolves correctly. Double-tap Retry is ignored. All three user stories are independently functional.

---

## Phase 6: Tests

**Purpose**: Unit tests for use-case computation logic (12 scenarios), Bloc state transitions (9 scenarios), and widget-level states (12 scenarios). All three test files are independent and can run in parallel.

**Integration evidence**: Constitution §XI.5 requires integration tests covering critical journeys. For SCR-22 at POC scope (ADR-022 reduced scope), the manual quickstart.md validation scenarios (T026 — HP-01–HP-07, DI-01, DI-02, NV-01–NV-03, PR-01–PR-02) constitute the integration evidence for the full Drift → use-case → Bloc → Screen read journey. No separate automated integration test file is required at this scope.

- [X] T021 [P] Write `forge/test/features/progress/application/use_cases/get_exercise_progress_data_use_case_test.dart`: 12 test scenarios from quickstart.md — (1) returns empty list when no sessions, (2) returns single exercise with 1 session in Group 2, (3) returns exercise with ≥2 sessions in Group 1, (4) chip ordering: Group 1 before Group 2, newest-first within group, alpha tie-break, (5) chart capped at 12 sessions for exercise with 15 sessions, (6) stat tile always uses 2 most-recent regardless of cap, (7) weighted volume = Σ(weight × reps) rounded, skipped sets excluded, (8) bodyweight: TOTAL REPS replaces VOLUME; TOTAL SETS in first tile, (9) timeBased: BEST DURATION / TOTAL TIME / SETS tiles; chart plots max durationSec per session, (10) delta is null when only 1 valid session, (11) corrupt session with missing fields is excluded; valid sessions shown, (12) Left from repository propagates as Left from use-case; use `mocktail` to mock `WorkoutSessionRepository`
- [X] T022 [P] Write `forge/test/features/progress/application/bloc/progress_bloc_test.dart`: 9 Bloc scenarios from quickstart.md — (1) initial state is `ProgressInitial`, (2) `ProgressLoadRequested` emits [Loading, Loaded] on success with exercises, (3) `ProgressLoadRequested` emits [Loading, Loaded([], '')] on success with empty result, (4) `ProgressLoadRequested` emits [Loading, Error] on Left from use-case, (5) `ProgressExerciseSelected` in `ProgressLoaded` emits new `ProgressLoaded` with updated `selectedExerciseName` and same exercises list, (6) `ProgressExerciseSelected` in `ProgressError` is ignored (guard: not ProgressLoaded), (7) `ProgressLoadRequested` from `ProgressError` (Retry) emits [Loading, Loaded], (8) `ProgressLoadRequested` from `ProgressLoaded` (Retry after success) emits [Loading, Loaded], (9) `_onExerciseSelected` does NOT call the use-case or repository; use `bloc_test` and `mocktail`
- [X] T023 [P] Write `forge/test/features/progress/presentation/screens/progress_screen_test.dart`: 12 widget scenarios — (1) `ProgressInitial` renders `ProgressSkeleton` (no content visible), (2) `ProgressLoading` renders `ProgressSkeleton`, (3) `ProgressLoaded` with 2+ sessions renders chip row + chart card + stat tiles, (4) `ProgressLoaded` with <2 sessions for selected exercise renders `ProgressEmptyState` + chip row, (5) `ProgressLoaded` chip row tap dispatches `ProgressExerciseSelected`, (6) `ProgressError` renders `ProgressErrorCard` (no chip row), (7) Retry button tap dispatches `ProgressLoadRequested` and sets `_retrying`, (8) double Retry tap does not dispatch twice (debounce), (9) `BlocListener` resets `_retrying` when Loaded state arrives, (10) timeBased exercise shows BEST DURATION / TOTAL TIME / SETS tile labels, (11) bodyweight exercise shows TOTAL SETS / BEST REPS / TOTAL REPS tile labels, (12) FR-019: `ProgressScreen` Scaffold has no leading back-arrow widget (`automaticallyImplyLeading: false`) and renders within a Scaffold body (not as a full-screen route that occludes the bottom nav bar); use `flutter_test` and `mocktail`

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Formatting, static analysis, and manual validation before the feature is considered done.

- [X] T024 Run `dart format .` from `forge/` directory and fix any formatting issues introduced by SCR-22 files
- [X] T025 Run `flutter analyze` from `forge/` directory and resolve any new warnings or errors introduced by SCR-22 (pre-existing warnings are acceptable if they were present before this feature; do NOT suppress analyzer rules to make code compile — fix the underlying issue)
- [ ] T026 Run 9 quickstart.md validation scenarios on a device or emulator: HP-01 (skeleton immediacy), HP-02 (chip row renders), HP-03 (chart renders), HP-04 (stat tiles), HP-05 (chip tap), DI-01 (stat value accuracy), DI-02 (zero Drift writes), NV-01 (error state), NV-02 (Retry → success), NV-03 (Retry → failure), PR-02 (20+ exercises performance)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: T001 must complete; all Phase 2 tasks (T002–T007) are then independent and can run in parallel
- **Phase 3 (US1)**: All Phase 2 tasks must complete; within Phase 3, see individual task dependencies below
- **Phase 4 (US2)**: T014 (ProgressScreen created) must complete — T017 is independent; T018 depends on T017
- **Phase 5 (US3)**: T014 must complete — T019 is independent; T020 depends on T019
- **Phase 6 (Tests)**: T008, T013, T014, T016 must complete (or at least files must exist with defined interfaces); all 3 test files are independent of each other
- **Phase 7 (Polish)**: All Phase 3–5 tasks must complete

### Within Phase 3 (US1) — Task Dependencies

```
T005 (events) ─┐
T006 (states) ─┤→ T008 (ProgressBloc) ─┐
T007 (use-case)┘                        │
                                        ├→ T015 (GetIt) ─┐
T003 (entities)→ T013 (ChartCard)  ─┐  │                 │
T010 (Chip) ──→ T011 (ChipRow)  ────┤  │                 │
T009 (Skeleton)                      │  │                 │
T012 (StatTile)                      ├→ T014 (Screen) ──→ T016 (Route)
                                     │
T017 (EmptyState, Phase 4) ─────────┘
T019 (ErrorCard, Phase 5) ──────────┘
```

### User Story Dependencies

- **US1 (P1)**: Depends on Phase 2 foundational only — independently testable
- **US2 (P2)**: Depends on US1 (ProgressScreen must exist for T018 modification) — T017 can run in parallel with US1 after Phase 2
- **US3 (P3)**: Depends on US1 (ProgressScreen must exist for T020 modification) — T019 can run in parallel with US1 after Phase 2

---

## Parallel Opportunities

```bash
# Phase 2 — all independent, run together:
T002  # AppStrings constants
T003  # ExerciseProgressData entities
T004  # ExerciseMetrics sealed class
T005  # progress_event.dart
T006  # progress_state.dart
T007  # GetExerciseProgressDataUseCase

# Phase 3 — after T005+T006+T007 complete, then:
T008  # ProgressBloc (sequential — depends on T005+T006+T007)

# After T003 and T008 complete:
T009  # ProgressSkeleton [P]
T010  # ExerciseChip [P]
T012  # StatTile [P]
T013  # ProgressChartCard [P]   ← needs T003

# Then:
T011  # ProgressChipRow (needs T010)
T014  # ProgressScreen (needs T008+T009+T011+T012+T013)
T017  # ProgressEmptyState [P]  ← can start as soon as T001 done
T019  # ProgressErrorCard [P]   ← can start as soon as T001 done

# Then:
T015  # GetIt (needs T007+T008)
T018  # wire EmptyState (needs T014+T017)
T020  # wire ErrorCard (needs T014+T019)
T016  # Route (needs T014+T015)

# Phase 6 — all independent after Phase 3 establishes interfaces:
T021  T022  T023
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup)
2. Complete Phase 2 (Foundational) — all T002–T007 in parallel
3. Complete Phase 3 (US1) — T008, then widget tasks in parallel, then T014, T015, T016
4. **STOP AND VALIDATE**: Run the app, navigate to Progress tab, verify skeleton → chip row → chart → stat tiles
5. Proceed to Phase 4 (US2) and Phase 5 (US3) for remaining user stories

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. US1 (T008–T016) → Progress tab functional for exercises with ≥2 sessions → **MVE (Minimum Viable Experience)**
3. US2 (T017–T018) → Per-exercise empty state handled correctly
4. US3 (T019–T020) → Error state + Retry functional
5. Tests (T021–T023) → Regression safety
6. Polish (T024–T026) → Ship-ready

---

## Notes

- **AppColors.danger**: Use `AppColors.danger` (not `AppColors.error` — that token does not exist) for negative delta indicators in `StatTile` (T012) and for `ProgressErrorCard` styling (T019). See research D-05.
- **No Drift writes**: No task may introduce any Drift write. `getAllSessions()` is read-only; all state is computed in memory.
- **No new packages**: All chart rendering via `CustomPainter` (T013). No SVG package, no `intl` package.
- **ProgressEmptyState is not a Bloc state**: It is a UI branch within `ProgressLoaded` (T014, T018). Never introduce a `ProgressEmptyState` Bloc state.
- **No `Cubit`**: `ProgressBloc extends Bloc` only (T008).
- **ErrorCard note**: The generic `core/widgets/error_card.dart` (moved to core in this session) accepts a single `message` parameter. `ProgressErrorCard` (T019) requires a separate `title` + `body` layout — it does NOT delegate to `ErrorCard`.
- **Test files**: Test files are in `forge/test/features/progress/` matching the `forge/lib/features/progress/` source tree.
- **[P] tasks**: Different files, no dependency on other in-progress tasks in the same phase.
- **Mark tasks complete**: Update each task checkbox from `[ ]` to `[X]` immediately after the task is done.
