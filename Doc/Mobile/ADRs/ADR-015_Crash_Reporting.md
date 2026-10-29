# ADR-015 Crash Reporting

Version: 2.0 (ForgeApp — Deferred)

Status: Accepted (Deferred Scope)

---

> **Changelog**
> - **2.0 (2026-09-08):** Reduced to a deferred stub for ForgeApp. Firebase Crashlytics/Performance
>   Monitoring requires a Firebase project and, implicitly, network reachability to report — neither
>   fits a fully offline POC with no backend. Deferred beyond POC scope per the "enough, not too
>   much" scoping principle applied throughout this project's documentation.

---

## Context

ForgeApp is a POC/MVP with no backend and no Firebase project (SDS §2.3). Centralized crash
reporting and remote performance monitoring provide little value at this scope — there is no
production user base to monitor, and no team on the other end of a Crashlytics dashboard.

---

## Decision

Crash reporting and remote performance monitoring are **deferred beyond POC scope**. The app
relies on:

- Local logging (ADR-020) during development
- Flutter's own `FlutterError.onError` / `PlatformDispatcher.instance.onError` handlers, logged
  locally, for surfacing uncaught errors during development and testing

If ForgeApp is ever taken toward production distribution, this ADR should be revisited and a real
crash-reporting decision made at that time — not designed for speculatively now.

---

## Consequences

### Positive

- No Firebase/Crashlytics dependency, no privacy-review burden, no added SDK weight for a POC

### Negative

- No remote visibility into crashes on a device the developer doesn't have in hand — acceptable
  for a POC/assignment context

---

## Related ADRs

* ADR-020 Logging Strategy
