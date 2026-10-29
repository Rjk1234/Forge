# ADR-007 Error Handling

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp. Replaced the network/auth/API failure taxonomy
>   with the local-only failure taxonomy already defined in `SDS_v2.0.md` §8 (SDS-ERR-1 through
>   SDS-ERR-9): static login failure, Drift read/write failure, validation failure, cancelled
>   workout, statistics recalculation failure. The centralized-failure-mapping decision, layering,
>   and prohibited list are unchanged in spirit.

---

## Context

ForgeApp has no backend and no network calls; the only failure sources are local: Drift
read/write failures, business validation failures, and a small number of app-specific conditions
(a cancelled/interrupted workout, a statistics recalculation failure). SDS §8 already defines nine
error states (SDS-ERR-1–9); this ADR is the architectural mechanism that implements them
consistently.

---

## Decision

The application shall adopt a centralized error handling strategy. Raw exceptions must never be
exposed outside the Data layer. All failures must be transformed into standardized domain
failures.

---

## Error Flow

```text
Exception (e.g. DriftException)
↓
Failure Mapping
↓
Domain Failure
↓
Bloc State
↓
UI (SCR-27 generic read/write-failure templates, or a screen-specific instantiation of them)
```

---

## Failure Types

```text
LocalReadFailure        — maps to SDS-ERR-5 (Drift Read Failure)
LocalWriteFailure        — maps to SDS-ERR-6 (Drift Write Failure)
ValidationFailure        — maps to SDS-ERR-7
StaticLoginFailure       — maps to SDS-ERR-1
CancelledWorkoutFailure  — maps to SDS-ERR-8 (not really an error path, but modeled the same way for consistency)
StatisticsFailure        — maps to SDS-ERR-9
UnknownFailure
```

There is no `NetworkFailure`, `AuthenticationFailure` (token-based), or `AuthorizationFailure` —
none of these conditions can occur in a fully offline, single-local-user app.

---

## Domain Failure Hierarchies

Feature domains may define sealed failure hierarchies that extend the core `Failure` base class,
each declared `sealed` within the domain layer of its feature, residing in `domain/failures/`.

Examples: `PlanFailure` (plans domain), `WorkoutFailure` (workout domain), `ProfileFailure`.

---

## Error Ownership

### Data Layer

Responsible for: Drift exception handling, mapping `DriftException` to `LocalReadFailure` /
`LocalWriteFailure`.

### Domain Layer

Responsible for: failure definitions, business rule failures (e.g. one-plan-per-day conflict).

### Presentation Layer

Responsible for: displaying the SCR-27 generic templates (or screen-specific text built on them)
with retry. Must never process raw exceptions.

---

## User Experience

Errors must be human readable, actionable (retry, per SDS-ERR-5/6), and consistent across
features — using the exact templates already designed in the ForgeApp Design System
(`Doc/DESIGN-SYSTEM.md` §7 Patterns & States). A failed write is never represented as successful,
and retrying a failed write never creates a duplicate persisted record (SDS-ERR-6, FR-2/AC-3).

---

## Logging

All unexpected failures must be logged locally (ADR-020). No secrets exist to redact (no tokens,
no OTPs, no customer PII) — the only sensitive-adjacent data is the user's own profile fields
(name, fitness goal, height/weight), which should still not appear in logs verbatim.

---

## Retry Strategy

Retry support exists for `LocalReadFailure` and `LocalWriteFailure` only (SDS-ERR-5/6). There is
no network retry/backoff concept.

---

## Prohibited

- try/catch blocks inside UI widgets
- Displaying raw exception messages
- Isolated feature-specific error models that do not extend the core `Failure` hierarchy
- Returning null instead of failures
- Silent failure handling

---

## Alternatives Considered

### Exception-Based UI Handling

Rejected — creates inconsistent error behavior across the 9 features.

### Feature-Specific Error Models

Rejected — increases maintenance complexity versus one shared `Failure` hierarchy.

---

## Consequences

### Positive

- Consistent user experience, matching the already-published Design System error patterns
- Simplified debugging; direct traceability to SDS-ERR-1–9

### Negative

- Additional mapping layer for what is, ultimately, a small failure surface (Drift only)

---

## Related ADRs

* ADR-008 Local Storage
* ADR-020 Logging Strategy
* ADR-026 Form Validation Strategy
* ADR-027 Loading Empty Error States
