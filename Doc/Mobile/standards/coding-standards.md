# ForgeApp — Flutter/Dart Coding Standards

This document is the day-to-day coding reference for ForgeApp (Flutter/Dart). The relevant ADRs
remain the source of truth for rationale. Test coverage targets and test-writing patterns live in
`standards/testing-standards.md`, not here.

---

## 1. General Principles

- **Spec first, code second**: no code is written without an approved spec (see
  `governance/definition-of-ready.md`).
- **SOLID**: every class/function has a single, well-defined responsibility.
- **DRY**: extract common logic into shared utilities — but do not abstract prematurely.
- **YAGNI**: do not implement features or abstractions not required by the current spec — this
  matters especially for a scoped POC (see `app/PRODUCT_CONTEXT.md` §10 Product Principles).
- **Composition over inheritance**: prefer dependency injection and composition.
- **Immutability by default**: prefer `final` fields, `const` constructors, and immutable models
  over mutable state.
- **Clean Architecture layer rules** (ADR-001) are non-negotiable — see
  `governance/architecture-boundaries.md`.

```dart
// Preferred
class WorkoutPlanRepository {
  final WorkoutPlanLocalDataSource dataSource;
  WorkoutPlanRepository(this.dataSource);
}

// Avoid
class WorkoutPlanRepository extends WorkoutPlanLocalDataSourceImpl {}
```

### 1.1 Commit Message Convention

Commits should use a feature/story reference and exactly one relevant Gitmoji from
[gitmoji.dev](https://gitmoji.dev/) describing the primary intent of the commit. Do not add a
redundant textual commit type such as `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`,
or `perf` alongside the Gitmoji.

```
[US-NNN-feature-name] <gitmoji> short description

Examples:
[US-012-workout-execution] ✨ add rest timer auto-start
[US-012-workout-execution] 🐛 fix timer not pausing when app backgrounded
[US-012-workout-execution] ✅ add Bloc tests for active workout state
```

For example, use `✨` for a new feature, `🐛` for a bug fix, `✅` for tests, `📝` for
documentation, `♻️` for a refactor, and `⚡️` for performance work. The current Gitmoji catalogue
at `gitmoji.dev` is authoritative when choosing a symbol.

### 1.2 Branch Naming

```
feature/NNN-feature-name
bugfix/NNN-feature-name
chore/NNN-feature-name
```

### 1.3 Code Review Requirements

- `fvm flutter analyze` zero issues and `fvm flutter test` all passing before requesting review
  (this is a single-developer POC, so "review" may be a self-review pass against
  `standards/code-review-checklist.md` rather than a second engineer).
- No `// ignore` suppression without a comment explaining why.

---

## 2. Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files and directories | `snake_case` | `workout_plan_page.dart` |
| Classes | `PascalCase` | `WorkoutExecutionBloc` |
| Variables and functions | `camelCase` | `submitWorkoutSet()` |
| Constants | `camelCase` | `defaultRestSeconds` |
| Private members | `_camelCase` | `_planRepository` |

No magic numbers/strings — extract to named constants or enums.

---

## 3. Dart Style

- Use `const` constructors wherever possible.
- Prefer `final` for local variables.
- Use `sealed` classes for Bloc state and event hierarchies (ADR-002).
- Use `abstract interface class` for contracts (repositories, use cases).
- Prefer named parameters for constructors with more than one parameter.
- Use single quotes for string literals.
- Do not use `dynamic` — use explicit types or generics.
- Document public APIs with `///` doc comments; comments explain **why**, not what.

```dart
/// Returns the exercise with the given [id] from the seeded catalogue.
///
/// Throws [LocalReadFailure] when the local database cannot be read.
Future<Exercise> getExercise(String id);
```

---

## 4. File Organization

- One primary class per file.
- Each feature exposes its public API through a single barrel file, e.g.
  `lib/features/workout_execution/workout_execution.dart`.
- Import from the barrel when referencing a feature from outside it. Never import from another
  feature's internal paths (`data/`, `domain/`, `application/`, `presentation/` subfolders are
  private) — see `governance/architecture-boundaries.md`.

---

## 5. Lint Rules

Base ruleset: `flutter_lints` (already in `pubspec.yaml`), with project overrides in
`analysis_options.yaml` as needed.

Generated files are excluded from analysis:

```yaml
analyzer:
  exclude:
    - "**/*.g.dart"
```

Supplementary rules worth enabling on top of the default set: `always_declare_return_types`,
`avoid_print`, `prefer_final_fields`, `prefer_const_constructors`, `directives_ordering`.

All lint violations must be resolved before merge.

---

## 6. Null Safety

Prefer non-nullable types; use nullable only when null is a valid business state. Avoid
force-unwrap (`!`).

```dart
// Preferred
final String name;
String? notes; // only when null is a valid state

// Avoid
plan!.name

// Preferred
plan?.name
if (plan == null) return;
```

---

## 7. Functions

| Target | Limit |
|---|---|
| Preferred length | ≤ 20 lines |
| Maximum length | 50 lines |
| Parameters | max 4 (use a request model beyond that) |

Each function performs one task.

```dart
// Preferred
Future<WorkoutSession> startSession(String planId)

// Avoid
Future<void> loadPlanAndStartTimerAndLogAnalytics()
```

---

## 8. Error Handling

- Never swallow exceptions (`catch (_) {}` is forbidden).
- Use typed exceptions where the platform throws generically.
- Convert exceptions to typed `Failure`s at the repository boundary — raw Drift exceptions must
  never be exposed outside the Data layer (ADR-007, SDS-ERR-5/6).

```dart
try {
  return await dataSource.getPlan(id);
} on DriftException {
  throw LocalReadFailure();
}
```

---

## 9. Async Programming

- Prefer `async`/`await` over `.then()` chains; `.then()` only when it genuinely improves
  readability.
- Drift I/O must never block the UI thread, particularly during the active-workout rest timer
  (ADR-021).
- Explicitly mark fire-and-forget operations with `unawaited(...)`.

---

## 10. Collections

Prefer functional operations (`where`, `map`, `firstWhere`) and spread operators over imperative
loops.

```dart
plans.where((plan) => plan.isScheduled);
[...exercises, customExercise];
```

---

## 11. Models & Drift Mapping

ForgeApp has no backend and no JSON payloads to deserialize, so there are no DTOs and no Freezed
JSON serialization. Domain models are plain immutable Dart classes (`Equatable` for value
equality); Drift persistence uses generated table and row classes (`drift_dev`), kept strictly in the
Data layer.

- Domain entities extend `Equatable` and stay framework-independent — no Drift imports or
  table annotations in the domain layer.
- Drift tables and the hand-written `*Record` storage classes live in the Data layer only.
- An explicit Mapper converts between the storage record and the domain entity
  (`ExerciseRecord → ExerciseMapper → Exercise`); the record must never be exposed outside
  the Data layer (ADR-008, ADR-032).

```dart
class Exercise extends Equatable {
  const Exercise({required this.id, required this.name, required this.type});
  final String id;
  final String name;
  final ExerciseType type;

  @override
  List<Object?> get props => [id, name, type];
}

@DataClassName('ExerciseRow')
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<ExerciseType>()();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## 12. Enums

Prefer enhanced enums with labels over magic strings.

```dart
enum ExerciseType {
  weighted('Weighted'),
  timeBased('Time-Based'),
  bodyweight('Bodyweight');

  const ExerciseType(this.label);
  final String label;
}
```

---

## 13. Dependency Injection

Dependencies are always injected, never instantiated inside a class. Use GetIt for explicit central
registration as defined by ADR-004. Prefer constructor injection; resolve dependencies at
composition roots and never call `getIt<T>()` from business logic.

```dart
// Preferred
class StartWorkoutUseCase {
  final WorkoutSessionRepository repository;
  StartWorkoutUseCase(this.repository);
}
```

---

## 14. Logging

Never use `print()` — use the centralized Logging Service described by ADR-020; feature code must
not import a logger implementation directly.

| Level | When to use |
|---|---|
| `error` | Unhandled exception, Drift read/write failure |
| `warning` | Recoverable error, deprecated usage |
| `info` | Approved non-sensitive operational events (workout completed, plan scheduled) |
| `debug` | Detailed flow tracing — development only |

Never log: the static demo credential, profile field values, or any other personal data.

```dart
// Avoid
print(session);

// Preferred
appLogger.info('workout_completed', planId: session.planId);
logger.e(error, stackTrace);
```

---

## 15. Performance

- Use `const` constructors wherever possible.
- Avoid unnecessary widget rebuilds — use `BlocSelector`, `buildWhen`, or
  `context.select((BlocType bloc) => bloc.state.field)` to scope rebuilds.
- Use lazy rendering (`ListView.builder`) for large lists (exercise catalogue, history), never
  `Column(children: list.map(...))`.

---

## 16. Complexity Limits

| Metric | Preferred | Maximum |
|---|---|---|
| Method length | 20 lines | 50 lines |
| Class length | 300 lines | 500 lines |
| File length | 300 lines | 500 lines |
| Parameters | 3 | 5 |
| Nesting depth | 2 | 3 |
| Cyclomatic complexity | 10 | 15 |

---

## 17. Code Generation

Generated code must never be manually modified.

| Tool | Purpose |
|---|---|
| `drift_dev` | Generates table, row and query code for `AppDatabase` |

Run before committing if any Drift table changed:
`fvm flutter pub run build_runner build --delete-conflicting-outputs`. Commit generated `.g.dart`
files alongside source changes.

---

## 18. AI Code Generation Rules

When generating Dart code for this project:

1. Follow Clean Architecture layer boundaries — no cross-layer leakage.
2. Prefer immutable domain models with `Equatable`; keep Drift tables and `*Record` classes confined to the Data
   layer with an explicit mapper (§11).
3. Use dependency injection — never instantiate dependencies inside classes.
4. Avoid business logic inside widgets or Drift models.
5. Use typed failures and typed exceptions.
6. Use `async`/`await` — avoid `.then()` chains.
7. Use null-safe code — avoid `!` force unwrap.
8. Generate unit-testable code — keep side-effects at layer boundaries.
9. Follow feature-first architecture; do not introduce global mutable state.
10. Keep functions focused on a single responsibility.
11. Generate `///` documentation for all public APIs.
12. Ensure generated code passes `fvm flutter analyze` with zero issues.

---

## Related Documents

- `standards/code-review-checklist.md` — PR review checklist.
- `standards/security-standards.md` — local data-handling and security rules.
- `standards/release-readiness-standards.md` — release/operational readiness.
- `governance/architecture-boundaries.md` — module isolation and layer boundary rules.
- `governance/solution-architecture.md` — Clean Architecture layering and folder structure.
- `ADRs/` — ADR-001 (Architecture Style), ADR-002 (State Management), ADR-004 (Dependency
  Injection), ADR-007 (Error Handling), ADR-008 (Local Storage), ADR-032 (Modularization
  Strategy).
- `ADRs/ADR-026_Form_Validation_Strategy.md` — validation ownership.
- `ADRs/ADR-037_Theme_Architecture.md` — centralized project theming.
- `standards/testing-standards.md` — test types, coverage targets, and test-writing patterns.

---

*Last updated: 2026-09-08 | Document owner: ForgeApp*
