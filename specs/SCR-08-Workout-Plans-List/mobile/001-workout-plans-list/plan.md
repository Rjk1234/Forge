# Implementation Plan: SCR-08 Workout Plans List

**Branch**: `001-workout-plans-list` | **Date**: 2026-09-17 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/SCR-08-Workout-Plans-List/mobile/001-workout-plans-list/spec.md`

---

## Summary

SCR-08 replaces the Plans tab placeholder (`PlaceholderTabScreen`) with a live Workout Plans List screen. It adds the missing domain, application, and presentation layers for the `workout_plan` feature — the data layer (`WorkoutPlanRecord`, `WorkoutPlanLocalDataSource`) already exists and is registered in GetIt. The screen reads all plans from the `workout_plans` table, sorts them newest-first by `createdAt`, and renders them in one of four states: Loading (skeleton), Populated (scrollable list), Empty (CTA), or Error (retry card). A lightweight `WorkoutPlansReloadNotifier` in `core/navigation/` enables optimistic re-reads when the Plans tab is re-activated without losing the existing list.

---

## Technical Context

**Language/Version**: Dart 3.12.x / Flutter latest stable (FVM-managed)

**Primary Dependencies** (all existing — zero new packages):
- `flutter_bloc ^8.0.0` — `WorkoutPlansBloc` (Bloc, not Cubit)
- `get_it ^7.6.0` — DI registration for repository, use case, bloc, reload notifier
- `go_router ^13.0.0` — replaces `PlaceholderTabScreen` at `/plans` route; adds `/plans/:planId` for SCR-10
- `drift` — read the `workout_plans` table via `AppDatabase` (opened at boot)
- `fpdart ^1.1.0` — `Either<AppException, List<WorkoutPlan>>` in repository
- `equatable ^2.0.5` — `WorkoutPlan` entity, Bloc states

**Storage**: `workout_plans` table (existing). No new tables.

**Testing**: `flutter_test` + manual fakes (implements interface in test) — same pattern as SCR-06 and SCR-07.

**Target Platform**: Android 10+ / iOS 15+; portrait-only; single fixed dark theme.

**Performance Goals**: Skeleton visible within 1 frame of tab tap (SC-001); populated/empty state within 1 second (SC-002); plan card tap navigation within 1 second (SC-003).

**Constraints**:
- No network calls — offline Drift-only
- No new packages (ADR-030)
- Bloc only — no Cubit (ADR-002)
- go_router only — no second router (ADR-003)
- GetIt DI — no alternative (ADR-004)
- Single fixed dark theme — no light mode (ADR-037)

**Scale/Scope**: Single screen; typical POC usage of tens of plans at most.

---

## Constitution Check

*GATE: Must pass before implementation.*

| Principle | Status | Notes |
|---|---|---|
| Fully offline (no network) | ✅ PASS | Reads `workout_plans` table only; no HTTP client |
| Drift as sole data store | ✅ PASS | No new persistence mechanism; uses existing `workout_plans` table |
| No new packages | ✅ PASS | All dependencies already in `pubspec.yaml` |
| flutter_bloc (Bloc not Cubit) | ✅ PASS | `WorkoutPlansBloc extends Bloc` |
| go_router only | ✅ PASS | Existing `/plans` route builder replaced; `/plans/:planId` added |
| GetIt DI | ✅ PASS | New registrations in `get_it_setup.dart` |
| Single dark theme | ✅ PASS | Uses `AppColors.*` tokens and `textTheme.*`; no hardcoded hex in widgets |
| Clean Feature-First layers | ✅ PASS | domain → application → data → presentation; no layer violation |
| No Git operations | ✅ PASS | No git commands in tasks |

**GATE PASSED.** No violations or complexity justification required.

---

## Project Structure

### Documentation (this feature)

```text
specs/SCR-08-Workout-Plans-List/mobile/001-workout-plans-list/
├── spec.md              # Feature specification (complete)
├── plan.md              # This file
├── research.md          # Phase 0 — 6 research decisions
├── data-model.md        # Phase 1 — storage records + domain model
├── quickstart.md        # Phase 1 — 11 validation scenarios VS-01..VS-11
├── checklists/
│   └── requirements.md  # Quality checklist (16/16 passing)
└── tasks.md             # Phase 2 output (/speckit-tasks — not yet created)
```

### Source Code (forge/)

**Existing files — modified by this feature**:

```text
forge/lib/
├── app/get_it_setup.dart              ← add WorkoutPlanRepository, GetWorkoutPlansUseCase,
│                                         WorkoutPlansBloc, WorkoutPlansReloadNotifier registrations
├── config/routes/app_routes.dart     ← replace PlaceholderTabScreen at RoutePaths.plans (/plans)
│                                         with WorkoutPlansScreen + WorkoutPlansBloc;
│                                         add RoutePaths.planDetail ('/plans/:planId') stub
└── features/home/presentation/
    └── screens/app_shell.dart        ← call WorkoutPlansReloadNotifier.notify() when branch index
                                          switches to 1 (Plans tab)
```

**New files — Core Navigation Infrastructure**:

```text
forge/lib/core/navigation/
└── workout_plans_reload_notifier.dart   ← ChangeNotifier singleton; AppShell notifies on tab switch;
                                            WorkoutPlansScreen subscribes and dispatches LoadRequested
```

**New files — Domain layer**:

```text
forge/lib/features/workout_plan/domain/
├── entities/
│   └── workout_plan.dart              ← immutable entity (id, name, exerciseCount, createdAt)
├── repositories/
│   └── workout_plan_repository.dart   ← abstract interface: getAllPlans()
└── usecases/
    └── get_workout_plans_usecase.dart  ← thin delegator to repository
```

**New files — Data layer** (extends existing):

```text
forge/lib/features/workout_plan/data/
├── mappers/
│   └── workout_plan_mapper.dart        ← WorkoutPlanRecord → WorkoutPlan (static method)
└── repositories/
    └── workout_plan_repository_impl.dart ← implements WorkoutPlanRepository; sorts newest-first;
                                              catches database exceptions → CacheException
```

**New files — Application layer**:

```text
forge/lib/features/workout_plan/application/bloc/
├── workout_plans_bloc.dart            ← Bloc; optimistic re-read logic (Decision 4)
├── workout_plans_event.dart           ← WorkoutPlansLoadRequested (single event)
└── workout_plans_state.dart           ← Initial, Loading, Populated, Empty, Error
```

**New files — Presentation layer**:

```text
forge/lib/features/workout_plan/presentation/
├── screens/
│   └── workout_plans_screen.dart      ← StatefulWidget; subscribes to reload notifier; dispatches
│                                          LoadRequested on init and on notifier signal
└── widgets/
    ├── plan_card.dart                  ← single plan row (name, exercise count, chevron); tappable
    ├── plans_skeleton_list.dart        ← 4 skeleton cards + skeleton FAB placeholder
    └── plans_empty_state.dart          ← centred icon + title + subtitle + lime CTA button
```

**Reused existing widgets** (no modifications):

```text
forge/lib/features/home/presentation/widgets/error_card.dart  ← ErrorCard(message, onRetry)
```

**New files — Tests**:

```text
forge/test/features/workout_plan/
├── domain/entities/
│   └── workout_plan_test.dart                      ← entity equality, exerciseCount edge cases
├── application/bloc/
│   └── workout_plans_bloc_test.dart                ← all state transitions; optimistic re-read
├── data/mappers/
│   └── workout_plan_mapper_test.dart               ← mapping + exerciseCount derivation
├── data/repositories/
│   └── workout_plan_repository_impl_test.dart      ← sort order; error wrapping
└── presentation/screens/
    └── workout_plans_screen_test.dart              ← all 4 UI states; plan card content
```

---

## Key Implementation Notes

### WorkoutPlansBloc — Optimistic Re-Read

```dart
// In workout_plans_event.dart
final class WorkoutPlansLoadRequested extends WorkoutPlansEvent {
  const WorkoutPlansLoadRequested();
}

// In workout_plans_bloc.dart
void _onLoadRequested(
  WorkoutPlansLoadRequested event,
  Emitter<WorkoutPlansState> emit,
) async {
  final hasExistingData = state is WorkoutPlansPopulated
      || state is WorkoutPlansEmpty;

  if (!hasExistingData) {
    emit(const WorkoutPlansLoading());
  }
  // If hasExistingData: keep current state during read (optimistic)

  final result = await _getWorkoutPlans();
  result.fold(
    (failure) => emit(WorkoutPlansError(message: failure.message)),
    (plans) => plans.isEmpty
        ? emit(const WorkoutPlansEmpty())
        : emit(WorkoutPlansPopulated(plans: plans)),
  );
}
```

### Plan Card — Singular/Plural Exercise Count

```dart
// In PlanCard or workout_plans_screen.dart
String _exerciseLabel(int count) =>
    count == 1 ? '1 exercise' : '$count exercises';
```

### WorkoutPlansScreen — Reload Notifier Subscription

```dart
class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  late final WorkoutPlansReloadNotifier _reloadNotifier;

  @override
  void initState() {
    super.initState();
    _reloadNotifier = getIt<WorkoutPlansReloadNotifier>();
    _reloadNotifier.addListener(_onTabActivated);
    context.read<WorkoutPlansBloc>().add(const WorkoutPlansLoadRequested());
  }

  @override
  void dispose() {
    _reloadNotifier.removeListener(_onTabActivated);
    super.dispose();
  }

  void _onTabActivated() {
    if (!mounted) return;
    context.read<WorkoutPlansBloc>().add(const WorkoutPlansLoadRequested());
  }
}
```

### AppShell — Branch Switch Notification

`AppShell` already receives `StatefulNavigationShell navigationShell`. Extend it to call `getIt<WorkoutPlansReloadNotifier>().notify()` whenever `navigationShell.currentIndex` changes to 1. This can be implemented via a `didUpdateWidget` override or by passing an `onBranchSelected` callback to the `AppShell.build` method that wraps the `StatefulNavigationShell`.

### Sort in Repository (not Bloc)

```dart
// In workout_plan_repository_impl.dart
@override
Future<Either<AppException, List<WorkoutPlan>>> getAllPlans() async {
  try {
    final models = _dataSource.getAllPlans()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
    return Right(models.map(WorkoutPlanMapper.fromRecord).toList());
  } catch (e) {
    return Left(CacheException(message: "Couldn't load your workout plans"));
  }
}
```

### Skeleton: 4 Cards + FAB Placeholder

`PlansSkeletonList` renders 4 skeleton plan cards (card fill `AppColors.card`, border `AppColors.border`, 16 pt radius, 16 pt padding). Each skeleton card has two shimmer lines (65% width / 15 pt height for name; 32% / 11 pt for count). Shimmer animation reuses the same `AnimationController` pattern as `ExerciseSkeletonList` (1.4 s, ease, infinite). A skeleton FAB placeholder (38 × 38 pt, `AppColors.card` fill, 12 pt radius) appears in the app bar position when the skeleton is active.

### App Bar — Shared Chrome

"Workout Plans" title uses `textTheme.headlineSmall` (22 pt / 800 / `AppColors.white`). There is no `leading` back button — this is a root tab screen. The FAB (38 × 38 pt, lime fill, `AppColors.bg` icon, plus icon, 12 pt radius) appears only in `WorkoutPlansPopulated` state.

### Error Handling — Error Card Copy

The `ErrorCard` widget is called with:
- `message: "Couldn't load your workout plans"`
- `onRetry: () => context.read<WorkoutPlansBloc>().add(const WorkoutPlansLoadRequested())`

The retry fires `WorkoutPlansLoadRequested` from the `Error` state, which causes the Bloc to emit `WorkoutPlansLoading` (because `hasExistingData` is false when in Error state).

---

## Complexity Tracking

No constitution violations. No complexity justification required.
