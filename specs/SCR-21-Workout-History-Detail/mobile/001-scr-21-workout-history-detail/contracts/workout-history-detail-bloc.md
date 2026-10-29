# Contract: WorkoutHistoryDetailBloc

**Feature**: SCR-21 Workout History Detail  
**Date**: 2026-09-23  
**File**: `forge/lib/features/workout_session/application/bloc/workout_history_detail_bloc.dart`

---

## Overview

`WorkoutHistoryDetailBloc` owns the full read lifecycle for a single workout session detail view. It receives one event (with retry support), invokes the use case, and emits one of three outcome states. Read-only — zero Drift writes occur.

---

## Event → State Transitions

```
WorkoutHistoryDetailInitial
    │
    ▼ WorkoutHistoryDetailLoadRequested(sessionId)
WorkoutHistoryDetailLoading
    │
    ├──[use case returns Right(session)]──▶ WorkoutHistoryDetailSuccess(session)
    │
    └──[use case returns Left(exception)]──▶ WorkoutHistoryDetailError(message)

WorkoutHistoryDetailSuccess(session)
    └── Terminal (read-only; no further events change this state)

WorkoutHistoryDetailError(message)
    └──▶ WorkoutHistoryDetailLoadRequested(sessionId) ──▶ WorkoutHistoryDetailLoading ──▶ (outcome as above)
```

**Retry**: The screen re-dispatches `WorkoutHistoryDetailLoadRequested` with the same `sessionId`. The Bloc re-enters Loading and re-runs the use case.

---

## Constructor

```dart
WorkoutHistoryDetailBloc({required GetWorkoutHistoryDetailUseCase getDetail})
    : _getDetail = getDetail,
      super(const WorkoutHistoryDetailInitial()) {
  on<WorkoutHistoryDetailLoadRequested>(_onLoadRequested);
}
```

Provided via `getIt` in the route's builder:
```dart
GoRoute(
  path: 'detail',
  builder: (context, state) {
    final sessionId = state.extra as String;
    return BlocProvider(
      create: (_) => getIt<WorkoutHistoryDetailBloc>(),
      child: WorkoutHistoryDetailScreen(sessionId: sessionId),
    );
  },
)
```

---

## `_onLoadRequested` Contract

```
_onLoadRequested(WorkoutHistoryDetailLoadRequested event, Emitter emit):
  1. emit WorkoutHistoryDetailLoading
  2. await _getDetail.call(event.sessionId)
  3. On Right(session):
       emit WorkoutHistoryDetailSuccess(session: session)
  4. On Left(exception):
       emit WorkoutHistoryDetailError(message: AppStrings.detailErrorTitle)
```

The raw `AppException.message` is NEVER surfaced to the UI. The error state always uses `AppStrings.detailErrorTitle` as the displayed string.

---

## Retry Debounce

The screen sets a flag in `setState` to track whether a retry is in progress:

```
Retry button onPressed:
  if (_retrying) return;          // guard against double-tap
  setState(() => _retrying = true);
  context.read<WorkoutHistoryDetailBloc>()
      .add(WorkoutHistoryDetailLoadRequested(sessionId: widget.sessionId));
```

The flag `_retrying` is reset when `BlocListener` observes a transition out of Loading (to Success or Error). This is a local UI concern — NOT a flag on the Bloc itself.

---

## DI Registration

```dart
// forge/lib/app/get_it_setup.dart
getIt.registerLazySingleton<GetWorkoutHistoryDetailUseCase>(
  () => GetWorkoutHistoryDetailUseCase(getIt<WorkoutSessionRepository>()),
);
getIt.registerFactory<WorkoutHistoryDetailBloc>(
  () => WorkoutHistoryDetailBloc(getDetail: getIt<GetWorkoutHistoryDetailUseCase>()),
);
```

---

## Prohibited Behaviours

- Do NOT call `getDetail` from inside `build()` or any widget callback.
- Do NOT emit `WorkoutHistoryDetailError` when the use case returns `Right(session)`.
- Do NOT introduce a `WorkoutHistoryDetailEmpty` state — it is not applicable for this screen.
- Do NOT surface raw `AppException.message` to the UI.
- Do NOT hold mutable state on the Bloc (no `_sessionId`, `_isFetching`, or cache flags).
- Do NOT share state or Bloc instance with `WorkoutHistoryBloc` (SCR-20).
