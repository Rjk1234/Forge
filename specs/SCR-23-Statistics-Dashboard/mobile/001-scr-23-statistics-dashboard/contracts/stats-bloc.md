# Contract: StatsBloc

**Feature**: SCR-23 Statistics Dashboard  
**Layer**: `features/stats/application/bloc/`

---

## Events

### `StatsLoadRequested`

Triggers a full statistics computation from Drift. Used for both initial load (dispatched in `StatsScreen.initState`) and retry (dispatched from `StatsErrorCard`'s Retry button).

```dart
// stats_event.dart
sealed class StatsEvent {}

final class StatsLoadRequested extends StatsEvent {}
```

No payload. There is no separate retry event — `StatsLoadRequested` handles both paths.

---

## States

```dart
// stats_state.dart
sealed class StatsState {}

final class StatsInitial extends StatsState {}

final class StatsLoading extends StatsState {}

final class StatsLoaded extends StatsState {
  final StatsData stats;
  final List<ExerciseStatRow> exercises;

  const StatsLoaded({required this.stats, required this.exercises});
}

final class StatsError extends StatsState {}
```

**UI derivation from `StatsLoaded`**:

| Condition | UI shown |
|-----------|---------|
| `stats.totalWorkoutsCompleted == 0` | Empty state (dimmed tiles + prompt) |
| `stats.totalWorkoutsCompleted > 0` | Main state (real tiles + breakdown + PB link) |

`StatsInitial` renders identically to `StatsLoading` (skeleton).

---

## Bloc

```dart
// stats_bloc.dart
class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final GetStatisticsUseCase _getStatistics;

  StatsBloc({required GetStatisticsUseCase getStatistics})
      : _getStatistics = getStatistics,
        super(StatsInitial()) {
    on<StatsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    StatsLoadRequested event,
    Emitter<StatsState> emit,
  ) async {
    emit(StatsLoading());
    try {
      final (stats, exercises) = await _getStatistics();
      emit(StatsLoaded(stats: stats, exercises: exercises));
    } catch (_) {
      emit(StatsError());
    }
  }
}
```

---

## Use Case

```dart
// get_statistics_use_case.dart
class GetStatisticsUseCase {
  final WorkoutSessionRepository _repository;

  GetStatisticsUseCase(this._repository);

  Future<(StatsData, List<ExerciseStatRow>)> call() async {
    final sessions = await _repository.getAllSessions();
    // 1. filter to valid sessions
    // 2. accumulate aggregates
    // 3. build exercise rows
    // 4. sort by sessionCount desc, alpha tie-break
    // returns (StatsData, List<ExerciseStatRow>)
  }
}
```

Valid session filter (FR-003):
- `session.completedAt != null`
- AND `session.sessionExercises` contains ≥1 exercise with ≥1 `ActualSet` where `skipped != true`

---

## DI Registration

Registration order in `get_it_setup.dart` (after `WorkoutSessionRepository` is registered):

```dart
getIt.registerLazySingleton<GetStatisticsUseCase>(
  () => GetStatisticsUseCase(getIt<WorkoutSessionRepository>()),
);

getIt.registerFactory<StatsBloc>(
  () => StatsBloc(getStatistics: getIt<GetStatisticsUseCase>()),
);
```

`StatsBloc` is `registerFactory` because the screen re-creates it on each visit to get fresh data on re-entry.

The `BlocProvider` in `app_routes.dart` Branch 5:

```dart
BlocProvider(
  create: (_) => getIt<StatsBloc>()..add(StatsLoadRequested()),
  child: const StatsScreen(),
)
```

---

## State Transition Diagram

```
StatsInitial
     │
     │ (screen mounted → BlocProvider fires StatsLoadRequested)
     ▼
StatsLoading  ◄─────────────────────────────────────────┐
     │                                                   │
     ├─ success ──► StatsLoaded                          │
     │               ├─ totalWorkoutsCompleted == 0      │
     │               │    → Empty UI                     │
     │               └─ totalWorkoutsCompleted > 0       │
     │                    → Main UI                      │
     │                                                   │
     └─ exception ──► StatsError                         │
                        └─ user taps Retry ──────────────┘
```

---

## Screen Contract (`StatsScreen`)

`StatsScreen` is a `StatefulWidget` that:
- Owns `bool _retrying = false` — set to `true` on Retry tap; reset by `BlocListener` when any non-Loading state arrives
- Does NOT own an `AnimationController` — `StatsSkeleton` owns its own controller (lifecycle-isolated)
- Dispatches no events itself; `BlocProvider.create` fires `StatsLoadRequested` on screen mount
- On re-entry (returning from a pushed route), the `BlocProvider` with `registerFactory` creates a new `StatsBloc` and fires `StatsLoadRequested` (on-entry recalculation — FR-019)
