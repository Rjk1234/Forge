# ADR-004 Dependency Injection

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp. Removed the "environment-specific
>   implementations" framing tied to multi-backend environments (no backend exists). GetIt-only
>   decision and its rationale are unchanged.

---

## Context

ForgeApp contains multiple features, each with its own repository, use cases, and Drift-backed data
source. The application requires loose coupling, testability (mocking a repository in unit tests
without a live database), and centralized, replaceable dependency management.

---

## Decision

The application shall use `get_it` for dependency injection and service registration.
`injectable`, `injectable_generator`, and annotation-based DI generation MUST NOT be introduced.

---

## Dependency Registration

All dependencies must be registered centrally: repositories, the `AppDatabase` instance, use cases.

```dart
final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<ProfileRepository>(() => DriftProfileRepository(getIt()));
  getIt.registerLazySingleton<WorkoutPlanRepository>(() => DriftWorkoutPlanRepository(getIt()));
  // ...
}
```

---

## Injection Principles

- Constructor injection must be preferred.
- Dependencies must be resolved through the DI container.
- Features must depend on abstractions (repository interfaces), not database implementations
  directly.
- Implementations must be replaceable without changing consumers (e.g. swapping a repository's
  `AppDatabase` for an in-memory fake in tests).

---

## Lifecycle Management

Supported lifecycles: Singleton, Lazy Singleton, Factory. Drift-backed repositories are typically
lazy singletons (`AppDatabase` is registered as a singleton and opened once; data sources take it as a constructor argument).

---

## Testing Support

Dependencies must support mocking/stubbing so unit tests never touch a real database file unless
explicitly testing the persistence layer itself.

---

## Prohibited

- Direct instantiation of repositories inside features
- Manual dependency wiring inside features
- `injectable` annotations or `injectable_generator`

```dart
// Prohibited
final repository = DriftWorkoutPlanRepository();
```

---

## Alternatives Considered

### Manual Feature-Level Wiring

Rejected — dependencies must be centrally registered through GetIt rather than wired inside
features.

### Riverpod Dependency Injection

Rejected — would introduce a second architectural responsibility alongside Bloc (ADR-002).

---

## Consequences

### Positive

- Loose coupling, improved testability, consistent dependency management

### Negative

- Manual GetIt registration must be maintained as features are added

---

## Related ADRs

* ADR-001 Architecture Style
* ADR-002 State Management
* ADR-003 Routing
