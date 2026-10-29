# Research: Local Data Persistence (LOCALDB-01)

**Date**: 2026-09-19 | **Branch**: `001-local-data-persistence`

## 1. Drift Infrastructure — Status

### Decision: `AppDatabase` defines all eight tables and is opened at boot before GetIt setup

**Rationale**: `forge/lib/core/database/app_database.dart` (generated `app_database.g.dart`) declares the
whole schema (`schemaVersion = 1`, `onCreate` creates all tables, `PRAGMA foreign_keys = ON`). The database
file `forge.sqlite` lives in the application documents directory located with `path_provider` (ADR-031).
Bootstrap order is AppConfig → database (`AppDatabase`) → GetIt → seed exercise catalogue (transactional
replace on every launch) → `runApp`. Nothing needs to be registered per entity; the schema is the table
definitions.

**Confirmed table map:**

| Dart table | SQL table | Row class | Role |
|------------|-----------|-----------|------|
| `UserProfiles` | `user_profiles` | `UserProfileRow` | single profile row, id fixed `0` (SDS-DATA-2) |
| `Exercises` | `exercises` | `ExerciseRow` | seeded catalogue, read-only from client (SDS-DATA-3) |
| `WorkoutPlans` | `workout_plans` | `WorkoutPlanRow` | user plans (SDS-DATA-4) |
| `PlanExercises` | `plan_exercises` | `PlanExerciseRow` | ordered exercises of a plan; FK to plan, cascade |
| `ScheduleEntries` | `schedule_entries` | `ScheduleEntryRow` | one row per weekday 1–7 (SDS-DATA-5) |
| `WorkoutSessions` | `workout_sessions` | `WorkoutSessionRow` | completed sessions (SDS-DATA-6) |
| `SessionExercises` | `session_exercises` | `SessionExerciseRow` | ordered exercises of a session; FK cascade |
| `ActualSets` | `actual_sets` | `ActualSetRow` | ordered sets of a session exercise; FK cascade |

**Alternatives considered**: Separate tables for history/statistics views — rejected; the single
`workout_sessions` family serves all consumers (US4, FR-008).

---

## 2. Existing Feature Persistence — Status by Feature

### Decision: workout_plan, schedule, exercise, profile — fully implemented at data layer

**Rationale**: Direct filesystem inspection confirms:
- `workout_plan`: `WorkoutPlanLocalDataSourceImpl` — `getAllPlans`, `getPlanById`, `savePlan`, `deletePlan`, `planExists` (all `Future`) ✓
- `schedule`: `ScheduleLocalDataSource` — present (primary key: weekday int, one plan per day) ✓
- `exercise`: `ExerciseLocalDataSource` — present (read-only catalogue) ✓
- `profile`: `ProfileLocalDataSource` — present (single row with id 0); `ProfileRepository.getProfile()` returns `Future<Either<...>>` ✓

**Alternatives considered**: Verifying GetIt registration — to be confirmed during tasks execution; data sources are implemented regardless.

---

## 3. workout_session Feature — Gap Analysis

### Decision: workout_session has data layer only; domain and repository layers must be created

**Rationale**: The `workout_session` feature directory contains:
- ✓ `data/datasources/workout_session_local_data_source.dart` — `WorkoutSessionLocalDataSourceImpl(AppDatabase)` with `getAllSessions`, `getSessionsByPlanId`, `getSessionById`, `saveSession`, `deleteSession` (all `Future`)
- ✓ `data/models/` — `WorkoutSessionRecord`, `SessionExerciseRecord`, `ActualSetRecord`
- ✗ `domain/` — **does not exist**
- ✗ `application/` — **does not exist** (owned by SCR-19 Workout Execution)

What LOCALDB-01 must create:
1. `domain/entities/` — `WorkoutSession`, `SessionExercise`, `ActualSet` (pure Dart, no framework imports)
2. `domain/repositories/workout_session_repository.dart` — abstract interface
3. `domain/failures/workout_session_failure.dart` — typed failure sealed class/union
4. `data/mappers/workout_session_mapper.dart` — storage record ↔ domain entity
5. `data/repository/workout_session_repository_impl.dart` — implements interface, wraps data source, maps database exceptions to typed failure, enforces completion criterion

**Completion criterion location**: The repository implementation is the correct enforcement point for FR-003/FR-004 (≥1 set + explicit Finish). The data source (`saveSession`) performs the transactional write unconditionally — the repository guards against zero-set writes before calling the data source.

**Alternatives considered**: Enforcing completion criterion in the Bloc (application layer) — rejected; this is a business rule that belongs in the domain/repository boundary, not in presentation-adjacent state management. The Bloc may provide a guard too, but the repository must be the authoritative gate.

---

## 4. Write Failure Propagation Pattern

### Decision: database exception → typed Domain failure → Bloc error state → visible UI error

**Rationale**: ADR-007 and Constitution Principle VI.2 require that raw database exceptions (`SqliteException`, `DriftWrappedException`) terminate in the Data layer and map to typed Domain failures. The SCR-11 Delete Plan Confirmation feature (already implemented) provides the reference pattern:
- `WorkoutPlanRepositoryImpl.deletePlan` catches the exception → returns `Left(WorkoutPlanFailure.deleteFailure(...))`
- `DeletePlanBloc` maps `DeletePlanFailure` state → `InlineDialogError` widget
- FR-013 / SC-011: user sees a visible error, can retry

`WorkoutSessionRepositoryImpl.saveSession` must follow the same pattern: catch the exception, return `Left(WorkoutSessionFailure.saveFailure(...))`, never throw. Because the multi-table write runs in a single `database.transaction`, a failure rolls the whole write back and previously persisted data is unaffected (FR-011).

**Alternatives considered**: Letting database exceptions propagate up to the Bloc uncaught — rejected; violates constitution II.5 and produces untyped error handling.

---

## 5. History Immutability Pattern

### Decision: Snapshot-at-finish — copy all values into session rows at write time

**Rationale**: `workout_sessions` stores `plan_name` as a snapshot string (not a live reference to the plan's current name), and `session_exercises` copies `exercise_name` at finish time. `plan_id` is retained for linking (history filtering) but there is **no foreign key** from `workout_sessions` to `workout_plans`, and plan content is never re-read from the plan tables when displaying history. This satisfies FR-006 and SC-004: deleting a plan cannot cascade into history.

**Alternatives considered**: Storing only planId and joining to plan at read time — rejected by the data model (snapshots) and by FR-006 requirement for immutability independent of plan changes.

---

## 6. Performance — Read/Write Analysis

### Decision: Drift asynchronous reads and transactional writes meet SC-009/SC-010 on target devices

**Rationale**:
- `getAllSessions()` selects the session rows and their ordered children from local SQLite; 50 records is a small result set — comfortably under SC-010's 2-second target
- `saveSession(record)` is a single transaction inserting one session row plus roughly 10 exercises × 3 sets of child rows — a few dozen small inserts, well within SC-009's 1-second target on API 29

**Alternatives considered**: Adding explicit timing assertions in tests — tests can use `stopwatch` against an in-memory Drift database (`NativeDatabase.memory()`) to assert duration, but real-device figures are QA-validated on hardware; SC-009/SC-010 are not unit-test gated.

---

## 7. No Network Invariant

### Decision: No change to networking posture; confirmed zero network surface in persistence path

**Rationale**: All persistence operations are Drift calls against the local SQLite file (`sqlite3_flutter_libs`). `path_provider` supplies the storage path (ADR-031) and `dart:io` handles file I/O — no network socket. FR-012 and SC-007 are satisfied by the architecture.

---

## 8. GetIt Registration — workout_session

### Decision: WorkoutSessionLocalDataSourceImpl and WorkoutSessionRepositoryImpl must be registered in injection.dart

**Rationale**: Other features (workout_plan, schedule, exercise, profile) register their data sources and repositories in the central DI setup. workout_session needs a GetIt entry so Blocs (in SCR-19) can inject it. The data source takes the shared `AppDatabase`.

**Pattern** (from workout_plan):
```dart
getIt.registerLazySingleton<WorkoutSessionLocalDataSource>(
  () => WorkoutSessionLocalDataSourceImpl(getIt<AppDatabase>()),
);
getIt.registerLazySingleton<WorkoutSessionRepository>(
  () => WorkoutSessionRepositoryImpl(
    localDataSource: getIt<WorkoutSessionLocalDataSource>(),
  ),
);
```

---

## 9. Testing Approach

### Decision: Data-layer tests run against an in-memory Drift database

**Rationale**: `AppDatabase(NativeDatabase.memory())` gives a real SQLite engine with the real schema, foreign keys and transactions, and no file I/O, so data source tests exercise cascade deletes, ordering and rollback realistically. Repository tests use a hand-written fake data source.

---

## Summary of Findings

| Area | Finding | Action Required |
|------|---------|-----------------|
| Database boot | `AppDatabase` defines all 8 tables; opened before GetIt; catalogue seeded | None — existing |
| workout_plan persistence | Fully implemented (data source + repository) | Verify GetIt registration |
| schedule persistence | Data source exists | Verify GetIt registration + repository interface |
| exercise persistence | Data source exists (read-only) | No action |
| profile persistence | Data source exists; `getProfile()` is `Future` | Verify GetIt registration |
| workout_session data layer | Data source + Record classes exist | No change needed |
| workout_session domain layer | **Missing** | Create entities, repository interface, failure types |
| workout_session repository impl | **Missing** | Create impl with completion criterion guard + error mapping |
| workout_session mapper | **Missing** | Create Record ↔ domain entity mapper |
| workout_session GetIt | **Missing** | Register data source + repository in injection.dart |
| Write failure propagation | Pattern established (SCR-11) | Apply same pattern to workout_session repository |
| History immutability | Snapshot columns + no plan FK | No change needed |
