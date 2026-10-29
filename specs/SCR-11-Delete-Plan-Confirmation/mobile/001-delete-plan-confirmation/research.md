# Research: Delete Plan Confirmation (SCR-11)

**Date**: 2026-09-19 | **Feature**: SCR-11 — Delete Plan Confirmation

---

## Decision 1: Dialog Presentation — `showDialog()` vs. Pushed Route

**Decision**: Use Flutter's `showDialog()` from `PlanDetailScreen._onDelete`, not a `go_router` pushed route.

**Rationale**: The design spec explicitly states SCR-11 is "a modal dialog, not a pushed route." `showDialog()` is Flutter's standard API for transient confirmation dialogs — it does not modify the navigation stack, it returns a typed result (`bool?`), and it naturally supports `barrierDismissible: false`. Using a pushed route for a dialog creates unnecessary stack entries, requires custom `Page` subclasses for transparency, and complicates result passing. `showDialog()` is not a second router; `go_router` remains the sole router for screen-level navigation.

**Consequence for SCR-10**: `_onDelete` in `plan_detail_screen.dart` changes from `await context.push('/plans/$planId/delete')` to `await showDialog<bool>(...)`. The go_router stub route for `delete` under `:planId` is not created (it was never wired in the existing routes). SCR-10's test file has no test asserting navigation to a delete route — the change is additive.

**Alternatives considered**:
- `GoRoute` with transparent `Page` subclass — overly complex; no precedent in this codebase; `go_router` route for a dialog adds unnecessary stack entry.
- `CupertinoActionSheet` — wrong pattern for a destructive confirmation dialog with a spinner state; not aligned with the Material design system ForgeApp uses.

---

## Decision 2: Atomicity — Sequential Delete (Schedules First, Then Plan)

**Decision**: `WorkoutPlanRepositoryImpl.deletePlan` deletes schedule entries first, then the plan, sequentially. Both steps use existing Drift data-source operations (two separate statements, not one transaction).

**Rationale**: The two deletes run as independent statements, so a failure between them leaves a partial result. The chosen order minimises the worst-case data inconsistency:
- **If schedule delete fails** (before plan delete): Plan and all schedules remain. Consistent state. User retries.
- **If plan delete fails** (after schedules deleted): Plan exists, schedules for it are gone. Minor inconsistency (orphaned plan visible, no schedule entries) — more tolerable than the reverse (plan gone from list, schedule entries still reference it).
- **If both succeed**: Clean state.

The "schedules then plan" order ensures the entity users interact with (the plan in the list) is the last thing removed, preserving the most user-visible consistency on partial failure.

**Implementation**: `ScheduleLocalDataSource` gains `deleteEntriesForPlan(String planId)` — scans all entries (max 7), deletes those matching the planId using the existing `deleteEntry(weekday)` method.

**Alternatives considered**:
- Plan first, then schedules — worse on partial failure (plan gone but schedules linger, causing SCR-08 to show ghost schedule entries for a non-existent plan).
- Atomic wrapper class — Drift has no transaction API; a custom wrapper would add unwarranted complexity for a 2-step sequential operation on max 7 entries.

---

## Decision 3: `DeletePlanBloc` State Design — No `DeletePlanInitial` State

**Decision**: `DeletePlanBloc` starts in `DeletePlanConfirmation` state (not a separate `Initial` state).

**Rationale**: The dialog only exists while it is visible. The initial visible state is always the Confirmation dialog — there is no blank or pre-initialised intermediate. Adding a `DeletePlanInitial` state would add a no-op state that the dialog would skip in a single frame with no meaningful difference in behaviour or testability.

**States**: `DeletePlanConfirmation`, `DeletePlanDeleting`, `DeletePlanSuccess`, `DeletePlanFailure({required String message})`.

**Events**: A single event class `DeletePlanConfirmed({required String planId})` handles both the initial Delete tap and the Retry tap (same action, same handler). Cancel is handled directly via `Navigator.pop(context, false)` — no Bloc event needed for a dismiss.

---

## Decision 4: `onDanger` Color Token

**Decision**: Add `static const Color onDanger = Color(0xFF2A1414)` to `AppColors`.

**Rationale**: The design spec documents `#2a1414` as the text color on the danger-red (`#ff6b6b`) fill button. It provides ~4.6:1 contrast (just passes WCAG AA). It is not a shade of black or white — it is a very-dark desaturated red specifically designed for legibility on the danger fill. Hardcoding it inline would violate the CLAUDE.md rule against hardcoded colors. Formalising it as a token (`onDanger`) parallels the existing `onPrimary` / `onSecondary` naming convention.

`dangerBg` (`#2A1F1F`) and `dangerBorder` (`#5C3A3A`) already exist in `AppColors` — `onDanger` is the final gap.

---

## Decision 5: `InlineDialogError` — New Shared Widget

**Decision**: Extract the inline error pill into `core/widgets/inline_dialog_error.dart` rather than building it inline inside `DeletePlanDialog`.

**Rationale**: The design spec notes that the same visual pattern (`#2a1f1f` fill, `#5c3a3a` border, danger text) is used in both SCR-09 (save failure) and SCR-11 (delete failure). Extracting it now creates the shared widget that SCR-09 would reference when it is updated. Inline implementation in SCR-11 would create a second copy and trigger the "duplicate UI" rule in CLAUDE.md §21.

**Widget signature**: `InlineDialogError({required String message})` — stateless, all colours from `AppColors.*`, text style from `theme.textTheme`.

---

## Decision 6: Navigation After Successful Deletion

**Decision**: On `DeletePlanSuccess`, the `BlocListener` in `DeletePlanDialog` calls `Navigator.pop(context, true)`. SCR-10's `_onDelete` receives `true` and calls `context.go('/plans')`.

**Rationale**: `context.go('/plans')` replaces the current navigation stack with the Plans List — SCR-10 is not retained. This is the correct go_router idiom for "pop this screen and all its children and go to a known route." Using `context.pop()` from `_onDelete` would navigate back to SCR-08 only if SCR-10 was the top of the stack, which relies on the stack shape rather than explicit intent. `context.go('/plans')` is unambiguous regardless of stack depth.

The dialog itself does not call `context.go()` directly — navigation from the presentation layer is kept at the screen level (SCR-10), not inside a dialog widget. This keeps the dialog reusable and its tests simpler (dialog tests only verify the pop result, not the navigation target).

---

## Decision 7: `PopScope` Usage During Deleting State

**Decision**: Wrap `DeletePlanDialog`'s content in `PopScope(canPop: !isDeleting)` to block Android system back during the Deleting state.

**Rationale**: The spec requires that back navigation is blocked while deletion is in flight (FR-4). `showDialog` with `barrierDismissible: false` blocks scrim taps. `PopScope` (the Flutter 3.12+ replacement for `WillPopScope`) blocks the Android system back button and iOS back swipe at the route/dialog level. Setting `canPop: false` only when `state is DeletePlanDeleting` allows back gesture in Confirmation and Failure states (treated as Cancel, which pops with `false`).

The `onPopInvokedWithResult` callback handles the Confirmation/Failure cancel: when `canPop: true` and the pop is invoked, the dialog has already returned the correct `false` result via `Navigator.pop(context, false)`.
