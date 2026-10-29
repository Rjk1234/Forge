# Contract: WorkoutSummaryBloc

**Feature**: SCR-19 Workout Summary & Completion
**Location**: `forge/lib/features/workout_session/application/bloc/workout_summary_bloc.dart`

---

## Class declaration

```dart
class WorkoutSummaryBloc extends Bloc<WorkoutSummaryEvent, WorkoutSummaryState>
```

**Constructor**:

```dart
WorkoutSummaryBloc({required WorkoutSessionRepository repository})
    : _repository = repository,
      super(const WorkoutSummaryInitial())
```

Registered in `get_it_setup.dart` as `getIt.registerFactory<WorkoutSummaryBloc>`.

---

## Private Bloc state (not emitted)

```dart
final WorkoutSessionRepository _repository;

// Retained across retry attempts. Set on WorkoutSummaryStarted; never cleared
// (even after success — the screen is replaced by navigation, so no disposal risk).
WorkoutSession? _session;
```

---

## Events

### `WorkoutSummaryStarted`

```dart
final class WorkoutSummaryStarted extends WorkoutSummaryEvent {
  const WorkoutSummaryStarted({required this.session});
  final WorkoutSession session;
  @override
  List<Object?> get props => [session];
}
```

Dispatched by the route builder in `app_routes.dart` when the screen is created.
Carries the in-memory `WorkoutSession` built by `ActiveWorkoutBloc`.

### `WorkoutSummaryRetryRequested`

```dart
final class WorkoutSummaryRetryRequested extends WorkoutSummaryEvent {
  const WorkoutSummaryRetryRequested();
  @override
  List<Object?> get props => [];
}
```

Dispatched by `_handleRetry()` in `WorkoutSummaryScreen` when the user taps Retry.

---

## States

### `WorkoutSummaryInitial`

Never rendered. Initial Bloc state; replaced immediately when `WorkoutSummaryStarted` fires.

### `WorkoutSummaryLoading`

```dart
final class WorkoutSummaryLoading extends WorkoutSummaryState {
  const WorkoutSummaryLoading({required this.planName});
  final String planName;
  @override
  List<Object?> get props => [planName];
}
```

Displayed while the Drift write (or dedup check) is in progress.
`planName` is needed to render the workout name in the loading chrome.

### `WorkoutSummarySuccess`

```dart
final class WorkoutSummarySuccess extends WorkoutSummaryState {
  const WorkoutSummarySuccess({required this.session});
  final WorkoutSession session;
  @override
  List<Object?> get props => [session];
}
```

Displayed after a successful save or after the dedup guard confirms the session was
already saved.

### `WorkoutSummaryError`

```dart
final class WorkoutSummaryError extends WorkoutSummaryState {
  const WorkoutSummaryError({required this.planName, required this.sessionId});
  final String planName;
  final String sessionId;
  @override
  List<Object?> get props => [planName, sessionId];
}
```

Displayed when the Drift write fails. `sessionId` is retained for diagnostic
purposes only — it is not displayed. `planName` is rendered in the error card.

---

## State transition table

| Current state | Event | Guard | → Next state |
|---|---|---|---|
| `Initial` | `Started(session)` | — | `Loading(planName)` → async save |
| `Loading` | _(internal)_ | dedup: `Right(non-null)` | `Success(session: existing)` |
| `Loading` | _(internal)_ | dedup: `Right(null)`, save OK | `Success(session: _session)` |
| `Loading` | _(internal)_ | dedup: `Right(null)`, save fail | `Error(planName, sessionId)` |
| `Loading` | _(internal)_ | dedup: `Left(...)`, save OK | `Success(session: _session)` |
| `Loading` | _(internal)_ | dedup: `Left(...)`, save fail | `Error(planName, sessionId)` |
| `Error` | `RetryRequested` | — | `Loading(planName)` → async save |
| `Loading` (retry) | _(internal)_ | dedup found | `Success` (idempotent) |
| `Loading` (retry) | _(internal)_ | save OK | `Success` |
| `Loading` (retry) | _(internal)_ | save fail | `Error` |

---

## Handler pseudo-code

```dart
Future<void> _onStarted(WorkoutSummaryStarted event, Emitter emit) async {
  _session = event.session;
  await _attemptSave(emit);
}

Future<void> _onRetryRequested(WorkoutSummaryRetryRequested event, Emitter emit) async {
  await _attemptSave(emit);
}

Future<void> _attemptSave(Emitter emit) async {
  final session = _session!;
  emit(WorkoutSummaryLoading(planName: session.planName));

  // Dedup check (FR-011)
  final existing = await _repository.getSessionById(session.sessionId);
  if (existing.isRight() && existing.getOrElse((_) => null) != null) {
    emit(WorkoutSummarySuccess(session: existing.getOrElse((_) => session)!));
    return;
  }

  // Attempt write
  final result = await _repository.saveSession(session);
  result.fold(
    (_) => emit(WorkoutSummaryError(
      planName: session.planName,
      sessionId: session.sessionId,
    )),
    (_) => emit(WorkoutSummarySuccess(session: session)),
  );
}
```

---

## DI registration

```dart
// get_it_setup.dart — workout_session section
getIt.registerFactory<WorkoutSummaryBloc>(
  () => WorkoutSummaryBloc(repository: getIt<WorkoutSessionRepository>()),
);
```

---

## Route wiring

```dart
// app_routes.dart — replaces the SCR-19 stub from SCR-16
GoRoute(
  path: RoutePaths.postWorkout,    // '/workout/summary'
  name: RoutePaths.postWorkoutName,
  builder: (context, state) {
    final session = state.extra as WorkoutSession;
    return BlocProvider(
      create: (_) => getIt<WorkoutSummaryBloc>()
        ..add(WorkoutSummaryStarted(session: session)),
      child: const WorkoutSummaryScreen(),
    );
  },
),
```

**Entry from SCR-16 BlocListener**:
```dart
if (state.navigateToPostWorkout && state.completedSession != null) {
  context.go(RoutePaths.postWorkout, extra: state.completedSession);
  context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutPostWorkoutNavigated());
}
```

`context.go` removes SCR-16 from the stack (FR-003, SC-004). The `PostWorkoutNavigated`
event resets `navigateToPostWorkout: false` and `completedSession: null` in the Bloc —
consistent with the `CancelNavigated` pattern from SCR-18.
