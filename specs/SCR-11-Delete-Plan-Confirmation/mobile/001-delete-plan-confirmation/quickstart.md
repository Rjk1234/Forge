# Quickstart Validation: Delete Plan Confirmation (SCR-11)

**Date**: 2026-09-19 | **Feature**: SCR-11

---

## Prerequisites

- iOS Simulator or Android Emulator booted and running
- `forge/` Flutter project builds cleanly (`flutter build apk --debug` or `flutter run`)
- Drift seed data present (at least one workout plan with exercises and a schedule assignment)
- SCR-10 (Plan Detail screen) is working (navigate to a plan from SCR-08)

---

## Seeding Test Data

Seed via the app's existing seed mechanism or by manually inserting records in `main.dart` / `bootstrap.dart`:

```dart
// Seed a plan
final plan = WorkoutPlanRecord(
  planId: 'test-plan-1',
  name: 'Delete Me Plan',
  exercises: [],
  createdAt: DateTime.now(),
);
// Insert-or-replace into the `workout_plans` table via the data source
await workoutPlanLocalDataSource.savePlan(plan);

// Seed a schedule entry referencing the plan
final entry = ScheduleEntryRecord(weekday: 1, planId: 'test-plan-1', planName: 'Delete Me Plan');
// Insert-or-replace into the `schedule_entries` table via the data source
await scheduleLocalDataSource.saveEntry(entry);
```

---

## Validation Scenarios

### VS-01 — Dialog Opens with Correct Content

1. Navigate to "Delete Me Plan" on SCR-10
2. Tap the Delete (trash) icon in the app bar
3. **Expected**: Modal dialog appears over SCR-10 (background visible but non-interactive)
4. **Expected**: Dialog shows trash icon (red), title "Delete this workout plan?", subtitle containing `"Delete Me Plan"` and mentioning schedule removal and session preservation
5. **Expected**: Two buttons visible — "Cancel" (left, dark background) and "Delete" (right, red background with dark text)

---

### VS-02 — Cancel Dismisses Without Deleting

1. Open the dialog (VS-01)
2. Tap "Cancel"
3. **Expected**: Dialog closes; SCR-10 remains visible; plan still exists in Drift

**Verify**: Open database inspector or navigate to SCR-08 — "Delete Me Plan" is still listed.

---

### VS-03 — Scrim Tap Acts as Cancel

1. Open the dialog (VS-01)
2. Tap the dark scrim area outside the dialog card
3. **Expected**: Dialog closes; plan unchanged (same as VS-02)

---

### VS-04 — Delete Triggers Loading State

1. Open the dialog (VS-01)
2. Tap "Delete"
3. **Expected**: Button label changes to spinner + "Deleting…" (red background, slightly dimmed)
4. **Expected**: "Cancel" button appears dimmed (50% opacity) and does not respond to taps
5. **Expected**: Tapping the scrim does nothing

*(If Drift write is too fast to observe, add a short `Future.delayed(Duration(seconds: 2))` before the delete call during development.)*

---

### VS-05 — Successful Delete Navigates to Plans List

1. Open the dialog (VS-01)
2. Tap "Delete" and wait for completion
3. **Expected**: Dialog closes
4. **Expected**: App navigates directly to SCR-08 (Plans List)
5. **Expected**: "Delete Me Plan" is no longer listed on SCR-08
6. **Expected**: SCR-10 is not visible or accessible via back navigation

---

### VS-06 — Schedule Entries Removed

After VS-05 completes:
1. Navigate to the Schedule tab (SCR-12 or placeholder)
2. **Expected**: Monday is no longer assigned "Delete Me Plan"

OR verify via database inspector: `schedule_entries` row with weekday=1 is absent.

---

### VS-07 — Historical Sessions Preserved

After VS-05 (with sessions seeded for the plan):
1. Navigate to Workout History (SCR-16 or inspect Drift directly)
2. **Expected**: Sessions that referenced `test-plan-1` are still present in the `workout_sessions` table

---

### VS-08 — Delete Failure Shows Error State

*(Requires simulating a Drift write failure — easiest via a `_FakeFailingRepo` in tests; manual simulation requires temporarily overriding `WorkoutPlanLocalDataSourceImpl.deletePlan` to throw an exception.)*

1. Override `deletePlan` to throw `Exception('simulated failure')`
2. Open dialog, tap Delete
3. **Expected**: After short delay, dialog shows inline error message: "Couldn't delete the plan — something went wrong writing to local storage. Nothing was removed."
4. **Expected**: "Cancel" button is restored (enabled, full opacity)
5. **Expected**: Right button is now "Retry" with lime background

---

### VS-09 — Retry After Failure Succeeds

1. Reach error state (VS-08)
2. Restore normal `deletePlan` behaviour (remove failure override)
3. Tap "Retry"
4. **Expected**: Dialog transitions back to loading state (spinner)
5. **Expected**: On success, dialog closes and app navigates to SCR-08

---

### VS-10 — Cancel from Error State

1. Reach error state (VS-08)
2. Tap "Cancel"
3. **Expected**: Dialog closes; SCR-10 visible; plan unchanged in Drift

---

### VS-11 — Back Gesture During Confirmation (iOS)

1. Open dialog (VS-01)
2. Swipe from the left edge (iOS back gesture)
3. **Expected**: Dialog closes (same as Cancel)

---

### VS-12 — Back Gesture Blocked During Deleting (iOS)

1. Slow down the Drift write so dialog stays in loading state
2. Swipe from the left edge during loading state
3. **Expected**: Nothing happens — dialog remains open

---

### VS-13 — Very Long Plan Name in Subtitle

1. Create a plan with a name of 80+ characters
2. Open the delete dialog for it
3. **Expected**: Subtitle text wraps across multiple lines; dialog card grows in height; no text is truncated or overflowed outside the card

---

### VS-14 — Android System Back During Deleting

1. (Android only) Slow down the Drift write
2. During loading state, press the Android system back button
3. **Expected**: Nothing happens — dialog remains open

---

### VS-15 — Plan-Not-Found Treated as Success

1. Seed a plan, open its detail screen (SCR-10)
2. Before tapping Delete, manually delete the plan from Drift via another mechanism (or test-only code)
3. Tap Delete on the already-open dialog
4. **Expected**: Dialog closes and app navigates to SCR-08 (plan not found is treated as successful deletion)

---

## Running Tests

```bash
cd forge
flutter test test/features/workout_plan/application/bloc/delete_plan_bloc_test.dart
flutter test test/features/workout_plan/presentation/widgets/delete_plan_dialog_test.dart
flutter test test/features/workout_plan/
```

All tests must pass with zero new analyzer warnings:
```bash
flutter analyze
dart format . --set-exit-if-changed
```
