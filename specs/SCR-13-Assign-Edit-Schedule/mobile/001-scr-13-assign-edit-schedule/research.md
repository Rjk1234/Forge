# Phase 0 Research: SCR-13 Assign / Edit Schedule

All items resolved by reading the existing codebase directly (`forge/lib/`) and this feature's own spec.md/Clarifications, rather than external research.

## Decision 1: Mode (New vs. Edit) is data-driven, not entry-point-driven

- **Decision**: Whether the screen behaves as "New Schedule" or "Edit Schedule" is determined by whether the given `planId` already has any assigned days (queried fresh at screen-init), not by which screen navigated here.
- **Rationale**: The design mockup's entry-point table treats Plan Detail's "Schedule" button as always "New" with blank chips, which would silently ignore a plan's true existing schedule if the user reaches it a second time. This feature's own spec.md already frames User Story 1 ("no existing schedule assignment") vs. User Story 2 ("already has a plan scheduled") in data terms, not navigation-source terms — so a data-driven mode check is both more correct and already what the spec requires.
- **Alternatives considered**: Pass an explicit `isEditMode` flag from the caller (mirrors `CreateEditWorkoutPlanBloc`'s `planId == null` check) — rejected because, unlike creating a brand-new plan (which truly has no prior identity), a plan here always has a real, stable `planId`; a caller-supplied mode flag could drift out of sync with actual Drift state, exactly the inconsistency this decision avoids.

## Decision 2: "Assignment" is a computed grouping, not a first-class record

- **Decision**: There is no single Drift record representing "Plan X on days {1,3,5}". The existing `schedule_entries` table (`ScheduleEntryRecord`) is keyed by weekday, one entry per day. An "assignment" for editing purposes is computed as: all weekdays whose entry's `planId` equals the plan being edited.
- **Rationale**: Matches the actual, already-implemented storage record (confirmed in `features/schedule/data/models/schedule_entry_record.dart`), rather than the design mockup's Assumption 3 ("stored as a single entry with three days"), which does not reflect the real persistence shape. SCR-12's plan.md made the analogous call for its own read side.
- **Alternatives considered**: Change the storage record to a multi-day record — rejected as an unrelated, out-of-scope schema change; the weekday-keyed model already satisfies every functional requirement in this and SCR-12's spec.

## Decision 3: Conflict detection is client-side against data loaded once at screen-init

- **Decision**: On screen init, one repository call (`loadAssignmentContext(planId)`) returns the plan's current days plus a map of every day occupied by a *different* plan (`occupiedDays`). Tapping a day chip re-evaluates conflicts purely in memory against that already-loaded map — no Drift round-trip per tap.
- **Rationale**: Satisfies QA PR-01 ("conflict check is immediate... without a round-trip to Drift") and FR-004/FR-005. This reuses the same "day → occupant" shape SCR-12's `getWeeklySchedule()` already computes, so `loadAssignmentContext` is implemented by calling the same underlying data sources SCR-12's repository uses, just excluding the plan being edited from its own occupancy.
- **Alternatives considered**: Re-query Drift on every chip tap — rejected as unnecessary I/O for data that cannot change mid-session (this is a single-user, single-device, offline app with no concurrent writers).

## Decision 4: No in-screen plan picker; the plan display is static

- **Decision**: The plan name is shown in a non-interactive display card. There is no tap-to-change-plan affordance on this screen, and the Invalid Plan banner's recovery path is "go back and pick a different plan from the Plans List," not an in-screen picker.
- **Rationale**: Directly follows this feature's own Clarification (2026-09-19) and Out of Scope section, which explicitly reject an in-screen picker in favor of reusing the existing Plans List → Plan Detail → "Schedule" button journey. This also avoids adding a `pickerContext`-style callback parameter to `WorkoutPlansScreen` (the only existing precedent for a "picker mode," used by the unrelated exercise-catalogue feature) purely for this one flow — no such plumbing is needed at all once the picker is out of scope.
- **Alternatives considered**: Mirror `ExerciseCatalogueScreen`'s `pickerContext` pattern on `WorkoutPlansScreen` — rejected per the Clarification; would be cross-feature UI surface added to `workout_plan` for a capability this spec explicitly excludes.

## Decision 5: Recurrence display has no New/Edit visual distinction

- **Decision**: The "Repeats weekly" row is always shown identically (no dimmed/locked opacity difference between New and Edit modes).
- **Rationale**: The design mockup's OQ-3 opacity distinction (0.5 in New, 1.0 in Edit) is a cosmetic nuance never promoted into a functional requirement in spec.md — FR-012 only requires that recurrence is always weekly and never user-configurable. Implementing an unspecified visual nuance would be scope creep beyond this feature's actual requirements.
- **Alternatives considered**: Implement the opacity distinction as designed — rejected as unnecessary given no FR or success criterion depends on it; can be added later as a pure design-polish change if requested.

## Decision 6: Back-navigation lock during save

- **Decision**: Implemented with Flutter's standard `PopScope(canPop: state is! AssignScheduleSaving, ...)` wrapping the screen — no custom navigation-interception mechanism.
- **Rationale**: `PopScope` is the current Flutter API for exactly this case (superseding `WillPopScope`, which the design doc mentions) and requires no new dependency. Satisfies FR-010 and design spec §6's platform notes for both the iOS edge-swipe and Android system-back cases uniformly.
- **Alternatives considered**: None needed — this is a standard, single well-known API for the exact requirement.

## Decision 7: Return-to-SCR-12 refresh is the caller's responsibility

- **Decision**: This screen calls `context.pop()` on successful save and otherwise on back navigation; it does not itself notify SCR-12 or any reload mechanism.
- **Rationale**: Consistent with the already-implemented pattern in `plan_detail_screen.dart` (`await context.push(...); if (mounted) _reload();`) used for its own Edit/Delete sub-routes. The caller that pushed to this screen (SCR-12's edit-icon handler, or Plan Detail's existing `_onSchedule`) is responsible for awaiting the pop and re-dispatching its own reload — this screen has no way to know what its caller needs to refresh, and doing so would couple it to callers outside this feature.
- **Alternatives considered**: Have this screen depend on and call a `ScheduleReloadNotifier` singleton directly — rejected; that pattern (mirroring `WorkoutPlansReloadNotifier`) solves *tab-switch-while-alive* staleness, a different problem than *pop-back-refresh*, and forcing this screen to know about it would be an unnecessary coupling for a concern the caller already has a proven, simpler solution for.

## Decision 8: Partial-write failure handling on multi-day save

- **Decision**: `saveAssignment` performs its deletes (days removed from the assignment) and puts (days in the new selection) sequentially against Drift; if any individual operation throws, the whole call reports a single `CacheException` failure per FR-008, with no rollback of already-completed steps.
- **Rationale**: Each Drift insert-or-replace/delete is atomic per row, but the overall multi-row operation is not wrapped in a single transaction. Given this is a single-user, single-device, offline POC with no concurrent writers, a mid-operation failure (e.g., disk full) is an already-accepted-scope edge case (constitution's local-data-governance principles do not require distributed-transaction guarantees), and the existing `WorkoutPlanRepositoryImpl` follows the same non-transactional pattern for its own multi-field saves.
- **Alternatives considered**: Build a manual "stage then commit" rollback layer — rejected as disproportionate engineering for a scale (≤7 keys) and environment (local-only) where the failure mode is already rare and already surfaced to the user via the standard save-failure/retry path.
