# Implementation Plan: SCR-13 Assign / Edit Schedule

**Branch**: `001-scr-13-assign-edit-schedule` | **Date**: 2026-09-19 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/SCR-13-Assign-Edit-Schedule/mobile/001-scr-13-assign-edit-schedule/spec.md`

---

## Summary

Build the pushed "Assign / Edit Schedule" screen (SCR-13): given a `planId` (arriving from Plan Detail's existing "Schedule" button, or from SCR-12's per-day edit icon), the user selects one or more days of the week to schedule that plan on, with immediate client-side conflict detection against days already occupied by a different plan, then saves. This extends the same `schedule` feature module SCR-12 owns (currently data-layer only in the codebase, and specified-but-not-yet-implemented at the domain/application/presentation layers) by adding write capability to its `ScheduleRepository` contract and a new form Bloc/screen, rather than creating a second feature or a parallel repository. Mode (new vs. edit) is determined by data — whether the plan already has assigned days — not by which screen the user came from, which both matches this feature's own spec (User Story 1 vs. 2 are framed by existing-assignment state, not entry point) and resolves an inconsistency in the design mockup (SCR-10's "Schedule" button is mocked as always-blank, which would silently ignore a plan's true existing schedule).

---

## Technical Context

**Language/Version**: Dart (Flutter latest stable via FVM)

**Primary Dependencies**: `flutter_bloc` / `bloc` / `equatable`, `get_it`, `go_router`, `drift` (read/write of existing `schedule_entries` and read of `workout_plans` tables), `fpdart` (`Either`, matching the existing project-wide convention) — all already in use for this exact shape of feature (see SCR-12's plan.md Technical Context for the same pre-existing-dependency note re: ADR-030's list not yet including `fpdart`).

**Storage**: Read/write against the existing `schedule_entries` table only, via the existing `ScheduleLocalDataSource.saveEntry`/`deleteEntry`/`getAllEntries` methods — no new table or column. Read-only against `workout_plans` table via the existing `WorkoutPlanLocalDataSource.getPlanById`.

**Testing**: `flutter_test`, `bloc_test`, `mocktail` — governed set (ADR-030)

**Target Platform**: Android 10 / API 29+, iOS 15+, phone form factors only (ADR-022)

**Project Type**: Flutter mobile application (extends the existing `schedule` feature module — ADR-032)

**Performance Goals**: Conflict detection on day-chip tap is instantaneous (client-side, against data already loaded at screen-init — QA PR-01); save completes and returns to SCR-12 in one action (SC-001).

**Constraints**: Fully offline (Principle VI); this screen is the only place `schedule_entries` records are created/modified (design spec §1) — SCR-12 remains read-only; back navigation MUST be blocked while a save is in progress (FR-010); single fixed dark theme, tokens only (ADR-037); recurrence is always weekly with no user-facing alternative (FR-012); English only (ADR-016).

**Scale/Scope**: 5 user stories (P1×2, P2×2, P3×1), a 7-item day selector (no pagination), ~14 new source files, ~4 new test files.

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design — see below.*

| Principle | Gate Check | Status |
|-----------|-----------|--------|
| I — Clean Feature-First Architecture | Extends the existing `schedule` feature's `domain/`, `application/`, `presentation/` layers (shared with SCR-12); dependencies point inward | ✅ Pass |
| I — Domain independence | `ScheduleFormContext` entity has no Flutter/Drift imports | ✅ Pass |
| I — One owning feature per capability | Schedule creation/editing is owned by `schedule` (same feature as SCR-12's read side), not a new feature and not folded into `workout_plan` | ✅ Pass |
| I — No cross-feature internal imports | `ScheduleRepositoryImpl` composes `ScheduleLocalDataSource` + `WorkoutPlanLocalDataSource` (Data-layer interfaces), matching SCR-12's precedent; new widgets are `schedule`-local, shaped after (not imported from) `workout_plan`'s `SaveFailureBanner`/`PlanNotAvailableCard` | ✅ Pass |
| I — storage records stay in Data layer | `ScheduleEntryRecord` never leaves `ScheduleRepositoryImpl` | ✅ Pass |
| II — `flutter_bloc` sole state management | New `AssignScheduleBloc extends Bloc<...>` with explicit events; no Cubit | ✅ Pass |
| II — `go_router` sole router | New nested route `schedule` under the existing `:planId` branch in `app_router.dart`, alongside the already-coded (not-yet-routed) `edit` sibling | ✅ Pass |
| II — GetIt DI | New use case/Bloc registered in `get_it_setup.dart`; `ScheduleRepository` registration is shared with/extended from SCR-12's plan | ✅ Pass |
| II — Raw Drift exceptions → typed failures | `ScheduleRepositoryImpl` maps to `CacheException`, matching `WorkoutPlanRepositoryImpl` | ✅ Pass |
| III — Centralized routes/guards | Reached only via the existing app-lock-gated router; back-navigation lock during save uses `PopScope`, not a second routing mechanism | ✅ Pass |
| VI — Drift is sole store | All writes go through the existing `ScheduleLocalDataSource`; no new store | ✅ Pass |
| VII — Explicit states | Bloc emits `Loading`, `Ready`, `InvalidPlan`, `Saving`, `Saved`, `SaveFailure` — no blank/silent state | ✅ Pass |
| VII — Destructive/business-critical confirmation | Saving a schedule is not framed as destructive in the spec (no confirmation dialog required); failure retains user input per FR-008 | ✅ Pass |
| VIII — Dark theme, tokens only | All new widgets use `Theme.of(context)` / `AppColors.*` | ✅ Pass |
| IX — Governed dependencies only | No new package added | ✅ Pass |
| X — Centralized logging | No `print`/`debugPrint` | ✅ Pass |
| XI — Testability | Bloc unit tests (`bloc_test`), repository unit tests (`mocktail`), widget tests for all 5 states planned | ✅ Pass |
| Mandatory Rule — No Git operations | No git commands in any planned task | ✅ Pass |

No violations requiring Complexity Tracking.

**Cross-plan coordination notes (not constitution violations, but dependencies this plan surfaces)**:
1. This plan extends `ScheduleRepository` (the interface SCR-12's plan defines) with write methods. If SCR-12 is implemented first, this feature adds to that existing interface/impl rather than replacing it; if this feature is implemented first, SCR-12's own implementation must add its `getWeeklySchedule()` method to the same interface this plan creates. Either order works — the interface is additive.
2. FR-007 ("returns to the weekly schedule view with the change reflected") depends on the **caller** reloading after this screen pops — mirroring the existing `plan_detail_screen.dart` pattern (`await context.push(...); if (mounted) _reload();`), not on anything this screen itself does. SCR-12's edit-icon and empty-state-CTA navigation call sites need to follow that same await-then-reload pattern; this is called out for whoever implements SCR-12's navigation, not built here.
3. Per this feature's own Clarification (2026-09-19), SCR-12's empty-state CTA should navigate to the Plans List (`RoutePaths.plans`), not directly to this screen — the user reaches this screen via the Plans List → Plan Detail → the already-implemented "Schedule" button, with no new picker-mode plumbing needed anywhere.

---

## Project Structure

### Documentation (this feature)

```text
specs/SCR-13-Assign-Edit-Schedule/mobile/001-scr-13-assign-edit-schedule/
├── plan.md              # This file
├── research.md          # Phase 0 — decisions
├── data-model.md        # Phase 1 — ScheduleFormContext, AssignScheduleBloc state shape
├── quickstart.md        # Phase 1 — manual validation scenarios
├── contracts/
│   ├── schedule-repository.md   # ScheduleRepository contract (extends SCR-12's)
│   └── assign-schedule-bloc.md  # AssignScheduleBloc events/states contract
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
        │   │   └── schedule_form_context.dart      # ScheduleFormContext (planId, planName?, currentDays, occupiedDays)
        │   ├── repositories/
        │   │   └── schedule_repository.dart          # EXTENDED: adds loadAssignmentContext(), saveAssignment()
        │   └── usecases/
        │       ├── load_assignment_context_usecase.dart
        │       └── save_schedule_assignment_usecase.dart
        ├── application/
        │   └── bloc/
        │       ├── assign_schedule_event.dart          # AssignScheduleInitialized, DayToggled, SaveRequested, RetrySaveRequested
        │       ├── assign_schedule_state.dart           # Initial/Loading/Ready/InvalidPlan/Saving/Saved/SaveFailure
        │       └── assign_schedule_bloc.dart
        ├── data/
        │   └── repositories/
        │       └── schedule_repository_impl.dart        # EXTENDED: implement the two new methods
        └── presentation/
            ├── screens/
            │   └── assign_schedule_screen.dart           # SCR-13 screen (BlocBuilder root, PopScope save-lock)
            └── widgets/
                ├── plan_selector_display.dart              # Static, non-tappable plan name card (Out of Scope: no in-screen picker)
                ├── day_chip_row.dart                        # 7-chip tri-state (unselected/selected/conflict) row
                ├── day_chip.dart                             # Single circular chip
                ├── recurrence_row.dart                       # Static "Repeats weekly" row
                ├── invalid_plan_banner.dart                   # In-field banner replacing the plan selector (State D)
                ├── schedule_save_failure_banner.dart           # Top-of-screen error banner (schedule-local, shaped after workout_plan's SaveFailureBanner)
                └── save_schedule_button.dart                    # Footer button with enabled/disabled/saving visual states

forge/lib/config/routes/
└── app_router.dart      # Add nested GoRoute(path: 'schedule') under the existing :planId branch

forge/lib/app/
└── get_it_setup.dart    # Register/extend ScheduleRepository, LoadAssignmentContextUseCase, SaveScheduleAssignmentUseCase, AssignScheduleBloc

forge/test/
└── features/
    └── schedule/
        ├── data/
        │   └── repositories/
        │       └── schedule_repository_impl_test.dart   # EXTENDED — new methods' cases added to SCR-12's file
        ├── application/
        │   └── bloc/
        │       └── assign_schedule_bloc_test.dart         # bloc_test — all states + retry
        └── presentation/
            └── screens/
                └── assign_schedule_screen_test.dart        # widget tests — all 5 states render
```

**Structure Decision**: Extends the existing `schedule` feature rather than creating a new one (Principle I.5 — schedule assignment and schedule viewing are the same domain concept). The plan/day-chip/save-button widgets are new and feature-local since no existing reusable component covers a tri-state day selector or this exact plan-assignment banner shape (Rule 6/20) — the closest analogs (`workout_plan`'s `SaveFailureBanner`, `PlanNotAvailableCard`) are mirrored in shape, not imported, to respect feature boundaries (Principle I.5).

**Post-Design Re-check** (after Phase 1 `data-model.md`/`contracts/` below): No new table or schema change, dependency, Cubit, or second router/DI mechanism was introduced during design. All gates above remain ✅ Pass.

## Complexity Tracking

*No entries — no Constitution Check violations.*
