# Implementation Plan: SCR-15 Workout Pre-Start / Overview

**Branch**: `001-scr-15-workout-prestart-overview` | **Date**: 2026-09-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/SCR-15-Workout-PreStart-Overview/mobile/001-scr-15-workout-prestart-overview/spec.md`

---

## Summary

Build the "Workout Pre-Start / Overview" screen (SCR-15): a pushed route entered from either Plan Detail (SCR-10) or the Weekly Schedule (SCR-12), which reads the referenced workout plan from Drift via the existing `GetWorkoutPlanByIdUseCase`, renders a shimmer skeleton while loading, then presents every exercise with type-appropriate targets (weighted: Sets/Reps/Weight; bodyweight: Sets/Reps; time-based: Sets/Duration) in a scrollable card list above a "Begin Workout" footer button. If the plan is gone or has no exercises, a centred blocking state is shown with no begin option. If the Drift read throws, a distinct error state with Retry and a secondary back action is shown. Navigation to SCR-16 (Active Workout) is wired as a route push but SCR-16 itself remains a stub.

This feature extends the existing `workout_plan` feature (owned Bloc/use-case/presentation layer) using only already-registered dependencies — no new table or column, no new repository, no new package. It also updates the SCR-12 schedule branch to complete the `TODO(SCR-15)` stubs wired in that implementation.

---

## Technical Context

**Language/Version**: Dart (Flutter latest stable via FVM)

**Primary Dependencies**: `flutter_bloc`/`bloc`/`equatable`, `get_it`, `go_router`, `drift` (read-only via existing `WorkoutPlanLocalDataSource.getPlanById`), `fpdart` (`Either`) — all pre-existing; no new package (ADR-030)

**Storage**: Read-only from the existing `workout_plans` table via `GetWorkoutPlanByIdUseCase` → `WorkoutPlanRepository.getPlanById` → `WorkoutPlanLocalDataSource.getPlanById`. No new table or column. SCR-15 writes nothing to Drift.

**Testing**: `flutter_test`, `bloc_test`, `mocktail` — governed set (ADR-030)

**Target Platform**: Android 10 / API 29+, iOS 15+, phone form factors only (ADR-022)

**Project Type**: Flutter mobile application — extends the existing `workout_plan` feature module (ADR-032)

**Performance Goals**: Loading state visible only during the Drift read (typically <50 ms local latency); skeleton resolves to content or a blocking/error state within one frame after the future completes (SC-001).

**Constraints**: Fully offline (Principle VI); SCR-15 MUST NOT write to Drift at any state (FR-007); `PreStartBloc` must guard against concurrent load attempts on rapid Retry taps (FR-009); single fixed dark theme with design-system tokens only (ADR-037); English only (ADR-016); no `Cubit` (II.1).

**Scale/Scope**: 3 user stories (US1: P1, US2: P1, US3: P2), ~8 new source files, ~3 new test files, ~2 modified source files (routes + DI), and ~4 modified schedule-layer files (SCR-12 TODO completion).

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design — see below.*

| Principle | Gate Check | Status |
|-----------|-----------|--------|
| I — Clean Feature-First Architecture | `PreStartBloc` in `workout_plan/application/bloc/`; presentation imports application only; no data-layer import in presentation | ✅ Pass |
| I — Domain independence | No new domain entity; reuses `WorkoutPlanDetail` + `PlanExercise` from existing `workout_plan/domain/` — no Flutter/Drift import in domain | ✅ Pass |
| I — One owning feature per capability | Pre-start overview is owned by `workout_plan` (reads plan data, nested under `/plans/:planId`); not split across features | ✅ Pass |
| I — No cross-feature internal imports | `PreStartBloc` uses `GetWorkoutPlanByIdUseCase` (owned by `workout_plan`); schedule-layer TODO completion touches `schedule/presentation/` only | ✅ Pass |
| I — storage records stay in Data layer | No new storage record; `WorkoutPlanRecord` never leaves `WorkoutPlanLocalDataSource` (unchanged from prior features) | ✅ Pass |
| II — `flutter_bloc` sole state management | New `PreStartBloc extends Bloc<...>` with explicit events; no Cubit | ✅ Pass |
| II — `go_router` sole router | New `start` nested route added under `:planId` alongside `edit` and `schedule`; no second router | ✅ Pass |
| II — GetIt DI | `PreStartBloc` registered as `registerFactory` in `get_it_setup.dart`; `GetWorkoutPlanByIdUseCase` is already registered | ✅ Pass |
| II — Raw Drift exceptions → typed failures | `WorkoutPlanRepositoryImpl.getPlanById` already wraps Drift in `CacheException`; `PreStartBloc` folds `Left` to `PreStartError` | ✅ Pass |
| III — Centralized routes/guards | Entered only via the existing app-lock-gated router; route constant centralized in `app_routes.dart` | ✅ Pass |
| VI — Drift is sole store | No network call, no new store; all reads through existing `WorkoutPlanLocalDataSource` | ✅ Pass |
| VII — Explicit states | Bloc emits `Initial`, `Loading`, `Loaded`, `Unavailable`, `Error` — no blank/silent state (FR-001, FR-004, FR-005) | ✅ Pass |
| VII — No destructive action requiring confirmation | SCR-15 is read-only; "Begin Workout" is not destructive; no confirmation dialog required | ✅ Pass |
| VIII — Dark theme, tokens only | All new widgets use `Theme.of(context)` / `AppColors.*` / `textTheme.*` | ✅ Pass |
| IX — Governed dependencies only | No new package added | ✅ Pass |
| X — Centralized logging | No `print`/`debugPrint` | ✅ Pass |
| XI — Testability | Bloc unit tests (`bloc_test`), widget tests for all 4 rendered states planned | ✅ Pass |
| Mandatory Rule — No Git operations | No git commands in any planned task | ✅ Pass |

No violations requiring Complexity Tracking.

**Cross-plan coordination notes** (not violations):
1. SCR-15 completes the `TODO(SCR-15)` navigation stubs left in `weekly_schedule_screen.dart` by SCR-12's plan. The `onStartDay` callback in `DayRow` / `WeekScheduleList` needs to carry both `planId` and `weekday` (currently only passes `planId`) so the pre-start screen can render the scheduling context line. Tasks in this plan include updating those three files.
2. "Begin Workout" navigates to SCR-16 (Active Workout). SCR-16 does not exist yet — the route push is wired with a new `RoutePaths.activeWorkout` constant, but the route builder renders a placeholder. This mirrors the SCR-12 pattern for SCR-13/15 stubs.
3. `PlanNotAvailableCard` in `workout_plan/presentation/widgets/` is not reused for SCR-15's invalid state: it uses a different layout (card container vs. full-screen centred), different icon, and a different button label. A new `PreStartUnavailableState` widget is created instead.

---

## Project Structure

### Documentation (this feature)

```text
specs/SCR-15-Workout-PreStart-Overview/mobile/001-scr-15-workout-prestart-overview/
├── plan.md              # This file
├── research.md          # Phase 0 — decisions
├── data-model.md        # Phase 1 — state shape and entities
├── quickstart.md        # Phase 1 — manual validation scenarios
├── contracts/
│   └── pre-start-bloc.md     # PreStartBloc events/states contract
├── spec.md              # Feature specification (input)
├── checklists/
│   └── requirements.md  # G-01 quality checklist (existing)
└── tasks.md             # Phase 2 — generated by /speckit-tasks
```

### Source Code

**New files:**

```text
forge/lib/features/workout_plan/
├── application/
│   └── bloc/
│       ├── pre_start_event.dart          # PreStartRequested, PreStartRetried
│       ├── pre_start_state.dart          # Initial/Loading/Loaded/Unavailable/Error
│       └── pre_start_bloc.dart           # PreStartBloc — uses GetWorkoutPlanByIdUseCase
└── presentation/
    ├── screens/
    │   └── pre_start_screen.dart         # WorkoutPreStartScreen (StatefulWidget, shimmer controller)
    └── widgets/
        ├── pre_start_skeleton.dart       # 3-card shimmer skeleton (State A)
        ├── exercise_preview_card.dart    # Single exercise card with type dot + field grid (State B)
        ├── pre_start_unavailable_state.dart  # Centred alert-circle + "Back to Schedule" (State C)
        └── pre_start_error_state.dart    # Centred calendar-icon + Retry + secondary back (State D)
```

**Modified files:**

```text
forge/lib/
├── app/
│   └── get_it_setup.dart             # Register PreStartBloc as factory
├── config/routes/
│   └── app_routes.dart               # Add 'start' nested route under :planId;
│                                     # update workoutPreStart constant to '/plans/:planId/start';
│                                     # add activeWorkout = '/workout/active' stub constant
├── core/strings/
│   └── app_strings.dart              # Add SCR-15 strings section
└── features/
    └── schedule/
        └── presentation/
            ├── screens/
            │   └── weekly_schedule_screen.dart   # Complete TODO(SCR-15) onStartDay navigation
            └── widgets/
                ├── day_row.dart                  # Update onStartTap to pass weekday too
                └── week_schedule_list.dart       # Update onStartDay typedef to carry weekday
```

**New test files:**

```text
forge/test/features/workout_plan/
├── application/
│   └── bloc/
│       └── pre_start_bloc_test.dart
└── presentation/
    └── screens/
        └── pre_start_screen_test.dart
```
