# Contract: CancelWorkoutScreen

**File**: `forge/lib/features/workout_session/presentation/screens/cancel_workout_screen.dart`  
**Layer**: `presentation/screens/` (Clean Feature-First — `workout_session` feature)  
**Type**: `StatefulWidget` (local UI state only — `bool _isDiscarding`)

---

## Purpose

A transparent overlay screen pushed at `RoutePaths.cancelWorkout` (`/workout/cancel`) when the user initiates a workout cancellation from SCR-16. Shows a destructive confirmation modal over a dimmed SCR-16 background. The user chooses "Keep Going" (resume workout) or "Discard Workout" (abandon session and go home).

SCR-18 has no Bloc of its own. It does not interact with Drift. "Discard" is a navigation-only operation (see research D-04).

---

## Inputs (Constructor Parameters)

`CancelWorkoutScreen` takes one required `planName` parameter (FR-003: "MUST display the name of the active workout plan"). The plan name is sourced from `ActiveWorkoutRunning.planName` in SCR-16's Bloc state and forwarded via `go_router`'s `extra` field when the BlocListener pushes the cancel route.

```dart
class CancelWorkoutScreen extends StatefulWidget {
  const CancelWorkoutScreen({super.key, required this.planName});
  final String planName;
  // ...
}
```

**Routing extra**: The BlocListener in `ActiveWorkoutScreen` passes the plan name when pushing:

```dart
context.push(RoutePaths.cancelWorkout, extra: state.planName);
```

The `GoRoute.pageBuilder` extracts it:

```dart
final planName = state.extra as String? ?? '';
child: CancelWorkoutScreen(planName: planName),
```

---

## Local State

| Field | Type | Initial | Purpose |
|-------|------|---------|---------|
| `_isDiscarding` | `bool` | `false` | Disables "Discard Workout" button after first tap (FR-011) |

---

## Interactions

### `_handleKeepGoing()`

- Called by: "Keep Going" button `onPressed`, `GestureDetector.onTap` on the scrim background, `PopScope.onPopInvokedWithResult`
- Effect: `context.pop()` — pops SCR-18 and returns to SCR-16

```dart
void _handleKeepGoing() {
  context.pop();
}
```

### `_handleDiscard()`

- Called by: "Discard Workout" button `onPressed` (only when `!_isDiscarding`)
- Guard: `setState(() => _isDiscarding = true)` before navigation (FR-011)
- Effect: `context.go(RoutePaths.home)` — replaces entire navigation stack with home (FR-007, SC-004)

```dart
void _handleDiscard() {
  if (_isDiscarding) return;
  setState(() => _isDiscarding = true);
  context.go(RoutePaths.home);
}
```

---

## UI Contract

### Layout

- Root: `Scaffold(backgroundColor: Colors.transparent)` — keeps SCR-16 visible through the route's `barrierColor`
- Scrim tap target: `GestureDetector` covering the full screen area outside the modal card → `_handleKeepGoing()` (FR-008)
- Modal card: anchored to bottom of screen (`Alignment.bottomCenter`) with `SafeArea` padding
- Card background: `AppColors.card`
- Card border radius: top corners rounded (use existing card radius from design tokens)

### Back navigation guard

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (_, __) => _handleKeepGoing(),
  child: ...
)
```

OS back while SCR-18 is open = "Keep Going" (FR-009).

### Strings

| Slot | Source | Value |
|------|--------|-------|
| Plan name | `widget.planName` (constructor param) | Dynamic — from `ActiveWorkoutRunning.planName` |
| Title | `AppStrings.cancelWorkoutTitle` | `'Cancel this workout?'` |
| Subtitle | `AppStrings.cancelWorkoutSubtitle` | `"Your progress won't be saved. This session won't appear in your workout history."` |
| Discard button label | `AppStrings.cancelWorkoutDiscardButton` | `'Discard Workout'` |
| Keep Going button label | `AppStrings.cancelWorkoutKeepGoingButton` | `'Keep Going'` |

The plan name is rendered in the modal body between the title and the warning subtitle (FR-003). It uses `theme.textTheme` — no hardcoded text style.

### Colors

| Element | Color |
|---------|-------|
| Modal card background | `AppColors.card` |
| "Discard Workout" button fill | `AppColors.danger` |
| "Discard Workout" button text | `AppColors.onDanger` |
| "Keep Going" button background | `AppColors.cardAlt` |
| "Keep Going" button border | `AppColors.border` |
| "Keep Going" button text | `AppColors.white` |
| Warning icon background | `AppColors.dangerBg` |

All tokens exist — no new `AppColors` entries needed (research D-08).

### Button states

| State | Discard button | Keep Going button |
|-------|---------------|-------------------|
| `_isDiscarding = false` | Enabled | Enabled |
| `_isDiscarding = true` | Disabled (greyed, no `onPressed`) | Enabled |

---

## Route Registration

**File**: `forge/lib/config/routes/app_routes.dart`

```dart
GoRoute(
  path: RoutePaths.cancelWorkout,     // '/workout/cancel'
  name: RoutePaths.cancelWorkoutName, // 'cancelWorkout'
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    opaque: false,
    barrierColor: AppColors.scrimBarrier,
    child: const CancelWorkoutScreen(),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  ),
),
```

`opaque: false` allows SCR-16 to remain rendered and visible through the scrim (research D-02).

---

## Acceptance Scenarios (from spec US1 + US2)

| # | Trigger | Expected |
|---|---------|----------|
| 1 | SCR-16 Cancel tap → SCR-18 opens | Modal visible, SCR-16 dimmed behind it; plan name shown in modal body (FR-003) |
| 2 | SCR-18 → "Keep Going" tap | `context.pop()`, SCR-16 unchanged |
| 3 | SCR-18 → "Discard Workout" tap | `context.go('/'), ActiveWorkoutBloc disposed |
| 4 | SCR-18 → scrim tap | Same as "Keep Going" |
| 5 | SCR-18 → OS back gesture | Same as "Keep Going" |
| 6 | SCR-18 → "Discard Workout" double-tap | Button disabled after first tap; no double navigation |
| 7 | SCR-16 OS back gesture → SCR-18 opens | Same modal appears (PopScope in SCR-16 dispatches `CancelRequested`) |
