# Implementation Plan: SCR-14 Remove From Schedule Confirmation

**Branch**: `001-scr-14-remove-from-schedule` | **Date**: 2026-09-19 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/SCR-14-Remove-From-Schedule/mobile/001-scr-14-remove-from-schedule/spec.md`

---

## Summary

Build a `showDialog` modal confirmation (not a routed screen) that removes a single day's schedule assignment from the `schedule_entries` table, shown over the weekly schedule view when the user taps a day row's "Remove" icon. This mirrors an already-implemented, near-identical pattern in this codebase — `workout_plan`'s `DeletePlanBloc`/`DeletePlanDialog` (confirm → removing → success/failure → retry, `showDialog` invoked directly from the calling screen, no go_router route) — with the same structure but scoped to the `schedule` feature and styled lime (not red/danger), per this feature's own low-stakes-vs-irreversible design distinction. Adds a third write method to the same shared `ScheduleRepository` interface SCR-12 and SCR-13's plans already extend.

---

## Technical Context

**Language/Version**: Dart (Flutter latest stable via FVM)

**Primary Dependencies**: `flutter_bloc` / `bloc` / `equatable`, `get_it`, `drift` (write to the existing `schedule_entries` table only), `fpdart` (`Either`, matching the existing project-wide convention). No `go_router` involvement — this is a dialog, not a route, matching the established `DeletePlanDialog` precedent (no `/plans/:planId/delete` route exists either).

**Storage**: Write-only (delete) against the existing `schedule_entries` table via the existing `ScheduleLocalDataSource.deleteEntry(weekday)` method — no new table or column.

**Testing**: `flutter_test`, `bloc_test`, `mocktail` — governed set (ADR-030)

**Target Platform**: Android 10 / API 29+, iOS 15+, phone form factors only (ADR-022)

**Project Type**: Flutter mobile application (extends the existing `schedule` feature module — ADR-032)

**Performance Goals**: Single-tap confirm-to-removed flow, no perceptible delay beyond the local Drift write itself (SC-001).

**Constraints**: Fully offline (Principle VI); this dialog is the only place a single day's `scheduleEntry` is deleted independent of a full reassignment (SCR-13 handles reassignment); dismissal (Cancel/scrim/back) MUST be blocked only while the removal is in progress (FR-006); MUST NOT modify any other day or workout history (FR-007/FR-010); single fixed dark theme, lime (not danger) for the confirm/retry action per design's own intentional low-stakes distinction; English only (ADR-016).

**Scale/Scope**: 3 user stories (P1×2, P2×1), a single dialog widget with 3 visual states, ~6 new source files, ~2 new test files.

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design — see below.*

| Principle | Gate Check | Status |
|-----------|-----------|--------|
| I — Clean Feature-First Architecture | Extends the existing `schedule` feature's `domain/`, `application/`, `presentation/` layers (shared with SCR-12/SCR-13) | ✅ Pass |
| I — One owning feature per capability | Schedule-entry removal is owned by `schedule`, not `workout_plan` — even though its dialog is structurally mirrored from `workout_plan`'s `DeletePlanDialog`, no code is imported across the feature boundary | ✅ Pass |
| I — No cross-feature internal imports | `ScheduleRepositoryImpl` composes only `ScheduleLocalDataSource` (already the case for this method — no `WorkoutPlanLocalDataSource` needed here, unlike SCR-13); the new dialog/Bloc are `schedule`-local, shaped after (not imported from) `workout_plan`'s `DeletePlanDialog`/`DeletePlanBloc` | ✅ Pass |
| II — `flutter_bloc` sole state management | New `RemoveScheduleEntryBloc extends Bloc<...>`, mirroring `DeletePlanBloc`'s exact shape; no Cubit | ✅ Pass |
| II — `go_router` sole router | No new route — `showDialog` from the calling screen, matching the established `DeletePlanDialog` precedent (no second routing mechanism introduced) | ✅ Pass |
| II — GetIt DI | New use case/Bloc registered in `get_it_setup.dart`, `ScheduleRepository` extended (shared with SCR-12/13's plans) | ✅ Pass |
| II — Raw Drift exceptions → typed failures | `ScheduleRepositoryImpl.removeEntry` maps to `CacheException`, matching `WorkoutPlanRepositoryImpl`/`DeleteWorkoutPlanUseCase`'s pattern | ✅ Pass |
| III — Centralized routes/guards | No new route; reached only while already inside the app-lock-gated shell | ✅ Pass |
| VI — Drift is sole store | Only existing `ScheduleLocalDataSource.deleteEntry` is called; no new store | ✅ Pass |
| VII — Explicit states | Bloc emits `Confirmation`, `Removing`, `Success`, `Failure` — no blank/silent state | ✅ Pass |
| VII — Destructive-action confirmation | This is exactly the confirmation step Principle VII.2 calls for ("SHOULD request explicit confirmation where the action is destructive") | ✅ Pass |
| VIII — Dark theme, tokens only | Dialog uses `Theme.of(context)` / `AppColors.*`, specifically `AppColors.lime`/`AppColors.onLime` for the confirm/retry button (not `AppColors.danger`, per this feature's own design decision) | ✅ Pass |
| IX — Governed dependencies only | No new package | ✅ Pass |
| X — Centralized logging | No `print`/`debugPrint` | ✅ Pass |
| XI — Testability | Bloc unit tests (`bloc_test`), repository unit tests (`mocktail`), widget tests for all 3 dialog states planned | ✅ Pass |
| Mandatory Rule — No Git operations | No git commands in any planned task | ✅ Pass |

No violations requiring Complexity Tracking.

**Cross-plan coordination notes**:
1. This is the **third** feature to extend the shared `ScheduleRepository` interface (after SCR-12's `getWeeklySchedule()` and SCR-13's `loadAssignmentContext()`/`saveAssignment()`). Whichever of these three is implemented first should leave the interface open for the others — additive only, per the same note in SCR-12's and SCR-13's plans.
2. This dialog is invoked directly from SCR-12's weekly schedule view via a `showDialog` call (mirroring `plan_detail_screen.dart`'s `_onDelete` pattern exactly: `await showDialog<bool>(...); if (!mounted) return; if (result == true) _reload();`). This is simpler than SCR-12/13's pop-then-reload dependency, because the dialog overlays the *same* screen instance rather than being a separate pushed route — SCR-12's own remove-icon handler is expected to follow this exact await-then-reload pattern, not built here.
3. Per this feature's own Clarification (2026-09-19), SCR-12's weekly schedule view needs a small scope amendment to add a dedicated "Remove" icon per scheduled day row (alongside its existing edit icon) — not built here, flagged for whoever next touches SCR-12's spec/tasks.

---

## Project Structure

### Documentation (this feature)

```text
specs/SCR-14-Remove-From-Schedule/mobile/001-scr-14-remove-from-schedule/
├── plan.md              # This file
├── research.md          # Phase 0 — decisions
├── data-model.md        # Phase 1 — state shape (no new domain entity)
├── quickstart.md        # Phase 1 — manual validation scenarios
├── contracts/
│   ├── schedule-repository.md         # ScheduleRepository contract (extends SCR-12/13's)
│   └── remove-schedule-entry-bloc.md  # RemoveScheduleEntryBloc events/states contract
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
        │   ├── repositories/
        │   │   └── schedule_repository.dart      # EXTENDED: adds removeEntry(int weekday)
        │   └── usecases/
        │       └── remove_schedule_entry_usecase.dart
        ├── application/
        │   └── bloc/
        │       ├── remove_schedule_entry_event.dart   # RemoveScheduleEntryConfirmed(weekday)
        │       ├── remove_schedule_entry_state.dart    # Confirmation/Removing/Success/Failure
        │       └── remove_schedule_entry_bloc.dart
        ├── data/
        │   └── repositories/
        │       └── schedule_repository_impl.dart        # EXTENDED: implement removeEntry
        └── presentation/
            └── widgets/
                └── remove_schedule_entry_dialog.dart      # SCR-14 dialog (showDialog content)

forge/lib/app/
└── get_it_setup.dart    # Register/extend ScheduleRepository, RemoveScheduleEntryUseCase, RemoveScheduleEntryBloc

forge/test/
└── features/
    └── schedule/
        ├── data/
        │   └── repositories/
        │       └── schedule_repository_impl_test.dart   # EXTENDED — removeEntry cases added
        ├── application/
        │   └── bloc/
        │       └── remove_schedule_entry_bloc_test.dart   # bloc_test — all 4 states + retry
        └── presentation/
            └── widgets/
                └── remove_schedule_entry_dialog_test.dart  # widget tests — all 3 visual states
```

**Structure Decision**: Extends the existing `schedule` feature (shared with SCR-12/SCR-13) rather than creating a new one or placing it under `workout_plan` — schedule-entry removal is the same domain concept as schedule-entry creation/viewing (Principle I.5). The dialog/Bloc are new, `schedule`-local files shaped after `workout_plan`'s already-implemented `DeletePlanDialog`/`DeletePlanBloc` (structure, `PopScope`, `BlocConsumer` pattern, reused `InlineDialogError` from `core/widgets/`) rather than a speculative shared "confirmation dialog" abstraction — no such shared abstraction exists in the codebase today (every feature builds its own dialog widget), so introducing one here would be scope creep beyond this feature's actual need (Rule 6).

**Post-Design Re-check** (after Phase 1 design below): No new table or schema change, dependency, Cubit, or second routing mechanism introduced. All gates above remain ✅ Pass.

## Complexity Tracking

*No entries — no Constitution Check violations.*
