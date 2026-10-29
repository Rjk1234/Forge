# ADR-031 Path Provider

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp. Removed log-export and temporary-media use
>   cases (no media capture, no log export at POC scope). The sole remaining use case is resolving
>   the application documents directory in which `AppDatabase` stores its database file.

---

## Context

`AppDatabase` (Drift, ADR-008) stores all application data in a single SQLite file, `forge.sqlite`,
which must live in a platform-appropriate application documents directory. Direct use of hardcoded
paths is not portable across Android and iOS.

---

## Decision

The application shall use `path_provider` directly, inside `AppDatabase`, as the approved
mechanism for resolving the application documents directory (`getApplicationDocumentsDirectory()`),
joined with the `forge.sqlite` file name via `path`. No feature module resolves file system paths
itself, because no feature needs to — this is purely the database's own startup concern.

---

## Approved Use Case

| Use Case | Directory | API |
|---|---|---|
| Drift database file (`forge.sqlite`) | Application documents directory | `getApplicationDocumentsDirectory()` from `path_provider`, called by `AppDatabase` |

---

## Scope Constraints

- `path_provider` is used in exactly one place, `AppDatabase`; feature code never calls it.
- There is no temporary file storage, no media capture, and no log export — none of these
  capabilities exist in this app.

---

## Prohibited

- Feature modules using `path_provider` directly
- Any file-system storage outside the Drift database file

---

## Alternatives Considered

### Hardcoded paths

Rejected — not portable across Android and iOS.

---

## Consequences

### Positive

- Portable, sandbox-compliant database location, resolved in one place, with essentially no ongoing governance burden

### Negative

- `AppDatabase` depends on `path_provider`, so the package is part of the governed set (ADR-030)
  and must be mocked or bypassed (in-memory database) in tests

---

## Related ADRs

* ADR-008 Local Storage
