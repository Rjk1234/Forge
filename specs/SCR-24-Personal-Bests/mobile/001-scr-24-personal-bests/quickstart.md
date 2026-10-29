# Quickstart Validation Guide: SCR-24 Personal Bests

**Feature**: SCR-24 Personal Bests  
**Date**: 2026-09-23  
**References**: [spec.md](spec.md) | [data-model.md](data-model.md) | [contracts/pb-bloc.md](contracts/pb-bloc.md)

---

## Prerequisites

- Flutter app running on a simulator or device (Android API 29+ or iOS 15+)
- `workout_sessions` table accessible
- SCR-23 Statistics Dashboard route (`/stats`) implemented so the Personal Bests link row navigates to `/stats/personal-bests`

> If SCR-23 is not yet implemented, navigate directly to `/stats/personal-bests` via `context.go` in a debug entry point.

---

## Setup Commands

```bash
cd forge
flutter run
```

---

## Validation Scenarios

### VS-01: Loading Skeleton Appears Immediately

**Seed**: ≥1 valid `WorkoutSession` in the Drift table (`completedAt != null`, ≥1 non-skipped set).

**Steps**:
1. Navigate to SCR-23 (`/stats`)
2. Tap the Personal Bests link row

**Expected**:
- SCR-24 pushes instantly with no bottom navigation bar
- 5 skeleton rows appear immediately (no blank frame between push and skeleton)
- Each skeleton row shows: circular dot placeholder, two shimmer lines, badge placeholder
- After shimmer, skeleton resolves to the populated list

**Validates**: SC-001, FR-001, FR-015

---

### VS-02: Populated List — Correct PB Values

**Seed**:
- Session A: Exercise "Bench Press" (weighted), Set 1: weight=80.0kg, Set 2: weight=85.0kg, skipped=false; completedAt=2026-08-01
- Session B: Exercise "Bench Press" (weighted), Set 1: weight=87.5kg; completedAt=2026-09-01

**Steps**:
1. Navigate to SCR-24

**Expected**:
- "Bench Press" pb-card appears
- Badge shows `"87.5 kg"` (one decimal — not whole number)
- Date shows `"Set Sep 1, 2026"`
- Badge label shows `"BEST WEIGHT"`
- Type dot is lime-colored (weighted convention)

**Validates**: SC-002, SC-003, FR-004 (max weight, tie-break by date), FR-006, FR-007, FR-008

---

### VS-03: All Three Exercise Types Display Correctly

**Seed**:
- Session A: 
  - "Squat" (weighted): weight=100.0, completedAt=2026-08-15
  - "Plank" (timeBased): durationSec=90, completedAt=2026-08-15
  - "Push-Up" (bodyweight): repetitions=25, completedAt=2026-08-15

**Steps**:
1. Navigate to SCR-24

**Expected**:
- "Plank" pb-card: badge shows `"01:30"`, label `"BEST TIME"`, dot is cyan
- "Push-Up" pb-card: badge shows `"25"`, label `"BEST REPS"`, dot is muted
- "Squat" pb-card: badge shows `"100 kg"` (integer — whole number), label `"BEST WEIGHT"`, dot is lime
- List order: Plank, Push-Up, Squat (alphabetical ascending)

**Validates**: SC-002, FR-006, FR-007, FR-008 (all three types)

---

### VS-04: Valid-Session Filter (Skipped Sets Excluded)

**Seed**:
- Session A: "Curl" (weighted): weight=30.0kg, skipped=true; completedAt=2026-08-01
- Session B: "Curl" (weighted): weight=25.0kg, skipped=false; completedAt=2026-09-01

**Steps**:
1. Navigate to SCR-24

**Expected**:
- "Curl" pb-card appears with badge `"25 kg"` — NOT `"30 kg"` (skipped set excluded)

**Validates**: FR-004 (valid set guard: skipped != true)

---

### VS-05: Empty State

**Seed**: Empty `workout_sessions` table, OR all sessions have `completedAt == null`, OR all sets have `skipped=true`.

**Steps**:
1. Navigate to SCR-24

**Expected**:
- Skeleton flashes briefly
- Empty state resolves with:
  - 52×52 dim trophy icon (decorative; screen reader skips it)
  - Heading: "No personal bests yet"
  - Subtitle: "Complete a workout to start setting personal bests."
  - No CTA button
- Appbar title "Personal Bests" present; back arrow functional

**Validates**: US2 AC-1–AC-6, FR-010

---

### VS-06: Error State and Retry

**Setup**: Inject a failure in `GetPersonalBestsUseCase.call()` (e.g. mock repository returns `Left(AppException(...))`).

**Steps**:
1. Navigate to SCR-24
2. Observe error state
3. Tap "Retry"
4. Observe skeleton, then outcome state

**Expected — error state**:
- Alert-triangle icon (40×40, danger color)
- Title: "Couldn't load your personal bests"
- Body: "Something went wrong calculating this data.\nYour workout history is unaffected."
- "Retry" button present (≥44pt touch target)
- Appbar + back arrow present and functional

**Expected — after Retry**:
- Skeleton appears
- Resolves to Main or Empty state depending on Drift content

**Validates**: SC-004, FR-011, FR-012, US3 AC-1–AC-6

---

### VS-07: Retry Debounce — Double-Tap

**Setup**: Same as VS-06; slow down the use case artificially.

**Steps**:
1. Navigate to error state
2. Tap Retry twice rapidly

**Expected**:
- Only one read + calculation cycle is triggered (one skeleton transition)
- No duplicate events in Bloc

**Validates**: FR-012 (debounce guard)

---

### VS-08: On-Entry Recalculation

**Seed**: 1 valid session; navigate to SCR-24, see existing PB, then pop back to SCR-23.

**Steps**:
1. Complete a second session that beats the existing PB (simulate by modifying Drift directly or via app flow)
2. Navigate to SCR-24 again (new push)

**Expected**:
- The updated (higher) PB value is shown — on-entry recalculation fires automatically
- No stale cached value from prior visit

**Validates**: SC-007, FR-016

---

### VS-09: 20+ Exercises — No ANR

**Seed**: ≥20 completed workout sessions, each with multiple exercises across all three types.

**Steps**:
1. Navigate to SCR-24 on Android API 29 emulator

**Expected**:
- Screen resolves without ANR dialog
- All PBs computed and displayed; list scrollable; appbar fixed

**Validates**: SC-006

---

### VS-10: No Bottom Nav Bar

**Steps**:
1. Navigate from SCR-23 to SCR-24

**Expected**: No bottom navigation bar visible in any of the four states (Loading, Empty, Main, Error).

**Validates**: FR-014, US1 AC-11

---

## Zero Drift Writes Verification

After navigating through SCR-24 in all states (VS-01 through VS-09), verify via debug tooling that zero Drift write operations occurred on the `workout_sessions` table.

**Validates**: SC-005, FR-003
