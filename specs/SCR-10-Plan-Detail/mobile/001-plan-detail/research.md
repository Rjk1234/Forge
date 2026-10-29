# Research: Plan Detail (SCR-10)

**Feature**: SCR-10-Plan-Detail  
**Date**: 2026-09-19  
**Branch**: 001-plan-detail

No external research was needed. All decisions are resolved from inspecting the existing codebase.

---

## Decision 1: State management pattern

**Decision**: `PlanDetailBloc` with sealed state classes, mirroring `CreateEditWorkoutPlanBloc`.

**Rationale**: Bloc is the mandated state-management framework. The existing bloc follows: one `sealed class` for states, one `sealed class` for events, `Bloc<Event, State>` subclass, use-case injection via constructor. No deviation.

**Alternatives considered**: None — Cubit is constitutionally prohibited.

---

## Decision 2: Bloc states

**Decision**: Four sealed states:
- `PlanDetailInitial` — before first event
- `PlanDetailLoading` — database read in flight
- `PlanDetailLoaded(WorkoutPlanDetail plan)` — successful read
- `PlanDetailNotFound(String message)` — plan missing or read exception

**Rationale**: Covers all screen states from the design spec (§3.1, §3.2, §3.3). Both "planId missing" and "read exception" map to the same `PlanDetailNotFound` state, consistent with the spec's requirement that both causes show identical UI.

**Alternatives considered**: Separate `PlanDetailError` and `PlanDetailMissing` states — rejected because the spec explicitly requires identical UI for both causes and the recovery action is the same.

---

## Decision 3: Refresh-on-return strategy

**Decision**: Use `await context.push('/plans/$planId/edit')` from the Edit handler and `await context.push(...)` from the Delete handler. After each `await` resolves (when the child screen pops), dispatch `PlanDetailLoadRequested(planId)` to re-read from the database.

**Rationale**: This is the idiomatic go_router pattern for reacting to child screen completion. It keeps the Bloc as the sole source of truth and avoids `RouteAware`, `WidgetsBindingObserver`, or platform channel hooks.

**Alternatives considered**:
- `RouteAware` / `didPopNext` lifecycle hook — more complex, less testable, tightly coupled to navigator state
- Global reload notifier — appropriate for cross-branch invalidation (like the existing `WorkoutPlansReloadNotifier`), not needed for a single-screen refresh

---

## Decision 4: Shimmer animation

**Decision**: Extract `_ShimmerBox` from `plans_skeleton_list.dart` into a public `ShimmerBox` widget at `forge/lib/core/widgets/shimmer_box.dart`. Both `PlansSkeletonList` and the new `PlanDetailSkeleton` then use `ShimmerBox`.

**Rationale**: `_ShimmerBox` is currently a private class but represents a reusable UI concept (CLAUDE.md rule: private widgets for reusable concepts must be made public). The detail screen needs the identical shimmer behaviour (AnimationController-driven `AnimatedBuilder`, `AppColors.cardAlt` ↔ `#35342F` lerp). Duplication would violate DRY and CLAUDE.md rule 21 ("Extract repeated UI into reusable widgets").

**Alternatives considered**: Duplicate shimmer logic in `PlanDetailSkeleton` — rejected because it duplicates both the gradient math and the `Animation<double>` contract, making future shimmer changes require edits in two places.

---

## Decision 5: Read-only exercise card

**Decision**: New public widget `PlanExerciseDetailCard` in `forge/lib/features/workout_plan/presentation/widgets/plan_exercise_detail_card.dart`. Takes a `PlanExercise` (domain entity) and renders Sets/Reps-or-Duration/Weight/Rest as display-only text cells with a type dot and exercise name.

**Rationale**: The existing `ExerciseCard` is a `StatefulWidget` that owns four `TextEditingController`s and dispatches Bloc events. It is fundamentally a form widget. Wrapping it in a `readOnly` mode would add complexity (disabled controllers, suppressed callbacks) for no benefit. A dedicated read-only widget is simpler, independently testable, and follows the single-responsibility principle.

**Alternatives considered**: Adding a `readOnly: bool` flag to `ExerciseCard` — rejected because it would require conditional controller management and optional callbacks throughout a complex stateful widget; the two use cases (edit form vs. read-only display) differ enough to warrant separate widgets.

---

## Decision 6: Bodyweight badge colour correction

**Decision**: Update `ExerciseCard`'s `_TypeBadge` in `exercise_card.dart`: change `ExerciseType.bodyweight` badge colour from `AppColors.amber` → `AppColors.textMuted`.

**Rationale**: The design spec for SCR-10 (§3.2, §8 Token usage) defines the 3-colour coding as cyan (Weighted), lime (Time-based), muted (Bodyweight). OQ-8 in the design spec explicitly notes this colour set should also apply to SCR-09. `AppColors.amber` is reserved for "open-decision banners ONLY" per its code comment. Using it for exercise type badges was an error in SCR-09's initial implementation.

**Alternatives considered**: Leaving SCR-09's amber badge as-is and using a different colour in SCR-10 — rejected because having two different type indicator colours for the same exercise type across two screens would be visually inconsistent.

---

## Decision 7: `PlanDetailBloc` GetIt registration

**Decision**: Register as `getIt.registerFactory<PlanDetailBloc>(...)` — not a singleton.

**Rationale**: Consistent with `CreateEditWorkoutPlanBloc` registration pattern. A fresh Bloc instance per screen opening avoids stale state from a previous plan detail view.

---

## Decision 8: Navigation to future screens (SCR-11, SCR-13, SCR-15)

**Decision**: SCR-11 (Delete), SCR-13 (Schedule), and SCR-15 (Start Workout) routes do not exist yet. For SCR-10, use `context.push()` to the anticipated route paths:
- Delete: `/plans/:planId/delete` (SCR-11)
- Schedule: `/plans/:planId/schedule` (SCR-13)  
- Start Workout: `/plans/:planId/start` (SCR-15)

These will 404 in go_router until those screens are implemented. The Plan Detail screen must compile and be testable in isolation; the navigation targets are stubs at this stage.

**Rationale**: Hardcode anticipated routes rather than disabling/hiding buttons, so the route contracts are established for downstream screens to fulfil. This follows the pattern used for the existing `PlaceholderTabScreen` routes.
