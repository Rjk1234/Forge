# Research: SCR-24 Personal Bests

**Feature**: SCR-24 Personal Bests  
**Date**: 2026-09-23  
**Status**: Complete — all decisions resolved

---

## D-01: Route Registration Pattern

**Decision**: Child `GoRoute` nested under the `/stats` branch in `app_routes.dart`.

**Rationale**: GoRouter's `StatefulShellBranch` for the stats tab (Branch 5) already registers `RoutePaths.stats = '/stats'` with a `_statsNavigatorKey`. Pushed detail screens in ForgeApp are nested child routes of their parent tab, not standalone GoRoute registrations. The full path `/stats/personal-bests` is achieved by adding a `routes:` list to the stats `GoRoute` with a child whose `path = RoutePaths.personalBests` (relative, e.g. `'personal-bests'`).

**Route constant**: `RoutePaths.personalBests = 'personal-bests'` (relative child of `/stats`). Navigation: `context.push('/stats/personal-bests')` or `context.go(...)` from SCR-23.

**BlocProvider wrapper**:
```dart
GoRoute(
  path: RoutePaths.personalBests,
  builder: (context, state) => BlocProvider(
    create: (_) => getIt<PbBloc>()..add(PbLoadRequested()),
    child: const PersonalBestsScreen(),
  ),
),
```

**`registerFactory` rationale**: The `BlocProvider.create` fires a fresh `PbLoadRequested` each time the route is pushed, which gives on-entry recalculation (FR-016). `registerFactory` ensures each push gets a new Bloc instance with fresh state.

**Alternatives considered**: A named route at the root level (not nested) — rejected because it would break the shell branch navigator key and the `StatefulShellScaffold` bottom nav bar would remain visible, violating FR-014 (no bottom nav bar on SCR-24). Nesting under `/stats` suppresses the shell tab bar when the child is pushed.

---

## D-02: Type Dot Color Convention

**Decision**: Follow the design spec convention — `lime` for `weighted`, `cyan` for `timeBased`, `textMuted` for `bodyweight` — for the `PbTypeDot` widget in SCR-24.

**Rationale**: The SCR-24 spec FR-006 explicitly states "lime for weighted, cyan for timeBased, muted for bodyweight". The existing `_TypeDot` in `exercise_list_item.dart` has the INVERSE mapping (weighted→cyan, timeBased→lime) — this is a pre-existing inconsistency in the codebase, not a design authority. The design spec is the authoritative source for SCR-24.

**Impact**: `PbTypeDot` is a new widget; no existing widget is modified. The existing `_TypeDot` inconsistency is out of scope for this feature.

**Size**: 8×8 px per FR-006 (existing `_TypeDot` uses 7×7 — do not reuse it as-is).

**Alternatives considered**: Reusing `_TypeDot` — rejected because (a) it is private to `exercise_list_item.dart`, (b) its color mapping is opposite to the design spec, (c) its size is 7×7 not 8×8.

---

## D-03: Formatter Utilities

**Decision**: Create `forge/lib/core/utils/format_utils.dart` with three static display-formatting methods. `DurationMmSsInputFormatter.formatFromSeconds` is reused for MM:SS formatting.

**Rationale**: Weight formatting logic exists only as a private `_formatWeight` method inside `plan_exercise_detail_card.dart` — it cannot be imported. A shared `FormatUtils` utility avoids duplication across SCR-23 and SCR-24, which both need weight and potentially duration display formatting.

**`FormatUtils` API**:
```dart
class FormatUtils {
  // "{N} kg" — integer if whole (e.g. "65 kg"), one decimal if fractional (e.g. "62.5 kg")
  static String formatWeight(double kg);

  // "Set {Mon} {D}, {YYYY}" — e.g. "Set Aug 31, 2026"
  static String formatPbDate(DateTime date);

  // "MM:SS" — delegates to DurationMmSsInputFormatter.formatFromSeconds
  static String formatMmSs(int totalSeconds);
}
```

`formatPbDate` uses `AppStrings.shortMonthNames[date.month - 1]` for the three-letter month abbreviation. No `intl` package (ADR-030).

**Alternatives considered**: Feature-scoped `pb_format_utils.dart` — rejected because SCR-23 also needs weight formatting; sharing avoids duplication per CLAUDE.md §5. Extending the existing `DecimalOneDigitInputFormatter` — rejected because it is an input formatter, not a display formatter.

---

## D-04: Month Name Array

**Decision**: Add `static const List<String> shortMonthNames` to `AppStrings` alongside the existing `weekdayAbbreviations` list.

**Rationale**: No month abbreviation array exists in the codebase. `AppStrings` already owns `weekdayAbbreviations` and `weekdayFullNames` — month names fit the same pattern. Placing it in `AppStrings` keeps all localisation-relevant string constants in one file (consistent with CLAUDE.md §36).

**Value**: `['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']`

**Alternatives considered**: Hardcode in `FormatUtils` — rejected because CLAUDE.md §36 prohibits hardcoded user-facing strings in non-string-constant files. Inline in each widget — rejected (violates §38 scatter rule).

---

## D-05: PbBloc Structure

**Decision**: 1 event (`PbLoadRequested`), 4 states (`PbInitial`, `PbLoading`, `PbLoaded`, `PbError`), following the same sealed-class pattern as `StatsBloc` (SCR-23).

**State transitions**:
```
PbInitial → (BlocProvider fires PbLoadRequested on screen mount)
PbLoading → PbLoaded(records: List<PersonalBestRecord>)  if success
PbLoading → PbError                                       if exception
PbError   → PbLoading                                     on Retry (user taps)
```

**Empty vs Main branching**: `PbLoaded` carries `records: List<PersonalBestRecord>`. In `PersonalBestsScreen._buildBody`:
- `records.isEmpty` → render `PbEmptyState`
- `records.isNotEmpty` → render scrollable `PbCard` list

`PbInitial` renders identically to `PbLoading` (skeleton) — no blank frame (FR-015).

**`PbLoadRequested` serves both initial load and Retry** — no separate event needed.

---

## D-06: GetPersonalBestsUseCase Algorithm

**Decision**: Single-pass algorithm iterating sessions → exercises → sets, accumulating per (exerciseName, type) best values with date tracking.

**Algorithm**:
```
1. sessions = await repository.getAllSessions()  →  Either<AppException, List<WorkoutSession>>
2. sessions.fold(left: throw AppException, right: compute)
3. Map<(String exerciseName, ExerciseType type), _PbAccumulator> accumulator = {}
4. For each session where session.completedAt != null:
     For each sessionExercise in session.sessionExercises:
       For each actualSet in sessionExercise.actualSets where (actualSet.skipped != true):
         key = (sessionExercise.exerciseName, sessionExercise.type)
         acc = accumulator[key] ?? _PbAccumulator()
         update acc with (actualSet, session.completedAt!)
         accumulator[key] = acc
5. Convert accumulator → List<PersonalBestRecord>
6. Sort by exerciseName ascending (case-insensitive)
7. Return sorted list
```

**`_PbAccumulator` per-type logic** (private helper in use case file):
- `weighted`: track max `weight`; tie on weight → take more recent `completedAt`
- `timeBased`: track max `durationSec`; same tie-break
- `bodyweight`: track max `repetitions`; same tie-break

**Valid set guard**: `actualSet.skipped != true` — absent field (null) evaluates to `null != true` → true → treated as non-skipped (consistent with SCR-21/22/23).

**Return type**: `Future<List<PersonalBestRecord>>` — throws on `AppException` to propagate to `PbBloc`'s catch block.

**Alternatives considered**: Returning `Either<AppException, List<PersonalBestRecord>>` — rejected for consistency with the pattern used by `GetStatisticsUseCase` (SCR-23) which also throws on Left to let the Bloc's try/catch handle it uniformly.

---

## D-07: DI Registration

**Decision**:
```dart
// In get_it_setup.dart, after WorkoutSessionRepository is registered:
getIt.registerLazySingleton<GetPersonalBestsUseCase>(
  () => GetPersonalBestsUseCase(getIt<WorkoutSessionRepository>()),
);
getIt.registerFactory<PbBloc>(
  () => PbBloc(getPersonalBests: getIt<GetPersonalBestsUseCase>()),
);
```

**`registerFactory` for PbBloc**: Each route push creates a fresh Bloc instance; on-entry recalculation (FR-016) is guaranteed without manual reset.

**`registerLazySingleton` for `GetPersonalBestsUseCase`**: Stateless; safe to share across Bloc instances.

---

## D-08: Shimmer / Skeleton Strategy

**Decision**: `PbSkeleton` uses `ShimmerBox` (existing `core/widgets/shimmer_box.dart`) with an `AnimationController` owned by `PbSkeleton` itself (lifecycle-isolated from `PersonalBestsScreen`). 5 placeholder rows per FR-001.

**Each skeleton row**: A `PbCard`-shaped row with:
- 8×8 `ShimmerBox(height: 8, borderRadius: 50, widthFraction: null)` — circular dot placeholder
- `ShimmerBox(height: 14, borderRadius: 6, widthFraction: 0.5)` — exercise name line
- `ShimmerBox(height: 11, borderRadius: 4, widthFraction: 0.3)` — date line
- A fixed-size badge-shaped `ShimmerBox` (right-aligned)

**Alternatives considered**: Single-file shimmer inside `PersonalBestsScreen` — rejected because `ShimmerBox` requires an `AnimationController`; owning it in the skeleton widget keeps disposal clean and the screen file focused.

---

## D-09: Error Card Approach

**Decision**: Feature-specific `PbErrorCard` widget (not the core `ErrorCard`).

**Rationale**: Core `ErrorCard` accepts only `message: String` (single text field) and uses `OutlinedButton` for Retry. SCR-24 requires:
- Separate `title` (16px/weight-800) and `body` (13px/muted, multi-line, text-align:center, line-height:1.5)
- `ElevatedButton` for Retry (not `OutlinedButton`)
- 40×40 icon

A `PbErrorCard` with the exact spec layout avoids over-engineering the shared `ErrorCard` for one screen's requirements.

---

## D-10: Retry Debounce Guard

**Decision**: `PersonalBestsScreen` is a `StatefulWidget` owning `bool _retrying = false`.

**Pattern**:
```dart
void _onRetry(BuildContext context) {
  if (_retrying) return;
  setState(() => _retrying = true);
  context.read<PbBloc>().add(PbLoadRequested());
}
```

`BlocListener` in `PersonalBestsScreen`:
```dart
listenWhen: (_, current) => current is! PbLoading,
listener: (context, state) => setState(() => _retrying = false),
```

**Why `StatefulWidget`**: Only one piece of genuinely local UI state (`_retrying`). The Bloc owns all business state; `_retrying` is a presentation-layer debounce flag only.

**No existing implementation**: The `_retrying` pattern does not yet exist in the codebase — SCR-24 introduces it first.

---

## D-11: AppStrings Constants (SCR-24)

The following 10 constants + 1 list are added to `AppStrings`:

| Constant | Value |
|---|---|
| `pbScreenTitle` | `'Personal Bests'` |
| `pbEmptyTitle` | `'No personal bests yet'` |
| `pbEmptySubtitle` | `'Complete a workout to start setting personal bests.'` |
| `pbErrorTitle` | `"Couldn't load your personal bests"` |
| `pbErrorBody` | `'Something went wrong calculating this data.\nYour workout history is unaffected.'` |
| `pbRetryButton` | `'Retry'` |
| `pbBadgeWeightLabel` | `'BEST WEIGHT'` |
| `pbBadgeTimeLabel` | `'BEST TIME'` |
| `pbBadgeRepsLabel` | `'BEST REPS'` |
| `pbDatePrefix` | `'Set '` |
| `shortMonthNames` (List) | `['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']` |

---

## D-12: No New Color Tokens

**Decision**: SCR-24 requires zero new color tokens. All required colors exist in `AppColors`:

| Color need | Existing token |
|---|---|
| Type dot — weighted | `AppColors.lime` |
| Type dot — timeBased | `AppColors.cyan` |
| Type dot — bodyweight | `AppColors.textMuted` |
| Error card fill | `AppColors.dangerBg` |
| Error card border | `AppColors.dangerBorder` |
| Error icon | `AppColors.danger` |
| Badge fill | `AppColors.cardAlt` |
| Exercise name | `AppColors.white` |
| Date text | `AppColors.textDim` |
| Badge label | `AppColors.textDim` |

Note: `AppColors.successFill` (needed by SCR-23's `PersonalBestsLinkRow`) is out of scope for SCR-24 — it will be added in SCR-23's implementation.
