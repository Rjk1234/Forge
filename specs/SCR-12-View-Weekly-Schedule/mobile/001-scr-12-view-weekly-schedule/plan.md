# Implementation Plan: SCR-12 View Weekly Workout Schedule

**Branch**: `001-scr-12-view-weekly-schedule` | **Date**: 2026-09-19 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/SCR-12-View-Weekly-Schedule/mobile/001-scr-12-view-weekly-schedule/spec.md`

---

## Summary

Build the Schedule tab (SCR-12): a read-only weekly view showing all 7 days (Mon–Sun), each day's assigned plan (or "Rest day"), a highlighted "today" row with a one-tap Start action into the workout pre-start flow, an empty state prompting the user to schedule a plan, and an error state with retry when the local read fails. The `schedule` feature currently has only a `data/` layer (`ScheduleEntryRecord`, `ScheduleLocalDataSource`) — this plan adds `domain/`, `application/` (Bloc), and `presentation/` layers, composing the existing `ScheduleLocalDataSource` and `WorkoutPlanLocalDataSource` (the same composition pattern already used by the Home feature's dashboard data source) into a new `ScheduleRepository` that resolves each weekday to a plan name or rest state, treating orphaned plan references as unscheduled per FR-009. The existing `RoutePaths.schedule` route's placeholder builder is replaced with the real screen; no new route paths are required by this feature (Start/Edit navigate to routes owned by other features/SCR-13/SCR-15, which are out of scope here and stubbed as `TODO` navigation until those features exist).

---

## Technical Context

**Language/Version**: Dart (Flutter latest stable via FVM)

**Primary Dependencies**: `flutter_bloc` / `bloc` / `equatable` (state management), `get_it` (DI), `go_router` (routing), `drift` (read of existing `schedule_entries` and `workout_plans` tables) — all from the governed set (ADR-030). This feature also uses `fpdart`'s `Either` for repository failure typing, matching the existing convention in `workout_plan` and `home` features (`AppException` + `Either`) — pre-existing project convention, not a new dependency introduced by this feature.

**Storage**: Read-only against two existing tables — `schedule_entries` table (`ScheduleEntryRecord`, keyed by weekday int) and `workout_plans` table (`WorkoutPlanRecord`, keyed by planId). No new table or write path is introduced.

**Testing**: `flutter_test`, `bloc_test`, `mocktail` — governed set (ADR-030)

**Target Platform**: Android 10 / API 29+, iOS 15+, phone form factors only (ADR-022)

**Project Type**: Flutter mobile application (single app, existing `schedule` feature module — ADR-032)

**Performance Goals**: Today's workout identifiable and startable in one tap within 5 seconds of opening the tab (SC-001); local Drift reads are asynchronous and effectively instantaneous, so this is dominated by widget build time, not data access

**Constraints**: Fully offline, no network call (Principle VI); read-only screen — MUST NOT write to Drift (Assumption); single fixed dark theme, tokens only (ADR-037); no live clock listener — "today" is re-evaluated only on screen open/resume (Clarification, 2026-09-19); English only (ADR-016); no WCAG/screen-reader certification gate (ADR-028, reduced scope) — the design spec's accessibility notes are followed as good practice, not a mandatory test gate

**Scale/Scope**: 4 user stories (P1×2, P2, P3), fixed 7-row list (no pagination/virtualization needed), ~13 new source files, ~4 new test files

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design — see below.*

| Principle | Gate Check | Status |
|-----------|-----------|--------|
| I — Clean Feature-First Architecture | `schedule` feature gains `domain/`, `application/`, `presentation/` alongside its existing `data/`; dependencies point inward (presentation → application → domain ← data) | ✅ Pass |
| I — Domain independence | `WeeklySchedule`, `ScheduleDay` entities have no Flutter/Drift imports | ✅ Pass |
| I — No cross-feature internal imports | `ScheduleRepositoryImpl` imports `WorkoutPlanLocalDataSource` (an existing **Data**-layer datasource interface), not any of `workout_plan`'s domain/application/presentation — mirrors the exact pattern already used by `HomeDashboardLocalDataSourceImpl` | ✅ Pass |
| I — storage records stay in Data layer | `ScheduleEntryRecord` / `WorkoutPlanRecord` are mapped to `WeeklySchedule`/`ScheduleDay` in the repository impl; never passed to Bloc or UI | ✅ Pass |
| II — `flutter_bloc` sole state management | New `WeekScheduleBloc extends Bloc<...>` with explicit events (`WeekScheduleRequested`, `WeekScheduleRetried`); no Cubit introduced | ✅ Pass |
| II — `go_router` sole router | `RoutePaths.schedule`'s existing `GoRoute` builder is swapped from `PlaceholderTabScreen` to the real screen; no second routing mechanism | ✅ Pass |
| II — GetIt DI | New datasource/repository/usecase/bloc registered in `get_it_setup.dart` following the existing `registerLazySingleton`/`registerFactory` pattern | ✅ Pass |
| II — Raw Drift exceptions → typed failures | `ScheduleRepositoryImpl` catches and maps to `CacheException` (existing `AppException` subtype), matching `WorkoutPlanRepositoryImpl` | ✅ Pass |
| III — Centralized routes/guards | Screen is reached only via the existing `StatefulShellRoute` branch already gated by the app-lock `redirect`; no new guard needed | ✅ Pass |
| VI — Drift is sole store; read-only here | No `saveEntry`/`deleteEntry` call is made from this feature's new code | ✅ Pass |
| VII — Explicit states | Bloc emits `WeekScheduleLoading`, `WeekSchedulePopulated`, `WeekScheduleEmpty`, `WeekScheduleError` — no blank/silent state | ✅ Pass |
| VIII — Dark theme, tokens only | All new widgets use `Theme.of(context)` / `AppColors.*`; no hardcoded hex | ✅ Pass |
| VIII — Reduced-scope accessibility | Touch-target and semantic-label guidance from the design spec applied as best effort; not gated by a WCAG test | ✅ Pass |
| IX — Governed dependencies only | No new package added; reuses `fpdart`/`equatable`/etc. already present in `pubspec.yaml` | ✅ Pass |
| X — Centralized logging | No `print`/`debugPrint`; orphaned schedule-entry cleanup (FR-009) logs via the existing logging service, not ad hoc | ✅ Pass |
| XI — Testability | Bloc unit tests (`bloc_test`), repository unit tests (`mocktail`), widget tests for loading/empty/populated/error states planned | ✅ Pass |
| Mandatory Rule — No Git operations | No git commands in any planned task | ✅ Pass |

No violations requiring Complexity Tracking.

**Pre-existing, out-of-scope observation (not a gate failure introduced by this feature)**: `pubspec.yaml` includes `dio` and `shared_preferences`, which are not in the ADR-030 governed list, and `fpdart` is used project-wide for `Either`-based failure handling without an explicit ADR-030 entry. This plan does not add any of these — it only continues the existing, already-established `fpdart`/`AppException` convention used by `workout_plan` and `home`. Resolving the ADR-030 list mismatch is outside this feature's scope.

---

**Post-Design Re-check** (after Phase 1 `data-model.md`/`contracts/` below): No new entities, fields, or navigation targets introduced during design require a schema change, a new dependency, a Cubit, or a second router/DI mechanism. The orphaned-entry cleanup (research.md Decision 2) is the only write path and is confined to the Data layer, consistent with Principle VI.2 (typed failure states, no silent data loss) and does not turn this into a user-facing write screen. All gates above remain ✅ Pass.

## Project Structure

### Documentation (this feature)

```text
specs/SCR-12-View-Weekly-Schedule/mobile/001-scr-12-view-weekly-schedule/
├── plan.md              # This file
├── research.md          # Phase 0 — technology/design decisions
├── data-model.md         # Phase 1 — WeeklySchedule, ScheduleDay entities
├── quickstart.md        # Phase 1 — manual validation scenarios
├── contracts/
│   ├── schedule-repository.md   # ScheduleRepository contract
│   └── week-schedule-bloc.md    # WeekScheduleBloc events/states contract
├── spec.md              # Feature specification (input)
├── checklists/
│   └── requirements.md  # G-01 quality checklist
└── tasks.md             # Phase 2 — generated by /speckit-tasks
```

### Source Code

```text
forge/lib/
└── features/
    └── schedule/
        ├── domain/
        │   ├── entities/
        │   │   ├── weekly_schedule.dart           # WeeklySchedule (7x ScheduleDay, todayWeekday)
        │   │   └── schedule_day.dart               # ScheduleDay (weekday, plan info or null, isToday)
        │   ├── repositories/
        │   │   └── schedule_repository.dart        # ScheduleRepository (abstract)
        │   └── usecases/
        │       └── get_weekly_schedule_usecase.dart
        ├── application/
        │   └── bloc/
        │       ├── week_schedule_bloc.dart          # WeekScheduleBloc
        │       ├── week_schedule_event.dart          # WeekScheduleRequested, WeekScheduleRetried
        │       └── week_schedule_state.dart          # Loading/Populated/Empty/Error
        ├── data/
        │   ├── models/
        │   │   └── schedule_entry_record.dart    # (existing — unchanged)
        │   ├── datasources/
        │   │   └── schedule_local_data_source.dart   # (existing — unchanged)
        │   └── repositories/
        │       └── schedule_repository_impl.dart     # NEW — composes Schedule + WorkoutPlan datasources
        └── presentation/
            ├── screens/
            │   └── weekly_schedule_screen.dart        # SCR-12 screen (BlocBuilder root)
            └── widgets/
                ├── week_schedule_list.dart             # 7-item list; picks Loading/Populated/Empty/Error
                ├── day_row.dart                         # Single day row (plan/rest, edit icon or Start)
                ├── day_badge.dart                        # Day name + day number, lime when today
                ├── start_workout_button.dart              # Lime pill Start action
                ├── schedule_skeleton_list.dart             # 7x ShimmerBox-based skeleton rows
                ├── schedule_empty_state.dart               # Empty state (mirrors PlansEmptyState shape)
                └── schedule_error_card.dart                 # Full-screen error+retry card (mirrors home/ErrorCard)

forge/lib/config/routes/
└── app_router.dart      # Branch 2 (Schedule) builder swapped from PlaceholderTabScreen to WeeklyScheduleScreen

forge/lib/app/
└── get_it_setup.dart    # Register ScheduleRepository, GetWeeklyScheduleUseCase, WeekScheduleBloc

forge/test/
└── features/
    └── schedule/
        ├── data/
        │   └── repositories/
        │       └── schedule_repository_impl_test.dart   # mocktail — orphaned-plan handling, error mapping
        ├── application/
        │   └── bloc/
        │       └── week_schedule_bloc_test.dart           # bloc_test — all 4 states + retry
        └── presentation/
            └── screens/
                └── weekly_schedule_screen_test.dart        # widget tests — loading/populated/empty/error render
```

**Structure Decision**: Extend the existing `schedule` feature in place (it already owns `data/`) rather than creating a parallel feature — this satisfies Principle I.5 (one owning feature per capability). The repository composes two existing Data-layer datasource interfaces (`ScheduleLocalDataSource`, `WorkoutPlanLocalDataSource`) exactly as `HomeDashboardLocalDataSourceImpl` already does, so no cross-feature domain/presentation import is introduced. New feature-local widgets (`schedule_empty_state.dart`, `schedule_error_card.dart`) mirror the shape of `workout_plan`'s `PlansEmptyState`/`PlanNotAvailableCard` and `home`'s `ErrorCard`, which are themselves feature-local rather than shared `core/widgets` — no existing shared component covers this screen's specific empty/error copy and icon, so new feature-local widgets are added rather than a speculative shared abstraction (Rule 6).

---

## Complexity Tracking

*No entries — no Constitution Check violations.*
