# Research: SCR-06 Home Dashboard

**Date**: 2026-09-16 | **Phase**: 0 — Design Research

---

## Decision 1: Bottom Navigation Shell — StatefulShellRoute vs alternatives

**Decision**: Use `StatefulShellRoute` with 6 branches in `app_routes.dart`.

**Rationale**:
- `StatefulShellRoute` preserves each tab's navigation stack across tab switches. Without it, switching away from a deep screen and returning would pop the user back to the tab root — a broken UX. 
- Each branch gets its own `Navigator` key (`GlobalKey<NavigatorState>`), so Plans → Plan Detail → back does not affect the Home or Schedule tab stacks.
- This is the idiomatic go_router approach for tab navigation as of go_router 12+, which is already a dependency of ForgeApp. No new package required.

**Alternatives considered**:

| Alternative | Rejected because |
|---|---|
| `ShellRoute` (stateless) | Does not preserve child navigator stacks; re-entering a tab pops to root |
| `GoRoute('/')` with manual `IndexedStack` | Bypasses go_router's Navigator management; deep links break; back-button handling is manual |
| `TabController` + `BottomNavigationBar` | Requires explicit stack management per tab; duplicates work go_router already provides |

**Implementation note**: The 6 branch roots are: `/` (Home), `/plans`, `/schedule`, `/history`, `/progress`, `/stats`. Tabs 2–6 serve placeholder screens until those features are implemented. Each branch uses a distinct `GlobalKey<NavigatorState>`.

---

## Decision 2: Tab Re-Activation Refresh Trigger

**Decision**: Fire `HomeLoadRequested` from `didChangeDependencies` in `HomeScreen`, guarded by a check that the current `GoRouterState` branch index is Home (0).

**Rationale**:
- `FR-012` requires a re-read every time the Home tab is activated, including returns from sub-screens and switches from other tabs.
- `didChangeDependencies` is called after every widget dependency change, including when the `StatefulShellRoute` navigator branch is re-activated. This is more reliable than `initState` (called only on mount) or `RouteObserver` (requires a separate observer wiring).
- Alternative: `StatefulShellRoute.navigatorObservers` could fire a callback on tab switch, but that pattern couples route config to feature-specific logic.
- The guard (`context.go_router_state.uri.path.startsWith('/')`) ensures we only re-read when the Home branch is actually in front, not on every dependency change.

**Alternatives considered**:

| Alternative | Rejected because |
|---|---|
| `initState` only | Only fires on mount; does not re-read when user returns from sub-screen or another tab |
| `RouteObserver` with `RouteAware` mixin | Requires wiring in `app_routes.dart` and registering the observer — more coupling, more boilerplate |
| `VisibilityDetector` (package) | Requires adding a package outside the governed set |
| Drift `watch()` stream listener | A Drift `watch()` query stays open and re-emits on every write to the watched tables — overkill for a refresh-on-activation pattern; subscription lifecycle also complex |

**Implementation note**: The Bloc event `HomeLoadRequested` must be idempotent — firing it while already in `HomeLoading` state is a no-op (handled in the Bloc's event handler by checking current state).

---

## Decision 3: DashboardSnapshot Entity Design

**Decision**: Two domain entities — `DashboardSnapshot` and `TodayWorkout`.

```
DashboardSnapshot {
  bool hasData          // true if any table (plans, schedule, sessions) non-empty
  TodayWorkout? todayWorkout  // null → rest day; present → show today's card
}

TodayWorkout {
  String planId
  String planName
  int exerciseCount
  ExerciseType dominantType   // most frequent type in the plan's exercises
  int? firstExerciseRestSec   // null if plan has no exercises (FR-003)
}
```

**Rationale**:
- `hasData` captures the empty-vs-populated branch (FR-002 vs FR-003/FR-005). The Home screen need not inspect raw tables.
- `todayWorkout == null` with `hasData == true` → rest day (FR-005). `todayWorkout != null` → scheduled workout (FR-003).
- `TodayWorkout` contains exactly what the UI needs — no raw storage record leaks into the domain layer.
- `dominantType`: mode of `ExerciseType` across all plan exercises. Tie-break: weighted > bodyweight > timeBased (arbitrary but deterministic).
- `firstExerciseRestSec`: `null` when `planExercises.isEmpty` (per FR-003 clarification).

**Alternatives considered**:

| Alternative | Rejected because |
|---|---|
| Single flat entity with all fields nullable | Unclear null semantics — consumer cannot tell "no workout today" from "workout exists but has no exercises" |
| Expose raw `WorkoutPlanRecord` to domain | Violates Clean Architecture — domain must not depend on data layer |
| Add `isRestDay: bool` field | Redundant — `hasData == true && todayWorkout == null` already encodes rest day |

---

## Decision 4: Replacing HomeRemoteDataSource (Constitutional Fix)

**Decision**: Delete `home_remote_data_source.dart` (Dio-based) and `home_model.dart` (JSON model). Replace with `HomeDashboardLocalDataSource` which reads from three existing tables via three existing local data source interfaces.

**Rationale**:
- The existing `HomeRemoteDataSource` calls `throw UnimplementedError()` and is registered with `UnimplementedError` in GetIt — it was never functional and is a scaffold placeholder.
- The constitutional constraint ("ForgeApp MUST remain fully offline; it MUST NOT make a network call") absolutely prohibits retaining any Dio-based data source, even an unimplemented one that could be accidentally wired up.
- Three existing data source interfaces already cover all data needed for the dashboard: `WorkoutPlanLocalDataSource`, `ScheduleLocalDataSource`, `WorkoutSessionLocalDataSource`. All three are already registered in GetIt.
- `HomeDashboardLocalDataSource` composes these three — no new table, no new schema.

**Reading strategy**:
```
hasData = workoutPlans.isNotEmpty || scheduleEntries.isNotEmpty || sessions.isNotEmpty
todayWeekday = DateTime.now().weekday   // 1=Mon … 7=Sun
entryToday = schedule.firstWhereOrNull((e) => e.weekday == todayWeekday)
planToday = entryToday != null ? workoutPlans.firstWhereOrNull((p) => p.planId == entryToday.planId) : null
```

**Alternatives considered**:

| Alternative | Rejected because |
|---|---|
| Keep `HomeRemoteDataSource` with `UnimplementedError` stub | Remains a constitutional violation; blocks any real implementation |
| Read tables directly in the repository impl | Bypasses the data source layer; violates Clean Architecture layer contract |
| Subscribe to table streams | Live stream subscription is unnecessary — refresh-on-activation satisfies FR-012 without keeping an open stream |

---

## Decision 5: "Has Data" Logic

**Decision**: `hasData = true` if **any** of the three tables contains at least one entry.

**Rationale**: Per spec Assumptions: "The 'has data' check for the empty vs. populated decision reads all three local tables: workout plans, schedule entries, and workout history sessions. If any contains at least one entry, the populated path is taken."

This means a user with only workout session history (but no current plans) is in the populated/rest-day state — they are not a "first-time user" and should see quick links, not the empty-state CTA. The empty state is reserved for the true first-time user.

---

## Decision 6: Bloc Layer Location

**Decision**: `HomeBloc`, `HomeEvent`, `HomeState` live in `forge/lib/features/home/application/bloc/`. The existing `forge/lib/features/home/presentation/bloc/` directory is deleted.

**Rationale**: Per constitution Principle I (Clean Feature-First Architecture), state management belongs in the `application/` layer, not `presentation/`. The `auth` feature correctly places its state management in `application/`. The existing `home/presentation/bloc/` placement is a scaffold error.

**No behaviour change**: the Bloc is still a `Bloc<HomeEvent, HomeState>` — only the file location changes.

---

## Decision 7: dominantType Derivation Algorithm

**Decision**: `dominantType = mode(planExercises.map((e) => e.type))`. Tie-break order if frequencies are equal: `weighted > bodyweight > timeBased`.

**Rationale**: The most common type gives the best single-word label for the card chip. Tie-break is deterministic and weighted exercises are the most common case in strength-training apps (an informed default).

**Edge case**: If `planExercises.isEmpty`, `dominantType` is omitted from the card altogether (same condition as `firstExerciseRestSec == null`).

---

## Unresolved / Deferred

None — all blocking decisions are resolved. The following were confirmed as in-scope defaults and require no further research:

- Navigation destination for each quick link: SCR-08, SCR-12, SCR-20, SCR-22, SCR-23 (per FR-006 / US-2 acceptance criteria)
- Empty-state CTA: switch to Plans tab + push SCR-09 within Plans stack (per FR-010 clarification)
- `DateTime.now().weekday` for "today" determination (per spec Assumptions)
