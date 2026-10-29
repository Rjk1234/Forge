# Data Model: SCR-16 Active Workout

**Phase 1 — entity changes, state model, and AppStrings**

---

## Existing domain entities — changes required

### `ActualSet` — add `skipped: bool`

```
forge/lib/features/workout_session/domain/entities/actual_set.dart
```

Add one field and include in `props`:

```dart
final bool skipped;  // true if this set was skipped during execution
```

Constructor change:
```dart
const ActualSet({this.repetitions, this.weight, this.durationSec, this.skipped = false});
```

`props` update:
```dart
@override
List<Object?> get props => [repetitions, weight, durationSec, skipped];
```

---

### `WorkoutSession` — add `startedAt: DateTime`

```
forge/lib/features/workout_session/domain/entities/workout_session.dart
```

Add one field and include in `props`:

```dart
final DateTime startedAt;  // session began at this instant (entered SCR-16)
```

Constructor: `required this.startedAt`

`props` update: add `startedAt`.

Note: `sessionDurationSec` is computed as `completedAt.difference(startedAt).inSeconds` at Finish time. Both fields are stored.

---

## Existing storage records — additive field changes

### `ActualSetRecord` — add `bool skipped` (`skipped` column)

```
forge/lib/features/workout_session/data/models/actual_set_record.dart
```

```dart
final bool skipped;

const ActualSetRecord({this.repetitions, this.weight, this.durationSec, this.skipped = false});
```

Schema: `actual_sets` table gains `BoolColumn get skipped => boolean().withDefault(const Constant(false))()`; regenerate Drift code with `flutter pub run build_runner build --delete-conflicting-outputs`.

---

### `WorkoutSessionRecord` — add `DateTime? startedAt` (`started_at` column)

```
forge/lib/features/workout_session/data/models/workout_session_record.dart
```

```dart
final DateTime? startedAt;
```

Nullable in the storage record and `started_at` column (`DateTimeColumn get startedAt => dateTime().nullable()()`) so rows without a start timestamp remain valid. Constructor: `this.startedAt`.

Regenerate Drift code with the same `build_runner` command.

---

## Mapper updates

```
forge/lib/features/workout_session/data/mappers/workout_session_mapper.dart
```

**`toDomain` — `ActualSet`**:
```dart
static ActualSet _actualSetToDomain(ActualSetRecord model) => ActualSet(
  repetitions: model.repetitions,
  weight: model.weight,
  durationSec: model.durationSec,
  skipped: model.skipped,  // ← NEW
);
```

**`toDomain` — `WorkoutSession`**:
```dart
static WorkoutSession toDomain(WorkoutSessionRecord model) =>
    WorkoutSession(
      sessionId: model.sessionId,
      planId: model.planId,
      planName: model.planName,
      completedAt: model.completedAt,
      startedAt: model.startedAt ?? model.completedAt,  // ← NEW (fallback for old records)
      sessionDurationSec: model.sessionDurationSec,
      sessionExercises: model.sessionExercises
          .map(_sessionExerciseToDomain)
          .toList(growable: false),
    );
```

**`toRecord` — `ActualSet`**:
```dart
static ActualSetRecord _actualSetToRecord(ActualSet set) =>
    ActualSetRecord(
      repetitions: set.repetitions,
      weight: set.weight,
      durationSec: set.durationSec,
      skipped: set.skipped,  // ← NEW
    );
```

**`toRecord` — `WorkoutSession`**:
```dart
static WorkoutSessionRecord toRecord(WorkoutSession session) =>
    WorkoutSessionRecord(
      sessionId: session.sessionId,
      planId: session.planId,
      planName: session.planName,
      completedAt: session.completedAt,
      startedAt: session.startedAt,  // ← NEW
      sessionDurationSec: session.sessionDurationSec,
      sessionExercises: session.sessionExercises
          .map(_sessionExerciseToRecord)
          .toList(growable: false),
    );
```

---

## New Bloc state model

### `ActiveWorkoutState` sealed class hierarchy

```
ActiveWorkoutState (sealed)
├── ActiveWorkoutInitial          — before Started event; never rendered
└── ActiveWorkoutRunning          — all visible states (Active, Validation Error, Paused, Write Error)
```

### `ActiveWorkoutRunning` fields

| Field | Type | Nullable | Purpose |
|---|---|---|---|
| `currentExercise` | `PlanExercise` | No | Exercise name, type, target values for pre-population, field layout |
| `exerciseIndex` | `int` | No | 0-based index into plan.exercises (for display: +1) |
| `exerciseCount` | `int` | No | Total exercises in plan (for display: "2 / 5") |
| `currentSetIndex` | `int` | No | 0-based index within current exercise's sets |
| `setStatuses` | `List<SetStatus>` | No | One per set in current exercise; drives dot row |
| `repError` | `String?` | Yes | Inline error on Reps field; null = no error |
| `weightError` | `String?` | Yes | Inline error on Weight field; null = no error |
| `durationError` | `String?` | Yes | Inline error on Duration field; null = no error |
| `isPaused` | `bool` | No | When true: render Paused overlay on top of content |
| `writeError` | `String?` | Yes | Non-null when Finish write failed; drives write-error banner |
| `navigateToPostWorkout` | `bool` | No | Set true on successful Finish write; BlocListener routes to SCR-19; defaults false |
| `navigateToCancel` | `bool` | No | Set true on FR-009 discard trigger; BlocListener routes to SCR-18; defaults false |

```dart
class ActiveWorkoutRunning extends ActiveWorkoutState {
  const ActiveWorkoutRunning({
    required this.currentExercise,
    required this.exerciseIndex,
    required this.exerciseCount,
    required this.currentSetIndex,
    required this.setStatuses,
    this.repError,
    this.weightError,
    this.durationError,
    this.isPaused = false,
    this.writeError,
  });
  // ... fields ...

  @override
  List<Object?> get props => [
    currentExercise,
    exerciseIndex,
    exerciseCount,
    currentSetIndex,
    setStatuses,
    repError,
    weightError,
    durationError,
    isPaused,
    writeError,
    navigateToPostWorkout,
    navigateToCancel,
  ];

  ActiveWorkoutRunning copyWith({...}) { ... }
}
```

### Supporting enums

```dart
// active_workout_state.dart — UI state concern
enum SetStatus { pending, logged, skipped }

// active_workout_event.dart — first use is ActiveWorkoutFieldChanged; lives alongside the event that carries it
enum ActiveWorkoutField { reps, weight, duration }
```

---

## New Bloc event model

### `ActiveWorkoutEvent` sealed class hierarchy

```
ActiveWorkoutEvent (sealed)
├── ActiveWorkoutStarted({required WorkoutPlanDetail plan})
├── ActiveWorkoutCompleteSetRequested({int? reps, double? weight, int? durationSec})
├── ActiveWorkoutSkipSetRequested
├── ActiveWorkoutPauseRequested
├── ActiveWorkoutResumeRequested
├── ActiveWorkoutFieldChanged({required ActiveWorkoutField field, required String value})
└── ActiveWorkoutRetryFinishRequested
```

`ActiveWorkoutStarted` carries the full `WorkoutPlanDetail` — passed via route `extra` from SCR-15's `pushReplacement`. No second Drift read needed; the plan is already loaded.

---

## Route constants to add to `RoutePaths`

```dart
// Active workout (SCR-16)
static const String activeWorkout = '/workout/active';
static const String activeWorkoutName = 'activeWorkout';

// Cancel confirmation stub (SCR-18)
static const String cancelWorkout = '/workout/cancel';
static const String cancelWorkoutName = 'cancelWorkout';

// Post-workout summary stub (SCR-19)
static const String postWorkout = '/workout/summary';
static const String postWorkoutName = 'postWorkout';
```

---

## New AppStrings (SCR-16)

Section added to `forge/lib/core/strings/app_strings.dart`:

```dart
// SCR-16: Active Workout
static const String activeWorkoutExerciseCounter = 'Exercise';       // used: "Exercise 2 / 5"
static const String activeWorkoutOfSeparator = '/';
static const String activeWorkoutSetCounter = 'Set';                 // used: "Set 3 / 4"
static const String activeWorkoutCompleteSetButton = 'Complete Set';
static const String activeWorkoutSkipButton = 'Skip';
static const String activeWorkoutPauseButton = 'Pause';
static const String activeWorkoutResumeButton = 'Resume';
static const String activeWorkoutCancelButton = 'Cancel';
static const String activeWorkoutRepsLabel = 'Reps';
static const String activeWorkoutWeightLabel = 'Weight (kg)';
static const String activeWorkoutDurationLabel = 'Duration';

// Validation errors
static const String activeWorkoutRepErrorZero = 'Reps must be greater than 0';
static const String activeWorkoutWeightErrorNegative = 'Weight cannot be negative';
static const String activeWorkoutDurationErrorZero = 'Duration must be greater than 0';

// Write error (Finish failure)
static const String activeWorkoutWriteErrorTitle = "Couldn't save your workout";
static const String activeWorkoutWriteErrorBody =
    'Your session is preserved — tap Retry to save it. Your data is safe.';
static const String activeWorkoutRetryButton = 'Retry';

// Paused overlay
static const String activeWorkoutPausedTitle = 'Workout Paused';

// Stub screen labels (SCR-18 and SCR-19 placeholders)
static const String cancelWorkoutStubLabel = 'SCR-18 — Cancel Workout Confirmation (coming soon)';
static const String postWorkoutStubLabel = 'SCR-19 — Post-Workout Summary (coming soon)';
```
