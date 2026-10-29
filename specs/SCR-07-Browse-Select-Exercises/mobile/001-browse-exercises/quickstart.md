# Quickstart Validation Guide: SCR-07 Browse & Select Exercises

**Branch**: `001-browse-exercises` | **Date**: 2026-09-17

This guide provides runnable validation scenarios that prove the exercise catalogue feature works end-to-end. All scenarios run inside the `forge/` Flutter project.

---

## Prerequisites

1. FVM Flutter installed and `fvm use` run in the `forge/` directory.
2. An iOS Simulator or Android Emulator booted.
3. `ExerciseSeedService` runs at app launch — the exercise catalogue is pre-populated with seeded exercises on first run.
4. The app is at the logged-in (unlocked) state before starting any scenario.

---

## Setup & Build

```bash
cd forge
fvm flutter pub get
fvm flutter run
```

Navigate to the Plans tab after launch. The Plans tab currently shows a placeholder. Once SCR-07 is implemented, a "Browse Exercises" entry point will be available from the Plans screen.

---

## Validation Scenarios

### VS-01 — Browse Mode: Catalogue Loads with Skeleton then Populates

**Entry**: Plans tab → tap "Browse Exercises" (or navigate to `/plans/exercises`).

**Expected loading state** (visible for < 2 seconds):
- App bar shows "Exercise Catalogue" with back icon.
- 6 skeleton rows visible with shimmer animation.
- 4 skeleton filter chip placeholders visible.
- Search bar visible but not focusable.

**Expected populated state**:
- Full seeded exercise list renders.
- Each row shows: exercise name (white, 700 weight), type-coloured dot (7 px circle), type label (muted).
- "All" filter chip is active (lime background, dark text); other chips are inactive.
- No picker banner visible.
- Each row shows a chevron-right icon (decorative — tapping the row does nothing, FR-014).

**Pass**: Skeleton → full list transition completes within 2 seconds; 0 blank frames.

---

### VS-02 — Browse Mode: Search Filters List

**Entry**: From VS-01 populated state.

1. Tap the search field.
2. Type `"bench"`.

**Expected**: List narrows to exercises whose names contain "bench" (case-insensitive). Search field border and icon turn lime.

3. Clear the field (tap ×).

**Expected**: Full catalogue list restores for the active filter.

**Pass**: Live filtering updates on every keystroke (with ≤300 ms debounce); clear restores correctly.

---

### VS-03 — Browse Mode: Filter Chip Narrows List

**Entry**: From VS-01 populated state.

1. Tap the "Weighted" chip.

**Expected**: Only weighted exercises shown; "Weighted" chip becomes active (lime).

2. Tap "All".

**Expected**: Full list restored; "All" becomes active.

3. Tap "Time-based".

**Expected**: Only time-based exercises shown.

**Pass**: Exactly one chip active at all times; list updates immediately on each chip tap.

---

### VS-04 — Browse Mode: Search + Filter Combined

**Entry**: From VS-01 populated state.

1. Tap "Weighted" chip.
2. Type `"press"` in search field.

**Expected**: Only weighted exercises whose names contain "press" are shown.

3. Clear search.

**Expected**: All weighted exercises restore (filter chip still active).

**Pass**: Combined search+filter operates correctly; clearing search does not clear the type filter.

---

### VS-05 — Browse Mode: Empty State

**Entry**: From VS-01 populated state.

1. Type a search string that matches no exercises (e.g. `"zzzzz"`).

**Expected**:
- Exercise list area replaced by centred empty state.
- Magnifier-with-minus icon visible.
- Title: "No exercises match your search".
- Subtitle: "Try a different name or clear the filter."
- No CTA button.

**Pass**: Empty state renders exactly; filter chips remain interactive.

---

### VS-06 — Browse Mode: Back Navigation

**Entry**: From VS-01 populated state.

1. Tap the back icon (chevron-left in app bar).

**Expected**: Screen slides out; user returns to the previous screen (Plans tab or wherever they navigated from). Bottom nav bar reappears.

**Pass**: Back navigation works from all 5 screen states (Loading, Populated, Empty, Error, and also from Picker mode).

---

### VS-07 — Picker Mode: Banner and "+" Button

**Entry**: From SCR-09 Create/Edit Workout Plan — tap "Add exercise" (once SCR-09 is implemented, or navigate to `/plans/exercises` with `extra: PickerContext(planName: 'Push Day')` in code).

**Expected loaded state**:
- Picker banner visible below app bar: "Adding an exercise to **Push Day**" (cyan icon, muted text, bold white plan name).
- Each exercise row shows a circular "+" button (28 px lime circle, dark "+" icon) instead of a chevron.
- Row itself is tappable only at the "+" button; the row body has no InkWell ripple.

**Pass**: Banner visible with correct plan name; "+" button visible on each row.

---

### VS-08 — Picker Mode: Add Exercise and Return

**Entry**: From VS-07 picker mode populated state.

1. Optionally search or filter to locate a specific exercise.
2. Tap the "+" button on any exercise row.

**Expected**:
- Screen immediately pops back to SCR-09 (plan editor).
- SCR-09's exercise list shows the newly added exercise at the bottom.
- No confirmation dialog.

**Pass**: Exercise added and navigation completes in ≤ 1 second from tap.

---

### VS-09 — Picker Mode: Back Without Selecting

**Entry**: From VS-07 picker mode populated state.

1. Tap back icon without tapping any "+".

**Expected**: Screen pops to SCR-09. Plan editor's exercise list is unchanged (no exercise added).

**Pass**: No accidental exercise addition; back navigation available from all picker states.

---

### VS-10 — Error State: Retry Cycle

**How to trigger** (requires a test-only override or forced database error in the data source — not testable on a production build without a test helper; validate via unit tests in `exercise_catalogue_bloc_test.dart`):

**Expected error state**:
- Search bar and filter chips absent.
- Error card visible: "Couldn't load the exercise catalogue" (title) + "Something went wrong reading local data." (body).
- Retry button visible (lime fill, dark text).

**Expected retry behavior**:
- Tap Retry → screen returns to Loading (skeleton) state.
- If retry succeeds → Populated state.
- Back icon remains functional in error state.

**Pass**: Error card renders with correct copy; Retry loops correctly; back available.

---

## Automated Test Verification

Run all tests before claiming implementation complete:

```bash
cd forge
dart format .
flutter analyze
flutter test
```

Expected results after full implementation:
- **0 new analyzer errors** (2 pre-existing `prefer_initializing_formals` info items acceptable)
- **All new tests pass** (see test files in `test/features/exercise/`)
- **50+ total tests pass** (existing suite + new exercise tests)

Key test files to verify:
- `test/features/exercise/domain/entities/exercise_test.dart`
- `test/features/exercise/application/bloc/exercise_catalogue_bloc_test.dart`
- `test/features/exercise/application/usecases/get_exercises_usecase_test.dart`
- `test/features/exercise/data/repositories/exercise_repository_impl_test.dart`
- `test/features/exercise/data/mappers/exercise_mapper_test.dart`
- `test/features/exercise/presentation/screens/exercise_catalogue_screen_test.dart`
