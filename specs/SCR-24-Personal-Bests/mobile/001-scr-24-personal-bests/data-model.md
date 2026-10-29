# Data Model: SCR-24 Personal Bests

**Feature**: SCR-24 Personal Bests  
**Date**: 2026-09-23

---

## Overview

SCR-24 computes entities entirely in memory from existing Drift data. No new tables are introduced. Two categories of entities exist: **Drift source entities** (read-only; owned by the `workout_session` feature) and the **computed domain entity** (`PersonalBestRecord`; owned by `features/personal_bests/domain/`).

---

## Drift Source Entities (Read-Only)

These entities are read from the `workout_sessions` table via `WorkoutSessionRepository.getAllSessions()`. They are owned by the `workout_session` feature and are not modified by SCR-24.

### `WorkoutSession`

| Field | Type | Notes |
|-------|------|-------|
| `completedAt` | `DateTime?` | Non-null → session is complete; null → in-progress or abandoned |
| `sessionExercises` | `List<SessionExercise>` | Ordered list of exercises performed |
| *(other fields)* | — | Not accessed by SCR-24 |

**Valid session filter** (FR-004): `completedAt != null`.

### `SessionExercise`

| Field | Type | Notes |
|-------|------|-------|
| `exerciseName` | `String` | Used as the PB grouping key (case-sensitive) |
| `type` | `ExerciseType` | `weighted`, `timeBased`, or `bodyweight` |
| `actualSets` | `List<ActualSet>` | Sets logged during the session |

### `ActualSet`

| Field | Type | Notes |
|-------|------|-------|
| `weight` | `double` | kg; used for `weighted` PB |
| `repetitions` | `int` | Used for `bodyweight` PB |
| `durationSec` | `int` | seconds; used for `timeBased` PB |
| `skipped` | `bool?` | `null` → treat as non-skipped (pre-SCR-16 compatibility) |

**Valid set filter** (FR-004): `skipped != true` (null-safe: absent field → non-skipped).

---

## Computed Domain Entity

### `PersonalBestRecord`

**File**: `forge/lib/features/personal_bests/domain/entities/personal_best_record.dart`

**Description**: One record per unique `(exerciseName, type)` pair that has ≥1 qualifying set across all valid sessions. Computed by `GetPersonalBestsUseCase`. Not persisted to Drift; never written to any store.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `exerciseName` | `String` | No | Display name; also the alphabetical sort key |
| `type` | `ExerciseType` | No | Determines PB metric and badge label |
| `bestWeight` | `double?` | Yes (null unless `weighted`) | Max weight in kg across all qualifying sets |
| `bestDurationSec` | `int?` | Yes (null unless `timeBased`) | Max durationSec across all qualifying sets |
| `bestReps` | `int?` | Yes (null unless `bodyweight`) | Max repetitions across all qualifying sets |
| `bestDate` | `DateTime` | No | `completedAt` of the session containing the set that produced the PB; most-recent date wins ties |

**Type invariant**: Exactly one of `bestWeight`, `bestDurationSec`, `bestReps` is non-null, determined by `type`:
- `ExerciseType.weighted` → `bestWeight != null`
- `ExerciseType.timeBased` → `bestDurationSec != null`
- `ExerciseType.bodyweight` → `bestReps != null`

**Not persisted**: `PersonalBestRecord` is a pure Dart class. It is not annotated and not stored.

**No `equatable`**: Not needed — `PersonalBestRecord` is not used in Bloc state equality comparisons directly; `PbLoaded` holds a `List<PersonalBestRecord>` and uses `const` equality of the list reference.

---

## Private Accumulator (Use Case Internal)

**`_PbAccumulator`** — private to `get_personal_bests_use_case.dart`; not a domain entity.

Tracks the running best for a single `(exerciseName, type)` pair during iteration.

| Field | Type | Description |
|-------|------|-------------|
| `exerciseName` | `String` | Key |
| `type` | `ExerciseType` | Key |
| `bestValue` | `double` | Unified best value (coerced to double regardless of type) |
| `bestDate` | `DateTime?` | Session `completedAt` of the set that produced `bestValue`; null until first qualifying set |

**Update logic** per type:
- `weighted`: candidate = `actualSet.weight`; compare as double
- `timeBased`: candidate = `actualSet.durationSec.toDouble()`
- `bodyweight`: candidate = `actualSet.repetitions.toDouble()`

Tie on `bestValue`: keep the accumulator with the **more recent** `bestDate` (i.e. if `candidate == bestValue` and `session.completedAt.isAfter(bestDate)`, update `bestDate` only).

**Conversion to `PersonalBestRecord`**:
```
weighted   → bestWeight = bestValue,        bestDurationSec = null, bestReps = null
timeBased  → bestWeight = null,             bestDurationSec = bestValue.toInt(), bestReps = null
bodyweight → bestWeight = null,             bestDurationSec = null, bestReps = bestValue.toInt()
```

---

## Display Formatting (Presentation Layer)

Formatting is handled in the presentation layer by `FormatUtils` (core/utils) and does not affect the domain entity.

| Type | Field | `FormatUtils` method | Output example |
|------|-------|---------------------|----------------|
| `weighted` | `bestWeight` | `FormatUtils.formatWeight(double kg)` | `"65 kg"`, `"62.5 kg"` |
| `timeBased` | `bestDurationSec` | `FormatUtils.formatMmSs(int seconds)` | `"01:10"`, `"00:45"` |
| `bodyweight` | `bestReps` | `"{bestReps}"` (int.toString()) | `"18"` |
| All | `bestDate` | `FormatUtils.formatPbDate(DateTime date)` | `"Set Aug 31, 2026"` |

---

## Entity Relationships

```
workout_sessions (Drift table)
└── WorkoutSession [completedAt != null → valid]
    └── SessionExercise [exerciseName, type]
        └── ActualSet [skipped != true → qualifying]
              │
              ▼
    GetPersonalBestsUseCase (in-memory computation)
              │
              ▼
    PersonalBestRecord (computed, not persisted)
    [one per unique (exerciseName, type)]
              │
              ▼
    PbLoaded.records: List<PersonalBestRecord>
    [sorted alphabetically by exerciseName]
```

---

## State Model

| State | Payload | Rendered as |
|-------|---------|-------------|
| `PbInitial` | none | Skeleton (5 shimmer rows) — identical to `PbLoading` |
| `PbLoading` | none | Skeleton (5 shimmer rows) |
| `PbLoaded` | `List<PersonalBestRecord> records` | `records.isEmpty` → `PbEmptyState`; otherwise scrollable `PbCard` list |
| `PbError` | none | `PbErrorCard` with Retry |
