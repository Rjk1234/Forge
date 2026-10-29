# Contract: PreStartBloc

**Feature**: SCR-15 Workout Pre-Start / Overview
**Location**: `forge/lib/features/workout_plan/application/bloc/pre_start_bloc.dart`

---

## Class declaration

```dart
class PreStartBloc extends Bloc<PreStartEvent, PreStartState>
```

**Constructor**:

```dart
PreStartBloc({required GetWorkoutPlanByIdUseCase getWorkoutPlanById})
    : super(const PreStartInitial())
```

Registered in `get_it_setup.dart` as `sl.registerFactory<PreStartBloc>`.

---

## Events

### `PreStartRequested`

```dart
class PreStartRequested extends PreStartEvent {
  const PreStartRequested({required this.planId, this.scheduledWeekday});
  final String planId;
  final int? scheduledWeekday;
}
```

- Dispatched from `WorkoutPreStartScreen.initState` via `context.read<PreStartBloc>().add(...)`.
- Triggers the initial plan load.
- If state is already `PreStartLoading`, the event is a no-op (FR-009 guard).

### `PreStartRetried`

```dart
class PreStartRetried extends PreStartEvent {
  const PreStartRetried({required this.planId, this.scheduledWeekday});
  final String planId;
  final int? scheduledWeekday;
}
```

- Dispatched when the user taps Retry in `PreStartErrorState`.
- Carries the same payload as `PreStartRequested`.
- If state is already `PreStartLoading`, the event is a no-op (FR-009 guard).

---

## States

All states extend `PreStartState` (sealed) and use `Equatable` (no `props` override needed for `Initial`, `Loading`, and `Unavailable`).

### `PreStartInitial`

```dart
class PreStartInitial extends PreStartState {
  const PreStartInitial();
}
```

- Initial Bloc state before any event is dispatched.
- Not rendered as a distinct UI state; screen dispatches `PreStartRequested` in `initState`, so this state is transient.

### `PreStartLoading`

```dart
class PreStartLoading extends PreStartState {
  const PreStartLoading();
}
```

- Emitted immediately when handling `PreStartRequested` or `PreStartRetried`.
- Screen renders `PreStartSkeleton` (State A).

### `PreStartLoaded`

```dart
class PreStartLoaded extends PreStartState {
  const PreStartLoaded({
    required this.plan,
    this.scheduledWeekday,
    required this.isScheduledForToday,
  });
  final WorkoutPlanDetail plan;
  final int? scheduledWeekday;
  final bool isScheduledForToday;

  @override
  List<Object?> get props => [plan, scheduledWeekday, isScheduledForToday];
}
```

- Emitted when use case returns `Right(plan)` and `plan.exercises.isNotEmpty`.
- Screen renders the plan preview with "Begin Workout" (State B).
- `isScheduledForToday` is set by Bloc: `scheduledWeekday != null && scheduledWeekday == DateTime.now().weekday`.

### `PreStartUnavailable`

```dart
class PreStartUnavailable extends PreStartState {
  const PreStartUnavailable();
}
```

- Emitted when use case returns `Right(null)` (plan deleted) OR `Right(plan)` with `plan.exercises.isEmpty`.
- Equivalent treatment per spec assumption (zero-exercise plan ≡ deleted plan).
- Screen renders `PreStartUnavailableState` (State C).

### `PreStartError`

```dart
class PreStartError extends PreStartState {
  const PreStartError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}
```

- Emitted when use case returns `Left(AppException)`.
- `message` is the `AppException.message` for internal diagnostic use; the widget always shows `AppStrings.preStartErrorTitle` / `AppStrings.preStartErrorBody` (user-facing copy is never derived from the raw exception).
- Screen renders `PreStartErrorState` (State D).

---

## State transition table

| Current state | Event | Guard | → Next state |
|---|---|---|---|
| any | `PreStartRequested` | `if state is PreStartLoading: no-op` | `PreStartLoading` → `PreStartLoaded` / `PreStartUnavailable` / `PreStartError` |
| any | `PreStartRetried` | `if state is PreStartLoading: no-op` | `PreStartLoading` → `PreStartLoaded` / `PreStartUnavailable` / `PreStartError` |
| `PreStartLoading` | either event | (guard fires) | no state change |

---

## Handler pseudo-code

```dart
// Shared load logic for both events
Future<void> _onLoad(String planId, int? scheduledWeekday, Emitter<PreStartState> emit) async {
  if (state is PreStartLoading) return; // FR-009
  emit(const PreStartLoading());
  final result = await _getWorkoutPlanById(planId);
  result.fold(
    (failure) => emit(PreStartError(message: failure.message)),
    (plan) {
      if (plan == null || plan.exercises.isEmpty) {
        emit(const PreStartUnavailable());
      } else {
        final isToday = scheduledWeekday != null &&
            scheduledWeekday == DateTime.now().weekday;
        emit(PreStartLoaded(
          plan: plan,
          scheduledWeekday: scheduledWeekday,
          isScheduledForToday: isToday,
        ));
      }
    },
  );
}
```

**Note**: `GetWorkoutPlanByIdUseCase` returns `Either<AppException, WorkoutPlanDetail?>`. If the repository's data source returns `null` for a missing plan ID, the result is `Right(null)` → `PreStartUnavailable`.

---

## DI registration

```dart
// get_it_setup.dart — within the workout_plan Blocs section
sl.registerFactory<PreStartBloc>(
  () => PreStartBloc(getWorkoutPlanById: sl()),
);
```

---

## Route wiring (summary)

`GoRoute` added as a child of the existing `:planId` shell route:

```dart
GoRoute(
  path: 'start',
  name: RoutePaths.workoutPreStartName,
  builder: (context, state) {
    final planId = state.pathParameters['planId']!;
    final extra = state.extra as Map<String, dynamic>?;
    final weekday = extra?['scheduledWeekday'] as int?;
    return BlocProvider(
      create: (_) => sl<PreStartBloc>()
        ..add(PreStartRequested(planId: planId, scheduledWeekday: weekday)),
      child: WorkoutPreStartScreen(planId: planId, scheduledWeekday: weekday),
    );
  },
),
```

**Entry from Plan Detail** (`plan_detail_screen.dart`):
```dart
context.push('/plans/$planId/start');
// extra is null → scheduledWeekday = null
```

**Entry from Weekly Schedule** (`weekly_schedule_screen.dart`):
```dart
context.push(
  '/plans/$planId/start',
  extra: {'scheduledWeekday': weekday},
);
```
