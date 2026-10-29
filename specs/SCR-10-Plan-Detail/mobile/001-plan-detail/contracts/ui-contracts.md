# UI Contracts: Plan Detail (SCR-10)

**Feature**: SCR-10-Plan-Detail  
**Date**: 2026-09-19

---

## Screen Contract: `PlanDetailScreen`

### Route

```
/plans/:planId
```

Registered in `RoutePaths.planDetail`. Replaces the current `PlaceholderTabScreen` at this path.

### Input

| Parameter | Source | Type | Required |
|-----------|--------|------|----------|
| `planId` | `state.pathParameters['planId']` | `String` | Yes |

### Bloc provisioning

```
BlocProvider(
  create: (_) => getIt<PlanDetailBloc>(),
  child: PlanDetailScreen(planId: planId),
)
```

`PlanDetailBloc` is a `registerFactory` — a fresh instance per screen open.

### Initial behaviour

On `initState`, dispatches `PlanDetailLoadRequested(planId: planId)`.

### State → UI mapping

| State | UI |
|-------|----|
| `PlanDetailInitial` | Same as `PlanDetailLoading` (should not be visible long) |
| `PlanDetailLoading` | `PlanDetailSkeleton` |
| `PlanDetailLoaded(plan)` | Populated layout: title block + exercise list + footer |
| `PlanDetailNotFound(message)` | Error layout: app bar (back only) + `PlanNotAvailableCard` |

### Navigation outputs

| Trigger | Route | Method | Refresh after? |
|---------|-------|--------|----------------|
| Back chevron | `context.pop()` | Pop | No |
| Edit button | `/plans/$planId/edit` | `await context.push(...)` | Yes — dispatch `PlanDetailLoadRequested` on return |
| Delete button | `/plans/$planId/delete` | `await context.push(...)` | Yes — dispatch `PlanDetailLoadRequested` on return |
| Schedule button | `/plans/$planId/schedule` | `context.push(...)` | No |
| Start Workout button | `/plans/$planId/start` | `context.push(...)` | No |
| "Back to Plans" (error state) | `context.pop()` | Pop | No |
| Back chevron (loading state) | `context.pop()` | Pop | No |

> Note: `/plans/$planId/delete`, `/plans/$planId/schedule`, and `/plans/$planId/start` are stub routes at SCR-10 implementation time. Their screens are implemented by SCR-11, SCR-13, and SCR-15 respectively.

---

## Bloc Contract: `PlanDetailBloc`

### Events

```dart
sealed class PlanDetailEvent extends Equatable {
  const PlanDetailEvent();
}

final class PlanDetailLoadRequested extends PlanDetailEvent {
  const PlanDetailLoadRequested({required this.planId});
  final String planId;
  @override List<Object> get props => [planId];
}
```

### States

```dart
sealed class PlanDetailState extends Equatable {
  const PlanDetailState();
}

final class PlanDetailInitial extends PlanDetailState {
  const PlanDetailInitial();
  @override List<Object> get props => [];
}

final class PlanDetailLoading extends PlanDetailState {
  const PlanDetailLoading();
  @override List<Object> get props => [];
}

final class PlanDetailLoaded extends PlanDetailState {
  const PlanDetailLoaded({required this.plan});
  final WorkoutPlanDetail plan;
  @override List<Object> get props => [plan];
}

final class PlanDetailNotFound extends PlanDetailState {
  const PlanDetailNotFound({required this.message});
  final String message;
  @override List<Object> get props => [message];
}
```

### Handler contract

```
On PlanDetailLoadRequested(planId):
  1. emit(PlanDetailLoading())
  2. result = await getWorkoutPlanById(planId)
  3. result.fold(
       (error) => emit(PlanDetailNotFound(message: error.message)),
       (plan)  => emit(PlanDetailLoaded(plan: plan)),
     )
```

---

## Widget Contracts

### `PlanDetailSkeleton`

| Parameter | Type | Purpose |
|-----------|------|---------|
| `animation` | `Animation<double>` | Drives shimmer colour lerp |

Renders: shimmer app bar stubs (two icon box skeletons), two shimmer title lines, three shimmer exercise cards, two shimmer footer buttons. Back chevron is live (not skeleton).

### `PlanExerciseDetailCard`

| Parameter | Type | Required | Purpose |
|-----------|------|----------|---------|
| `exercise` | `PlanExercise` | Yes | Exercise data to display |

Read-only. No callbacks. Renders: type dot + type label + exercise name in header row; field boxes (layout by `exercise.type`) in body.

**Field layout by type**:
- `weighted`: Row 1: Sets + Reps + Weight. Row 2 (full-width): Rest.
- `timeBased`: One row: Sets + Duration + Rest.
- `bodyweight`: One row: Sets + Reps + Rest.

**Value formatting** (see data-model.md for rules): weight → "N kg", rest → "Ns", duration → "mm:ss", sets/reps → plain int.

### `PlanNotAvailableCard`

| Parameter | Type | Required | Purpose |
|-----------|------|----------|---------|
| `onBackToPlans` | `VoidCallback` | Yes | Handles "Back to Plans" button tap |

Renders: X-in-circle icon (danger colour), "This plan is no longer available" title, body copy, "Back to Plans" button.

### `ShimmerBox` (extracted shared widget)

Located at `forge/lib/core/widgets/shimmer_box.dart`.

| Parameter | Type | Required | Purpose |
|-----------|------|----------|---------|
| `animation` | `Animation<double>` | Yes | Drives shimmer lerp |
| `height` | `double` | Yes | Box height |
| `borderRadius` | `double` | Yes | Corner radius |
| `width` | `double?` | No | Fixed width (null = fill parent via `LayoutBuilder`) |
| `widthFraction` | `double?` | No | Width as fraction of parent (used when `width` is null) |

---

## New AppStrings Constants (SCR-10)

To be added to `forge/lib/core/strings/app_strings.dart`:

```dart
// SCR-10: Plan Detail
static const String planDetailLoadingSemantics = 'Loading plan details';
static const String planDetailExercisesSectionLabel = 'EXERCISES';
static const String planDetailExerciseCount =
    ''; // formatted at runtime: '$n exercises'
static const String planDetailStartWorkoutButton = 'Start Workout';
static const String planDetailScheduleButton = 'Schedule';
static const String planDetailEditTooltip = 'Edit plan';
static const String planDetailDeleteTooltip = 'Delete plan';
static const String planDetailBackTooltip = 'Back';
static const String planNotAvailableTitle = 'This plan is no longer available';
static const String planNotAvailableBody =
    'It may have been deleted, or something went wrong reading local data.';
static const String planNotAvailableButton = 'Back to Plans';
static const String planDetailSetsLabel = 'Sets';    // reuse AppStrings.setsLabel
static const String planDetailRepsLabel = 'Reps';    // reuse AppStrings.repsLabel
static const String planDetailWeightLabel = 'Weight'; // display-only — "N kg" includes unit
static const String planDetailRestLabel = 'Rest';    // display-only — "Ns" includes unit
static const String planDetailDurationLabel = 'Duration'; // reuse AppStrings.durationLabel
static const String exerciseUnavailableName = 'Exercise unavailable';
```

> Note: Field labels for the read-only display reuse existing `AppStrings.setsLabel`, `AppStrings.repsLabel`, `AppStrings.durationLabel`. New string constants are only added where no equivalent exists.

---

## Modified Files Summary

| File | Change |
|------|--------|
| `forge/lib/config/routes/app_routes.dart` | Replace `PlaceholderTabScreen` at `/plans/:planId` with `PlanDetailScreen` |
| `forge/lib/app/get_it_setup.dart` | Register `PlanDetailBloc` as `registerFactory` |
| `forge/lib/core/strings/app_strings.dart` | Add SCR-10 string constants |
| `forge/lib/core/widgets/shimmer_box.dart` | **New** — extracted from `_ShimmerBox` in `plans_skeleton_list.dart` |
| `forge/lib/features/workout_plan/presentation/widgets/plans_skeleton_list.dart` | Update to use shared `ShimmerBox` |
| `forge/lib/features/workout_plan/presentation/widgets/exercise_card.dart` | Fix bodyweight badge colour: `amber` → `textMuted` |
