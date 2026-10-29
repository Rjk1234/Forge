# ADR-027 Loading Empty Error States

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp. Removed `network_error`, `server_error`, and
>   `permission_blocked` states (no network, no device permissions gate any screen). Replaced with
>   the local-read/write failure states already defined in SDS §8 and already designed in the
>   ForgeApp Design System (`Doc/DESIGN-SYSTEM.md` §7) and SCR-27's generic templates. This ADR is
>   now the code-side mechanism that implements those already-approved visual patterns.

---

## Context

ForgeApp has many data-driven screens backed by Drift reads: Home, Plans, Schedule, History,
Progress, Statistics, and more. Without a shared screen state model, different features could
implement inconsistent loading, empty, and error behavior — the exact problem the Design System's
Patterns & States section (loading skeleton, empty state, generic error/retry templates) already
solves visually. This ADR is the Bloc-side state model that drives those already-designed visuals.

---

## Decision

Every async screen must implement the standard screen state model below. Blank screens are
prohibited — every state transition must produce a defined, intentional UI, using the patterns
already published in the Design System.

---

## Standard Screen State Model

```text
initial            — screen has mounted; no Drift read requested yet
loading             — first-time Drift read in progress
refreshing          — refresh while existing data is displayed
success             — data loaded successfully
empty               — no data available (Design System: Empty State pattern)
validation_error     — invalid user input (ADR-026)
business_blocked     — a local business rule prevents the operation (e.g. one-plan-per-day conflict)
local_read_error     — Drift read failed (SDS-ERR-5; Design System: Read Failure template)
local_write_error     — Drift write failed (SDS-ERR-6; Design System: Write Failure template)
unknown_error        — unclassified failure
```

---

## State UX Guidelines

| State | Required Behavior |
|---|---|
| `loading` | Layout-matched skeleton for the initial load (Design System §7). Do not clear existing content during refresh. |
| `refreshing` | Preserve existing content while refreshing. |
| `empty` | Show the Design System's empty-state pattern with contextual copy (e.g. "Create your first plan"). |
| `business_blocked` | Explain why the action can't continue (e.g. "This weekday already has a plan assigned"). |
| `local_read_error` | Design System Read Failure template, with retry, preserving previously loaded content when available. |
| `local_write_error` | Design System Write Failure template — never represents the write as successful; retry never creates a duplicate (SDS-ERR-6, FR-2/AC-3). |
| `unknown_error` | Generic error state; log diagnostics (ADR-020). |

---

## Retry Behavior

Retry re-issues the same Drift read/write; retrying a write must never create a duplicate
persisted record (SDS-ERR-6).

---

## Confirmation Before Destructive/Committing Actions

Business-critical local actions require confirmation using the Design System's confirmation
modal convention (destructive red for irreversible actions — delete plan, cancel workout, logout;
lime for reversible ones — remove from schedule). Actions display success only after the Drift
write actually completes.

---

## Prohibited

- Blank screens for any loading, empty, or error condition
- Erasing displayed content during a background refresh
- Swallowing errors silently
- Retrying a write automatically without user intent (would risk duplicate records)

---

## Alternatives Considered

### Feature-Specific State Models

Rejected — inconsistent UX and prevents reusing the Design System's shared error/empty widgets.

---

## Consequences

### Positive

- Consistent, predictable UX across all features, matching the already-published Design System
- No blank screens or unhandled async states

### Negative

- Every screen Bloc must handle the applicable state set

---

## Related ADRs

* ADR-007 Error Handling
* ADR-026 Form Validation Strategy
* ADR-002 State Management
