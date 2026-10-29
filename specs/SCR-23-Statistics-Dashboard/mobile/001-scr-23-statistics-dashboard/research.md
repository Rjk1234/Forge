# Research: SCR-23 Statistics Dashboard

**Date**: 2026-09-23 | **Branch**: `001-scr-23-statistics-dashboard`

---

## D-01 — Feature Ownership: `features/stats/` (new feature)

**Decision**: SCR-23 lives in a new `features/stats/` feature directory.

**Rationale**: Statistics Dashboard is a distinct business concept. It has its own domain entities (`StatsData`, `ExerciseStatRow`), its own Bloc, and its own screen. Clean Feature-First architecture (Constitution §I) requires it to own `domain/`, `application/`, and `presentation/` layers. Its data dependency on `WorkoutSessionRepository` is injected via GetIt — a legitimate cross-feature domain contract dependency.

**No `data/` layer created**: SCR-23 reads via the existing `WorkoutSessionRepository` (owned by `workout_session/`). No new table, no new data source. Omitting `features/stats/data/` is correct per CLAUDE.md rule 6 (no speculative abstractions).

---

## D-02 — Data Read: `WorkoutSessionRepository.getAllSessions()` (existing)

**Decision**: SCR-23 uses the existing `WorkoutSessionRepository.getAllSessions()` method. No new repository method, no new table, no `build_runner` run.

**Confirmed from source** (`get_it_setup.dart` line 94): `WorkoutSessionRepository` registered as `LazySingleton`. Already available in GetIt.

**WorkoutSession fields used**: `completedAt: DateTime?`, `sessionDurationSec: int`, `sessionExercises: List<SessionExercise>`

**SessionExercise fields used**: `exerciseName: String`, `type: ExerciseType`, `actualSets: List<ActualSet>`

**ActualSet fields used**: `weight: double`, `repetitions: int`, `durationSec: int`, `skipped: bool?` (absent in pre-SCR-16 data → treat as non-skipped)

---

## D-03 — Route: Branch 5 at `/stats` (existing placeholder)

**Decision**: SCR-23 replaces `PlaceholderTabScreen(label: 'Stats')` on Branch 5 (`/stats`) of the existing `StatefulShellRoute`. The `BlocProvider<StatsBloc>` wraps `StatsScreen` in the route builder.

**Confirmed from source** (`config/routes/app_routes.dart`): `RoutePaths.stats = '/stats'`; Branch 5 uses `_statsNavigatorKey`. Currently `PlaceholderTabScreen`.

**SCR-24 child route**: A placeholder child route `'/stats/personal-bests'` must be added to Branch 5 so that `context.push('/stats/personal-bests')` from the Personal Bests link does not 404. SCR-24 implementation is deferred; the child route registers a `PlaceholderTabScreen` or a minimal stub that accepts a back-pop.

**New path constant**: `RoutePaths.statsPersonalBests = '/stats/personal-bests'` added alongside existing constants.

---

## D-04 — Type Dot Colors: Design-Spec Convention (lime=weighted, cyan=timeBased)

**Decision**: The 8×8 `type-dot` in the exercise breakdown uses:
- `ExerciseType.weighted` → `AppColors.lime`
- `ExerciseType.timeBased` → `AppColors.cyan`
- `ExerciseType.bodyweight` → `AppColors.textMuted`

**Discrepancy noted**: The existing `_TypeBadge` widget (`workout_plan/presentation/widgets/exercise_card.dart`) uses the opposite mapping: `weighted → AppColors.cyan`, `timeBased → AppColors.lime`. The `AppColors.cyan` comment "weighted exercise type badge ONLY" reflects this current badge usage.

**Rationale for divergence**: The design spec (§8 Component & Design System Mapping) states the 8×8 type dot convention is "established in SCR-09/10/15/16/19/21/22" with lime=weighted/cyan=time. Type *dots* and type *text badges* are different UI components with different readability requirements (dots are non-text, badges are text chips). The design intent is deliberate. The dot convention is followed here.

**No AppColors change needed for this**: `AppColors.lime`, `AppColors.cyan`, and `AppColors.textMuted` already exist.

---

## D-05 — New Color Token: `AppColors.successFill` (#1E2A12)

**Decision**: Add `static const Color successFill = Color(0xFF1E2A12);` to `AppColors`.

**Rationale**: The Personal Bests link row (`pb-icon-wrap`) uses background `#1e2a12`. The design spec notes this as `color.successFill` "established in SCR-21." However, the token does not exist in `app_colors.dart` — the SCR-21 design spec established the value in design intent but it was never added to AppColors.

**Impact on spec assumption**: The spec Assumption "No new color tokens are introduced by SCR-23" is incorrect. One token is added: `AppColors.successFill`. Using `const Color(0xFF1E2A12)` directly in the widget would violate CLAUDE.md rule 28 ("Never hardcode colors in widgets").

---

## D-06 — Shimmer: `ShimmerBox` (lerp-based, existing `core/widgets/`)

**Decision**: The stats skeleton (`StatsSkeleton`) uses the existing `ShimmerBox` widget from `core/widgets/shimmer_box.dart`. The skeleton is a `StatefulWidget` owning an `AnimationController`.

**Confirmed from source**: `ShimmerBox` lerps between `AppColors.cardAlt` and `AppColors.shimmerDark` driven by `Animation<double>`. Duration: 1000ms (per SCR-21/22 pattern).

**Spec note**: FR-001 says "translate-based shimmer animation" — this is CSS design-spec language. The Flutter implementation uses lerp-based `ShimmerBox`, which achieves the same visual effect.

**Skeleton layout** (4 stat-tile placeholders + 3 exercise-row placeholders):
```
stat-grid: 2×2 Grid
  ShimmerBox(height: 88, borderRadius: 14) ×4
exercise-row placeholders:
  ShimmerBox(height: 56, borderRadius: 14, widthFraction: 1.0) ×3
```

---

## D-07 — AppStrings: New Constants (18 new, 1 reused)

**Reused**: `AppStrings.retryButton = 'Retry'` ✅ already exists.

**New constants needed** (18):

| Constant | Value |
|---|---|
| `statsTitle` | `'Stats'` |
| `statsWorkoutsCompleted` | `'Workouts Completed'` |
| `statsTotalVolume` | `'Total Volume'` |
| `statsTotalDuration` | `'Total Duration'` |
| `statsAvgDuration` | `'Avg. Duration'` |
| `statsExerciseBreakdownLabel` | `'EXERCISE BREAKDOWN'` |
| `statsRecordsLabel` | `'RECORDS'` |
| `statsPersonalBestsTitle` | `'Personal Bests'` |
| `statsPersonalBestsSub` | `'Your all-time top performances'` |
| `statsEmptyTitle` | `'No stats yet'` |
| `statsEmptySub` | `'Complete a workout to start building your statistics.'` |
| `statsEmptyCta` | `'Start a Workout'` |
| `statsErrorTitle` | `"Couldn't load your stats"` |
| `statsErrorBody` | `"Something went wrong calculating your statistics.\nYour workout history is unaffected."` |
| `statsBestWeight` | `'Best weight'` |
| `statsBestTime` | `'Best time'` |
| `statsBestReps` | `'Best reps'` |
| `statsSessionsSuffix` | `'sessions'` |

`statsSessionsSuffix` is composed with a count at runtime: `'${row.sessionCount} ${AppStrings.statsSessionsSuffix}'`.

---

## D-08 — Bloc Architecture: `StatsBloc` (1 event, 4 states)

**Decision**: `StatsBloc` has 1 meaningful event (triggering load/retry) and 4 states.

**Events**:
- `StatsLoadRequested` — triggers full data load. Used for initial load and Retry (no separate RetryRequested event needed — same computation path).

**States**:
- `StatsInitial` — renders skeleton identically to `StatsLoading` (FR-020)
- `StatsLoading` — skeleton shown; shimmer active
- `StatsLoaded({required StatsData stats, required List<ExerciseStatRow> exercises})` — both empty and populated states are UI derivations of this state:
  - `stats.totalWorkoutsCompleted == 0` → Empty UI (dimmed tiles + prompt)
  - `stats.totalWorkoutsCompleted > 0` → Main UI (real tiles + breakdown + PB link)
- `StatsError` — error card + Retry

**No chip-selection event**: Unlike SCR-22, the Stats screen has no user-driven data selection. The single `StatsLoadRequested` event is sufficient.

---

## D-09 — `GetStatisticsUseCase` Computation

**Decision**: A single use case computes both aggregate stats and the exercise breakdown in one pass over the session list.

**Algorithm**:
1. `getAllSessions()` → `List<WorkoutSession>`
2. Filter to valid sessions: `completedAt != null` AND `sessionExercises` contains ≥1 exercise with ≥1 non-skipped `ActualSet` (treat absent `skipped` as false)
3. Compute `StatsData`:
   - `totalWorkoutsCompleted` = valid sessions count
   - `totalVolumeKg` = Σ (weight × repetitions) for non-skipped sets where `type == weighted` across all valid sessions, rounded to nearest int
   - `totalDurationSec` = Σ `sessionDurationSec` across valid sessions
   - `avgDurationSec` = `totalDurationSec ~/ totalWorkoutsCompleted` (null when 0 valid sessions)
4. Compute exercise breakdown:
   - Group non-skipped actual sets by `exerciseName`
   - For each exercise group, collect only the sessions where that exercise had ≥1 non-skipped set → `sessionCount`
   - Compute `bestValue` per type: weighted → max weight; timeBased → max durationSec; bodyweight → max repetitions
5. Sort by `sessionCount` descending, alpha tie-break
6. Return `(StatsData, List<ExerciseStatRow>)`

---

## D-10 — DI Registration

```dart
getIt.registerLazySingleton<GetStatisticsUseCase>(
  () => GetStatisticsUseCase(getIt<WorkoutSessionRepository>()),
);
getIt.registerFactory<StatsBloc>(
  () => StatsBloc(getStatistics: getIt<GetStatisticsUseCase>()),
);
```

---

## D-11 — Error Card: Feature-Specific `StatsErrorCard`

**Decision**: SCR-23 creates its own `StatsErrorCard` in `stats/presentation/widgets/`.

**Rationale**: `core/widgets/error_card.dart` accepts a single `message: String`. SCR-23's error state requires a separate `title` ("Couldn't load your stats") and `body` (two-line text) — two distinct text nodes with different typography. Same reasoning as `ProgressErrorCard` in SCR-22.

**Visual**: `dangerBg` card + `dangerBorder` + `AppColors.danger` alert-triangle icon + title + body + `AppStrings.retryButton` ElevatedButton.

---

## D-12 — No New Tables

**Decision**: SCR-23 introduces zero new tables, zero schema changes in `AppDatabase`, and requires no `build_runner` run.

`StatsData` and `ExerciseStatRow` are computed-only entities that exist purely in memory during the screen's lifecycle. They are never persisted.

---

## D-13 — `_retrying` Guard on `StatsScreen`

**Decision**: `StatsScreen` is a `StatefulWidget` with `bool _retrying = false`. When the user taps Retry, `_retrying` is set to `true` (prevents double-dispatch). The flag is reset when the Bloc emits any non-Loading state. Same pattern as SCR-22's `ProgressScreen`.
