# Phase 0 Research: SCR-12 View Weekly Workout Schedule

All items below were resolved by reading the existing codebase directly (`forge/lib/`) rather than external research, since this is an internal feature extension of an already-architected app. No `NEEDS CLARIFICATION` markers remained in the Technical Context after this pass.

## Decision 1: Where does the weekly-schedule read logic live?

- **Decision**: A new `ScheduleRepository`/`ScheduleRepositoryImpl` in the existing `features/schedule/` module, composing the already-registered `ScheduleLocalDataSource` and `WorkoutPlanLocalDataSource`.
- **Rationale**: `features/home/data/datasources/home_local_data_source.dart` (`HomeDashboardLocalDataSourceImpl`) already composes these exact two datasources (plus a session datasource) to resolve "today's plan" for the Home dashboard. SCR-12 needs the same weekday→plan resolution for all 7 days, not just today. Reusing the datasource composition pattern — but as a dedicated `schedule`-owned repository rather than reaching into `home` — satisfies Principle I.5 (one owning feature per capability; `schedule` owns weekly-schedule read, `home` owns the dashboard snapshot).
- **Alternatives considered**:
  - *Import `HomeRepository` from the `schedule` feature*: Rejected — `home` owns the dashboard-snapshot capability, not the weekly-schedule-view capability; importing it would be a cross-feature domain dependency and would couple SCR-12's data shape to Home's dashboard model (which only carries "today", not all 7 days).
  - *Have the Bloc call both datasources directly*: Rejected — Blocs must not call Drift/repositories directly under Principle II; a repository/use-case layer is required regardless.

## Decision 2: How is an orphaned plan reference (FR-009) detected and cleaned up?

- **Decision**: `ScheduleRepositoryImpl.getWeeklySchedule()` iterates `ScheduleLocalDataSource.getAllEntries()`; for each entry, if `WorkoutPlanLocalDataSource.getPlanById(entry.planId)` returns null, the day is treated as unscheduled in the returned `WeeklySchedule`, and the orphaned entry is removed via `ScheduleLocalDataSource.deleteEntry(entry.weekday)` as a side effect of the read.
- **Rationale**: This matches the spec's edge case ("orphaned schedule entry is silently discarded so it does not reappear on the next load") and QA's OQ-01 recommendation. The Home feature's equivalent code (`home_local_data_source.dart` line ~37-39) currently just silently drops the day when `plan == null`, *without* deleting the entry — SCR-12 goes one step further by cleaning up the stale entry to prevent it from being re-encountered by other consumers (e.g., SCR-13). This delete is a narrow, explicitly-specified exception to the "read-only screen" framing: the *screen* never triggers a write from user interaction, but the *repository* performs a one-time consistency cleanup as an implementation detail of resolving stale data — a pattern already implicitly expected by FR-009's "silently discarded" wording.
- **Alternatives considered**:
  - *Never delete, just skip on every read*: Rejected — leaves a growing set of dead entries in the `schedule_entries` table indefinitely, silently increasing read cost and risking future bugs if another feature reads raw entries without the same null-check.
  - *Delete lazily from a background job*: Rejected — no job/scheduler mechanism exists or is justified for this POC's scale (7 rows max).

## Decision 3: Live "today" updates vs. re-evaluate-on-open

- **Decision**: `WeekScheduleBloc` computes `DateTime.now().weekday` only inside its `_onRequested` handler (triggered by `WeekScheduleRequested`, dispatched from the screen's `initState`), not via a `Timer`/`Stream.periodic`.
- **Rationale**: Resolved by clarification (2026-09-19): "today" re-evaluates only on screen open/resume, no live clock listener. This also avoids Principle "no timers created in `build()`" concerns entirely, since no timer is created at all.
- **Alternatives considered**: A `Timer.periodic` or clock-stream listener to flip the highlighted row at midnight while the screen stays open — rejected per the clarification decision (added complexity for a rare foreground-across-midnight case with no product requirement).

## Decision 4: Reusable UI components vs. new feature-local widgets

- **Decision**: Reuse `core/widgets/shimmer_box.dart` (`ShimmerBox`) for skeleton rows. Create new feature-local widgets `schedule_empty_state.dart` and `schedule_error_card.dart` under `features/schedule/presentation/widgets/`, shaped after `workout_plan`'s `PlansEmptyState`/`PlanNotAvailableCard` and `home`'s `ErrorCard` respectively.
- **Rationale**: No existing shared (`core/widgets`) empty-state or error-card widget exists — every prior screen (`home`, `workout_plan`) implements its own feature-local empty/error widget with screen-specific copy, icon, and CTA, using shared *tokens* (`AppColors`, `textTheme`) but not a shared *widget*. Following that established precedent avoids inventing a premature shared abstraction (Rule 6) while still eliminating duplication of layout primitives (`ShimmerBox`).
- **Alternatives considered**: Promote `home/ErrorCard` to `core/widgets` and reuse directly — rejected as an unrelated refactor of another feature's widget, out of scope for this feature (Rule 4: no unrelated changes).

## Decision 5: Navigation targets for Start / Edit actions

- **Decision**: The Start action (today's row) and Edit action (every other row) call `context.go`/`context.push` against route constants for SCR-15 (Workout Pre-Start) and SCR-13 (Assign/Edit Schedule) respectively. Neither route exists yet in `RoutePaths` (confirmed: `app_routes.dart` has no `planPreStart`/`scheduleAssign` style constants). These two navigation calls are implemented behind a single injectable callback pair (or a small `ScheduleNavigator` contract) so that once SCR-13/SCR-15 are implemented, this screen only needs its route-constant references updated, not its widget tree.
- **Rationale**: Per Principle III, routes are centralized in `app_routes.dart`; this feature must not invent a second routing mechanism or hardcode raw path strings inline. Since SCR-13 and SCR-15 are separate, not-yet-implemented features, this plan documents the dependency rather than fabricating route paths that don't yet exist.
- **Alternatives considered**: Block SCR-12 entirely until SCR-13/SCR-15 ship — rejected; the spec explicitly scopes SCR-12 as independently testable (User Story 1–4 in spec.md), and QA's SN-01–SN-04 test cases already expect SCR-12 to exist standalone with these as forward-navigation stubs.
