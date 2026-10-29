# **System Design Specification (SDS)**

## **Changelog**

| Date | Version | Summary |
| ----- | ----- | ----- |
| 2026-09-05 | **v2.0.2** | **Final citation cleanup pass.** Verified remaining SRS-FR/NFR citations against the actual SRS_vNext.md numbering and fixed the last leftovers missed by the v2.0.1 pass: SDS-DATA-1 (local app-lock state) now carries "No dedicated SRS FR (see SRS-FR-49 note — login is architectural/design-level only)" instead of the stale SRS-FR-1–SRS-FR-6 range; SDS-DATA-2 (User Profile) now cites SRS-FR-47/48/49 instead of SRS-FR-1/2; SDS-DATA-3 (Exercise) now cites SRS-FR-1/2 instead of SRS-FR-7/8/48; SDS-ERR-1 (Static Login Failure) now carries the same "no dedicated SRS FR — see SRS-FR-49 note" framing as SDS-COMP-1/2/15 instead of citing SRS-FR-1/2/6; SDS-IF-8, SDS-IF-12, and SDS-DATA-7 (all Statistics-related) now cite the real Statistics range SRS-FR-36–41 instead of ranges that incorrectly folded in SRS-FR-47 (a Profile requirement); and the §10.1/§10.2 traceability tables had their stale rows keyed by the nonexistent SRS-NFR-17/SRS-NFR-18 removed, leaving only the real SRS-NFR-4/SRS-NFR-5 (Scalability) rows already present elsewhere in each table. No architectural or behavioral content was changed — citations only. |
| 2026-09-05 | **v2.0.1** | **Traceability-correction pass.** Corrected SRS-FR/NFR citations throughout the SDS against the actual current SRS numbering (SRS-FR-1 through SRS-FR-49; SRS-NFR-1 through SRS-NFR-16 plus SRS-NFR-2A) — no FR-50/51/52 or NFR-17/18 exist and none should have been cited. Fixed: Login-component (SDS-COMP-1/2/15) citations, which no longer point to Exercise Management FRs and instead note that no dedicated SRS FR covers the login screen itself; SDS-COMP-3 (User Profile) now cites SRS-FR-47–49; SDS-COMP-4 (Exercise Catalogue) now cites SRS-FR-1–2; all SDS-COMP-5/8/10/12/13, IF-6/10/11/14, DATA-4/6/8, and ERR-5/6/7/9 citations that referenced nonexistent SRS-FR-50/51/52 (or a mislabeled SRS-FR-47); SDS-NFR-4/5 (§7.2 Scalability) now cite SRS-NFR-4/5 instead of nonexistent SRS-NFR-17/18; SDS-NFR-8 (§7.3) now cites SRS-NFR-8 to match its own BRD-NFR-006 parent; the §10.1/§10.2 traceability tables' Statistics and Validation buckets were narrowed to the real SRS-FR-36–41 and SRS-FR-42–46 ranges, and a missing SRS-FR-47–49 → SDS-COMP-3 row was added; and explicit citations of the deferred SRS-FR-40 (Personal Best) and SRS-NFR-2A (app-backgrounded timer) were added to SDS-COMP-11, SDS-COMP-7, §3.5, and Appendix F, alongside their existing PD-004/PD-007 references. No architectural or behavioral content was changed — citations only. |
| 2026-09-05 | **v2.0** | **Architecture pivot — Local-only rewrite.** Product-owner decision: ForgeApp is fully offline, single-device, MVP/POC scope. **Drift** (typed on-device SQLite) replaces Firebase Authentication + Cloud Firestore as the entire persistence layer; there is no cloud backend and no network calls anywhere in the app. Login is a **static, hardcoded local login** (no real authentication, no registration, no password reset/recovery, no multi-user accounts) — it exists only so the user can play through a login-like flow before reaching a simple local unlocked/locked app state. Since there is a single local user per device, UID-based data partitioning and cross-user isolation logic are removed from the data model and security design. The Profile screen is now in scope and editable (display name, fitness goal, experience level, height & weight). Exercise records now carry an explicit `type` (weighted / time-based / bodyweight); duration is stored in seconds and displayed as mm:ss. Cancelled/exited workouts are always fully discarded (no "Incomplete" state, no partial save). The rest timer auto-starts on set completion and is skippable. Personal Best calculation logic and app-backgrounded timer behavior are explicitly **deferred/open decisions** — flagged here, not designed. This pivot is a deliberate reversal of the SDS v1.0 architecture baseline (Firebase Auth + Firestore), which is now deprecated. Reason: POC/MVP/assignment scope — "enough but not too much," avoiding backend infrastructure the exercise does not need. See `/tmp/decisions_log.md` for the authoritative decision record. |

---

## **Document Control**

| Attribute | Details |
| ----- | ----- |
| **Document Type** | System Design Specification (SDS) |
| **Document Version** | v2.0 |
| **Document Status** | **DRAFT — Local Architecture, pending re-approval** (supersedes v1.0 "LOCKED") |
| **Derivation Level** | Derived Document — Level 2 |
| **Project Name** | ForgeApp (Workout Tracker) |
| **Parent Document** | Software Requirements Specification (SRS), Version 1.0 |
| **Grandparent Document** | Business Requirements Document (BRD), Version 1.0 |
| **Target Platforms** | iOS and Android mobile application |
| **Architecture Model** | Fully offline, single-device mobile client — no backend |
| **Authentication** | Static local login (hardcoded credential check; not real authentication) |
| **Primary Data Store** | Drift (typed on-device SQLite database) |
| **Local Database** | Drift (SQLite) — the sole persistence layer |
| **Offline Persistence / Sync** | Fully offline by design; no synchronization, no cloud backup, no multi-device support |
| **Status** | Architecture baseline for MVP, revised (v2.0) — pending re-approval following architecture pivot |

---

# **1. Introduction**

## **1.1 Purpose**

This System Design Specification defines the technical architecture and system design for the ForgeApp (Workout Tracker) MVP.

The document translates the requirements established in SRS Version 1.0 into implementable architectural components, interfaces, data structures, local persistence design, error handling mechanisms, and non-functional design decisions.

The design supports the complete MVP lifecycle:

> **Login → Plan → Schedule → Perform → Record → Review → Progress**

"Login" here is a static, hardcoded local login screen — not real authentication (see §2.2, §3.2 SDS-COMP-2). It exists so the user can play through a login-like flow before reaching the application's main functionality.

The design uses a **single mobile client with no backend of any kind**. **Drift**, a typed on-device SQLite database, provides the entire persistent data layer. There is no Firebase, no Firestore, no cloud service, and no network call anywhere in the application.

The system intentionally does **not** use any cloud-hosted database or authentication service. All application data lives only on the device and is lost if the app is uninstalled or its local storage is cleared; this is an accepted MVP/POC constraint, not an oversight.

---

## **1.2 Scope**

The SDS covers:

* Static local login and local app-unlock state.
* User profile (editable: display name, fitness goal, experience level, height & weight).
* Exercise catalogue access (developer-seeded, local, read-only from the client).
* Workout plan management.
* Basic workout scheduling (weekly recurrence).
* Workout execution.
* Workout recording.
* Workout history.
* Progress tracking.
* Statistics and personal-best structure (metric definition explicitly deferred — see §3.2 SDS-COMP-11, Appendix F).
* Data validation and integrity.
* Local (Drift) persistence.
* Error and recovery behavior.
* Performance, reliability, security, scalability, usability, and maintainability design, scoped to a fully offline single-device app.

The design is limited to behavior already represented in SRS Version 1.0, as reinterpreted for the local-only architecture confirmed in the decisions log (2026-09-05).

The following remain outside the design scope:

* Firebase Authentication, Cloud Firestore, or any cloud/managed backend service.
* Any network call, cloud sync, or cloud backup.
* Multi-device sync or multi-device conflict resolution.
* Real authentication of any kind: registration, password reset/forgot-password, email verification, OTP/phone authentication, biometric authentication, MFA, session tokens, multi-user accounts, or login-recovery flows.
* Social authentication.
* AI coaching.
* Advanced/adaptive scheduling.
* Health-platform integrations.
* Wearables.
* Social features.
* Advanced workout programming.
* Account deletion and data export (there is no account and no cloud data to export).
* An "Incomplete Workout" saved state, or any discard-vs-save-incomplete prompt (cancelling always discards — see §3.2 SDS-COMP-7).
* Finalized Personal Best calculation logic and finalized app-backgrounded timer behavior — both are explicitly open/deferred (see Appendix F).

---

## **1.3 Definitions, Acronyms, Abbreviations**

| Term | Definition |
| ----- | ----- |
| **SDS** | System Design Specification |
| **SRS** | Software Requirements Specification |
| **BRD** | Business Requirements Document |
| **Drift** | Typed, code-generated Dart persistence library over on-device SQLite, used as the application's sole persistent data store |
| **Table** | A relational Drift/SQLite table holding rows of one type; related tables are linked by foreign keys |
| **Static Local Login** | A hardcoded email/password check performed entirely on-device; not real authentication |
| **App Lock State** | The application's local `LOCKED` / `UNLOCKED` state, set after a successful static login check; not a security boundary |
| **Workout Plan** | A predefined collection of exercises and intended performance targets |
| **Workout Session** | An actual, completed workout performed by the user; only completed workouts are ever persisted |
| **Exercise** | A defined physical activity carrying an explicit `type`: `weighted`, `time-based`, or `bodyweight` |
| **Set** | A single instance of performing an exercise |
| **Training Volume** | Accumulated weight × repetitions across valid applicable completed sets |
| **Personal Best** | Best recorded performance for a defined exercise metric — **metric definition is an open/deferred decision** (see Appendix F) |
| **Completed Workout** | A workout session with at least one logged set for at least one exercise, and an explicit Finish action |
| **MVP** | Minimum Viable Product |
| **POC** | Proof of Concept |

Note: "Incomplete Workout," "UID," "Owner," and "Firestore" are removed from this version — cancelled workouts are discarded entirely rather than persisted in an incomplete state (see §3.2 SDS-COMP-7), and there is no cloud identity or multi-user ownership concept in a single-local-user, offline app.

---

## **1.4 References**

1. **Business Requirements Document — Workout Tracker, Version 1.0**.
   The available BRD establishes the core Plan → Schedule → Perform → Record → Review → Progress lifecycle, mobile iOS/Android scope, functional requirements, and NFR baseline.
2. **Software Requirements Specification — Workout Tracker, Version 1.0**.
3. **ForgeApp — Confirmed Product Decisions log, dated 2026-09-05** (`/tmp/decisions_log.md`). This is the current authoritative source for architecture and scope; it supersedes the SRS/BRD wherever they still describe Firebase/Firestore, registration, or password-reset as in-scope.
4. Drift local persistence and static local login are the architectural constraints established by the 2026-09-05 decision log, superseding the earlier Firebase Authentication + Cloud Firestore Authentication Module decision record referenced in SDS v1.0.

---

# **2. Design Overview**

## **2.1 Design Goals and Guiding Principles**

The architecture follows these principles:

1. **Single source of truth, on-device**
   Persistent application data is stored entirely in the local Drift (SQLite) database. There is no server-side copy and no cloud source of truth.
2. **Static local login, not managed authentication**
   Login is a hardcoded credential check performed on-device; it exists to demonstrate a login-like flow, not to provide security.
3. **Local database is the architecture, not an exclusion**
   The mobile application maintains its persistent state entirely in a local relational database (Drift). This reverses the earlier "no local database" position.
4. **Offline-first / offline-only operation**
   The application never requires network connectivity for any read or write. There is no network call anywhere in the app.
5. **Single local user — no ownership partitioning needed**
   There is exactly one user per device install; no UID, account, or cross-user isolation logic is needed or present.
6. **Separation of planned and actual performance**
   Workout plans remain independent from historical workout sessions.
7. **Immutable historical meaning**
   Changes to a workout plan must not rewrite historical performance.
8. **Validation before persistence**
   Invalid workout data must be rejected before being treated as valid performance.
9. **Minimal MVP/POC architecture**
   Architecture should avoid infrastructure that exists only to support out-of-scope capabilities — this is the reason the cloud backend was removed, not just a stylistic preference.
10. **Traceability-first design**
    Every component, interface, data structure, and design decision maps to an SRS requirement (as reinterpreted for the local-only architecture).

The BRD explicitly establishes the core lifecycle as Plan → Schedule → Perform → Record → Review → Progress; "Login" replaces "Authenticate" as a static, non-authenticating step ahead of it.

---

## **2.2 Architectural Style / Approach**

The system uses a **fully offline, single-tier mobile client architecture**. There is no backend tier.

### **Architectural layers**

```
┌─────────────────────────────────────────────┐
│              Mobile Application              │
│                                               │
│  Static Local Login / App Lock State         │
│  Workout Planning                            │
│  Scheduling                                  │
│  Workout Execution                           │
│  History / Progress / Statistics             │
│  ─────────────────────────────────────────   │
│  Drift / SQLite (local on-device persistence)│
│    - user_profiles                           │
│    - exercises                               │
│    - workout_plans / plan_exercises          │
│    - schedule_entries                        │
│    - workout_sessions / session_exercises /  │
│      actual_sets                             │
└───────────────────────────────────────────────┘
```

There is no external layer beneath the mobile application. The architecture is intentionally offline-first: there is no local cache of a remote source, because there is no remote source — the Drift database **is** the source of truth.

### **Architectural rationale**

| Decision | Design Rationale | SRS Traceability |
| ----- | ----- | ----- |
| Static local login | Demonstrates a login-like flow without building real authentication infrastructure the POC does not need | No dedicated SRS FR (see SRS-FR-49 note — login is architectural/design-level only) |
| Drift local persistence | Sole, sufficient persistence mechanism for a single-device MVP/POC; removes backend cost/complexity | SRS-FR-33–SRS-FR-46 |
| No account/UID partitioning | Single local user per device; ownership isolation logic would be unused complexity | SRS-NFR-4 (reinterpreted) |
| Fully offline operation | Eliminates network dependency, sync, and conflict-management entirely | SRS-NFR-6 |
| Separate plans and sessions | Prevents plan changes from modifying history | SRS-FR-38 |
| Nested workout structures (as parent/child table relationships) | Keeps one plan/session logically self-contained | SRS-FR-10 to SRS-FR-14, SRS-FR-33 to SRS-FR-38 |

---

## **2.3 Assumptions and Design Constraints**

### **Assumptions**

1. The application runs for a single local user per device install; there is no concept of multiple accounts on one device.
2. That single local user owns all workout plans and workout records stored on the device.
3. Exercise catalogue data is a fixed, developer-seeded list, loaded into the Drift database on first launch, and read-only from the client thereafter.
4. Workout plans can contain weighted, time-based, and bodyweight exercises (see §6.1 SDS-DATA-3).
5. Actual performance can differ from planned targets.
6. Statistics are derived from valid completed records (Personal Best metric definition is deferred — see Appendix F).
7. The application is used entirely on a single mobile device, with no expectation of data appearing on any other device.
8. **The application operates fully offline. No internet connectivity is required, assumed, or used for any application function.**

The BRD establishes mobile iOS/Android deployment and an MVP centered on the core workout lifecycle; the local-only architecture is a POC/MVP-scoping decision, not a reflection of the BRD's original cloud-first assumption.

### **Design Constraints**

* Login shall be a static, hardcoded local credential check. No real authentication mechanism shall be implemented.
* No registration, password reset, email verification, OTP, biometric authentication, or MFA shall be implemented.
* **Drift (SQLite) shall be the sole persistent application data store.**
* No cloud backend, network call, or synchronization layer shall be introduced.
* No UID-based or account-based data partitioning shall be introduced — there is one local data set per device.
* Exercise catalogue data shall be read-only from the client, seeded into the Drift database at first launch.
* Cancelled/exited workouts shall always be discarded — no partial or "incomplete" persistence.

---

## **2.4 Out-of-Scope Design Elements**

The following architectural elements are deliberately excluded:

* Firebase Authentication, Cloud Firestore, or any other cloud/managed backend service.
* Any network call, REST/gRPC client, or cloud SDK.
* Offline write queue and synchronization/conflict-resolution engine (not needed — there is nothing remote to synchronize with).
* Multi-device sync or multi-device conflict resolution.
* Registration, password reset, email verification.
* Social login providers, phone authentication, biometric authentication, MFA.
* Custom authentication backend or password storage (login is a hardcoded local check, not a credential store).
* AI recommendation engine.
* Wearable integration layer.
* Health platform integration layer.
* Social graph.
* Advanced/adaptive scheduling engine.
* Background synchronization service.
* An "Incomplete Workout" persisted state.

---

# **3. System Architecture**

## **3.1 High-Level Architecture Description**

### **Component Catalogue**

| ID | Component | Responsibility | SRS Traceability |
| ----- | ----- | ----- | ----- |
| **SDS-COMP-1** | Mobile Application Shell | Application lifecycle, app-lock-state entry point and navigation boundary | No dedicated SRS FR (see SRS-FR-49 note — login is architectural/design-level only), SRS-NFR-1, SRS-NFR-13 |
| **SDS-COMP-2** | Static Local Login Component | Checks entered credentials against a hardcoded value; sets local unlocked/locked app state; no registration, reset, or token/session management | No dedicated SRS FR (see SRS-FR-49 note — login is architectural/design-level only), SRS-NFR-4 |
| **SDS-COMP-3** | User Profile Component | Stores and retrieves the local, editable user profile (display name, fitness goal, experience level, height & weight) in the Drift database | SRS-FR-47, SRS-FR-48, SRS-FR-49, SRS-NFR-4, SRS-NFR-5 |
| **SDS-COMP-4** | Exercise Catalogue Component | Provides access to the fixed, developer-seeded exercise list (with `type` flag) | SRS-FR-1, SRS-FR-2, SRS-FR-48 |
| **SDS-COMP-5** | Workout Plan Component | Creates, validates, updates and deletes workout plans in the Drift database | SRS-FR-9–SRS-FR-14, SRS-FR-42–SRS-FR-46 |
| **SDS-COMP-6** | Scheduling Component | Manages weekly-recurrence workout schedules (one plan per weekday max) | SRS-FR-15–SRS-FR-24 |
| **SDS-COMP-7** | Workout Execution Component | Controls active workout behavior, set/exercise completion, auto-starting/skippable rest timer, cancellation (always discards) and finish | SRS-FR-25–SRS-FR-32, SRS-NFR-2A (DEFERRED — app-backgrounded timer behavior) |
| **SDS-COMP-8** | Workout Record Component | Persists completed workout sessions and summaries to the Drift database | SRS-FR-33–SRS-FR-35, SRS-FR-44–SRS-FR-46 |
| **SDS-COMP-9** | History Component | Retrieves and presents historical completed workouts from the Drift database | SRS-FR-36–SRS-FR-38 |
| **SDS-COMP-10** | Progress Component | Compares valid performance across sessions | SRS-FR-39–SRS-FR-41, SRS-FR-46 |
| **SDS-COMP-11** | Statistics Component | Calculates workout counts, duration, volume, exercise statistics; Personal Best structure exists but its metric is deferred (Appendix F) | SRS-FR-36–SRS-FR-41 (includes SRS-FR-40, Personal Best, DEFERRED) |
| **SDS-COMP-12** | Validation Component | Performs business/data validation before persistence and calculation | SRS-FR-42–SRS-FR-46, SRS-NFR-5 |
| **SDS-COMP-13** | Drift Persistence Boundary | Provides the sole local persistence and retrieval boundary for application data | SRS-FR-33–SRS-FR-46, SRS-NFR-4–SRS-NFR-7 |
| **SDS-COMP-14** | Local App Lock Boundary | Enforces the app's local unlocked/locked navigation state (not a real security boundary; single local user) | SRS-NFR-4, SRS-NFR-5, SRS-NFR-8–SRS-NFR-10 |
| **SDS-COMP-15** | Static Credential Check Service | Compares login input against a hardcoded credential; returns pass/fail only — no identity, token, or session lifecycle | No dedicated SRS FR (see SRS-FR-49 note — login is architectural/design-level only), SRS-NFR-4 |

---

## **3.2 Component Responsibilities and Boundaries**

### **SDS-COMP-1 — Mobile Application Shell**

**Responsibilities**

* Start the application.
* Observe local app-lock state.
* Route unlocked users to application functionality.
* Route locked users to the static login screen.
* Prevent application functionality from being used while locked.

**Inputs**

* Application lifecycle events.
* Local app-lock state.

**Outputs**

* Unlocked application context.
* Locked (login) entry context.

**Boundary**

The application shell does not itself perform the credential check.

---

### **SDS-COMP-2 — Static Local Login Component**

**Responsibilities**

* Present a static login screen (email/password-style inputs + Login button).
* Compare entered input against a hardcoded credential (SDS-COMP-15).
* Set the local app-lock state to `UNLOCKED` on match, `LOCKED`/error on mismatch.
* Provide a Logout action (on the Profile screen — see SDS-COMP-3) that returns the state to `LOCKED`.

**Explicitly excluded**

* Registration, password reset/forgot-password, email verification, OTP, biometric login, MFA, multi-user accounts.
* Any token or session object — the only state is the local `LOCKED`/`UNLOCKED` flag.
* Any lockout/recovery flow — a failed attempt simply allows retry; there is no real security to recover from.

**Boundary**

Nothing is transmitted anywhere; the credential comparison happens entirely on-device against a hardcoded value.

---

### **SDS-COMP-3 — User Profile Component**

The component manages the local, editable user profile, stored in a single `user_profiles` row (see SDS-DATA-2).

**Fields (exactly these — no more):**

* Display name
* Fitness goal
* Experience level (Beginner / Intermediate / Advanced — informational only; no logic/calculations tied to it for MVP)
* Height & weight (numeric; stored for reference only — not used in any calculation unless later decided)

The Logout action lives on this screen and returns the app-lock state to `LOCKED` (SDS-COMP-2).

There is no registration flow that collects these fields at signup — the user sets/edits them directly on this screen after the static login.

---

### **SDS-COMP-4 — Exercise Catalogue Component**

The exercise catalogue is fixed, developer-seeded reference data, loaded into the `exercises` table on first launch.

Client users can read valid exercise definitions but cannot create, edit, or delete catalogue entries — there is no admin/curation tooling and no in-app mechanism to add custom exercises.

Each exercise carries an explicit **type** flag — `weighted`, `time-based`, or `bodyweight` — that other components (Workout Plan, Workout Execution, Workout Record) branch on rather than using one generic reps+weight+duration form for every exercise.

---

### **SDS-COMP-5 — Workout Plan Component**

The component manages workout plans stored in the `workout_plans` table, with their ordered exercises in `plan_exercises`.

A workout plan contains:

* Plan identity (key).
* Plan name.
* Planned exercises, each carrying its exercise `type` (weighted / time-based / bodyweight) and only the target fields applicable to that type:
  * Weighted: target sets, target repetitions, target weight (strictly positive).
  * Time-based: target sets, target duration (entered/displayed mm:ss, stored as seconds).
  * Bodyweight: target sets, target repetitions (no weight field).
* Applicable rest periods.

Plan data is independent of completed workout history.

---

### **SDS-COMP-6 — Scheduling Component**

The scheduling component manages, in the `schedule_entries` table:

* Weekday assignments (weekly recurrence only — no specific-date/calendar scheduling).
* Scheduled-plan retrieval.
* Schedule modification.
* Schedule removal.
* Schedule validation, including the **one-plan-per-weekday maximum** rule.

The component does not provide intelligent or adaptive scheduling.

Previously completed workout sessions are never rewritten because of scheduling changes.

---

### **SDS-COMP-7 — Workout Execution Component**

The execution component maintains the active workout state in application memory only (never persisted mid-workout):

* Follow the selected plan.
* Record actual performance (branching per exercise `type`).
* Complete sets — completing a set **auto-starts** the rest timer, which the user can **Skip**.
* Complete exercises; skip items.
* Finish or cancel the session.

**Completion rule:** a session is "completed" only when at least one set of at least one exercise has been logged **and** the user explicitly taps Finish.

**Cancellation rule:** cancelling or exiting an active workout at any point **always discards it entirely** — nothing is saved, nothing appears in history, and no "Incomplete" record or state exists. There is no discard-vs-save-incomplete prompt.

**Open/Deferred:** App-backgrounded timer behavior (pause-and-resume vs. wall-clock catch-up vs. ending the session) is **not decided** — see Appendix F. This design does not assume a default; it flags the gap for a future product decision.

---

### **SDS-COMP-8 — Workout Record Component**

The record component converts a valid completed workout (per SDS-COMP-7's completion rule) into a persistent record in the `workout_sessions` table (with its exercises and sets in `session_exercises` and `actual_sets`), written in a single transaction.

The persisted record contains actual performance rather than relying on the current version of the workout plan — this is the principal mechanism protecting historical integrity.

Because cancelled workouts are never handed to this component, every record that exists in `workout_sessions` is, by definition, a completed one.

---

### **SDS-COMP-9 — History Component**

The history component retrieves completed workout records from the `workout_sessions` table.

It does not modify historical records as a side effect of viewing them.

---

### **SDS-COMP-10 — Progress Component**

The progress component derives comparisons from valid historical workout records.

Because no "Incomplete" record type exists (SDS-COMP-7), this component's exclusion logic is limited to malformed/invalid records rather than an "incomplete vs. complete" distinction.

---

### **SDS-COMP-11 — Statistics Component**

The statistics component derives:

* Total completed workouts.
* Training volume.
* Workout duration.
* Exercise-level statistics.
* A Personal Bests view exists structurally (per-exercise bests are shown), but the exact metric(s) — heaviest weight / highest reps / highest volume / longest duration, one or more — are an **open, deferred decision** (Appendix F, resolves PD-004). This design does not silently pick a default.

All derived values are calculated from valid records.

---

### **SDS-COMP-12 — Validation Component**

Validation is applied before a record can become a valid business record.

The component validates:

* Required information.
* Exercise references (including exercise `type` consistency — e.g., a bodyweight exercise entry must not carry a weight value).
* Set values.
* Repetition values.
* Weight values (strictly positive for weighted exercises).
* Duration values (stored as seconds; entered/displayed as mm:ss for time-based exercises).
* Workout completion state (per the SDS-COMP-7 completion rule).

---

### **SDS-COMP-13 — Drift Persistence Boundary**

This component provides the only persistent application-data boundary. It is implemented by a single `AppDatabase` (Drift, file `forge.sqlite` in the application documents directory) that owns the following local tables:

* `user_profiles` — single-row user profile (id fixed to `0`).
* `exercises` — keyed by `exerciseId`; seeded on every launch (transactional replace), read-only from the client.
* `workout_plans` — keyed by `planId`; ordered exercises in `plan_exercises` (foreign key to the plan, `ON DELETE CASCADE`, explicit `position`).
* `schedule_entries` — one row per weekday (primary key = weekday), storing the plan id and plan name.
* `workout_sessions` — keyed by `sessionId`, storing a plan id and plan name snapshot; ordered exercises in `session_exercises` and ordered sets in `actual_sets` (each with a cascading foreign key to its parent).

Foreign keys are enabled, `schemaVersion` starts at 1, and writes that touch more than one table (saving a plan, saving a session, replacing the exercise catalogue) run in a single transaction.

No cloud service, network call, or remote fallback sits behind this boundary — Drift is the entire persistence layer.

---

### **SDS-COMP-14 — Local App Lock Boundary**

This boundary enforces only the local `LOCKED` / `UNLOCKED` navigation state set by SDS-COMP-2:

```
LOCKED  ──(credential match)──►  UNLOCKED
UNLOCKED ──(logout)──►  LOCKED
```

There is no per-record authorization check, no cross-user isolation, and no cryptographic security boundary — with a single local user and local-only data, there is nothing to isolate data from. This component exists purely to gate navigation to the app's screens while `LOCKED`.

---

### **SDS-COMP-15 — Static Credential Check Service**

This internal service:

* Holds a single hardcoded credential value (not user-supplied, not stored via any real credential-management mechanism).
* Compares login input against it.
* Returns match/no-match only.

There is no UID generation, no session/token issuance, and no password-reset mechanism — none of these exist for a hardcoded, single-credential local login.

---

## **3.3 Component Interaction / Data Flow Overview**

### **Static Local Login**

```
User
 │
 ▼
SDS-COMP-2 Static Local Login
 │
 ▼
SDS-COMP-15 Static Credential Check
 │
 ├── Match ──► SDS-COMP-14 App Lock Boundary: UNLOCKED ──► Application
 │
 └── No match ──► Remain LOCKED, show error, allow retry
```

### **Workout Planning**

```
User
 │
 ▼
SDS-COMP-5 Workout Plan
 │
 ├── SDS-COMP-12 Validation
 │
 └── SDS-COMP-13 Drift (workout_plans)
```

### **Workout Execution**

```
Saved Plan
    │
    ▼
SDS-COMP-7 Workout Execution
    │
    ├── Validation
    │
    ├── Cancel ──► Discard entirely (nothing persisted)
    │
    ▼ Finish (≥1 set logged)
Completed Workout
    │
    ▼
SDS-COMP-8 Workout Record
    │
    ▼
SDS-COMP-13 Drift (workout_sessions)
```

### **Progress / Statistics**

```
Drift (workout_sessions)
    │
    ▼
Valid Completed Workout Sessions
    │
    ├──► SDS-COMP-9 History
    │
    ├──► SDS-COMP-10 Progress
    │
    └──► SDS-COMP-11 Statistics (Personal Best metric: deferred, Appendix F)
```

---

## **3.4 Deployment View**

```
┌────────────────────────────────────────────┐
│             Mobile Device                   │
│                                              │
│ ┌──────────────────────────────────────────┐│
│ │ ForgeApp (Workout Tracker) Mobile App     ││
│ │                                           ││
│ │ Static Local Login / App Lock State      ││
│ │ Workout Planning                         ││
│ │ Scheduling                               ││
│ │ Execution                                ││
│ │ History / Progress / Statistics          ││
│ │ ───────────────────────────────────────  ││
│ │ Drift / SQLite (local persistence)       ││
│ │   user_profiles / exercises /            ││
│ │   workout_plans / schedule_entries /     ││
│ │   workout_sessions (+ child tables)      ││
│ └──────────────────────────────────────────┘│
└──────────────────────────────────────────────┘
```

There is **no backend tier and no network connection of any kind**. Everything shown above runs entirely on the single mobile device.

---

## **3.5 Open / Deferred Design Items (Not Finalized)**

These are explicitly **not** designed or locked in this version. They are flagged so build order and future work are visible, not silently defaulted:

1. **Personal Best calculation logic** (resolves PD-004; also see SRS-FR-40, DEFERRED) — which metric(s) count as a "Personal Best" (heaviest weight / highest reps / highest volume / longest duration — one or more) is undecided. A future product-owner brainstorming session will resolve this. The Personal Bests view may still be scoped structurally (SDS-COMP-11), but its metric definition carries a visible **TBD** flag until then.
2. **App-backgrounded timer behavior** (relates to PD-007; also see SRS-NFR-2A, DEFERRED) — whether the active-workout/rest timer should pause-and-resume, wall-clock-catch-up, or end the session when the app is backgrounded is undecided. Background handling is not removed from requirements; the specific behavior is **TBD** pending a future product-owner decision.

See Appendix F for the same two items in one place.

---

# **4. Component Design**

## **SDS-COMP-1 — Mobile Application Shell**

**SRS:** No dedicated SRS FR (see SRS-FR-49 note — login is architectural/design-level only), SRS-NFR-1, SRS-NFR-13

| Aspect | Design |
| ----- | ----- |
| Responsibility | Application lifecycle and app-lock-state application boundary |
| Input | Local app-lock state |
| Output | Unlocked or locked application context |
| Persistence | None (state itself is transient/in-memory; see SDS-COMP-14) |
| Boundary | Does not itself perform the credential check |

---

## **SDS-COMP-2 — Static Local Login Component**

**SRS:** No dedicated SRS FR (see SRS-FR-49 note — login is architectural/design-level only), SRS-NFR-4

| Function | Design |
| ----- | ----- |
| Login | Email/password-style input compared to a hardcoded credential (SDS-COMP-15) |
| Logout | App-lock state set to `LOCKED` (action lives on the Profile screen, SDS-COMP-3) |
| Registration | **Not implemented** — no such flow exists |
| Reset | **Not implemented** — no such flow exists |
| Lock state | Simple local `LOCKED` / `UNLOCKED` flag, held in app state |
| Credential storage | A single hardcoded value in application code — not a credential store, not encrypted, not intended as real security |

### **App lock state model**

```
LOCKED
   │
   ├── Credential match ──► UNLOCKED
   │
   └── No match ──► remain LOCKED (retry allowed)

UNLOCKED
   │
   └── Logout ──► LOCKED
```

---

## **SDS-COMP-3 — User Profile Component**

**SRS:** SRS-FR-47, SRS-FR-48, SRS-FR-49, SRS-NFR-4, SRS-NFR-5

The user profile is a single row in the local `user_profiles` table.

Conceptual profile:

```
user_profiles (single row, id fixed to 0)
    ├── displayName
    ├── fitnessGoal
    ├── experienceLevel
    ├── heightCm
    ├── weightKg
    ├── createdAt
    └── updatedAt
```

Since there is a single local user per device, there is no owner/UID key — the table holds exactly one row.

---

## **SDS-COMP-4 — Exercise Catalogue Component**

**SRS:** SRS-FR-1, SRS-FR-2, SRS-FR-48

Conceptual structure:

```
exercises (table)
    exerciseId (primary key)
        ├── name
        ├── type            // text enum: "weighted" | "time-based" | "bodyweight"
        ├── muscleGroup (if applicable)
        └── metadata
```

The catalogue is:

* Fixed and developer-seeded (hardcoded, or seeded into the database on launch).
* Read-only from the client.
* Referenced by workout plans.
* Validated before a plan is persisted (including `type`-appropriate fields).

---

## **SDS-COMP-5 — Workout Plan Component**

**SRS:** SRS-FR-9–SRS-FR-14, SRS-FR-42–SRS-FR-46

Conceptual structure:

```
workout_plans (table)
    planId (primary key)
        ├── name
        ├── plan_exercises (child table, ordered by position)
        │    ├── exerciseId
        │    ├── type              // copied/validated from catalogue
        │    ├── targetSets
        │    ├── targetRepetitions   // weighted, bodyweight
        │    ├── targetWeight        // weighted only
        │    ├── targetDurationSec   // time-based only; mm:ss in UI
        │    └── restPeriodSec
        ├── createdAt
        └── updatedAt
```

Plan exercises are stored as ordered child rows of the plan in `plan_exercises` (foreign key to `workout_plans`, `ON DELETE CASCADE`), so deleting a plan removes its exercises automatically while the plan remains logically self-contained.

---

## **SDS-COMP-6 — Scheduling Component**

**SRS:** SRS-FR-15–SRS-FR-24

Conceptual structure:

```
schedule_entries (table)
    weekday (primary key: 1..7, Mon..Sun)
        ├── planId   // at most one plan per weekday
        └── planName // snapshot; no foreign key to workout_plans
```

The component validates:

1. Referenced workout plan exists.
2. Referenced workout plan is available.
3. Weekly-recurrence configuration is valid.
4. **One plan per weekday maximum** — assigning a new plan to an already-assigned weekday replaces the existing assignment rather than stacking.
5. Scheduling changes affect future scheduling only.

There is no specific-date/calendar scheduling — weekly recurrence only. Previously completed workout sessions are never rewritten because of scheduling changes.

---

## **SDS-COMP-7 — Workout Execution Component**

**SRS:** SRS-FR-25–SRS-FR-32, SRS-NFR-2, SRS-NFR-2A (DEFERRED — app-backgrounded timer behavior), SRS-NFR-3, SRS-NFR-6

The component maintains the current workout execution state in application memory only — nothing is written to the database until (and unless) the workout is finished.

Conceptual state:

```
NOT_STARTED
     │
     ▼
ACTIVE
 ┌───┼──────────────────┐
 ▼   ▼                  ▼
PAUSED  SET_COMPLETE     SKIPPED
          │
          ▼
   REST (auto-started, skippable)
          │
          ▼
       ACTIVE
          │
   ┌──────┴──────┐
   ▼             ▼
FINISH        CANCEL
   │             │
   ▼             ▼
Persist       Discard
(SDS-COMP-8)  entirely
```

**Rest timer:** starts automatically the moment a set is marked complete; the user may tap Skip to end it early. There is no manual "tap Start" step.

**Finish:** requires at least one logged set across the session (per §1.3, "Completed Workout").

**Cancel:** at any point, always discards the entire in-memory session. Nothing is persisted, regardless of how much was logged. There is no "Incomplete" record and no save-vs-discard prompt.

**Open/Deferred:** background-app timer behavior — see §3.5 / Appendix F.

---

## **SDS-COMP-8 — Workout Record Component**

**SRS:** SRS-FR-33–SRS-FR-35, SRS-FR-44–SRS-FR-46

Conceptual structure:

```
workout_sessions (table)
    sessionId (primary key)
        ├── planId + planName   // snapshot; no foreign key to workout_plans
        ├── completedAt
        ├── sessionDuration
        └── session_exercises (child table, ordered by position)
             ├── exerciseId
             ├── type                 // weighted | time-based | bodyweight
             └── actual_sets (child table, ordered by position)
                  ├── repetitions      // weighted, bodyweight
                  ├── weight           // weighted only
                  └── durationSec      // time-based only; mm:ss in UI
```

There is no `status`/`completionState` field at the session level — because cancelled sessions are discarded before reaching this component, every row in this table is, by construction, a completed one.

The actual values are copied into the workout session record rather than dynamically referencing the current plan targets, so later plan edits cannot change historical performance.

---

## **SDS-COMP-9 — History Component**

**SRS:** SRS-FR-36–SRS-FR-38

History reads completed sessions from the `workout_sessions` table.

The component does not modify historical records as a side effect of viewing them.

---

## **SDS-COMP-10 — Progress Component**

**SRS:** SRS-FR-39–SRS-FR-41, SRS-FR-46

Progress is calculated from valid completed workout records.

Supported measures include:

* Weight.
* Repetitions.
* Training volume.
* Duration where applicable (time-based exercises).

Malformed/invalid records are excluded; there is no separate "incomplete" case to exclude, since none exist (SDS-COMP-7).

---

## **SDS-COMP-11 — Statistics Component**

**SRS:** SRS-FR-36–SRS-FR-41 (includes SRS-FR-40, Personal Best, DEFERRED)

The statistics component provides:

```
Completed Workout Count
Training Volume
Workout Duration
Exercise Statistics
Personal Best   ← structure only; metric definition DEFERRED (Appendix F)
```

The component uses the same validity rules used by progress calculations, so a record is never valid for statistics but invalid for progress (or vice versa).

---

## **SDS-COMP-12 — Validation Component**

**SRS:** SRS-FR-42–SRS-FR-46, SRS-NFR-5

Validation rules include:

| Data | Validation |
| ----- | ----- |
| Plan name | Required and non-blank |
| Exercise | Must reference a valid catalogue exercise; type-appropriate fields only |
| Sets | Must satisfy applicable positive-value requirements |
| Repetitions | Must satisfy applicable positive-value requirements (weighted, bodyweight) |
| Weight | Strictly positive for weighted exercises; not applicable/shown for bodyweight or time-based |
| Duration | Stored as seconds, non-negative; entered/displayed as mm:ss for time-based exercises |
| Workout completion state | Must satisfy the SDS-COMP-7 completion rule (≥1 logged set + explicit Finish) |
| Performance record | Records not meeting the completion rule are never persisted (see SDS-COMP-7) |

---

## **SDS-COMP-13 — Drift Persistence Boundary**

**SRS:** SRS-FR-33–SRS-FR-46, SRS-NFR-4–SRS-NFR-7

All application persistence passes through this boundary, backed by the local Drift tables (`user_profiles`, `exercises`, `workout_plans`, `plan_exercises`, `schedule_entries`, `workout_sessions`, `session_exercises`, `actual_sets`).

The boundary does not provide:

* Any cloud/remote persistence.
* Network calls of any kind.
* Synchronization or conflict resolution (nothing remote to synchronize with).
* Cross-device data access.

---

## **SDS-COMP-14 — Local App Lock Boundary**

**SRS:** SRS-NFR-4, SRS-NFR-5, SRS-NFR-8–SRS-NFR-10

Conceptual state gate:

```
appLockState == UNLOCKED
        │
        ▼
Application screens reachable
```

There is no per-record authorization model beneath this — with one local user and local-only data, there is nothing to isolate data from. This is a navigation gate, not a security boundary, and must not be represented as one.

---

## **SDS-COMP-15 — Static Credential Check Service**

**SRS:** No dedicated SRS FR (see SRS-FR-49 note — login is architectural/design-level only), SRS-NFR-4

This service owns:

* A single hardcoded credential value.
* Login-input comparison (match / no-match).

It does **not** own or provide: credential storage/hashing, password reset, session/token issuance, or UID generation — none of these apply to a hardcoded, single-credential, device-local login.

---

# **5. Interface Design**

## **5.1 User Interfaces**

### **SDS-IF-1 — [Deprecated] Registration Interface**

**Status:** Removed. Registration does not exist in this architecture — login is a static, hardcoded credential check with no account creation (see decisions log §0). This ID is retained, marked deprecated, for traceability continuity only.

---

### **SDS-IF-2 — Static Login Interface**

**SRS:** SRS-FR-2

Inputs:

* Email-style text input.
* Password-style text input.
* Login button.

Outputs:

* Match → app-lock state set to `UNLOCKED`, application entered.
* No match → remain `LOCKED`, user-facing error, retry allowed.

---

### **SDS-IF-3 — [Deprecated] Password Reset Interface**

**Status:** Removed. There is no password-reset/forgot-password flow and no recovery flow of any kind — the static credential is fixed and there is no real lockout risk to recover from (see decisions log §0). This ID is retained, marked deprecated, for traceability continuity only.

---

### **SDS-IF-4 — Workout Planning Interface**

**SRS:** SRS-FR-7–SRS-FR-14

Supports:

* Exercise selection (with type-appropriate fields shown per SDS-COMP-4/5).
* Plan creation.
* Target configuration.
* Plan modification.
* Plan deletion.

---

### **SDS-IF-5 — Scheduling Interface**

**SRS:** SRS-FR-15–SRS-FR-24

Supports:

* Weekday assignment (one plan per weekday max).
* Weekly-recurrence configuration.
* Schedule viewing.
* Schedule modification.
* Schedule removal.

---

### **SDS-IF-6 — Active Workout Interface**

**SRS:** SRS-FR-25–SRS-FR-32, SRS-NFR-2A (DEFERRED — app-backgrounded timer behavior)

Supports:

* Planned exercise information (type-appropriate fields).
* Actual performance entry.
* Auto-starting, skippable rest timer.
* Pause/resume of the active exercise (app-backgrounded behavior: **deferred**, Appendix F).
* Completion.
* Skip.
* Finish (persists; requires ≥1 logged set).
* Cancel (always discards; nothing persisted).

---

### **SDS-IF-7 — History Interface**

**SRS:** SRS-FR-36–SRS-FR-38

Supports:

* Completed workout list.
* Individual workout details.

---

### **SDS-IF-8 — Progress and Statistics Interface**

**SRS:** SRS-FR-36–SRS-FR-41

Supports:

* Performance comparison.
* Training volume.
* Duration.
* Exercise statistics.
* Personal bests view (metric definition **deferred** — Appendix F).

---

## **5.2 Internal Component Interfaces**

### **SDS-IF-9 — App Lock State Interface**

**SRS:** SRS-FR-2, SRS-FR-3, SRS-FR-6

```
Static Local Login Component
        │
        ▼
Local App Lock State
        │
        ├── UNLOCKED
        └── LOCKED
```

---

### **SDS-IF-10 — Validation Interface**

**SRS:** SRS-FR-42–SRS-FR-46

```
Feature Component
      │
      ▼
Validation Component
      │
 ┌────┴────┐
 ▼         ▼
Valid    Invalid
 │         │
 ▼         ▼
Persist   Reject
```

---

### **SDS-IF-11 — Persistence Interface**

**SRS:** SRS-FR-33–SRS-FR-46

Feature components communicate with the Drift Persistence Boundary for:

* Create.
* Read.
* Update.
* Delete where permitted.

All operations are local, asynchronous on-device calls — there is no network round trip to account for.

---

### **SDS-IF-12 — Statistics Calculation Interface**

**SRS:** SRS-FR-36–SRS-FR-41

```
Valid Completed Workout Records
          │
          ▼
Statistics Component
          │
          ├── Workout Count
          ├── Volume
          ├── Duration
          ├── Exercise Statistics
          └── Personal Best (metric: deferred)
```

---

## **5.3 Local System Interfaces (No External Systems)**

The application has **no external system interfaces**. It is fully offline. The two IDs below are retained from the prior version for traceability continuity.

### **SDS-IF-13 — [Deprecated] Firebase Authentication Interface**

**Status:** Removed. There is no external authentication system; login is a static, hardcoded, on-device check (SDS-COMP-2/15).

---

### **SDS-IF-14 — Local Drift Persistence Interface**

**SRS:** SRS-FR-7–SRS-FR-46

Purpose (now a local, not external, interface):

* User profile persistence.
* Exercise catalogue read access.
* Workout plan persistence.
* Workout session persistence.
* Historical record retrieval.

All operations are in-process calls to the local Drift tables described in SDS-COMP-13 — there is no external system, and no network transport, behind this interface.

---

## **5.4 Communication/Integration Patterns**

The system uses **asynchronous (`Future`-based), in-process, local calls** for all application data operations. There is no request/response over a network in any part of the application.

### **Login**

```
Mobile UI
  │
  │ Credential input
  ▼
Static Credential Check (in-process)
  │
  │ Match / no-match
  ▼
Mobile UI
```

### **Drift**

```
Mobile UI / Component
  │
  │ Local read/write call
  ▼
Drift / SQLite (on-device)
  │
  │ Result
  ▼
Mobile UI / Component
```

No background synchronization, offline write queue, or network call of any kind is defined anywhere in the system.

---

# **6. Data Design**

## **6.1 Data Entities and Relationships**

### **SDS-DATA-1 — Local App Access State**

**SRS:** No dedicated SRS FR (see SRS-FR-49 note — login is architectural/design-level only), SRS-NFR-4

Held in application memory (not a persisted identity record):

```
appLockState: LOCKED | UNLOCKED
```

There is no UID, account, or persisted identity — this replaces "Authenticated User Identity" from the deprecated Firebase-based design.

---

### **SDS-DATA-2 — User Profile**

**SRS:** SRS-FR-47, SRS-FR-48, SRS-FR-49, SRS-NFR-4, SRS-NFR-9

```
user_profiles (table, single row)
```

Contains only the fields approved in the decisions log: display name, fitness goal, experience level, height, weight (plus createdAt/updatedAt housekeeping fields). No dateOfBirth field — it was part of the deprecated design and is not in the approved field list.

---

### **SDS-DATA-3 — Exercise**

**SRS:** SRS-FR-1, SRS-FR-2

```
exercises (table)
    exerciseId (primary key) → { name, type, ... }
```

`type` ∈ { `weighted`, `time-based`, `bodyweight` } — added in this version; drives which fields a Workout Plan / Workout Execution / Workout Record entry may carry.

Relationship:

```
Exercise
   ▲
   │ referenced by
   │
Workout Plan
   │
   │ produces actual performance (on Finish only)
   ▼
Workout Session
```

---

### **SDS-DATA-4 — Workout Plan**

**SRS:** SRS-FR-9–SRS-FR-14, SRS-FR-42–SRS-FR-46

```
workout_plans (table)
    planId (primary key)
plan_exercises (child table → workout_plans, ON DELETE CASCADE)
```

Plan exercises are represented as ordered child rows of the plan, with fields gated by exercise `type` (see SDS-COMP-5).

---

### **SDS-DATA-5 — Workout Schedule**

**SRS:** SRS-FR-15–SRS-FR-24, SRS-NFR-7

```
schedule_entries (table)
    weekday (primary key) → planId, planName
```

Weekly recurrence only; at most one `planId` per weekday. Schedule data represents future planned activity; schedule changes do not mutate completed sessions.

---

### **SDS-DATA-6 — Workout Session**

**SRS:** SRS-FR-25–SRS-FR-41, SRS-FR-44–SRS-FR-46

```
workout_sessions (table)
    sessionId (primary key)
session_exercises (child table → workout_sessions, ON DELETE CASCADE)
actual_sets (child table → session_exercises, ON DELETE CASCADE)
```

The session stores actual performance independently of the current workout plan. Duration values are stored as seconds and displayed as mm:ss for time-based exercises. There is no `status`/"incomplete" field — every stored session is, by construction, completed (see SDS-COMP-7/8).

---

### **SDS-DATA-7 — Derived Statistics**

**SRS:** SRS-FR-36–SRS-FR-41

Statistics are derived from valid workout sessions in the `workout_sessions` table. They are logically derived, not stored as an independent authoritative record. Personal Best metric definition: **deferred** (Appendix F).

---

## **6.2 Data Flow and Transformation Rules**

### **Plan-to-Session Transformation**

```
Workout Plan
     │
     │ Start workout
     ▼
Active Workout (in-memory only)
     │
     │ Actual performance
     ▼
     ├── Cancel ──► Discard (nothing persisted, no history entry)
     │
     ▼ Finish (≥1 set logged)
Completed Session
     │
     ▼
Historical Record (workout_sessions)
```

The transformation copies relevant planned context and stores actual performance separately.

### **Statistics Transformation**

```
Workout Sessions (all persisted sessions — all completed, by construction)
       │
       ▼
Validity Filter (malformed-data check only; no "incomplete" case exists)
       │
       ▼
Valid Completed Records
       │
       ├──► Count
       ├──► Volume
       ├──► Duration
       ├──► Exercise Statistics
       └──► Personal Best (metric: deferred)
```

---

## **6.3 Data Validation Design**

### **SDS-DATA-8 — Validation Rules**

**SRS:** SRS-FR-42–SRS-FR-46

Validation is performed before persistence or calculation.

Rules:

1. Required values must be present.
2. Workout plan names must not be blank.
3. Exercises must exist in the fixed, developer-seeded exercise catalogue.
4. Set values must be invalid-rejected per applicable rules.
5. Repetition values must be invalid-rejected per applicable rules (weighted, bodyweight).
6. Weight must be strictly positive for weighted exercises; not applicable to bodyweight/time-based.
7. Duration (seconds) must be non-negative for time-based exercises.
8. A session is rejected as a persistable "completed workout" unless it has ≥1 logged set and an explicit Finish action (SDS-COMP-7). Cancelled sessions are never validated for persistence — they are discarded before validation would apply.

---

## **6.4 Data Retention and Archival Design**

**SRS:** SRS-NFR-5, SRS-NFR-6, SRS-NFR-10, SRS-NFR-11

The MVP does not define a separate archival store.

### **Design constraints**

* Completed workout records remain available on-device, in the Drift database, for as long as the app is installed and its local storage is intact.
* Uninstalling the app or clearing its local storage deletes all application data; there is no cloud backup or recovery.
* No automatic archival process is introduced.
* No account deletion/cascading cleanup mechanism is included in MVP (there is no account to delete).
* No data export mechanism is included in MVP.

---

# **7. Non-Functional Design**

## **7.1 Performance Design Decisions**

**SRS:** SRS-NFR-1, SRS-NFR-2, SRS-NFR-3

### **SDS-NFR-1**

**Parent:** SRS-NFR-1
**BRD:** BRD-NFR-001

The mobile application shall avoid unnecessary sequential operations for normal planning, scheduling, history, and statistics interactions.

### **SDS-NFR-2**

**Parent:** SRS-NFR-2
**BRD:** BRD-NFR-002

Workout timers shall operate independently of any database read/write completion.

**Design constraint:** Timer transitions shall not depend on a persistence operation completing first.

### **SDS-NFR-3**

**Parent:** SRS-NFR-3
**BRD:** BRD-NFR-003

Workout input operations shall not introduce a persistence write on every timer transition.

**Design constraint:** Work/rest timer state shall remain local to the active in-memory execution context until Finish.

---

## **7.2 Scalability Design Decisions**

**SRS:** SRS-NFR-4, SRS-NFR-5

### **SDS-NFR-4**

**Parent:** SRS-NFR-4
**BRD:** BRD-NFR-017

**Not applicable in the same form as v1.0.** There is a single local user per device, so UID-based partitioning is unnecessary; each table already holds only that one user's data. No cross-user isolation logic is designed or required.

### **SDS-NFR-5**

**Parent:** SRS-NFR-5
**BRD:** BRD-NFR-018

Functional components shall communicate through defined boundaries so future capabilities can be introduced without modifying the local persistence model.

**Design constraint:** Future functionality must not require inventing a multi-user or account concept unless a future architecture decision reintroduces one.

---

## **7.3 Availability and Reliability Design Decisions**

**SRS:** SRS-NFR-4–SRS-NFR-7

### **SDS-NFR-6**

**Parent:** SRS-NFR-4
**BRD:** BRD-NFR-004

Successfully persisted completed workout records (in the Drift database) shall be treated as authoritative historical data.

### **SDS-NFR-7**

**Parent:** SRS-NFR-5
**BRD:** BRD-NFR-005

Progress and statistics shall use the same validity rules as workout records.

### **SDS-NFR-8**

**Parent:** SRS-NFR-8
**BRD:** BRD-NFR-006

Cancelled/interrupted active workouts shall never be persisted and shall never modify previously completed sessions (see SDS-COMP-7).

### **SDS-NFR-9**

**Parent:** SRS-NFR-7
**BRD:** BRD-NFR-007

Schedule and plan references shall be validated before scheduling persistence.

**Design constraint:** A schedule cannot persist a reference to an unavailable workout plan.

---

## **7.4 Security Design Decisions**

**SRS:** SRS-NFR-4, SRS-NFR-8–SRS-NFR-12

**Important framing note:** this section describes a local navigation gate, not real security. The static local login provides no actual protection against another person using the device.

### **SDS-NFR-10**

**Parent:** SRS-NFR-8
**BRD:** BRD-NFR-008

Application screens beyond the login screen shall require the local app-lock state to be `UNLOCKED` (SDS-COMP-14).

### **SDS-NFR-11**

**Parent:** SRS-NFR-9
**BRD:** BRD-NFR-009

Only the MVP-required personal profile information shall be collected (display name, fitness goal, experience level, height & weight — see SDS-COMP-3).

### **SDS-NFR-12**

**Parent:** SRS-NFR-10
**BRD:** BRD-NFR-010

**Not applicable in the same form as v1.0.** There is no other local user's data on the device to isolate from; this requirement is satisfied trivially by the single-local-user, single-device model rather than by an access-control mechanism.

### **SDS-NFR-13**

**Parent:** SRS-NFR-11
**BRD:** BRD-NFR-011

Privacy controls shall support applicable target-market data-protection obligations. In this architecture, data never leaves the device, which simplifies (but does not eliminate) this obligation.

### **SDS-NFR-14**

**Parent:** SRS-NFR-12
**BRD:** BRD-NFR-012

The system shall keep workout statistics within the general-fitness product boundary.

**Design constraint:** No clinical or medical interpretation engine shall be implemented.

### **Local access model**

```
Static Local Login
     │
     ▼
Local App Lock State: UNLOCKED
     │
     ▼
Application screens (single local user, single local data set)
```

---

## **7.5 Usability and Accessibility Design Decisions**

**SRS:** SRS-NFR-13–SRS-NFR-16

### **SDS-NFR-15**

**Parent:** SRS-NFR-13
**BRD:** BRD-NFR-013

The application shall use consistent interaction patterns across workout planning, execution, history, and statistics.

### **SDS-NFR-16**

**Parent:** SRS-NFR-14
**BRD:** BRD-NFR-014

Workout recording shall minimize unnecessary interaction.

**Design constraint:** Timer transitions (including rest-timer auto-start) shall not require additional user confirmation.

### **SDS-NFR-17**

**Parent:** SRS-NFR-15
**BRD:** BRD-NFR-015

Validation failures shall be returned as clear user-facing states.

### **SDS-NFR-18**

**Parent:** SRS-NFR-16
**BRD:** BRD-NFR-016

Scheduling operations shall use explicit weekday and weekly-recurrence semantics rather than adaptive scheduling behavior.

---

## **7.6 Maintainability and Observability Design Decisions**

The SRS does not define a dedicated logging/monitoring NFR beyond reliability and maintainability implications.

Therefore, no independent observability subsystem is introduced as a new functional capability.

Design constraints:

* Components shall maintain clear responsibility boundaries.
* Static login failures shall be translated into simple application-level states (no raw provider errors — there is no provider).
* Drift (database) operation failures shall be distinguishable from validation failures.
* Business validation shall remain separate from persistence operations.
* Statistics calculation logic shall be independently testable.

No additional business-facing monitoring capability is introduced.

---

# **8. Error Handling and Recovery Design**

## **SDS-ERR-1 — Static Login Failure**

**SRS:** No dedicated SRS FR (see SRS-FR-49 note — login is architectural/design-level only)

A credential mismatch is converted into a simple application-level error state ("incorrect email or password" or equivalent).

**Recovery:** remain `LOCKED`; display the error; allow retry. There is no lockout/recovery flow — the static credential is fixed and there is no real security to recover from (decisions log §0).

---

## **SDS-ERR-2 — [Deprecated] Registration Failure**

**Status:** Removed. Registration does not exist in this architecture.

---

## **SDS-ERR-3 — [Deprecated] Password Reset Failure**

**Status:** Removed. Password reset does not exist in this architecture.

---

## **SDS-ERR-4 — [Deprecated] (reserved)**

**Status:** Retained for numbering continuity only; no content applies (see SDS-ERR-2/3 above, both superseding the same v1.0 auth-recovery concepts).

---

## **SDS-ERR-5 — Database Read Failure**

**SRS:** SRS-FR-7–SRS-FR-46

```
Database Read
     │
     ├── Success ──► Continue
     │
     └── Failure
           │
           ▼
     Error State
           │
           ▼
       Retry Action
```

There is no cloud fallback — a database read failure (e.g., local storage corruption) is a local, on-device failure, not a connectivity failure.

---

## **SDS-ERR-6 — Database Write Failure**

**SRS:** SRS-FR-9–SRS-FR-46

A failed write must not be represented to the user as successfully persisted data.

The application shall:

1. Detect failure.
2. Display failure state.
3. Preserve currently available in-memory input where appropriate.
4. Allow retry.
5. Avoid creating a duplicate successful record through incorrect UI state.

---

## **SDS-ERR-7 — Validation Failure**

**SRS:** SRS-FR-42–SRS-FR-46

Invalid input is rejected before persistence.

```
Non-positive Weight (weighted)     → Reject
Negative Duration                  → Reject
Invalid Exercise / type mismatch   → Reject
Blank Plan Name                    → Reject
Invalid Repetitions                → Reject
```

---

## **SDS-ERR-8 — Cancelled / Interrupted Workout**

**SRS:** SRS-FR-25, SRS-FR-32, SRS-NFR-6

A cancelled or interrupted active workout is **always discarded in full** — it must never be persisted, in any partial or "incomplete" form, and must never modify previously completed sessions.

```
Active (in memory, not yet Finished)
        │
        ▼
   Cancel / Exit
        │
        ▼
    Discarded — nothing written to the database, no history entry
```

This is a stricter rule than v1.0's "must not modify completed sessions" — v2.0 additionally guarantees no partial record is ever created at all.

---

## **SDS-ERR-9 — Statistics Recalculation Failure**

**SRS:** SRS-FR-41

If underlying workout records change, derived statistics must be calculated from the current valid source records in the Drift database rather than relying on stale derived values.

---

# **9. Design Quality Attributes & Compliance Mapping**

| Quality Attribute | Design Response |
| ----- | ----- |
| Security | Local app-lock navigation gate only (SDS-COMP-14); explicitly **not** real security — static hardcoded login |
| Data Integrity | Validation boundary + separate plan/session structures |
| Reliability | Authoritative local (Drift) persistence |
| Performance | Local in-memory active timer state; Drift reads/writes are local and do not block on network |
| Scalability | Single local user per device — no partitioning required |
| Maintainability | Explicit component boundaries |
| Usability | Simple state-driven workflows |
| Privacy | Minimal profile information; data never leaves the device |
| Compliance | Reduced surface area — no cloud data transfer/storage compliance concerns for this MVP |
| Historical Integrity | Actual workout data separated from plan data |
| Consistency | Shared validity rules for records, progress and statistics |
| Scope Control | No advanced scheduling, AI, social, health integrations, or cloud backend |

---

# **10. Traceability**

## **10.1 SRS-to-SDS Traceability Table**

| SRS Requirement | SDS Components | SDS Interfaces / Data / Design |
| ----- | ----- | ----- |
| SRS-FR-1 | SDS-COMP-1, 2, 3, 15 | SDS-IF-2 (login only — SDS-IF-1 deprecated), SDS-DATA-1, SDS-DATA-2 |
| SRS-FR-2 | SDS-COMP-1, 2, 15 | SDS-IF-2, SDS-IF-9 |
| SRS-FR-3 | SDS-COMP-2, 15 | SDS-IF-9 |
| SRS-FR-4 | SDS-COMP-2 | SDS-ERR-1 |
| SRS-FR-5 | SDS-COMP-2, 15 | SDS-IF-3 (deprecated), SDS-ERR-3 (deprecated) |
| SRS-FR-6 | SDS-COMP-1, 2 | SDS-IF-9 |
| SRS-FR-7 | SDS-COMP-4 | SDS-IF-14, SDS-DATA-3 |
| SRS-FR-8 | SDS-COMP-4, 12 | SDS-IF-4, SDS-DATA-8 |
| SRS-FR-9–14 | SDS-COMP-5, 12, 13 | SDS-IF-4, SDS-DATA-4 |
| SRS-FR-15–24 | SDS-COMP-6, 12, 13 | SDS-IF-5, SDS-DATA-5 |
| SRS-FR-25–32 | SDS-COMP-7, 12 | SDS-IF-6, SDS-ERR-8 |
| SRS-FR-33–35 | SDS-COMP-8, 12, 13 | SDS-DATA-6 |
| SRS-FR-36–38 | SDS-COMP-9, 13 | SDS-IF-7 |
| SRS-FR-39–41 | SDS-COMP-10, 11, 12 | SDS-IF-8, SDS-DATA-7 |
| SRS-FR-36–41 | SDS-COMP-11, 12 | SDS-IF-8, SDS-DATA-7 |
| SRS-FR-42–46 | SDS-COMP-12, 13 | SDS-IF-10, SDS-DATA-8, SDS-ERR-7 |
| SRS-FR-47–49 | SDS-COMP-3 | SDS-DATA-2 |
| SRS-NFR-1 | SDS-COMP-1, 7 | SDS-NFR-1 |
| SRS-NFR-2 | SDS-COMP-7 | SDS-NFR-2 |
| SRS-NFR-3 | SDS-COMP-7, 13 | SDS-NFR-3 |
| SRS-NFR-4 | SDS-COMP-13, 14, 15 | SDS-NFR-6, 10, 12 (12 now N/A — single local user) |
| SRS-NFR-5 | SDS-COMP-10, 11, 12 | SDS-NFR-7 |
| SRS-NFR-6 | SDS-COMP-7, 8 | SDS-NFR-8 |
| SRS-NFR-7 | SDS-COMP-5, 6 | SDS-NFR-9 |
| SRS-NFR-8 | SDS-COMP-14, 15 | SDS-NFR-10 |
| SRS-NFR-9 | SDS-COMP-3 | SDS-NFR-11 |
| SRS-NFR-10 | SDS-COMP-14 | SDS-NFR-12 (N/A — single local user) |
| SRS-NFR-11 | SDS-COMP-14 | SDS-NFR-13 |
| SRS-NFR-12 | SDS-COMP-1, 11 | SDS-NFR-14 |
| SRS-NFR-13 | SDS-COMP-1–12 | SDS-NFR-15 |
| SRS-NFR-14 | SDS-COMP-7 | SDS-NFR-16 |
| SRS-NFR-15 | SDS-COMP-12 | SDS-NFR-17 |
| SRS-NFR-16 | SDS-COMP-6 | SDS-NFR-18 |

---

## **10.2 Full-Chain Traceability Table**

| BRD Requirement | SRS Requirement | SDS Design |
| ----- | ----- | ----- |
| BRD-FR-1 | SRS-FR-7 | SDS-COMP-4, SDS-DATA-3 |
| BRD-FR-2 | SRS-FR-8 | SDS-COMP-4, SDS-COMP-12 |
| BRD-FR-3–8 | SRS-FR-9–14 | SDS-COMP-5, SDS-DATA-4 |
| BRD-FR-9–18 | SRS-FR-15–24 | SDS-COMP-6, SDS-DATA-5 |
| BRD-FR-19–26 | SRS-FR-25–32 | SDS-COMP-7 |
| BRD-FR-27–29 | SRS-FR-33–35 | SDS-COMP-8, SDS-DATA-6 |
| BRD-FR-30–32 | SRS-FR-36–38 | SDS-COMP-9 |
| BRD-FR-33–35 | SRS-FR-39–41 | SDS-COMP-10 |
| BRD-FR-36–41 | SRS-FR-36–41 | SDS-COMP-11 |
| BRD-FR-42–46 | SRS-FR-42–46 | SDS-COMP-12 |
| BRD-NFR-1 | SRS-NFR-1 | SDS-NFR-1 |
| BRD-NFR-2 | SRS-NFR-2 | SDS-NFR-2 |
| BRD-NFR-3 | SRS-NFR-3 | SDS-NFR-3 |
| BRD-NFR-4 | SRS-NFR-4 | SDS-NFR-6 |
| BRD-NFR-5 | SRS-NFR-5 | SDS-NFR-7 |
| BRD-NFR-6 | SRS-NFR-6 | SDS-NFR-8 |
| BRD-NFR-7 | SRS-NFR-7 | SDS-NFR-9 |
| BRD-NFR-8 | SRS-NFR-8 | SDS-NFR-10 |
| BRD-NFR-9 | SRS-NFR-9 | SDS-NFR-11 |
| BRD-NFR-10 | SRS-NFR-10 | SDS-NFR-12 (N/A) |
| BRD-NFR-11 | SRS-NFR-11 | SDS-NFR-13 |
| BRD-NFR-12 | SRS-NFR-12 | SDS-NFR-14 |
| BRD-NFR-13 | SRS-NFR-13 | SDS-NFR-15 |
| BRD-NFR-14 | SRS-NFR-14 | SDS-NFR-16 |
| BRD-NFR-15 | SRS-NFR-15 | SDS-NFR-17 |
| BRD-NFR-16 | SRS-NFR-16 | SDS-NFR-18 |

**Authentication requirements note:** SRS-FR-1–SRS-FR-6 were originally derived from a Firebase Authentication Module specification. That module is deprecated; these requirements are now satisfied by the Static Local Login Component (SDS-COMP-2/15) at a much reduced scope (no registration/reset). Any residual SRS wording implying real authentication should be corrected in the next SRS revision — flagged here, not silently resolved by this SDS.

---

# **11. Verification and Validation Criteria**

| Design Element | Verification Method | Acceptance Condition |
| ----- | ----- | ----- |
| SDS-COMP-1 | Architecture review + system test | Correct locked/unlocked application boundary |
| SDS-COMP-2 | Integration test | Correct credential match/no-match, no registration/reset paths exist |
| SDS-COMP-3 | Integration test | Profile fields (name, goal, experience, height, weight) persist and reload correctly from the Drift database |
| SDS-COMP-4 | Integration test | Seeded exercise catalogue (with type) can be read and cannot be modified by clients |
| SDS-COMP-5 | Functional test | Plans can be created, edited and deleted according to requirements, respecting exercise type |
| SDS-COMP-6 | Functional test | Valid weekly schedules persist; one-plan-per-weekday rule enforced; invalid schedules rejected |
| SDS-COMP-7 | System test | Active workout transitions operate without any persistence I/O blocking the timer; rest timer auto-starts and is skippable; cancel always discards |
| SDS-COMP-8 | Integration test | Completed sessions persist with actual performance; no session exists that wasn't Finished |
| SDS-COMP-9 | System test | Local history displays correctly from the Drift database |
| SDS-COMP-10 | Calculation test | Progress excludes invalid records |
| SDS-COMP-11 | Calculation test | Statistics (excluding PB metric, which is deferred) match approved calculation rules |
| SDS-COMP-12 | Unit + integration test | Invalid values cannot become valid persisted performance |
| SDS-COMP-13 | Integration test | All persistent application data uses Drift; no network call occurs |
| SDS-COMP-14 | Functional test | Locked state blocks navigation to application screens |
| SDS-COMP-15 | Unit test | Credential check returns correct match/no-match for known inputs |
| SDS-IF-1 | N/A | Deprecated — no registration to verify |
| SDS-IF-2 | UI/system test | Correct login reaches unlocked application |
| SDS-IF-3 | N/A | Deprecated — no password reset to verify |
| SDS-IF-4 | Functional test | Workout plan operations meet SRS behavior |
| SDS-IF-5 | Functional test | Scheduling operations meet SRS behavior |
| SDS-IF-6 | System test | Workout execution supports required state transitions |
| SDS-IF-7 | System test | Historical records are correctly retrieved |
| SDS-IF-8 | Calculation/system test | Progress/statistics display valid derived values |
| SDS-IF-9 | Integration test | App lock state controls application access |
| SDS-IF-10 | Unit/integration test | Invalid data is rejected |
| SDS-IF-11 | Integration test | Drift persistence failures are correctly surfaced |
| SDS-IF-12 | Calculation test | Derived statistics are consistent with valid records |
| SDS-IF-13 | N/A | Deprecated — no external authentication system |
| SDS-IF-14 | Integration test | Drift read/write boundaries operate correctly, fully offline |
| SDS-DATA-1 | Functional test | App lock state transitions correctly on login/logout |
| SDS-DATA-2 | Data test | Profile data persists correctly in the single local record |
| SDS-DATA-3 | Data test | Exercise references resolve to valid catalogue records; type flag is present and correct |
| SDS-DATA-4 | Data test | Plan structures retain required target information, gated by exercise type |
| SDS-DATA-5 | Functional test | Schedule changes do not modify completed sessions; one-plan-per-weekday enforced |
| SDS-DATA-6 | Data integrity test | Actual session performance is independent of current plan; no session exists unless Finished |
| SDS-DATA-7 | Calculation test | Statistics derive only from valid records |
| SDS-DATA-8 | Validation test | Invalid data is rejected |
| SDS-NFR-1 | Performance benchmark | Normal application operations remain responsive |
| SDS-NFR-2 | Timing benchmark | Work/rest transitions remain timely and consistent |
| SDS-NFR-3 | Performance test | Recording does not introduce unnecessary interaction delays |
| SDS-NFR-4 | Architecture review | Confirmed N/A — single local user, no partitioning needed |
| SDS-NFR-5 | Architecture review | Components remain extensible without MVP scope expansion |
| SDS-NFR-6 | Reliability test | Successfully persisted records remain available |
| SDS-NFR-7 | Consistency test | Statistics agree with underlying valid records |
| SDS-NFR-8 | Interruption test | Cancelled/interrupted activity is never persisted in any form |
| SDS-NFR-9 | Scheduling test | Invalid plan references cannot be persisted |
| SDS-NFR-10 | Functional/security test | Locked state blocks access; note this is a navigation gate, not real security |
| SDS-NFR-11 | Privacy review | Only required profile information is collected |
| SDS-NFR-12 | Architecture review | Confirmed N/A — single local user, nothing to isolate from |
| SDS-NFR-13 | Compliance review | Data handling aligns with applicable requirements; no cloud transfer occurs |
| SDS-NFR-14 | Product review | System does not provide clinical/medical interpretation |
| SDS-NFR-15 | Usability test | Core workflows are understandable |
| SDS-NFR-16 | Workout usability test | Workout recording minimizes unnecessary interaction |
| SDS-NFR-17 | Validation usability test | Invalid input produces clear feedback |
| SDS-NFR-18 | Scheduling usability test | Basic weekly scheduling behaves predictably |
| SDS-ERR-1–9 | Negative-path integration/system tests | Defined failure states are handled without corrupting valid data; SDS-ERR-2/3/4 confirmed N/A (deprecated) |

---

# **12. Appendix**

## **Appendix A — Authoritative Data Ownership Model**

```
Local Device
     │
     ▼
Drift / SQLite (local persistence)
     │
     ├── user_profiles (single row)
     │
     ├── exercises/{exerciseId}
     │
     ├── workout_plans/{planId} ── plan_exercises
     │
     ├── schedule_entries/{weekday}
     │
     └── workout_sessions/{sessionId} ── session_exercises ── actual_sets
```

### **Ownership Rules**

There is a single local user per device install. All tables above belong to that one user by construction — there is no UID, account, or partition key, and no cross-user access to guard against.

---

## **Appendix B — Static Local Login Boundary**

```
┌─────────────────────────┐
│      Mobile Client      │
│                         │
│ Email + Password input │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│ Static Credential Check │
│ (hardcoded, on-device)  │
└────────────┬────────────┘
             │
             ▼
       Match / No match
             │
             ▼
      App Lock State
     (UNLOCKED / LOCKED)
             │
             ▼
┌─────────────────────────┐
│         Drift           │
│  (unaffected by login — │
│   already local-only)   │
└─────────────────────────┘
```

**This is not a security boundary.** No password is stored, hashed, or transmitted anywhere; the credential comparison is a fixed, hardcoded check performed entirely on-device.

---

## **Appendix C — Persistence Constraint**

The ForgeApp (Workout Tracker) MVP has exactly one application persistence mechanism:

> **Drift (local, on-device SQLite)**

The mobile application does **not** use:

* Firebase / Cloud Firestore
* Any other cloud/remote database
* A network-backed synchronization engine
* A conflict-resolution engine
* Any REST/gRPC API for application data

The presence of Drift as the sole local persistence layer is intentional and forms the core of the v2.0 MVP architecture — reversing the v1.0 "no local database" constraint.

---

## **Appendix D — Historical Integrity Principle**

The architecture enforces the following separation:

```
                ┌────────────────────┐
                 │   Workout Plan     │
                 │   Planned Targets  │
                 └─────────┬──────────┘
                           │
                       Start
                           │
                           ▼
                 ┌────────────────────┐
                 │ Active Workout     │
                 │ Actual Performance │
                 │ (in-memory only)   │
                 └─────────┬──────────┘
                           │
                    ┌──────┴──────┐
                    ▼             ▼
                 Finish         Cancel
                    │             │
                    ▼             ▼
          ┌────────────────────┐  Discarded
          │ Workout Session    │  (no record)
          │ Historical Record  │
          │ (Drift)            │
          └────────────────────┘
```

A subsequent change to the workout plan must not rewrite the historical session.

---

## **Appendix E — Architectural Baseline (Revised)**

The following decisions are locked for SDS Version **2.0**, replacing the v1.0 baseline in its entirety:

1. **Drift (SQLite) is the sole application data store.** (Replaces: "Cloud Firestore is the application data store.")
2. **Login is a static, hardcoded local credential check** — not real authentication. (Replaces: "Firebase Authentication is the authentication boundary" and "Email/password is the only authentication mechanism.")
3. **No registration, password reset, or login-recovery flow of any kind exists.** (Replaces the implicit v1.0 assumption that these existed via Firebase.)
4. **There is a single local user per device; no UID-based data partitioning exists.** (Replaces: "User-owned Firestore data is nested beneath `users/{uid}`.")
5. Exercise catalogue data is fixed, developer-seeded, and client-read-only (unchanged from v1.0, now Drift-backed instead of Firestore-backed).
6. Workout plans and workout sessions are separate logical entities (unchanged from v1.0, now relational Drift tables instead of Firestore collections).
7. Actual workout performance is retained independently from plan targets (unchanged from v1.0).
8. Statistics and progress are derived from valid completed workout records (unchanged from v1.0); **the Personal Best metric definition itself is explicitly deferred — not locked** (see Appendix F).
9. **The application operates fully offline; no network call exists anywhere in the app.** (Replaces: "Online-first operation" / "Internet connectivity assumed available.")
10. No offline synchronization mechanism is needed, since there is nothing remote to synchronize with.
11. No password is stored anywhere — the login credential is a fixed value in application code, not user data.
12. Cancelled/exited workouts are always discarded in full; no "Incomplete" workout state exists. **(New in v2.0.)**
13. The Profile screen is in scope and editable: display name, fitness goal, experience level, height & weight. **(New in v2.0, per decisions log §8.)**
14. Exercises carry an explicit `type` (weighted / time-based / bodyweight); duration is stored in seconds and displayed as mm:ss. **(New in v2.0, per decisions log §5.)**
15. The rest timer auto-starts on set completion and is user-skippable. **(New in v2.0, per decisions log §6.)**
16. No new MVP capabilities beyond those listed in the decisions log are introduced by this SDS.

**Explicitly NOT locked** (see Appendix F): Personal Best calculation metric; app-backgrounded timer behavior.

---

## **Appendix F — Open / Deferred Decisions (Not Finalized)**

These items are intentionally left open. They must not be silently defaulted by implementers; each needs a dedicated future product-owner decision.

| # | Item | Resolves | Status |
| ----- | ----- | ----- | ----- |
| 1 | **Personal Best calculation logic** — which metric(s) (heaviest weight / highest reps / highest volume / longest duration — one or more) define a "Personal Best" per exercise | PD-004; and SRS-FR-40 (DEFERRED) | **Deferred** — pending a future brainstorming session with the product owner |
| 2 | **App-backgrounded timer behavior** — whether the active-workout/rest timer should pause-and-resume, wall-clock-catch-up, or end the session when the app is backgrounded | Related to PD-007; and SRS-NFR-2A (DEFERRED) | **Deferred** — pending a future product-owner decision |

Both items may be structurally represented in the UI/design (e.g., a Personal Bests view exists; background-handling hooks exist) without their exact behavior being finalized or locked by this document.
