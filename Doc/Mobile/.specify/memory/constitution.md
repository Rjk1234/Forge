<!--
Sync Impact Report
- Version change: (none previously ratified) -> 1.0.0 (ForgeApp, initial ratification)
- Date: 2026-09-08
- Bump rationale: 1.0.0 is the initial ratified constitution for ForgeApp — a single-developer,
  fully offline, single-local-user, Drift-only Flutter workout tracker POC/MVP (see
  `Doc/SDS_v2.0.md`, `app/PRODUCT_CONTEXT.md`).
- Principles established: Product Mandate (ForgeApp scope); I Clean/Feature-First Architecture;
  II Exclusive Architectural Mechanisms (Drift-only persistence); III Centralized Routes (app-lock
  guard only, no deep link/QR/push entry points); IV Local Access Authority; V Local Data Handling
  (no network/permission surface exists); VI Fully Offline By Design (Drift is the *only* store, not
  a restricted preferences cache); VII Explicit, Locally-Confirmed User States; VIII Reduced-Scope
  Theme/Adaptive/Accessibility/Localization (phone-only/single-theme/reduced-accessibility/
  deferred-localization, matching approved POC scoping); IX Governed SDKs and Dependencies (no
  environment flavors, no Firebase); X Centralized Logging (no analytics/crash/performance
  monitoring — not applicable); XI Testability and Evidence (no four-device matrix); XII SDD
  Lifecycle and Review Gates (a single-developer G-01..G-04 gate set — see
  `governance/review-gate-framework.md`); a Mandatory Rule on No Git Operations.
- Templates inspected: `.specify/templates/plan-template.md`, `spec-template.md`, and
  `tasks-template.md` were not modified by this pass — they are generic SpecKit scaffolding and
  remain compatible with the principles below.
- ADR status handling: this constitution's Source Traceability table (below) reflects the current
  ADR set in `ADRs/README.md` — 20 Accepted (5 of them Deferred/Reduced Scope) and 18 Removed —
  Not Applicable (no backend, RBAC, QR/GPS/camera/push, or media-upload capability exists in
  ForgeApp).
- Open items tracked from `Doc/SDS_v2.0.md` (not resolved by this constitution — genuinely open
  product decisions, not constitutional gaps): the Personal Best metric definition (SDS §3.5
  Decision #1) and app-backgrounded rest-timer behavior (SDS §3.5 Decision #2). Neither is
  constitutional; both remain feature-level decisions to resolve when the owning feature is
  specified.
- This sync used filesystem inspection only and performed no Git or GitHub operations.
-->

# ForgeApp Constitution

## ForgeApp Product Mandate

1. ForgeApp is one Flutter application, fully offline, for exactly one local user per device
   install, on Android and iPhone phones. There are no roles, no permission tiers, and no
   multi-account concept (`app/user role matrix.md`; SDS §2.3 Assumptions).
2. Product scope is: static local login and app-lock, user profile, a seeded read-only exercise
   catalogue, workout plan creation/editing, weekly scheduling, workout execution (rest timer,
   set-by-set logging), workout history, progress comparison, and statistics (including Personal
   Bests, metric TBD — SDS §3.5).
3. Any backend, cloud sync, multi-device access, multi-user account/role system, push
   notification, QR scanning, GPS/location tracking, camera/media capture, social/sharing feature,
   analytics, or crash/remote monitoring is outside ForgeApp (`app/PRODUCT_CONTEXT.md` §9
   Non-Goals). None of these may be introduced without a new ADR that revises this Mandate.
4. ForgeApp MUST remain fully offline. It MUST NOT make a network call, connect to a backend, or
   introduce a REST/GraphQL/gRPC client.
5. The Drift database is the single source of truth for all application data — there is no backend to defer to
   (see Principle VI; this is the direct inverse of a typical client/server mobile app's data
   model).
6. Product capabilities beyond the scope in item 2 MAY be specified in the future, but their
   technical mechanisms MUST NOT be invented where no governing ADR has approved them.

## Core Architecture Principles

### I. Clean, Feature-First Architecture

1. ForgeApp MUST use Clean Architecture, Feature-First organization, repositories, use cases, and
   dependency injection.
2. Each business feature MUST own `presentation/`, `application/`, `domain/`, and `data/` layers.
   Presentation depends on Application, Application depends on Domain, and Data implements Domain
   contracts. Dependencies MUST point inward.
3. Domain code MUST remain independent of Flutter, Drift, and third-party packages. Widgets MUST
   NOT own business rules or call Drift/repositories directly.
4. Drift storage records (`*Record` classes populated from Drift rows) MUST be immutable Data-layer artifacts, MUST be mapped
   explicitly to Domain entities via a Mapper, and MUST NOT leak into Domain or Presentation.
5. Every capability MUST have one owning feature (see the Domain Ownership table in
   `governance/solution-architecture.md` §5). Cross-feature internal imports are prohibited;
   communication MUST use published feature barrel files or shared infrastructure.
6. `app/` owns composition and DI; `config/routes` and `config/theme` own the approved
   cross-cutting configuration exemptions. `core/` owns shared technical infrastructure. None of
   these locations may contain feature business logic.
7. Code stays in the single application — package extraction is not a concern at this POC's scale
   and MUST NOT be pursued speculatively (see `ADRs/ADR-032_Modularization_Strategy.md`).

### II. Exclusive Architectural Mechanisms

1. `flutter_bloc` is the sole state-management framework. State MUST be immutable, owned locally
   by the feature, and updated through unidirectional flow via explicit-event `Bloc` classes.
   `Cubit` MUST NOT be introduced.
2. `go_router` is the sole router. Route names and paths MUST be centralized constants; Data,
   Domain, and use cases MUST NOT navigate.
3. GetIt is the approved DI mechanism (ADR-004). Constructor injection is preferred, registration
   is centralized, and service-locator access in business logic is prohibited. `injectable`,
   Riverpod, and provider DI MUST NOT be introduced.
4. Drift is the sole persistence mechanism, and it is unrestricted — unlike a typical mobile-client
   architecture, there is no separate secure-storage tier and no "preferences only" boundary: every
   entity in SDS §Data Model may live in Drift (ADR-008).
5. Raw Drift exceptions MUST terminate in the Data layer and map to typed Domain failures. UI
   receives actionable failure states and MUST NOT display raw exception text.

### III. Centralized Routes and Guards

1. All navigation MUST enter the same centralized `go_router` configuration.
2. The only guard is the app-lock guard: locked vs. unlocked. There is no permission,
   workflow-prerequisite, or entity-validation guard chain — ForgeApp has one user and no backend
   authorization to defer to.
3. There is no deep link, push notification, or external-link entry point to secure — none of
   these exist in ForgeApp.
4. An invalid or unavailable destination MUST produce a defined, clear blocked/error state rather
   than a crash or blank screen.

## Local Data Governance

### IV. Local Access Authority

1. A static local login check (a hardcoded demo credential — SDS Appendix B) and an app-lock
   boundary are the entirety of ForgeApp's access model. There is no session token, no refresh
   flow, and no backend to authenticate against.
2. There is no Role-Based Access Control. Once unlocked, the single local user has access to every
   feature — there is no per-feature permission check to enforce.
3. The static demo credential is not a real secret and MUST NOT be stored or handled as if it were
   one (`standards/security-standards.md` §2).
4. Logout MUST re-lock the app. It MUST NOT clear local Drift data — logout and data deletion are
   different operations.

### V. Local Data Handling

1. There is no network communication to secure — ForgeApp makes no network calls of any kind.
   Hardcoded endpoints, API keys, and secrets are prohibited on the general principle that none
   should exist; if one is ever needed, it requires a new ADR revising the Product Mandate first.
2. There is no runtime permission to request — camera, location, biometrics, and notifications are
   all out of scope (Product Mandate item 3).
3. Data collection MUST be minimized to what SDS §7 defines (profile fields, workout data). None of
   it leaves the device, so there is no analytics/crash-report/notification channel to keep it out
   of, but it still MUST NOT appear in application logs verbatim (ADR-020).
4. No custom cryptography is used or required. Store-submission governance is not applicable — this
   POC/assignment is not distributed through an app store.

## Data, Storage, and State

### VI. Fully Offline By Design

1. ForgeApp makes no network calls and has no backend. Drift is the **complete and sole** data
   store for every entity — access state, profile, exercise catalogue, workout plans, schedules,
   sessions, and derived statistics (ADR-008; SDS-COMP-13). This is the direct inverse of a
   typical mobile client, where local storage is a restricted cache alongside a backend source of
   truth — here, the Drift database **is** the source of truth, unconditionally, with no scoped exception needed
   because there is no online alternative to fall back to.
2. A Drift read/write failure MUST produce a meaningful, typed failure state (ADR-007, SDS-ERR-5/6),
   never a silent data loss.
3. Temporary in-memory screen, form, filter, selection, and navigation state MAY exist for the
   active session, same as any Flutter app.
4. There is no cloud backup or sync. If asked, the honest answer is that data is not backed up
   anywhere — this is accepted POC scope (`standards/security-standards.md` §4), not a defect to
   silently work around by inventing a sync mechanism.
5. `path_provider` use is limited to the Drift database file location (ADR-031). There is no
   temporary upload/export file concept — ForgeApp has nothing to upload or export to.

## Workflow and UX Constraints

### VII. Explicit, Locally-Confirmed User States

1. Every screen MUST define applicable initial, loading, success, empty, validation-error, and
   Drift-error states. Blank screens and silent failures are prohibited (ADR-027).
2. A business-critical action (finishing a workout, deleting a plan) MUST show success only after
   the Drift write is confirmed, and SHOULD request explicit confirmation where the action is
   destructive (e.g. Cancel Workout always fully discards — SDS behavior).
3. Forms MUST model pristine, dirty, validating, valid, and invalid states where applicable
   (ADR-026). There is no server-rejected state — validation is entirely local.
4. Validation trigger choice MUST be documented in the feature specification. Hardcoded, untyped
   error strings and silent failures are prohibited.

### VIII. Reduced-Scope Theme, Adaptive UI, and Accessibility

1. All user-visible content is currently English-only; localization is deferred (ADR-016) — no
   second locale, no ARB pipeline exists yet for this POC.
2. Android phone and iPhone are the day-one targets; Android tablet and iPad are explicitly out of
   scope for this POC (ADR-022, reduced scope). Portrait is the primary, tested orientation.
3. Layout selection MUST use the Design System's spacing/breakpoint conventions
   (`Doc/DESIGN-SYSTEM.md`), not device-model or OS checks.
4. UI SHOULD respect safe areas, system insets, and reasonable touch-target sizing. Full WCAG 2.1
   AA certification and screen-reader (TalkBack/VoiceOver) support are explicitly out of scope for
   this POC (ADR-028, reduced scope) and MUST NOT be represented as a mandatory acceptance gate.
5. UI MUST follow the single, fixed dark theme in `Doc/DESIGN-SYSTEM.md` and ADR-037. There is no
   light mode and no system-theme-following — this is a deliberate, not deferred, design choice.
   Feature colors MUST use the Design System's tokens via `Theme.of(context)`, never hardcoded
   hex values outside `lib/config/theme/`.

## Platform and Technology Constraints

### IX. Governed SDKs and Dependencies

1. Flutter MUST track the latest compatible stable release through FVM and MUST NOT be pinned to
   an exact version.
2. The Dart environment constraint follows `pubspec.yaml`'s current value and changes only when an
   approved Flutter-major migration requires it.
3. Minimum platforms are Android 10/API 29 and iOS 15.
4. There are no environment flavors (development/staging/production) — ForgeApp has no backend or
   Firebase project to isolate per environment (ADR-033).
5. Dependencies MUST be declared centrally in `pubspec.yaml` and limited to the governed set in
   ADR-030: `flutter_bloc`/`bloc`/`equatable`, `get_it`, `go_router`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`, `build_runner`/`drift_dev`, `flutter_test`/`bloc_test`/`mocktail`. Agents MUST NOT add a
   package outside this set without a new ADR.
6. No second state, routing, or persistence framework may be introduced.
7. There is no app-update mechanism to build — no force-update gate, no store redirect (ADR-036,
   deferred scope; ForgeApp is not distributed through a store).

## Privacy-Safe Observability

### X. Centralized Logging Only

1. Logging MUST pass through the centralized Logging Service (ADR-020). `print`/`debugPrint` for
   application logs and feature-specific logging frameworks are prohibited.
2. Logs MUST use environment-appropriate levels and MUST NOT include the static demo credential or
   any profile field value verbatim.
3. There is no analytics, crash reporting, or performance-monitoring provider — none of these exist
   in ForgeApp (ADR-014, ADR-015 — both removed/deferred). Features MUST NOT call an analytics or
   crash-reporting SDK, because none is integrated.

## Quality and Testing Gates

### XI. Testability and Evidence Are Mandatory

1. Tests are part of feature work, not optional polish. The suite MUST be deterministic, mirror
   source structure, and validate behavior rather than implementation details.
2. Minimum coverage targets are Domain 90%+, Application 80%+, Data 70%+, and Presentation critical
   flows (`standards/testing-standards.md` §2).
3. Unit tests MUST cover use cases, repositories, entities/value objects, mappers, failures, and
   all Bloc state transitions using `bloc_test` and `mocktail`.
4. Widget tests MUST cover critical screens and applicable loading/success/empty/error states.
   There is no responsive-breakpoint matrix to test — phone-only, single-theme (ADR-022, reduced
   scope).
5. Integration tests MUST cover the critical journeys listed in `standards/testing-standards.md`
   §4.3, run on at least one Android and one iOS device/emulator — there is no four-device matrix.
6. Every change MUST satisfy the applicable coding, security, testing, review, and
   release-readiness evidence in `standards/`.
7. Commit messages use a feature reference and exactly one relevant Gitmoji as the sole
   change-type indicator, without a redundant textual type (`standards/coding-standards.md` §1.1).

## SDD Lifecycle and Review Gates

### XII. Spec Kit Is Artifact-Driven and Self-Governed

1. Functional changes MUST follow: `speckit-specify` -> `speckit-clarify` -> `speckit-checklist`
   -> G-01 -> `speckit-plan` -> G-02 -> `speckit-tasks` -> `speckit-analyze` -> G-03 ->
   `speckit-implement` -> G-04. There is no G-05 — that gate assumed a separate QA role and a
   device/store release matrix that do not apply to this single-developer POC (see
   `governance/review-gate-framework.md`).
2. A feature MAY maintain `spec.md`, `plan.md`, `tasks.md`, `checklists/`, and `analysis.md`
   evidence under one `specs/{feature}/` directory. A small fix or refactor with no meaningful
   design decision MAY skip straight to G-04 (`governance/review-gate-framework.md`).
3. Every requirement in a feature's spec MUST trace to an FR/AC/acceptance scenario, a plan
   decision, one or more executable tasks, and relevant tests. An unresolved open product decision
   (e.g. the Personal Best metric, SDS §3.5) MUST be reported as still open, never silently
   defaulted by an agent.
4. Definition of Ready and Definition of Done (`governance/definition-of-ready.md`,
   `governance/definition-of-done.md`) are both self-reviewed by the developer — there is no
   separate Product Manager/Tech Lead/QA role to route approval through on this project.

## Mandatory Rule: No Git Operations

Agents, automation, Spec Kit skills, hooks, workflows, and code-generation tools MUST NOT execute
any Git or GitHub repository operation while specifying, planning, generating tasks, implementing,
validating, or synchronizing this project. The prohibition includes read-only and mutating Git
commands, branch detection/creation, remote inspection, commits, merges, rebases, pushes, pull
requests, and repository issue creation.

All repository operations are performed manually by the user. Agents MUST use direct filesystem
inspection and non-Git validation, MUST NOT add Git work to generated tasks, and MUST skip any
extension hook that would perform Git/GitHub operations.

## Open Product Decisions (Not Constitutional Gaps)

These are genuine open decisions from `Doc/SDS_v2.0.md`, tracked here for visibility so no agent
silently defaults them. They are feature-level decisions, not constitutional principles:

1. **Personal Best metric definition** (SDS §3.5 Decision #1) — the statistics dashboard has a
   structural shell for Personal Bests, but the metric itself (heaviest set? highest volume?
   estimated 1RM?) is not yet defined. Resolve this when the Statistics feature is specified, not
   by inventing a default in code.
2. **App-backgrounded rest-timer behavior** (SDS §3.5 Decision #2) — whether the rest timer
   continues counting, pauses, or is recalculated from a timestamp when the app is backgrounded
   during an active workout is not yet decided. Resolve this when the Workout Execution feature is
   specified.

## Source Traceability

| Source File | Constitutional Section(s) | Source Status | Applied State |
|---|---|---|---|
| ADRs/ADR-001_Architecture_Style.md | Product Mandate; I | Accepted | Applied |
| ADRs/ADR-002_State_Management.md | II; XI | Accepted | Applied; Bloc-only |
| ADRs/ADR-003_Routing.md | II; III | Accepted | Applied |
| ADRs/ADR-004_Dependency_Injection.md | II; IX | Accepted | Applied; GetIt |
| ADRs/ADR-007_Error_Handling.md | II; VII; VI | Accepted | Applied |
| ADRs/ADR-008_Local_Storage.md | IV; VI | Accepted | Applied; Drift is the sole, unrestricted store for all application data |
| ADRs/ADR-015_Crash_Reporting.md | X | Accepted (Deferred Scope) | Applied; not integrated |
| ADRs/ADR-016_Localization.md | VIII | Accepted (Deferred Scope) | Applied; English only |
| ADRs/ADR-020_Logging_Strategy.md | V; X | Accepted | Applied |
| ADRs/ADR-021_Performance_Architecture.md | VIII; XI | Accepted | Applied; phone-only targets |
| ADRs/ADR-022_Responsive_Architecture.md | VIII; XI | Accepted (Reduced Scope) | Applied; phone-only, no breakpoint matrix |
| ADRs/ADR-026_Form_Validation_Strategy.md | VII | Accepted | Applied |
| ADRs/ADR-027_Loading_Empty_Error_States.md | VII; XI | Accepted | Applied |
| ADRs/ADR-028_Accessibility_Strategy.md | VIII; XI | Accepted (Reduced Scope) | Applied; no WCAG/screen-reader gate |
| ADRs/ADR-030_Dependency_Versioning_Governance.md | IX; XI | Accepted | Applied; small governed package set |
| ADRs/ADR-031_Path_Provider.md | VI | Accepted | Applied; Drift database file path only |
| ADRs/ADR-032_Modularization_Strategy.md | I | Accepted | Applied; no package extraction at this scale |
| ADRs/ADR-033_Environment_Management.md | IX | Accepted | Applied; single build config, no flavors |
| ADRs/ADR-036_App_Update_Strategy.md | IX | Accepted (Deferred Scope) | Applied; no store distribution |
| ADRs/ADR-037_Theme_Architecture.md | VIII | Accepted | Applied; single fixed dark theme |
| ADRs/README.md | Governance; Source Traceability | ADR index | Applied; canonical ADR status/navigation log, including the 18 Removed — Not Applicable ADRs this constitution does not reference |
| governance/architecture-boundaries.md | Product Mandate; I; III | Governance | Applied |
| governance/definition-of-done.md | XI; XII | Governance | Applied; single-developer self-review |
| governance/definition-of-ready.md | XII | Governance | Applied; single-developer self-review |
| governance/review-gate-framework.md | XII | Governance | Applied; four gates, not five |
| governance/solution-architecture.md | Product Mandate; I-X | Accepted architecture map | Applied |
| app/PRODUCT_CONTEXT.md | Product Mandate; VI | Product Context | Applied |
| app/platform-requirements.md | VIII; IX | Platform Authority | Applied |
| app/user role matrix.md | Product Mandate; IV | Role Authority | Applied; confirms single-user, no-role model |
| standards/code-review-checklist.md | XI; XII | Engineering Standard | Applied |
| standards/coding-standards.md | I; II; XI | Engineering Standard | Applied |
| standards/release-readiness-standards.md | XI; XII | Engineering Standard | Applied |
| standards/security-standards.md | IV-VI; XI | Engineering Standard | Applied |
| standards/testing-standards.md | III; XI | Engineering Standard | Applied |

### Removed Sources (No Longer Referenced)

The 18 ADRs listed as "Removed — Not Applicable" in `ADRs/README.md` (network, API, RBAC, QR, GPS,
push, analytics, secure storage, image caching, deep linking, permissions, offline-sync — see that
file for the full list and reasons) are not cited anywhere in this constitution. If a future draft
references one of them as live, that is a stale citation to correct against `ADRs/README.md`, not
a decision to honor.

## Governance

1. Explicit user instructions and this document's own principles control this project. Accepted
   ADRs control their architectural concern. Product, role, platform, governance, and standards
   files control only their stated concerns.
2. Standards cannot override ADR-owned technologies. A conflict MUST be recorded with both source
   paths; generated artifacts MUST use the unambiguous authority or stop for a decision.
3. Deferred items and open questions (see "Open Product Decisions" above) MUST retain those states
   until the owning feature resolves them. Missing sources MUST NOT be fabricated.
4. An amendment requires a complete corpus read, a conflict/reference check, a per-file
   traceability update, a semantic-version decision, and a refreshed Sync Impact Report.
5. Versioning follows semantic versioning: MAJOR for incompatible principle/governance removal or
   redefinition, MINOR for a new/materially expanded principle or gate, PATCH for non-semantic
   clarification/reference correction, and no bump when constitutional meaning is unchanged.
6. The ratification date is immutable unless historical evidence proves it wrong. Last Amended
   changes only when constitutional content changes.
7. All writes MUST remain within the project's `Doc/Mobile` root (or wherever this doc set is
   relocated to within ForgeApp) and all validation MUST remain Git-free.

**Version**: 1.0.0 | **Ratified**: 2026-09-08 | **Last Amended**: 2026-09-08
