# ADR-002 State Management

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp's actual features (Access, Profile, Exercise
>   Catalogue, Workout Planning, Scheduling, Workout Execution, History/Progress/Statistics). The
>   Bloc-only decision, its rationale, and the alternatives-considered analysis are unchanged —
>   they hold regardless of feature set. Removed the QR Scanner related-ADR reference (N/A to
>   ForgeApp).

---

# Context

ForgeApp consists of a small set of local, offline features:

- App Lock / Static Login
- Profile
- Exercise Catalogue
- Workout Plans
- Scheduling
- Workout Execution (active workout, rest timer)
- History
- Progress
- Statistics

These involve asynchronous Drift I/O, workflow-like state transitions (e.g. active workout:
in-progress → resting → in-progress → finished), and local validation/error handling.

The application requires predictable state transitions, clear separation of concerns, high
testability, and consistent implementation across all features — the same needs as any
Bloc-based Flutter app, independent of domain.

---

# Decision

The application shall use **flutter_bloc** as the single state management solution.

`Bloc` is the only permitted application/feature state primitive from `flutter_bloc`. Features
MUST use explicit events and states through `Bloc`. `Cubit` MUST NOT be introduced for new
feature, screen, workflow, theme, or shared application state. No other state-management
framework may be introduced.

Supporting packages:

```text
bloc
flutter_bloc
equatable
```

---

# State Ownership

## Global State

- App lock state (unlocked/locked)
- Theme (dark; see ADR-037)

## Feature State

Each feature owns its own state: Profile, Exercise Catalogue, Plans, Schedule, Workout Execution,
History, Progress, Statistics. Feature state shall not be shared directly with other features.

## Screen State

UI-specific state (form validation, selected items, loading indicators, dialog visibility) shall
remain inside the corresponding Bloc. Widgets must remain stateless whenever practical.

---

# Principles

### Event-Driven Architecture

```text
User Action → Bloc Event → Business Logic → Repository (Drift) → New State → UI Update
```

### Single Source of Truth

Each feature shall have exactly one primary `Bloc` responsible for managing its business state.

### Immutable State

All state objects shall be immutable; state updates always create new instances.

### Unidirectional Data Flow

```text
UI → Event → Bloc → Use Case → Repository → Drift → State → UI
```

### Business Logic Isolation

Business rules reside inside Bloc, Use Cases, and the Domain layer — never inside Widgets.

---

# Prohibited

- Riverpod, GetX, MobX
- Business logic inside Widgets
- Mutable state
- Calling Drift directly from UI
- Sharing Bloc state between unrelated features

---

# Alternatives Considered

## Cubit

Rejected — allowing both Bloc and Cubit requires every feature to specify a choice and leads to
inconsistent AI-generated implementations. No feature may use `Cubit`.

## Riverpod

Rejected — introduces an additional architectural pattern for no benefit at this app's scope.

## Provider

Rejected — weaker fit for the active-workout timer's explicit state-transition needs
(in-progress/resting/finished) than an event-driven Bloc.

## GetX

Rejected — weak separation of concerns, encourages tightly coupled implementations.

---

# Consequences

## Positive

- Predictable state transitions (especially useful for the active-workout/rest-timer flow)
- High testability of business rules without a live database
- Consistent implementation across all 9 features

## Negative

- More boilerplate than Cubit or Provider would require for a POC this size — accepted for
  consistency and testability

---

# Compliance

All features shall use `flutter_bloc` with explicit-event `Bloc` classes. Introducing another
state management solution requires an approved ADR update.

---

# Related ADRs

- ADR-001 Architecture Style
- ADR-003 Routing
- ADR-004 Dependency Injection
