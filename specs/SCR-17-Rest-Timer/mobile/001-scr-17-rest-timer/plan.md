# Implementation Plan: SCR-17 Rest Timer

**Branch**: `001-scr-17-rest-timer` | **Date**: 2026-09-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/SCR-17-Rest-Timer/mobile/001-scr-17-rest-timer/spec.md`

## Summary

SCR-17 is an interstitial rest-timer screen that appears automatically between sets during an active workout (SCR-16). The rest period duration comes from `PlanExercise.restPeriodSec` (already in memory via `WorkoutPlanDetail`). The screen counts down in MM:SS format; the user can tap Skip Rest at any time (or let the timer expire naturally) to return to SCR-16 at the next set or exercise. The OS back gesture is treated identically to Skip Rest.

SCR-17 lives in the existing `workout_session` feature. Implementation adds:
- A dedicated `RestTimerBloc` (application layer)
- A `RestTimerScreen` widget (presentation layer)
- A new `GoRoute` at `/workout/rest`
- Additive amendments to `ActiveWorkoutRunning` state and `ActiveWorkoutBloc` logic (2 new state fields + 1 new event) to trigger SCR-17 navigation after set completion when `restPeriodSec > 0`
- No new domain entities, no Drift changes, no new packages

**Dependency**: SCR-16 (Active Workout) application/ and presentation/ files must be implemented before SCR-17. The `ActiveWorkoutBloc`, `ActiveWorkoutRunning` state, and `ActiveWorkoutScreen` do not yet exist in the codebase.

## Technical Context

**Language/Version**: Dart (Flutter stable via FVM)

**Primary Dependencies**: `flutter_bloc` / `bloc` / `equatable` (state management); `go_router` (navigation); `get_it` (DI); `dart:async` (`Timer.periodic`) — all within the governed set (ADR-030)

**Storage**: None — rest timer state is in-memory only; no Drift read or write occurs.

**Testing**: `flutter_test` / `bloc_test` / `mocktail`

**Target Platform**: Android 10+ / iOS 15+ (phone portrait — ADR-022 reduced scope)

**Project Type**: Flutter mobile app — Clean Feature-First Architecture

**Performance Goals**: No network I/O. No Drift I/O. Countdown tick is `Timer.periodic` at 1-second resolution — sub-millisecond overhead per tick.

**Constraints**: Fully offline (ADR-008); single dark theme (ADR-037); no new packages; timer state is transient (lost if app is killed; expected per spec FR-009 and SCR-16 spec assumptions); app-backgrounded timer behavior is deferred (SRS-NFR-2A, PD-007).

**Scale/Scope**: Single local user. One active rest timer at a time. Timer runs for at most `restPeriodSec` seconds (typically 30–300).

## Constitution Check

| Principle | Gate | Status |
|---|---|---|
| Fully offline (Principle V) | No network call introduced | ✅ PASS |
| Drift is the sole store (Principle VI) | No Drift read/write; timer is in-memory | ✅ PASS |
| `flutter_bloc` / Bloc only (Principle II) | New `RestTimerBloc extends Bloc<...>` — no Cubit | ✅ PASS |
| `go_router` only (Principle II) | New `GoRoute` added to existing centralized config | ✅ PASS |
| GetIt DI (Principle II) | `registerFactory<RestTimerBloc>` | ✅ PASS |
| No new dependency (ADR-030) | `dart:async` `Timer` is Dart SDK — not a package | ✅ PASS |
| Single dark theme (ADR-037) | No hardcoded colors; AppColors/colorScheme only | ✅ PASS |
| No hardcoded strings (CLAUDE.md) | New AppStrings section for SCR-17 | ✅ PASS |
| Clean Architecture layer rules (Principle I) | Domain ← Application ← Presentation; no Drift in presentation | ✅ PASS |
| All states defined (ADR-027) | Running, navigateBack=true (terminal) — both handled | ✅ PASS |
| No Drift call from build() (CLAUDE.md rule 43) | Timer-only; no Drift access at any layer | ✅ PASS |
| Single feature ownership (Principle I §5) | SCR-17 owns workout_session alongside SCR-16 | ✅ PASS |

No violations. No Complexity Tracking section required.

## Project Structure

### Documentation (this feature)

```text
specs/SCR-17-Rest-Timer/mobile/001-scr-17-rest-timer/
├── spec.md
├── plan.md              ← this file
├── research.md          ← Phase 0 decisions
├── data-model.md        ← Phase 1 state model, event model, contract amendments, AppStrings
├── quickstart.md        ← Phase 1 validation guide
├── contracts/
│   ├── rest-timer-bloc.md                    ← RestTimerBloc full contract
│   └── active-workout-bloc-amendments.md     ← Additive changes to SCR-16 contracts
└── checklists/
    └── requirements.md
```

### Source Code

```text
# Existing feature — workout_session
forge/lib/features/workout_session/
│
├── domain/                              ← no changes
│   ├── entities/
│   │   ├── workout_session.dart         ← no change (SCR-16 adds startedAt; SCR-17 adds nothing)
│   │   ├── session_exercise.dart        ← no change
│   │   └── actual_set.dart              ← no change (SCR-16 adds skipped; SCR-17 adds nothing)
│   ├── repositories/
│   │   └── workout_session_repository.dart  ← no change
│   └── usecases/
│       └── save_workout_session_usecase.dart ← no change (SCR-16 adds this)
│
├── data/                                ← no changes from SCR-17
│
├── application/
│   └── bloc/                            ← SCR-16 creates this directory
│       ├── active_workout_event.dart    ← MODIFY: add ActiveWorkoutRestTimerNavigated event
│       ├── active_workout_state.dart    ← MODIFY: add navigateToRestTimer, restPeriodSec fields
│       ├── active_workout_bloc.dart     ← MODIFY: fork CompleteSet handler; add RestTimerNavigated handler
│       ├── rest_timer_event.dart        ← NEW
│       ├── rest_timer_state.dart        ← NEW
│       └── rest_timer_bloc.dart         ← NEW
│
└── presentation/
    ├── screens/
    │   ├── active_workout_screen.dart   ← MODIFY: BlocListener + navigate to SCR-17
    │   └── rest_timer_screen.dart       ← NEW
    └── widgets/
        ├── set_field_row.dart           ← SCR-16 (no SCR-17 change)
        ├── set_progress_row.dart        ← SCR-16 (no SCR-17 change)
        └── paused_workout_overlay.dart  ← SCR-16 (no SCR-17 change)

# Cross-cutting changes
forge/lib/core/strings/app_strings.dart           ← MODIFY: add SCR-17 strings
forge/lib/config/routes/app_routes.dart           ← MODIFY: add restTimer route + GoRoute
forge/lib/app/get_it_setup.dart                   ← MODIFY: register RestTimerBloc

# Tests
forge/test/features/workout_session/
├── application/bloc/
│   ├── active_workout_bloc_test.dart    ← MODIFY: add rest-timer scenarios; update set-completion scenarios
│   └── rest_timer_bloc_test.dart        ← NEW
└── presentation/screens/
    ├── active_workout_screen_test.dart  ← MODIFY: verify SCR-17 navigation on set completion
    └── rest_timer_screen_test.dart      ← NEW
```

**Structure Decision**: SCR-17 lives entirely in the existing `workout_session` feature — no new feature directory. The domain and data layers are untouched by SCR-17. SCR-17 adds three new application-layer files (`rest_timer_event.dart`, `rest_timer_state.dart`, `rest_timer_bloc.dart`) and one new screen (`rest_timer_screen.dart`), plus additive amendments to four existing SCR-16 files that are planned but not yet written.
