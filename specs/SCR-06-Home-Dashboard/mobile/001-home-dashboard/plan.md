# Implementation Plan: SCR-06 Home Dashboard

**Branch**: `001-home-dashboard` | **Date**: 2026-09-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/SCR-06-Home-Dashboard/mobile/001-home-dashboard/spec.md`

---

## Summary

Implement the Home Dashboard screen as the authenticated tab root for ForgeApp. The screen reads from three tables on every Home tab activation and renders one of five mutually exclusive UI states: loading, empty (no data), populated/scheduled (today's workout), populated/rest-day (data but no workout today), and error (with retry). A six-tab `StatefulShellRoute` bottom navigation bar is the persistent app shell hosting all root destinations. The entire existing home scaffold (network-based placeholder) is replaced with a Drift-only implementation.

---

## Technical Context

**Language/Version**: Dart 3 (Flutter stable, managed via FVM)

**Primary Dependencies**: `flutter_bloc` (Bloc — not Cubit), `get_it`, `go_router`, `drift`, `sqlite3_flutter_libs`, `equatable`, `fpdart`

**Storage**: Drift — three tables consumed read-only by this feature:
- `workout_plans` table (`WorkoutPlanRecord`)
- `schedule_entries` table (`ScheduleEntryRecord`)
- `workout_sessions` table (`WorkoutSessionRecord`)

**Testing**: `flutter_test` + `bloc_test` + `mocktail` (per governed dependency set)

**Target Platform**: Android 10 / API 29+ · iOS 15+ · phone portrait only

**Project Type**: Flutter mobile feature within existing Clean Architecture monorepo

**Performance Goals**: Dashboard content visible within 3 seconds of Home tab activation (database read is a local `Future` — expected < 50 ms actual latency)

**Constraints**: Fully offline; no network calls; no writes; Drift is the sole data source

**Scale/Scope**: Single local user; maximum 7 schedule entries; plans and sessions unbounded but practically small

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Action Required |
|---|---|---|
| I. Clean Feature-First Architecture | ✓ Pass | HomeBloc moves to `application/bloc/`; wrong `presentation/bloc/` scaffold deleted |
| II. Exclusive Mechanisms — Bloc only | ✓ Pass | HomeBloc extends `Bloc<HomeEvent, HomeState>`; no Cubit introduced |
| II. Exclusive Mechanisms — go_router only | ✓ Pass | `StatefulShellRoute` added to existing GoRouter config; no second router |
| II. Exclusive Mechanisms — GetIt DI | ✓ Pass | Registrations updated; no Riverpod/provider |
| II. Exclusive Mechanisms — Drift only | ⚠ **Fix in impl** | `HomeRemoteDataSource` (Dio) deleted; replaced with `HomeDashboardLocalDataSource` (Drift) |
| IV. No network calls | ⚠ **Fix in impl** | Same — Dio dependency removed from home feature entirely |
| VI. Drift is sole data store | ✓ Pass | Three existing tables read; no new store introduced |
| VII. Explicit user states | ✓ Pass | 5 distinct states each defined with explicit trigger conditions |
| VIII. Design System | ✓ Pass | All styling uses `Theme.of(context)` tokens from `AppColors` / `AppTheme` |
| IX. No new packages | ✓ Pass | No package outside the governed set required |
| XI. Testability | ✓ Pass | Domain, Application, Presentation layers all independently testable |
| No Git operations | ✓ Pass | Filesystem operations only |

**Complexity justification** (Principle I violation fix):

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| `HomeRemoteDataSource` uses Dio | Placeholder scaffold; no feature logic implemented yet | Cannot implement FR-001–FR-012 with a broken, unimplementable stub |
| `presentation/bloc/` location | Scaffold was auto-generated with wrong layer | Bloc belongs in `application/` per constitution; fix is a delete + recreate in correct path |

---

## Project Structure

### Documentation (this feature)

```text
specs/SCR-06-Home-Dashboard/mobile/001-home-dashboard/
├── plan.md              ← this file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── quickstart.md        ← Phase 1 output
├── contracts/           ← Phase 1 output
│   ├── home-bloc.md
│   └── home-screen.md
└── tasks.md             ← Phase 2 output (/speckit-tasks)
```

### Source Code (forge/)

```text
forge/lib/
├── config/
│   └── routes/
│       └── app_routes.dart                          REWRITE — add StatefulShellRoute + 6 branches
├── app/
│   └── get_it_setup.dart                            UPDATE — replace HomeRemoteDataSource registration
└── features/
    └── home/
        ├── domain/
        │   ├── entities/
        │   │   ├── dashboard_snapshot.dart           REWRITE (replaces home_entity.dart)
        │   │   └── today_workout.dart                NEW
        │   └── repositories/
        │       └── home_repository.dart              REWRITE interface
        ├── application/
        │   ├── bloc/                                 NEW DIRECTORY
        │   │   ├── home_bloc.dart                   REWRITE (moves from presentation/bloc/)
        │   │   ├── home_event.dart                  REWRITE
        │   │   └── home_state.dart                  REWRITE
        │   └── usecases/
        │       └── get_dashboard_snapshot_usecase.dart  REWRITE (replaces get_home_data_usecase.dart)
        ├── data/
        │   ├── datasources/
        │   │   └── home_local_data_source.dart       REWRITE (replaces home_remote_data_source.dart)
        │   ├── repositories/
        │   │   └── home_repository_impl.dart         REWRITE
        │   └── models/
        │       └── home_model.dart                   DELETE (JSON model, no backend)
        └── presentation/
            ├── bloc/                                 DELETE DIRECTORY (moved to application/bloc/)
            ├── screens/
            │   ├── home_screen.dart                  REWRITE
            │   ├── app_shell.dart                    NEW (StatefulShellRoute shell with 6-tab NavigationBar)
            │   └── placeholder_tab_screen.dart        NEW (stub for unimplemented tab roots)
            └── widgets/
                ├── home_header.dart                  NEW
                ├── loading_indicator.dart            NEW
                ├── empty_state_view.dart             NEW
                ├── today_workout_card.dart           NEW
                ├── rest_day_card.dart                NEW
                ├── quick_links_grid.dart             NEW
                └── error_card.dart                   NEW

forge/test/features/home/
├── application/
│   ├── bloc/
│   │   └── home_bloc_test.dart                      NEW
│   └── usecases/
│       └── get_dashboard_snapshot_usecase_test.dart NEW
├── data/
│   └── datasources/
│       └── home_local_data_source_test.dart         NEW
└── presentation/
    └── screens/
        └── home_screen_test.dart                    NEW
```

**Structure Decision**: Feature-First under `features/home/`. Bloc moved from incorrectly placed `presentation/bloc/` to `application/bloc/` per constitution Principle I. The `home/widgets/` directory already exists in the scaffold and is used for presentation widgets (kept as-is).

---

## Complexity Tracking

No new complexity violations. The only tracked items are the two scaffold violations being corrected (see Constitution Check above).
