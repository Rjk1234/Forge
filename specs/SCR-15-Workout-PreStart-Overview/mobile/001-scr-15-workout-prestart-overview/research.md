# Research: SCR-15 Workout Pre-Start / Overview

**Phase 0 decisions — resolved before design**

---

## D-01: Feature ownership — `workout_plan` vs. new feature

**Decision**: Own SCR-15 inside the existing `workout_plan` feature.

**Rationale**: The screen reads `WorkoutPlanDetail` via `GetWorkoutPlanByIdUseCase`, a use case already registered and owned by `workout_plan`. The route is a child of `/plans/:planId`. Splitting into a new feature would require cross-feature data access, which the architecture disallows.

**Alternatives considered**:
- `workout_session` feature — rejected: session feature does not exist yet and should not own plan-reading logic.
- Shared `overview` feature — rejected: artificial split that violates "one owning feature per capability."

---

## D-02: Route structure

**Decision**: Add `start` as a named subroute under the existing `:planId` `ShellRoute` in `app_routes.dart`, producing the full path `/plans/:planId/start`. The constant `RoutePaths.workoutPreStart` is changed from the current (unused) `/plans/pre-start` to `/plans/:planId/start`.

**Rationale**: `plan_detail_screen.dart` already navigates with `context.push('/plans/${widget.planId}/start')`. The route constant just needs to be updated to match — zero change to call sites. Nesting under `:planId` gives the route builder access to the same `planId` parameter already resolved by the parent shell.

**Alternatives considered**:
- Keep `/plans/pre-start?planId=…` (query param) — rejected: `plan_detail_screen.dart` already hard-codes the path-param style; switching would require changing an already-tested screen.
- Top-level `/workout/pre-start` — rejected: breaks the plan-scoped URL hierarchy and requires a new top-level route.

---

## D-03: Data source for the plan — existing use case vs. new repository method

**Decision**: Use `GetWorkoutPlanByIdUseCase` unchanged. No new use case, repository method, or data-source method is needed.

**Rationale**: `GetWorkoutPlanByIdUseCase.call(String planId)` returns `Future<Either<AppException, WorkoutPlanDetail>>`. `WorkoutPlanDetail` carries `name`, `exercises: List<PlanExercise>`, and `createdAt` — all fields SCR-15 needs. The use case already wraps raw Drift exceptions into typed `AppException` failures.

**Alternatives considered**:
- New `GetPlanPreviewUseCase` — rejected: would duplicate `GetWorkoutPlanByIdUseCase` with no meaningful distinction.
- Direct `WorkoutPlanLocalDataSource` call from Bloc — rejected: violates Clean Architecture (application layer must not import `data/`).

---

## D-04: New Bloc vs. reusing `PlanDetailBloc`

**Decision**: Create a new `PreStartBloc`. Do not reuse or inherit from `PlanDetailBloc`.

**Rationale**: `PlanDetailBloc` carries additional state (edit/delete in-progress, plan-not-found from deletion) and events that SCR-15 must not expose. SCR-15 has a distinct "unavailable" state that covers both `null` (plan deleted) and `empty exercises` — different from `PlanDetailNotFound`. A separate Bloc keeps both screens independently testable and avoids coupling through shared event types.

**Alternatives considered**:
- Reuse `PlanDetailBloc` — rejected: state machine has different semantics; SCR-15 would need to filter/ignore irrelevant states in `BlocBuilder`, which is error-prone.
- Shared base class `AbstractPlanBloc` — rejected: premature abstraction; only two screens share the load pattern, and their states differ.

---

## D-05: Shimmer animation ownership — `StatefulWidget` vs. external package

**Decision**: `WorkoutPreStartScreen` is a `StatefulWidget` that owns an `AnimationController` for the shimmer. No new package (e.g., `shimmer`) is added.

**Rationale**: The project has no shimmer package in `pubspec.yaml` (ADR-030). A single `AnimationController` with a looping `Tween<double>` and `AnimatedBuilder` in `PreStartSkeleton` matches the SCR-10 implementation pattern and avoids a new dependency.

**Alternatives considered**:
- Add `shimmer` pub.dev package — rejected: requires a new ADR and dependency approval.
- `StatelessWidget` + `RepaintBoundary` trick — rejected: requires `ticker`/external state; a `StatefulWidget` is cleaner.

---

## D-06: Exercise display — reuse `PlanExerciseDetailCard` vs. new widget

**Decision**: Create a new `ExercisePreviewCard` widget. Do not reuse `PlanExerciseDetailCard`.

**Rationale**: The design spec for SCR-15 explicitly omits the Rest period field, uses a colored type dot (not a text badge), and uses a different column layout (weighted: 3-col sets/reps/weight; bodyweight/time-based: 2-col). `PlanExerciseDetailCard` shows rest, uses a badge, and has a 4-column layout. Making it configurable would introduce excessive boolean flags (CLAUDE.md rule 22). A purpose-built read-only `ExercisePreviewCard` is cleaner.

**Alternatives considered**:
- Extend `PlanExerciseDetailCard` with `showRest: false, showTypeDot: true` — rejected: 3 diverging display modes plus 2 new boolean flags; violates composition-over-flags rule.
- Reuse with `shrinkWrap` + layout hacks — rejected: produces fragile layout that breaks at different screen widths.

---

## D-07: "Plan unavailable" state — reuse `PlanNotAvailableCard` vs. new widget

**Decision**: Create `PreStartUnavailableState` (full-screen centred layout). Do not reuse `PlanNotAvailableCard`.

**Rationale**: `PlanNotAvailableCard` renders inside a `Container` card with padding and its own border. SCR-15's design requires a centred full-screen state with a larger alert icon (30×30 danger), different copy, and a different button label ("Back to Schedule" vs. "Back to Plans"). Reusing would require wrapping hacks or making the widget configurable in incompatible ways.

**Alternatives considered**:
- `PlanNotAvailableCard` with new props — rejected: layout and icon are fundamentally different; would require `isFullScreen: true` + `iconSize` + `buttonLabel` params — too many flags.
- Shared `EmptyStateWidget` — not yet in the project; would be a new abstraction, out of scope for this task.

---

## D-08: Weight "not set" display

**Decision**: Show `"—"` (em dash) for null or zero `targetWeight` on a weighted exercise. Sourced from `AppStrings.preStartWeightNotSet`.

**Rationale**: The design spec OQ-3 states: "Weight not yet configured → show a dash". An em dash is idiomatic for "not applicable / not set" in fitness UIs. Using an `AppStrings` constant (not a hardcoded literal) satisfies the no-hardcoded-strings rule.

---

## D-09: Duration format

**Decision**: Format `targetDurationSec` as `MM:SS` using a utility function `formatDuration(int seconds) → String`. Example: 45 → `"00:45"`, 90 → `"01:30"`.

**Rationale**: The design spec shows `"00:45"` for a 45-second exercise. `MM:SS` is the universal format for sub-hour durations in workout apps. The existing codebase has no centralized duration formatter, so a small helper is added to `forge/lib/core/utils/format_utils.dart` (or analogous file if it already exists).

---

## D-10: Scheduled-weekday context — how PreStartBloc receives it

**Decision**: `PreStartRequested` carries both `planId: String` and `scheduledWeekday: int?` (nullable). The Bloc passes the weekday through to `PreStartLoaded` so the screen can display the scheduling context line (FR-008) without an extra Drift read.

**Rationale**: The route receives `planId` from the path parameter. The scheduled weekday is only meaningful when the entry point is the weekly schedule; it is null when entered from Plan Detail. The caller passes it via the `extra` parameter in the `context.push` call:
- `plan_detail_screen.dart`: passes `scheduledWeekday: null`
- `weekly_schedule_screen.dart`: passes `scheduledWeekday: weekday`

**Alternatives considered**:
- Store weekday in route query params — rejected: makes the URL expose schedule state; fragile if navigated to directly.
- Re-read schedule in `PreStartBloc` from `ScheduleRepository` — rejected: unnecessary second Drift read; the caller already knows the weekday.

---

## D-11: "Begin Workout" navigation — SCR-16 stub

**Decision**: `WorkoutPreStartScreen` calls `context.push(RoutePaths.activeWorkout)` where `activeWorkout = '/workout/active'`. The route builder for this path renders a temporary placeholder screen (`Scaffold` + `Center` + `Text('SCR-16 — Active Workout (coming soon)')`).

**Rationale**: SCR-16 is out of scope for this feature. A stub route constant and placeholder keeps the codebase navigable and the tests meaningful (the test can verify the push call fires) without partial-feature code.

---

## D-12: SCR-12 onStartDay callback update

**Decision**: Update `OnStartDayCallback typedef` in `week_schedule_list.dart` from `void Function(String planId)` to `void Function(String planId, int weekday)`. Update `DayRow`, `WeekScheduleList`, and `WeeklyScheduleScreen` accordingly.

**Rationale**: The SCR-12 plan left `TODO(SCR-15): wire navigation` in `WeeklyScheduleScreen`. The TODO stub calls `onStartDay(day.assignedPlan!.planId)` but `PreStartScreen` also needs the scheduled weekday (D-10). Passing weekday alongside planId is the minimal change; no extra Drift read required.

**Scope note**: This is a modification of three already-existing files in `schedule/presentation/`, not a new feature. The change is small, typed, and directly enables FR-008. All existing SCR-12 tests remain valid — the callback signature change is propagated through the widget tree consistently.
