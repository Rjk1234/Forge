# Implementation Plan: SCR-22 Progress Comparison

**Branch**: `001-scr-22-progress-comparison` | **Date**: 2026-09-23 | **Spec**: [spec.md](spec.md)

## Summary

SCR-22 is the Progress Comparison screen — the 5th root tab in the app's bottom navigation. It reads all completed `WorkoutSession` records from Drift once per entry, computes per-exercise progress data in memory (top weight/reps/volume or type-appropriate metrics, chart data points, session deltas), and displays a horizontally scrollable exercise chip row, a `CustomPainter` line chart (≤12 sessions), and three stat tiles with signed delta indicators. Chip taps update the displayed exercise without re-reading Drift. The screen handles four Bloc states: Initial (skeleton), Loading (skeleton), Loaded (chip row + Main or Empty depending on selected exercise's session count), and Error (error card with Retry). The screen lives in a new `features/progress/` feature directory and introduces zero new tables.

**Key design decision**: `ProgressEmptyState` is NOT a Bloc state — it is a UI branch within `ProgressLoaded` driven by the selected exercise's `totalValidSessions < 2` condition. This keeps the Bloc surface minimal and chip-selection free of Drift reads (see research D-10, contracts/progress-bloc.md).

---

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x

**Primary Dependencies**: `flutter_bloc`, `go_router`, `get_it`, `equatable`, `fpdart` (all existing — no new packages)

**Storage**: Drift (existing) — `workout_sessions` table; SCR-22 reads via `WorkoutSessionRepository.getAllSessions()` only; no writes; no new tables

**Testing**: `flutter_test`, `bloc_test`, `mocktail` (all existing)

**Target Platform**: iOS + Android (mobile only, phone portrait — ADR-022 reduced scope)

**Performance Goals**: Skeleton appears within one frame of tab activation (SC-001); Drift read + in-memory computation of ≤20 exercises × ≤15 sessions completes in < 100ms; 12-point chart renders at 60fps without jank (SC-006)

**Constraints**: Offline-only; Drift sole persistence; single dark theme (ADR-037); `Bloc` only; `go_router` only; `GetIt` DI; no new packages; no Drift writes; read-only; chart via `CustomPainter` (no SVG package); `intl` package unavailable (ADR-030)

**Scale/Scope**: 1 new screen, 1 new Bloc (3 files), 1 new use-case, 2 new domain entities + 1 sealed class (3 files), 6 new presentation widgets, 3 amended files (`app_strings.dart`, `app_routes.dart`, `get_it_setup.dart`), 14 new AppStrings constants, 0 new tables

---

## Constitution Check

| Rule | Status | Note |
|---|---|---|
| No new package without ADR | ✅ PASS | No new packages; chart via `CustomPainter`; no SVG/intl packages |
| `Bloc` only (no `Cubit`) | ✅ PASS | `ProgressBloc extends Bloc`; skeleton uses local `StatefulWidget` (CLAUDE.md §45) |
| `go_router` only | ✅ PASS | Branch 4 `PlaceholderTabScreen` replaced with `BlocProvider + ProgressScreen`; no second router |
| `GetIt` DI | ✅ PASS | `GetExerciseProgressDataUseCase` → `registerLazySingleton`; `ProgressBloc` → `registerFactory` |
| Single dark theme | ✅ PASS | All colours from `AppColors`; no hardcoded hex values in widgets |
| No hardcoded strings | ✅ PASS | 14 new `AppStrings` constants; all UI copy references them |
| No hardcoded text styles | ✅ PASS | Uses `theme.textTheme.*` throughout |
| Domain layer purity | ✅ PASS | `ExerciseProgressData`, `ExerciseMetrics` in `progress/domain/`; no Drift imports in domain |
| `presentation/` layer imports | ✅ PASS | Screen imports `application/` (Bloc, states) and `domain/` entities only; no `data/` imports |
| No network calls | ✅ PASS | Zero network calls; reads via `WorkoutSessionRepository` (Drift) only |
| No Drift writes | ✅ PASS | `getAllSessions()` is read-only; screen lifecycle produces zero writes (FR-016) |
| Drift failure → typed state | ✅ PASS | `Left(AppException)` → `ProgressError`; raw exception message never surfaced to UI |
| All applicable states defined | ✅ PASS | Initial, Loading, Loaded, Error — all defined. Empty is a UI branch within Loaded, not a Bloc state |
| LoggingService on error path | ✅ PASS | `LoggingService.logError(exception, stackTrace)` called in `_onLoadRequested` Left branch (Constitution §X.1) |
| `ExerciseType` enum correctness | ✅ PASS | Uses `.weighted`, `.timeBased`, `.bodyweight` — confirmed from source |
| Error color token | ✅ PASS | `AppColors.danger` used for negative delta and error states (not the non-existent `AppColors.error`) |
| Cross-feature presentation imports | ✅ PASS | `ProgressErrorCard` created in `progress/presentation/widgets/` (cannot import `home/presentation/`) |

**Gate**: PASS — no violations. No ADR required.

---

## Project Structure

### Documentation (this feature)

```text
specs/SCR-22-Progress-Comparison/mobile/001-scr-22-progress-comparison/
├── plan.md              ← This file
├── spec.md              ← Feature specification (with clarifications)
├── research.md          ← 13 architecture decisions (D-01 through D-13)
├── data-model.md        ← Entity mapping, Bloc state hierarchy, stat tile display table
├── quickstart.md        ← 9 validation scenarios + test checklists
├── contracts/
│   └── progress-bloc.md  ← Bloc event/state contract + use-case contract + DI
└── tasks.md             ← Generated by /speckit-tasks (next step)
```

### Source Code

```text
forge/lib/
├── core/
│   └── strings/
│       └── app_strings.dart                              MODIFY: add 14 SCR-22 string constants
├── config/
│   └── routes/
│       └── app_routes.dart                               MODIFY: replace PlaceholderTabScreen on branch 4 with BlocProvider<ProgressBloc> + ProgressScreen
├── app/
│   └── get_it_setup.dart                                 MODIFY: register use-case + Bloc
└── features/
    └── progress/
        ├── domain/
        │   └── entities/
        │       ├── exercise_progress_data.dart            CREATE: ExerciseProgressData + ProgressDataPoint
        │       └── exercise_metrics.dart                  CREATE: ExerciseMetrics (sealed) + WeightedMetrics + TimedMetrics + BodyweightMetrics
        ├── application/
        │   ├── use_cases/
        │   │   └── get_exercise_progress_data_use_case.dart  CREATE
        │   └── bloc/
        │       ├── progress_event.dart                    CREATE: ProgressLoadRequested, ProgressExerciseSelected
        │       ├── progress_state.dart                    CREATE: ProgressInitial, ProgressLoading, ProgressLoaded, ProgressError
        │       └── progress_bloc.dart                     CREATE
        └── presentation/
            ├── screens/
            │   └── progress_screen.dart                   CREATE
            └── widgets/
                ├── progress_skeleton.dart                 CREATE: ShimmerBox-based skeleton (StatefulWidget)
                ├── exercise_chip.dart                     CREATE: single chip with active/inactive state
                ├── progress_chip_row.dart                 CREATE: SingleChildScrollView horizontal + chip list
                ├── progress_chart_card.dart               CREATE: Card + LayoutBuilder + CustomPaint
                ├── stat_tile.dart                         CREATE: label + value + signed delta
                ├── progress_empty_state.dart              CREATE: title + subtitle (no CTA)
                └── progress_error_card.dart               CREATE: danger card + title + body + Retry button

forge/test/
└── features/
    └── progress/
        ├── application/
        │   ├── use_cases/
        │   │   └── get_exercise_progress_data_use_case_test.dart  CREATE: 12 use-case scenarios
        │   └── bloc/
        │       └── progress_bloc_test.dart                        CREATE: 9 Bloc scenarios
        └── presentation/
            └── screens/
                └── progress_screen_test.dart                      CREATE: 11 widget scenarios
```

**No new tables. No `build_runner` run needed for SCR-22.**

---

## Complexity Tracking

No constitution violations. No complexity justification required.

---

## Phase Dependencies

```
Phase 1 (AppStrings): No prerequisites.
Phase 2 (Foundational — domain entities + events + states + use-case): No prerequisites; all files independent.
Phase 3 (ProgressBloc): Phase 2 (events + states + use-case must exist).
Phase 4 (Presentation widgets — ProgressSkeleton, ExerciseChip, ProgressChipRow, ProgressEmptyState, ProgressErrorCard): Phase 1 (AppStrings).
Phase 5 (ProgressChartCard + StatTile): Phase 1 (AppStrings) + Phase 2 (ExerciseMetrics needed for StatTile type branching).
Phase 6 (ProgressScreen): Phase 3 (Bloc) + Phase 4 + Phase 5.
Phase 7 (Route + DI): Phase 3 (Bloc) + Phase 6 (Screen).
Phase 8 (Tests): All prior phases.
Phase 9 (Polish): All prior phases.
```

Phases 1 and 2 can start in parallel (all independent files).
Phase 3 depends on Phase 2. Phases 4 and 5 depend on Phase 1 (and Phase 2 for typed metrics in StatTile).
Phase 6 depends on 3 + 4 + 5. Phase 7 depends on 3 + 6.
Phases 8 and 9 depend on all.
