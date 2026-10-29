# Research: SCR-08 Workout Plans List

**Branch**: `001-workout-plans-list` | **Date**: 2026-09-17 | **Phase**: 0 — Pre-Design Research

---

## Decision 1 — Exercise Count Source: `planExercises.length`

**Decision**: Derive the exercise count for each plan card from `WorkoutPlanRecord.planExercises.length` — not from an `exerciseIds` list.

**Rationale**: Inspection of the existing `WorkoutPlanRecord` (`forge/lib/features/workout_plan/data/models/workout_plan_record.dart`) shows that exercises within a plan are stored as `List<PlanExerciseRecord> planExercises`, not as a list of string exercise IDs. The spec's `Key Entities` section refers to an `exerciseIds` list based on the design spec's assumption (OQ-9), but the actual storage record uses the richer `planExercises` embedded list. The count is `planExercises.length` and the mapper derives this into `WorkoutPlan.exerciseCount: int`.

**Alternatives considered**:
- _Pre-computed counter field_: The design spec OQ-9 asked whether to store a counter; the existing model stores the full exercise list, so the counter is derived at read time — no extra field needed.
- _Reading only a subset of the plan_: the `WorkoutPlanRecord` is assembled whole (plan row plus its ordered exercise rows), so count derivation is free.

---

## Decision 2 — Sort Order: In-Memory Newest-First by `createdAt`

**Decision**: After reading all plans from the table with `getAllPlans()`, sort the resulting list in memory by `WorkoutPlanRecord.createdAt` descending (newest plan first) before mapping to domain entities.

**Rationale**: The `WorkoutPlanRecord` already carries a `createdAt: DateTime` field . The plan list at POC scale (tens of plans) is small enough that in-memory sorting is instant (<1 ms) and trivially testable. The sort is applied in `WorkoutPlanRepositoryImpl.getAllPlans()` before mapping to domain entities — the domain entity receives the already-sorted list, and the Bloc does not need to know about the sort order.

**Alternatives considered**:
- _Sort in Bloc after repository returns_: shifts sort responsibility to the application layer, violating the principle that data shaping belongs in the data layer.
- _Sort in mapper_: mapper is stateless and should transform one item at a time; list ordering is a collection concern, not a per-item concern.
- _SQL `ORDER BY` in the data source_: workable, but the sort stays in the repository where it is unit-testable without a database.

---

## Decision 3 — Tab Re-Activation Signal: `AppShell` Branch Stream

**Decision**: Extend `AppShell` with a broadcast `StreamController<int>` (`_branchIndexController`) that emits the newly selected branch index whenever the `StatefulNavigationShell` switches branches. Register a `WorkoutPlansReloadNotifier` singleton in GetIt that `AppShell` pushes to. `WorkoutPlansScreen` subscribes in `initState` and dispatches `WorkoutPlansLoadRequested` when its branch index (1) is emitted.

**Rationale**: `StatefulShellRoute.indexedStack` preserves widget state across tab switches — `initState` fires only once per widget lifetime. A pub-sub notifier is the cleanest way to signal "Plans tab is now active" without breaking Clean Architecture layer boundaries. The notifier is a thin core infrastructure object (`forge/lib/core/navigation/workout_plans_reload_notifier.dart`), not a Bloc or repository. `WorkoutPlansScreen` subscribes to it and dispatches a Bloc event; the Bloc handles the optimistic re-read logic. The Bloc is the source of truth for state; the notifier is just a trigger.

**Alternatives considered**:
- _`didChangeDependencies` override_: does not detect tab re-activation when the route stays constant.
- _`WidgetsBindingObserver.didChangeAppLifecycleState`_: fires for app foreground/background, not tab switches.
- _Recreating the Bloc via `registerFactory` and re-running the GoRoute builder_: `StatefulShellRoute.indexedStack` reuses the widget tree; the builder is not called again on tab re-selection.
- _Sharing state via a singleton Bloc_: violates single-responsibility; plans state is owned by `WorkoutPlansBloc`.

---

## Decision 4 — Optimistic Re-Read Bloc Pattern

**Decision**: `WorkoutPlansBloc` distinguishes between an initial load and a re-read:
- **Initial load** (state is `WorkoutPlansInitial` or `WorkoutPlansError`): emit `WorkoutPlansLoading` first, then emit the result state.
- **Re-read** (state is already `WorkoutPlansPopulated` or `WorkoutPlansEmpty`): do **not** emit `WorkoutPlansLoading`; perform the database read and emit the updated result state directly (silent swap). This is the "optimistic re-read" that keeps the existing list visible per FR-015.

**Rationale**: The spec (FR-015, clarification Q2) requires that on tab return the existing list stays visible. By not emitting Loading during a re-read, the screen's `BlocBuilder` naturally keeps rendering the previous populated state while the read is in flight (Dart's event loop means the read completes before the next frame in most cases). This is simpler than a `WorkoutPlansReloading` state and keeps the state machine small.

**Alternatives considered**:
- _Separate `WorkoutPlansReloading` state_: adds a state that the UI must handle explicitly; unnecessary given that the behaviour is "don't change the UI during the re-read".
- _Optimistic state with embedded `previousPlans` field on `WorkoutPlansLoading`_: pollutes the loading state model; the simpler "skip Loading on re-read" achieves the same outcome.

---

## Decision 5 — Reuse Shared `ErrorCard` Widget

**Decision**: Reuse `forge/lib/features/home/presentation/widgets/error_card.dart` for the error state, identical to SCR-07's pattern. No new error widget is created for SCR-08.

**Rationale**: The `ErrorCard` widget already accepts `message: String` and `onRetry: VoidCallback`. The SCR-08 error card requires the same structure as the home feature's error card. Creating a duplicate would violate CLAUDE.md rule 21 ("Do not duplicate existing functionality").

**Alternatives considered**:
- _New `PlansErrorCard`_: unnecessary; `ErrorCard` is already parameterised for any message + retry callback.

---

## Decision 6 — `WorkoutPlan` Domain Entity: Projection, Not Full Model

**Decision**: The `WorkoutPlan` domain entity for SCR-08 carries only the fields needed to render the plans list: `id: String`, `name: String`, `exerciseCount: int`, `createdAt: DateTime`. It does NOT expose the full `planExercises` list — that level of detail belongs to SCR-10 (Plan Detail).

**Rationale**: Domain entities should model what their owning use case needs. `GetWorkoutPlansUseCase` serves the list screen; the list screen needs id (to navigate to SCR-10), name, count, and creation time (for sort). Exposing the full exercise list couples the list screen to SCR-10's data shape prematurely.

**Alternatives considered**:
- _Full `WorkoutPlan` entity with complete exercise list_: violates YAGNI at this stage; SCR-10 may define its own richer domain model when specified.
- _Using `WorkoutPlanRecord` directly in the Bloc_: violates Clean Architecture; storage records must not cross the data layer boundary.
