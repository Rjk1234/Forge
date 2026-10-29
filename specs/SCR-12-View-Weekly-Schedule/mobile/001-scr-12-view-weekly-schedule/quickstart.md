# Quickstart: SCR-12 View Weekly Workout Schedule

Manual/automated validation scenarios proving the feature works end-to-end. See [data-model.md](data-model.md) for entity shapes and [contracts/](contracts/) for the repository/Bloc contracts these scenarios exercise.

## Prerequisites

- ForgeApp running on an Android 10+/iOS 15+ device or emulator (`flutter run` from `forge/`).
- App unlocked (past SCR-03 login).
- At least one workout plan exists (via SCR-09) if testing the populated path; none if testing the empty path.

## Scenario 1 — Populated week (User Story 1, FR-003)

1. Create a workout plan (e.g. "Push Day") via the Plans tab.
2. Assign it to today's weekday and one other weekday (once SCR-13 exists; until then, seed `schedule_entries` table directly for manual testing per `contracts/schedule-repository.md`).
3. Open the Schedule tab.
4. **Expect**: skeleton rows appear briefly, then all 7 days render Monday→Sunday; the two assigned days show the plan name and "Weekly"; the other 5 show "Rest day".

## Scenario 2 — Today with a plan, Start action (User Story 2, FR-004, FR-005)

1. With today's weekday assigned a plan (Scenario 1 setup).
2. Open the Schedule tab.
3. **Expect**: today's row is visually distinguished (lime border/background) and shows a "Start" button instead of an edit icon; plan meta reads "Weekly · Today".
4. Tap "Start".
5. **Expect**: navigates toward the workout pre-start flow for that plan (SCR-15 — see research.md Decision 5 for current stub behavior if SCR-15 is not yet implemented).

## Scenario 3 — Today with no plan (Edge Case)

1. Ensure today's weekday has no schedule entry, but at least one other day does.
2. Open the Schedule tab.
3. **Expect**: today's row is highlighted but shows "Rest day" and an edit icon, not a Start button.

## Scenario 4 — Empty state (User Story 3, FR-002)

1. Ensure `schedule_entries` table has zero entries (fresh install or all entries removed).
2. Open the Schedule tab.
3. **Expect**: centered empty state — "No workouts scheduled", subtitle, and a "Schedule a plan" button.
4. Tap "Schedule a plan".
5. **Expect**: navigates toward the schedule-assignment flow (SCR-13).

## Scenario 5 — Load failure and retry (User Story 4, FR-007)

1. Simulate a Drift read failure for the `schedule_entries` table (e.g. temporarily make the database unavailable in a debug build, or use the repository unit test in `contracts/schedule-repository.md` as the automated equivalent).
2. Open the Schedule tab.
3. **Expect**: error card — "Couldn't load your schedule" + reassurance that plans/history are unaffected + "Retry" button.
4. Restore normal Drift access, tap "Retry".
5. **Expect**: transitions to Loading, then to Populated or Empty based on actual data.

## Scenario 6 — Orphaned plan reference (FR-009)

1. Assign a plan to a weekday, then delete that plan via SCR-11 (Delete Plan).
2. Open the Schedule tab.
3. **Expect**: that weekday now shows "Rest day", not an error and not the deleted plan's name.
4. Re-open the Schedule tab a second time.
5. **Expect**: same result (the orphaned entry was cleaned up on first read, per `contracts/schedule-repository.md` Decision 2 — no duplicate cleanup errors on the second read).

## Automated equivalents

- Scenarios 1–3, 6 → `test/features/schedule/data/repositories/schedule_repository_impl_test.dart` (mocktail, see contract test table).
- Scenarios 1, 4, 5 → `test/features/schedule/application/bloc/week_schedule_bloc_test.dart` (bloc_test, see contract test table).
- All 4 states' rendering → `test/features/schedule/presentation/screens/weekly_schedule_screen_test.dart` (widget tests, one per Bloc state).

## Definition of Done for this quickstart

All 6 scenarios pass manually on at least one Android and one iOS device/emulator (Principle XI.5), and their automated equivalents pass in `flutter test`.
