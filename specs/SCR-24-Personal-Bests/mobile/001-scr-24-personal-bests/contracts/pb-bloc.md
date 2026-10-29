# Contract: PbBloc

**Feature**: SCR-24 Personal Bests  
**Layer**: `features/personal_bests/application/bloc/`

---

## Events

### `PbLoadRequested`

Triggers a full PB computation from Drift. Used for both initial load (fired by `BlocProvider.create`) and Retry (dispatched from `PersonalBestsScreen._onRetry`).

```dart
// pb_event.dart
sealed class PbEvent {}

final class PbLoadRequested extends PbEvent {}
```

No payload. A single event covers both initial entry and Retry — no separate event needed.

---

## States

```dart
// pb_state.dart
sealed class PbState {}

final class PbInitial extends PbState {}

final class PbLoading extends PbState {}

final class PbLoaded extends PbState {
  final List<PersonalBestRecord> records;

  const PbLoaded({required this.records});
}

final class PbError extends PbState {}
```

**UI derivation from `PbLoaded`**:

| Condition | UI shown |
|-----------|---------|
| `records.isEmpty` | Empty state (`PbEmptyState`) |
| `records.isNotEmpty` | Main state (scrollable `PbCard` list) |

`PbInitial` renders identically to `PbLoading` (skeleton) — no blank screen on first entry (FR-015).

---

## Bloc

```dart
// pb_bloc.dart
class PbBloc extends Bloc<PbEvent, PbState> {
  final GetPersonalBestsUseCase _getPersonalBests;

  PbBloc({required GetPersonalBestsUseCase getPersonalBests})
      : _getPersonalBests = getPersonalBests,
        super(PbInitial()) {
    on<PbLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    PbLoadRequested event,
    Emitter<PbState> emit,
  ) async {
    emit(PbLoading());
    try {
      final records = await _getPersonalBests();
      emit(PbLoaded(records: records));
    } catch (_) {
      emit(PbError());
    }
  }
}
```

---

## Use Case

```dart
// get_personal_bests_use_case.dart
class GetPersonalBestsUseCase {
  final WorkoutSessionRepository _repository;

  GetPersonalBestsUseCase(this._repository);

  Future<List<PersonalBestRecord>> call() async {
    final result = await _repository.getAllSessions();
    return result.fold(
      (exception) => throw exception,
      (sessions) => _compute(sessions),
    );
  }

  List<PersonalBestRecord> _compute(List<WorkoutSession> sessions) {
    // 1. Filter valid sessions (completedAt != null)
    // 2. For each valid session → each sessionExercise → each non-skipped actualSet
    // 3. Accumulate per (exerciseName, type) → track max value + date (tie: more recent)
    // 4. Convert accumulators → List<PersonalBestRecord>
    // 5. Sort alphabetically ascending by exerciseName
    // 6. Return sorted list
  }
}
```

**Valid set guard**: `actualSet.skipped != true` — null `skipped` evaluates as non-skipped (pre-SCR-16 compatibility, consistent with SCR-21/22/23).

**Tie-break**: If two sets tie on the best value, the `bestDate` of the **more recent** session is kept.

---

## DI Registration

Registration order in `get_it_setup.dart` (after `WorkoutSessionRepository` is registered):

```dart
getIt.registerLazySingleton<GetPersonalBestsUseCase>(
  () => GetPersonalBestsUseCase(getIt<WorkoutSessionRepository>()),
);

getIt.registerFactory<PbBloc>(
  () => PbBloc(getPersonalBests: getIt<GetPersonalBestsUseCase>()),
);
```

`PbBloc` uses `registerFactory` so each route push creates a fresh Bloc instance, giving on-entry recalculation (FR-016) without manual state reset.

The `BlocProvider` in `app_routes.dart`:

```dart
GoRoute(
  path: RoutePaths.personalBests,   // 'personal-bests' (child of '/stats')
  builder: (context, state) => BlocProvider(
    create: (_) => getIt<PbBloc>()..add(PbLoadRequested()),
    child: const PersonalBestsScreen(),
  ),
),
```

---

## State Transition Diagram

```
PbInitial
     │
     │ (BlocProvider.create fires PbLoadRequested)
     ▼
PbLoading  ◄─────────────────────────────────────────┐
     │                                                │
     ├─ success ──► PbLoaded                          │
     │               ├─ records.isEmpty               │
     │               │    → PbEmptyState              │
     │               └─ records.isNotEmpty            │
     │                    → PbCard list               │
     │                                                │
     └─ exception ──► PbError                         │
                        └─ user taps Retry ───────────┘
                           (debounced via _retrying)
```

---

## Screen Contract (`PersonalBestsScreen`)

`PersonalBestsScreen` is a `StatefulWidget` that:
- Owns `bool _retrying = false` — prevents concurrent Retry dispatches
- Owns no `AnimationController` — `PbSkeleton` owns its own controller
- Uses `BlocListener` to reset `_retrying` when a non-Loading state arrives:
  ```dart
  listenWhen: (_, current) => current is! PbLoading,
  listener: (context, state) => setState(() => _retrying = false),
  ```
- Does NOT dispatch events itself; `BlocProvider.create` fires `PbLoadRequested` on mount
- On re-entry (new push): `registerFactory` creates a new `PbBloc` + fires `PbLoadRequested` automatically

**Retry dispatch**:
```dart
void _onRetry(BuildContext context) {
  if (_retrying) return;
  setState(() => _retrying = true);
  context.read<PbBloc>().add(PbLoadRequested());
}
```

**AppBar**: Present in all four states. Title: `AppStrings.pbScreenTitle` at `18px/weight-800`. Back arrow: `22×22 / white / stroke-width:2 / M15 18l-6-6 6-6`. `NoBottomNavBar` scaffold (or equivalent — no `BottomNavigationBar` in the scaffold).
