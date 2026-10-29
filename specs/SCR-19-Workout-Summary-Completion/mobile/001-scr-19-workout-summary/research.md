# Research: SCR-19 Workout Summary & Completion

**Date**: 2026-09-23 | **Feature**: SCR-19

---

## Decisions

### D-01: Feature ownership — `workout_session`

SCR-19 lives entirely within the existing `workout_session` feature
(`forge/lib/features/workout_session/`). No new feature directory is needed. This
feature already owns the domain entities (`WorkoutSession`, `SessionExercise`,
`ActualSet`), storage records, repository interface, and repository implementation.

---

### D-02: Save ownership — `WorkoutSummaryBloc` (not `ActiveWorkoutBloc`)

**Decision**: The Drift write is owned by the new `WorkoutSummaryBloc` on SCR-19,
not by `ActiveWorkoutBloc` on SCR-16.

**Rationale**: SCR-19's spec requires the full loading/error/retry lifecycle to be
visible on the SCR-19 screen (FR-001, FR-008, US2). Placing the write in
`ActiveWorkoutBloc` would require the error to surface on SCR-16, contradicting
FR-008 ("navigate to the error state") and US2.

**SCR-16 contract amendments** (see `contracts/active-workout-bloc-amendments.md`):
- `SaveWorkoutSessionUseCase` is removed from `ActiveWorkoutBloc`'s constructor
- `writeError: String?` is removed from `ActiveWorkoutRunning` (was: Finish error banner)
- `ActiveWorkoutRetryFinishRequested` event is removed
- `_triggerFinish` is renamed `_prepareFinish`: builds session + emits
  `navigateToPostWorkout: true` with session in state — no Drift I/O
- New field `completedSession: WorkoutSession?` added to `ActiveWorkoutRunning`
  so the BlocListener can pass it as `extra` to the route

**Alternatives considered**:
- Save in `ActiveWorkoutBloc` with error banner on SCR-16 and a separate "success
  navigation" to SCR-19 → rejected: SCR-19 spec owns the error state
- Save in both Blocs with dedup coordination → rejected: unnecessary complexity

---

### D-03: New `WorkoutSummaryBloc`

A dedicated `WorkoutSummaryBloc` is introduced in
`workout_session/application/bloc/`. It is injected with `WorkoutSessionRepository`
(already registered as `LazySingleton` in `get_it_setup.dart`).

No new use case class is introduced: the repository's `getSessionById` and
`saveSession` methods are called directly from the Bloc. A use-case wrapper would
add a layer with no new logic and no existing cross-feature reuse need.

**Registered in `get_it_setup.dart` as**:
```dart
getIt.registerFactory<WorkoutSummaryBloc>(
  () => WorkoutSummaryBloc(repository: getIt<WorkoutSessionRepository>()),
);
```

`registerFactory` (not `LazySingleton`) — a fresh Bloc instance per session.

---

### D-04: Deduplication guard implementation

**Decision**: Before each write attempt, call
`repository.getSessionById(session.sessionId)`:
- `Right(non-null)` → session already saved → emit Success, no second write
- `Right(null)` → not yet saved → attempt `repository.saveSession(session)`
- `Left(failure)` → treat as "not found" and attempt write anyway (the write's
  own error path handles failure; a duplicate insert-or-replace is safe and idempotent)

**Rationale**: The dedup guard is predicated on the session ID being stable
(generated at SCR-16 start, held in `ActiveWorkoutBloc` private state through all
retry attempts). A failed `getSessionById` can't confirm absence, so we attempt
the write and let the save result propagate normally.

---

### D-05: Route registration and navigation

**Decision**: The existing SCR-16 stub at `RoutePaths.postWorkout = '/workout/summary'`
is replaced with a real `GoRoute.builder` (opaque full-screen, no custom transition):

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

**Navigation from SCR-16 BlocListener** (amendment to SCR-16 screen):
```dart
if (state.navigateToPostWorkout && state.completedSession != null) {
  context.go(RoutePaths.postWorkout, extra: state.completedSession);
  context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutPostWorkoutNavigated());
}
```

`context.go` (not `push`) replaces the stack: SCR-16 is removed (FR-003, SC-004).
The reset event clears `navigateToPostWorkout` and `completedSession` from state,
consistent with the existing `CancelNavigated` pattern from SCR-18.

---

### D-06: `successBg` color token

**Decision**: Add `AppColors.successBg = const Color(0xFF1E2A12)` to
`forge/lib/core/theme/app_colors.dart`.

**Naming**: Follows the existing convention (`dangerBg`, `amberBg`) — a dark tinted
fill for contextual containers. The spec draft called it `successFill` but `*Bg` is
the established pattern.

**Usage**: Hero icon container background on the success state's trophy/check icon.

---

### D-07: `WorkoutSummaryScreen` widget structure

- `StatefulWidget` with `bool _isRetrying = false` local state (double-tap guard
  for Retry button; FR-015)
- `PopScope(canPop: false)` — blocks OS back on all three states (FR-013, FR-014)
- `BlocBuilder<WorkoutSummaryBloc, WorkoutSummaryState>` renders three states:
  - **Loading**: Finish button transformed to loading row, Cancel suppressed — no
    active timer or set logging UI (static render matching SCR-16's visual chrome)
  - **Success**: full-screen summary with hero icon in `successBg` container, plan
    name, `session.startedAt` formatted as `{Day}, {Mon} {D} · {h:mm AM/PM}`,
    duration in minutes, stat row, exercise breakdown
  - **Error**: plan name prominent, failure message, reassurance line, Retry button
    (disabled when `_isRetrying`)
- `BlocListener` navigates on success: Done → `context.go(RoutePaths.home)`;
  View History → `context.push(RoutePaths.workoutHistory)` (SCR-20 route, defined
  in its own spec)

Named public widgets for reusable concepts:
- `SetPill` — renders one set's pill (weighted/bodyweight/time/skipped)
- `ExerciseBreakdownCard` — renders one exercise entry in the breakdown

---

### D-08: Session display values

| Displayed field | Source |
|---|---|
| Plan name | `session.planName` |
| Date/time | `session.startedAt` (added by SCR-16 amendment) formatted `EEE, MMM d · h:mm a` |
| Duration | `session.sessionDurationSec ~/ 60` displayed as `"{N} min"` |
| Exercises count | `session.sessionExercises.length` (all exercises in plan, per OQ-5) |
| Sets logged count | count of sets where `!set.skipped` across all exercises (per OQ-4) |
| Set pill — weighted | `"${set.actualReps}×${set.weight!.toStringAsFixed(1)}kg"` but trim trailing `.0` → `"${set.weight! % 1 == 0 ? set.weight!.toInt() : set.weight}kg"` |
| Set pill — bodyweight | `"${set.actualReps} reps"` |
| Set pill — time | `"${(set.durationSec! ~/ 60).toString().padLeft(2, '0')}:${(set.durationSec! % 60).toString().padLeft(2, '0')}"` |
| Set pill — skipped | `AppStrings.workoutSummarySkippedPill = 'Skipped'` with muted strikethrough |

`startedAt` availability: SCR-16's data-model amends `WorkoutSession` to add
`startedAt: DateTime`. SCR-19 depends on SCR-16 being implemented first.

---

### D-09: No new tables, no new packages

All tables are already defined in `AppDatabase`. SCR-19 reads from Drift
(via `getSessionById` for dedup) and writes to Drift (via `saveSession`). No schema change and no `build_runner` run needed for SCR-19 alone.

The `skipped: bool` field (on the `actual_sets` table) and `startedAt: DateTime?`
(on the `workout_sessions` table) are added by SCR-16 and regenerated during SCR-16
implementation. SCR-19 relies on those fields being present.

No new package is introduced. Constitution Principle IX.5 is satisfied.
