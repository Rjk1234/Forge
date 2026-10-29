# Data Model: SCR-21 Workout History Detail

**Date**: 2026-09-23 | **Branch**: `001-scr-21-workout-history-detail`

---

## 1. Existing Domain Entities (read-only for SCR-21)

SCR-21 creates no new domain entities. It reads the existing `WorkoutSession` hierarchy.

### WorkoutSession

```dart
// forge/lib/features/workout_session/domain/entities/workout_session.dart
class WorkoutSession extends Equatable {
  final String sessionId;
  final String planId;           // retained but NOT used for display reads
  final String planName;         // snapshot at completion time
  final DateTime completedAt;
  final int sessionDurationSec;
  final List<SessionExercise> sessionExercises;
  // startedAt → added by SCR-16 (prerequisite); fallback: completedAt
}
```

**Display mapping for SCR-21**:

| Display element | Source | Formula |
|---|---|---|
| Hero name | `planName` | direct |
| Hero date/time | `startedAt ?? completedAt` | `"Ddd, Mon D, YYYY · H:MM AM/PM"` — see D-04 |
| Duration stat | `sessionDurationSec` | `(sessionDurationSec / 60).round()` → `"38 min"` |
| Exercises stat | `sessionExercises` | `sessionExercises.length` |
| Sets Logged stat | `sessionExercises[*].actualSets` | `sum of actualSets.length` across all exercises |

### SessionExercise

```dart
// forge/lib/features/workout_session/domain/entities/session_exercise.dart
class SessionExercise extends Equatable {
  final String exerciseId;
  final String exerciseName;   // snapshot at completion time
  final ExerciseType type;     // weighted | timeBased | bodyweight
  final List<ActualSet> actualSets;
}
```

**Type-dot colour mapping** (D-06):
- `ExerciseType.weighted` → `AppColors.lime`
- `ExerciseType.timeBased` → `AppColors.cyan`
- `ExerciseType.bodyweight` → `AppColors.textDim`

### ActualSet

```dart
// forge/lib/features/workout_session/domain/entities/actual_set.dart
class ActualSet extends Equatable {
  final int? repetitions;
  final double? weight;
  final int? durationSec;
  // skipped → added by SCR-16 (prerequisite); until then, treat all as non-skipped
}
```

**Set pill format by type** (D-05):
- `ExerciseType.weighted` + not skipped: `'${set.repetitions}×${set.weight?.toStringAsFixed(set.weight! % 1 == 0 ? 0 : 1)}kg'` e.g. `"8×60kg"`
- `ExerciseType.bodyweight` + not skipped: `'${set.repetitions}${AppStrings.detailBodyweightRepsSuffix}'` e.g. `"15 reps"`
- `ExerciseType.timeBased` + not skipped: `MM:SS` (upgrade to `H:MM:SS` if `durationSec >= 3600`)
- Skipped (SCR-16): `AppStrings.detailSetSkippedLabel` with strikethrough + `AppColors.textDim`

---

## 2. Use Case

```dart
// forge/lib/features/workout_session/application/use_cases/
//     get_workout_history_detail_use_case.dart
class GetWorkoutHistoryDetailUseCase {
  final WorkoutSessionRepository _repository;
  const GetWorkoutHistoryDetailUseCase(this._repository);

  Future<Either<AppException, WorkoutSession>> call(String sessionId) async {
    final result = await _repository.getSessionById(sessionId);
    return result.flatMap((session) {
      if (session == null) {
        return Left(CacheException(message: "Session not found in local storage"));
      }
      return Right(session);
    });
  }
}
```

`Right(null)` from `getSessionById` (session missing) is mapped to `Left(CacheException)` — treated as a read failure and shown as Error state.

---

## 3. Bloc Events

```dart
// forge/lib/features/workout_session/application/bloc/
//     workout_history_detail_event.dart
sealed class WorkoutHistoryDetailEvent extends Equatable {
  const WorkoutHistoryDetailEvent();
}

final class WorkoutHistoryDetailLoadRequested extends WorkoutHistoryDetailEvent {
  const WorkoutHistoryDetailLoadRequested({required this.sessionId});
  final String sessionId;
  @override List<Object?> get props => [sessionId];
}
```

Single event. Fired from `WorkoutHistoryDetailScreen.initState()`.

---

## 4. Bloc States

```dart
// forge/lib/features/workout_session/application/bloc/
//     workout_history_detail_state.dart
sealed class WorkoutHistoryDetailState extends Equatable {
  const WorkoutHistoryDetailState();
}

final class WorkoutHistoryDetailInitial extends WorkoutHistoryDetailState {
  const WorkoutHistoryDetailInitial();
  @override List<Object?> get props => [];
}

final class WorkoutHistoryDetailLoading extends WorkoutHistoryDetailState {
  const WorkoutHistoryDetailLoading();
  @override List<Object?> get props => [];
}

final class WorkoutHistoryDetailSuccess extends WorkoutHistoryDetailState {
  final WorkoutSession session;
  const WorkoutHistoryDetailSuccess({required this.session});
  @override List<Object?> get props => [session];
}

final class WorkoutHistoryDetailError extends WorkoutHistoryDetailState {
  final String message;
  const WorkoutHistoryDetailError({required this.message});
  @override List<Object?> get props => [message];
}
```

**State invariants** (FR-016, FR-017):
- `Initial` and `Loading` MUST both render `DetailSkeleton` — no blank screen in either state.
- `WorkoutHistoryDetailEmpty` does NOT exist. Zero exercises → `WorkoutHistoryDetailSuccess` with `session.sessionExercises.isEmpty`.
- `WorkoutHistoryDetailError` is emitted ONLY on `Left(AppException)` or `Right(null)` from the use case.

---

## 5. AppStrings (new constants for SCR-21)

```dart
// forge/lib/core/strings/app_strings.dart — additions

// SCR-21: Workout History Detail
static const String detailScreenTitle         = 'Workout Detail';
static const String detailErrorTitle          = "Couldn't load this workout";
static const String detailErrorBody           =
    'Something went wrong reading local data. '
    'Your workout history is unaffected.';
static const String detailRetryLabel          = 'Retry';
static const String detailSectionPerformance  = 'Performance';
static const String detailStatDurationLabel   = 'DURATION';
static const String detailStatExercisesLabel  = 'EXERCISES';
static const String detailStatSetsLoggedLabel = 'SETS LOGGED';
static const String detailStatMinSuffix       = ' min';
static const String detailSetCountSuffix      = ' sets';
static const String detailBodyweightRepsSuffix = ' reps';
static const String detailSetSkippedLabel     = 'Skipped';
```

12 new constants. All display strings use static constants; formatted values use Dart string interpolation (`'$count${AppStrings.detailSetCountSuffix}'`).

---

## 6. AppColors (no new tokens)

All tokens used by SCR-21 already exist:

| Token | Value | Usage |
|-------|-------|-------|
| `AppColors.bg` | `0xFF131315` | screen background |
| `AppColors.card` | `0xFF201F22` | stat boxes, exercise cards, error card |
| `AppColors.cardAlt` | `0xFF2A2A2C` | skeleton base, set pill background |
| `AppColors.border` | `0xFF444933` | card borders |
| `AppColors.lime` | `0xFFC3F400` | weighted type dot, retry button background |
| `AppColors.cyan` | `0xFF7DF4FF` | timeBased type dot |
| `AppColors.textDim` | `0xFF8A8F7A` | bodyweight type dot, stat labels, section label, appbar Loading dim |
| `AppColors.textMuted` | `0xFFC4C9AC` | hero-meta date/time |
| `AppColors.white` | `0xFFF5F6F1` | primary text, stat values, exercise names |
| `AppColors.danger` | `0xFFFF6B6B` | error icon |
| `AppColors.dangerBg` | `0xFF2A1F1F` | error card background |
| `AppColors.dangerBorder` | `0xFF5C3A3A` | error card border |
| `AppColors.onLime` | `0xFF131315` | retry button text on lime |

No new `AppColors` tokens required. Shimmer sweep colour `rgba(255,255,255,.06)` is a file-private local constant: `const Color(0x0FFFFFFF)`.

---

## 7. New Route Constant

```dart
// forge/lib/config/routes/app_routes.dart
static const String workoutHistoryDetail = '/history/detail';
```

The detail screen is a push route nested under the history branch. `state.extra` carries the `sessionId` String.

---

## 8. Widget Shapes

### WorkoutHistoryDetailScreen

```dart
// forge/lib/features/workout_session/presentation/screens/
//     workout_history_detail_screen.dart
class WorkoutHistoryDetailScreen extends StatefulWidget {
  final String sessionId;
  const WorkoutHistoryDetailScreen({super.key, required this.sessionId});
}
```

`initState` dispatches `WorkoutHistoryDetailLoadRequested(sessionId: widget.sessionId)`.

`BlocBuilder<WorkoutHistoryDetailBloc, WorkoutHistoryDetailState>` `switch`:
- `WorkoutHistoryDetailInitial`, `WorkoutHistoryDetailLoading` → `DetailSkeleton()`
- `WorkoutHistoryDetailSuccess` → scrollable detail content
- `WorkoutHistoryDetailError` → error card with Retry button

### DetailSkeleton

```dart
// forge/lib/features/workout_session/presentation/widgets/detail_skeleton.dart
class DetailSkeleton extends StatefulWidget {
  const DetailSkeleton({super.key});
}
```

Stateful — owns `AnimationController(duration: Duration(milliseconds: 1400))` with `repeat()`. Uses translate-based sweep `Color(0x0FFFFFFF)` over `AppColors.cardAlt` skeleton shapes. Disposes controller in `dispose()`.

### SessionExerciseCard

```dart
// forge/lib/features/workout_session/presentation/widgets/session_exercise_card.dart
class SessionExerciseCard extends StatelessWidget {
  final SessionExercise exercise;
  const SessionExerciseCard({super.key, required this.exercise});
}
```

Renders: type-dot, exercise name, set count tag (`'${exercise.actualSets.length}${AppStrings.detailSetCountSuffix}'`), and a `Wrap` of `SetPill` widgets.

### SetPill

```dart
// forge/lib/features/workout_session/presentation/widgets/set_pill.dart
class SetPill extends StatelessWidget {
  final ActualSet set;
  final ExerciseType type;
  const SetPill({super.key, required this.set, required this.type});
}
```

Renders the appropriate pill variant based on `type` and `set.skipped` (SCR-16 guard). Skipped variant: `AppColors.textDim` text + `TextDecoration.lineThrough` + `FontWeight.w600`.

### SessionStatBox

```dart
// forge/lib/features/workout_session/presentation/widgets/session_stat_box.dart
class SessionStatBox extends StatelessWidget {
  final String label;
  final String value;
  const SessionStatBox({super.key, required this.label, required this.value});
}
```

Renders label (uppercase, `AppColors.textDim`, `10px/700`) and value (primary text, `18px/800`) in a bordered `card`-background box. One of three in the stat row.
