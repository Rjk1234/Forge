# ADR-021 Performance Architecture

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp. Removed all network/4G-conditioned performance
>   goals (no network calls exist) and all tablet/iPad/multi-window performance validation (POC
>   scope trim — phone-only, one form factor; see ADR-022). Reframed performance entirely around
>   local Drift I/O and UI responsiveness, which are the only performance concerns this app has.

---

## Context

ForgeApp is a fully offline, phone-only POC. There is no network latency to manage. The
performance concerns that remain are local: Drift read/write speed, list rendering (exercise
catalogue, history, plans), and the active-workout/rest-timer's need to stay smooth and accurate
without any I/O blocking the timer (SDS-COMP-7, SDS-NFR-1/2/3).

---

## Decision

Performance shall be treated as a cross-cutting architectural concern, scoped to what this app
actually does: local storage I/O and UI responsiveness on a single mid-range Android/iOS phone
baseline.

---

## Performance Goals

### Target Device

A single representative mid-range Android phone and iPhone (phone only — no tablet/iPad
validation for this POC; see ADR-022).

### Application Goals

- Fast startup (no session restore from a server — just an app-lock check and, if unlocked, a
  Drift read)
- Fast screen navigation
- Smooth active-workout/rest-timer updates, unaffected by concurrent Drift writes
- Minimal memory usage

### Performance KPIs

Cold start under 3 seconds. Additional KPIs may be defined during implementation.

---

## Architecture Principles

### Performance By Design

Performance must be considered during architecture decisions, not postponed until after
implementation.

### Asynchronous Drift Access

All Drift reads/writes must be asynchronous and must never block the UI thread — critical for the
active-workout timer (SDS-COMP-7: "Drift reads/writes are local and do not block on network").

---

## UI Performance

- Widget rebuilds must be minimized; UI should rebuild only affected components.
- Large lists (exercise catalogue, history, plans) must use `ListView.builder`.
- Heavy business logic (statistics recalculation) must never execute during animation frames or
  block the rest timer's tick.

---

## State Management Performance

State updates must be granular, avoid full-screen rebuilds, and avoid duplicated state. State
ownership must remain localized to its owning Bloc (ADR-002).

---

## Memory Management

The application must dispose controllers, subscriptions, and streams properly (particularly the
active-workout timer's `Stream`/`Timer`). Memory leaks are prohibited.

---

## Startup Performance

```text
Open AppDatabase → Check App Lock State → Launch Application (Login or Home)
```

There is no session restore step — the app-lock check is the entire startup decision.

---

## Prohibited

- Synchronous Drift calls on the UI thread
- Large dataset loading without pagination where a list can grow unbounded (history)
- Excessive widget rebuilds
- Memory leaks in the active-workout timer

---

## Alternatives Considered

### Performance Optimization After Development

Rejected — the active-workout timer's smoothness is a first-class requirement (SDS-COMP-7), not
an afterthought.

### Multi-Device-Class Validation (tablet/iPad)

Rejected for this POC — deferred, see ADR-022 (Responsive Architecture, POC scope: phone only).

---

## Consequences

### Positive

- Simple, well-scoped performance surface (no network variables to account for)
- Direct traceability to SDS-NFR-1/2/3

### Negative

- None significant at this scope

---

## Related ADRs

* ADR-002 State Management
* ADR-008 Local Storage
* ADR-022 Responsive Architecture
