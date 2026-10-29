# Quickstart: SCR-13 Assign / Edit Schedule

Manual/automated validation scenarios proving the feature works end-to-end. See [data-model.md](data-model.md) for entity/state shapes and [contracts/](contracts/) for the repository/Bloc contracts these scenarios exercise.

## Prerequisites

- ForgeApp running on an Android 10+/iOS 15+ device or emulator (`flutter run` from `forge/`).
- App unlocked, at least one workout plan exists (via SCR-09).

## Scenario 1 — New assignment (User Story 1, FR-001/FR-002)

1. From a plan's detail screen, tap "Schedule" (existing button — already wired to `/plans/:planId/schedule`).
2. **Expect**: app bar reads "New Schedule"; no day chip is selected; Save is disabled.
3. Tap an unoccupied day.
4. **Expect**: chip turns selected (lime); Save becomes enabled.
5. Tap Save.
6. **Expect**: brief saving state, then return to the plan/weekly schedule; the plan now appears on that day.

## Scenario 2 — Edit an existing assignment (User Story 2, FR-003)

1. Navigate to a plan already scheduled on specific days (via its detail screen's "Schedule" button, or SCR-12's edit icon once implemented).
2. **Expect**: app bar reads "Edit Schedule"; those days are pre-selected; Save is already enabled.
3. Add or remove a day, then Save.
4. **Expect**: the updated day set is reflected wherever the schedule is viewed.

## Scenario 3 — Conflict detection (User Story 3, FR-004/FR-005)

1. Ensure a day is already assigned to Plan A (via Scenario 1).
2. Open the assignment screen for a different Plan B, and tap that same day.
3. **Expect**: the day is flagged (red/conflict style), an inline message names Plan A, and Save is disabled.
4. Deselect that day.
5. **Expect**: the conflict clears and Save re-enables (if at least one other day is selected).
6. Re-open Plan A's own assignment (which owns that day) and confirm that day is never shown as conflicting against itself.

## Scenario 4 — Save failure and retry (User Story 4, FR-008)

1. Simulate a Drift write failure for the `schedule_entries` table (or exercise the automated equivalent in `assign_schedule_bloc_test.dart`).
2. Select valid days and tap Save.
3. **Expect**: an error banner reading "Couldn't save your schedule" with reassurance nothing changed; day selection remains exactly as entered.
4. Restore normal Drift access, tap "Retry Save".
5. **Expect**: the save succeeds and the screen returns to the previous screen.

## Scenario 5 — Invalid plan recovery (User Story 5, FR-009)

1. Schedule Plan A on a day (Scenario 1), then delete Plan A entirely (SCR-11, once implemented — or seed the Drift state directly for manual testing).
2. Re-open the assignment screen for Plan A's `planId` (e.g., via a stale deep-link/back-stack entry).
3. **Expect**: the plan selector is replaced with "This plan is no longer available"; day selection is disabled; Save is disabled.
4. Navigate back and pick a different, valid plan via the Plans List → Plan Detail → "Schedule" journey.
5. **Expect**: the screen now behaves as a fresh New Schedule assignment for that plan.

## Scenario 6 — Cancel without saving (Edge Case)

1. Open the assignment screen for any plan, make some chip selections, then navigate back without tapping Save.
2. **Expect**: no change to any existing schedule entry; the plan's schedule (if any) is exactly as it was before opening this screen.

## Scenario 7 — Back navigation locked during save (FR-010)

1. Trigger a save (ideally with an artificially slowed Drift write, or via the widget-test equivalent).
2. While the saving state is visible, attempt back navigation (button or OS gesture).
3. **Expect**: navigation is blocked until the save completes or fails.

## Automated equivalents

- Scenarios 1–3, 5 → `test/features/schedule/data/repositories/schedule_repository_impl_test.dart` (mocktail, see contract test table) and `test/features/schedule/application/bloc/assign_schedule_bloc_test.dart` (bloc_test).
- Scenario 4 → `assign_schedule_bloc_test.dart` save-failure/retry cases.
- Scenario 6 → covered implicitly by the Bloc never being asked to save unless `SaveRequested` fires; no dedicated test needed beyond confirming no repository write methods are called before that event.
- Scenario 7 → `test/features/schedule/presentation/screens/assign_schedule_screen_test.dart` (widget test asserting `PopScope.canPop` during `AssignScheduleSaving`).

## Definition of Done for this quickstart

All 7 scenarios pass manually on at least one Android and one iOS device/emulator (Principle XI.5), and their automated equivalents pass in `flutter test`.
