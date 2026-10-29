# ForgeApp Solution Architecture

> **Architecture Baseline:** This document consolidates the architectural foundation of ForgeApp.
> Accepted ADRs take precedence where a conflict exists. It serves as the navigational reference
> for architecture, module boundaries, technology stack, dependency rules, security, navigation,
> and ADR references.

Version: 2.0 (ForgeApp)

Status: Accepted

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp's actual single-user, fully offline, Drift-only,
>   phone-only architecture. Folder structure trimmed to what ForgeApp actually needs (no
>   `network/`, `secure storage/`, `l10n/` generation, FCM, or analytics scaffolding). The Clean
>   Architecture layer structure, dependency-direction rules, error-handling flow, and testing/ADR
>   pointers are project-agnostic and carried forward.

## 1. Purpose

This document defines the architectural foundation of ForgeApp.

It serves as the source of truth for:

- Flutter application architecture
- Module boundaries
- Technology stack
- Dependency rules
- Security architecture
- Navigation architecture
- ADR references

This document is intentionally limited to the mobile application. ForgeApp has no backend,
infrastructure, DevOps, or administrative system to exclude — there simply isn't one.

## 2. Product Overview

Before making any architectural decisions, read and understand `app/PRODUCT_CONTEXT.md` and
`Doc/SDS_v2.0.md`. Those documents define product vision, business objectives, target users, core
capabilities, workflows, and product principles. The architecture must align with them.

Primary Platform:

- Android (Flutter, phone)
- iOS (Flutter, phone)

## 3. Architectural Goals

### Maintainability

Support independent feature ownership within a single-developer POC/MVP.

### Testability

Support comprehensive automated testing (`standards/testing-standards.md`).

### Simplicity

Prefer the smallest architecture that correctly solves ForgeApp's actual requirements — "enough,
not too much" (`app/PRODUCT_CONTEXT.md` §10). Do not build for scale, multi-user, or backend
integration this project does not have.

### Data Integrity

Since Drift is ForgeApp's only and permanent data store, correctness of local read/write handling
matters more than in an app that can re-fetch from a backend.

## 4. Architectural Principles

### AP-001 Fully Offline By Design

ForgeApp makes no network calls and has no backend. All data is created, read, updated, and
deleted entirely on-device via Drift (ADR-008). There is no sync, no cache-invalidation problem, and
no connectivity-loss handling to design for — the app behaves identically with or without a network
connection because it never uses one.

### AP-002 Clean Architecture

Business logic must remain independent of frameworks.

### AP-003 Feature Isolation

Features must remain independently maintainable.

### AP-004 Dependency Direction

Dependencies must always point inward.

### AP-005 Security By Design (Local Data Scope)

Data-handling requirements are implemented at the architecture level — see
`standards/security-standards.md`. There is no remote-attack surface to design against; the
concern is local data integrity, not network/backend security.

### AP-006 Testability By Default

All layers must support automated testing.

## 5. Architecture Style

### Architecture Pattern

```text
Clean Architecture
+ Feature First Structure
```

### Layer Structure

```text
presentation
application
domain
data
```

### Dependency Direction

```text
Presentation
↓
Application
↓
Domain

Data
↓
Domain
```

Domain layer must remain independent of:

- Flutter
- Drift
- Third-party packages

### Domain Ownership

Every business capability belongs to exactly one feature domain.

| Domain | ForgeApp Features |
|----------|-------------------------------------------------------------|
| Access | Static Local Login, App Lock/Unlock |
| Profile | User Profile (display name, fitness goal, experience, height/weight) |
| Exercise Catalogue | Browse seeded, read-only exercise list |
| Workout Planning | Create/Edit/Delete Workout Plans, per-exercise target fields |
| Scheduling | Weekly Workout Schedule assignment |
| Workout Execution | Pre-Start Overview, Active Workout logging, Rest Timer, Cancel/Finish |
| History | Workout History List and Detail |
| Progress | Progress Comparison (single-exercise, over time) |
| Statistics | Statistics Dashboard, Personal Bests (metric TBD — SDS §3.5) |

Cross-domain communication must occur only through public interfaces or shared services. Domains
must not directly depend on another domain's internal implementation. Shared models should remain
minimal and domain-agnostic to preserve clear ownership boundaries.

## 6. Mobile Module Architecture

### Foundation Modules

```text
Routing
Logging
Theme
Local Persistence (Drift)
```

There is no Authentication module beyond the static login check, no Authorization module (single
user, no roles), and no Analytics/Notifications/Crash Reporting/Localization foundation module —
none of these exist in ForgeApp (see `ADRs/README.md` — Removed/Deferred).

### Business Modules

```text
Access
├── Purpose
│   └── Gate the app behind a static local login and app-lock state.
├── Capabilities
│   ├── Static Login (hardcoded demo credential)
│   ├── App Lock / Unlock
│   └── Logout (re-locks; does not clear data)
├── Owned Data
│   └── Local App Access State (SDS-DATA-1)
└── Collaborates With
    └── Profile

────────────────────────────────────────────

Profile
├── Purpose
│   └── Manage the single local user's profile.
├── Capabilities
│   ├── Edit Profile (display name, fitness goal, experience level, height, weight)
│   └── View Profile
├── Owned Data
│   └── User Profile (SDS-DATA-2)
└── Collaborates With
    └── Access

────────────────────────────────────────────

Exercise Catalogue
├── Purpose
│   └── Present the seeded, read-only exercise catalogue.
├── Capabilities
│   └── Browse / Search Exercises
├── Owned Data
│   └── Exercise (SDS-DATA-3, seed data)
└── Collaborates With
    └── Workout Planning

────────────────────────────────────────────

Workout Planning
├── Purpose
│   └── Build workout plans from the exercise catalogue.
├── Capabilities
│   ├── Create / Edit / Delete Workout Plan
│   └── Per-exercise target fields, gated by exercise type
├── Owned Data
│   └── Workout Plan (SDS-DATA-4)
└── Collaborates With
    ├── Exercise Catalogue
    └── Scheduling

────────────────────────────────────────────

Scheduling
├── Purpose
│   └── Assign plans to weekdays.
├── Capabilities
│   ├── View Weekly Schedule
│   ├── Assign / Edit Plan-to-Weekday (one plan per weekday max)
│   └── Remove Plan from Schedule
├── Owned Data
│   └── Workout Schedule (SDS-DATA-5)
└── Collaborates With
    ├── Workout Planning
    └── Workout Execution

────────────────────────────────────────────

Workout Execution
├── Purpose
│   └── Run an active workout session.
├── Capabilities
│   ├── Pre-Start Overview
│   ├── Set-by-Set Logging
│   ├── Rest Timer (auto-start, skippable)
│   ├── Cancel Confirmation (always discards fully)
│   └── Workout Summary
├── Owned Data
│   └── Workout Session (SDS-DATA-6)
└── Collaborates With
    ├── Scheduling
    └── History

────────────────────────────────────────────

History, Progress & Statistics
├── Purpose
│   └── Review completed workouts.
├── Capabilities
│   ├── History List / Detail
│   ├── Progress Comparison (single-series line chart)
│   └── Statistics Dashboard, Personal Bests (metric TBD)
├── Owned Data
│   └── Derived Statistics (SDS-DATA-7)
└── Collaborates With
    └── Workout Execution
```

### Module Rules

Each module owns:

- UI
- State
- Use Cases
- Repository Contracts

Modules must not access another module's internal implementation.

## 7. Folder Structure

```text
project/
│
├─ assets/                                      # Static assets bundled with the application
│  ├─ fonts/                                    # Custom font files
│  ├─ icons/                                    # Icon assets (PNG, SVG, etc.)
│  └─ images/                                   # Images (PNG, JPG, WebP)
│
├─ docs/                                        # Architecture docs, ADRs (mirrors Doc/Mobile)
│
├─ lib/
│  │
│  ├─ app/                                      # Application composition and startup
│  │  ├─ bootstrap/                             # App initialization and startup logic
│  │  ├─ di/                                    # Dependency injection registration (GetIt)
│  │  └─ app.dart                               # Root application widget
│  │
│  ├─ config/                                   # Cross-cutting configuration (ADR-001 exemption)
│  │  ├─ routes/                                # go_router configuration
│  │  └─ theme/                                 # Centralized Design System theme implementation
│  │
│  ├─ core/                                     # Shared technical infrastructure
│  │  ├─ constants/                             # Application-wide constants
│  │  ├─ enums/                                 # Shared enums
│  │  ├─ errors/                                # Failure models and error abstractions
│  │  ├─ exceptions/                            # Custom exception definitions
│  │  ├─ extensions/                            # Dart and Flutter extension methods
│  │  ├─ formatters/                            # Date/number/text formatters
│  │  ├─ logger/                                # Logging infrastructure (ADR-020)
│  │  ├─ result/                                # AppResult<T> / Either-style result type
│  │  ├─ storage/                               # database access services (`AppDatabase`) (ADR-008, ADR-031)
│  │  ├─ use_cases/                             # Base UseCase abstractions
│  │  ├─ validators/                            # Shared validators (ADR-026)
│  │  └─ widgets/                               # Reusable application-wide widgets
│  │
│  ├─ features/                                 # Business features/modules
│  │  │
│  │  ├─ access/
│  │  ├─ profile/
│  │  ├─ exercise_catalogue/
│  │  ├─ workout_planning/
│  │  ├─ scheduling/
│  │  ├─ workout_execution/
│  │  ├─ history/
│  │  ├─ progress/
│  │  └─ statistics/
│  │  │      (each with data/domain/application/presentation + a barrel file — see §6)
│  │
│  └─ gen/                                      # Generated code (drift_dev .g.dart files)
│
├─ test/                                        # Test suite
│  ├─ core/                                     # Shared infrastructure tests
│  └─ features/                                 # Feature tests
│
└─ tool/                                        # Development scripts, seed-data generators
```

There is no `l10n/` (localization deferred, ADR-016), no `core/network/` or `core/security/`
(no network calls, no secrets to protect), and no `core/services/` for analytics/FCM/deep-link
(none of these exist in ForgeApp). All features must remain self-contained.

## 8. Technology Stack

Technology decisions are owned by their respective ADRs. This section is a navigational index only.

| Concern | ADR |
| --- | --- |
| State Management | ADR-002 |
| Routing | ADR-003 |
| Dependency Injection | ADR-004 |
| Local Storage | ADR-008 |
| Logging | ADR-020 |
| Modularization | ADR-032 |
| Environment Management | ADR-033 |
| Theme Architecture | ADR-037 |

## 9. Data Flow Architecture

All features must follow:

```text
UI
↓
Bloc
↓
Use Case
↓
Repository
↓
AppDatabase (Drift)
```

Direct Drift access from UI is prohibited.

## 10. Navigation Architecture

Navigation shall be centralized through GoRouter.

Supported entry points:

```text
Application Navigation (in-app only)
```

There is no push-notification or deep-link entry point — ForgeApp has no backend to send a push
notification from, and no external caller to deep-link in from.

Navigation flow:

```text
Entry Point
↓
Router
↓
App-Lock Guard (ADR-003)
↓
Destination
```

## 11. Authentication & Access Architecture

### Single-User Model

ForgeApp has exactly one local user per install and no role system (`app/user role matrix.md`).
There is no Role-Based Access Control, no per-feature permission check, and no backend to be the
source of truth for roles — the entire access model is the app-lock guard: locked vs. unlocked.

---

### Access Responsibilities

```text
Static Local Login (hardcoded demo credential)
App Lock / Unlock
Logout (re-lock only; does not clear local data)
```

---

### Access Principles

- Every screen beyond static login requires the app to be unlocked.
- There is no per-feature authorization check beyond the app-lock guard itself — once unlocked,
  the single local user has access to every feature.
- The static demo credential is not a real secret; it is not stored as if it were one (see
  `standards/security-standards.md` §2).

## 12. Networking Architecture

Not applicable. ForgeApp makes no network calls and has no networking abstraction to route through
(ADR-005 — removed as not applicable; see `app/platform-requirements.md` — Prohibited).

## 13. Error Handling Architecture

All failures must follow a centralized error handling strategy.

Raw exceptions must never be exposed outside the Data layer.

### Error Flow

```text
Exception (e.g. DriftException)
↓
Failure Mapping
↓
Domain Failure
↓
State
↓
UI
```

### Layer Responsibilities

```text
Data Layer
Catches exceptions and maps to domain failures.

Domain Layer
Defines failure contracts.

Presentation Layer
Renders user-facing messages only.
```

→ See ADR-007 for failure types, prohibited patterns, and the full error taxonomy (SDS §Appendix
around SDS-ERR-1 through SDS-ERR-9).

## 14. Storage Architecture

### Local Storage (Drift)

Drift is ForgeApp's **sole** persistence layer — not a preferences-only cache alongside a secure
store, but the complete data store for every entity: access state, profile, exercise catalogue,
workout plans, schedules, sessions, and derived statistics (ADR-008, SDS-COMP-13).

There is no Secure Storage module — there are no tokens, no refresh credentials, and nothing that
qualifies as a secret to isolate from the rest of Drift.

→ See ADR-008 (Local Storage) and ADR-031 (Path Provider) for implementation decisions.

## 15. Notification Architecture

Not applicable. ForgeApp has no push notifications, no backend to send them from, and no in-app
notification/badge system (ADR-013 — removed as not applicable).

## 16. Analytics Architecture

Not applicable. There is no analytics provider, and no event-tracking requirement — this is a
POC/MVP measured by functional completeness, not usage metrics (`app/PRODUCT_CONTEXT.md` §8, §9).

## 17. Security Architecture

### Data Handling

- No hardcoded values other than the one documented static demo credential
- No sensitive values logged
- Drift read/write failures always surface through the typed failure taxonomy, never silently

### Compliance

ForgeApp collects no data that leaves the device and has no third party with access to it, so no
external privacy or cybersecurity regulation regime applies to its architecture in the way one
would to a backend-connected app (see `standards/security-standards.md` §5).

→ See `standards/security-standards.md` for the full local data-handling and secure coding
checklist.

## 18. Performance Architecture

### Target Platforms

```text
Android
├── Android 10 (API 29)+
└── Representative mid-range Android phones

iOS
├── iOS 15+
└── Representative supported iPhones
```

There is no tablet or iPad target (ADR-022, reduced scope) and no network condition to design for
— ForgeApp performs no network requests.

### Performance Objectives

```text
Fast Application Startup

Responsive UI (60 FPS)

Efficient Battery Usage

Minimal Memory Consumption

Non-blocking Drift I/O, particularly during the active-workout rest timer
```

Performance is a cross-cutting architectural concern and must be considered during all
implementation decisions.

→ See **ADR-021: Performance Architecture** for performance requirements and prohibited
implementation patterns.

## 19. Responsive Architecture

### Strategy

```text
Phone-Only, Single Flutter Codebase
Shared Design System
```

ForgeApp targets Android and iPhone phones only for this POC (ADR-022, reduced scope). Tablet/iPad
support and adaptive breakpoint layouts are explicitly deferred — not a day-one requirement.

---

### Supported Devices

```text
Android Phones
iPhone
```

---

### Orientation

```text
Portrait    Primary and tested orientation for this POC.

Landscape   Not a tested requirement for this POC.
```

---

### Design System

Spacing, typography, sizing, colors, and component styling come from the ForgeApp Design System
(`Doc/DESIGN-SYSTEM.md`), implemented per ADR-037. Layouts must respect standard Android system
insets and iOS safe areas.

→ See ADR-022 for the full reduced-scope rationale.

## 20. Localization Architecture

Initial Language:

```text
English
```

Deferred for this POC (ADR-016) — no second locale, no translation pipeline, no `l10n/` generation
step exists yet. All user-facing strings may be inline for now; if localization is picked up later,
strings should be extracted into an ARB-based pipeline at that time, not built speculatively now.

## 21. Testing Architecture

Testing requirements, coverage targets, and quality gates are fully documented in:

→ `standards/testing-standards.md`

## 22. Architecture Decision Records (ADR)

```text
ADR-001 Architecture Style
ADR-002 State Management
ADR-003 Routing
ADR-004 Dependency Injection
ADR-007 Error Handling
ADR-008 Local Storage
ADR-015 Crash Reporting (Deferred Scope)
ADR-016 Localization (Deferred Scope)
ADR-020 Logging Strategy
ADR-021 Performance Architecture
ADR-022 Responsive Architecture (Reduced Scope)
ADR-026 Form Validation Strategy
ADR-027 Loading Empty Error States
ADR-028 Accessibility Strategy (Reduced Scope)
ADR-030 Dependency Versioning Governance
ADR-031 Path Provider
ADR-032 Modularization Strategy
ADR-033 Environment Management
ADR-036 App Update Strategy (Deferred Scope)
ADR-037 Theme Architecture
```

The full removed-ADR list (network, API, auth/RBAC, QR, GPS, push, analytics, secure storage,
image caching, etc.) is in `ADRs/README.md` — none of it applies to ForgeApp.

## 23. Supporting Documents

The following documents complement the ADRs and are maintained in the canonical docs structure:

```text
app/platform-requirements.md          Flutter/Dart SDK versions, Android/iOS build config, FVM
Doc/DESIGN-SYSTEM.md                  Colors, typography, spacing, component conventions
Doc/SDS_v2.0.md                       System Design Specification — components, data, error taxonomy
standards/testing-standards.md        Test types, coverage requirements, mocking strategy, quality gates
```

## 24. Out of Scope

The following are intentionally excluded from ForgeApp's architecture, not because they were
overlooked but because the app has no backend, no multi-user need, and no distribution requirement
that would call for them:

```text
Backend / API Integration

Remote Configuration / Feature Flags

Multi-User / Role-Based Access Control

Push Notifications

Analytics / Crash Reporting (deferred)

CI/CD Architecture

Tablet/iPad Support (deferred)

App Store Distribution
```

These may be introduced through future architecture decisions if this POC is ever extended toward
a production, multi-user, backend-connected product.
