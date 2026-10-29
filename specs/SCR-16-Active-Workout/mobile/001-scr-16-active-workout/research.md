# Research: SCR-16 Active Workout

**Phase 0 decisions — resolved before design**

---

## D-01: Feature ownership — `workout_session` (existing)

**Decision**: SCR-16 belongs inside the existing `workout_session` feature at `forge/lib/features/workout_session/`. No new feature directory is created.

**Rationale**: The `workout_session` feature was scaffolded in advance: `WorkoutSession`, `SessionExercise`, and `ActualSet` domain entities exist; `WorkoutSessionRecord`, `SessionExerciseRecord`, and `ActualSetRecord` are defined with their tables (`workout_sessions`, `session_exercises`, `actual_sets`) in `AppDatabase`; `WorkoutSessionLocalDataSource` and `WorkoutSessionRepositoryImpl` are wired into GetIt. SCR-16 is the feature that creates and persists the first session — it is the natural presentation and application owner.

**Alternatives considered**:
- New `active_workout` feature — rejected: domain logic and persistence are already in `workout_session`; splitting would require cross-feature data access (prohibited by architecture).
- Owned by `workout_plan` — rejected: `workout_plan` reads plan data; session writing is a distinct domain concern already established in `workout_session`.

---

## D-02: Two additive columns — no new table

**Decision**: Existing records `WorkoutSessionRecord` (`workout_sessions` table) and `ActualSetRecord` (`actual_sets` table) each receive one new column. No new table is created.

| Record | New field | Column | Dart type |
|---|---|---|---|
| `ActualSetRecord` | `skipped` | `skipped` (default `false`) | `bool` |
| `WorkoutSessionRecord` | `startedAt` | `started_at` (nullable) | `DateTime` |

**Rationale**: `ActualSet.skipped` is required by the spec clarification (all sets including skipped must be stored with a `skipped` flag). `WorkoutSession.startedAt` is required by the spec clarification (session must store a start timestamp; `sessionDurationSec` derives from `completedAt - startedAt` in seconds). Both additions are backward-compatible: rows without a value return `false` for `skipped` (column default) and `null` for `started_at`, which is safe for `bool` and `DateTime?` (see D-02a).

**D-02a: `startedAt` nullability**: `WorkoutSession.startedAt` is declared `final DateTime startedAt` (non-nullable) in the domain entity. `WorkoutSessionRecord.startedAt` is `DateTime?` (nullable in the storage record to handle existing records). The mapper converts `model.startedAt ?? model.completedAt` for old records — this is a safe fallback: old sessions had no startedAt, so completedAt is an acceptable sentinel.

**Alternatives considered**:
- Add a new table/record `SkippedSetRecord` — rejected: over-engineering; the simplest solution is a bool flag on the existing model.
- Omit skipped sets from the stored record — rejected: spec clarification explicitly requires all sets stored.

---

## D-03: New `SaveWorkoutSessionUseCase`

**Decision**: Create `domain/usecases/save_workout_session_usecase.dart`. Its single `call(WorkoutSession session)` method validates the completion criterion (≥1 `SessionExercise` with ≥1 non-skipped `ActualSet`) then delegates to `WorkoutSessionRepository.saveSession`.

**Rationale**: The repository already enforces this criterion, but the use case layer should also enforce it as a named policy. Dual enforcement means a Bloc mistake (calling save with 0 logged sets) produces a clear typed failure at the use case boundary rather than a silent discard at the repository. Consistent with the pattern in `workout_plan` where business rules live in use cases.

**Alternatives considered**:
- Call `repository.saveSession` directly from the Bloc — rejected: violates Clean Architecture (application layer must not import `data/`); also bypasses the use-case boundary that carries the business rule.

---

## D-04: New `ActiveWorkoutBloc` — in-memory execution state strategy

**Decision**: `ActiveWorkoutBloc` extends `Bloc<ActiveWorkoutEvent, ActiveWorkoutState>`. All execution state (the in-progress session: current position, per-set logged values, start time) is held in **private Bloc fields** — not emitted in every state. The emitted state carries only what the presentation needs to render the current view.

**Private Bloc fields (not in state)**:
```
_plan: WorkoutPlanDetail
_startedAt: DateTime
_loggedSets: List<List<_SetEntry>>  // [exerciseIdx][setIdx]
_completedSession: WorkoutSession?  // non-null only while retrying a failed write
```

**Emitted state carries**:
- `currentExercise: PlanExercise` — for exercise name, type, field layout
- `exerciseIndex: int` — 1-based display (e.g. "Exercise 2 / 5")
- `exerciseCount: int`
- `currentSetIndex: int` — 0-based within the exercise
- `setStatuses: List<SetStatus>` — ordered status of all sets in current exercise (for dot row)
- `repError: String?` / `weightError: String?` / `durationError: String?` — inline validation
- `isPaused: bool` — drives paused overlay
- `writeError: String?` — non-null when Finish write failed

**Rationale**: Emitting the entire `_loggedSets` matrix in every state would make the Equatable `props` comparison expensive and create churn on every field edit. The private-field approach keeps state emissions lean. The Bloc assembles the full `WorkoutSession` from `_loggedSets` only at Finish time.

**Alternatives considered**:
- Store full session data in emitted state — rejected: excessive Equatable overhead; every keystroke would rebuild the full state graph.
- Use `StatefulWidget` local state for execution tracking — rejected: violates CLAUDE.md rule 42 (business logic in widgets).

---

## D-05: OS back gesture — `PopScope` interception

**Decision**: Wrap `ActiveWorkoutScreen` body with `PopScope(canPop: false, onPopInvokedWithResult: (_, __) => context.push(RoutePaths.cancelWorkout))` to intercept swipe-back (iOS) and hardware back (Android) and route to SCR-18 instead of popping.

**Rationale**: `PopScope` (Flutter 3.12+) is the current non-deprecated API for back gesture control. `canPop: false` prevents go_router from popping the route; `onPopInvokedWithResult` fires on every pop attempt, where we route to SCR-18. This is identical in behavior to tapping Cancel.

**Note**: SCR-18 (Cancel Workout Confirmation) is out of scope for SCR-16. The route `RoutePaths.cancelWorkout = '/workout/cancel'` is stubbed with a placeholder screen, identical to how SCR-15 stubs the `activeWorkout` route.

**Alternatives considered**:
- Override `WillPopScope` — rejected: deprecated in Flutter 3.12.
- Return `false` from `RoutePredicate` in go_router — rejected: go_router does not expose a synchronous back-interception hook at that level; `PopScope` is the correct approach.

---

## D-06: Finish write failure — write-error state with preserved session

**Decision**: On `SaveWorkoutSessionUseCase` failure:
1. Bloc stores the assembled `WorkoutSession` in `_completedSession` (private field).
2. Bloc emits `ActiveWorkoutRunning.copyWith(writeError: failure.message)` *(supersedes the original draft which named a distinct `ActiveWorkoutFinishError` state class — contracts and tasks.md settled on the `copyWith` approach to avoid an extra state; implementation MUST follow contracts/tasks.md)*.
3. Screen shows write-error banner with Retry button (driven by `writeError ≠ null` in the Running state).
4. Retry dispatches `ActiveWorkoutRetryFinishRequested` — Bloc reuses `_completedSession` (same UUID) and calls the use case again.

**Idempotence**: The repository saves with an insert-or-replace on `workout_sessions` keyed by `session_id`, which overwrites any prior row for the same key. Since the UUID is generated once and reused, concurrent retries cannot produce duplicate records.

**Rationale**: This follows the project's established write-error pattern (ADR-007 §SDS-ERR-5/6). The session is preserved in the Bloc, not re-built from UI fields, so the user never re-enters data.

**Alternatives considered**:
- Distinct `ActiveWorkoutFinishError` state class — initially considered; superseded by `ActiveWorkoutRunning.copyWith(writeError: ...)` which avoids an extra state class with identical UI shape and simplifies BlocBuilder logic.
- Re-navigate the user back to the workout to retry — rejected: confusing UX; the write-error state stays on the same screen.

---

## D-07: Field value management — presentation vs. Bloc

**Decision**: `TextEditingController` instances live in the presentation layer (managed by `StatefulWidget` that holds the controllers). On **Complete Set tap**, the screen reads the current field values and dispatches `ActiveWorkoutCompleteSetRequested({reps, weight, durationSec})` to the Bloc. On **every field text change**, the screen dispatches `ActiveWorkoutFieldChanged({field, value})` to clear the relevant error from state.

**Rationale**: `TextEditingController` is a Flutter UI concern that belongs in the presentation layer. The Bloc does not own text controllers. Passing field values only on Complete Set (not on every keystroke) keeps Bloc event frequency low. `ActiveWorkoutFieldChanged` is a lightweight event that clears one error field — it does not re-validate the full set.

**Alternatives considered**:
- Hold field values in Bloc state — rejected: every character typed would rebuild state and re-render all `BlocBuilder` descendants.
- Validate on blur — rejected: spec explicitly requires real-time clearing (FR-006).

---

## D-08: Paused visual treatment

**Decision**: In `ActiveWorkoutScreen`, a `Stack` contains:
1. The main workout content widget.
2. When `isPaused == true`: a `ColorFiltered` + `Opacity` wrapper on the content (opacity: 0.35, grayscale matrix), plus the `PausedWorkoutOverlay` widget centered in the Stack.

No scrim background. The overlay panel is plain (Cancel + Resume buttons, pause icon, elapsed time if displayed). The `Cancel` button in the overlay navigates to SCR-18 identically to the active-state Cancel.

**Rationale**: Design spec specifies `opacity: 0.35 + grayscale(0.4)` on content with no scrim. A `Stack` with conditional rendering is the standard Flutter pattern. `ColorFiltered` with a grayscale matrix handles the desaturation.

---

## D-09: `SetStatus` enum and `ActiveWorkoutField` enum

**Decision**: Two enums added to `application/bloc/active_workout_state.dart`:

```dart
enum SetStatus { pending, logged, skipped }
enum ActiveWorkoutField { reps, weight, duration }
```

**Rationale**: `SetStatus` drives the set-indicator dot row (pending = dim, logged = lime, skipped = muted). `ActiveWorkoutField` is used in `ActiveWorkoutFieldChanged` to identify which error to clear. Both are application-layer concerns (not domain) because they describe UI state transitions.

---

## D-10: Stub route for SCR-18 and SCR-19

**Decision**: Add two stub routes to `app_routes.dart`:
- `RoutePaths.cancelWorkout = '/workout/cancel'` — renders a placeholder screen labeled "SCR-18 — Cancel Workout Confirmation (coming soon)".
- `RoutePaths.postWorkout = '/workout/summary'` — renders a placeholder screen labeled "SCR-19 — Post-Workout Summary (coming soon)".

**Rationale**: SCR-16's acceptance tests require navigation to SCR-18 (cancel) and SCR-19 (finish). Stubs make these navigations testable without implementing the full screens. Consistent with the pattern used for SCR-16's own `activeWorkout` stub in SCR-15's plan.
