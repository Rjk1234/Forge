# Data Model: SCR-23 Statistics Dashboard

**Source spec**: [spec.md](./spec.md) §5 (Key Entities)

All entities in this feature are **computed-in-memory**. None are persisted to Drift; none require a schema change or `build_runner`.

---

## Existing Entities Used (read-only, no changes)

| Entity | Owner feature | Fields consumed |
|--------|--------------|-----------------|
| `WorkoutSession` | `workout_session/domain/` | `completedAt: DateTime?`, `sessionDurationSec: int`, `sessionExercises: List<SessionExercise>` |
| `SessionExercise` | `workout_session/domain/` | `exerciseName: String`, `type: ExerciseType`, `actualSets: List<ActualSet>` |
| `ActualSet` | `workout_session/domain/` | `weight: double`, `repetitions: int`, `durationSec: int`, `skipped: bool?` |
| `ExerciseType` | `workout_plan/domain/` | `.weighted`, `.timeBased`, `.bodyweight` (stored as text) |

**Valid session rule** (FR-003): `completedAt != null` AND the session contains ≥1 `ActualSet` where `skipped != true`. Applied uniformly to all four aggregate stats and the exercise breakdown.

---

## New Entities (domain layer — pure Dart)

### `StatsData`

**File**: `forge/lib/features/stats/domain/entities/stats_data.dart`

Holds the four aggregate totals computed from all valid sessions.

```dart
class StatsData {
  final int totalWorkoutsCompleted;   // count of valid sessions
  final int totalVolumeKg;            // Σ weight×reps for non-skipped weighted sets, rounded
  final int totalDurationSec;         // Σ sessionDurationSec across valid sessions
  final int? avgDurationSec;          // totalDurationSec ~/ totalWorkoutsCompleted; null when 0

  const StatsData({
    required this.totalWorkoutsCompleted,
    required this.totalVolumeKg,
    required this.totalDurationSec,
    required this.avgDurationSec,
  });
}
```

**Derivations used in UI**:

| UI element | Derived from |
|------------|-------------|
| Workouts Completed tile | `totalWorkoutsCompleted` |
| Total Volume tile | `totalVolumeKg` formatted as `'{N}kg'` |
| Total Duration tile | `totalDurationSec` formatted as `'{N}h {N}m'` (or `'{N}m'` if < 60 min) |
| Avg. Duration tile | `avgDurationSec` formatted same as duration; `'—'` when null |
| Empty state guard | `totalWorkoutsCompleted == 0` |

---

### `ExerciseStatRow`

**File**: `forge/lib/features/stats/domain/entities/exercise_stat_row.dart`

One row in the exercise breakdown. Carries the exercise identity, usage count, and single best-value highlight.

```dart
class ExerciseStatRow {
  final String exerciseName;
  final ExerciseType type;
  final int sessionCount;       // sessions where this exercise had ≥1 non-skipped set
  final double bestWeight;      // max weight across non-skipped weighted sets; 0 for other types
  final int bestReps;           // max reps across non-skipped bodyweight sets; 0 for other types
  final int bestDurationSec;    // max durationSec across non-skipped time-based sets; 0 for other types

  const ExerciseStatRow({
    required this.exerciseName,
    required this.type,
    required this.sessionCount,
    required this.bestWeight,
    required this.bestReps,
    required this.bestDurationSec,
  });
}
```

**Best-value display rules** (FR-015, from spec Clarification OQ-4):

| `type` | Right-column label | Right-column value |
|--------|--------------------|--------------------|
| `weighted` | `AppStrings.statsBestWeight` | `'{N}kg'` where N = `bestWeight.toStringAsFixed(bestWeight % 1 == 0 ? 0 : 1)` |
| `timeBased` | `AppStrings.statsBestTime` | `'{N}m {N}s'` or `'{N}s'` derived from `bestDurationSec` |
| `bodyweight` | `AppStrings.statsBestReps` | `'$bestReps'` |

**Ordering** (FR-016): Sort by `sessionCount` descending; alpha tie-break on `exerciseName`.

**Type dot color** (D-04 — design-spec convention):

| `type` | Dot color |
|--------|-----------|
| `weighted` | `AppColors.lime` |
| `timeBased` | `AppColors.cyan` |
| `bodyweight` | `AppColors.textMuted` |

---

## Computation Summary

`GetStatisticsUseCase` produces `(StatsData, List<ExerciseStatRow>)` in a single pass:

1. `getAllSessions()` → raw list
2. Filter to valid sessions (completedAt non-null + ≥1 non-skipped set)
3. Accumulate `totalWorkoutsCompleted`, `totalVolumeKg`, `totalDurationSec` over valid sessions
4. Group exercises by name; accumulate `sessionCount` and `bestWeight`/`bestReps`/`bestDurationSec` per type
5. Derive `avgDurationSec`
6. Sort exercise rows
7. Return both objects
