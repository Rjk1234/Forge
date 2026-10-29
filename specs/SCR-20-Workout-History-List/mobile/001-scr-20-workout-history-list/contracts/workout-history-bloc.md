# Contract: WorkoutHistoryBloc

**Feature**: SCR-20 Workout History List
**Date**: 2026-09-23
**File**: `forge/lib/features/workout_session/application/bloc/workout_history_bloc.dart`

---

## Overview

`WorkoutHistoryBloc` owns the full read lifecycle for the history list: it receives a single event, invokes the use-case, and emits one of three outcome states. It has no write responsibility — it reads only.

---

## Event → State Transitions

```
WorkoutHistoryInitial
    │
    ▼ WorkoutHistoryLoadRequested
WorkoutHistoryLoading
    │
    ├──[use-case returns Right(sessions) where sessions.isNotEmpty]──▶ WorkoutHistorySuccess(groups)
    │
    ├──[use-case returns Right(sessions) where sessions.isEmpty]────▶ WorkoutHistoryEmpty
    │
    └──[use-case returns Left(exception)]───────────────────────────▶ WorkoutHistoryError(message)

WorkoutHistorySuccess(groups)
    │
    └──▶ WorkoutHistoryLoadRequested ──▶ WorkoutHistoryLoading ──▶ (outcome as above)

WorkoutHistoryEmpty
    │
    └──▶ WorkoutHistoryLoadRequested ──▶ WorkoutHistoryLoading ──▶ (outcome as above)

WorkoutHistoryError(message)
    │
    └──▶ WorkoutHistoryLoadRequested ──▶ WorkoutHistoryLoading ──▶ (outcome as above)
```

**Key invariant**: `WorkoutHistoryEmpty` is emitted **only** on `Right([])`. `WorkoutHistoryError` is emitted **only** on `Left(exception)`. These two states are NEVER interchangeable.

---

## Constructor

```dart
WorkoutHistoryBloc({required GetWorkoutHistoryUseCase getWorkoutHistory})
    : _getWorkoutHistory = getWorkoutHistory,
      super(const WorkoutHistoryInitial()) {
  on<WorkoutHistoryLoadRequested>(_onLoadRequested);
}
```

Injected via `getIt` in `app_routes.dart`:
```dart
BlocProvider(
  create: (_) => getIt<WorkoutHistoryBloc>(),
  child: const WorkoutHistoryScreen(),
)
```

---

## `_onLoadRequested` Contract

```
_onLoadRequested(WorkoutHistoryLoadRequested event, Emitter<WorkoutHistoryState> emit):
  1. emit WorkoutHistoryLoading
  2. await _getWorkoutHistory.call()
  3. On Right(sessions):
       if sessions.isEmpty → emit WorkoutHistoryEmpty
       else               → emit WorkoutHistorySuccess(groups: _buildGroups(sessions))
  4. On Left(exception):
       emit WorkoutHistoryError(message: AppStrings.historyErrorTitle)
```

The raw `AppException.message` from the repository (`"Couldn't load workout history"`) is **NOT** surfaced to the UI. The error state always shows `AppStrings.historyErrorTitle` and `AppStrings.historyErrorBody`.

---

## `_buildGroups` Helper

```
_buildGroups(List<WorkoutSession> sessions) → List<HistoryMonthGroup>:
  // sessions are pre-sorted newest-first by GetWorkoutHistoryUseCase
  // Group consecutive sessions by (year, month) of their display date
  For each session:
    displayDate = session.startedAt ?? session.completedAt  // SCR-16 guard
    key = (displayDate.year, displayDate.month)
    label = '${_monthNames[displayDate.month - 1]} ${displayDate.year}'
    append to current group if same key, else start new group
  Return List<HistoryMonthGroup>
```

This is a private method on the Bloc (≤ 30 lines). If it exceeds 30 lines, extract to a file-private top-level function.

---

## Use-Case Dependency

`GetWorkoutHistoryUseCase.call()` contract:
- Input: none
- Output: `Future<Either<AppException, List<WorkoutSession>>>`
- On success: list is sorted newest-first by `startedAt` (or `completedAt` if SCR-16 not yet done)
- On failure: `Left(CacheException(message: "Couldn't load workout history"))`

---

## DI Registration

```dart
// forge/lib/app/get_it_setup.dart
getIt.registerLazySingleton<GetWorkoutHistoryUseCase>(
  () => GetWorkoutHistoryUseCase(getIt<WorkoutSessionRepository>()),
);
getIt.registerFactory<WorkoutHistoryBloc>(
  () => WorkoutHistoryBloc(getWorkoutHistory: getIt<GetWorkoutHistoryUseCase>()),
);
```

---

## Prohibited Behaviours

- Do NOT call `getWorkoutHistory` from inside `build()` or any widget callback.
- Do NOT emit `WorkoutHistoryEmpty` when the use-case returns a `Left`.
- Do NOT emit `WorkoutHistoryError` when the use-case returns a `Right([])`.
- Do NOT swallow the error and emit `WorkoutHistoryEmpty` as a fallback.
- Do NOT surface raw `AppException.message` strings to the UI.
- Do NOT hold mutable state on the Bloc itself (no `_retryCount`, no `_isFetching` flags).
