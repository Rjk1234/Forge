# Screen & Flow / Use-Case Inventory
## Workout Tracker

| Attribute | Details |
|---|---|
| Document Type | Screen & Flow / Use-Case Inventory (Design-Facing Requirements Bridge) |
| Document Version | 1.1 |
| Document Status | Revised — Product Owner Clarifications Incorporated (2026-09-05); ready for Figma / User Story authoring |
| Derivation Level | Derived Document — Level 3 |
| Parent Document | System Design Specification (SDS), Version 1.0 — **superseded on architecture** by the ForgeApp Confirmed Product Decisions Log (2026-09-05), see Changelog and §0 note below |
| Grandparent Document | Software Requirements Specification (SRS), Version 1.0 |
| Great-Grandparent Document | Business Requirements Document (BRD), Version 1.0 |
| Purpose | Bridges the SDS/SRS/BRD requirement chain into a screen-level, state-level inventory that can be used directly to (a) build Figma frames/flows and (b) author user stories, without re-deriving requirements |
| ID Scheme | `FLOW-*` (flow), `SCR-*` (screen), `UC-<SCR>-*` (use case / UI state within a screen). IDs are never renumbered once assigned — a screen removed from scope is marked **REMOVED / OUT OF SCOPE** in place rather than deleted, to preserve numbering and traceability history. |
| Change Policy | No new functionality is introduced beyond what is confirmed in the Decisions Log dated 2026-09-05. Every screen and every use case MUST trace to at least one SRS-FR-*/SRS-NFR-* ID and, where applicable, the SDS-COMP-*/SDS-IF-*/SDS-DATA-*/SDS-ERR-* ID(s) that define its behavior. If a state cannot be traced, it must not appear here without being flagged as an **Assumption**. |

---

## Changelog

**v1.1 — 2026-09-05 — Product Owner Clarification Session**
Revised following a product-owner clarification session confirming ForgeApp is a fully offline, local-only (Drift-persisted) POC/MVP with no backend, no real authentication, and no network calls of any kind (see ForgeApp Confirmed Product Decisions Log, §0, 2026-09-05). Changes in this revision:
- **Architecture:** All Firebase Authentication / Cloud Firestore references corrected to reflect the local-only (Drift) architecture; "no connectivity" framing removed or reframed as not applicable, since the app has no network dependency.
- **Removed (marked REMOVED / OUT OF SCOPE, not deleted, for traceability):** SCR-02 Registration, SCR-04 Forgot Password, SCR-05 Password Reset Email Sent. There is no registration, password-reset, or account-recovery flow of any kind — login is a static, hardcoded demo credential check only.
- **SCR-01 (Splash) / SCR-03 (Login):** Rewritten to reflect a static/demo login (local hardcoded credential string match) — no real auth service, no "unknown account" enumeration-safe messaging beyond a simple match/no-match, no forgot-password link, no offline/service-failure states.
- **SCR-25 (Profile / Account):** **[ASSUMPTION]** flag removed — confirmed in scope and editable by the product owner on 2026-09-05. Fields updated to exactly: display name, fitness goal, experience level, height & weight (informational only, no calculations).
- **FLOW-11 (Cross-Cutting / Global States):** Firestore-write-failure, offline-banner, and session-invalidation states removed as not applicable (no server, no session to invalidate). Replaced with a minimal local-storage (Drift) read/write failure state.
- **SCR-09 (Create/Edit Plan) and scheduling screens (SCR-12/SCR-13):** Updated to reflect the exercise type flag (weighted/time-based/bodyweight) driving which input fields show, weekly recurrence with a maximum of one plan per weekday, and duration entered as mm:ss.
- **SCR-16 (Active Workout) / SCR-18 (Cancel) / SCR-19 (Summary):** Updated so that completion = at least one set logged + explicit Finish; cancel always discards in full (no "Incomplete" saved state, no discard-vs-save prompt); rest timer auto-starts on set completion and is skippable; app-backgrounded timer behavior explicitly flagged **DEFERRED / OPEN** (not designed).
- **SCR-24 (Personal Bests):** Metric definition explicitly flagged **DEFERRED / OPEN** — screen remains structurally in scope, but no metric (heaviest weight / highest reps / highest volume / longest duration) is finalized.
- **Document status/version** updated accordingly; this Changelog added.

**v1.1.1 — 2026-09-05 — Cleanup pass: leftover "Offline / No Connection" rows**
Corrected 8 leftover rows (UC-SCR08-05, UC-SCR10-04, UC-SCR11-05, UC-SCR14-05, UC-SCR20-05, UC-SCR21-05, UC-SCR22-06, UC-SCR23-06) that still read as "No connectivity / Offline state," contradicting the local-only architecture. Each already had an adjacent Error/System Failure row covering the genuine local-storage (Drift) read/write failure equivalent for that screen, so each was marked `*(removed)*` with a "REMOVED — not applicable" explanation pointing to its sibling local-equivalent row, matching the pattern already used elsewhere in this document (e.g., SCR-09/12/13/15/16/19/25).

**v1.1.2 — 2026-09-05 — Traceability fix: SDS-ERR-7 mislabeled as database read/write failure**
Corrected 8 rows (UC-SCR09-10, UC-SCR12-05, UC-SCR13-07, UC-SCR19-04, UC-SCR24-04, UC-SCR25-06, UC-SCR27-02, UC-SCR27-03) that incorrectly cited SDS-ERR-7 (Validation Failure) for what are actually local-storage read/write failures; each now cites SDS-ERR-5 (Database Read Failure) and/or SDS-ERR-6 (Database Write Failure) as appropriate. Also corrected the self-contradicting FLOW-11 row in §1 (Flow Index) to correctly identify SDS-ERR-5/SDS-ERR-6 as the applicable local-storage error IDs, and added a corresponding note to §14 (Traceability Coverage Check).

---

## 0. How to Use This Document

> **Architecture note (2026-09-05):** ForgeApp is a fully offline, local-only mobile app using **Drift** (typed SQLite) as its sole persistence layer. There is no Firebase, no Firestore, no cloud backend, and no network call anywhere in the app. Any table row below still framed as "Offline / No Connection" or referencing a backend/server failure is a carryover from an earlier (now deprecated) online-first design and should be read as **not applicable** unless a row has been explicitly revised in this version to describe a local-storage (Drift) equivalent. See the ForgeApp Confirmed Product Decisions Log, §0, for the authoritative architecture statement.

- One **Flow** = a related group of screens a user moves through to accomplish something (matches SDS interface groupings).
- One **Screen** = one Figma frame family (all its states share one layout).
- One **Use Case** = one *state* that screen must be designed for (success, error, loading, empty, etc.) — each becomes a Figma frame variant and, later, a testable user-story acceptance criterion.
- **Traces to** columns carry SRS-FR-*/SRS-NFR-* IDs (requirement) and SDS-COMP-*/SDS-IF-*/SDS-DATA-*/SDS-ERR-* IDs (design mechanism) so nothing is designed without a requirement backing it, and nothing required is missing a screen.
- Items marked **[ASSUMPTION]** are inferred from the SDS data model but are not explicitly backed by a numbered SRS-FR — flag these for confirmation before building user stories from them.

### Use Case Type Legend

| Type | Meaning |
|---|---|
| **Empty** | Screen's first-time/no-data state (nothing created/recorded yet) |
| **Loading** | Data or action is in flight |
| **Success / Positive** | The happy path — valid input, action completes as intended |
| **Negative / Validation** | User input fails a validation rule (client-side or rejected by Validation Component) |
| **Error / System Failure** | Local storage (Drift) read/write failure on-device. There is no backend/network/auth service in this architecture (see §0 note above) — any row still describing one is legacy and superseded. |
| **Offline / No Connection** | **Legacy type, largely not applicable.** The app is local-only and has no network dependency, so there is nothing to be "offline" from. Retained only where a row has been explicitly rewritten as a local-storage-failure equivalent; otherwise treat as removed. |
| **Confirmation** | Destructive or consequential action requires explicit confirmation |
| **Populated** | Normal state with real data present |
| **Placeholder / Skeleton** | Optional loading placeholder shown while Populated state resolves |

---

## 1. Flow Index

| Flow ID | Flow Name | Screens | Traces to (SDS Interface) |
|---|---|---|---|
| FLOW-01 | Authentication (Static/Demo Login) | SCR-01, SCR-03 (SCR-02, SCR-04, SCR-05 **REMOVED — OUT OF SCOPE**, see §3) | SDS-IF-2, SDS-IF-9 |
| FLOW-02 | Home / Navigation Shell | SCR-06 | SDS-COMP-1 |
| FLOW-03 | Exercise Catalogue | SCR-07 | SDS-IF-14, SDS-DATA-3 |
| FLOW-04 | Workout Plan Management | SCR-08–SCR-11 | SDS-IF-4 |
| FLOW-05 | Basic Scheduling | SCR-12–SCR-14 | SDS-IF-5 |
| FLOW-06 | Workout Execution | SCR-15–SCR-19 | SDS-IF-6 |
| FLOW-07 | Workout History | SCR-20–SCR-21 | SDS-IF-7 |
| FLOW-08 | Progress | SCR-22 | SDS-IF-8 |
| FLOW-09 | Statistics | SCR-23–SCR-24 | SDS-IF-8, SDS-IF-12 |
| FLOW-10 | Account | SCR-25–SCR-26 | SDS-COMP-3 |
| FLOW-11 | Cross-Cutting / Global States (Local-Only) | SCR-27 | SDS-ERR-5 (Database Read Failure), SDS-ERR-6 (Database Write Failure) — the applicable local-storage error IDs used throughout this document; the Firebase/Firestore-era error IDs are no longer applicable, see §13 |

---

## 2. Sitemap (Navigation Hierarchy)

```
SCR-01 Splash / Local Login-State Check
 ├── (not "logged in") ──► SCR-03 Login (static/demo credential check)
 │                                     [SCR-02 Registration — REMOVED, out of scope]
 │                                     [SCR-04 Forgot Password — REMOVED, out of scope]
 │                                     [SCR-05 Reset Email Sent — REMOVED, out of scope]
 └── (already "logged in") ──► SCR-06 Home (tab root)
                          ├── Tab: Plans
                          │    ├── SCR-08 Workout Plans List
                          │    │    ├── SCR-09 Create/Edit Plan ──► SCR-07 Exercise Catalogue (picker mode)
                          │    │    ├── SCR-10 Plan Detail ──► SCR-11 Delete Plan Confirmation
                          │    │    └──► SCR-15 Workout Pre-Start
                          ├── Tab: Schedule
                          │    └── SCR-12 Weekly Schedule
                          │         ├── SCR-13 Assign/Edit Schedule
                          │         └── SCR-14 Remove From Schedule Confirmation
                          ├── SCR-15 Workout Pre-Start ──► SCR-16 Active Workout ──► SCR-17 Rest Timer (inline/modal)
                          │                                     ├──► SCR-18 Cancel Confirmation
                          │                                     └──► SCR-19 Workout Summary ──► SCR-06 Home / SCR-20 History
                          ├── Tab: History
                          │    └── SCR-20 Workout History List ──► SCR-21 Workout History Detail
                          ├── Tab: Progress
                          │    └── SCR-22 Progress Comparison
                          ├── Tab: Stats
                          │    └── SCR-23 Statistics Dashboard ──► SCR-24 Personal Bests
                          └── SCR-25 Profile / Account ──► SCR-26 Logout Confirmation ──► SCR-01
```

---

## 3. FLOW-01 — Authentication (Static/Demo Login)

> **Revised 2026-09-05:** Per Decisions Log §0, ForgeApp has no real authentication. Login is a static, hardcoded demo credential (email + password inputs, Login button) checked as a simple local string match — there is no auth service, no session token, no registration, and no password-recovery flow of any kind. "Auth state" below means only a simple local unlocked/locked flag, not a real session.

### SCR-01 — Splash / Local Login-State Check
**Purpose:** Determine whether the local "logged in" flag is set and route accordingly. No user-visible interaction.
**Traces to:** SRS-FR-3, SRS-FR-6 · SDS-COMP-1
**Entry points:** App cold start / app resume
**Exit points:** SCR-03 (not logged in) or SCR-06 (logged in)
**Auth requirement:** N/A (this screen determines the local login-state flag)

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR01-01 | Loading | App launch, local login-state flag being read from the local database | Show brand/splash indicator; no interaction available | SDS-COMP-1 |
| UC-SCR01-02 | Success | Local flag indicates already "logged in" | Route to SCR-06 | SRS-FR-3, SRS-FR-6 |
| UC-SCR01-03 | Success | Local flag indicates not "logged in" | Route to SCR-03 | SRS-FR-2 |
| UC-SCR01-04 | *(removed)* | ~~No connectivity at launch~~ | **REMOVED — not applicable.** There is no network call at launch; the local flag read from the local database cannot fail due to connectivity. A genuine local-storage read failure, if it occurs, falls under FLOW-11 (see §13). | — |

---

### SCR-02 — Registration — **REMOVED / OUT OF SCOPE (2026-09-05)**
**Why removed:** Per Decisions Log §0, ForgeApp has no registration flow. Login uses a single static, hardcoded demo credential; there is no account creation, no user data collected at "signup." Profile fields (display name, fitness goal, experience level, height & weight — see SCR-25) are set/edited directly on the Profile screen after the static login, not collected at registration.
**Disposition:** This ID is retained, unused, for traceability continuity only. No screen, use case, or flow references SCR-02 as of v1.1. Do not build a Figma frame or user story for this ID.

---

### SCR-03 — Login (Static / Demo)
**Purpose:** Check the entered credentials against a single hardcoded demo email/password pair via simple local string match, purely so the user can "play through" a login-like flow.
**Traces to:** SRS-FR-2 · SDS-COMP-2
**Entry points:** SCR-01 · SCR-26 (post-logout)
**Exit points:** SCR-06 (success)
**Key content:** Email field, password field, Login action. **No "Forgot password?" link and no "Create account" link — neither exists (Decisions Log §0).**
**Auth requirement:** None (pre-login screen)

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR03-01 | Empty / Default | Screen first opened | Empty fields, Login disabled until both fields are non-empty | SRS-FR-2 |
| UC-SCR03-02 | Negative / Validation | Malformed email format | Inline field error (basic client-side format check only) | SRS-FR-2 |
| UC-SCR03-03 | Loading | Form submitted | Brief local-check loading state (no network round trip) | SDS-COMP-2 |
| UC-SCR03-04 | Success | Entered credentials match the hardcoded demo value | Route to SCR-06; local "logged in" flag set locally | SRS-FR-2 |
| UC-SCR03-05 | Negative / Business Rule | Entered credentials do not match the hardcoded demo value | Simple generic error: "Email or password is incorrect" (plain local string-mismatch message, not a security-hardened/enumeration-safe design since there is no real account system) | SRS-FR-2 |
| UC-SCR03-06 | *(removed)* | ~~Disabled account~~ | **REMOVED — not applicable.** There is only one static credential; there is no multi-account/disabled-account concept. | — |
| UC-SCR03-07 | *(removed)* | ~~Auth service failure~~ | **REMOVED — not applicable.** There is no external auth service to fail; see Decisions Log §0. | — |
| UC-SCR03-08 | *(removed)* | ~~No connectivity at submit~~ | **REMOVED — not applicable.** Credential check is a local string match with no network call. | — |

---

### SCR-04 — Forgot Password — **REMOVED / OUT OF SCOPE (2026-09-05)**
**Why removed:** Per Decisions Log §0/§"No login recovery flow of any kind", there is no password-reset request flow. The static credential is fixed and cannot be reset in-app; there is no real lockout risk because there is no real security being enforced.
**Disposition:** ID retained, unused, for traceability continuity only. No Figma frame or user story should be authored for this ID.

---

### SCR-05 — Password Reset Email Sent (Confirmation) — **REMOVED / OUT OF SCOPE (2026-09-05)**
**Why removed:** Depends entirely on SCR-04 (Forgot Password), which is removed. There is no reset-email flow, no external reset page, no email verification step anywhere in the app.
**Disposition:** ID retained, unused, for traceability continuity only. No Figma frame or user story should be authored for this ID.

---

## 4. FLOW-02 — Home / Navigation Shell

### SCR-06 — Home Dashboard
**Purpose:** Authenticated landing screen and tab-navigation root.
**Traces to:** SRS-FR-3, SRS-FR-6 · SDS-COMP-1
**Entry points:** SCR-01, SCR-02, SCR-03 (post-auth) · any tab's "Home" action
**Exit points:** All authenticated tabs/flows
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR06-01 | Empty | New account, no plans/schedule/history exist yet | Onboarding-style empty state prompting "Create your first workout plan" | SRS-FR-9, BR-FR-003 |
| UC-SCR06-02 | Loading | Dashboard summary data being fetched | Skeleton/placeholder cards | SDS-IF-14 |
| UC-SCR06-03 | Populated | User has plans/schedule/history | Shows today's scheduled workout (if any), quick links to Plans/Schedule/History/Progress/Stats | SRS-FR-15, SRS-FR-24, SDS-COMP-6 |
| UC-SCR06-04 | Error / System Failure | Dashboard data fails to load | Error state with retry; navigation shell itself remains usable | SDS-ERR-5 |
| UC-SCR06-05 | *(removed)* | ~~Connectivity lost while on Home~~ | **REMOVED — not applicable.** No network dependency exists anywhere in the app (Decisions Log §0); see FLOW-11 §13. | — |

---

## 5. FLOW-03 — Exercise Catalogue

### SCR-07 — Exercise Catalogue / Browse
**Purpose:** Browse/select valid exercises. Used both as a standalone browse screen and, in **picker mode**, embedded within Create/Edit Plan (SCR-09).
**Traces to:** SRS-FR-7, SRS-FR-8 · SDS-COMP-4, SDS-IF-14, SDS-DATA-3
**Entry points:** SCR-06 (browse mode) · SCR-09 (picker mode)
**Exit points:** SCR-09 (on select, picker mode) · back (browse mode)
**Key content:** Searchable/filterable list of exercises (read-only reference data)
**Auth requirement:** Required (read-only, catalogue itself is shared but access requires sign-in)

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR07-01 | Loading | Catalogue being fetched | Skeleton list | SDS-IF-14 |
| UC-SCR07-02 | Populated | Catalogue loaded | List/grid of exercises, searchable | SRS-FR-7, SDS-DATA-3 |
| UC-SCR07-03 | Empty | Search/filter yields no results | "No exercises match your search" state | SRS-FR-8 |
| UC-SCR07-04 | Success (picker mode) | User selects a valid exercise | Exercise added to the in-progress plan on SCR-09 | SRS-FR-8, SDS-COMP-12 |
| UC-SCR07-05 | Negative / Business Rule | Attempt to reference an exercise not in the catalogue (defensive case — e.g., stale client state) | Selection rejected before it can be added to a plan | SRS-FR-48, SDS-DATA-8 |
| UC-SCR07-06 | Error / System Failure | Catalogue fails to load | Error state with retry | SDS-ERR-5 |
| UC-SCR07-07 | *(removed)* | ~~No connectivity; catalogue not cached locally (no local DB)~~ | **REMOVED — factually superseded.** Per Decisions Log §0/§7, Drift **is** the sole persistence layer and the exercise catalogue is a fixed, developer-seeded list seeded into the Drift database on launch — there is no network fetch to be "offline" from in the first place. | Decisions Log §0, §7 |

---

## 6. FLOW-04 — Workout Plan Management

### SCR-08 — Workout Plans List
**Traces to:** SRS-FR-9–SRS-FR-14 · SDS-COMP-5, SDS-IF-4, SDS-DATA-4
**Entry points:** SCR-06 (Plans tab)
**Exit points:** SCR-09 (create/edit) · SCR-10 (view detail)
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR08-01 | Loading | Plans being fetched | Skeleton list | SDS-IF-14 |
| UC-SCR08-02 | Empty | No plans created yet | Empty state with "Create a workout plan" call to action | BR-FR-003 |
| UC-SCR08-03 | Populated | One or more plans exist | List of named plans with summary (e.g., exercise count) | SRS-FR-9, SDS-DATA-4 |
| UC-SCR08-04 | Error / System Failure | Plans fail to load | Error state with retry | SDS-ERR-5 |
| UC-SCR08-05 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** Plans are read from local storage (Drift) only, with no network dependency; see UC-SCR08-04 for the local-equivalent failure case. | — |

---

### SCR-09 — Create / Edit Workout Plan
**Traces to:** SRS-FR-9–SRS-FR-14, SRS-FR-48 · SDS-COMP-5, SDS-COMP-12, SDS-IF-4, SDS-DATA-4, SDS-DATA-8, SDS-ERR-7
**Entry points:** SCR-08 ("New plan" / edit action) · SCR-10 (edit action)
**Exit points:** SCR-10 (on save) · SCR-08 (on cancel/back)
**Key content:** Plan name field, exercise list (add via SCR-07), per-exercise target fields. **Revised 2026-09-05 (Decisions Log §5):** each exercise carries a fixed **type flag** — `weighted` (reps + weight fields shown), `time-based` (duration field only, entered/displayed as **mm:ss**, no weight field), or `bodyweight` (reps only, no weight field at all). The form must branch on this flag per exercise rather than always showing a single generic reps+weight+duration form.
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR09-01 | Empty / Default | New plan, create mode | Blank name field, empty exercise list, "Add exercise" action | SRS-FR-9 |
| UC-SCR09-02 | Populated | Edit mode, existing plan loaded | Fields pre-filled with current plan data; per-exercise field set matches that exercise's type flag | SRS-FR-13, SDS-DATA-4 |
| UC-SCR09-03 | Negative / Validation | Blank/whitespace-only plan name on save | Inline error, save blocked | SRS-FR-10 (BR-FR-004), SDS-DATA-8 |
| UC-SCR09-04 | Negative / Validation | Invalid exercise reference | Item flagged/rejected, cannot be saved | SRS-FR-48, SDS-DATA-8 |
| UC-SCR09-05 | Negative / Validation | Non-positive sets/reps entered where required (`weighted`/`bodyweight` types) | Inline field error | SRS-FR-49, SDS-ERR-7 |
| UC-SCR09-06 | Negative / Validation | Non-positive weight entered on a `weighted`-type exercise | Inline field error (field is not shown at all for `time-based`/`bodyweight` types, so this case cannot arise for them) | SRS-FR-50 (BR-FR-044), SDS-ERR-7 |
| UC-SCR09-07 | Negative / Validation | Invalid/non-positive duration entered on a `time-based`-type exercise | Inline field error; duration is entered and displayed as **mm:ss**, stored internally as seconds | SRS-FR-51 (BR-FR-045), SDS-ERR-7, Decisions Log §5 |
| UC-SCR09-08 | Loading | Save submitted | Save action shows brief loading state (local database write) | SDS-IF-4 |
| UC-SCR09-09 | Success | Plan saved (create or edit) | Route to SCR-10 with updated data | SRS-FR-9, SRS-FR-13, SDS-COMP-5 |
| UC-SCR09-10 | Error / System Failure | Local storage (Drift) write fails | Error state; plan not represented as saved; retry available; no duplicate record created | SDS-ERR-6 |
| UC-SCR09-11 | *(removed)* | ~~No connectivity at save~~ | **REMOVED — not applicable.** Save is a local database write with no network dependency; see UC-SCR09-10 for the local-equivalent failure case. | — |
| UC-SCR09-12 | Confirmation | User attempts to leave with unsaved changes | Discard-changes confirmation | Usability constraint, BR-NFR-015 |

---

### SCR-10 — Plan Detail
**Traces to:** SRS-FR-9–SRS-FR-14 · SDS-COMP-5, SDS-DATA-4
**Entry points:** SCR-08 · SCR-09 (post-save)
**Exit points:** SCR-09 (edit) · SCR-11 (delete) · SCR-15 (start workout from this plan)
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR10-01 | Loading | Plan being fetched | Skeleton | SDS-IF-14 |
| UC-SCR10-02 | Populated | Plan loaded | Name, exercise list with targets, actions: Edit / Delete / Start Workout / Schedule | SRS-FR-9, SDS-DATA-4 |
| UC-SCR10-03 | Error / System Failure | Plan fails to load (e.g., deleted elsewhere, read failure) | Error/"not found" state with back action | SDS-ERR-5 |
| UC-SCR10-04 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** Plan detail is read from local storage (Drift) only; see UC-SCR10-03 for the local-equivalent failure case. | — |

---

### SCR-11 — Delete Plan Confirmation
**Traces to:** SRS-FR-14 · SDS-COMP-5
**Entry points:** SCR-10 (Delete action)
**Exit points:** SCR-08 (on confirm) · SCR-10 (on cancel)
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR11-01 | Confirmation | User taps Delete on SCR-10 | Modal explaining the plan (and its schedule assignments) will be removed; historical workout sessions using this plan are unaffected | SRS-FR-14, BR-FR-032 (historical integrity) |
| UC-SCR11-02 | Loading | Confirm tapped | Loading state on confirm action | SDS-IF-4 |
| UC-SCR11-03 | Success | Delete succeeds | Route to SCR-08; plan removed from list | SRS-FR-14 |
| UC-SCR11-04 | Error / System Failure | Delete fails | Error state, plan remains, retry available | SDS-ERR-6 |
| UC-SCR11-05 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** Delete is a local database write with no network dependency; see UC-SCR11-04 for the local-equivalent failure case. | — |

---

## 7. FLOW-05 — Basic Scheduling

### SCR-12 — Weekly Schedule View
**Traces to:** SRS-FR-15, SRS-FR-18, SRS-FR-24 · SDS-COMP-6, SDS-IF-5, SDS-DATA-5
**Entry points:** SCR-06 (Schedule tab)
**Exit points:** SCR-13 (assign/edit) · SCR-15 (start a scheduled workout)
**Auth requirement:** Required
**Revised 2026-09-05 (Decisions Log §4):** Recurrence is **weekly only** — a plan is assigned to one or more weekdays and repeats every week; there is no specific-date/calendar (non-recurring) scheduling. **One plan per weekday, maximum** — a given weekday can hold at most one scheduled plan.

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR12-01 | Loading | Schedule being fetched | Skeleton weekly grid | SDS-IF-14 |
| UC-SCR12-02 | Empty | No plans scheduled on any day | Empty state per day, or overall empty state with "Schedule a plan" CTA | SRS-FR-15 |
| UC-SCR12-03 | Populated | Plans scheduled | Weekly view showing which single plan (if any) falls on each weekday, repeating every week | SRS-FR-16, SRS-FR-17, SDS-DATA-5, Decisions Log §4 |
| UC-SCR12-04 | Success | Scheduled day reached (today) | "Start" action surfaced for today's scheduled workout | SRS-FR-24, BR-FR-015 |
| UC-SCR12-05 | Error / System Failure | Schedule fails to load from local storage (Drift) | Error state with retry | SDS-ERR-5 |
| UC-SCR12-06 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** Schedule is read from local storage only; see UC-SCR12-05 for the local-equivalent failure case. | — |

---

### SCR-13 — Assign / Edit Schedule for a Plan
**Traces to:** SRS-FR-15–SRS-FR-23 · SDS-COMP-6, SDS-COMP-12, SDS-IF-5, SDS-DATA-5
**Entry points:** SCR-10 ("Schedule" action) · SCR-12 (add/edit action)
**Exit points:** SCR-12 (on save/cancel)
**Key content:** Plan selector (if not pre-selected), weekday selection (multi-select, weekly recurring only — no non-recurring/date-specific option)
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR13-01 | Empty / Default | New assignment | No days selected, save disabled until at least one valid day chosen | SRS-FR-15 |
| UC-SCR13-02 | Populated | Editing existing schedule entry | Pre-filled with current weekday(s) | SRS-FR-19 (BR-FR-012), SDS-DATA-5 |
| UC-SCR13-03 | Negative / Validation | Referenced plan is invalid/unavailable | Selection blocked, explanatory message | SRS-FR-21 (BR-FR-017), SDS-COMP-12 |
| UC-SCR13-04 | Negative / Business Rule | Selected weekday already holds a different scheduled plan | Save blocked with explanatory message: a weekday may hold at most **one** scheduled plan (Decisions Log §4); user must remove/reassign the existing entry first | SRS-FR-22 (BR-FR-018), SDS-DATA-8, Decisions Log §4 |
| UC-SCR13-05 | Loading | Save submitted | Brief local-write loading state | SDS-IF-5 |
| UC-SCR13-06 | Success | Schedule saved | Route to SCR-12 with updated week view; confirmed that existing history is unaffected | SRS-FR-16, SRS-FR-23 (BR-FR-016) |
| UC-SCR13-07 | Error / System Failure | Local storage (Drift) write fails | Error state, retry available | SDS-ERR-6 |
| UC-SCR13-08 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** Save is a local database write; see UC-SCR13-07 for the local-equivalent failure case. | — |

---

### SCR-14 — Remove From Schedule Confirmation
**Traces to:** SRS-FR-20 · SDS-COMP-6
**Entry points:** SCR-12 or SCR-13 (remove action)
**Exit points:** SCR-12
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR14-01 | Confirmation | User taps Remove on a scheduled entry | Modal confirming removal from that day/recurrence | SRS-FR-20 (BR-FR-013) |
| UC-SCR14-02 | Loading | Confirm tapped | Loading state | SDS-IF-5 |
| UC-SCR14-03 | Success | Removal succeeds | Route to SCR-12, entry removed | SRS-FR-20 |
| UC-SCR14-04 | Error / System Failure | Removal fails | Error state, retry available | SDS-ERR-6 |
| UC-SCR14-05 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** Removal is a local database write with no network dependency; see UC-SCR14-04 for the local-equivalent failure case. | — |

---

## 8. FLOW-06 — Workout Execution

### SCR-15 — Workout Pre-Start / Overview
**Purpose:** Confirm plan details before beginning an active session.
**Traces to:** SRS-FR-25, SRS-FR-26 · SDS-COMP-7, SDS-IF-6
**Entry points:** SCR-10, SCR-12 ("Start Workout")
**Exit points:** SCR-16 (start) · back
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR15-01 | Loading | Plan data being fetched | Skeleton | SDS-IF-14 |
| UC-SCR15-02 | Populated | Plan loaded | Preview of exercises/targets, "Begin Workout" action | SRS-FR-26, SDS-DATA-4 |
| UC-SCR15-03 | Negative / Business Rule | Underlying plan no longer valid/available (e.g., deleted) | Blocking message, cannot start | SRS-FR-21, SDS-COMP-12 |
| UC-SCR15-04 | Error / System Failure | Plan fails to load | Error state with retry | SDS-ERR-5 |
| UC-SCR15-05 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** Plan data is read from local storage; a workout can begin with zero network dependency. A genuine local-storage read failure falls under UC-SCR15-04. | — |

---

### SCR-16 — Active Workout — Exercise & Set Logging
**Purpose:** Core execution screen — record actual performance against the plan.
**Traces to:** SRS-FR-27–SRS-FR-31 · SDS-COMP-7, SDS-COMP-12, SDS-IF-6, SDS-DATA-8, SDS-ERR-7, SDS-ERR-8
**Entry points:** SCR-15
**Exit points:** SCR-17 (rest timer, inline) · SCR-18 (cancel) · SCR-19 (finish)
**Key content:** Current exercise, target vs. actual entry fields (branching on the exercise type flag per Decisions Log §5 — see SCR-09), set progress, pause/skip/complete actions
**Auth requirement:** Required
**Design note (from SDS):** Timer/execution state is held in local application memory, not persisted per action — see SDS-COMP-7.
**Revised 2026-09-05 (Decisions Log §1, §6, §6b):** A workout counts as **completed** once at least one set of at least one exercise has been logged AND the user explicitly taps Finish — zero sets logged + Finish is not a real attempt (see SCR-19). The **rest timer auto-starts** the instant a set is marked complete (no manual "tap Start" step) and can be skipped (see SCR-17). **App-backgrounded timer behavior is explicitly DEFERRED/OPEN** — not yet designed; do not build a specific pause/resume/wall-clock behavior without a follow-up product decision.

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR16-01 | Success / Positive | Workout begins | First exercise/set shown, state = ACTIVE | SRS-FR-25, SDS-COMP-7 |
| UC-SCR16-02 | Negative / Validation | Non-positive reps/sets entered where required | Inline error, cannot mark set complete | SRS-FR-49 (BR-FR-043), SDS-ERR-7 |
| UC-SCR16-03 | Negative / Validation | Non-positive weight entered on a `weighted`-type exercise | Inline error (field not shown for other exercise types) | SRS-FR-50 (BR-FR-044), SDS-ERR-7 |
| UC-SCR16-04 | Negative / Validation | Invalid duration entered on a `time-based`-type exercise (mm:ss input) | Inline error | SRS-FR-51 (BR-FR-045), SDS-ERR-7 |
| UC-SCR16-05 | Success | Set marked complete | Rest timer (SCR-17) **auto-starts immediately**, no manual start step; progress advances to next set/exercise once rest ends or is skipped | SRS-FR-28 (BR-FR-024), Decisions Log §6 |
| UC-SCR16-06 | Other (Skip) | User skips an applicable item | Item marked skipped; excluded appropriately from completion/valid-record logic | SRS-FR-29 (BR-FR-025), SDS-COMP-7 |
| UC-SCR16-07 | Other (Pause) | User pauses applicable activity | Execution state = PAUSED; timer state held locally | SRS-FR-29, SDS-COMP-7 |
| UC-SCR16-08 | **DEFERRED / OPEN** | App is backgrounded/killed mid-workout | **Not designed.** Whether the timer/session should pause-and-resume, wall-clock-catch-up, or end on backgrounding is an explicitly open product decision (Decisions Log §6b) pending a future brainstorming session. Placeholder only — do not assume a default. Regardless of outcome, an in-progress session that never reaches an explicit Finish is not treated as a completed historical record (Decisions Log §2); previously completed sessions are unaffected. | SRS-NFR-6 (BR-NFR-006), Decisions Log §6b |
| UC-SCR16-09 | *(removed)* | ~~Connectivity lost mid-workout~~ | **REMOVED — not applicable.** There is no network dependency at any point in workout execution or finish; see SCR-19 for the local-write-failure equivalent. | — |
| UC-SCR16-10 | Confirmation | User taps Cancel | Routes to SCR-18 | SDS-COMP-7 |
| UC-SCR16-11 | Success | Last item completed | Routes to SCR-19 | SRS-FR-32 (BR-FR-026) |

---

### SCR-17 — Rest Timer
**Purpose:** Work/rest timing between sets — presented inline or as an overlay on SCR-16.
**Traces to:** SRS-FR-29, SRS-NFR-2 · SDS-COMP-7, SDS-NFR-2
**Entry points:** SCR-16 (**automatically, the instant a set is marked complete** — Decisions Log §6, no manual start step)
**Exit points:** SCR-16 (on timer end or Skip)
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR17-01 | Success / Positive | Set marked complete | Rest countdown **auto-starts immediately**, no manual "tap Start" step; runs independently of any network call (there is none) | SRS-NFR-2 (BR-NFR-002), SDS-NFR-2, Decisions Log §6 |
| UC-SCR17-02 | Other | User taps **Skip** | Rest ends immediately; returns to SCR-16 | SRS-FR-29, Decisions Log §6 |
| UC-SCR17-03 | Success | Timer reaches zero | Auto-advances to next set/exercise on SCR-16 without requiring confirmation | SRS-NFR-14 (BR-NFR-014), SDS-NFR-16 |
| UC-SCR17-04 | **DEFERRED / OPEN** | App backgrounded while rest timer is running | **Not designed** — see SCR-16 (UC-SCR16-08) and Decisions Log §6b. | Decisions Log §6b |

---

### SCR-18 — Cancel Workout Confirmation
**Traces to:** SRS-FR-29 · SDS-COMP-7
**Entry points:** SCR-16
**Exit points:** SCR-16 (resume) · SCR-06 (confirm cancel)
**Auth requirement:** Required
**Revised 2026-09-05 (Decisions Log §2):** Cancel **always discards the session in full, with no partial save** — regardless of how much was logged. There is no "Save as Incomplete vs Discard" prompt and no "Incomplete" state anywhere in the app; nothing appears in history for a cancelled session.

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR18-01 | Confirmation | User taps Cancel during active workout | Modal warning that all progress will be discarded — not saved in any form, including as "incomplete" | SRS-FR-29, Decisions Log §2 |
| UC-SCR18-02 | Success | Cancel confirmed | Session discarded entirely; nothing persisted, nothing appears in history; route to SCR-06 | SRS-FR-29, SDS-COMP-7, Decisions Log §2 |

---

### SCR-19 — Workout Summary (Complete)
**Traces to:** SRS-FR-33–SRS-FR-35 · SDS-COMP-8, SDS-DATA-6
**Entry points:** SCR-16 (finish)
**Exit points:** SCR-06 · SCR-20 (view in history)
**Auth requirement:** Required
**Revised 2026-09-05 (Decisions Log §1, §2):** Every session that reaches this screen is, by definition, completed (at least one set logged + explicit Finish). There is no "Incomplete" saved-record state and no discard-vs-save-incomplete prompt — see SCR-18. Zero-set sessions cannot reach Finish as a real attempt; if the UI allows tapping Finish with zero sets logged, that is treated the same as Cancel (full discard), not as a saved "incomplete" record.

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR19-01 | Loading | Finish tapped, session being persisted to local storage | Brief loading state on finish action | SDS-COMP-8 |
| UC-SCR19-02 | Success | Session persists successfully (completion criteria met — Decisions Log §1) | Summary of completed workout (date/time, duration, sets/reps/weight actuals) | SRS-FR-33–35, SDS-DATA-6, Decisions Log §1 |
| UC-SCR19-03 | *(removed)* | ~~Workout does not meet completion criteria → saved as "incomplete"~~ | **REMOVED — not applicable.** Per Decisions Log §2, there is no "Incomplete" saved state of any kind; a session not meeting completion criteria is discarded via Cancel (SCR-18), never persisted, and therefore never reaches this screen's Success path. | — |
| UC-SCR19-04 | Error / System Failure | Local storage (Drift) write fails at finish | Error state — workout is **not** shown as saved; retry available; no duplicate record created on retry | SDS-ERR-6 |
| UC-SCR19-05 | *(removed)* | ~~No connectivity at finish~~ | **REMOVED — not applicable.** Finish is a local database write with no network dependency; see UC-SCR19-04 for the local-equivalent failure case. | — |

---

## 9. FLOW-07 — Workout History

### SCR-20 — Workout History List
**Traces to:** SRS-FR-36 · SDS-COMP-9, SDS-IF-7
**Entry points:** SCR-06 (History tab) · SCR-19 ("View in history")
**Exit points:** SCR-21
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR20-01 | Loading | History being fetched | Skeleton list | SDS-IF-14 |
| UC-SCR20-02 | Empty | No completed workouts yet | Empty state, "Your completed workouts will appear here" | SRS-FR-36 |
| UC-SCR20-03 | Populated | Completed sessions exist | Reverse-chronological list of sessions (only the authenticated user's own) | SRS-FR-36, SDS-COMP-9 |
| UC-SCR20-04 | Error / System Failure | History fails to load | Error state with retry | SDS-ERR-5 |
| UC-SCR20-05 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** History is read from local storage (Drift) only; see UC-SCR20-04 for the local-equivalent failure case. | — |

---

### SCR-21 — Workout History Detail
**Traces to:** SRS-FR-37 · SDS-COMP-9, SDS-DATA-6
**Entry points:** SCR-20
**Exit points:** back to SCR-20
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR21-01 | Loading | Session detail being fetched | Skeleton | SDS-IF-14 |
| UC-SCR21-02 | Populated | Session loaded | Full recorded detail: date/time, per-exercise actual sets/reps/weight/duration | SRS-FR-37, SDS-DATA-6 |
| UC-SCR21-03 | Success (integrity) | Underlying plan was later edited or deleted | Detail still shows the actual performance as originally recorded, unaffected by subsequent plan changes | SRS-FR-38 (BR-FR-032), SDS-DATA-6 |
| UC-SCR21-04 | Error / System Failure | Detail fails to load | Error state with retry | SDS-ERR-5 |
| UC-SCR21-05 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** Detail is read from local storage (Drift) only; see UC-SCR21-04 for the local-equivalent failure case. | — |

---

## 10. FLOW-08 — Progress

### SCR-22 — Progress Comparison
**Traces to:** SRS-FR-39–SRS-FR-41 · SDS-COMP-10, SDS-IF-8, SDS-DATA-7
**Entry points:** SCR-06 (Progress tab)
**Exit points:** —
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR22-01 | Loading | Progress data being calculated/fetched | Skeleton/placeholder chart | SDS-IF-12 |
| UC-SCR22-02 | Empty | Fewer than two valid completed sessions for a given exercise | "Complete a few more workouts to see your progress" state | SRS-FR-39 |
| UC-SCR22-03 | Populated | Sufficient valid history exists | Comparison view (weight, reps, volume, duration where applicable) across sessions, per exercise | SRS-FR-40, SDS-DATA-7 |
| UC-SCR22-04 | *(revised)* | ~~An incomplete/invalid session exists in the underlying history~~ | **Revised 2026-09-05:** per Decisions Log §2, every persisted session is by definition completed — there is no "incomplete" record to exclude. This row is retained only to note that progress logic never needs incomplete-session handling; no design action required. | Decisions Log §2 |
| UC-SCR22-05 | Error / System Failure | Progress data fails to load/calculate | Error state with retry | SDS-ERR-5, SDS-ERR-9 |
| UC-SCR22-06 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** Progress data is calculated from local storage (Drift) only; see UC-SCR22-05 for the local-equivalent failure case. | — |

---

## 11. FLOW-09 — Statistics

### SCR-23 — Statistics Dashboard
**Traces to:** SRS-FR-42–SRS-FR-46 · SDS-COMP-11, SDS-IF-8, SDS-IF-12, SDS-DATA-7
**Entry points:** SCR-06 (Stats tab)
**Exit points:** SCR-24
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR23-01 | Loading | Statistics being calculated | Skeleton/placeholder cards | SDS-IF-12 |
| UC-SCR23-02 | Empty | No valid completed workouts yet | Empty state, zeroed/placeholder stats with a prompt to complete a workout | SRS-FR-42 |
| UC-SCR23-03 | Populated | Valid history exists | Total completed workouts, training volume, workout duration, exercise-level stats | SRS-FR-42–45, SDS-DATA-7 |
| UC-SCR23-04 | Success (data integrity) | A workout record is edited/deleted after being counted | Statistics recalculate from current valid records rather than showing stale values | SRS-FR-47 (BR-FR-041), SDS-ERR-9 |
| UC-SCR23-05 | Error / System Failure | Statistics fail to load/calculate | Error state with retry | SDS-ERR-5, SDS-ERR-9 |
| UC-SCR23-06 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** Statistics are calculated from local storage (Drift) only; see UC-SCR23-05 for the local-equivalent failure case. | — |

---

### SCR-24 — Personal Bests **[METRIC DEFINITION DEFERRED / OPEN]**
**Traces to:** SRS-FR-46 · SDS-COMP-11, SDS-DATA-7
**Entry points:** SCR-23
**Exit points:** back to SCR-23
**Auth requirement:** Required
**Deferred-decision flag (Decisions Log §3):** The screen is structurally in scope — a Personal Bests view showing per-exercise bests — but **the exact metric definition (heaviest weight / highest reps / highest volume / longest duration — one or more) is NOT decided**. The product owner wants a separate brainstorming session to pick it. Do not silently pick a default metric in Figma or user-story authoring; carry the "TBD — deferred, see open decisions" flag forward until that session happens.

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR24-01 | Loading | PB data being calculated | Skeleton | SDS-IF-12 |
| UC-SCR24-02 | Empty | No completed workouts yet | Empty state | SRS-FR-46 |
| UC-SCR24-03 | Populated | PBs exist | List of personal bests per exercise, **using a metric definition that is TBD — deferred, see Decisions Log §3** (not heaviest weight / highest reps / highest volume / longest duration by default; none is finalized) | SRS-FR-46, SDS-DATA-7, Decisions Log §3 |
| UC-SCR24-04 | Error / System Failure | PB calculation/load fails (local storage) | Error state with retry | SDS-ERR-5, SDS-ERR-9 |
| UC-SCR24-05 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** PB data is calculated from local storage only. | — |

---

## 12. FLOW-10 — Account

### SCR-25 — Profile / Account **[CONFIRMED IN SCOPE — EDITABLE]**
**Purpose:** View and edit the user's local profile information, set directly on this screen (there is no registration flow to collect it at signup — Decisions Log §0/§8).
**Traces to:** SRS-FR-1, SRS-FR-2 · SDS-COMP-3, SDS-DATA-2
**Resolution note (was [ASSUMPTION], resolved 2026-09-05):** Previously flagged as an unresolved assumption recommended to ship read-only. **Confirmed in scope and editable by the product owner in the 2026-09-05 clarification session — this is approved new scope, not scope creep (Decisions Log §8).** The field list below is exact and final for MVP; do not add fields beyond it.
**Key content (exactly these fields, no more — Decisions Log §8):**
- Display name (text)
- Fitness goal (short text or pick-list, e.g., Build muscle / Lose weight / General fitness)
- Experience level (Beginner / Intermediate / Advanced — informational only; no logic/calculations tied to it for MVP)
- Height & weight (numeric; stored for reference only, informational only — **no calculations of any kind performed on these values for MVP**)
- Logout action (unchanged, routes to SCR-26)
**Entry points:** SCR-06
**Exit points:** SCR-26
**Auth requirement:** Required (local login-state flag set — see FLOW-01)

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR25-01 | Loading | Profile being read from local storage (Drift) | Skeleton | SDS-COMP-3 |
| UC-SCR25-02 | Empty / Default | First time on this screen, no profile fields set yet | Blank/default fields shown, editable | Decisions Log §8 |
| UC-SCR25-03 | Populated | Profile loaded | Display name, fitness goal, experience level, height & weight shown, all editable; Logout action | SRS-FR-1, SDS-DATA-2, Decisions Log §8 |
| UC-SCR25-04 | Negative / Validation | Invalid numeric entry for height/weight (e.g., non-numeric or negative) | Inline field error, save blocked | SDS-DATA-8 |
| UC-SCR25-05 | Success | Edits saved | Local storage (Drift) updated; confirmation shown | Decisions Log §8 |
| UC-SCR25-06 | Error / System Failure | Profile fails to load or save (local storage failure) | Error state with retry | SDS-ERR-5, SDS-ERR-6 |
| UC-SCR25-07 | *(removed)* | ~~No connectivity~~ | **REMOVED — not applicable.** Profile is read from and written to local storage only. | — |

---

### SCR-26 — Logout Confirmation
**Traces to:** SRS-FR-4 · SDS-COMP-2, SDS-IF-9
**Entry points:** SCR-25
**Exit points:** SCR-01 (confirm) · SCR-25 (cancel)
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR26-01 | Confirmation | User taps Logout | Confirmation modal | SRS-FR-4 |
| UC-SCR26-02 | Success | Logout confirmed | Local login flag cleared; route to SCR-01/SCR-03; local storage (Drift) data untouched | SRS-FR-4 (BR-FR-050 boundary note), SDS-COMP-2 |

---

## 13. FLOW-11 — Cross-Cutting / Global States (Local-Only)

**Revised 2026-09-05 (Decisions Log §0):** This flow previously assumed an online-first architecture with Firestore reads/writes and a real auth session, and modeled offline banners, uncategorized Firestore read/write failures, and session-invalidation as global states every authenticated screen must support. **None of that applies.** ForgeApp has no network of any kind, so there is no connectivity to lose and no offline state to bannerize; and login is a static local flag (FLOW-01), not a real session, so there is no token/session to expire or invalidate elsewhere. The only cross-cutting concern that still has a genuine local-only equivalent is a local storage (Drift) read/write failure, kept below in simplified form.

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR27-01 | *(removed)* | ~~Connectivity drops while anywhere in the app~~ | **REMOVED — no longer applicable.** No network dependency exists anywhere in the app (Decisions Log §0); there is nothing to be "offline" from and no global offline banner to design. | — |
| UC-SCR27-02 | Error (Global) | Any local storage (Drift) read fails, uncategorized (e.g., corrupted record, unexpected I/O error) | Generic recoverable error state with retry, distinguished from validation errors | SDS-ERR-5 |
| UC-SCR27-03 | Error (Global) | Any local storage (Drift) write fails, uncategorized | Write is never represented as successful; retry offered; no duplicate persisted record on retry | SDS-ERR-6 |
| UC-SCR27-04 | *(removed)* | ~~Session becomes invalid mid-use (token expired, account disabled elsewhere)~~ | **REMOVED — no longer applicable.** There is no real session, token, or multi-device/server-side account state to invalidate; login is a static local unlocked/locked flag only (Decisions Log §0). | — |
| UC-SCR27-05 | *(removed)* | ~~Attempt to access another user's data via a malformed request~~ | **REMOVED — no longer applicable.** There is no multi-user account system and no server-side security-rule boundary; the app is single-user, single-device, local-only. | — |

---

## 14. Traceability Coverage Check

Every SRS-FR-1 through SRS-FR-52 and every SRS-NFR-1 through SRS-NFR-18 is referenced by at least one UC above via its parent screen, except where an SRS-FR/NFR item itself describes the now-deprecated online/registration/reset architecture (see Decisions Log §0) — those items are stale in the SRS and should be reconciled there separately; this document no longer builds screens against them. Before moving into Figma or user-story authoring, confirm:

1. **SCR-25 (Profile/Account)** ships as the confirmed **editable** screen with exactly the four fields listed (display name, fitness goal, experience level, height & weight) — do not read-only it, and do not add fields beyond that list (Decisions Log §8).
2. **SCR-24 (Personal Bests)** ships with the metric definition visibly marked TBD/deferred — do not silently pick a default metric (Decisions Log §3).
3. **SCR-16/SCR-17 app-backgrounded timer behavior** ships as an explicitly open/deferred placeholder, not a designed behavior (Decisions Log §6b).
4. Rows marked **REMOVED — not applicable** throughout this document (Offline states, Firestore-specific error states, session-invalidation, the SCR-19 "Incomplete" row, etc.) should not be carried into Figma frames or user stories — they document what was intentionally dropped, for traceability, not what still needs building.
5. The **Loading/Skeleton** state is listed per screen for completeness but may be intentionally lightweight in v1 designs — treat as lower priority than Empty/Error states, which carry actual requirement traceability.
6. **SDS-ERR-7 mislabeling (found and corrected, 2026-09-05):** A traceability audit found eight use-case rows (UC-SCR09-10, UC-SCR12-05, UC-SCR13-07, UC-SCR19-04, UC-SCR24-04, UC-SCR25-06, UC-SCR27-02, UC-SCR27-03) and the FLOW-11 Flow Index row incorrectly citing **SDS-ERR-7 (Validation Failure)** for what are actually local-storage read/write failures. These have been corrected to cite **SDS-ERR-5 (Database Read Failure)** and/or **SDS-ERR-6 (Database Write Failure)** as appropriate (UC-SCR24-04 also retains SDS-ERR-9, matching the pattern used for the sibling stats/PB-calculation rows UC-SCR22-05/UC-SCR23-05). SDS-ERR-7 remains correctly reserved for genuine input-validation rows (e.g., UC-SCR09-05–07, UC-SCR16-02–04) per SRS-FR-48–52. See Changelog v1.1.2.

---

## 15. Next Steps

- This document is now ready to drive **Figma frame creation**: one frame group per Screen ID, one frame variant per Use Case row.
- It is also ready to drive **user story authoring**: each UC row is close to a "Given/When/Then" acceptance criterion already — the Trigger/Condition column is your "Given/When," the Behavior column is your "Then."
- Recommended story-writing pattern per UC: `As an authenticated user, when [Trigger/Condition] on [Screen], the system shall [Behavior] (traces to [SRS/SDS IDs]).`
