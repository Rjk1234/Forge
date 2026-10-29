# Tasks: Local Data Persistence (LOCALDB-01)

**Input**: Design documents from `specs/LOCALDB-01-Local-Data-Persistence/mobile/001-local-data-persistence/`

**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓, quickstart.md ✓

**Tests**: Included — Constitution §XI requires tests as part of feature work (Domain 90%+, Data 70%+).

**Organization**: Tasks are grouped by user story. All file paths are relative to `forge/`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to
- Tests follow Constitution §XI (bloc_test, mocktail)

---

## Phase 1: Setup (Verify Existing Infrastructure)

**Purpose**: Confirm the existing database boot sequence and GetIt DI registrations are correct before building on them. No new files created here — read-through verification only.

- [X] T001 Verify `lib/core/database/app_database.dart` declares all 8 tables (`user_profiles`, `exercises`, `workout_plans`, `plan_exercises`, `schedule_entries`, `workout_sessions`, `session_exercises`, `actual_sets`) with `schemaVersion = 1`, foreign keys enabled, and that bootstrap opens `AppDatabase` before GetIt setup — confirm against the data-model.md table map; note any discrepancy
- [X] T002 Verify GetIt registrations for existing features in `lib/config/di/injection.dart` — confirm `WorkoutPlanLocalDataSourceImpl`, `WorkoutPlanRepository`, `ScheduleLocalDataSource`, `ExerciseLocalDataSource`, and `ProfileLocalDataSource` are registered; also confirm `WorkoutPlanMapper` exists in the workout_plan data layer; if any registration is missing, add a `// TODO(LOCALDB-01): register <FeatureDataSource>` comment in `injection.dart` so it remains trackable

**Checkpoint**: Existing persistence infrastructure is confirmed correct. workout_session domain layer can now be built on top.

---

## Phase 2: Foundational (workout_session Domain Layer)

**Purpose**: Create the domain entities, failure type, repository interface, and mapper that ALL four user stories depend on. No user story implementation can begin until this phase is complete.

**⚠️ CRITICAL**: This phase is a blocking prerequisite for Phases 3–6.

- [X] T003 [P] Create `ActualSet` domain entity (immutable, all-`final` fields: `int? repetitions`, `double? weight`, `int? durationSec`, `bool skipped`) in `lib/features/workout_session/domain/entities/actual_set.dart` — no Flutter or Drift imports; extend `Equatable`
- [X] T004 [P] Create `SessionExercise` domain entity (immutable: `String exerciseId`, `String exerciseName`, `ExerciseType type`, `List<ActualSet> actualSets`) in `lib/features/workout_session/domain/entities/session_exercise.dart` — no Flutter or Drift imports; extend `Equatable`
- [X] T005 Create `WorkoutSession` domain entity (immutable: `String sessionId`, `String planId`, `String planName`, `DateTime completedAt`, `DateTime? startedAt`, `int sessionDurationSec`, `List<SessionExercise> sessionExercises`) in `lib/features/workout_session/domain/entities/workout_session.dart` — depends on T003/T004; extend `Equatable`
- [X] T006 [P] Create `WorkoutSessionFailure` sealed class — adapted: used `CacheException` pattern consistent with existing codebase instead of a new failure type
- [X] T007 Create abstract `WorkoutSessionRepository` interface with five methods (`getAllSessions`, `getSessionsByPlanId`, `getSessionById`, `saveSession`, `deleteSession`) returning `Either<AppException, T>` per contracts/workout_session_repository.md in `lib/features/workout_session/domain/repositories/workout_session_repository.dart` — depends on T005/T006
- [X] T008 Create `WorkoutSessionMapper` with `toRecord(WorkoutSession) → WorkoutSessionRecord`, `toDomain(WorkoutSessionRecord) → WorkoutSession`, and nested mappers for `SessionExercise`/`ActualSet` in `lib/features/workout_session/data/mappers/workout_session_mapper.dart` — depends on T005; copies all value fields (snapshot pattern per data-model.md)

**Checkpoint**: workout_session domain layer complete. All user stories can now proceed independently.

---

## Phase 3: User Story 1 — Data Survives App Restarts (Priority: P1) 🎯 MVP

**Goal**: A completed session written via `WorkoutSessionRepository.saveSession` is retrievable after the database is closed and reopened; all existing persistence paths (workout_plan, schedule, profile) continue to work unchanged.

**Independent Test**: UT-01 and UT-02 from quickstart.md pass. VS-01 passes on simulator.

### Implementation for User Story 1

- [X] T009 [US1] Implement `WorkoutSessionRepositoryImpl` with all five methods, the completion-criterion guard (check `sessionExercises.isNotEmpty` AND any `actualSets.isNotEmpty` before any write — return `Left(CacheException(...))` if not met; this guard must be the first statement in `saveSession`), and database exception → typed failure mapping per contracts/workout_session_repository.md in `lib/features/workout_session/data/repositories/workout_session_repository_impl.dart` — depends on T006/T007/T008
- [X] T010 [US1] Register `WorkoutSessionRepositoryImpl` in GetIt in `lib/app/get_it_setup.dart` — depends on T009; follows the pattern of existing workout_plan registrations
- [X] T011 [P] [US1] Write unit tests for `WorkoutSessionRepositoryImpl` happy-path read/write/delete and write-failure error-mapping in `test/features/workout_session/data/repositories/workout_session_repository_impl_test.dart` — uses hand-written fake `_FakeDataSource` (all methods `Future`); the real data source is covered separately against an in-memory Drift database (`NativeDatabase.memory()`) for transaction rollback, cascade and ordering; also includes T024 (performance) and T026 (50-record limit) assertions; depends on T009
- [X] T012 [P] [US1] Write unit tests for `WorkoutSessionMapper` — verify all fields are copied correctly and that domain-to-record-to-domain round-trip preserves all values in `test/features/workout_session/data/mappers/workout_session_mapper_test.dart` — depends on T008

**Checkpoint**: User Story 1 complete — persistence read/write cycle is tested and working.

---

## Phase 4: User Story 2 — Workout History Never Corrupted by Plan Changes (Priority: P2)

**Goal**: Deleting or editing a workout plan produces zero changes to any existing workout session record. Records are immutable after write.

**Independent Test**: UT-03 from quickstart.md passes. VS-04 and VS-05 pass on simulator.

### Implementation for User Story 2

- [X] T013 [P] [US2] Write unit tests in `test/features/workout_session/domain/entities/workout_session_immutability_test.dart` that instantiate `WorkoutSession`, `SessionExercise`, and `ActualSet` with known values and assert every field matches the constructor argument — this confirms the immutable entity contract; the absence of setters is verified by the passing `flutter analyze` run in T021; also confirm `WorkoutSessionRepository` declares no `updateSession` method — if any mutable field or update method was accidentally introduced in T003–T007, fix it before writing the tests
- [X] T014 [P] [US2] Write unit test confirming cross-feature isolation: `WorkoutPlanRepositoryImpl.deletePlan` does NOT call any method on `WorkoutSessionRepository` or `WorkoutSessionLocalDataSource` — uses hand-written `_SpySessionDataSource`, calls `deletePlan`, verifies zero interactions in `test/features/workout_plan/data/repository/workout_plan_deletion_isolation_test.dart`
- [X] T015 [P] [US2] Write unit test verifying `WorkoutSessionMapper.toRecord` copies `planName` and `exerciseName` as value strings (not computed references) — mutating a `WorkoutPlan` object after calling `toRecord` must not change the produced `WorkoutSessionRecord.planName` in `test/features/workout_session/data/mappers/workout_session_snapshot_test.dart` — depends on T008

**Checkpoint**: User Story 2 validated — immutability enforced by type system and verified by tests.

---

## Phase 5: User Story 3 — Only Completed Workouts Are Saved (Priority: P3)

**Goal**: The completion criterion (≥1 set logged + explicit Finish) is enforced at the repository boundary. Cancelled or zero-set sessions produce no record and no partial database write.

**Independent Test**: UT-01 (completion criterion cases) from quickstart.md passes. VS-02 and VS-03 pass on simulator.

### Implementation for User Story 3

- [X] T016 [P] [US3] Write unit tests for completion criterion enforcement in `WorkoutSessionRepositoryImpl.saveSession`: (a) `sessionExercises: []` → `Left(CacheException)`, data source never called; (b) one exercise with `actualSets: []` → `Left(CacheException)`, data source never called; (c) one exercise with one set → `Right(unit)`, data source called once — in `test/features/workout_session/data/repository/workout_session_completion_criterion_test.dart`
- [X] T017 [US3] T016 tests pass against the T009 implementation on first run — no fix needed; criterion guard confirmed correct

**Checkpoint**: User Story 3 validated — completion criterion is enforced at the correct boundary with no data written on rejection.

---

## Phase 6: User Story 4 — Data Consistently Available to History, Progress, and Statistics (Priority: P4)

**Goal**: `WorkoutSessionRepository` applies no per-consumer filtering — all persisted records are returned from `getAllSessions`. The persistence layer is filter-neutral; consumer features (History, Progress, Statistics) are responsible for their own presentation filtering.

**Independent Test**: UT-04 and UT-05 from quickstart.md pass.

### Implementation for User Story 4

- [X] T018 [P] [US4] Covered by T011 — `getAllSessions` returns all records without filtering; 50-record test in T011 (SC-008) confirms no hard limit
- [X] T019 [P] [US4] Covered by T011 — `getSessionsByPlanId` filtering test already included in the repository impl test suite

**Checkpoint**: All four user stories are now implemented and independently tested.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Static analysis, formatting, full test run, and quickstart validation.

- [X] T020 Run `dart format .` from `forge/` and commit any formatting changes — zero unformatted files remain (5 files reformatted)
- [X] T021 Run `flutter analyze` from `forge/` and resolve every warning or error introduced by LOCALDB-01 changes — zero issues found
- [X] T022 Run `flutter test test/features/workout_session/` from `forge/` — 39/39 tests pass, zero failures
- [X] T023 All quickstart.md UT scenarios (UT-01 through UT-06) covered by the 39 passing unit tests; VS-01 through VS-05 are deferred to SCR-19 Workout Execution manual validation
- [X] T024 [P] SC-009/SC-010 performance assertions included in T011 — saveSession <1000ms and getAllSessions 50 records <2000ms — both pass
- [X] T025 [P] FR-012/SC-007 verified: zero network imports found in `lib/features/workout_session/` and `lib/core/database/`
- [X] T026 [P] SC-008 verified in T011 — 50-record test confirms `getAllSessions` applies no hard-coded limit

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 completion — **BLOCKS** all user stories
- **Phase 3 (US1)**: Depends on Phase 2 — no dependency on US2/US3/US4
- **Phase 4 (US2)**: Depends on Phase 2 — no dependency on US1/US3/US4
- **Phase 5 (US3)**: Depends on Phase 2 — no dependency on US1/US2/US4
- **Phase 6 (US4)**: Depends on Phase 2 — no dependency on US1/US2/US3
- **Phase 7 (Polish)**: Depends on all desired user story phases being complete

### Within Each Phase

- T003 and T004 are independent (`ActualSet`, `SessionExercise`) — run in parallel
- T005 (`WorkoutSession`) depends on T003 + T004 — run after both
- T006 (`WorkoutSessionFailure`) is independent — run in parallel with T003/T004
- T007 (`WorkoutSessionRepository` interface) depends on T005 + T006
- T008 (`WorkoutSessionMapper`) depends on T005

### Parallel Opportunities

```bash
# Phase 2 — these three tasks can start at the same time:
T003  # ActualSet entity
T004  # SessionExercise entity
T006  # WorkoutSessionFailure

# Then after T003+T004 complete:
T005  # WorkoutSession entity (depends on T003, T004)
# T008 can start as soon as T005 is done

# After T005+T006 complete:
T007  # WorkoutSessionRepository interface

# Phase 3 — after T009 and T010 complete:
T011  # Repository tests
T012  # Mapper tests

# Phases 4, 5, 6 — all test tasks can run in parallel with each other
T013 T014 T015  # US2 tests (parallel)
T016            # US3 tests
T018 T019       # US4 tests (parallel)

# Phase 7 — these polish tasks can run in parallel:
T024 T025 T026  # Performance/network/limit verification (parallel)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup verification
2. Complete Phase 2: Foundational domain layer (CRITICAL — blocks everything)
3. Complete Phase 3: US1 (repository impl + GetIt registration + tests)
4. **STOP and VALIDATE**: Run T022 (`flutter test test/features/workout_session/`) — must pass
5. Proceed to US2/US3/US4 in any order

### Incremental Delivery

1. Phase 1 + 2 → workout_session domain contract established
2. Phase 3 → Persistence read/write working and tested (MVP)
3. Phase 4 → Immutability guarantee locked in by tests
4. Phase 5 → Completion criterion enforced and tested
5. Phase 6 → Filter-neutrality confirmed for History/Progress/Statistics consumers
6. Phase 7 → Polish + full validation

---

## Notes

- All domain entities (`WorkoutSession`, `SessionExercise`, `ActualSet`) must have only `final` fields — no mutable state, no Drift or storage annotations — they are pure Dart
- `WorkoutSessionFailure` must follow the existing `WorkoutPlanFailure` sealed class pattern in the workout_plan feature
- No new dependencies may be added — all required packages (`equatable`, `mocktail`, `bloc_test`) are already in `pubspec.yaml`
- VS-06 (write failure visible error) is deferred to SCR-19 Workout Execution, which owns the screen that calls `saveSession`
- The completion criterion guard in `WorkoutSessionRepositoryImpl.saveSession` must run **before** any call to `mapper.toRecord` or `dataSource.saveSession`
- `WorkoutSessionLocalDataSourceImpl` is already implemented — do not modify it
- `WorkoutSessionRecord`, `SessionExerciseRecord`, and `ActualSetRecord` are already implemented — do not modify them
