# Contract: `WeekScheduleBloc`

**Layer**: Application (`features/schedule/application/bloc/`)

## Events

```dart
sealed class WeekScheduleEvent extends Equatable {}

class WeekScheduleRequested extends WeekScheduleEvent {}
class WeekScheduleRetried extends WeekScheduleEvent {}
```

- `WeekScheduleRequested`: dispatched once from `WeeklyScheduleScreen.initState()` and every time the Schedule tab is resumed/re-entered (FR-008). Not dispatched on a timer.
- `WeekScheduleRetried`: dispatched by the error state's Retry button (I-9). Ignored (no-op) if the Bloc is already in `WeekScheduleLoading` (Edge Case EC-7 — debounce concurrent retries).

## States

```dart
sealed class WeekScheduleState extends Equatable {}

class WeekScheduleInitial extends WeekScheduleState {}
class WeekScheduleLoading extends WeekScheduleState {}
class WeekSchedulePopulated extends WeekScheduleState {
  final WeeklySchedule schedule;
}
class WeekScheduleEmpty extends WeekScheduleState {}
class WeekScheduleError extends WeekScheduleState {
  final String message; // user-safe, from AppException.message
}
```

## Transition table

| Current state | Event | Repository result | Next state |
|---|---|---|---|
| `Initial` | `WeekScheduleRequested` | — | `Loading` |
| `Loading` | (internal) | `Right(schedule)`, all days rest | `Empty` |
| `Loading` | (internal) | `Right(schedule)`, ≥1 day scheduled | `Populated(schedule)` |
| `Loading` | (internal) | `Left(failure)` | `Error(failure.message)` |
| `Error` | `WeekScheduleRetried` | — | `Loading` |
| `Loading` | `WeekScheduleRetried` | — | *(ignored — no state change, no duplicate repository call)* |
| `Populated`/`Empty` | `WeekScheduleRequested` (tab re-entered) | *(re-runs full flow above)* | `Loading` → next result |

## UI mapping (consumed by `WeeklyScheduleScreen` via `BlocBuilder`)

| State | Widget |
|---|---|
| `Initial`, `Loading` | `ScheduleSkeletonList` (§3.1 design spec — 7 shimmer rows) |
| `Empty` | `ScheduleEmptyState` (§3.2 — "No workouts scheduled" + CTA to SCR-13) |
| `Populated` | `WeekScheduleList` → 7× `DayRow`, today's row highlighted with `StartWorkoutButton` when `ScheduleDay.assignedPlan != null`, else rest label + edit icon (Edge Case: today unscheduled) |
| `Error` | `ScheduleErrorCard` (§3.4 — message + Retry → dispatches `WeekScheduleRetried`) |

## Test contract (`week_schedule_bloc_test.dart`, `bloc_test`)

| Case | Seed | Act | Expect |
|---|---|---|---|
| Populated path | `getWeeklySchedule` returns `Right` with 2 scheduled days | `add(WeekScheduleRequested())` | `[Loading, Populated(schedule)]` |
| Empty path | `getWeeklySchedule` returns `Right` with all rest days | `add(WeekScheduleRequested())` | `[Loading, Empty]` |
| Error path | `getWeeklySchedule` returns `Left(CacheException)` | `add(WeekScheduleRequested())` | `[Loading, Error(message)]` |
| Retry recovers | Error state seeded; second call returns `Right` | `add(WeekScheduleRetried())` | `[Loading, Populated(...)]` |
| Retry debounce | State is `Loading` | `add(WeekScheduleRetried())` | no new states emitted, repository called exactly once (from the original request) |
