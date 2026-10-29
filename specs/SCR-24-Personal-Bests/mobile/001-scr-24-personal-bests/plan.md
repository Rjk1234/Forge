# Implementation Plan: SCR-24 Personal Bests

**Branch**: `001-scr-24-personal-bests` | **Date**: 2026-09-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/SCR-24-Personal-Bests/mobile/001-scr-24-personal-bests/spec.md`

---

## Summary

SCR-24 is a pushed detail screen surfacing per-exercise personal bests (PBs), navigated to from SCR-23's Personal Bests link row. It reads all `WorkoutSession` records from the `workout_sessions` table once per entry, computes per-exercise-per-type best values in memory via `GetPersonalBestsUseCase`, and renders a read-only scrollable list of `PbCard` widgets ordered alphabetically. The screen has four states — Loading (skeleton), Empty, Main (populated list), and Error (with Retry debounce) — managed by `PbBloc`. No Drift writes occur at any point during the screen's lifecycle. A shared `FormatUtils` utility is introduced in `core/utils/` to provide weight, duration, and date formatting reusable across SCR-23 and SCR-24.

---

## Technical Context

**Language/Version**: Dart 3 / Flutter (latest stable via FVM)

**Primary Dependencies**: `flutter_bloc`, `go_router`, `get_it`, `drift`, `equatable` (all governed — ADR-030)

**Storage**: Drift — `workout_sessions` table (read-only; zero writes during SCR-24 lifecycle)

**Testing**: `flutter_test`, `bloc_test`, `mocktail`

**Target Platform**: Android API 29+ and iOS 15+; phone portrait

**Project Type**: Flutter mobile app — Clean, Feature-First Architecture

**Performance Goals**: 20+ completed sessions with multiple exercises compute all PBs without ANR on API 29 (SC-006)

**Constraints**: Fully offline (no network); no new packages; no Cubit; go_router only; GetIt only; single fixed dark theme

**Scale/Scope**: Single-user; local Drift table; in-memory computation only; no pagination

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | Check | Result |
|---|-----------|-------|--------|
| 1 | No network calls (Product Mandate §4) | SCR-24 is Drift-read-only; `GetPersonalBestsUseCase` makes zero network calls | ✅ PASS |
| 2 | Drift is sole persistence mechanism (Principle II.4) | Only reads `workout_sessions` table; no writes at any point (FR-003) | ✅ PASS |
| 3 | `flutter_bloc` sole state management (Principle II.1) | `PbBloc` with explicit events/states; no Cubit | ✅ PASS |
| 4 | No Cubit (Principle II.1) | `PbBloc extends Bloc<PbEvent, PbState>` only | ✅ PASS |
| 5 | `go_router` sole router (Principle II.2) | Child `GoRoute` under `/stats` branch; no second router | ✅ PASS |
| 6 | GetIt sole DI (Principle II.3) | `registerLazySingleton<GetPersonalBestsUseCase>` + `registerFactory<PbBloc>` | ✅ PASS |
| 7 | Single fixed dark theme (Principle VIII.5 / ADR-037) | All colors via `AppColors.*`; no hardcoded hex in widgets | ✅ PASS |
| 8 | No new packages (Principle IX.5 / ADR-030) | `DurationMmSsInputFormatter.formatFromSeconds` (existing) reused; new `FormatUtils` is pure Dart core code | ✅ PASS |
| 9 | Clean Architecture layers (Principle I) | `domain/` → `application/` → `presentation/`; `PersonalBestRecord` is pure Dart; no Flutter in domain | ✅ PASS |
| 10 | Domain independent of Flutter/Drift (Principle I.3) | `PersonalBestRecord` has no imports from Flutter, Drift, or third-party packages | ✅ PASS |
| 11 | AppStrings for all user-facing strings (CLAUDE.md §36) | All 10 string constants + `shortMonthNames` list added to `AppStrings` | ✅ PASS |
| 12 | AppColors for all colors (CLAUDE.md §28-29) | Only existing tokens used: `dangerBg`, `dangerBorder`, `danger`, `lime`, `cyan`, `textMuted`, `textDim`, `card`, `cardAlt`, `white`; no new color tokens needed | ✅ PASS |
| 13 | No Git operations (Mandatory Rule) | No Git commands in any task | ✅ PASS |
| 14 | No Drift writes (FR-003 / Principle VI.1) | Use case returns computed entities; screen never writes | ✅ PASS |
| 15 | All four states defined (Principle VII.1 / ADR-027) | Loading/Initial (skeleton), Empty, Main, Error — all defined | ✅ PASS |
| 16 | Error state maps to typed failure, no raw exception text (Principle II.5) | `PbBloc._onLoadRequested` catches and emits `PbError`; UI shows copy from `AppStrings` | ✅ PASS |

**Constitution Check: 16/16 PASS**

---

## Project Structure

### Documentation (this feature)

```text
specs/SCR-24-Personal-Bests/mobile/001-scr-24-personal-bests/
├── spec.md                          # Feature specification
├── plan.md                          # This file
├── research.md                      # Phase 0 decisions
├── data-model.md                    # Phase 1 entities
├── quickstart.md                    # Phase 1 validation guide
├── contracts/
│   └── pb-bloc.md                   # PbBloc contract
├── checklists/
│   └── requirements.md              # Spec quality checklist
└── tasks.md                         # Phase 2 output (/speckit-tasks)
```

### Source Code

```text
forge/lib/
├── core/
│   ├── strings/
│   │   └── app_strings.dart         # MODIFY: add pb* strings + shortMonthNames
│   └── utils/
│       └── format_utils.dart        # NEW: shared formatWeight / formatPbDate
│
├── config/
│   └── routes/
│       └── app_routes.dart          # MODIFY: add personalBests route constant + child GoRoute under /stats
│
├── app/
│   └── get_it_setup.dart            # MODIFY: register GetPersonalBestsUseCase + PbBloc
│
└── features/
    └── personal_bests/              # NEW feature directory
        ├── domain/
        │   └── entities/
        │       └── personal_best_record.dart
        ├── application/
        │   ├── bloc/
        │   │   ├── pb_event.dart
        │   │   ├── pb_state.dart
        │   │   └── pb_bloc.dart
        │   └── use_cases/
        │       └── get_personal_bests_use_case.dart
        └── presentation/
            ├── screens/
            │   └── personal_bests_screen.dart
            └── widgets/
                ├── pb_skeleton.dart
                ├── pb_card.dart
                ├── pb_type_dot.dart
                ├── pb_badge.dart
                ├── pb_empty_state.dart
                └── pb_error_card.dart

forge/test/
└── features/
    └── personal_bests/
        └── application/
            ├── use_cases/
            │   └── get_personal_bests_use_case_test.dart
            └── bloc/
                └── pb_bloc_test.dart
```

**Structure Decision**: Feature-first under `features/personal_bests/`. No `data/` layer — SCR-24 has no repository of its own; `GetPersonalBestsUseCase` takes `WorkoutSessionRepository` (injected via GetIt) as its sole dependency. The `personal_bests` domain layer is purely computational — no storage records, no mappers.

---

## Implementation Phases

### Phase 1: Setup & Strings

Add the 10 `AppStrings.pb*` constants and the `shortMonthNames` list. Create `FormatUtils` in `core/utils/`. These are prerequisites for all presentation work and can be written before any feature files exist.

### Phase 2: Domain & Application

Create `PersonalBestRecord` entity, `PbEvent`/`PbState` sealed classes, `GetPersonalBestsUseCase` (computation algorithm), and `PbBloc`. Register both in `get_it_setup.dart`. Wire the route constant and child `GoRoute` in `app_routes.dart`.

### Phase 3: US1 — Populated List (P1)

Implement all presentation widgets (`PbSkeleton`, `PbTypeDot`, `PbBadge`, `PbCard`) and `PersonalBestsScreen` scaffold with `_buildLoadedBody`. Add tests for the use case and Bloc.

### Phase 4: US2 — Empty State (P2)

Implement `PbEmptyState` widget. Update `PersonalBestsScreen` to branch on empty list.

### Phase 5: US3 — Error + Retry (P3)

Implement `PbErrorCard` widget with `_retrying` debounce guard. Update `PersonalBestsScreen` to replace placeholder error branch.

### Phase 6: Polish & Validation

`dart format`, `flutter analyze`, `flutter test`, manual validation per `quickstart.md`.

---

## Complexity Tracking

No constitution violations. No complexity justifications required.
