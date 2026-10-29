# Data Model: SCR-20 Workout History List

**Date**: 2026-09-23 | **Branch**: `001-scr-20-workout-history-list`

---

## 1. Existing Domain Entities (read-only for SCR-20)

SCR-20 creates no new domain entities. It reads the existing `WorkoutSession` entity and its nested types.

### WorkoutSession

```dart
// forge/lib/features/workout_session/domain/entities/workout_session.dart
class WorkoutSession extends Equatable {
  final String sessionId;
  final String planId;
  final String planName;           // snapshot at completion time
  final DateTime completedAt;
  final int sessionDurationSec;
  final List<SessionExercise> sessionExercises;
  // startedAt → added by SCR-16 (prerequisite)
}
```

**Display mapping**:
| Display field | Source | Formula |
|---|---|---|
| Day number | `startedAt` (SCR-16) or `completedAt` | `date.day.toString().padLeft(2, '0')` |
| Day-of-week | `startedAt` (SCR-16) or `completedAt` | `_dowAbbr[date.weekday - 1]` |
| Plan name | `planName` | direct |
| Duration (min) | `sessionDurationSec` | `sessionDurationSec ~/ 60` |
| Exercise count | `sessionExercises` | `sessionExercises.length` |
| Sets count | `sessionExercises[*].actualSets` | sum of non-skipped sets (see D-07) |
| Month group label | `startedAt` (SCR-16) or `completedAt` | `'${_monthNames[date.month - 1]} ${date.year}'` |

### SessionExercise

```dart
// Already defined; SCR-20 reads only actualSets.length (or filtered by skipped)
class SessionExercise extends Equatable {
  final String exerciseId;
  final String exerciseName;
  final ExerciseType type;
  final List<ActualSet> actualSets;
}
```

### ActualSet

```dart
// SCR-16 adds: final bool skipped;
class ActualSet extends Equatable {
  final int? repetitions;
  final double? weight;
  final int? durationSec;
  // skipped → added by SCR-16 (prerequisite)
}
```

---

## 2. New Value Class (application layer)

```dart
// forge/lib/features/workout_session/application/models/history_month_group.dart
class HistoryMonthGroup extends Equatable {
  final String label;                  // "September 2026"
  final List<WorkoutSession> sessions; // newest-first within this month
  const HistoryMonthGroup({required this.label, required this.sessions});
  @override List<Object?> get props => [label, sessions];
}
```

This class is constructed by `WorkoutHistoryBloc._onLoadRequested` from the sorted list returned by the use-case. It is NOT a domain entity — it is a state artifact for the presentation layer.

---

## 3. Use Case

```dart
// forge/lib/features/workout_session/application/use_cases/get_workout_history_use_case.dart
class GetWorkoutHistoryUseCase {
  final WorkoutSessionRepository _repository;
  const GetWorkoutHistoryUseCase(this._repository);

  Future<Either<AppException, List<WorkoutSession>>> call() async {
    final result = await _repository.getAllSessions();
    return result.map((sessions) {
      final date = (WorkoutSession s) => s.startedAt ?? s.completedAt; // SCR-16 guard
      return [...sessions]..sort((a, b) => date(b).compareTo(date(a)));
    });
  }
}
```

Returns `Either<AppException, List<WorkoutSession>>` sorted newest-first. The Bloc handles the `Left` (error) and `Right` (success/empty distinction) branches.

---

## 4. Bloc Events

```dart
// forge/lib/features/workout_session/application/bloc/workout_history_event.dart
sealed class WorkoutHistoryEvent extends Equatable {
  const WorkoutHistoryEvent();
}

final class WorkoutHistoryLoadRequested extends WorkoutHistoryEvent {
  const WorkoutHistoryLoadRequested();
  @override List<Object?> get props => [];
}
```

Single event. Fired by `WorkoutHistoryScreen.didChangeDependencies()` on every tab-switch entry.

---

## 5. Bloc States

```dart
// forge/lib/features/workout_session/application/bloc/workout_history_state.dart
sealed class WorkoutHistoryState extends Equatable {
  const WorkoutHistoryState();
}

final class WorkoutHistoryInitial extends WorkoutHistoryState {
  const WorkoutHistoryInitial();
  @override List<Object?> get props => [];
}

final class WorkoutHistoryLoading extends WorkoutHistoryState {
  const WorkoutHistoryLoading();
  @override List<Object?> get props => [];
}

final class WorkoutHistorySuccess extends WorkoutHistoryState {
  final List<HistoryMonthGroup> groups;
  const WorkoutHistorySuccess({required this.groups});
  @override List<Object?> get props => [groups];
}

final class WorkoutHistoryEmpty extends WorkoutHistoryState {
  const WorkoutHistoryEmpty();
  @override List<Object?> get props => [];
}

final class WorkoutHistoryError extends WorkoutHistoryState {
  final String message;
  const WorkoutHistoryError({required this.message});
  @override List<Object?> get props => [message];
}
```

State invariant: `WorkoutHistoryEmpty` is emitted only when the read succeeds AND the list is empty. `WorkoutHistoryError` is emitted only when the read fails. They are **never** interchangeable (FR-007).

---

## 6. AppStrings (new constants for SCR-20)

```dart
// forge/lib/core/strings/app_strings.dart — additions
static const String historyScreenTitle         = 'History';
static const String historyEmptyTitle          = 'No workout history yet';
static const String historyEmptySubtitle       = 'Your completed workouts will appear here.';
static const String historyErrorTitle          = "Couldn't load your history";
static const String historyErrorBody           =
    'Something went wrong reading local data. Your plans and schedule are unaffected.';
static const String historyRetryLabel          = 'Retry';
```

Six new constants. Month labels are constructed dynamically (static array lookup — see D-04 in research.md) and are not string constants.

---

## 7. AppColors (no new tokens)

`AppColors.shimmerDark` (`0xFF35342F`) already exists and serves as the shimmer animation dark stop. No new color token is required for SCR-20.

Error card styling uses existing tokens:
- Background: `AppColors.dangerBg` (`0xFF2A1F1F`)
- Border: `AppColors.dangerBorder` (`0xFF5C3A3A`)
- Icon / title: `AppColors.danger` (`0xFFFF6B6B`)

---

## 8. Public Widget Shape

### HistoryCard

```dart
// forge/lib/features/workout_session/presentation/widgets/history_card.dart
class HistoryCard extends StatelessWidget {
  final String dayNumber;    // "07"
  final String dayOfWeek;   // "MON"
  final String planName;
  final String summaryLine;  // "42 min · 5 exercises · 18 sets"
  final VoidCallback onTap;
  const HistoryCard({
    super.key,
    required this.dayNumber,
    required this.dayOfWeek,
    required this.planName,
    required this.summaryLine,
    required this.onTap,
  });
}
```

Renders a tappable card with a date-badge column (day number + day-of-week abbreviation), a body column (plan name + summary line), and a trailing chevron. All colors from `AppColors` / `colorScheme`; all text styles from `theme.textTheme`.

### HistoryMonthLabel

```dart
// forge/lib/features/workout_session/presentation/widgets/history_month_label.dart
class HistoryMonthLabel extends StatelessWidget {
  final String label;  // "September 2026"
  const HistoryMonthLabel({super.key, required this.label});
}
```

A section header rendered above each month group. Uses `theme.textTheme.labelMedium` or similar, `AppColors.textMuted` color.

### HistorySkeleton

```dart
// forge/lib/features/workout_session/presentation/widgets/history_skeleton.dart
class HistorySkeleton extends StatefulWidget {
  const HistorySkeleton({super.key});
}
```

Stateful (owns `AnimationController`). Renders 4–5 placeholder card rows with a sweeping `LinearGradient` shimmer. Colors: `AppColors.cardAlt` (light stop) → `AppColors.shimmerDark` (dark stop). Disposes `AnimationController` in `dispose()`.
