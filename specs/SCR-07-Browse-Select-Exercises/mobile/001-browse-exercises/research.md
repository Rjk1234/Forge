# Research: SCR-07 Browse & Select Exercises

**Branch**: `001-browse-exercises` | **Date**: 2026-09-17 | **Phase**: 0 — Pre-Design Research

---

## Decision 1 — In-Memory Filtering vs. Drift Query

**Decision**: Filter and search in memory after an initial full catalogue load.

**Rationale**: The seeded exercise catalogue is small (tens to low hundreds of records) and fits entirely in RAM. Drift does not support full-text substring queries — querying by type filter would require scanning every row anyway. A single `getAllExercises()` call on load followed by Dart-native `List.where` for type and substring filtering is simpler, faster, and keeps all filtering logic testable inside the Bloc without Drift interaction after initial load.

**Alternatives considered**:
- _Per-row lazy loading of plan exercises_: adds complexity with no benefit at this scale.
- _Re-reading Drift on every filter change_: unnecessary I/O; database reads are local but redundant.

---

## Decision 2 — Search Debounce Implementation

**Decision**: Use `transformer: restartable()` from the `bloc_concurrency` package (a transitive dependency of `flutter_bloc`) on the `ExerciseCatalogueSearchChanged` event handler, combined with `await Future<void>.delayed(const Duration(milliseconds: 300))` at the start of the handler.

**Rationale**: `restartable()` cancels the previous in-flight event handler when a new event arrives. By placing a 300 ms `Future.delayed` before the filter logic, rapid keystrokes cancel the previous handler and only the last typed character's event completes the filter — achieving debounce without `rxdart` or any new package.

**Alternatives considered**:
- _`rxdart` with `debounceTime`_: simplest debounce API, but `rxdart` is not in the governed package set (ADR-030) and cannot be added.
- _`Timer` stored as Bloc field_: works but pollutes Bloc state with lifecycle management; harder to test.
- _No debounce_: acceptable for a small catalogue but spec requires 300 ms (Assumption 6 in spec.md).

**Note**: `bloc_concurrency` is a transitive dependency of `flutter_bloc ^8.0.0` — no new pubspec entry required.

---

## Decision 3 — Picker Mode Navigation Pattern

**Decision**: Use GoRouter `context.push('/plans/exercises', extra: PickerContext(...))` for picker mode entry and `context.pop(exerciseId)` to return the selected exercise to the caller (SCR-09 plan editor).

**Rationale**: GoRouter's `push`/`pop`-with-result pattern is the cleanest approach for a secondary screen that must return a value: no shared singleton state, no event bus, and no BlocProvider tunneling across branches. The plan editor bloc catches the returned `exerciseId` and appends the exercise to the in-progress plan.

**Alternatives considered**:
- _Shared application-layer PickerService singleton_: decouples navigation from state but adds an implicit global dependency that is harder to test and violates single-responsibility at the feature boundary.
- _BlocProvider.of from ancestor_: breaks the layer rule (presentation cannot reach another feature's application layer).
- _Modal bottom sheet_: considered for picker mode (OQ-10), but design spec shows a standard app-bar screen with slide-in transition, so `push` is correct.

---

## Decision 4 — Route Placement

**Decision**: Add the exercise catalogue as a sub-route of `/plans`:
- Browse entry: `/plans/exercises` (no extra)
- Picker entry: `/plans/exercises` with `extra: PickerContext`

**Rationale**: The Plans tab navigator key (`_plansNavigatorKey`) manages the back stack for all plan-related flows. Since SCR-09 (Create/Edit Plan, the primary picker-mode caller) lives under `/plans`, pushing `/plans/exercises` from SCR-09 keeps the back stack inside the Plans branch and allows the Plans shell tab to remain correctly highlighted during the catalogue visit.

**Alternatives considered**:
- _Global root route `/exercises`_: would push outside the shell, losing the tab-bar highlight and complicating the back stack.
- _Separate branch in the bottom nav_: spec explicitly states no bottom nav bar on SCR-07 (it is a secondary screen).

---

## Decision 5 — Exercise Domain Entity vs. Storage Record

**Decision**: Introduce a clean `Exercise` domain entity in `features/exercise/domain/entities/` mapped from `ExerciseRecord` by a new `ExerciseMapper`. The Bloc and use cases operate on `Exercise`; the `ExerciseRecord` is confined to the data layer.

**Rationale**: Architecture Principle I.4 mandates that storage records must not leak into Domain or Presentation. `ExerciseRecord` has optional `muscleGroup` and `description` fields that are not needed by SCR-07. The domain entity exposes only what the feature needs and is immutable/equatable.

**Alternatives considered**:
- _Use `ExerciseRecord` directly_: violates the architecture boundary; also couples the UI to the storage record shape.
- _DTO without a full mapper_: a simple function call rather than a class is acceptable for this small model — mapper will be a static method on `ExerciseMapper`.

---

## Decision 6 — Skeleton Animation Technique

**Decision**: Implement the skeleton shimmer using a looping `AnimationController` driving a `LinearGradient` inside a `DecoratedBox`. No shimmer package.

**Rationale**: The design spec defines a specific shimmer gradient (`#2a2a2c → #35342f → #2a2a2c`, 1.4 s, ease infinite). Flutter's `AnimationController` + `AnimatedBuilder` with a `LinearGradient` interpolation reproduces this exactly. Using an external `shimmer` package would require a new pubspec entry (not in governed set, ADR-030).

**Alternatives considered**:
- _Static grey placeholder_: does not meet the spec (shimmer animation required).
- _External `shimmer` package_: out of governed set; would require new ADR.

---

## Decision 7 — ExerciseType Display Labels

**Decision**: Display `ExerciseType.weighted` as **"Weighted"**, `ExerciseType.timeBased` as **"Time-based"**, `ExerciseType.bodyweight` as **"Bodyweight"**.

**Rationale**: Design spec §3.3 specifies these exact labels. They must be centralised as string constants (not scattered in widget switch expressions) to comply with CLAUDE.md rule 36 (AppStrings). Since no `AppStrings` class exists yet, they will be defined as `ExerciseTypeStrings` constants in the exercise feature's presentation layer (or promoted to a shared `AppStrings` if one is introduced).

**Alternatives considered**:
- _`ExerciseType.name` (Dart enum property)_: returns `"weighted"`, `"timeBased"`, `"bodyweight"` — doesn't match spec labels.
- _Extension method on `ExerciseType`_: cleaner than a separate constants class; adopted.

---

## Decision 8 — Type Dot Color Assignment

**Decision**: Map `ExerciseType` to colour tokens as follows:

| Type | Dot Color | Token |
|---|---|---|
| `weighted` | Cyan | `AppColors._cyan` (#7DF4FF) |
| `timeBased` | Lime | `AppColors.lime` (#C3F400) |
| `bodyweight` | Muted | `AppColors.textMuted` (#C4C9AC) |

**Rationale**: Matches design spec §3.3 exactly. `AppColors._cyan` is reserved for time-based exercises in CLAUDE.md — but the design spec maps cyan to _Weighted_, not Time-based. The design spec governs here; CLAUDE.md's comment on `_cyan` was written before the exercise type dot colour scheme was finalised in the design. An implementation note in the widget will cite this decision.

**Alternatives considered**:
- _Follow CLAUDE.md token reservation verbatim_: would conflict with the artboard. Design spec takes priority for visual correctness on a feature-specific component.

---

## Open Items at Research Completion

All NEEDS CLARIFICATION markers were resolved in spec.md before the plan phase. No blockers remain.

- OQ-2 (Browse-mode row tap) → Resolved in clarification session: fully static row, FR-014.
- OQ-4 (Invalid-reference snackbar) → Resolved as spec assumption: silent rejection, no snackbar.
- OQ-6 (Duplicate exercises) → Resolved as spec assumption: duplicates allowed.
- OQ-7 (Name truncation) → Resolved as spec assumption: 1-line ellipsis.
- OQ-10 (Push vs. modal) → Resolved as spec assumption: standard push.
