# ADR-001 Architecture Style

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp's actual architecture: a fully offline, single
>   local user, Drift-only Flutter application. This version is authoritative; prior versions
>   (1.1–1.4) no longer apply.

---

# Context

ForgeApp is a Flutter-based, fully offline workout tracker (POC/MVP scope; see
`SDS_v2.0.md` §2). There is one local user per device install, no backend, no network calls, and
Drift is the sole persistence layer (SDS §2.2–2.3).

The application is CRUD/state-driven rather than workflow-driven against a server: business
operations (create a plan, log a set, finish a workout) complete entirely on-device, and success
is never contingent on a network round-trip.

The architecture must support:

- A small, fixed set of features (profile, exercise catalogue, workout plans, scheduling, workout
  execution, history, progress, statistics)
- Long-term maintainability at POC/MVP scale — "enough, not too much," not a large-team codebase
- High testability
- AI-assisted development

---

# Decision

ForgeApp shall adopt the following architectural principles.

## Primary Architecture

- Clean Architecture

## Organizational Architecture

- Feature-First Architecture

## Supporting Patterns

- Repository Pattern (repositories wrap Drift data sources, not a remote API)
- Use Case Pattern
- Dependency Injection

---

# Architectural Structure

Every business feature shall follow a consistent layered structure.

```text
feature/
├── presentation/
├── application/
├── domain/
└── data/
```

Each layer owns a single responsibility and communicates only through defined interfaces.

---

# Layer Responsibilities

## Presentation Layer

Responsible for: Flutter UI, user interactions, screen navigation, displaying application state.
Must not contain: business rules, Drift access, repository implementation, data mapping.

## Application Layer

Responsible for: use cases, feature orchestration, state management (Bloc), input validation.
Must not contain: UI implementation, direct database access.

## Domain Layer

Responsible for: business entities (SDS §6.1 — Profile, Exercise, WorkoutPlan, ScheduleEntry,
WorkoutSession), value objects, repository contracts, core business rules (e.g. one-plan-per-day,
exercise type-flag field gating). Must remain independent of Flutter, Drift, and any
serialization library.

## Data Layer

Responsible for: repository implementations, database access, generated Drift code, model mapping.
Must not contain: UI logic, business rules, workflow decisions.

---

# Dependency Rules

```text
Presentation → Application → Domain
Data → Domain
```

No layer may depend on an outer layer. The Domain layer must remain independent of Drift and
Flutter.

---

# Feature Organization

```text
features/
  app_lock/          (SDS-COMP-1, SDS-COMP-2, SDS-COMP-14, SDS-COMP-15 — splash, static login, lock state)
  profile/           (SDS-COMP-3)
  exercises/         (SDS-COMP-4 — seeded, read-only catalogue)
  plans/             (SDS-COMP-5)
  schedule/          (SDS-COMP-6)
  workout/           (SDS-COMP-7, SDS-COMP-8 — active execution + completed records)
  history/           (SDS-COMP-9)
  progress/          (SDS-COMP-10)
  statistics/        (SDS-COMP-11)
```

The application shall **not** be organized around technical folders (`screens/`, `widgets/`,
`repositories/`) at the application root.

No feature may directly depend on another feature's internal implementation. Cross-feature
communication occurs only through public contracts or shared abstractions (e.g. `plans` exposes a
read-only plan lookup that `schedule` and `workout` consume).

---

# Connectivity Model

ForgeApp is fully offline. There is no network layer, no backend, and no concept of connectivity
loss to design around (SDS §2.3, Design Constraints). All reads and writes are local Drift
operations; the only failure modes are local read/write failures (SDS §8, SDS-ERR-5/6), not
network failures.

---

# Shared Modules

```text
lib/
  app/                 (app shell, app-lock boundary)
  config/
    routes/            (ADR-003)
    theme/             (ADR-037)
  core/
    constants/
    errors/
    persistence/       (Drift boundary, ADR-008)
    validation/        (ADR-026)
  features/
```

These shared modules are exempt from the per-feature four-layer rule.

---

# Prohibited

- Presentation depending on repository implementations
- Business logic inside Widgets
- Domain depending on Flutter or Drift
- Cross-feature implementation access
- A network/API layer of any kind (out of scope — see deleted ADR-005/006)

---

# Alternatives Considered

## MVC / MVVM

Rejected for the same reasons as any multi-feature Flutter app: weak separation of concerns at
this scale, ViewModels tend to accumulate responsibilities over time.

## Layer-First Architecture

Rejected — with 9 features, a layer-first split fragments each feature across the tree
unnecessarily for an app this size.

---

# Consequences

## Positive

- Strong separation of concerns despite the app's small scope
- Easy to test business rules (one-plan-per-day, type-flag gating, statistics derivation) without
  any Drift or Flutter dependency
- Matches the SDS component catalogue one-to-one, so traceability is direct

## Negative

- More structure than a single-file POC would need — accepted deliberately for maintainability
  and testability given this is a learning/assignment codebase

---

# Compliance

All features shall comply with this architectural style. Any deviation requires an approved ADR
update.

---

# Related ADRs

- ADR-002 State Management
- ADR-003 Routing
- ADR-004 Dependency Injection
- ADR-007 Error Handling
- ADR-008 Local Storage
- ADR-032 Modularization Strategy
