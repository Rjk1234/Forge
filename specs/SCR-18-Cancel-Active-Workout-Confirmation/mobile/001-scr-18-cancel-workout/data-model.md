# Data Model: SCR-18 Cancel Active Workout Confirmation

**Date**: 2026-09-23 | **Feature**: SCR-18

---

## New Entities

**None.** SCR-18 introduces zero new domain entities or tables.

The in-progress workout session is held exclusively in `ActiveWorkoutBloc`'s in-memory state (confirmed in research D-04). Discarding it requires no Drift operation.

---

## SCR-16 State Amendments

The `ActiveWorkoutRunning` state already has `navigateToCancel: bool` (pre-designed in SCR-16 data model). SCR-18 fills in the event and handler pair that activates this field.

### `active_workout_state.dart` — No Changes Required

`navigateToCancel: bool` already exists in `ActiveWorkoutRunning`. No state shape change needed.

### `active_workout_event.dart` — Add Two Events

```dart
/// Dispatched by the Cancel button (app bar) or PopScope in ActiveWorkoutScreen.
/// Triggers navigation to SCR-18 by setting navigateToCancel: true in state.
class ActiveWorkoutCancelRequested extends ActiveWorkoutEvent {
  const ActiveWorkoutCancelRequested();
}

/// Dispatched by BlocListener after pushing the cancel route,
/// to reset navigateToCancel back to false.
class ActiveWorkoutCancelNavigated extends ActiveWorkoutEvent {
  const ActiveWorkoutCancelNavigated();
}
```

**Convention**: Follows the `ActiveWorkoutRestTimerNavigated` pattern established by SCR-17. Both `CancelRequested` and `CancelNavigated` are `const` and carry no payload.

### `active_workout_bloc.dart` — Add Two Handlers

```dart
on<ActiveWorkoutCancelRequested>(_onCancelRequested);
on<ActiveWorkoutCancelNavigated>(_onCancelNavigated);

void _onCancelRequested(
  ActiveWorkoutCancelRequested event,
  Emitter<ActiveWorkoutState> emit,
) {
  if (state is! ActiveWorkoutRunning) return;
  emit((state as ActiveWorkoutRunning).copyWith(navigateToCancel: true));
}

void _onCancelNavigated(
  ActiveWorkoutCancelNavigated event,
  Emitter<ActiveWorkoutState> emit,
) {
  if (state is! ActiveWorkoutRunning) return;
  emit((state as ActiveWorkoutRunning).copyWith(navigateToCancel: false));
}
```

### `active_workout_screen.dart` — Three Amendment Points

1. **BlocListener** — add `navigateToCancel` branch (alongside existing `navigateToRestTimer` and `navigateToPostWorkout`):

```dart
if (state.navigateToCancel) {
  context.push(RoutePaths.cancelWorkout, extra: state.planName);
  context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelNavigated());
}
```

2. **Cancel button `onPressed`** — replace stub direct push with Bloc event:

```dart
// BEFORE (SCR-16 stub):
// onPressed: () => context.push(RoutePaths.cancelWorkout),

// AFTER (SCR-18 fills):
onPressed: () =>
    context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelRequested()),
```

3. **`PopScope.onPopInvokedWithResult`** — replace stub direct push with Bloc event:

```dart
// BEFORE (SCR-16 stub, SCR-16 D-05):
// onPopInvokedWithResult: (_, __) => context.push(RoutePaths.cancelWorkout),

// AFTER (SCR-18 fills):
onPopInvokedWithResult: (_, __) =>
    context.read<ActiveWorkoutBloc>().add(const ActiveWorkoutCancelRequested()),
```

---

## Route Amendment

### `app_routes.dart` — Replace Stub with Real Route

The `GoRoute` at `RoutePaths.cancelWorkout` currently points to a stub screen. Replace with:

```dart
GoRoute(
  path: RoutePaths.cancelWorkout,
  name: RoutePaths.cancelWorkoutName,
  pageBuilder: (context, state) {
    final planName = state.extra as String? ?? '';
    return CustomTransitionPage(
      key: state.pageKey,
      opaque: false,
      barrierColor: AppColors.scrimBarrier,
      child: CancelWorkoutScreen(planName: planName),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  },
),
```

`RoutePaths.cancelWorkout`, `RoutePaths.cancelWorkoutName`, and `AppColors.scrimBarrier` all exist — no new constants needed. Remove the `cancelWorkoutStubLabel` constant once the stub screen is deleted.

---

## AppStrings — New Section

Add to `forge/lib/core/strings/app_strings.dart` in a clearly marked SCR-18 block:

```dart
// SCR-18: Cancel Active Workout Confirmation
static const String cancelWorkoutTitle = 'Cancel this workout?';
static const String cancelWorkoutSubtitle =
    "Your progress won't be saved. "
    "This session won't appear in your workout history.";
static const String cancelWorkoutKeepGoingButton = 'Keep Going';
static const String cancelWorkoutDiscardButton = 'Discard Workout';
```

**Notes**:
- `cancelWorkoutTitle` is distinct from the existing `activeWorkoutCancelButton = 'Cancel'` (SCR-16's app bar link).
- The subtitle is a two-part string concatenated at compile time (Dart adjacent string literals).
- No localization file update needed — ForgeApp uses `AppStrings` constants, not ARB files.

---

## `CancelWorkoutScreen` Widget Shape

**File**: `forge/lib/features/workout_session/presentation/screens/cancel_workout_screen.dart`

**Type**: `StatefulWidget` (local `bool _isDiscarding = false` for double-tap guard)

**Widget structure** (for contract and implementation reference):

```
CancelWorkoutScreen (StatefulWidget, required planName: String)
└── Scaffold(backgroundColor: Colors.transparent)
    └── GestureDetector(onTap: _handleKeepGoing)   ← scrim tap = Keep Going (FR-008)
        └── SafeArea
            └── Align(alignment: Alignment.bottomCenter)   ← anchored sheet
                └── Column (card container)
                    ├── AlertIcon (danger warning icon)
                    ├── Text(AppStrings.cancelWorkoutTitle)   ← title
                    ├── Text(widget.planName)                 ← plan name (FR-003)
                    ├── Text(AppStrings.cancelWorkoutSubtitle)  ← warning body copy
                    ├── PrimaryButton(
                    │       label: AppStrings.cancelWorkoutDiscardButton,
                    │       isEnabled: !_isDiscarding,   ← FR-011
                    │       onPressed: _handleDiscard,
                    │       variant: AppButtonVariant.danger,
                    │   )
                    └── SecondaryButton(
                            label: AppStrings.cancelWorkoutKeepGoingButton,
                            onPressed: _handleKeepGoing,
                        )
```

**State machine (local)**:

| State | `_isDiscarding` | Button state |
|-------|-----------------|--------------|
| Initial | `false` | Discard enabled |
| Discarding | `true` | Discard disabled (FR-011) |

**Methods**:
- `_handleKeepGoing()` → `context.pop()` (returns to SCR-16)
- `_handleDiscard()` → `setState(() => _isDiscarding = true)` → `context.go(RoutePaths.home)` (D-05, D-06)

**PopScope**: `PopScope(canPop: false, onPopInvokedWithResult: (_, __) => _handleKeepGoing())` — OS back while SCR-18 is open = Keep Going (FR-009).

---

## File Impact Summary

| File | Change Type | Note |
|------|-------------|------|
| `workout_session/application/bloc/active_workout_event.dart` | MODIFY | Add 2 events |
| `workout_session/application/bloc/active_workout_bloc.dart` | MODIFY | Add 2 handlers |
| `workout_session/presentation/screens/active_workout_screen.dart` | MODIFY | BlocListener + button + PopScope |
| `workout_session/presentation/screens/cancel_workout_screen.dart` | CREATE | New screen |
| `config/routes/app_routes.dart` | MODIFY | Replace stub route |
| `core/strings/app_strings.dart` | MODIFY | Add 4 string constants |
| `test/.../cancel_workout_screen_test.dart` | CREATE | Widget tests |
| `test/.../active_workout_bloc_test.dart` | MODIFY | 2 new event scenarios |
