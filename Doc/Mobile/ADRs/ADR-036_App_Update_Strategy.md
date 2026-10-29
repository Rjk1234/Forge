# ADR-036 App Update Strategy

Version: 2.0 (ForgeApp — Deferred)

Status: Accepted (Deferred Scope)

---

> **Changelog**
> - **2.0 (2026-09-08):** Reduced to a deferred stub for ForgeApp. The backend-driven version-gate
>   model requires a backend Version API, which does not exist and will not exist for this POC.
>   Deferred entirely.

---

## Context

ForgeApp is not distributed through app stores at POC stage, has no backend, and therefore has no
mechanism (or need) to force or prompt an update.

---

## Decision

App update strategy is **deferred beyond POC scope**. If ForgeApp is ever prepared for real store
distribution, this ADR should be rewritten at that time against whatever backend (if any) exists
then — a backend-driven version gate assumes a backend this app deliberately does not have.

---

## Consequences

### Positive

- No update-gate implementation burden for a POC that isn't distributed through a store

### Negative

- None relevant at this scope

---

## Related ADRs

(none — this ADR has no dependencies at POC scope)
