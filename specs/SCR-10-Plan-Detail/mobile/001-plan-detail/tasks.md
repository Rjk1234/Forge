# Tasks: Plan Detail (SCR-10)

**Input**: Design documents from `specs/SCR-10-Plan-Detail/mobile/001-plan-detail/`

**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ui-contracts.md ✅, quickstart.md ✅

**Tests**: Included — Bloc unit tests and widget tests per constitution XI.3 and quickstart.md validation scenarios. Tests use plain `flutter_test` with fake implementations (no `bloc_test`/`mocktail` — not in pubspec.yaml).

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Extract shared widget, fix existing colour deviation, and add SCR-10 string constants. These are prerequisites for all user stories.

- [X] T001 Add SCR-10 string constants (`planDetailStartWorkoutButton`, `planDetailScheduleButton`, `planDetailEditTooltip`, `planDetailDeleteTooltip`, `planDetailBackTooltip`, `planNotAvailableTitle`, `planNotAvailableBody`, `planNotAvailableButton`, `planDetailExercisesSectionLabel`, `planDetailLoadingSemantics`, `exerciseUnavailableName`) to `forge/lib/core/strings/app_strings.dart`
- [X] T002 [P] Extract `_ShimmerBox` from `forge/lib/features/workout_plan/presentation/widgets/plans_skeleton_list.dart` into new public `ShimmerBox` widget at `forge/lib/core/widgets/shimmer_box.dart` — params: `animation: Animation<double>`, `height: double`, `borderRadius: double`, `width: double?`, `widthFraction: double?`; lerps between `AppColors.cardAlt` and `Color(0xFF35342F)`
- [X] T003 [P] Update `forge/lib/features/workout_plan/presentation/widgets/plans_skeleton_list.dart` to import and use `ShimmerBox` from `core/widgets/shimmer_box.dart` in place of the now-removed private `_ShimmerBox` class (T002 must complete first)
- [X] T004 [P] Fix bodyweight badge colour in `forge/lib/features/workout_plan/presentation/widgets/exercise_card.dart`: change `ExerciseType.bodyweight` case from `AppColors.amber` → `AppColors.textMuted` in the type badge colour switch

**Checkpoint**: Shared infrastructure ready — ShimmerBox public, string constants defined, colour fix applied.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Bloc event, state, and Bloc class. No screen can be built until the state machine exists.

**⚠️ CRITICAL**: No user story implementation can begin until this phase is complete.

- [X] T005 Create `forge/lib/features/workout_plan/application/bloc/plan_detail_event.dart` — sealed class `PlanDetailEvent extends Equatable`; single subclass `PlanDetailLoadRequested({required String planId})`
- [X] T006 Create `forge/lib/features/workout_plan/application/bloc/plan_detail_state.dart` — sealed class `PlanDetailState extends Equatable`; subclasses: `PlanDetailInitial`, `PlanDetailLoading`, `PlanDetailLoaded({required WorkoutPlanDetail plan})`, `PlanDetailNotFound({required String message})`
- [X] T007 Create `forge/lib/features/workout_plan/application/bloc/plan_detail_bloc.dart` — `PlanDetailBloc extends Bloc<PlanDetailEvent, PlanDetailState>`; constructor takes `GetWorkoutPlanByIdUseCase`; handler for `PlanDetailLoadRequested`: emit Loading → await use case → fold Left to NotFound / Right to Loaded
- [X] T008 Register `PlanDetailBloc` as `registerFactory` in `forge/lib/app/get_it_setup.dart`, injecting `getIt<GetWorkoutPlanByIdUseCase>()` as the constructor argument

**Checkpoint**: Bloc fully wired in DI — foundation ready for all user story screens.

---

## Phase 3: User Story 1 — View Plan Details (Priority: P1) 🎯 MVP

**Goal**: A user can open any plan and see its name, exercise count, and all exercise target values in a read-only layout.

**Independent Test**: Seed Drift with a plan containing Weighted, Time-based, and Bodyweight exercises → navigate to `/plans/:planId` → verify all field values and type badges render correctly with no interactive controls.

### Tests for User Story 1

- [X] T009 [P] [US1] Create `forge/test/features/workout_plan/application/bloc/plan_detail_bloc_test.dart` — unit tests using plain `flutter_test` with `_FakeRepo implements WorkoutPlanRepository`: cover `PlanDetailLoadRequested` → Initial→Loading→Loaded transition (success path); LoadRequested → Loading→NotFound (not-found path); LoadRequested → Loading→NotFound (exception path); re-load after Loaded emits Loading then Loaded again
- [X] T010 [P] [US1] Create `forge/test/features/workout_plan/presentation/widgets/plan_exercise_detail_card_test.dart` — widget tests for `PlanExerciseDetailCard`: Weighted card shows 4 field boxes in correct layout; Time-based card shows 3 field boxes with Duration formatted as "mm:ss"; Bodyweight card shows 3 field boxes with no Weight; type dot colour correct per type; all text widgets are non-interactive (no `TextEditingController`, no `onTap` callbacks)

### Implementation for User Story 1

- [X] T011 [US1] Create `forge/lib/features/workout_plan/presentation/widgets/plan_exercise_detail_card.dart` — public `StatelessWidget PlanExerciseDetailCard({required PlanExercise exercise})`; header row: 7×7 type dot (colour from `ExerciseType` switch: weighted→`AppColors.cyan`, timeBased→`AppColors.lime`, bodyweight→`AppColors.textMuted`), type label, exercise name; body: `_PlanFieldGrid` with `_PlanFieldBox` cells; Weighted: row1 (Sets+Reps+Weight) + row2 full-width (Rest); TimeBased: single row (Sets+Duration+Rest); Bodyweight: single row (Sets+Reps+Rest); value formatting from data-model.md rules (weight→"N kg", rest→"Ns", duration→"mm:ss"); all strings from `AppStrings.*`; all colours from `AppColors.*`/`theme.colorScheme`
- [X] T012 [US1] Create `forge/lib/features/workout_plan/presentation/screens/plan_detail_screen.dart` — `StatefulWidget PlanDetailScreen({required String planId})`; `initState` dispatches `PlanDetailLoadRequested(planId: planId)`; `BlocBuilder` renders: `PlanDetailLoading` or `PlanDetailInitial` → call `_buildLoading()`; `PlanDetailLoaded` → call `_buildLoaded(state.plan)`; `PlanDetailNotFound` → call `_buildNotFound()`; `_buildLoaded` renders: `CustomScrollView` with fixed `SliverAppBar` (back chevron left, edit+delete icons right), sliver title block (plan name + "$n exercises"), sliver section label "EXERCISES", `SliverList` of `PlanExerciseDetailCard` widgets, persistent footer `SafeArea` column (Schedule secondary button + Start Workout primary button); "Start Workout" disabled when `plan.exercises.isEmpty`; stub navigation handlers `_onEdit`, `_onDelete`, `_onStartWorkout`, `_onSchedule`, `_onBack` (implement with `context.pop()` only for now — navigation wired in US2); all strings from `AppStrings.*`
- [X] T013 [US1] Update `forge/lib/config/routes/app_routes.dart` — replace `PlaceholderTabScreen` at `/plans/:planId` with `BlocProvider(create: (_) => getIt<PlanDetailBloc>(), child: PlanDetailScreen(planId: planId))` where `planId = state.pathParameters['planId']!`

**Checkpoint**: US1 complete — opening any plan displays its full exercise detail in a read-only layout.

---

## Phase 4: User Story 2 — Navigate to Downstream Actions (Priority: P2)

**Goal**: Edit, Delete, Schedule, and Start Workout buttons each navigate to the correct route; returning from Edit or Delete re-reads the plan so displayed data is always current.

**Independent Test**: Tap each of the four action controls, verify correct route is pushed with correct `planId`; return from a simulated edit and confirm the plan detail re-dispatches `PlanDetailLoadRequested`.

### Tests for User Story 2

- [X] T014 [US2] Extend `forge/test/features/workout_plan/presentation/screens/plan_detail_screen_test.dart` — widget tests for navigation: tapping Edit icon calls `context.push('/plans/$planId/edit')` and after pop re-dispatches `PlanDetailLoadRequested`; tapping Delete icon calls `context.push('/plans/$planId/delete')` and after pop re-dispatches; tapping Schedule calls `context.push('/plans/$planId/schedule')`; tapping Start Workout calls `context.push('/plans/$planId/start')`; Start Workout button is disabled when plan has 0 exercises; back chevron calls `context.pop()`; GoRouter test harness provides stub routes for all destinations

### Implementation for User Story 2

- [X] T015 [US2] Wire navigation handlers in `forge/lib/features/workout_plan/presentation/screens/plan_detail_screen.dart`: `_onEdit`: `await context.push('/plans/$planId/edit')` then `if (context.mounted) context.read<PlanDetailBloc>().add(PlanDetailLoadRequested(planId: planId))`; `_onDelete`: `await context.push('/plans/$planId/delete')` then same refresh dispatch; `_onStartWorkout`: `context.push('/plans/$planId/start')`; `_onSchedule`: `context.push('/plans/$planId/schedule')`; `_onBack`: `context.pop()`; guard all post-await `context` usages with `if (!context.mounted) return`

**Checkpoint**: US2 complete — all four action buttons navigate correctly and refresh-on-return is wired.

---

## Phase 5: User Story 3 — Loading Skeleton (Priority: P3)

**Goal**: A shimmer skeleton appears immediately during the database read; the skeleton back chevron is live; the skeleton is replaced without a blank flash when data arrives.

**Independent Test**: Hold the Bloc in `PlanDetailLoading` state → verify skeleton renders with shimmer animation, correct placeholder count, and live back chevron; advance to Loaded → verify skeleton replaced by populated layout.

### Tests for User Story 3

- [X] T016 [US3] Extend `forge/test/features/workout_plan/presentation/screens/plan_detail_screen_test.dart` — skeleton tests: seed Bloc with `PlanDetailLoading` state → verify skeleton widget appears; verify back chevron is a live `IconButton` (not a shimmer placeholder); verify shimmer exercise card placeholders are present; advance to `PlanDetailLoaded` → verify skeleton replaced by plan name text

### Implementation for User Story 3

- [X] T017 [US3] Create `forge/lib/features/workout_plan/presentation/widgets/plan_detail_skeleton.dart` — `StatefulWidget PlanDetailSkeleton`; owns `AnimationController` (300ms, repeating); disposes it in `dispose()`; `AnimatedBuilder` drives `ShimmerBox` instances from `core/widgets/shimmer_box.dart`; layout mirrors populated screen: app bar area with live back chevron + two shimmer icon boxes; two shimmer title lines (70% width + 35% width); three shimmer exercise card placeholders (each: two shimmer lines); two shimmer footer button placeholders; all colours via `AppColors.*`
- [X] T018 [US3] Wire `_buildLoading()` in `forge/lib/features/workout_plan/presentation/screens/plan_detail_screen.dart` to return `PlanDetailSkeleton()` instead of the temporary placeholder (if any was used in T012)

**Checkpoint**: US3 complete — loading skeleton shows correctly and transitions smoothly to populated view.

---

## Phase 6: User Story 4 — Error and Not-Found State (Priority: P4)

**Goal**: When the plan cannot be loaded (missing or read failure), the user sees a clear error card with a single "Back to Plans" recovery action.

**Independent Test**: Navigate with a non-existent `planId` → verify `PlanDetailNotFound` state produces the error card; verify "Back to Plans" button navigates to SCR-08; verify no Edit/Delete buttons are visible in this state.

### Tests for User Story 4

- [X] T019 [US4] Extend `forge/test/features/workout_plan/presentation/screens/plan_detail_screen_test.dart` — not-found tests: seed Bloc with `PlanDetailNotFound(message: '...')` → verify `PlanNotAvailableCard` is rendered; verify "Back to Plans" button is present; verify Edit and Delete icon buttons are absent; tapping "Back to Plans" calls `context.pop()`

### Implementation for User Story 4

- [X] T020 [US4] Create `forge/lib/features/workout_plan/presentation/widgets/plan_not_available_card.dart` — public `StatelessWidget PlanNotAvailableCard({required VoidCallback onBackToPlans})`; renders: X-in-circle `Icon` in `AppColors.danger` colour; title text `AppStrings.planNotAvailableTitle` using `theme.textTheme` style; body text `AppStrings.planNotAvailableBody`; "Back to Plans" `ElevatedButton` calling `onBackToPlans`; card background `AppColors.dangerBorder` or equivalent dark danger surface from theme; all colours from `AppColors.*`
- [X] T021 [US4] Wire `_buildNotFound()` in `forge/lib/features/workout_plan/presentation/screens/plan_detail_screen.dart` to return a `Scaffold` with app bar (back chevron only — no edit/delete icons) and body containing `PlanNotAvailableCard(onBackToPlans: _onBack)`

**Checkpoint**: US4 complete — error state renders correctly with sole recovery action.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Static analysis, formatting, full test pass, and quickstart validation.

- [X] T022 [P] Run `dart format .` from `forge/` and fix any formatting issues introduced by SCR-10 files
- [X] T023 [P] Run `flutter analyze` from `forge/` and resolve every warning or error introduced by SCR-10 changes — zero new issues allowed
- [X] T024 Run `flutter test test/features/workout_plan/` from `forge/` and confirm all SCR-10 tests pass with no regressions in existing tests
- [ ] T025 Manually validate VS-01 through VS-15 from `quickstart.md` on iOS Simulator or Android Emulator — mark each scenario pass/fail

**Checkpoint**: SCR-10 complete — all tests pass, analyzer clean, quickstart validated.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately. T002 must complete before T003.
- **Foundational (Phase 2)**: Depends on Phase 1 completion (T001 required for AppStrings in Bloc layer). T005→T006→T007→T008 must run in order.
- **US1 (Phase 3)**: Depends on Foundational completion. T011 can start after T001 (AppStrings), T002/T003 (ShimmerBox not needed until US3). T009, T010 [P] can start after Foundational.
- **US2 (Phase 4)**: Depends on US1 — extends `PlanDetailScreen` (T012) and its tests (T014 extends T009's test file).
- **US3 (Phase 5)**: Depends on US1 — T017 requires ShimmerBox (T002/T003); T018 modifies `PlanDetailScreen` (T012).
- **US4 (Phase 6)**: Depends on US1 — T021 modifies `PlanDetailScreen` (T012).
- **Polish (Phase 7)**: Depends on all user story phases complete.

### Within Each User Story

- Tests [P] can be written before or in parallel with implementation — tests will fail (red) until implementation is complete
- US1: T009, T010 [P] → T011, T012 [P] → T013
- US2: T014 → T015
- US3: T016 → T017 → T018
- US4: T019 → T020 → T021

### Parallel Opportunities

- T002 and T004 can run in parallel (different files)
- T003 and T004 can run in parallel (different files, but T003 depends on T002)
- T009 and T010 can run in parallel (different test files)
- T011 and T012 can run in parallel (different source files, no dependency between widget and screen until T013 wires them)
- T022 and T023 can run in parallel (format vs. analyze — both read-only checks)

---

## Parallel Example: User Story 1

```bash
# Tests (write first — expect them to fail):
T009: plan_detail_bloc_test.dart
T010: plan_exercise_detail_card_test.dart

# Implementation (can run in parallel — different files):
T011: plan_exercise_detail_card.dart
T012: plan_detail_screen.dart

# After T011 and T012 complete:
T013: app_routes.dart (wires the route)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Open any plan — verify exercise layout with all 3 exercise types
5. Proceed to US2 once US1 is verified

### Incremental Delivery

1. Setup + Foundational → Bloc registered in DI
2. US1 → Plan detail readable (MVP)
3. US2 → Navigation to Edit/Delete/Schedule/Start works
4. US3 → Skeleton polish complete
5. US4 → Error resilience complete
6. Polish → Analyzer clean, tests green

---

## Notes

- [P] tasks = different files, no shared-state dependencies
- All colours MUST come from `AppColors.*` / `theme.colorScheme` — no hardcoded hex in widgets
- All user-facing strings MUST use `AppStrings.*` — no hardcoded string literals in widgets
- `PlanDetailBloc` uses `registerFactory` — fresh instance per screen open
- Tests use plain `flutter_test` fake implementations — `bloc_test`/`mocktail` are NOT in pubspec.yaml
- After each async gap (`await context.push(...)`), guard with `if (!context.mounted) return`
- `ShimmerBox` extraction (T002/T003) must not change any visual behaviour of `PlansSkeletonList`
- Run `dart format` and `flutter analyze` before marking T022/T023 complete — zero new warnings allowed
