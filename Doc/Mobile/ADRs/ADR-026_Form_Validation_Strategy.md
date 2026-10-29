# ADR-026 Form Validation Strategy

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp. Removed the client/server validation split
>   entirely — ForgeApp has no backend, so the client is the sole and authoritative owner of every
>   validation rule (SDS-COMP-12, SDS-DATA-8). Removed `server_rejected` field state, server error
>   mapping, and localization (`context.l10n`) references (localization is deferred beyond POC —
>   see ADR-016 stub). Replaced the workflow list with ForgeApp's actual data-entry screens.

---

## Context

ForgeApp has several local data-entry workflows: static login (SCR-03), workout plan creation with
per-exercise type-gated targets (SCR-09), schedule assignment (SCR-13), and profile fields
(SCR-25). Since there is no backend, every validation rule — required fields, numeric ranges,
format checks, and the one-plan-per-weekday conflict rule — is owned entirely by the client
(SDS-COMP-12, SDS-DATA-8).

---

## Decision

All forms must implement a shared field state model and adhere to the validation standards
defined in this ADR. Validation is entirely client-owned; there is no server round-trip to defer
to.

---

## Field State Model

```text
pristine   — field has not been interacted with
dirty      — field has been touched or edited
valid      — field value passes all applicable checks
invalid    — field value fails a check
disabled   — field is not editable in the current context
readonly   — field displays a value that cannot be edited
```

(No `validating` or `server_rejected` states — there is no asynchronous remote check.)

---

## Validation Ownership

All validation is client-owned. Examples:

| Validation | Rule |
|---|---|
| Static login | Local string-match against the single hardcoded credential (SDS Appendix B) |
| Plan target fields | Gated by exercise type flag — weighted requires reps+weight, time-based requires duration, bodyweight requires reps only (SDS §6.1 SDS-DATA-3/4) |
| Schedule assignment | One plan per weekday maximum — reject a conflicting assignment (SDS §2.3) |
| Profile height/weight | Numeric range check (informational only, no calculations) |

---

## Validation Trigger Standards

| Trigger | Recommended Use |
|---|---|
| On blur | Required-field and format checks |
| On submit | Full validation pass before persisting to Drift |

The default trigger per form must be documented in that story's spec.

---

## User Experience Standards

- Validation messages must be clear and specific (e.g. "Weight must be greater than 0").
- Color must not be the only indicator of a validation error (matches the Design System's inline
  validation pattern — border color change plus an explicit helper-text line).
- Form submission must be debounced to prevent duplicate Drift writes from a double-tap.

---

## Prohibited

- Any reference to a "backend contract" owning field limits — there is no backend
- Displaying raw exception messages instead of a validation message
- Multiple simultaneous submissions of the same form (e.g. double-tapping Save on Profile)

---

## Alternatives Considered

### Deferring Validation to Persistence-Time Only

Rejected — poor UX; users should see a field-level error while editing (SDS-NFR-17: "invalid
input produces clear feedback"), not only after a failed Drift write.

---

## Consequences

### Positive

- Simple: one validation owner, no client/server split to keep in sync
- Direct traceability to SDS-DATA-8 and SDS-COMP-12

### Negative

- None significant — this is simpler than the split model it replaces

---

## Related ADRs

* ADR-007 Error Handling
* ADR-027 Loading Empty Error States
