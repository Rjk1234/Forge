# Phase 1 Data Model: SCR-14 Remove From Schedule Confirmation

No new table or column, and no new Domain entity. This feature deletes one existing `ScheduleEntryRecord` record via the existing `ScheduleLocalDataSource.deleteEntry(weekday)` method — the record shape is unchanged and already documented in SCR-12's data-model.md.

## Application-layer (Bloc) state shape — not persisted

`RemoveScheduleEntryState` (`application/bloc/remove_schedule_entry_state.dart`), mirroring `DeletePlanState`'s shape exactly:

| State | Fields | Description |
|---|---|---|
| `RemoveScheduleEntryConfirmation` | — | Initial state; dialog shows Cancel/Remove, fully interactive |
| `RemoveScheduleEntryRemoving` | — | Dismissal blocked; Cancel dimmed/disabled; Remove/Retry shows spinner + "Removing…" |
| `RemoveScheduleEntrySuccess` | — | Terminal; the dialog's `BlocConsumer` listener pops `true` the instant this is reached — never rendered |
| `RemoveScheduleEntryFailure` | `message: String` | Cancel re-enabled; inline error shown (reusing `core/widgets/inline_dialog_error.dart`); right button reads "Retry" |

The dialog widget itself is constructed with two plain, caller-supplied display parameters (not part of Bloc state, per research.md Decision 5):

| Parameter | Type | Source |
|---|---|---|
| `weekday` | `int` (1–7) | The row the user tapped Remove on |
| `planName` | `String` | The plan currently shown on that row |
| `dayName` | `String` | The day label already rendered on that row (e.g., "Monday") |

## State transitions (Bloc, not persisted)

```
RemoveScheduleEntryConfirmation
   │  RemoveScheduleEntryConfirmed(weekday)   [Remove tapped]
   ▼
RemoveScheduleEntryRemoving
   │  removeEntry(weekday) resolves
   ├─ Left(failure)  → RemoveScheduleEntryFailure(failure.message)
   └─ Right(_)        → RemoveScheduleEntrySuccess

RemoveScheduleEntryFailure
   │  RemoveScheduleEntryConfirmed(weekday)   [Retry tapped — same event as initial confirm]
   ▼
RemoveScheduleEntryRemoving  (re-attempts)
```

There is no `RetryRequested` event distinct from the initial confirm — exactly one event drives both the first attempt and every retry, matching `DeletePlanBloc`'s precedent. Dismissal (Cancel, scrim tap, back gesture) never dispatches a Bloc event at all; it is a pure `Navigator.pop(context, false)` outside the Bloc, available in every state except `Removing`.
