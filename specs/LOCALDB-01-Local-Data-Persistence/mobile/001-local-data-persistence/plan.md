# Implementation Plan: Local Data Persistence

**Branch**: `001-local-data-persistence` | **Date**: 2026-09-19 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/LOCALDB-01-Local-Data-Persistence/mobile/001-local-data-persistence/spec.md`

## Summary

LOCALDB-01 defines the persistence contract for ForgeApp: all user data (workout plans, completed session records, schedule assignments, user profile) is stored exclusively in the on-device Drift (SQLite) database with no network involvement. The Drift infrastructure (`AppDatabase`, tables, initialisation) and asynchronous data sources for workout_plan, schedule, exercise, and profile are already implemented. The critical gap is the **workout_session** feature, which has Record classes and a data source but is missing its domain entities, repository interface, repository implementation, mapper, GetIt registration, and the completion-criterion enforcement gate (≥1 set + explicit Finish) required by FR-003/FR-004.

## Technical Context

**Language/Version**: Dart (tracked via FVM, latest stable Flutter)

**Primary Dependencies**: `flutter_bloc` (Bloc, not Cubit), `get_it`, `go_router`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`, `drift_dev`/`build_runner`, `equatable`, `bloc_test`/`mocktail` (test only)

**Storage**: Drift (typed SQLite) — sole persistence mechanism (ADR-008); the theme preference alone stays in `shared_preferences`. One `AppDatabase` (`forge.sqlite`, `schemaVersion = 1`, foreign keys on) opened at boot; eight tables:
- `user_profiles` — single row (id 0)
- `exercises` — seeded catalogue (read-only from client)
- `workout_plans` + `plan_exercises` — plans and their ordered exercises (FK cascade)
- `schedule_entries` — one row per weekday 1–7 (PK = weekday)
- `workout_sessions` + `session_exercises` + `actual_sets` — completed sessions, ordered exercises and sets (FK cascade; no FK to plans)

Local data sources take `AppDatabase`, expose only `Future` methods and wrap multi-table writes in `database.transaction`.

**Testing**: `flutter_test`, `bloc_test`, `mocktail`; data-source tests use an in-memory Drift database (`NativeDatabase.memory()`)

**Target Platform**: Android API 29+ / iOS 15+

**Project Type**: Flutter mobile app (single-developer, offline-only, single local user)

**Performance Goals**:
- SC-009: Any single write (plan or completed session) completes in under 1 second
- SC-010: Read of up to 50 completed session records completes in under 2 seconds on API 29 / iOS 15

**Constraints**:
- FR-012: No network call of any kind in any persistence path
- Constitution Principle VI: Database write failure → typed Domain failure, never silent data loss
- Constitution Principle VII: Write failure must surface a visible error state (FR-013, SC-011)
- FR-003/FR-004: Completion criterion enforced at repository boundary — only sessions with ≥1 logged set and explicit Finish trigger a write; cancelled or zero-set sessions produce no record

**Scale/Scope**: Up to 20 plans and 50+ completed records (SC-008), single device

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Status |
|-----------|-------|--------|
| I — Clean Feature-First Architecture | workout_session domain and application layers must be created; data layer already exists | ✓ Plan-compliant — gap identified, will be addressed |
| I.4 — Drift rows and Records must not leak into Domain or Presentation | WorkoutSessionRecord, SessionExerciseRecord, ActualSetRecord are data-layer artifacts; mapper to domain entity required | ✓ Pattern established by workout_plan feature |
| II.1 — flutter_bloc only (Bloc, not Cubit) | No new state management introduced | ✓ Compliant |
| II.4 — Drift is sole persistence mechanism | No secondary store introduced | ✓ Compliant |
| II.5 — Raw database exceptions terminate in Data layer | Repository impls must catch database exceptions and map to typed failure | ✓ Required — pattern from ADR-007 |
| VI.2 — Write failure → typed failure state, never silent | All `saveSession`, `savePlan`, `saveScheduleEntry` paths must propagate typed failure | ✓ Required |
| VII.1 — Every screen must define error state | Presentation layer consuming persistence must handle error state | ✓ Deferred to owning screen features (SCR-18/19/12/13) |
| IX.5 — No new dependencies | Only the ADR-030 governed "Local Persistence" set (`drift`, `sqlite3_flutter_libs`, `path_provider`, `path`, dev `drift_dev`, `build_runner`) | ✓ Compliant |
| No Git operations | No Git operations in plan or tasks | ✓ Compliant |

**Constitution Check Result: PASS** — no violations. One gap confirmed: workout_session is missing domain + application + repository layers.

## Project Structure

### Documentation (this feature)

```text
specs/LOCALDB-01-Local-Data-Persistence/mobile/001-local-data-persistence/
├── plan.md              ← This file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── quickstart.md        ← Phase 1 output
├── contracts/           ← Phase 1 output
│   ├── workout_session_repository.md
│   └── persistence_failure.md
└── tasks.md             ← Phase 2 output (/speckit-tasks)
```

### Source Code (repository root)

```text
forge/lib/
├── core/
│   └── database/
│       ├── app_database.dart        ← EXISTING — AppDatabase: tables, schemaVersion, foreign keys
│       └── app_database.g.dart      ← EXISTING — generated by drift_dev
├── features/
│   ├── workout_plan/
│   │   ├── domain/
│   │   │   ├── entities/workout_plan.dart            ← EXISTING
│   │   │   └── repositories/workout_plan_repository.dart ← EXISTING
│   │   ├── application/bloc/                         ← EXISTING
│   │   └── data/
│   │       ├── datasources/workout_plan_local_data_source.dart ← EXISTING
│   │       ├── models/workout_plan_record.dart                 ← EXISTING
│   │       ├── models/plan_exercise_record.dart                ← EXISTING
│   │       ├── mappers/workout_plan_mapper.dart                ← EXISTING (verify)
│   │       └── repository/workout_plan_repository_impl.dart    ← EXISTING
│   ├── workout_session/
│   │   ├── domain/                          ← GAP — must be created
│   │   │   ├── entities/
│   │   │   │   ├── workout_session.dart     ← NEW
│   │   │   │   ├── session_exercise.dart    ← NEW
│   │   │   │   └── actual_set.dart          ← NEW
│   │   │   ├── repositories/
│   │   │   │   └── workout_session_repository.dart ← NEW
│   │   │   └── failures/
│   │   │       └── workout_session_failure.dart ← NEW
│   │   ├── application/                     ← GAP — owned by SCR-19; LOCALDB-01 defines contracts
│   │   └── data/
│   │       ├── datasources/workout_session_local_data_source.dart ← EXISTING
│   │       ├── models/workout_session_record.dart                 ← EXISTING
│   │       ├── models/session_exercise_record.dart                ← EXISTING
│   │       ├── models/actual_set_record.dart                       ← EXISTING
│   │       ├── mappers/workout_session_mapper.dart                ← NEW
│   │       └── repository/workout_session_repository_impl.dart    ← NEW
│   ├── schedule/
│   │   └── data/datasources/schedule_local_data_source.dart ← EXISTING
│   ├── exercise/
│   │   └── data/datasources/exercise_local_data_source.dart ← EXISTING
│   └── profile/
│       └── data/datasources/profile_local_data_source.dart  ← EXISTING
└── config/
    └── di/
        └── injection.dart  ← EXISTING — GetIt registration (workout_session entries NEW)
```

**Structure Decision**: Feature-first single-app layout (existing). LOCALDB-01 creates only the workout_session domain layer and repository; all other persistence infrastructure already exists and needs verification only.

## Complexity Tracking

No constitution violations requiring justification.
