# Research: SCR-20 Workout History List

**Date**: 2026-09-23 | **Branch**: `001-scr-20-workout-history-list`

---

## D-01: Re-fetch Strategy

**Decision**: `WorkoutHistoryScreen` is a `StatefulWidget`. `didChangeDependencies()` fires `WorkoutHistoryLoadRequested` on every tab-switch entry. This is the same pattern used by `HomeScreen` (confirmed in `forge/lib/features/home/presentation/screens/home_screen.dart`).

**Rationale**: FR-012 requires a re-fetch on every tab-switch entry. `didChangeDependencies` is called whenever the widget is first mounted and whenever it re-enters the composition tree, which aligns with every tab-switch entry. A `StatefulShellRoute` back-navigation from SCR-21 does **not** re-trigger `didChangeDependencies` on the history screen (the screen stays in the tree), so FR-011 (preserve on back) is satisfied automatically without extra guard logic.

**Alternatives considered**: Using `BlocListener` on a tab-active event — rejected because no tab-change stream is exposed; the `didChangeDependencies` approach is idiomatic Flutter for this pattern.

---

## D-02: Sort Location

**Decision**: Sort sessions by `startedAt` descending inside `GetWorkoutHistoryUseCase.call()`. The use-case returns a pre-sorted `List<WorkoutSession>`.

**Rationale**: Sorting is a domain-level business rule ("newest first"), not a UI concern. Placing it in the use-case keeps the Bloc thin and makes the sort independently testable. The Bloc simply consumes the sorted list and groups it.

**Alternatives considered**: Sorting in the Bloc — rejected; Blocs should coordinate state transitions, not implement sort logic. Sorting in the repository — rejected; the repository interface should remain generic and not impose view-specific ordering.

---

## D-03: Grouping Representation

**Decision**: The Bloc's success state holds a `List<HistoryMonthGroup>`, where `HistoryMonthGroup` is a plain Dart value class defined in `application/`:

```dart
class HistoryMonthGroup extends Equatable {
  final String label;          // "September 2026"
  final List<WorkoutSession> sessions; // newest-first within group
}
```

The Bloc constructs these groups in `_onLoadRequested` from the sorted `List<WorkoutSession>` returned by the use-case.

**Rationale**: Grouping by month is a presentation-time transformation, but the label string depends on the `startedAt` field (a domain entity field). Embedding the label in the value class at Bloc time avoids computing it repeatedly in the `build()` method. Keeping the class in `application/` is correct — it is a state artifact, not a domain entity.

---

## D-04: Date Formatting (No `intl` Package)

**Decision**: Use pure Dart static lookup arrays for all date-to-string conversions. No `intl` package.

```dart
// In a file-private helper or _DateFormatter utility
const _monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'];

const _dowAbbr = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

String monthLabel(DateTime date) => '${_monthNames[date.month - 1]} ${date.year}';
String dowLabel(DateTime date)   => _dowAbbr[date.weekday - 1]; // weekday: 1=Mon..7=Sun
String dayLabel(DateTime date)   => date.day.toString().padLeft(2, '0');
```

**Rationale**: `intl` is not in the ADR-030 governed package set. Adding it would require a new ADR. The date fields needed (month name, day-of-week abbreviation, zero-padded day, year) can all be derived from `DateTime` fields using a static array lookup — no locale parsing, no ICU dependency. This avoids the ADR process and any future package-version friction.

**Alternatives considered**: `intl.DateFormat` — rejected because `intl` is not in the governed set. Dart 3 extension methods on `DateTime` — accepted as the implementation mechanism (the helper functions above).

---

## D-05: Shimmer Animation

**Decision**: Pure Flutter `AnimationController` (repeat, vsync-aware) + `AnimatedBuilder` + `LinearGradient` sweep across placeholder `Container` widgets. Two color stops: `AppColors.cardAlt` (light) → `AppColors.shimmerDark` (dark) → `AppColors.cardAlt` (light).

**Rationale**: `AppColors.shimmerDark` (`0xFF35342F`) already exists in `app_colors.dart`. No new color token required. No new package required. A `TweenSequence<double>` or `Tween<double>` on the `begin`/`end` of the gradient's `stops` list produces the sweep effect.

**Alternatives considered**: `shimmer` package (pub.dev) — rejected (ADR-030; would require a new ADR). Opacity fade without color change — rejected (doesn't match the design spec's color range).

---

## D-06: Feature Layer Ownership

**Decision**: SCR-20 lives entirely within the existing `workout_session` feature directory. It creates `application/` and `presentation/` sub-layers that do not yet exist under that feature.

**Rationale**: `WorkoutSession` is the primary entity; `WorkoutSessionRepository` is the data source. Creating a new feature directory for "history" would be incorrect — history is a view of `WorkoutSession` data, not a new domain.

**Note for SCR-19 coordination**: SCR-19 also creates files under `workout_session/application/` and `workout_session/presentation/`. The two features must not conflict. The `application/bloc/` directory will contain both `WorkoutSummaryBloc` (SCR-19) and `WorkoutHistoryBloc` (SCR-20). Implementors must merge carefully if implementing both features in parallel.

---

## D-07: Sets Count Formula

**Decision**: The "sets" count in the summary line (`{N} sets`) is the count of **non-skipped** sets. The formula depends on `ActualSet.skipped` which is added by SCR-16.

```dart
// When SCR-16 is implemented (ActualSet.skipped exists):
int setsCount(WorkoutSession s) => s.sessionExercises.fold(
  0, (sum, e) => sum + e.actualSets.where((a) => !a.skipped).length);

// Fallback if SCR-16 is NOT yet complete (ActualSet.skipped absent):
int setsCount(WorkoutSession s) => s.sessionExercises.fold(
  0, (sum, e) => sum + e.actualSets.length);
```

**Rationale**: FR-003(d) specifies `{N} sets`. The spec Assumption says "non-skipped sets only (consistent with SCR-19's 'Sets Logged' definition)". If SCR-16 is not yet merged when SCR-20 is implemented, the implementor must use the fallback formula and document an issue to update it once SCR-16 lands.

**Prerequisite dependency**: SCR-16 must be fully implemented before SCR-20 can apply the non-skipped filter. If implementing SCR-20 before SCR-16, raise a blocker in the implementation notes.

---

## D-08: `startedAt` Dependency on SCR-16

**Decision**: The spec assumptions state that day number, day-of-week, and month grouping derive from the session **start date** (`startedAt`). `WorkoutSession.startedAt` is added by SCR-16. SCR-20 has a hard prerequisite on SCR-16.

**Rationale**: If `startedAt` is absent, the implementor must use `completedAt` as the display date and document a follow-up. Since most sessions complete within the same calendar day they start, `completedAt` is an acceptable fallback for v1, but the field name must be changed once SCR-16 lands.

**Prerequisite dependency**: SCR-16 must be implemented before SCR-20 for correct date display. The plan documents this as a prerequisite.

---

## D-09: State Count (Five Explicit States)

**Decision**: `WorkoutHistoryState` is a sealed class with five concrete states: `WorkoutHistoryInitial`, `WorkoutHistoryLoading`, `WorkoutHistorySuccess`, `WorkoutHistoryEmpty`, `WorkoutHistoryError`.

**Rationale**: FR-007 requires the error state and empty state to be "entirely distinct" — they cannot be conflated into a single "no-data" state. Having them as separate sealed variants makes this invariant statically enforced. `WorkoutHistoryInitial` prevents the screen from showing stale data before the first event fires.

**Alternatives considered**: Three states (Loading, Loaded/data, Loaded/empty | Error) — rejected because conflating empty and error into a single state risks the exact confusion FR-007 forbids.

---

## D-10: DI Registration

**Decision**: `GetWorkoutHistoryUseCase` → `registerLazySingleton`. `WorkoutHistoryBloc` → `registerFactory`. Both in `forge/lib/app/get_it_setup.dart`.

**Rationale**: Matches existing project patterns: use-cases are stateless and shared → lazy singleton; Blocs are stateful and route-scoped → factory (a new instance per route creation). `WorkoutSessionRepository` is already registered as a lazy singleton — the use-case injects it via `getIt<WorkoutSessionRepository>()`.
