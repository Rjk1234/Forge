# Quickstart: SCR-14 Remove From Schedule Confirmation

Manual/automated validation scenarios proving the feature works end-to-end. See [data-model.md](data-model.md) for state shape and [contracts/](contracts/) for the repository/Bloc contracts these scenarios exercise.

## Prerequisites

- ForgeApp running on an Android 10+/iOS 15+ device or emulator (`flutter run` from `forge/`).
- App unlocked, at least one day has an assigned plan (via SCR-13, or seeded directly for manual testing).

## Scenario 1 — Confirm and remove (User Story 1, FR-001/FR-002/FR-007/FR-008)

1. On the weekly schedule view, tap the Remove icon on a scheduled day's row.
2. **Expect**: a dialog appears naming that plan and day, states history is unaffected, and nothing is removed yet.
3. Tap "Remove".
4. **Expect**: a brief "Removing…" state, then the dialog closes and that day now shows as unscheduled; every other day (including other days assigned to the same plan, if any) is unchanged.

## Scenario 2 — Cancel from confirmation (User Story 2, FR-004)

1. Open the confirmation dialog for a scheduled day.
2. Tap "Cancel".
3. **Expect**: the dialog closes; that day's assignment is unchanged.

## Scenario 3 — Dismiss via scrim / back gesture (User Story 2, FR-004)

1. Open the confirmation dialog.
2. Tap outside the dialog (or use the OS back gesture) instead of tapping a button.
3. **Expect**: the dialog closes; nothing changes.

## Scenario 4 — Removal failure and retry (User Story 3, FR-009)

1. Simulate a Drift write failure for the `schedule_entries` table (or exercise the automated equivalent in `remove_schedule_entry_bloc_test.dart`).
2. Open the dialog and tap "Remove".
3. **Expect**: an inline error appears stating nothing was removed and retrying won't duplicate anything; the assignment is still present; Cancel remains tappable.
4. Restore normal Drift access, tap "Retry".
5. **Expect**: the removal succeeds and the dialog closes with the day now unscheduled.

## Scenario 5 — Cancel after a failure (User Story 2 + 3, FR-004/FR-009)

1. Trigger Scenario 4 up through the error state.
2. Tap "Cancel" instead of "Retry".
3. **Expect**: the dialog closes; the assignment is still present (nothing was ever removed).

## Scenario 6 — Dismissal locked while removing (FR-006)

1. Trigger a removal (ideally with an artificially slowed Drift write, or via the widget-test equivalent).
2. While "Removing…" is visible, attempt to tap Cancel, tap the scrim, or use the back gesture.
3. **Expect**: none of these have any effect until the removal completes or fails.

## Scenario 7 — Removing the only scheduled day (Edge Case)

1. Ensure exactly one day has an assignment.
2. Remove it via Scenario 1.
3. **Expect**: the weekly schedule view now shows its fully-empty state.

## Automated equivalents

- Scenarios 1, 4, 5 → `test/features/schedule/data/repositories/schedule_repository_impl_test.dart` (mocktail) and `test/features/schedule/application/bloc/remove_schedule_entry_bloc_test.dart` (bloc_test).
- Scenarios 2, 3, 6 → `test/features/schedule/presentation/widgets/remove_schedule_entry_dialog_test.dart` (widget tests asserting `Navigator.pop` calls and `PopScope.canPop`).
- Scenario 7 depends on SCR-12's own empty-state rendering (already covered by SCR-12's own test suite) — this feature only needs to confirm the delete succeeds.

## Definition of Done for this quickstart

All 7 scenarios pass manually on at least one Android and one iOS device/emulator (Principle XI.5), and their automated equivalents pass in `flutter test`.
