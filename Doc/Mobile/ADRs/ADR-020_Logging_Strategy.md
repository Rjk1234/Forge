# ADR-020 Logging Strategy

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp. Removed network/authentication-token/analytics/
>   crash-reporting/QR logging concerns (no backend, no tokens, analytics and crash reporting are
>   deferred beyond POC scope — see ADR-014/ADR-015 deletion and stub). Removed log export (no
>   support team to send diagnostics to at POC scope). Kept the sanitization principle, scoped to
>   the one thing ForgeApp actually has that's user-entered: profile fields.

---

## Context

ForgeApp requires consistent logging across its local-only features (app lock, profile, plans,
schedule, workout execution, history, progress, statistics) to support troubleshooting and
diagnostics during development. There is no network, no authentication tokens, and no analytics
or crash-reporting SDK in scope for this POC.

---

## Decision

The application shall adopt a centralized logging strategy. All logging shall be performed
through a shared Logging Service; direct use of `print()` or ad hoc logger instances from feature
modules is prohibited.

---

## Logging Framework

The application shall use `logger` (or an equivalent lightweight Dart logging package) as the
primary logging framework. Logging implementation must remain replaceable.

---

## Logging Architecture

```text
Feature → Logging Service → Logger → Console (dev) / no-op or file (release)
```

---

## Log Levels

`Debug, Info, Warning, Error`. Debug logging must be disabled in release builds.

---

## What May Be Logged

- Drift read/write failure events (SDS-ERR-5/6): feature, operation, table name
- App-lock transitions (locked/unlocked) — event name only
- Statistics recalculation failures (SDS-ERR-9)
- Navigation (`from → to`) for debugging

---

## Sensitive Data Protection

Profile fields (display name, fitness goal, experience level, height/weight) must not be logged
verbatim — mask or omit their values, logging only that a profile write occurred. There are no
tokens, passwords, or OTPs to redact, since none exist in this app.

---

## Prohibited

- `print()` for application logging
- Direct logger usage in feature modules (must go through the shared Logging Service)
- Logging raw profile field values
- A separate analytics or crash-reporting pipeline (out of POC scope — see ADR-014/ADR-015)

---

## Alternatives Considered

### print()

Rejected — no structure, and gets stripped/ignored inconsistently across build modes.

### Feature-Owned Logging

Rejected — inconsistent logging behavior across 9 features.

---

## Consequences

### Positive

- Consistent diagnostics during development
- Trivial to disable entirely for release builds

### Negative

- One more abstraction layer for what is, at this scope, a small amount of logging

---

## Related ADRs

* ADR-007 Error Handling
