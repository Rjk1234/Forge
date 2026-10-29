# ADR-030 Dependency Versioning Governance

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp with its actual, much smaller governed dependency
>   set — no backend, no device sensors, no Firebase. Removed tablet/iPad platform-compatibility
>   validation step (POC scope: phone only, see ADR-022).

---

## Context

ForgeApp's Flutter codebase relies on a small, defined set of packages established by the ADRs in
this set. Without explicit governance, unapproved packages could introduce a second state
management or routing framework, or (more likely at POC scale) unnecessary backend/analytics/SDK
dependencies that don't belong in an offline single-user app.

---

## Decision

All dependency governance is centralized in `pubspec.yaml`. No new dependency may be introduced
without justification against an approved module need.

---

## Governance Rules

| Rule | Detail |
|---|---|
| No second state management framework | `flutter_bloc` is the sole state management solution (ADR-002). |
| No second routing framework | `go_router` is the sole routing solution (ADR-003). |
| No network/HTTP packages | ForgeApp has no backend — `http`, `dio`, or any network client is out of scope entirely. |
| No secure-storage package | There are no secrets to protect (ADR-008/SDS Appendix B) — `flutter_secure_storage` is not needed. |
| Testability requirement | New packages must support unit testing and mocking. |

---

## Governed Core Dependency Set

```text
State Management     flutter_bloc, bloc, equatable
Routing               go_router
Dependency Injection  get_it
Local Persistence     drift, sqlite3_flutter_libs, path_provider, path
Code Generation       build_runner, drift_dev
Testing               flutter_test, bloc_test, mocktail
Build tooling (dev)    flutter_native_splash (generates native splash screens; no runtime code)
```

That is the complete governed set. There is deliberately no network, secure-storage, Firebase,
permissions, QR/camera, or localization package in this list — none of those capabilities exist
in ForgeApp (POC/MVP scope, SDS §2.3–2.4).

---

## Version Management Standards

- All dependency version pins/ranges are defined in `pubspec.yaml`.
- Flutter itself must not be pinned to an exact release; use the latest stable release compatible
  with the Dart environment constraint (`^3.12.2` per the current `pubspec.yaml`, or later within
  the same major).
- Breaking package updates require review and an ADR amendment if architecturally significant.

---

## New Dependency Approval Process

1. Identify the specific technical need not met by an existing approved package.
2. Verify compatibility with the code generation toolchain (`build_runner`) if applicable.
3. Evaluate testability (mockability).
4. Document the justification in the PR description.

---

## Prohibited

- Introducing a second state management, routing, or persistence library
- Adding a network client, analytics SDK, or crash-reporting SDK (out of POC scope)
- Adding packages to feature code without updating `pubspec.yaml`

---

## Alternatives Considered

### Per-Feature Dependency Autonomy

Rejected — produces incompatible frameworks and version conflicts even at this small scale.

---

## Consequences

### Positive

- A genuinely small, auditable dependency set — appropriate for a POC/MVP
- No governance overhead for capabilities the app doesn't have

### Negative

- If the app later grows a real backend, this ADR (and ADR-008/033) will need real revision, not
  just a note — that is a deliberate future decision point, not something to design for now

---

## Related ADRs

* ADR-001 Architecture Style
* ADR-002 State Management
* ADR-003 Routing
* ADR-004 Dependency Injection
* ADR-008 Local Storage
