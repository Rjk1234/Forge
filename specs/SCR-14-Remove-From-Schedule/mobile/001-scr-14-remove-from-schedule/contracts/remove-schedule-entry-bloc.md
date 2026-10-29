# Contract: `RemoveScheduleEntryBloc`

**Layer**: Application (`features/schedule/application/bloc/`)

Mirrors `features/workout_plan/application/bloc/delete_plan_bloc.dart` exactly in shape (research.md Decision 1).

## Event

```dart
class RemoveScheduleEntryConfirmed extends Equatable {
  final int weekday; // 1–7
}
```

One event, dispatched both by the initial "Remove" tap and by every "Retry" tap — identical to `DeletePlanConfirmed`.

## States

```dart
sealed class RemoveScheduleEntryState extends Equatable {}

final class RemoveScheduleEntryConfirmation extends RemoveScheduleEntryState {}
final class RemoveScheduleEntryRemoving extends RemoveScheduleEntryState {}
final class RemoveScheduleEntrySuccess extends RemoveScheduleEntryState {}
final class RemoveScheduleEntryFailure extends RemoveScheduleEntryState {
  final String message;
}
```

Initial state: `RemoveScheduleEntryConfirmation()`.

## Transition table

| Current state | Event | Repository result | Next state |
|---|---|---|---|
| `Confirmation` | `RemoveScheduleEntryConfirmed(weekday)` | — | `Removing` |
| `Removing` | (internal) | `Right(_)` | `Success` |
| `Removing` | (internal) | `Left(failure)` | `Failure(failure.message)` |
| `Failure` | `RemoveScheduleEntryConfirmed(weekday)` | — | `Removing` (re-attempts — this is the "Retry" action) |

There is no explicit guard against a second `RemoveScheduleEntryConfirmed` arriving while already `Removing` in the Bloc itself — exactly matching `DeletePlanBloc`'s precedent, where this is instead prevented at the UI layer (the Remove/Retry button has no `onPressed` handler at all while `state is Removing`, per `_RightButton`'s `if (state is DeletePlanDeleting) return ...(onPressed: null)`).

## UI mapping (`RemoveScheduleEntryDialog` via `BlocConsumer`)

| State | Rendering |
|---|---|
| `Confirmation` | Full dialog: icon, title, sub-text (plan + day + history-unaffected note), Cancel (active) / Remove (active, lime) |
| `Removing` | Same content; `PopScope(canPop: false)`; Cancel dimmed with `onPressed: null`; right button shows spinner + "Removing…", `onPressed: null` |
| `Success` | Never rendered — the `listener` calls `Navigator.pop(context, true)` the instant this state is emitted |
| `Failure` | Same content plus `InlineDialogError(message: state.message)` between sub-text and actions; Cancel fully active; right button reads "Retry", dispatches the same `RemoveScheduleEntryConfirmed(weekday)` |

Dismissal via scrim tap or OS back gesture is handled by `showDialog`'s own `barrierDismissible` and `PopScope`, not by a Bloc event — available in every state except `Removing` (`PopScope(canPop: state is! RemoveScheduleEntryRemoving)`).

## Test contract (`remove_schedule_entry_bloc_test.dart`, `bloc_test`)

| Case | Seed | Act | Expect |
|---|---|---|---|
| Confirm success | `removeEntry` returns `Right(null)` | `add(RemoveScheduleEntryConfirmed(weekday: 2))` | `[Removing, Success]` |
| Confirm failure | `removeEntry` returns `Left(CacheException(...))` | `add(RemoveScheduleEntryConfirmed(weekday: 2))` | `[Removing, Failure(message)]` |
| Retry after failure succeeds | `removeEntry` returns `Left` then `Right` | `add(...)`, then `add(...)` again | `[Removing, Failure, Removing, Success]` |
| Retry after failure fails again | `removeEntry` always returns `Left` | `add(...)` twice | `[Removing, Failure, Removing, Failure]`, no crash |
