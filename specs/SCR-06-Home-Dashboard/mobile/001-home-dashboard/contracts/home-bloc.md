# Contract: HomeBloc

**File**: `forge/lib/features/home/application/bloc/home_bloc.dart`

---

## Identity

```dart
class HomeBloc extends Bloc<HomeEvent, HomeState>
```

Registered in GetIt as a **factory** (not singleton) — new instance per route entry.

---

## Events

### HomeLoadRequested

```dart
class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
  @override List<Object?> get props => [];
}
```

**When dispatched**:
- `HomeScreen.didChangeDependencies()` — covers initial mount AND tab re-activation (FR-012)
- Retry button tap in `HomeError` state (FR-007)

**Idempotency rule**: If current state is already `HomeLoading`, the handler returns immediately without re-emitting.

---

## States

### HomeInitial

```dart
class HomeInitial extends HomeState {
  const HomeInitial();
  @override List<Object?> get props => [];
}
```

Starting state before any event is dispatched. Widget renders nothing (or an invisible placeholder).

---

### HomeLoading

```dart
class HomeLoading extends HomeState {
  const HomeLoading();
  @override List<Object?> get props => [];
}
```

Database read in progress. Widget shows `LoadingIndicator`. Bottom nav tabs visible but non-interactive (FR-008).

---

### HomeEmpty

```dart
class HomeEmpty extends HomeState {
  const HomeEmpty();
  @override List<Object?> get props => [];
}
```

All three tables are empty (`hasData == false`). Widget shows `EmptyStateView` with CTA. No quick links (FR-002).

---

### HomePopulated

```dart
class HomePopulated extends HomeState {
  final DashboardSnapshot snapshot;
  const HomePopulated(this.snapshot);
  @override List<Object?> get props => [snapshot];
}
```

At least one table has data (`hasData == true`). Two sub-cases expressed via `snapshot.todayWorkout`:

| `snapshot.todayWorkout` | Widget shown |
|---|---|
| `null` | `RestDayCard` + `QuickLinksGrid` |
| non-null | `TodayWorkoutCard` + `QuickLinksGrid` |

Both sub-cases are one state class — the widget switches on `snapshot.todayWorkout != null`.

---

### HomeError

```dart
class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override List<Object?> get props => [message];
}
```

Database read failed. Widget shows `ErrorCard` with `message` and retry button. Bottom nav fully interactive (FR-008).

---

## Event Handler Pseudocode

```
on<HomeLoadRequested> {
  if (state is HomeLoading) return;   // idempotent guard
  emit(HomeLoading());
  final result = await getDashboardSnapshot.call();
  result.fold(
    (failure) => emit(HomeError(failure.message)),
    (snapshot) => snapshot.hasData
        ? emit(HomePopulated(snapshot))
        : emit(HomeEmpty()),
  );
}
```

---

## Dependencies (injected via GetIt)

| Dependency | Type | Registration |
|---|---|---|
| `GetDashboardSnapshotUseCase` | `GetDashboardSnapshotUseCase` | factory |

---

## State Transition Table

| From state | Event | To state |
|---|---|---|
| `HomeInitial` | `HomeLoadRequested` | `HomeLoading` |
| `HomeLoading` | `HomeLoadRequested` | `HomeLoading` (no re-emit; guard) |
| `HomeLoading` | *(read succeeds, hasData=false)* | `HomeEmpty` |
| `HomeLoading` | *(read succeeds, hasData=true)* | `HomePopulated` |
| `HomeLoading` | *(read fails)* | `HomeError` |
| `HomeEmpty` | `HomeLoadRequested` | `HomeLoading` |
| `HomePopulated` | `HomeLoadRequested` | `HomeLoading` |
| `HomeError` | `HomeLoadRequested` | `HomeLoading` |

---

## Test Contract (bloc_test)

Every state transition in the table above MUST have a corresponding `blocTest` case. Key test scenarios:

| Test | Input | Expected states |
|---|---|---|
| Initial load success — empty | MockUseCase returns snapshot with hasData=false | [HomeLoading, HomeEmpty] |
| Initial load success — rest day | MockUseCase returns snapshot with hasData=true, todayWorkout=null | [HomeLoading, HomePopulated] |
| Initial load success — scheduled | MockUseCase returns snapshot with hasData=true, todayWorkout=non-null | [HomeLoading, HomePopulated] |
| Initial load failure | MockUseCase returns Left(Failure) | [HomeLoading, HomeError] |
| Retry after error | dispatch HomeLoadRequested twice; second returns success | [HomeLoading, HomeError, HomeLoading, HomePopulated] |
| Idempotent guard | dispatch HomeLoadRequested while loading | [HomeLoading] (only one) |
| Tab re-activation | dispatch HomeLoadRequested from HomePopulated | [HomeLoading, HomePopulated] |
