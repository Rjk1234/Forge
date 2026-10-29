# Research: SCR-21 Workout History Detail

**Date**: 2026-09-23 | **Branch**: `001-scr-21-workout-history-detail`

---

## D-01 — Navigation extra: `sessionId` (String) over full `WorkoutSession`

**Decision**: SCR-20 passes `session.sessionId` (a `String`) as the navigation extra when tapping a history row. SCR-21's route reads `state.extra as String` and passes it to the Bloc event.

**Rationale**: The spec's assumption said "pass the full `WorkoutSession` as extra" (written before surveying the repo). The design spec explicitly states "begin Drift read of session record on screen entry", and `WorkoutSessionRepository.getSessionById` already exists. Passing the full object would require manufacturing a fake loading state (emit Loading then immediately emit Success without any async gap), making the skeleton invisible on fast devices. A real `getSessionById` call gives the skeleton meaningful render time, properly implements FR-009 (Error state on Drift read failure), and produces authentic state transitions. Thin navigation extras (a String ID) are also more robust than passing large object graphs.

**Alternatives considered**: Passing the full `WorkoutSession` as extra (eliminated — fake loading state, cannot produce a real Error state if the read never happens).

---

## D-02 — `GetWorkoutHistoryDetailUseCase` wraps `getSessionById`

**Decision**: Introduce `GetWorkoutHistoryDetailUseCase` in `application/use_cases/`. It accepts a `sessionId` String, calls `WorkoutSessionRepository.getSessionById`, and maps the nullable result:

- `Right(WorkoutSession s)` → `Right(s)` (pass through)
- `Right(null)` → `Left(CacheException(...))` (session missing from Drift — treated as read failure)
- `Left(exception)` → `Left(exception)` (pass through)

Return type: `Future<Either<AppException, WorkoutSession>>`

**Rationale**: Following Clean Architecture, the Bloc must not call the repository directly. The use case encapsulates the null-handling logic so the Bloc only sees `Right(WorkoutSession)` or `Left(AppException)`.

**Alternatives considered**: Bloc calls repository directly (violates architecture; application layer must not import data layer).

---

## D-03 — Bloc state machine: Initial + Loading + Success + Error (no Empty)

**Decision**: Four sealed states:
- `WorkoutHistoryDetailInitial` — renders skeleton (satisfies FR-016 and constitution VII.1)
- `WorkoutHistoryDetailLoading` — renders skeleton
- `WorkoutHistoryDetailSuccess({required WorkoutSession session})` — renders full detail
- `WorkoutHistoryDetailError({required String message})` — renders error card

Single event: `WorkoutHistoryDetailLoadRequested({required String sessionId})`

Transitions: `Initial → Loading → Success | Error` and `Error → Loading (retry)`.

`WorkoutHistoryDetailEmpty` is explicitly NOT defined (FR-017): a session with zero exercises is `Success`, not Empty.

`Initial` and `Loading` render identical UI (skeleton). The BlocBuilder `switch` collapses both to the same branch.

**Rationale**: Constitution VII.1 requires defining all applicable states. Initial is applicable because there is always a brief window before the first event fires where the widget tree might render. FR-016 (added in clarify) mandates the skeleton for Initial. FR-017 rules out Empty. The state machine is the same pattern as SCR-20's (after the D1 HIGH finding fix), consistently applied.

**Alternatives considered**: Starting Bloc directly in Loading (no Initial state) — rejected, risks blank screen if widget renders before the first event.

---

## D-04 — Pure Dart date/time formatting for hero-meta

**Decision**: Pure Dart static arrays — no `intl` package (ADR-030 forbidden).

**Target format**: `"Mon, Sep 7, 2026 · 6:42 PM"` — title-case 3-letter DOW, abbreviated 3-letter month name, no leading zero on day, full year, middle dot `·` (U+00B7), 12-hour time with AM/PM.

**Static arrays** (defined as file-private constants in the Bloc or a helper):

```dart
const _dowAbbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthAbbr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
```

**Note**: SCR-21 uses title-case DOW (`'Mon'`) and abbreviated month names (`'Sep'`). SCR-20 uses UPPERCASE DOW (`'MON'`) and full month names (`'September'`). These arrays are defined separately in each respective file — no sharing, no conflict.

**12-hour formatting**: `hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12`, minute zero-padded, `amPm = date.hour < 12 ? 'AM' : 'PM'`.

**Fallback**: If `WorkoutSession.startedAt` is null (SCR-16 not yet merged), use `completedAt`. The guard is `session.startedAt ?? session.completedAt`. No UI change needed when SCR-16 lands — only remove the fallback.

**Alternatives considered**: `intl` package (forbidden per ADR-030); `DateFormat` (same package).

---

## D-05 — `ExerciseType` enum values: `timeBased`, not `time`

**Decision**: The actual enum values are `ExerciseType.weighted`, `ExerciseType.timeBased`, `ExerciseType.bodyweight`. The spec and design spec use "time" as shorthand, but the code uses `timeBased`.

All `switch` expressions in the Bloc and widgets MUST use `ExerciseType.timeBased`, not `ExerciseType.time`.

**Rationale**: Direct survey of `forge/lib/core/enums/exercise_type.dart`.

---

## D-06 — `AppColors.cyan` is the `timeBased` type-dot colour

**Decision**: `AppColors.cyan` (`0xFF7DF4FF`) is used for the `ExerciseType.timeBased` type-indicator dot. The comment in `app_colors.dart` reads "weighted exercise type badge ONLY" — this comment is **incorrect**; the design system uses `lime` for weighted exercises and `cyan` for time-based.

The type-dot colour mapping:
- `ExerciseType.weighted` → `AppColors.lime` (`0xFFC3F400`)
- `ExerciseType.timeBased` → `AppColors.cyan` (`0xFF7DF4FF`)
- `ExerciseType.bodyweight` → `AppColors.textDim` (`0xFF8A8F7A`)

No new color tokens required.

**Note for future**: The `AppColors.cyan` comment should be corrected to "time-based exercise type dot" in a separate cleanup task.

**Alternatives considered**: Hardcoding hex value directly (rejected — violates CLAUDE.md rule against hardcoded colors); adding a new token (rejected — `cyan` already exists).

---

## D-07 — 12 new `AppStrings` constants

**Decision**: Add 12 constants to `forge/lib/core/strings/app_strings.dart` under a `// SCR-21` comment block:

```dart
static const String detailScreenTitle        = 'Workout Detail';
static const String detailErrorTitle         = "Couldn't load this workout";
static const String detailErrorBody          =
    'Something went wrong reading local data. '
    'Your workout history is unaffected.';
static const String detailRetryLabel         = 'Retry';
static const String detailSectionPerformance = 'Performance';
static const String detailStatDurationLabel  = 'DURATION';
static const String detailStatExercisesLabel = 'EXERCISES';
static const String detailStatSetsLoggedLabel = 'SETS LOGGED';
static const String detailStatMinSuffix      = ' min';
static const String detailSetCountSuffix     = ' sets';
static const String detailBodyweightRepsSuffix = ' reps';
static const String detailSetSkippedLabel    = 'Skipped';
```

Usage: `'$count${AppStrings.detailSetCountSuffix}'` → `"4 sets"`.

**Alternatives considered**: Format strings with `%d` placeholders (not Dart idiom; use interpolation instead).

---

## D-08 — Widget naming to avoid collision with `ExerciseCard`

**Decision**: SCR-21's per-exercise display card is named `SessionExerciseCard` (not `ExerciseCard`). The existing `ExerciseCard` in `workout_plan/presentation/widgets/exercise_card.dart` is a stateful form widget for the create/edit plan flow — entirely different purpose.

Widget inventory for SCR-21:
- `SessionExerciseCard` — stateless; renders type dot, exercise name, set tag, set pills
- `SetPill` — stateless; renders one set pill (all four variants: weighted, bodyweight, time, skipped)
- `SessionStatBox` — stateless; renders a single labelled stat cell (label + value)
- `DetailSkeleton` — stateful; owns `AnimationController` for translate-based shimmer

**Rationale**: Clear names prevent import confusion. `SetPill` is a meaningful reusable concept (appears multiple times per screen). `SessionStatBox` may later be shared with SCR-19 when that screen is implemented.

---

## D-09 — Translate-based shimmer (vs SCR-20's position-based shimmer)

**Decision**: `DetailSkeleton` uses a translate-based shimmer: an `::after`-equivalent `AnimatedBuilder` moves a semi-transparent white overlay across the skeleton surface.

```dart
// Shimmer sweep: transforms from left-out to right-out across the widget
transform: Matrix4.translationValues(
  anim.value * totalWidth * 2 - totalWidth, 0, 0),
child: DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [
      Colors.transparent,
      const Color(0x0FFFFFFF),  // rgba(255,255,255,.06)
      Colors.transparent,
    ]),
  ),
),
```

`AnimationController` duration: `1400ms`, `repeat()`. Disposed in `dispose()`.

**Note**: SCR-20's `HistorySkeleton` uses a background-position shimmer (`LinearGradient` with animated `begin`/`end`). Both are 1.4s. These are distinct implementations — document both variants in the component library under "Skeleton / Shimmer". No sharing or refactor needed now.

**Alternatives considered**: Reusing SCR-20's shimmer pattern (could work, but design spec intentionally specified translate-based for SCR-21; keeping both as documented variants is correct).

---

## D-10 — Route: push nav under history branch; SCR-20 not a hard prerequisite

**Decision**: Add `RoutePaths.workoutHistoryDetail = '/history/detail'` to `RoutePaths` and a nested `GoRoute` under the history branch's root route. The route reads `state.extra as String` for the `sessionId`.

SCR-21's route can be added before or after SCR-20 is implemented — the history branch root can still serve `PlaceholderTabScreen(label: 'History')` while the detail route is live. SCR-20's T011 already plans to add this constant; SCR-21 must verify it exists and add it if absent (same guard pattern).

Push navigation (not a tab root): no `StatefulShellBranch` involvement for the detail screen itself. The `GoRoute` is added as a sub-route of `RoutePaths.history`.

**Alternatives considered**: Separate top-level route (rejected — breaks `StatefulShellRoute` history navigation and the back gesture to SCR-20).
