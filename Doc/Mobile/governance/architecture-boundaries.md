# ForgeApp — Flutter App Architecture Boundaries

Violation of these boundaries requires an ADR filed in `ADRs/`. AI agents must enforce these
boundaries and refuse to implement code that violates them.

This document has one job: the boundary around **ForgeApp's own runtime** — what it may and may
not do, given that it is a fully offline, single-local-user app with no backend and no platform to
share with. It does not restate the app's internal architecture (layering, module structure,
folder tree, tech stack) — that lives in `governance/solution-architecture.md`,
`app/platform-requirements.md`, and the ADRs.

---

## 1. ForgeApp ↔ Device Boundary

**Purpose**: A single-user, fully offline Flutter application for Android and iOS phones, with no
shared backend, no other client, and no multi-device sync.

### CAN
- Implement all UI using Flutter widgets
- Persist all application data — profile, exercise catalogue, workout plans, schedules, sessions,
  and derived statistics — in Drift, on-device (ADR-008)
- Implement its own local state management (`flutter_bloc`, ADR-002)

### CANNOT
- Make any network call, connect to a backend, or introduce a REST/GraphQL/gRPC client — ForgeApp
  is fully offline by design (see `app/platform-requirements.md` — Prohibited)
- Introduce Firebase, push notifications, analytics, or any remote service
- Introduce device permissions (camera, location, biometrics) that no current feature requires
- Import packages outside the governed set in ADR-030 without a new ADR

Since there is no backend and no other client, there is no authorization/pricing/assignment
decision to keep off-device, no API key or JWT secret to protect, and no cross-app package boundary
to enforce — these concerns from a typical client/server mobile app simply do not exist here.

---

## 2. Internal Flutter Architecture Constraints — Pointers

The app's internal architecture rules (feature isolation, domain-layer purity, state
management/DI exclusivity, navigation exclusivity, folder ownership, naming/lint conventions) are
decided and documented elsewhere. Do not duplicate them here — follow these sources directly:

| Concern | Authoritative source |
|---|---|
| Clean Architecture layering, folder structure, domain ownership | `governance/solution-architecture.md` |
| Feature isolation, module ownership, package-extraction criteria | `ADRs/ADR-032_Modularization_Strategy.md` |
| Architecture style (Clean + Feature-First) | `ADRs/ADR-001_Architecture_Style.md` |
| State management (`flutter_bloc`; Bloc) | `ADRs/ADR-002_State_Management.md` |
| Navigation (GoRouter, exclusive) | `ADRs/ADR-003_Routing.md` |
| Dependency injection (GetIt, exclusive) | `ADRs/ADR-004_Dependency_Injection.md` |
| Local persistence (Drift, exclusive) | `ADRs/ADR-008_Local_Storage.md` |
| Naming conventions, lint rules, code generation | `standards/coding-standards.md` |
| Testing standards, coverage targets | `standards/testing-standards.md` |
| Code review checklist | `standards/code-review-checklist.md` |
| Flutter/Dart/Android/iOS SDK constraints, approved packages | `app/platform-requirements.md` |
| Theming and Design System | `ADRs/ADR-037_Theme_Architecture.md`, `Doc/DESIGN-SYSTEM.md` |

ADRs in this table are accepted architecture constraints after the 2026-09-08 review that adapted
this ADR set to ForgeApp (see `ADRs/README.md`).

---
