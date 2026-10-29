# Implementation Plan: SCR-16 Active Workout

**Branch**: `001-scr-16-active-workout` | **Date**: 2026-09-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/SCR-16-Active-Workout/mobile/001-scr-16-active-workout/spec.md`

## Summary

SCR-16 is the set-by-set workout logging screen. The user enters from SCR-15, logs or skips each set across all exercises, and either Finishes (writes the session to Drift and navigates to SCR-19) or Cancels (routes to SCR-18 without writing). The entire session is held in memory until a successful Finish. A Pause/Resume overlay is supported. Inline validation blocks invalid field values before a set can be logged.

The `workout_session` feature already exists with a complete domain and data layer (entities `WorkoutSession`, `SessionExercise`, `ActualSet`; storage records and tables; repository and local data source). SCR-16 adds the **application layer** (`ActiveWorkoutBloc`) and **presentation layer** (`ActiveWorkoutScreen` + 3 supporting widgets) to that feature. Two existing entities require backward-compatible field additions (`ActualSet.skipped` and `WorkoutSession.startedAt`). One new use case (`SaveWorkoutSessionUseCase`) is needed.

## Technical Context

**Language/Version**: Dart (Flutter stable via FVM)

**Primary Dependencies**: `flutter_bloc` / `bloc` / `equatable` (state management); `drift` (persistence); `go_router` (navigation); `get_it` (DI) — all within the governed set (ADR-030)

**Storage**: Drift — `workout_sessions` table, keyed by `sessionId` (UUID string). No new table; two additive columns (`started_at`, `skipped`).

**Testing**: `flutter_test` / `bloc_test` / `mocktail`

**Target Platform**: Android 10+ / iOS 15+ (phone portrait — ADR-022 reduced scope)

**Project Type**: Flutter mobile app — Clean Feature-First Architecture

**Performance Goals**: No network I/O. Drift write on Finish is a single local insert-or-replace transaction. Field validation is synchronous. No measurable performance constraint applies.

**Constraints**: Fully offline (ADR-008); single dark theme (ADR-037); no new packages; all execution state in memory until Finish; no session recovery on app kill.

**Scale/Scope**: Single local user. A session has ≤ N exercises × M sets per exercise (plan-bounded). No pagination or lazy loading required.

## Constitution Check

| Principle | Gate | Status |
|---|---|---|
| Fully offline (Principle V) | No network call introduced | ✅ PASS |
| Drift is the sole store (Principle VI) | `WorkoutSessionRepository.saveSession` via existing table | ✅ PASS |
| `flutter_bloc` / Bloc only (Principle II) | New `ActiveWorkoutBloc extends Bloc<...>` — no Cubit | ✅ PASS |
| `go_router` only (Principle II) | Route added to existing centralized config | ✅ PASS |
| GetIt DI (Principle II) | `registerFactory<ActiveWorkoutBloc>` + `registerLazySingleton<SaveWorkoutSessionUseCase>` | ✅ PASS |
| No new dependency (ADR-030) | All dependencies already in governed set | ✅ PASS |
| Single dark theme (ADR-037) | No hardcoded colors; AppColors/colorScheme only | ✅ PASS |
| No hardcoded strings (CLAUDE.md) | New AppStrings section for SCR-16 | ✅ PASS |
| Clean Architecture layer rules (Principle I) | Domain ← Application ← Presentation; data/ not imported from presentation/ | ✅ PASS |
| All states defined (ADR-027) | Active, Validation Error, Paused, Write Error — all handled | ✅ PASS |
| Validation trigger documented (ADR-026) | On Complete Set tap; clears in real time on field change | ✅ PASS |
| No Drift call from build() (CLAUDE.md rule 43) | All Drift access in data source, called only from repository, called only from use case, called only from Bloc | ✅ PASS |

No violations. No Complexity Tracking section required.

## Project Structure

### Documentation (this feature)

```text
specs/SCR-16-Active-Workout/mobile/001-scr-16-active-workout/
├── spec.md
├── plan.md              ← this file
├── research.md          ← Phase 0 decisions
├── data-model.md        ← Phase 1 entities, state model, AppStrings
├── quickstart.md        ← Phase 1 manual validation guide
├── contracts/
│   └── active-workout-bloc.md    ← Phase 1 Bloc contract
└── checklists/
    └── requirements.md
```

### Source Code

```text
# Existing feature — workout_session
forge/lib/features/workout_session/
│
├── domain/
│   ├── entities/
│   │   ├── workout_session.dart          ← MODIFY: add startedAt: DateTime
│   │   ├── session_exercise.dart         ← no change
│   │   └── actual_set.dart               ← MODIFY: add skipped: bool
│   ├── repositories/
│   │   └── workout_session_repository.dart   ← no change
│   └── usecases/
│       └── save_workout_session_usecase.dart  ← NEW
│
├── data/
│   ├── datasources/
│   │   └── workout_session_local_data_source.dart  ← no change
│   ├── mappers/
│   │   └── workout_session_mapper.dart    ← MODIFY: new fields
│   ├── models/
│   │   ├── workout_session_record.dart     ← MODIFY: add startedAt
│   │   └── actual_set_record.dart          ← MODIFY: add skipped
│   └── repositories/
│       └── workout_session_repository_impl.dart ← no change
│
├── application/
│   └── bloc/                                    ← NEW directory
│       ├── active_workout_event.dart             ← NEW
│       ├── active_workout_state.dart             ← NEW
│       └── active_workout_bloc.dart              ← NEW
│
└── presentation/
    ├── screens/
    │   └── active_workout_screen.dart            ← NEW
    └── widgets/
        ├── set_field_row.dart                    ← NEW
        ├── set_progress_row.dart                 ← NEW
        └── paused_workout_overlay.dart           ← NEW

# Cross-cutting changes
forge/lib/core/strings/app_strings.dart           ← MODIFY: add SCR-16 strings
forge/lib/config/routes/app_routes.dart           ← MODIFY: add activeWorkout constants + GoRoute
forge/lib/app/get_it_setup.dart                   ← MODIFY: register SaveWorkoutSessionUseCase + ActiveWorkoutBloc

# Tests
forge/test/features/workout_session/
├── application/bloc/
│   └── active_workout_bloc_test.dart             ← NEW
└── presentation/screens/
    └── active_workout_screen_test.dart           ← NEW
```

**Structure Decision**: SCR-16 lives entirely in the existing `workout_session` feature. The domain and data layers are already present (records, tables, repository, data source). Adding application/ and presentation/ sub-trees follows the established feature structure pattern (see `workout_plan` for reference). No new feature directory is created.
