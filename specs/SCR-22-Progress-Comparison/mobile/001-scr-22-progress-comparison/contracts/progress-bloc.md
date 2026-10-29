# Contract: ProgressBloc

**Feature**: SCR-22 Progress Comparison
**Date**: 2026-09-23
**File**: `forge/lib/features/progress/application/bloc/progress_bloc.dart`

---

## Overview

`ProgressBloc` owns the full lifecycle of the Progress screen: one read of all workout sessions, in-memory computation of per-exercise progress data, and chip-selection state changes. Read-only — zero Drift writes occur. Provided at the route level so it persists across tab switches.

---

## Event → State Transitions

```
ProgressInitial
    │
    ▼ ProgressLoadRequested
ProgressLoading
    │
    ├──[use case returns Right(exercises)]──▶ ProgressLoaded(exercises, selectedExerciseName: exercises.first.exerciseName)
    │
    └──[use case returns Left(exception)]──▶ ProgressError(message: AppStrings.progressErrorTitle)

ProgressLoaded(exercises, selectedExerciseName)
    │
    ├──[ProgressExerciseSelected(name)]──▶ ProgressLoaded(exercises, selectedExerciseName: name)
    │   (no Drift read — same exercises list, different selectedExerciseName)
    │
    └──[ProgressLoadRequested (Retry)]──▶ ProgressLoading ──▶ (outcome as above)

ProgressError
    └──▶ ProgressLoadRequested (Retry) ──▶ ProgressLoading ──▶ (outcome as above)
```

**Key invariant**: `ProgressExerciseSelected` is only dispatched when the Bloc is in `ProgressLoaded`. The screen widget guards this — no chip tap is possible during loading or error. The Bloc handler for `ProgressExerciseSelected` MUST guard with `if (state is! ProgressLoaded) return;`.

---

## Constructor

```dart
ProgressBloc({required GetExerciseProgressDataUseCase getProgressData})
    : _getProgressData = getProgressData,
      super(const ProgressInitial()) {
  on<ProgressLoadRequested>(_onLoadRequested);
  on<ProgressExerciseSelected>(_onExerciseSelected);
}
```

Provided via GetIt in `app_routes.dart` branch 4 builder:
```dart
StatefulShellBranch(
  navigatorKey: _progressNavigatorKey,
  routes: [
    GoRoute(
      path: '/progress',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ProgressBloc>()
          ..add(const ProgressLoadRequested()),
        child: const ProgressScreen(),
      ),
    ),
  ],
)
```

---

## `_onLoadRequested` Contract

```
_onLoadRequested(ProgressLoadRequested event, Emitter emit):
  1. emit ProgressLoading
  2. await _getProgressData.call()
  3. On Right(exercises) where exercises is not empty:
       final first = exercises.first.exerciseName;
       emit ProgressLoaded(exercises: exercises, selectedExerciseName: first)
  4. On Right(exercises) where exercises is empty (no sessions at all):
       emit ProgressLoaded(exercises: [], selectedExerciseName: '')
       [chip row shows empty; ProgressEmptyState shown — no exercises exist]
  5. On Left(exception):
       LoggingService.logError(exception, stackTrace)
       emit ProgressError(message: AppStrings.progressErrorTitle)
```

The raw `AppException.message` is NEVER surfaced to the UI. The error state always uses `AppStrings.progressErrorTitle`.

---

## `_onExerciseSelected` Contract

```
_onExerciseSelected(ProgressExerciseSelected event, Emitter emit):
  1. if (state is! ProgressLoaded) return;   // guard
  2. final current = state as ProgressLoaded;
  3. emit ProgressLoaded(
       exercises: current.exercises,
       selectedExerciseName: event.exerciseName,
     )
```

No Drift read. No use-case call. The exercises list is reused from existing state.

---

## Retry Debounce

The screen sets a flag in local `StatefulWidget` state:

```
Retry button onPressed:
  if (_retrying) return;
  setState(() => _retrying = true);
  context.read<ProgressBloc>().add(const ProgressLoadRequested());
```

`_retrying` is reset when `BlocListener` observes a transition from `ProgressLoading` to `ProgressLoaded` or `ProgressError`. This is a local UI concern — NOT a flag on the Bloc.

---

## GetExerciseProgressDataUseCase Contract

**File**: `forge/lib/features/progress/application/use_cases/get_exercise_progress_data_use_case.dart`

```
Input: none (reads from injected WorkoutSessionRepository)
Output: Either<AppException, List<ExerciseProgressData>>

call():
  1. await _repository.getAllSessions()
  2. On Left(exception): return Left(exception)
  3. On Right(sessions):
     a. Group sessions by exerciseName
     b. For each group:
        - Filter to valid sessions (≥1 non-skipped ActualSet for this exercise)
        - Sort by completedAt descending
        - Compute totalValidSessions
        - Take most-recent 12 for chart → sessionDataPoints (reversed to ascending for chart)
        - Compute latestMetrics from sessions[0]
        - Compute deltaMetrics from sessions[0] − sessions[1] (if totalValidSessions >= 2)
     c. Sort result by chip ordering rule (D-05 from research.md)
     d. Return Right(List<ExerciseProgressData>)
```

**Right(empty list)** is a valid success case (no sessions recorded yet). The Bloc handles it (step 4 above).

---

## DI Registration

```dart
// forge/lib/app/get_it_setup.dart
getIt.registerLazySingleton<GetExerciseProgressDataUseCase>(
  () => GetExerciseProgressDataUseCase(
    repository: getIt<WorkoutSessionRepository>(),
  ),
);

getIt.registerFactory<ProgressBloc>(
  () => ProgressBloc(getProgressData: getIt<GetExerciseProgressDataUseCase>()),
);
```

---

## Prohibited Behaviours

- Do NOT call `getAllSessions()` from `_onExerciseSelected` — chip taps must never trigger Drift reads.
- Do NOT emit `ProgressError` when the use case returns `Right([])` — an empty session list is valid `ProgressLoaded`.
- Do NOT surface raw `AppException.message` to the UI.
- Do NOT hold mutable state on the Bloc (no `_selectedName` field, no `_cachedExercises`).
- Do NOT share this Bloc with any SCR-20 or SCR-21 Bloc.
- Do NOT introduce a `ProgressEmptyState` *Bloc state* — Main vs Empty is a UI derivation from `ProgressLoaded`; it is NOT a separate Bloc state.
