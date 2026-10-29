# Tasks: SCR-21 Workout History Detail

**Feature Branch**: `001-scr-21-workout-history-detail`

**Input**: `specs/SCR-21-Workout-History-Detail/mobile/001-scr-21-workout-history-detail/`

**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ ✅ | quickstart.md ✅

**User Stories**:
- US1 (P1): View Full Workout Detail — happy path (skeleton → Success)
- US2 (P2): Error State with Retry
- US3 (P3): Historical Data Integrity — route + DI confirming snapshot-only reads

**Key note (D-01)**: Navigation passes `sessionId` (String) as go_router `extra` — not the full `WorkoutSession`. See research.md.

---

## Phase 1: Setup

**Purpose**: Centralise all display strings before any widget or Bloc references them.

- [X] T001 Add 12 SCR-21 AppStrings constants under a `// SCR-21: Workout History Detail` comment block in `forge/lib/core/strings/app_strings.dart` — `detailScreenTitle`, `detailErrorTitle`, `detailErrorBody`, `detailRetryLabel`, `detailSectionPerformance`, `detailStatDurationLabel`, `detailStatExercisesLabel`, `detailStatSetsLoggedLabel`, `detailStatMinSuffix`, `detailSetCountSuffix`, `detailBodyweightRepsSuffix`, `detailSetSkippedLabel` (exact values in data-model.md §5)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Bloc event, state, use-case, and Bloc implementation. No widget or screen work can begin until T005 is complete (all downstream files import these types).

**⚠️ CRITICAL**: T002/T003/T004 are parallel. T005 MUST wait for all three.

- [X] T002 [P] Create `sealed class WorkoutHistoryDetailEvent extends Equatable` with single subclass `WorkoutHistoryDetailLoadRequested({required String sessionId})` in `forge/lib/features/workout_session/application/bloc/workout_history_detail_event.dart` (shape in data-model.md §3)
- [X] T003 [P] Create `sealed class WorkoutHistoryDetailState extends Equatable` with four subclasses — `WorkoutHistoryDetailInitial`, `WorkoutHistoryDetailLoading`, `WorkoutHistoryDetailSuccess({required WorkoutSession session})`, `WorkoutHistoryDetailError({required String message})` — in `forge/lib/features/workout_session/application/bloc/workout_history_detail_state.dart` (shapes in data-model.md §4; NO Empty state — FR-017)
- [X] T004 [P] Create `GetWorkoutHistoryDetailUseCase` that calls `WorkoutSessionRepository.getSessionById(sessionId)` and maps `Right(null)` → `Left(CacheException(...))` (D-02); return type `Future<Either<AppException, WorkoutSession>>` in `forge/lib/features/workout_session/application/use_cases/get_workout_history_detail_use_case.dart` (exact code shape in data-model.md §2)
- [X] T005 Create `WorkoutHistoryDetailBloc extends Bloc<WorkoutHistoryDetailEvent, WorkoutHistoryDetailState>` with initial state `WorkoutHistoryDetailInitial`; `_onLoadRequested` emits Loading then awaits use-case and emits Success or Error; in the Left handler call `LoggingService.logError(exception, stackTrace)` BEFORE emitting Error state (Constitution §X.1 — MUST NOT use `print`/`debugPrint`); Error state message uses `AppStrings.detailErrorTitle` (raw `AppException.message` MUST NOT be surfaced to UI) in `forge/lib/features/workout_session/application/bloc/workout_history_detail_bloc.dart` (full contract in contracts/workout-history-detail-bloc.md)

**Checkpoint**: Run `flutter analyze forge/lib/features/workout_session/application/` — zero errors before proceeding.

---

## Phase 3: User Story 1 — View Full Workout Detail (Priority: P1) 🎯 MVP

**Goal**: Skeleton appears on push; Drift read resolves to full detail showing workout name, formatted date/time, three-stat row, "Performance" label, and per-exercise cards with type-appropriate set pills.

**Independent Test**: Seed one `WorkoutSession` with two exercises (one `weighted`, one `timeBased`). Push the route with the sessionId extra. Verify: skeleton visible → Success state with hero name, `"Mon, Sep 7, 2026 · 6:42 PM"` format, correct stat counts, lime/cyan type dots, set pills in correct format. Quickstart Scenario 1.

### Widgets

- [X] T006 [P] [US1] Create `DetailSkeleton extends StatefulWidget` — owns `AnimationController(duration: 1400ms, vsync: this)` with `repeat()`; translate-based shimmer using `Matrix4.translationValues` over `AppColors.cardAlt` skeleton shapes with sweep `const Color(0x0FFFFFFF)` (file-private constant, NOT `AppColors`); skeleton layout: one wide hero block (~80px high), one row of three stat-box placeholders, then three exercise-card placeholder blocks — see `specs/SCR-21-Workout-History-Detail/design/spec.md` for exact dimensions; disposes controller in `dispose()` in `forge/lib/features/workout_session/presentation/widgets/detail_skeleton.dart` (D-09 shape in research.md)
- [X] T007 [P] [US1] Create `SessionStatBox extends StatelessWidget` — accepts `final String label` and `final String value`; renders label in uppercase `AppColors.textDim` 10px/w700 and value in `AppColors.white` 18px/w800 inside a bordered `AppColors.card`-background box in `forge/lib/features/workout_session/presentation/widgets/session_stat_box.dart` (data-model.md §8)
- [X] T008 [P] [US1] Create `SetPill extends StatelessWidget` — accepts `final ActualSet set` and `final ExerciseType type`; `switch` on `type` to render: weighted → `'${set.repetitions}×${set.weight}kg'`; bodyweight → `'${set.repetitions}${AppStrings.detailBodyweightRepsSuffix}'`; timeBased → `MM:SS` (upgrade to `H:MM:SS` when `durationSec >= 3600`); skipped guard (treat absent `skipped` as false — SCR-16 compatibility) → `AppStrings.detailSetSkippedLabel` with `TextDecoration.lineThrough`, `AppColors.textDim`, `FontWeight.w600` in `forge/lib/features/workout_session/presentation/widgets/set_pill.dart` (D-05: use `ExerciseType.timeBased` NOT `ExerciseType.time`)
- [X] T009 [US1] Create `SessionExerciseCard extends StatelessWidget` — accepts `final SessionExercise exercise`; renders: type-dot (6px circle: `ExerciseType.weighted`→`AppColors.lime`, `.timeBased`→`AppColors.cyan`, `.bodyweight`→`AppColors.textDim`), `exercise.exerciseName`, set count tag (`'${exercise.actualSets.length}${AppStrings.detailSetCountSuffix}'`), and a `Wrap` of `SetPill(set: s, type: exercise.type)` for each `s` in `exercise.actualSets` in `forge/lib/features/workout_session/presentation/widgets/session_exercise_card.dart` (D-08; NOT named `ExerciseCard` — collision with workout_plan widget)

### Screen — Happy Path

- [X] T010 [US1] Create `WorkoutHistoryDetailScreen extends StatefulWidget` with `final String sessionId`; `initState` dispatches `WorkoutHistoryDetailLoadRequested(sessionId: widget.sessionId)`; `BlocBuilder` switch: `Initial|Loading` → `DetailSkeleton()`, `Success` → scrollable `CustomScrollView` with fixed `SliverAppBar` (title `AppStrings.detailScreenTitle`, back arrow, no edit/delete controls), hero section (planName in large text, formatted date/time using pure Dart `_dowAbbr`/`_monthAbbr` file-private arrays per D-04 — title-case DOW e.g. `'Mon'`, abbreviated month e.g. `'Sep'`, no leading zero on day, 12-hour AM/PM, middle dot U+00B7, fallback `session.startedAt ?? session.completedAt`), stat row with three `SessionStatBox` widgets (duration: `(sessionDurationSec/60).round()` + `AppStrings.detailStatMinSuffix`; exercises: `sessionExercises.length`; sets logged: sum of `actualSets.length` across all exercises), `AppStrings.detailSectionPerformance` label, then `ListView` of `SessionExerciseCard` for each exercise; appbar stays fixed during content scroll; `Error` branch → (covered by T011) in `forge/lib/features/workout_session/presentation/screens/workout_history_detail_screen.dart`

**Checkpoint**: Seed one session; confirm skeleton → full detail renders with correct data. Quickstart Scenario 1 + Scenario 6 (zero exercises).

---

## Phase 4: User Story 2 — Error State with Retry (Priority: P2)

**Goal**: Drift read failure produces Error card with title, body, and Retry button. Double-tap Retry is debounced. Retry re-enters Loading skeleton and retries the read.

**Independent Test**: Provide mock `WorkoutSessionRepository` returning `Left(CacheException())`. Push route. Observe error card (title, body, Retry button). Tap Retry → skeleton → (on second mock success) Success state. Quickstart Scenarios 3 + 4.

- [X] T011 [US2] Add Error state branch to `WorkoutHistoryDetailScreen`'s `BlocBuilder` switch: renders error card (background `AppColors.dangerBg`, border `AppColors.dangerBorder`, icon `AppColors.danger`, title `AppStrings.detailErrorTitle`, body `AppStrings.detailErrorBody`); add local `bool _retrying = false` field; Retry `ElevatedButton` with `AppStrings.detailRetryLabel`: `onPressed` guards `if (_retrying) return;` then `setState(() => _retrying = true)` then dispatches `WorkoutHistoryDetailLoadRequested(sessionId: widget.sessionId)`; add `BlocListener` that resets `_retrying = false` when state transitions away from Loading (to Success or Error) in `forge/lib/features/workout_session/presentation/screens/workout_history_detail_screen.dart`

**Checkpoint**: Quickstart Scenarios 3 + 4 pass. Raw exception text never appears in UI.

---

## Phase 5: User Story 3 — Route + DI + Data Integrity (Priority: P3)

**Goal**: Screen is reachable via `go_router`; DI is wired. Historical data reads only from `workout_sessions` table — confirmed by the architecture (no `workout_plans`/`exercises` reads anywhere in the Bloc/UseCase).

**Independent Test**: Navigate from history branch → detail screen using a real sessionId; confirm back navigation returns to SCR-20 without re-fetch. Quickstart Scenario 5 + 7.

- [X] T012 [P] [US3] Add `static const String workoutHistoryDetail = '/history/detail'` to `RoutePaths` class and add nested `GoRoute(path: 'detail', builder: (context, state) { final sessionId = state.extra as String; return BlocProvider(create: (_) => getIt<WorkoutHistoryDetailBloc>(), child: WorkoutHistoryDetailScreen(sessionId: sessionId)); })` under the history branch root route in `forge/lib/config/routes/app_routes.dart` (D-10; push nav, NOT a tab root)
- [X] T013 [P] [US3] Register `GetWorkoutHistoryDetailUseCase` as `registerLazySingleton` and `WorkoutHistoryDetailBloc` as `registerFactory` in `forge/lib/app/get_it_setup.dart` (DI code in contracts/workout-history-detail-bloc.md §DI Registration)

**Checkpoint**: Hot-restart; navigate to history tab → tap any seeded session row → detail screen pushes. Back navigation returns to history list. Quickstart Scenario 7.

---

## Phase 6: Tests

**Purpose**: Unit and widget test coverage for all three user stories per quickstart.md checklists.

- [X] T014 [P] Create `GetWorkoutHistoryDetailUseCase` unit tests (3 scenarios): Right(session)→Right(session), Right(null)→Left(CacheException), Left(exception)→Left(exception) in `forge/test/features/workout_session/application/use_cases/get_workout_history_detail_use_case_test.dart`
- [X] T015 [P] Create `WorkoutHistoryDetailBloc` tests (7 scenarios): initial state is `WorkoutHistoryDetailInitial`; `LoadRequested` emits `[Loading, ...]`; Right(session)→Success; Left(exception)→Error; retry re-enters Loading; Error message uses `AppStrings.detailErrorTitle` not raw exception; assert no `saveSession` or `deleteSession` method is called on the mock repository in any scenario (FR-015 / SC-005) in `forge/test/features/workout_session/application/bloc/workout_history_detail_bloc_test.dart`
- [X] T016 [P] Create `WorkoutHistoryDetailScreen` widget tests (10 scenarios): Initial→skeleton; Loading→skeleton; Success→hero name+stat row+"Performance"+exercise cards; Error→error title+body+Retry; Retry tap→`LoadRequested` event; weighted pill format; bodyweight pill format; timeBased pill format; skipped pill shows "Skipped" with strikethrough; back navigation (`context.pop()`) does not dispatch any event on a `WorkoutHistoryBloc` mock (FR-013) in `forge/test/features/workout_session/presentation/screens/workout_history_detail_screen_test.dart`

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T017 Run `dart format .` and `flutter analyze` from `forge/` root; fix every warning or error introduced by SCR-21 changes (no pre-existing warnings may be introduced)
- [X] T018 [P] Verify `AppColors.cyan` comment in `forge/lib/core/theme/app_colors.dart` is NOT relied on — confirm `SessionExerciseCard` uses `AppColors.cyan` for `ExerciseType.timeBased` dot regardless of the incorrect comment (D-06); add an inline comment next to the usage noting the comment in app_colors.dart is incorrect (cleanup deferred)
- [ ] T019 Walk through all 7 quickstart.md scenarios on simulator; confirm no regressions in SCR-20 (history list) after route additions; **explicitly include SC-006**: seed a session with 20 exercises × 15 sets each, open the detail screen, scroll the full list, and confirm smooth render with no jank or ANR (Quickstart PR-02)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: T001 (AppStrings) must exist; T002/T003/T004 are parallel; T005 waits for all three
- **Phase 3 (US1 Widgets)**: T001 ✅, T005 ✅ — T006/T007/T008 are parallel; T009 waits for T008; T010 waits for T005+T006+T007+T009
- **Phase 4 (US2 Error)**: T010 ✅ — T011 extends same screen file
- **Phase 5 (US3 Route+DI)**: T010 ✅, T011 ✅, T004 ✅, T005 ✅ — T012 and T013 are parallel with each other
- **Phase 6 (Tests)**: All prior phases ✅ — T014/T015/T016 are parallel
- **Phase 7 (Polish)**: All prior phases ✅

### User Story Dependencies

- **US1 (P1)**: Foundational (Phase 2) + Setup (Phase 1) → MVP deliverable
- **US2 (P2)**: US1 complete → Error card added to same screen file
- **US3 (P3)**: US1+US2 complete → Route + DI wires screen into the app

### Within Each Phase

- Models/events/states → Bloc → Widgets → Screen → Route/DI → Tests
- T009 (SessionExerciseCard) depends on T008 (SetPill)
- T010 (Screen happy path) depends on T005+T006+T007+T009
- T011 (Error branch) extends T010's screen file — run sequentially after T010
- T013 (GetIt) depends on T004+T005 — parallel with T012

---

## Parallel Execution Examples

### Phase 2 (Foundational)

```
Parallel:   T002 (event)   T003 (state)   T004 (use-case)
Sequential: T005 (bloc) — after all three above complete
```

### Phase 3 (US1 Widgets)

```
Parallel:   T006 (DetailSkeleton)   T007 (SessionStatBox)   T008 (SetPill)
Sequential: T009 (SessionExerciseCard) — after T008
Sequential: T010 (Screen happy path) — after T005+T006+T007+T009
```

### Phase 5 (US3 Route+DI)

```
Parallel:   T012 (app_routes.dart)   T013 (get_it_setup.dart)
```

### Phase 6 (Tests)

```
Parallel:   T014 (use-case tests)   T015 (bloc tests)   T016 (widget tests)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002→T005)
3. Complete Phase 3 widgets (T006–T009) and screen happy path (T010)
4. Wire route + DI (T012, T013 — minimum needed to reach the screen)
5. **STOP and VALIDATE**: Seed a session; navigate from SCR-20; confirm skeleton → full detail

### Incremental Delivery

1. Phase 1+2+3+route/DI → US1 visible on device
2. Phase 4 (T011) → US2 error card live; test with mock repository
3. Phase 6 (T014–T016) → test coverage confirmed
4. Phase 7 (T017–T019) → zero analyzer warnings; all quickstart scenarios verified

---

## Notes

- `[P]` tasks affect different files with no dependencies on each other — safe to implement concurrently
- `[Story]` label maps each task to the user story it delivers value for
- T008 uses `ExerciseType.timeBased` (NOT `ExerciseType.time`) — confirmed from source (D-05)
- T010 date arrays (`_dowAbbr`, `_monthAbbr`) are **file-private** constants in the screen file — title-case, not the UPPERCASE variant used by SCR-20 (D-04)
- Shimmer sweep color `Color(0x0FFFFFFF)` in T006 is a **file-private** `const`, not an AppColors token (D-09)
- T011's `_retrying` flag lives on the screen's `State` — NOT on the Bloc (contracts/workout-history-detail-bloc.md)
- T012 route is a push route nested under history branch — NOT a `StatefulShellBranch` tab root
- Run `flutter analyze` after every phase; never proceed with analyzer errors
