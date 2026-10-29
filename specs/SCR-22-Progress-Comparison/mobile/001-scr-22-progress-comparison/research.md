# Research: SCR-22 Progress Comparison

**Date**: 2026-09-23 | **Branch**: `001-scr-22-progress-comparison`

---

## D-01 — Feature Ownership: `features/progress/` (new feature)

**Decision**: SCR-22 lives in a new `features/progress/` feature directory (not inside `workout_session/`).

**Rationale**: Progress Comparison is a distinct business concept from session recording. It has its own domain entities (`ExerciseProgressData`, `ExerciseMetrics`), its own Bloc, and its own screen. Clean Feature-First architecture (Constitution §I) requires it to own `domain/`, `application/`, `data/`, and `presentation/` layers. Its data dependency on `WorkoutSessionRepository` is injected via GetIt — a legitimate cross-feature domain contract dependency, not a layer violation.

**Alternatives considered**: Placing it under `workout_session/` — rejected because progress comparison is a separate bounded context; coupling it to session recording would make future changes (e.g., adding plan-level comparison) harder to isolate.

---

## D-02 — Data Read: `getAllSessions()` (existing method)

**Decision**: SCR-22 uses `WorkoutSessionRepository.getAllSessions()` — the existing repository method. No new repository method, no new table, no new data source.

**Rationale**: `getAllSessions()` returns all `WorkoutSession` records, which is exactly what SCR-22 needs to compute per-exercise progress across history. The method already exists and is registered in GetIt.

**WorkoutSession entity fields confirmed**:
- `sessionId: String`, `planId: String`, `planName: String`, `completedAt: DateTime`, `sessionDurationSec: int`, `sessionExercises: List<SessionExercise>`
- **No `startedAt` field** — SCR-16 prerequisite not yet merged. SCR-22 does not use start time so this has no impact.

**SessionExercise fields confirmed**: `exerciseId: String`, `exerciseName: String`, `type: ExerciseType`, `actualSets: List<ActualSet>`

---

## D-03 — ExerciseType Enum Values

**Decision**: Use `ExerciseType.weighted`, `ExerciseType.timeBased`, `ExerciseType.bodyweight`.

**Confirmed from source** (`core/enums/exercise_type.dart`): three values exactly — `.weighted`, `.timeBased`, `.bodyweight` (stored as text). No `.time` alias exists.

---

## D-04 — go_router Integration: Replace Branch 4 Placeholder

**Decision**: SCR-22 replaces the `PlaceholderTabScreen(label: 'Progress')` on Branch 4 (`/progress`) of the existing `StatefulShellRoute`. The `BlocProvider<ProgressBloc>` wraps the screen in the route builder for that branch so the Bloc persists across tab switches.

**Confirmed from source** (`config/routes/app_routes.dart`): Branch 4 is `_progressNavigatorKey` with path `/progress`. Currently `PlaceholderTabScreen`. No child routes are needed for SCR-22 (root-tab-only screen).

**Note**: SCR-20 (WorkoutHistory) and SCR-21 (WorkoutHistoryDetail) have also not been implemented — Branch 3 is also a placeholder. SCR-22 is fully independent of SCR-20/21.

---

## D-05 — Error Color: `AppColors.danger`

**Decision**: Negative delta indicators and error states MUST use `AppColors.danger` (0xFFFF6B6B). The spec's reference to `AppColors.error / colorScheme.error` is incorrect — no such token exists.

**Confirmed from source** (`core/theme/app_colors.dart`): The danger semantic is `AppColors.danger` (red text/icons), `AppColors.dangerBg` (error card fill), `AppColors.dangerBorder` (error card border), `AppColors.onDanger` (text on danger fill). The error card for SCR-22's error state uses `dangerBg` + `dangerBorder` + `danger` (icon/text) — same pattern as `ErrorCard` in `home/presentation/`.

**Impact on spec**: FR-011 references `colorScheme.error` — implementation MUST use `AppColors.danger` instead.

---

## D-06 — Shimmer/Skeleton: Reuse `ShimmerBox` from `core/widgets/`

**Decision**: SCR-22's skeleton (`ProgressSkeleton`) uses the existing `ShimmerBox` widget from `core/widgets/shimmer_box.dart`. The skeleton is a `StatefulWidget` that owns an `AnimationController` and passes its `Animation<double>` to each `ShimmerBox`.

**Confirmed pattern** (from `PlanDetailSkeleton`, `PlansSkeletonList`):
- Skeleton widget is a `StatefulWidget` with `AnimationController` (repeating, 1000ms)
- Passes `animation` to `ShimmerBox(animation: ..., height: ..., borderRadius: ..., widthFraction: ...)`
- **No translate-based shimmer** — the app rolls its own lerp-based animation; no `shimmer` package

**SCR-22 skeleton layout**: 3 chip-width placeholders (height 32px, borderRadius 20) + 1 chart placeholder (height 150px, widthFraction 1.0, borderRadius 12) + 3 stat tile placeholders (height 64px, widthFraction 0.3 each).

---

## D-07 — Error Card: Feature-Specific `ProgressErrorCard`

**Decision**: SCR-22 creates its own `ProgressErrorCard` in `progress/presentation/widgets/`. It cannot reuse `home/presentation/widgets/error_card.dart` — cross-feature presentation imports are prohibited (Constitution §I.5).

**`ErrorCard`** (now at `core/widgets/error_card.dart`): `message: String` + `onRetry: VoidCallback`. This widget was moved to `core/` in the same session as SCR-22 planning (from `home/presentation/widgets/`). It can now be imported cross-feature.

**Why `ProgressErrorCard` is still feature-specific**: The generic `ErrorCard` accepts a single `message` string. SCR-22's error state requires a separate `title` ("Couldn't load your progress") and `body` ("Your workout history is unaffected.") — two distinct text nodes with different typography. Delegating to `ErrorCard` would require either passing concatenated text (poor UX) or extending the generic widget (CLAUDE.md rule 20 — don't extend when a small feature widget serves the purpose). `ProgressErrorCard` is a lightweight feature-specific wrapper.

**SCR-22 `ProgressErrorCard`**: renders `dangerBg` card + `AppStrings.progressErrorTitle` (title text) + `AppStrings.progressErrorBody` (body text) + Retry `OutlinedButton`.

---

## D-08 — Chart Rendering: `CustomPainter` (no SVG package)

**Decision**: The line chart is rendered using Flutter's `CustomPainter` API inside a `CustomPaint` widget. No SVG package is introduced (ADR-030). The canvas logical size is 320 × 150 units, scaled to fill card width via `LayoutBuilder`.

**Rationale**: `CustomPainter` provides full control over the SVG-equivalent path, circles, and grid lines described in the design spec without any new dependency. Performance is excellent for ≤12 data points.

**Rendering approach**:
- `ProgressChartPainter` extends `CustomPainter`
- Takes `List<ProgressDataPoint>` and `Color` (lime)
- Draws 3 horizontal grid lines at `y * totalHeight / 4` intervals (scaled to canvas)
- Normalizes metric values to the y range [top-padding .. bottom-padding]
- Draws trend line as `Path` connecting all points
- Draws regular dots as `circle(r: 4, fill: lime)` and latest dot as `circle(r: 5, fill: white, stroke: lime, strokeWidth: 2)`

---

## D-09 — `ExerciseProgressData` Computation Scope

**Decision**: `GetExerciseProgressDataUseCase` computes all `ExerciseProgressData` in memory from the full session list returned by `getAllSessions()`. No incremental or lazy computation.

**Computation steps** (executed once per `ProgressLoadRequested` event):
1. Call `getAllSessions()` → `List<WorkoutSession>`
2. Group sessions by `exerciseName` (string identity — same name = same exercise)
3. For each exercise group: sort sessions chronologically by `completedAt`
4. Filter to sessions that include the exercise with ≥1 non-skipped `ActualSet` (per spec Assumptions — "valid sessions")
5. Apply chip ordering: Group 1 (≥2 valid sessions) newest-first, Group 2 (<2 valid sessions) newest-first, alpha tie-break
6. For chart: take the most recent 12 valid sessions → `sessionDataPoints`
7. For stat tiles: `latestMetrics` from session[last], `deltaMetrics` = session[last] − session[last-1]
8. Return `List<ExerciseProgressData>` in chip order

---

## D-10 — Bloc Architecture: `ProgressBloc` (2 events, 4 states)

**Decision**: `ProgressBloc` has 2 events and 4 states.

**Events**:
- `ProgressLoadRequested` — triggers full data load (initial + Retry)
- `ProgressExerciseSelected(exerciseName: String)` — chip tap; transitions `ProgressLoaded` → new `ProgressLoaded` with updated `selectedExerciseName`; no Drift read triggered

**States**:
- `ProgressInitial` — skeleton (identical to Loading)
- `ProgressLoading` — skeleton
- `ProgressLoaded(exercises: List<ExerciseProgressData>, selectedExerciseName: String)` — chip row visible; whether Main or Empty is a UI derivation from `exercises.firstWhere(name == selectedExerciseName).totalValidSessions >= 2`
- `ProgressError` — error card; no chip row

**Key invariant**: The chip row is visible only in `ProgressLoaded`. It is hidden in `ProgressInitial`, `ProgressLoading`, and `ProgressError`. Chip tap only fires when Bloc is in `ProgressLoaded` — no guard needed at Bloc level.

---

## D-11 — DI Registration

**Decision**: `GetExerciseProgressDataUseCase` → `registerLazySingleton`; `ProgressBloc` → `registerFactory`.

**GetIt context**: `WorkoutSessionRepository` is already registered as `LazySingleton`. The use-case takes it as a constructor parameter. The Bloc takes the use-case as a constructor parameter.

```
getIt.registerLazySingleton<GetExerciseProgressDataUseCase>(
  () => GetExerciseProgressDataUseCase(getIt<WorkoutSessionRepository>()),
);
getIt.registerFactory<ProgressBloc>(
  () => ProgressBloc(getProgressData: getIt<GetExerciseProgressDataUseCase>()),
);
```

---

## D-12 — AppStrings New Constants

14 new constants needed (no existing strings cover SCR-22 copy):

| Constant | Value |
|---|---|
| `progressErrorTitle` | `"Couldn't load your progress"` |
| `progressErrorBody` | `"Your workout history is unaffected."` |
| `progressEmptyTitle` | `"Not enough data yet"` |
| `progressEmptySubtitle` | `"Complete a few more workouts to see your progress."` |
| `progressLatestSessionLabel` | `"Latest Session"` |
| `progressTopWeight` | `"TOP WEIGHT"` |
| `progressBestReps` | `"BEST REPS"` |
| `progressVolume` | `"VOLUME"` |
| `progressTotalReps` | `"TOTAL REPS"` |
| `progressTotalSets` | `"TOTAL SETS"` |
| `progressBestDuration` | `"BEST DURATION"` |
| `progressTotalTime` | `"TOTAL TIME"` |
| `progressSets` | `"SETS"` |
| `progressRetryButton` | `"Retry"` *(check if `retryButton` already exists; reuse if so)* |

---

## D-13 — No New Tables

**Decision**: SCR-22 introduces zero new tables, zero schema changes in `AppDatabase`, and requires no `build_runner` run.

**Rationale**: `ExerciseProgressData` and `ExerciseMetrics` are computed-only entities that exist purely in memory during the screen's lifecycle. They are never persisted to Drift.
