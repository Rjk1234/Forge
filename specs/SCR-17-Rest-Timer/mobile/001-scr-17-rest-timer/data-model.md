# Data Model: SCR-17 Rest Timer

**Phase 1 — state model, event model, contract amendments, and AppStrings**

---

## No domain entity changes

SCR-17 requires no new domain entities and no changes to existing storage records. The rest timer is entirely in-memory. `PlanExercise.restPeriodSec: int` already exists and is the sole data source.

---

## New Bloc state model — `RestTimerBloc`

### `RestTimerState` sealed class hierarchy

```
RestTimerState (sealed)
├── RestTimerInitial          — before RestTimerStarted event; never rendered
└── RestTimerRunning          — active countdown (and terminal navigateBack state)
```

### `RestTimerRunning` fields

| Field | Type | Nullable | Purpose |
|---|---|---|---|
| `totalSec` | `int` | No | Initial rest duration (from `restPeriodSec`); used to calculate progress fraction for any visual ring |
| `remainingSec` | `int` | No | Seconds remaining; counts down from `totalSec` to 0 |
| `navigateBack` | `bool` | No | Set true on Skip or natural expiry; `BlocListener` calls `context.pop()` when this is true |

```dart
class RestTimerRunning extends RestTimerState {
  const RestTimerRunning({
    required this.totalSec,
    required this.remainingSec,
    this.navigateBack = false,
  });

  final int totalSec;
  final int remainingSec;
  final bool navigateBack;

  @override
  List<Object?> get props => [totalSec, remainingSec, navigateBack];

  RestTimerRunning copyWith({int? totalSec, int? remainingSec, bool? navigateBack}) =>
      RestTimerRunning(
        totalSec: totalSec ?? this.totalSec,
        remainingSec: remainingSec ?? this.remainingSec,
        navigateBack: navigateBack ?? this.navigateBack,
      );
}
```

---

## New Bloc event model — `RestTimerEvent`

```
RestTimerEvent (sealed)
├── RestTimerStarted({required int restPeriodSec})   — dispatched by RestTimerScreen on BlocProvider.create
├── RestTimerTicked                                   — dispatched by Timer.periodic callback (every second)
└── RestTimerSkipped                                  — dispatched by Skip button or PopScope back intercept
```

```dart
sealed class RestTimerEvent extends Equatable {
  const RestTimerEvent();
}

class RestTimerStarted extends RestTimerEvent {
  const RestTimerStarted({required this.restPeriodSec});
  final int restPeriodSec;
  @override
  List<Object?> get props => [restPeriodSec];
}

class RestTimerTicked extends RestTimerEvent {
  const RestTimerTicked();
  @override
  List<Object?> get props => [];
}

class RestTimerSkipped extends RestTimerEvent {
  const RestTimerSkipped();
  @override
  List<Object?> get props => [];
}
```

---

## `RestTimerBloc` — private fields and state machine

```dart
class RestTimerBloc extends Bloc<RestTimerEvent, RestTimerState> {
  RestTimerBloc() : super(const RestTimerInitial()) {
    on<RestTimerStarted>(_onStarted);
    on<RestTimerTicked>(_onTicked);
    on<RestTimerSkipped>(_onSkipped);
  }

  Timer? _timer;

  void _onStarted(RestTimerStarted event, Emitter<RestTimerState> emit) {
    _timer?.cancel();
    emit(RestTimerRunning(totalSec: event.restPeriodSec, remainingSec: event.restPeriodSec));
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => add(const RestTimerTicked()));
  }

  void _onTicked(RestTimerTicked event, Emitter<RestTimerState> emit) {
    final current = state as RestTimerRunning;
    if (current.remainingSec <= 1) {
      _timer?.cancel();
      emit(current.copyWith(remainingSec: 0, navigateBack: true));
    } else {
      emit(current.copyWith(remainingSec: current.remainingSec - 1));
    }
  }

  void _onSkipped(RestTimerSkipped event, Emitter<RestTimerState> emit) {
    _timer?.cancel();
    if (state is RestTimerRunning) {
      emit((state as RestTimerRunning).copyWith(navigateBack: true));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
```

---

## `ActiveWorkoutRunning` — additive field amendments (SCR-16 contract)

These two fields are ADDED to the existing `ActiveWorkoutRunning` class defined in `SCR-16-Active-Workout/mobile/001-scr-16-active-workout/data-model.md`. No existing field changes.

| Field | Type | Nullable | Purpose |
|---|---|---|---|
| `navigateToRestTimer` | `bool` | No | Set true after set completion when `restPeriodSec > 0`; BlocListener pushes SCR-17 and immediately dispatches `ActiveWorkoutRestTimerNavigated` to reset to false |
| `restPeriodSec` | `int` | No | Duration (seconds) to pass to SCR-17 via route extra; 0 when no rest is pending |

Add both fields to the `props` list. Default both to `false` / `0` in `copyWith`.

---

## `ActiveWorkoutEvent` — additive event amendment (SCR-16 contract)

Add one new event to `active_workout_event.dart`:

```dart
class ActiveWorkoutRestTimerNavigated extends ActiveWorkoutEvent {
  const ActiveWorkoutRestTimerNavigated();
  @override
  List<Object?> get props => [];
}
```

This event is dispatched by `ActiveWorkoutScreen`'s BlocListener immediately after it calls `context.push(RoutePaths.restTimer, extra: ...)`. The Bloc resets `navigateToRestTimer: false, restPeriodSec: 0` so the flag does not fire again on the next rebuild.

---

## `ActiveWorkoutBloc` — set-completion logic amendment

When handling `ActiveWorkoutCompleteSetRequested` and the set is valid and not the final set of the final exercise, replace the current "always advance directly" emit with:

```dart
final completedExercise = _plan.exercises[_currentExerciseIndex]; // before advancing
// ... advance _currentSetIndex / _currentExerciseIndex ...
final restSec = completedExercise.restPeriodSec;
if (restSec > 0) {
  emit(currentRunningState.copyWith(
    // next-position fields (currentExercise, exerciseIndex, currentSetIndex, setStatuses)
    navigateToRestTimer: true,
    restPeriodSec: restSec,
  ));
} else {
  emit(currentRunningState.copyWith(
    // next-position fields only; navigateToRestTimer stays false
  ));
}
```

Handler for `ActiveWorkoutRestTimerNavigated`:
```dart
on<ActiveWorkoutRestTimerNavigated>((event, emit) {
  if (state is ActiveWorkoutRunning) {
    emit((state as ActiveWorkoutRunning).copyWith(
      navigateToRestTimer: false,
      restPeriodSec: 0,
    ));
  }
});
```

---

## Route constants to add to `RoutePaths`

```dart
// Rest Timer (SCR-17)
static const String restTimer = '/workout/rest';
static const String restTimerName = 'restTimer';
```

Route definition in `app_routes.dart`:

```dart
GoRoute(
  path: RoutePaths.restTimer,
  name: RoutePaths.restTimerName,
  builder: (context, state) {
    final restPeriodSec = state.extra as int;
    return BlocProvider(
      create: (_) => getIt<RestTimerBloc>()..add(RestTimerStarted(restPeriodSec: restPeriodSec)),
      child: const RestTimerScreen(),
    );
  },
),
```

---

## New AppStrings (SCR-17)

Section added to `forge/lib/core/strings/app_strings.dart`:

```dart
// SCR-17: Rest Timer
static const String restTimerSkipRestButton = 'Skip Rest';
static const String restTimerRestingLabel = 'Resting';
static const String restTimerSecondsUnit = 's';
```

Note: `restTimerSkipRestButton` uses `'Skip Rest'` (not `'Skip'`) to disambiguate from SCR-16's `activeWorkoutSkipButton = 'Skip'` (which skips a set). The two controls have different semantics and must use distinct copy.
