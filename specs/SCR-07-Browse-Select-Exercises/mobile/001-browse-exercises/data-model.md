# Data Model: SCR-07 Browse & Select Exercises

**Branch**: `001-browse-exercises` | **Date**: 2026-09-17

---

## Existing Storage Records (Read-Only for SCR-07)

### ExerciseRecord (existing)

Stored in `exercises` table. Keyed by `id` (String).

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Stable string key (e.g. `'ex_bench_press'`) |
| `name` | `String` | Display name |
| `type` | `ExerciseType` | `weighted` / `timeBased` / `bodyweight` |
| `muscleGroup` | `String?` | Optional; not used by SCR-07 |
| `description` | `String?` | Optional; not used by SCR-07 |

**SCR-07 reads this table via `ExerciseLocalDataSource.getAllExercises()`. No writes.**

### ExerciseType (existing)

```
enum ExerciseType { weighted, timeBased, bodyweight }   // stored as text
```

---

## New Domain Entities (SCR-07)

### Exercise (domain entity)

**File**: `forge/lib/features/exercise/domain/entities/exercise.dart`

Immutable, equatable domain object mapped from `ExerciseRecord` by `ExerciseMapper`.

| Field | Type | Nullable | Constraints |
|---|---|---|---|
| `id` | `String` | No | Non-empty; stable catalogue key |
| `name` | `String` | No | Non-empty; 1–80 chars (seeded data) |
| `type` | `ExerciseType` | No | One of three enum values |

SCR-07 does not need `muscleGroup` or `description`. They are excluded from the domain entity.

**Validation rules**: None at runtime — the catalogue is developer-seeded and trusted. The mapper may assert non-empty id/name in debug mode.

**State transitions**: None — the exercise entity is immutable and read-only.

---

### PickerContext (transient in-memory value object)

**File**: `forge/lib/features/exercise/domain/entities/picker_context.dart`

Passed from SCR-09 to SCR-07 via GoRouter `extra`. Not persisted to the database.

| Field | Type | Nullable | Constraints |
|---|---|---|---|
| `planName` | `String` | No | Non-empty; shown in picker banner |

**Lifecycle**: Created by SCR-09 → passed as `extra` on `context.push` → consumed by `ExerciseCatalogueScreen` → discarded on `context.pop`. Never stored anywhere.

---

## Bloc State Entities (SCR-07)

### ExerciseCatalogueState variants

These are sealed Bloc states, not storage records. They carry the minimum data for rendering each screen state.

| State | Carried Data |
|---|---|
| `ExerciseCatalogueInitial` | — |
| `ExerciseCatalogueLoading` | — |
| `ExerciseCataloguePopulated` | `displayedExercises: List<Exercise>`, `query: String`, `activeFilter: ExerciseType?` |
| `ExerciseCatalogueEmpty` | `query: String`, `activeFilter: ExerciseType?` |
| `ExerciseCatalogueError` | `message: String` |

The Bloc internally retains `_allExercises: List<Exercise>` (full catalogue) to re-filter on search/filter changes without re-reading Drift.

---

## Entity Relationships

```
`exercises` table
    │  (keyed by exercise.id)
    │
    └── ExerciseRecord  ──[ExerciseMapper]──► Exercise
                                                      │
                                              ExerciseRepository
                                                      │
                                            GetExercisesUseCase
                                                      │
                                       ExerciseCatalogueBloc
                                        ├── _allExercises: List<Exercise>
                                        └── emits ExerciseCatalogueState
                                                      │
                                       ExerciseCatalogueScreen
                                        ├── PickerContext? (from GoRouter extra)
                                        └── renders 5 states
```

---

## No New Drift Tables

SCR-07 adds **zero new Drift tables** and no schema change. All reads come from the existing `exercises` table already defined in `AppDatabase`.

`ExerciseRecord` and `ExerciseType` are already defined in the schema and their generated code is already included in the project.
