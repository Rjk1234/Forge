# Tasks: SCR-24 Personal Bests

**Input**: Design documents from `specs/SCR-24-Personal-Bests/mobile/001-scr-24-personal-bests/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/pb-bloc.md](contracts/pb-bloc.md), [quickstart.md](quickstart.md)

**User Stories**:
- US1 (P1): View Personal Bests List — populated main state
- US2 (P2): Handle Empty State — no qualifying sets
- US3 (P3): Error State with Retry — Drift/computation failure

**Format**: `[ID] [P?] [Story?] Description with file path`
- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Maps to user story (US1, US2, US3)
- Setup/Foundational/Polish phases have no story label

---

## Phase 1: Setup

**Purpose**: Add AppStrings constants and FormatUtils utility needed by all phases.

- [X] T001 Add 10 `AppStrings.pb*` string constants (`pbScreenTitle`, `pbEmptyTitle`, `pbEmptySubtitle`, `pbErrorTitle`, `pbErrorBody`, `pbRetryButton`, `pbBadgeWeightLabel`, `pbBadgeTimeLabel`, `pbBadgeRepsLabel`, `pbDatePrefix`) and `static const List<String> shortMonthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']` to `forge/lib/core/strings/app_strings.dart`
- [X] T002 [P] Create `FormatUtils` class with three static methods — `formatWeight(double kg)` returning `"{N} kg"` (int if whole, 1dp otherwise), `formatMmSs(int totalSeconds)` delegating to `DurationMmSsInputFormatter.formatFromSeconds`, `formatPbDate(DateTime date)` returning `"Set {Mon} {D}, {YYYY}"` using `AppStrings.shortMonthNames` — in `forge/lib/core/utils/format_utils.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entity, Bloc contracts, use case logic, DI, and route registration — MUST be complete before any user story phase begins.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T003 Create `PersonalBestRecord` entity (`exerciseName: String`, `type: ExerciseType`, `bestWeight: double?`, `bestDurationSec: int?`, `bestReps: int?`, `bestDate: DateTime` — pure Dart, no equatable) in `forge/lib/features/personal_bests/domain/entities/personal_best_record.dart`
- [X] T004 [P] Create `PbEvent` sealed class (`PbLoadRequested`) in `forge/lib/features/personal_bests/application/bloc/pb_event.dart`
- [X] T005 [P] Create `PbState` sealed class (`PbInitial`, `PbLoading`, `PbLoaded({required List<PersonalBestRecord> records})`, `PbError`) in `forge/lib/features/personal_bests/application/bloc/pb_state.dart`
- [X] T006 Implement `GetPersonalBestsUseCase` with private `_compute` and `_PbAccumulator` helper — filters valid sessions (`completedAt != null`), iterates non-skipped sets (`skipped != true`), accumulates per `(exerciseName, type)` best value with date tie-break (most-recent wins), sorts alphabetically ascending — in `forge/lib/features/personal_bests/application/use_cases/get_personal_bests_use_case.dart`
- [X] T007 Implement `PbBloc extends Bloc<PbEvent, PbState>` — constructor `({required GetPersonalBestsUseCase getPersonalBests})`, `super(PbInitial())`, `on<PbLoadRequested>` emits `PbLoading` then `PbLoaded` or `PbError` on catch — in `forge/lib/features/personal_bests/application/bloc/pb_bloc.dart`
- [X] T008 Register `GetPersonalBestsUseCase` as `registerLazySingleton` and `PbBloc` as `registerFactory` (after `WorkoutSessionRepository` registration block) in `forge/lib/app/get_it_setup.dart`
- [X] T009 [P] Add `static const String personalBests = 'personal-bests'` to `RoutePaths` and add child `GoRoute(path: RoutePaths.personalBests, builder: (context, state) => BlocProvider(create: (_) => getIt<PbBloc>()..add(PbLoadRequested()), child: const PersonalBestsScreen()))` inside the stats branch `GoRoute`'s `routes:` list in `forge/lib/config/routes/app_routes.dart`

**Checkpoint**: Foundation ready — domain entity, Bloc, use case, DI, and route are complete. User story phases can now begin.

---

## Phase 3: User Story 1 — View Personal Bests List (Priority: P1) 🎯 MVP

**Goal**: Users navigating from SCR-23 see a scrollable, alphabetically-sorted list of per-exercise personal best cards with correct metric values, dates, type dots, and badges. Loading skeleton appears immediately on push.

**Independent Test**: Seed ≥2 valid `WorkoutSession` records with exercises across weighted + bodyweight types. Navigate to `/stats/personal-bests`. Verify: (a) skeleton flashes immediately, (b) list resolves with correct per-type metric values, (c) date matches the session containing the PB set, (d) list is alphabetical, (e) cards are not tappable, (f) back arrow returns to SCR-23, (g) no bottom nav bar visible. See [quickstart.md VS-01 through VS-04](quickstart.md).

### Tests

- [X] T010 [P] [US1] Unit-test `GetPersonalBestsUseCase` — test: empty sessions → empty list, all-skipped sets → empty list, single exercise PB, multi-exercise alphabetical sort, tie-break (same value → more recent date), pre-SCR-16 null skipped → treated as non-skipped, `AppException` from repository → throws — in `forge/test/features/personal_bests/application/use_cases/get_personal_bests_use_case_test.dart`
- [X] T011 [P] [US1] Unit-test `PbBloc` — test state transitions: initial=`PbInitial`, `PbLoadRequested` emits `[PbLoading, PbLoaded]` on success, `[PbLoading, PbError]` on use-case throw, second `PbLoadRequested` from `PbError` resets to `PbLoading` — in `forge/test/features/personal_bests/application/bloc/pb_bloc_test.dart`

### Implementation

- [X] T012 [P] [US1] Implement `PbTypeDot` widget — `Container` 8×8, `BoxShape.circle`, color switch: `ExerciseType.weighted → AppColors.lime`, `ExerciseType.timeBased → AppColors.cyan`, `ExerciseType.bodyweight → AppColors.textMuted` — in `forge/lib/features/personal_bests/presentation/widgets/pb_type_dot.dart`
- [X] T013 [P] [US1] Implement `PbBadge` widget — `Container` with `AppColors.cardAlt` fill, `AppColors.border` border, `border-radius:10`, `padding:EdgeInsets.symmetric(horizontal:12, vertical:8)`; `Column` of metric value text (`14px/weight-800/white`) and badge label text (`9px/textDim/uppercase/letterSpacing:0.03em`) — in `forge/lib/features/personal_bests/presentation/widgets/pb_badge.dart`
- [X] T014 [P] [US1] Implement `PbSkeleton` widget — `StatefulWidget` owning `AnimationController` (repeat, `vsync: this`); renders 5 shimmer rows each with `ShimmerBox` dot placeholder, two `ShimmerBox` text lines, and `ShimmerBox` badge placeholder — in `forge/lib/features/personal_bests/presentation/widgets/pb_skeleton.dart`
- [X] T015 [US1] Implement `PbCard` widget — `Row` with `PbTypeDot`, `Expanded` column of exercise name (`14px/weight-700/white/overflow-ellipsis`) + date line (`11px/textDim`; `FormatUtils.formatPbDate(record.bestDate)` — format: `AppStrings.pbDatePrefix + '{Mon} {D}, {YYYY}'`), and `PbBadge` (metric value via `FormatUtils.*`, badge label via `AppStrings.pbBadge*Label` per type) — in `forge/lib/features/personal_bests/presentation/widgets/pb_card.dart`
- [X] T016 [US1] Implement `PersonalBestsScreen` as `StatefulWidget` — owns `bool _retrying = false`; appbar with `AppStrings.pbScreenTitle` (`18px/weight-800`) and back arrow (22×22/white/stroke-width:2/`M15 18l-6-6 6-6`); `BlocListener` (`listenWhen: (_, s) => s is! PbLoading`, `listener: setState(() => _retrying = false)`); `BlocBuilder` switching on `PbInitial/PbLoading → PbSkeleton`, `PbLoaded → _buildLoadedBody(records)`, `PbError → placeholder Container`; `_buildLoadedBody` renders `ListView.builder` of `PbCard` when records is non-empty — in `forge/lib/features/personal_bests/presentation/screens/personal_bests_screen.dart`

**Checkpoint**: US1 complete — skeleton, populated list, correct values, back navigation, no bottom nav bar all verified.

---

## Phase 4: User Story 2 — Handle Empty State (Priority: P2)

**Goal**: When no qualifying sets exist, a centred informational empty state appears (no CTA button).

**Independent Test**: Clear all `WorkoutSession` records (or seed sessions where all sets have `skipped=true`). Navigate to SCR-24. Verify: skeleton resolves to empty state with trophy icon, "No personal bests yet" heading, subtitle copy, and NO CTA button. Back arrow functional, no bottom nav bar. See [quickstart.md VS-05](quickstart.md).

### Implementation

- [X] T017 [P] [US2] Implement `PbEmptyState` widget — centred `Column` with `Semantics(excludeSemantics: true, child: Icon(trophy, 52×52, textDim))`, `Text(AppStrings.pbEmptyTitle, 16px/weight-800)`, `Text(AppStrings.pbEmptySubtitle, 13px/textMuted)`; NO CTA button — in `forge/lib/features/personal_bests/presentation/widgets/pb_empty_state.dart`
- [X] T018 [US2] Update `PersonalBestsScreen._buildLoadedBody` to branch on `records.isEmpty → PbEmptyState()` (centred) vs `records.isNotEmpty → ListView.builder` of `PbCard` — in `forge/lib/features/personal_bests/presentation/screens/personal_bests_screen.dart`

**Checkpoint**: US1 + US2 complete — populated list and empty state both verified.

---

## Phase 5: User Story 3 — Error State with Retry (Priority: P3)

**Goal**: Drift read or computation failure shows an error card with Retry; Retry is debounced against double-tap.

**Independent Test**: Inject a read failure into `GetPersonalBestsUseCase`. Navigate to SCR-24. Observe error card with correct copy, icon, and Retry button. Tap Retry — skeleton reappears. Double-tap Retry — only one cycle fires. See [quickstart.md VS-06 and VS-07](quickstart.md).

### Implementation

- [X] T019 [P] [US3] Implement `PbErrorCard` widget — centred `Container` (`AppColors.dangerBg` fill, `AppColors.dangerBorder` border, `border-radius:12`); `Column` with `Icon(alert-triangle, 40×40, AppColors.danger)`, `Text(AppStrings.pbErrorTitle, 16px/weight-800, text-align:center)`, `Text(AppStrings.pbErrorBody, 13px/textMuted, line-height:1.5, text-align:center)`, `ElevatedButton(AppStrings.pbRetryButton, minimumSize:Size(double.infinity, 44), onPressed: onRetry)` — in `forge/lib/features/personal_bests/presentation/widgets/pb_error_card.dart`
- [X] T020 [US3] Update `PersonalBestsScreen` — add `_onRetry(BuildContext context)` method (`if (_retrying) return; setState(() => _retrying = true); context.read<PbBloc>().add(PbLoadRequested())`) and replace the placeholder error `Container` in `BlocBuilder` with `PbErrorCard(onRetry: () => _onRetry(context))` — in `forge/lib/features/personal_bests/presentation/screens/personal_bests_screen.dart`

**Checkpoint**: All three user stories complete — populated list, empty state, and error+retry all verified.

---

## Phase 6: Polish & Validation

**Purpose**: Code quality gates and manual validation.

- [X] T021 Run `dart format .` from `forge/` directory and confirm zero formatting changes remain
- [X] T022 Run `flutter analyze` from `forge/` directory and resolve every new warning or error introduced by this feature
- [X] T023 Run `flutter test` from `forge/` directory and confirm all tests pass (including T010 and T011)
- [ ] T024 Manual validation per [quickstart.md](quickstart.md) — execute VS-01 through VS-10 and confirm all expected outcomes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately; T001 and T002 can run in parallel
- **Phase 2 (Foundational)**: Requires Phase 1 complete — BLOCKS all user story phases
  - T004 and T005 can run in parallel (once T003 is done)
  - T006 requires T003 (entity), T004, T005
  - T007 requires T006 (use case)
  - T008 requires T007; T009 can run in parallel with T008 (different files)
- **Phase 3 (US1)**: Requires Phase 2 complete
  - T010, T011, T012, T013, T014 can all run in parallel (different files)
  - T015 requires T012 and T013 (PbCard uses PbTypeDot + PbBadge)
  - T016 requires T014 and T015 (PersonalBestsScreen uses PbSkeleton + PbCard)
- **Phase 4 (US2)**: Requires Phase 2 complete; T017 in parallel with US1 tasks; T018 requires T016 and T017
- **Phase 5 (US3)**: Requires Phase 2 complete; T019 in parallel with US1/US2 tasks; T020 requires T016 and T019
- **Phase 6 (Polish)**: Requires all user story phases complete

### PersonalBestsScreen File — Sequential Updates

`personal_bests_screen.dart` is modified across three phases. These edits MUST remain sequential:
- **T016** (US1) — creates the file with Loading/Initial skeleton + _buildLoadedBody for non-empty list
- **T018** (US2) — adds empty-records branch in _buildLoadedBody
- **T020** (US3) — adds _onRetry + PbErrorCard in error branch

### User Story Dependencies

- **US1 (P1)**: No dependency on US2 or US3
- **US2 (P2)**: T018 requires T016 (same file); T017 widget is independent
- **US3 (P3)**: T020 requires T016 (same file); T019 widget is independent

### Within Phase 3 (US1) — Parallel Opportunities

```
# Start immediately (parallel):
T010 — use case unit tests
T011 — Bloc unit tests
T012 — PbTypeDot widget
T013 — PbBadge widget
T014 — PbSkeleton widget

# After T012 + T013 complete:
T015 — PbCard widget

# After T014 + T015 complete:
T016 — PersonalBestsScreen scaffold
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T009) — CRITICAL BLOCKER
3. Complete Phase 3: User Story 1 (T010–T016)
4. **STOP and VALIDATE**: Navigate to `/stats/personal-bests` with seeded data; verify VS-01 through VS-04
5. Skeleton, populated list, correct PB values, alphabetical order, no-tap cards, back navigation, no bottom nav bar — all verified

### Incremental Delivery

1. Setup + Foundational → domain entity, Bloc, use case, DI, route registered
2. US1 → fully working populated list state (MVF: minimum viable feature)
3. US2 → empty state (graceful degradation for new users)
4. US3 → error + retry (resilience)
5. Polish → clean, tested, analyzed

---

## Notes

- T001 and T002 are in different files and can run in parallel
- T004 and T005 are in different files and can run in parallel; both require T003 to be complete first
- `FormatUtils.formatMmSs` delegates to `DurationMmSsInputFormatter.formatFromSeconds` (existing static method in `forge/lib/core/formatters/duration_mm_ss_input_formatter.dart`) — do not duplicate the MM:SS logic
- `_formatWeight` exists as a private method in `plan_exercise_detail_card.dart` — do NOT import it; `FormatUtils.formatWeight` is the shared version
- `PersonalBestRecord` is pure Dart — no `equatable`, no Flutter imports in domain layer
- `PbTypeDot` color mapping (lime=weighted, cyan=timeBased) is OPPOSITE to the existing `_TypeDot` in `exercise_list_item.dart` — follow the design spec (FR-006), not the existing widget
- `PbErrorCard` uses `ElevatedButton` with `minimumSize: Size(double.infinity, 44)` — the 44pt minimum satisfies the touch-target assumption noted in spec.md
- No new color tokens needed — all required colors exist in `AppColors`
- No new packages needed — all dependencies already governed (ADR-030)
