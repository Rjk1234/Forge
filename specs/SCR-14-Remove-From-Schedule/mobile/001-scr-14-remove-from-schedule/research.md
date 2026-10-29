# Phase 0 Research: SCR-14 Remove From Schedule Confirmation

All items resolved by reading the existing codebase directly (`forge/lib/`), which already contains a near-identical, implemented precedent for this exact feature shape.

## Decision 1: Mirror `DeletePlanBloc`/`DeletePlanDialog` exactly

- **Decision**: Structure `RemoveScheduleEntryBloc` and `RemoveScheduleEntryDialog` to match `features/workout_plan/application/bloc/delete_plan_bloc.dart` and `features/workout_plan/presentation/widgets/delete_plan_dialog.dart` field-for-field: a single event that both confirms and retries (`RemoveScheduleEntryConfirmed`, mirroring `DeletePlanConfirmed`), four states (`Confirmation`/`Removing`/`Success`/`Failure`, mirroring `DeletePlanConfirmation`/`Deleting`/`Success`/`Failure`), a `BlocConsumer` whose `listener` pops `true` on `Success`, and a `PopScope(canPop: state is! Removing)` wrapper.
- **Rationale**: This exact pattern already exists, is already reviewed/working code, and satisfies every one of this feature's requirements (confirm → loading → success/failure → retry, dismissal locked only during the in-progress state) with no gaps. There is no reason to design a different shape when a proven one already exists one feature over.
- **Alternatives considered**: Design a bespoke state machine — rejected; would be an unjustified deviation from working, established project convention for the exact same interaction pattern.

## Decision 2: No go_router route — `showDialog` from the caller, like `DeletePlanDialog`

- **Decision**: This feature adds no route. The calling screen (SCR-12's weekly schedule view) opens the dialog with `showDialog<bool>(...)` and reacts to the returned boolean.
- **Rationale**: Confirmed no `/plans/:planId/delete` route exists for the structurally identical `DeletePlanDialog` either — `plan_detail_screen.dart`'s `_onDelete` calls `showDialog` directly and reloads if the result is `true`. A modal confirmation dialog is not a navigable destination in this codebase's established convention.
- **Alternatives considered**: A dedicated route/screen for the confirmation (as SCR-13 is) — rejected; SCR-14 is explicitly a modal overlay per its own design spec (§1: "not a pushed route"), and the codebase already has zero precedent for routing a same-screen confirmation dialog.

## Decision 3: Lime, not danger, for the confirm/retry button

- **Decision**: The confirm ("Remove") and retry ("Retry") buttons use `AppColors.lime`/`AppColors.onLime`, not `AppColors.danger`/`AppColors.onDanger` (which `DeletePlanDialog` uses for its "Delete"/"Retry").
- **Rationale**: This feature's own design spec explicitly calls this out as an intentional distinction from SCR-11: removing a schedule entry is low-stakes and trivially reversible (re-add via SCR-13), unlike deleting a plan outright. The spec's own Assumptions section states this is "Not a destructive irreversible action." Everything else about the dialog's visual shape still mirrors `DeletePlanDialog`.
- **Alternatives considered**: Copy `DeletePlanDialog`'s danger styling exactly for consistency — rejected; would misrepresent the action's actual severity to the user, contradicting the spec's explicit intent.

## Decision 4: `removeEntry` takes only a `weekday`, no plan-identity check

- **Decision**: `ScheduleRepository.removeEntry(int weekday)` unconditionally deletes whatever entry currently occupies that weekday — it does not verify which plan is there first.
- **Rationale**: Per the spec's Assumption ("Entry context: the modal receives context from SCR-12 at the moment the remove action is triggered... single-user, offline: no concurrent modification is possible"), the weekday the user tapped is trusted as still correct at confirm time. Re-verifying plan identity before delete would be unreachable dead code in a single-user, single-device, offline app with no concurrent writer.
- **Alternatives considered**: `removeEntry(weekday, expectedPlanId)` with a mismatch failure — rejected as unnecessary defensive coding for a concurrency scenario that cannot occur in this app (Principle context: single local user, no backend, no multi-device sync).

## Decision 5: Dialog receives plan name and day name as plain parameters, not via a repository read

- **Decision**: `RemoveScheduleEntryDialog(weekday: ..., planName: ..., dayName: ...)` — both display strings are passed in by the caller (SCR-12), which already has them from its own row data. The dialog/Bloc never reads Drift to determine what's being removed.
- **Rationale**: Matches `DeletePlanDialog(planId, planName)`'s exact precedent, and the spec's own Assumption 2 ("It does not re-read Drift on open"). Avoids an unnecessary repository round-trip purely to redisplay data the caller already has in memory.
- **Alternatives considered**: Have the Bloc load the entry by weekday to derive its own display strings — rejected as redundant I/O and a needless coupling to `ScheduleLocalDataSource.getEntryByWeekday` for data the caller already holds.
