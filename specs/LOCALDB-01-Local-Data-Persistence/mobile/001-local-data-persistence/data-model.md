# Data Model: Local Data Persistence (LOCALDB-01)

**Date**: 2026-09-19 | **Branch**: `001-local-data-persistence`

This document describes all Drift-persisted tables, the data-layer `*Record` classes assembled from
their rows, and the corresponding domain representations. Entities in the `workout_session` domain
layer are marked **NEW**; all other persistence artefacts are marked **EXISTING**.

---

## Storage Architecture

One `AppDatabase` (`forge/lib/core/database/app_database.dart`, generated `app_database.g.dart`) owns
the schema. The file `forge.sqlite` lives in the application documents directory (path from
`path_provider`, ADR-031). `schemaVersion = 1`; `onCreate` creates all tables; `PRAGMA foreign_keys = ON`
is executed when the database opens.

| Dart table | SQL table | Row class | Primary key | Capacity | Status |
|---|---|---|---|---|---|
| `UserProfiles` | `user_profiles` | `UserProfileRow` | `id` (fixed `0`) | 1 row | EXISTING |
| `Exercises` | `exercises` | `ExerciseRow` | `id` (text) | Fixed (seed) | EXISTING |
| `WorkoutPlans` | `workout_plans` | `WorkoutPlanRow` | `plan_id` (text) | Unbounded | EXISTING |
| `PlanExercises` | `plan_exercises` | `PlanExerciseRow` | auto-increment `id` | Unbounded | EXISTING |
| `ScheduleEntries` | `schedule_entries` | `ScheduleEntryRow` | `weekday` (int 1–7) | Max 7 | EXISTING |
| `WorkoutSessions` | `workout_sessions` | `WorkoutSessionRow` | `session_id` (text) | Unbounded | EXISTING — data layer only |
| `SessionExercises` | `session_exercises` | `SessionExerciseRow` | auto-increment `id` | Unbounded | EXISTING |
| `ActualSets` | `actual_sets` | `ActualSetRow` | auto-increment `id` | Unbounded | EXISTING |

Every table class carries `@DataClassName('<Name>Row')` so generated row classes never clash with
domain entities. `ExerciseType` is stored as text (`textEnum<ExerciseType>()`); the enum carries no
storage annotations. The app-lock flag (SDS-DATA-1) is in-memory and is not a table. The theme
preference is the only non-relational device setting and lives in `shared_preferences`.

### Relationships

```
workout_plans 1 ──< plan_exercises            FK plan_id → workout_plans.plan_id        ON DELETE CASCADE
workout_sessions 1 ──< session_exercises      FK session_id → workout_sessions.session_id ON DELETE CASCADE
session_exercises 1 ──< actual_sets           FK session_exercise_id → session_exercises.id ON DELETE CASCADE
schedule_entries  ·· plan_id (snapshot, no FK)
workout_sessions  ·· plan_id (snapshot, no FK)
```

`schedule_entries` and `workout_sessions` store `plan_id` and `plan_name` as a snapshot and have no
foreign key to `workout_plans`, so deleting a plan never touches workout history; the repository
removes a deleted plan's schedule entries explicitly. Child rows carry an explicit `position` so
exercise and set order is preserved.

### Data-layer record classes

Plain immutable Dart classes, hand-written, one per file in each feature's
`data/models/<name>_record.dart`. They are the storage-side models that mappers convert to and from
domain entities (domain entities never see Drift):

`UserProfileRecord`, `ExerciseRecord`, `WorkoutPlanRecord` (holds `List<PlanExerciseRecord> planExercises`),
`PlanExerciseRecord`, `ScheduleEntryRecord`, `WorkoutSessionRecord` (holds
`List<SessionExerciseRecord> sessionExercises`), `SessionExerciseRecord` (holds
`List<ActualSetRecord> actualSets`), `ActualSetRecord`.

Local data sources (`*LocalDataSource`) take `AppDatabase`, expose only `Future`-returning methods,
read the relational tables and assemble Records (parent plus ordered children). Multi-table writes
(plan save, session save, seed replace) run in one `database.transaction`.

---

## Entity 1 — WorkoutPlan

### Domain Entity (EXISTING)

```
WorkoutPlan
├── planId: String          — UUID, primary key of workout_plans
├── name: String            — user-visible plan name
├── exercises: List<PlanExercise>
└── createdAt: DateTime
```

### Tables (EXISTING)

```
workout_plans (WorkoutPlans → WorkoutPlanRow)
├── plan_id: text           PK
├── name: text
├── created_at: datetime
└── updated_at: datetime

plan_exercises (PlanExercises → PlanExerciseRow)
├── id: integer             PK, auto-increment
├── plan_id: text           FK → workout_plans.plan_id, ON DELETE CASCADE
├── position: integer       — order of the exercise within the plan
├── exercise_id: text
├── exercise_name: text     — snapshot at plan-creation time
├── type: text              — ExerciseType (textEnum)
├── target_sets: integer
├── target_repetitions: integer?
├── target_weight: real?
├── target_duration_sec: integer?
└── rest_period_sec: integer
```

`WorkoutPlanRecord` carries the plan columns plus `List<PlanExerciseRecord> planExercises` ordered by
`position`; `PlanExerciseRecord` carries the `plan_exercises` columns.

### Validation Rules
- `plan_id` must be non-empty and unique (primary key)
- `name` must be non-empty
- `exercises` may be empty (a plan with no exercises is valid to save)
- Saving a plan (insert-or-replace of the plan row plus delete and re-insert of its `plan_exercises`
  rows) runs in a single transaction
- Mapper: `WorkoutPlanMapper` (verify existence in data layer)

---

## Entity 2 — WorkoutSession (Completed Record)

### Domain Entity (NEW)

```
WorkoutSession
├── sessionId: String       — UUID, primary key of workout_sessions
├── planId: String          — retained for history filtering; not used to read plan content
├── planName: String        — snapshot of plan name at finish time
├── completedAt: DateTime   — timestamp of Finish tap
├── startedAt: DateTime?    — when the session started, if recorded
├── sessionDurationSec: int — total elapsed time in seconds
└── sessionExercises: List<SessionExercise>
```

```
SessionExercise
├── exerciseId: String      — retained for linking; exercise content is snapshotted
├── exerciseName: String    — snapshot at finish time
├── type: ExerciseType
└── actualSets: List<ActualSet>
```

```
ActualSet
├── repetitions: int?       — weighted + bodyweight exercises
├── weight: double?         — weighted exercises only; strictly positive when set
├── durationSec: int?       — time-based exercises only
└── skipped: bool           — the set was skipped by the user
```

### Tables (EXISTING)

```
workout_sessions (WorkoutSessions → WorkoutSessionRow)
├── session_id: text        PK
├── plan_id: text           — snapshot, no FK
├── plan_name: text         — snapshot
├── completed_at: datetime
├── started_at: datetime?
└── session_duration_sec: integer

session_exercises (SessionExercises → SessionExerciseRow)
├── id: integer             PK, auto-increment
├── session_id: text        FK → workout_sessions.session_id, ON DELETE CASCADE
├── position: integer
├── exercise_id: text
├── exercise_name: text     — snapshot
└── type: text              — ExerciseType (textEnum)

actual_sets (ActualSets → ActualSetRow)
├── id: integer             PK, auto-increment
├── session_exercise_id: integer FK → session_exercises.id, ON DELETE CASCADE
├── position: integer
├── repetitions: integer?
├── weight: real?
├── duration_sec: integer?
└── skipped: boolean
```

```
WorkoutSessionRecord
├── sessionId, planId, planName, completedAt, startedAt?, sessionDurationSec
└── sessionExercises: List<SessionExerciseRecord>

SessionExerciseRecord
├── exerciseId, exerciseName, type
└── actualSets: List<ActualSetRecord>

ActualSetRecord
└── repetitions?, weight?, durationSec?, skipped
```

### Validation Rules
- `session_id` must be non-empty and unique (primary key)
- `completed_at` must not be in the future at write time
- `session_duration_sec` must be ≥ 0
- `sessionExercises` must be non-empty (FR-003 completion criterion)
- Each `SessionExercise.actualSets` must be non-empty (FR-003: ≥1 set logged for ≥1 exercise)
- Records are immutable after write (no update path in repository interface)
- A session save inserts the session row, its exercise rows and their set rows in a single
  `database.transaction`, so a failed write leaves no partial session
- **Completion criterion** (enforced at repository boundary, not data source):
  - `sessionExercises.isNotEmpty` AND at least one `actualSets.isNotEmpty`
  - If criterion fails → repository returns `Left(WorkoutSessionFailure.completionCriterionNotMet())` and performs no write

### Mapper (NEW)
File: `forge/lib/features/workout_session/data/mappers/workout_session_mapper.dart`

```
WorkoutSessionMapper
├── toRecord(WorkoutSession) → WorkoutSessionRecord
└── toDomain(WorkoutSessionRecord) → WorkoutSession

SessionExerciseMapper
├── toRecord(SessionExercise) → SessionExerciseRecord
└── toDomain(SessionExerciseRecord) → SessionExercise

ActualSetMapper
├── toRecord(ActualSet) → ActualSetRecord
└── toDomain(ActualSetRecord) → ActualSet
```

---

## Entity 3 — ScheduleEntry

### Table (EXISTING)

```
schedule_entries (ScheduleEntries → ScheduleEntryRow)
├── weekday: integer        PK — 1 (Mon) … 7 (Sun)
├── plan_id: text           — references a plan by id (no FK)
└── plan_name: text         — snapshot of the plan name
```

`ScheduleEntryRecord` carries `weekday`, `planId`, `planName`.

### Validation Rules
- `weekday` must be 1–7
- One plan per weekday (enforced by the primary key — insert-or-replace on `weekday` overwrites)
- Deleting a plan removes that plan's schedule entries explicitly in the repository (there is no
  foreign key); the owning feature (SCR-12/13) triggers this through the repositories

---

## Entity 4 — UserProfile

### Table (EXISTING)

```
user_profiles (UserProfiles → UserProfileRow)
├── id: integer             PK — fixed 0
├── display_name: text
├── fitness_goal: text
├── experience_level: text
├── height_cm: real
├── weight_kg: real
├── created_at: datetime
└── updated_at: datetime
```

`UserProfileRecord` mirrors these columns (without `id`). `ProfileRepository.getProfile()` returns
`Future<Either<...>>` like every other repository method.

### Validation Rules
- Single row with `id = 0` in `user_profiles`
- Profile schema owned by SCR-25 (Profile feature) — LOCALDB-01 defines only the persistence lifecycle guarantee

---

## Entity 5 — Exercise (Catalogue)

### Table (EXISTING)

```
exercises (Exercises → ExerciseRow)
├── id: text                PK
├── name: text
├── type: text              — ExerciseType (textEnum)
├── muscle_group: text
└── description: text
```

`ExerciseRecord` mirrors these columns.

### Validation Rules
- Read-only from the client; the catalogue is replaced transactionally by the seed step on every launch; no write path in user-facing features
- `ExerciseType` enum: `weighted`, `timeBased`, `bodyweight` — stored as text

---

## Failure Types

### WorkoutSessionFailure (NEW)
File: `forge/lib/features/workout_session/domain/failures/workout_session_failure.dart`

```
WorkoutSessionFailure (sealed class / union)
├── saveFailure({String? detail})     — database write threw; data intact
├── readFailure({String? detail})     — database read threw
├── deleteFailure({String? detail})   — database delete threw
└── completionCriterionNotMet()       — guard rejection; no write attempted
```

### Existing Failure Pattern (REFERENCE — from workout_plan feature)
- `WorkoutPlanFailure` sealed class — `loadFailure`, `saveFailure`, `deleteFailure`
- Same pattern applies to `WorkoutSessionFailure`

---

## State Transitions

```
Session Lifecycle:
  in-progress (in-memory only, never persisted)
    ├── Cancel → no write (FR-004)
    ├── Finish with zero sets → no write (FR-004)
    └── Finish with ≥1 set → WorkoutSessionRepository.saveSession()
                               ├── Success → rows stored in workout_sessions / session_exercises / actual_sets (one transaction)
                               └── Failure → WorkoutSessionFailure.saveFailure (transaction rolled back; no data corruption)
```

```
Plan Lifecycle:
  created → WorkoutPlanRepository.savePlan()
  edited  → WorkoutPlanRepository.savePlan() (replace by planId, transactional)
  deleted → WorkoutPlanRepository.deletePlan(planId)
           → plan_exercises rows removed by cascade; schedule entries removed explicitly
           → workout_sessions tables UNAFFECTED (FR-006, FR-007)
```

```
Schedule Lifecycle:
  assigned → ScheduleRepository.saveEntry(weekday, planId) — replaces existing row
  cleared  → ScheduleRepository.deleteEntry(weekday)
```
