# Data Model: SCR-22 Progress Comparison

**Date**: 2026-09-23 | **Branch**: `001-scr-22-progress-comparison`

---

## Existing Entities (read-only — no changes)

### WorkoutSession
Source: `forge/lib/features/workout_session/domain/entities/workout_session.dart`

| Field | Type | SCR-22 Usage |
|---|---|---|
| `sessionId` | `String` | Identity; not directly displayed |
| `planId` | `String` | Not used in SCR-22 |
| `planName` | `String` | Not used in SCR-22 |
| `completedAt` | `DateTime` | Chip ordering (newest-first within group) |
| `sessionDurationSec` | `int` | Not used in SCR-22 |
| `sessionExercises` | `List<SessionExercise>` | Primary input for progress computation |

### SessionExercise
Source: `forge/lib/features/workout_session/domain/entities/session_exercise.dart`

| Field | Type | SCR-22 Usage |
|---|---|---|
| `exerciseId` | `String` | Not used directly (name is identity key) |
| `exerciseName` | `String` | Chip label; identity key for grouping across sessions |
| `type` | `ExerciseType` | Determines stat tile variant and chart metric |
| `actualSets` | `List<ActualSet>` | Source for all metric calculations |

### ActualSet
Source: `forge/lib/features/workout_session/domain/entities/actual_set.dart` (inferred)

| Field | Type | SCR-22 Usage |
|---|---|---|
| `repetitions` | `int?` | Used for bestReps, totalReps (weighted, bodyweight) |
| `weight` | `double?` | Used for topWeight, volume (weighted only) |
| `durationSec` | `int?` | Used for bestDuration, totalTime (timeBased only) |
| `skipped` | `bool?` | If null → treat as `false`; skipped sets excluded from all metrics |

### ExerciseType Enum
Source: `forge/lib/core/enums/exercise_type.dart`

| Value | Stored text | SCR-22 Stat Tiles |
|---|---|---|
| `ExerciseType.weighted` | 0 | TOP WEIGHT / BEST REPS / VOLUME |
| `ExerciseType.timeBased` | 1 | BEST DURATION / TOTAL TIME / SETS |
| `ExerciseType.bodyweight` | 2 | TOTAL SETS / BEST REPS / TOTAL REPS |

---

## New Computed Entities (not persisted — in-memory only)

### ExerciseProgressData
Computed per unique `exerciseName` across all sessions. Lives in `forge/lib/features/progress/domain/entities/exercise_progress_data.dart`.

| Field | Type | Description |
|---|---|---|
| `exerciseName` | `String` | Identity key; chip label |
| `type` | `ExerciseType` | Determines stat tile variant |
| `totalValidSessions` | `int` | Count of valid sessions (≥1 non-skipped set); drives chip group + 2-session threshold |
| `sessionDataPoints` | `List<ProgressDataPoint>` | ≤12 most recent valid sessions; chart data |
| `latestMetrics` | `ExerciseMetrics` | Stat tile values from most recent valid session |
| `deltaMetrics` | `ExerciseMetrics` | Change vs second-most-recent valid session (present only if `totalValidSessions >= 2`) |

**Null safety**: `deltaMetrics` is present whenever `totalValidSessions >= 2`. The Bloc only emits Main UI when `totalValidSessions >= 2`, so stat tiles can always access `deltaMetrics` without null check when in Main state.

### ProgressDataPoint
One entry per session in the chart. Lives inline or in `exercise_progress_data.dart`.

| Field | Type | Description |
|---|---|---|
| `sessionIndex` | `int` | 1-based index within the 12-session window (x-axis position) |
| `metricValue` | `double` | Y-axis value: max weight (weighted) / max durationSec (timeBased) / max reps (bodyweight) |
| `isLatest` | `bool` | True for the most recent session (rendered as larger dot) |

**Metric value derivation**:
- `weighted`: `max(weight)` across non-skipped sets with `weight != null && weight > 0`
- `timeBased`: `max(durationSec)` across non-skipped sets
- `bodyweight`: `max(repetitions)` across non-skipped sets with `repetitions != null`

### ExerciseMetrics (sealed class)
Stat tile values, typed by exercise category. Lives in `forge/lib/features/progress/domain/entities/exercise_metrics.dart`.

```dart
sealed class ExerciseMetrics extends Equatable {
  const ExerciseMetrics();
}

class WeightedMetrics extends ExerciseMetrics {
  final double topWeight;    // max(weight) across non-skipped sets
  final int bestReps;        // max(reps) across non-skipped sets
  final double volume;       // Σ(weight × reps) across non-skipped sets, rounded
}

class TimedMetrics extends ExerciseMetrics {
  final int bestDuration;    // max(durationSec) across non-skipped sets
  final int totalTime;       // Σ(durationSec) across non-skipped sets
  final int setCount;        // count of non-skipped sets
}

class BodyweightMetrics extends ExerciseMetrics {
  final int totalSets;       // count of non-skipped sets
  final int bestReps;        // max(reps) across non-skipped sets
  final int totalReps;       // Σ(reps) across non-skipped sets
}
```

**Delta semantics**: `deltaMetrics` stores the absolute difference (latest - previous) using the same typed class. `0.0` is zero delta; negative values are regressions (rendered in `AppColors.danger`).

---

## State Model (Bloc)

### Bloc State Derivation

```
getAllSessions() → List<WorkoutSession>
    │
    ▼
Group by exerciseName → Map<String, List<WorkoutSession>>
    │
    ▼ (per exercise)
Filter to valid sessions (≥1 non-skipped set) → sort by completedAt desc
    │
    ├── totalValidSessions = count
    ├── sessionDataPoints = take(12).reversed (ascending chronological for chart)
    ├── latestMetrics = computeMetrics(sessions[0])
    └── deltaMetrics = computeMetrics(sessions[0]) - computeMetrics(sessions[1])  [if totalValidSessions >= 2]
    │
    ▼
Sort all ExerciseProgressData by chip order (D-02 chip ordering rule)
    │
    ▼
ProgressLoaded(
  exercises: List<ExerciseProgressData>,
  selectedExerciseName: exercises.first.exerciseName
)
```

### Chip Ordering Rule (FR-005)

1. **Group 1**: `totalValidSessions >= 2`, sorted by `completedAt` of most recent valid session, descending (newest first)
2. **Group 2**: `totalValidSessions < 2`, same sort
3. **Tie-break**: alphabetical by `exerciseName` (for exercises last logged in same session)
4. Pre-selected chip: `exercises.first` (Group 1 first chip if any Group 1 chips exist)

---

## Stat Tile Display Mapping

| ExerciseType | Tile 1 | Tile 2 | Tile 3 |
|---|---|---|---|
| `weighted` | TOP WEIGHT (`topWeight` kg) | BEST REPS (`bestReps`) | VOLUME (`volume` kg) |
| `timeBased` | BEST DURATION (`bestDuration` as `m:ss` / `h:mm:ss`) | TOTAL TIME (`totalTime` as `m:ss` / `h:mm:ss`) | SETS (`setCount`) |
| `bodyweight` | TOTAL SETS (`totalSets`) | BEST REPS (`bestReps`) | TOTAL REPS (`totalReps`) |

**Delta color**: positive / zero → `AppColors.lime`; negative → `AppColors.danger`
**Delta prefix**: `+` for positive, `-` for negative, `0` for zero
**Delta format**: same unit as the value tile (kg, reps, s, etc.)

---

## Bloc State Hierarchy (summary)

```
ProgressInitial   → renders ProgressSkeleton
ProgressLoading   → renders ProgressSkeleton
ProgressLoaded(exercises, selectedExerciseName)
  → renders ExerciseChipRow (always)
  → if selectedExercise.totalValidSessions >= 2:
      renders ProgressChartCard + "Latest Session" label + StatTile × 3
  → else:
      renders ProgressEmptyState
ProgressError     → renders ProgressErrorCard (no chip row)
```
