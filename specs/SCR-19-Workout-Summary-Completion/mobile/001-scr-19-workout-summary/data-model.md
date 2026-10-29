# Data Model: SCR-19 Workout Summary & Completion

**Phase 1 — entity amendments, Bloc design, AppStrings, AppColors, widget shape**

---

## Existing domain entities — no new fields from SCR-19

SCR-19 reads from domain entities that are already defined and will be amended by
SCR-16 before SCR-19 is implemented. For reference:

| Entity | Source | SCR-16 amendment (dependency) |
|---|---|---|
| `WorkoutSession` | `domain/entities/workout_session.dart` | Adds `startedAt: DateTime` |
| `SessionExercise` | `domain/entities/session_exercise.dart` | No change |
| `ActualSet` | `domain/entities/actual_set.dart` | Adds `skipped: bool` |

**SCR-19 adds NO new domain entity fields or storage record fields.**

---

## SCR-16 contract amendments (supersedes SCR-16 data-model §Bloc for Finish path)

The SCR-16 contract placed `SaveWorkoutSessionUseCase` inside `ActiveWorkoutBloc`
and handled errors via `writeError: String?`. SCR-19 owns the save; the following
changes MUST be applied when implementing `ActiveWorkoutBloc`:

### `ActiveWorkoutRunning` — field changes

**Remove** (planned in SCR-16 data-model but superseded by SCR-19):
```dart
// REMOVED — SCR-19 owns the error state; writeError is never emitted for Finish
String? writeError;
```

**Add** (new field to carry the built session for navigation):
```dart
// NEW — holds the built session when navigateToPostWorkout is true;
// BlocListener reads this and passes it as route extra
final WorkoutSession? completedSession;
```

Updated `copyWith` signature includes `completedSession`.
Updated `props` includes `completedSession`.

### `ActiveWorkoutEvent` — event removed

**Remove** (planned in SCR-16 data-model but superseded by SCR-19):
```dart
// REMOVED — retry is handled by WorkoutSummaryBloc on SCR-19
class ActiveWorkoutRetryFinishRequested extends ActiveWorkoutEvent { ... }
```

### `ActiveWorkoutBloc` constructor — dependency removed

**SCR-16 contract** (superseded):
```dart
ActiveWorkoutBloc({required SaveWorkoutSessionUseCase saveWorkoutSession})
```

**Corrected constructor** (SCR-19 amendment):
```dart
ActiveWorkoutBloc()  // no use-case injection needed; save is owned by WorkoutSummaryBloc
    : super(const ActiveWorkoutInitial())
```

`SaveWorkoutSessionUseCase` registration in `get_it_setup.dart` is still needed —
but it is now registered for `WorkoutSummaryBloc`, not `ActiveWorkoutBloc`.

### `_triggerFinish` → `_prepareFinish`

**SCR-16 contract** `_triggerFinish` (superseded):
```dart
// Called when last set of last exercise is logged
Future<void> _triggerFinish(Emitter emit) async {
  final session = _buildSession();
  _completedSession = session;
  final result = await _saveWorkoutSession(session);  // ← REMOVED from this Bloc
  result.fold(
    (failure) => emit(_currentState.copyWith(writeError: failure.message, ...)),
    (_) { _completedSession = null; },
  );
}
```

**Corrected `_prepareFinish`** (SCR-19 amendment):
```dart
void _prepareFinish(Emitter emit) {
  final session = _buildSession();
  emit(_buildRunning().copyWith(
    navigateToPostWorkout: true,
    completedSession: session,
  ));
}
```

No `async`, no use-case call, no `writeError`. The session is built and put into
emitted state so the BlocListener can pick it up and pass it to SCR-19 as `extra`.

### New event: `ActiveWorkoutPostWorkoutNavigated`

```dart
class ActiveWorkoutPostWorkoutNavigated extends ActiveWorkoutEvent {
  const ActiveWorkoutPostWorkoutNavigated();
}
```

Dispatched by BlocListener after `context.go(RoutePaths.postWorkout, extra: ...)`.
Handler:
```dart
void _onPostWorkoutNavigated(ActiveWorkoutPostWorkoutNavigated event, Emitter emit) {
  if (state is! ActiveWorkoutRunning) return;
  emit((state as ActiveWorkoutRunning).copyWith(
    navigateToPostWorkout: false,
    completedSession: null,
  ));
}
```

This follows the same pattern as `ActiveWorkoutCancelNavigated` (SCR-18).

### `active_workout_screen.dart` BlocListener amendment

Existing SCR-16 stub for `navigateToPostWorkout` (no extra):
```dart
if (state.shouldNavigateToPostWorkout) {
  context.go(RoutePaths.postWorkout);  // ← old stub, no extra
}
```

Corrected (SCR-19 amendment):
```dart
if (state.navigateToPostWorkout && state.completedSession != null) {
  context.go(RoutePaths.postWorkout, extra: state.completedSession);
  context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutPostWorkoutNavigated());
}
```

---

## New Bloc: `WorkoutSummaryBloc`

### Event hierarchy

```dart
// workout_summary_event.dart
sealed class WorkoutSummaryEvent extends Equatable {}

final class WorkoutSummaryStarted extends WorkoutSummaryEvent {
  const WorkoutSummaryStarted({required this.session});
  final WorkoutSession session;
  @override
  List<Object?> get props => [session];
}

final class WorkoutSummaryRetryRequested extends WorkoutSummaryEvent {
  const WorkoutSummaryRetryRequested();
  @override
  List<Object?> get props => [];
}
```

### State hierarchy

```dart
// workout_summary_state.dart
sealed class WorkoutSummaryState extends Equatable {}

final class WorkoutSummaryInitial extends WorkoutSummaryState {
  const WorkoutSummaryInitial();
  @override List<Object?> get props => [];
}

final class WorkoutSummaryLoading extends WorkoutSummaryState {
  const WorkoutSummaryLoading({required this.planName});
  final String planName;
  @override List<Object?> get props => [planName];
}

final class WorkoutSummarySuccess extends WorkoutSummaryState {
  const WorkoutSummarySuccess({required this.session});
  final WorkoutSession session;
  @override List<Object?> get props => [session];
}

final class WorkoutSummaryError extends WorkoutSummaryState {
  const WorkoutSummaryError({required this.planName, required this.sessionId});
  final String planName;
  final String sessionId;
  @override List<Object?> get props => [planName, sessionId];
}
```

### Bloc class shape

```dart
// workout_summary_bloc.dart
class WorkoutSummaryBloc extends Bloc<WorkoutSummaryEvent, WorkoutSummaryState> {
  WorkoutSummaryBloc({required WorkoutSessionRepository repository})
      : _repository = repository,
        super(const WorkoutSummaryInitial()) {
    on<WorkoutSummaryStarted>(_onStarted);
    on<WorkoutSummaryRetryRequested>(_onRetryRequested);
  }

  final WorkoutSessionRepository _repository;
  WorkoutSession? _session;  // retained for retry
}
```

### State transition table

| Current state | Event | Guard | → Next state |
|---|---|---|---|
| `Initial` | `Started(session)` | — | `Loading(planName: session.planName)` |
| `Loading` | — | dedup found | `Success(session: existing)` |
| `Loading` | — | dedup miss + save OK | `Success(session: _session)` |
| `Loading` | — | dedup miss + save fail | `Error(planName, sessionId)` |
| `Error` | `RetryRequested` | — | `Loading(planName)` |
| `Loading` (retry) | — | dedup found | `Success` (idempotent) |
| `Loading` (retry) | — | save OK | `Success` |
| `Loading` (retry) | — | save fail | `Error` |

---

## AppStrings (SCR-19)

Section added to `forge/lib/core/strings/app_strings.dart`:

```dart
// SCR-19: Workout Summary & Completion
static const String workoutSummaryLoadingButton = 'Saving Workout…';
static const String workoutSummaryDoneButton = 'Done';
static const String workoutSummaryViewHistoryButton = 'View History';
static const String workoutSummarySetsLabel = 'Sets';
static const String workoutSummaryExercisesLabel = 'Exercises';
static const String workoutSummaryDurationSuffix = 'min';
static const String workoutSummarySkippedPill = 'Skipped';
static const String workoutSummaryErrorTitle = "Couldn't save your workout";
static const String workoutSummaryErrorMessage =
    'Your logged sets are preserved in memory and have not been recorded to history yet.';
static const String workoutSummaryRetryButton = 'Retry';
```

(Plan name in the error state is read from `WorkoutSummaryError.planName` — not a
string constant; it is displayed as a widget-level `Text(state.planName)`.)

---

## AppColors amendment (SCR-19)

Add to `forge/lib/core/theme/app_colors.dart`:

```dart
static const Color successBg = Color(0xFF1E2A12); // success hero icon fill
```

Naming follows the existing `dangerBg` / `amberBg` convention (dark tinted fill
for contextual icon containers). The design spec draft used `successFill` — the
canonical token name in this codebase is `successBg`.

---

## Route amendment (replaces SCR-16 stub)

In `forge/lib/config/routes/app_routes.dart`, replace:

```dart
// SCR-19 stub (created by SCR-16)
GoRoute(
  path: RoutePaths.postWorkout,
  name: RoutePaths.postWorkoutName,
  builder: (_, __) => Scaffold(
    body: Center(child: Text(AppStrings.postWorkoutStubLabel)),
  ),
),
```

With:

```dart
GoRoute(
  path: RoutePaths.postWorkout,
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

---

## DI registration (addition to `get_it_setup.dart`)

```dart
// workout_session section — add alongside existing WorkoutSessionRepository registration
getIt.registerFactory<WorkoutSummaryBloc>(
  () => WorkoutSummaryBloc(repository: getIt<WorkoutSessionRepository>()),
);
```

---

## Widget shape: `WorkoutSummaryScreen`

```dart
class WorkoutSummaryScreen extends StatefulWidget {
  const WorkoutSummaryScreen({super.key});
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  bool _isRetrying = false;  // double-tap guard on Retry button (FR-015)

  void _handleRetry() {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);
    context.read<WorkoutSummaryBloc>().add(const WorkoutSummaryRetryRequested());
  }
  // _isRetrying is reset when Loading state is emitted (BlocListener resets it)
}
```

`PopScope(canPop: false)` wraps the body; `onPopInvokedWithResult` is a no-op
(FR-013 / FR-014).

### Navigation actions (BlocListener)

```dart
BlocListener<WorkoutSummaryBloc, WorkoutSummaryState>(
  listener: (context, state) {
    if (state is WorkoutSummaryLoading) {
      setState(() => _isRetrying = false);  // reset guard when loading begins
    }
  },
  child: ...,
)
```

Done and View History are synchronous button callbacks:
```dart
void _handleDone() => context.go(RoutePaths.home);
void _handleViewHistory() => context.push(RoutePaths.workoutHistory);
```

No `async` gap → no `context.mounted` check needed (CLAUDE.md rule 63).

---

## Named public widgets

### `SetPill`

```dart
class SetPill extends StatelessWidget {
  const SetPill({super.key, required this.set, required this.exerciseType});
  final ActualSet set;
  final ExerciseType exerciseType;
}
```

Renders the correct format per `exerciseType` and `set.skipped`. The muted
strikethrough style for skipped pills uses `AppColors.textDim` and
`TextDecoration.lineThrough`.

### `ExerciseBreakdownCard`

```dart
class ExerciseBreakdownCard extends StatelessWidget {
  const ExerciseBreakdownCard({super.key, required this.exercise});
  final SessionExercise exercise;
}
```

Renders exercise name, type indicator chip (lime/cyan/muted), and a `Wrap` of
`SetPill` widgets for each set in `exercise.actualSets`.
