# Research: SCR-09 Create / Edit Workout Plan

**Feature**: `001-create-edit-workout-plan`
**Date**: 2026-09-17
**Status**: Complete — all unknowns resolved

---

## 1. UUID Generation for New Plan IDs

**Decision**: Use `const Uuid().v4()` from the `uuid` package already present in `pubspec.yaml` (`uuid: ^4.5.1`).

**Rationale**: The `uuid` package is in the governed dependency set and is already a declared dependency. No new package is needed. Version 4 UUIDs are collision-resistant and appropriate for local-only identifiers.

**Alternatives considered**:
- `DateTime.now().millisecondsSinceEpoch.toString()` — rejected: not guaranteed unique if two plans are created in the same millisecond (unlikely but possible in test scenarios).
- A manual counter — rejected: requires persistent state across app restarts, adding complexity.

**Usage**: In `SaveWorkoutPlanUseCase`, when `planId` is null (create mode), call `const Uuid().v4()` to generate the new ID. In edit mode, the existing `planId` is preserved.

---

## 2. Picker Return Value — Exercise Object vs. ID String

**Decision**: Modify `ExerciseCatalogueScreen._onAddExercise` to call `context.pop(exercises[i])` (returning the full `Exercise` object) instead of `context.pop(exercises[i].id)` (returning just the ID string). The `CreateEditWorkoutPlanScreen` awaits the push result and receives an `Exercise` directly.

**Rationale**: The current implementation pops with a String ID. SCR-09 needs the exercise's `name` and `type` to build the exercise card immediately (before any database read). Returning the full `Exercise` object eliminates the need for a `GetExerciseByIdUseCase` and an additional database read per added exercise. The current String-popping code has no downstream consumers that would break (the only caller today is a `PlaceholderTabScreen` that discards the result).

**Alternatives considered**:
- Add `GetExerciseByIdUseCase` and resolve the ID in the Bloc after receiving a String — rejected: adds a round-trip database read per exercise addition with no benefit, and forces the Bloc to handle a `Future` just to resolve a display name.
- Pass the Exercise forward through the picker's `extra` argument — rejected: the picker doesn't know which exercise the user will select at navigate time; only at pop time.

**Go_router pattern used**:
```dart
// In CreateEditWorkoutPlanScreen — navigate to picker and await result:
final exercise = await context.push<Exercise>(
  RoutePaths.planExercises,
  extra: PickerContext(planName: _currentPlanName),
);
if (exercise != null && mounted) {
  _bloc.add(ExerciseAdded(exercise));
}
```

---

## 3. Back Navigation Guard — PopScope Pattern

**Decision**: Use `PopScope(canPop: false, onPopInvokedWithResult: (didPop, _) { if (!didPop) _onBackRequested(); })` to intercept all back navigation (back icon tap, Android system back gesture, iOS swipe-from-left-edge). `_onBackRequested` shows the discard dialog if the form is dirty, or calls `context.pop()` if the form is clean.

**Rationale**: `PopScope` with `canPop: false` is the Flutter 3.13+ standard for conditional back navigation on both iOS and Android. It intercepts the system back gesture (Android edge swipe / hardware back button) and the in-app back icon tap identically. Using `WillPopScope` is deprecated since Flutter 3.12.

**Key detail**: The back icon in the `AppBar` must call `_onBackRequested()` directly (not `context.pop()`), so the same guard logic applies whether the user taps the icon or triggers the system gesture.

**Saving state special case**: During the saving state, `canPop` is set to `false` AND `_onBackRequested` does nothing (returns early), effectively blocking navigation. The back icon is rendered as dim/non-interactive via the `BlocBuilder` state check.

---

## 4. Weight Field — 1dp Input Formatter

**Decision**: Implement a `DecimalOneDigitInputFormatter extends TextInputFormatter` that uses the regex `RegExp(r'^\d*\.?\d{0,1}$')` to validate each edit. Any edit that would result in more than one decimal digit is rejected — the field does not accept the character.

**Rationale**: Client-side input formatters block disallowed input before it reaches the text field value, giving instant feedback. The regex allows: empty string, integer-only strings (e.g., `10`), strings with a trailing dot (e.g., `10.`), and strings with exactly one decimal digit (e.g., `10.5`). It rejects `10.55` and any subsequent digit after the first decimal.

**Alternatives considered**:
- Truncate on save — rejected by CL-01: the spec explicitly says "no silent rounding on save".
- Allow two decimal places in the field and show a validation error — rejected: the spec says the formatter blocks at the keyboard level.

**Usage**: Applied to the Weight `TextField` alongside `TextInputType.numberWithOptions(decimal: true)` keyboard type.

---

## 5. Edit Mode Route — Entry Point from SCR-10

**Decision**: Add a new route `/plans/:planId/edit` as a child route under the `:planId` GoRoute. `CreateEditWorkoutPlanScreen` receives `planId` via `state.pathParameters['planId']`. Create mode uses the existing `/plans/create` route, which passes `planId: null`.

**Rationale**: The spec (OQ-1) establishes that edit mode is entered from SCR-10 (Plan Detail). SCR-10 will navigate via `context.push('/plans/$planId/edit')`. This is a standard go_router child-route pattern consistent with the existing `/plans/:planId` hierarchy. The route parameter is the cleanest signal for mode — no `extra` or query-param hacks needed.

**Route additions to `app_routes.dart`**:
- `/plans/create` → `CreateEditWorkoutPlanScreen(planId: null)` (replaces existing PlaceholderTabScreen)
- `/plans/:planId/edit` → `CreateEditWorkoutPlanScreen(planId: state.pathParameters['planId'])` (new child route under `:planId`)

**Navigation after save**: `context.go('/plans/$savedPlanId')` — replaces the back stack so that back from SCR-10 returns to the Plans list, not the create/edit form.

---

## 6. Dirty State Detection

**Decision**: The Bloc holds an `_initialSnapshot` (the name and exercise list as they were when `CreateEditPlanInitialized` completed). Any `PlanNameChanged`, `ExerciseAdded`, `ExerciseRemoved`, or `ExerciseFieldChanged` event sets `isDirty = true`. The snapshot is never re-taken (no re-baselining after a successful save — success navigates away). For create mode, the initial snapshot is empty (empty name, empty list), so any typed character or added exercise triggers dirty.

**Rationale**: In-memory snapshot comparison avoids unnecessary database reads during typing. The spec (Assumption: Edit mode change detection) explicitly states "in-memory only; no deep-equality comparison to the database is performed on every keystroke." Once dirty, the form stays dirty until it is saved or discarded.

**Edge case — save failure**: In the save failure state, the form remains dirty. The discard guard stays active. Tapping "Retry Save" re-attempts the write — if it succeeds, the screen navigates away; if it fails, the form stays dirty in the failure state.

---

## 7. Form State — canSave and Validation Timing

**Decision**: `canSave` is computed as `name.trim().isNotEmpty && exercises.isNotEmpty && _nameValidationError == null && _exerciseErrors.isEmpty`. Validation errors are stored as `String? _nameValidationError` and `Map<int, List<String>> _exerciseErrors`. `ExerciseFieldChanged` events clear the specific field's error from the map immediately (FR-012). `PlanNameChanged` clears the name error immediately if the name is now non-empty/non-whitespace.

**Rationale**: The spec requires validation to run only on save attempt (FR-012), but errors to clear immediately as the user corrects them. This is cleanly implemented by storing errors in state and clearing them on the relevant change events. `canSave` is derived state, not separately stored.

**Saving state**: During `CreateEditPlanSaving`, the Bloc does not respond to any field-change events (they are no-ops). The back guard ignores the back gesture while saving.

---

## Summary of Decisions

| Topic | Decision |
|---|---|
| UUID generation | `Uuid().v4()` — `uuid` package already in pubspec |
| Picker return type | Return full `Exercise` object from picker; remove String ID pop |
| Back guard | `PopScope(canPop: false, onPopInvokedWithResult: ...)` |
| Weight input | `DecimalOneDigitInputFormatter` with regex `^\d*\.?\d{0,1}$` |
| Edit mode route | `/plans/:planId/edit` child route; create uses `/plans/create` |
| Dirty detection | In-memory snapshot at init; any change sets `isDirty = true` |
| Validation timing | Run on save attempt; clear per-field on correction event |
