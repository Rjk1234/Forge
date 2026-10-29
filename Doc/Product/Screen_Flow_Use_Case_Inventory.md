# Screen & Flow / Use-Case Inventory
## Workout Tracker

| Attribute | Details |
|---|---|
| Document Type | Screen & Flow / Use-Case Inventory (Design-Facing Requirements Bridge) |
| Document Version | 1.0 |
| Document Status | Draft — for review before Figma / User Story authoring |
| Derivation Level | Derived Document — Level 3 |
| Parent Document | System Design Specification (SDS), Version 1.0 |
| Grandparent Document | Software Requirements Specification (SRS), Version 1.0 |
| Great-Grandparent Document | Business Requirements Document (BRD), Version 1.0 |
| Purpose | Bridges the SDS/SRS/BRD requirement chain into a screen-level, state-level inventory that can be used directly to (a) build Figma frames/flows and (b) author user stories, without re-deriving requirements |
| ID Scheme | `FLOW-*` (flow), `SCR-*` (screen), `UC-<SCR>-*` (use case / UI state within a screen) |
| Change Policy | No new functionality is introduced. Every screen and every use case MUST trace to at least one SRS-FR-*/SRS-NFR-* ID and, where applicable, the SDS-COMP-*/SDS-IF-*/SDS-DATA-*/SDS-ERR-* ID(s) that define its behavior. If a state cannot be traced, it must not appear here without being flagged as an **Assumption**. |

---

## 0. How to Use This Document

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
| **Error / System Failure** | Backend/network/service failure (auth service, Firestore read/write failure) |
| **Offline / No Connection** | No connectivity — relevant everywhere since the app has no offline mode |
| **Confirmation** | Destructive or consequential action requires explicit confirmation |
| **Populated** | Normal state with real data present |
| **Placeholder / Skeleton** | Optional loading placeholder shown while Populated state resolves |

---

## 1. Flow Index

| Flow ID | Flow Name | Screens | Traces to (SDS Interface) |
|---|---|---|---|
| FLOW-01 | Authentication | SCR-01–SCR-05 | SDS-IF-1, SDS-IF-2, SDS-IF-3, SDS-IF-9 |
| FLOW-02 | Home / Navigation Shell | SCR-06 | SDS-COMP-1 |
| FLOW-03 | Exercise Catalogue | SCR-07 | SDS-IF-14, SDS-DATA-3 |
| FLOW-04 | Workout Plan Management | SCR-08–SCR-11 | SDS-IF-4 |
| FLOW-05 | Basic Scheduling | SCR-12–SCR-14 | SDS-IF-5 |
| FLOW-06 | Workout Execution | SCR-15–SCR-19 | SDS-IF-6 |
| FLOW-07 | Workout History | SCR-20–SCR-21 | SDS-IF-7 |
| FLOW-08 | Progress | SCR-22 | SDS-IF-8 |
| FLOW-09 | Statistics | SCR-23–SCR-24 | SDS-IF-8, SDS-IF-12 |
| FLOW-10 | Account | SCR-25–SCR-26 | SDS-COMP-3, SDS-IF-9 |
| FLOW-11 | Cross-Cutting / Global States | SCR-27 | SDS-ERR-1–9 |

---

## 2. Sitemap (Navigation Hierarchy)

```
SCR-01 Splash / Auth Check
 ├── (unauthenticated) ──► SCR-03 Login ──► SCR-02 Registration
 │                                     └──► SCR-04 Forgot Password ──► SCR-05 Reset Email Sent
 └── (authenticated) ──► SCR-06 Home (tab root)
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

## 3. FLOW-01 — Authentication

### SCR-01 — Splash / Auth Check
**Purpose:** Determine whether a valid session exists and route accordingly. No user-visible interaction.
**Traces to:** SRS-FR-3, SRS-FR-6 · SDS-COMP-1, SDS-IF-9
**Entry points:** App cold start / app resume
**Exit points:** SCR-03 (unauthenticated) or SCR-06 (authenticated)
**Auth requirement:** N/A (this screen determines auth state)

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR01-01 | Loading | App launch, auth state stream not yet resolved | Show brand/splash indicator; no interaction available | SDS-IF-9 |
| UC-SCR01-02 | Success | Auth state resolves to authenticated | Route to SCR-06 | SRS-FR-3, SRS-FR-6, SDS-IF-9 |
| UC-SCR01-03 | Success | Auth state resolves to unauthenticated | Route to SCR-03 | SRS-FR-2, SDS-IF-9 |
| UC-SCR01-04 | Offline | No connectivity at launch, auth state cannot be resolved | Show blocking "No connection" state with retry; app cannot proceed past this point since there is no offline/local session cache | BR-NFR-020, SDS-COMP-13 (no local fallback) |

---

### SCR-02 — Registration
**Purpose:** Create a new account.
**Traces to:** SRS-FR-1 · SDS-COMP-2, SDS-COMP-3, SDS-COMP-15, SDS-IF-1, SDS-DATA-1, SDS-DATA-2, SDS-ERR-2
**Entry points:** SCR-03 (Login, "Create account" link) · SCR-01 (if never authenticated)
**Exit points:** SCR-06 (on success) · SCR-03 (via "already have an account")
**Key content:** Email field, password field, submit action, link to Login
**Auth requirement:** None (pre-auth screen)

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR02-01 | Empty / Default | Screen first opened | Empty email/password fields, submit disabled until minimally valid | SRS-FR-1 |
| UC-SCR02-02 | Negative / Validation | Malformed email entered | Inline field error, submit blocked | SRS-FR-1, SDS-COMP-12 |
| UC-SCR02-03 | Negative / Validation | Password does not meet provider's minimum (6 characters) | Inline field error, submit blocked | SRS-FR-1, SDS-DATA-8 |
| UC-SCR02-04 | Loading | Valid form submitted | Submit button shows loading state; fields disabled | SDS-IF-1 |
| UC-SCR02-05 | Success | Registration succeeds | UID generated, profile doc created, route to SCR-06 | SRS-FR-1, SDS-COMP-3, SDS-DATA-2 |
| UC-SCR02-06 | Negative / Business Rule | Email already registered | Inline/banner error: "An account with this email already exists"; offer link to Login | SRS-FR-1, SDS-ERR-2 |
| UC-SCR02-07 | Error / System Failure | Firebase Authentication service failure | Non-technical error banner; retry available; raw provider error not shown | SDS-ERR-1, SDS-ERR-2 |
| UC-SCR02-08 | Offline | No connectivity at submit | "You're offline — check your connection and try again" state; form input preserved | BR-NFR-020, SDS-ERR-2 |

---

### SCR-03 — Login
**Purpose:** Authenticate an existing user.
**Traces to:** SRS-FR-2 · SDS-COMP-2, SDS-COMP-15, SDS-IF-2, SDS-IF-9, SDS-ERR-3
**Entry points:** SCR-01 · SCR-26 (post-logout) · SCR-05 (post-reset)
**Exit points:** SCR-06 (success) · SCR-02 (register link) · SCR-04 (forgot password)
**Key content:** Email field, password field, submit action, "Forgot password?" link, "Create account" link
**Auth requirement:** None (pre-auth screen)

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR03-01 | Empty / Default | Screen first opened | Empty fields, submit disabled until minimally valid | SRS-FR-2 |
| UC-SCR03-02 | Negative / Validation | Malformed email format | Inline field error | SRS-FR-2, SDS-COMP-12 |
| UC-SCR03-03 | Loading | Valid form submitted | Submit shows loading state | SDS-IF-2 |
| UC-SCR03-04 | Success | Correct credentials | Route to SCR-06 | SRS-FR-2, SDS-IF-2, SDS-IF-9 |
| UC-SCR03-05 | Negative / Business Rule | Wrong password or unknown account | Generic, non-enumerating error: "Email or password is incorrect" | SRS-FR-2, SDS-ERR-3 |
| UC-SCR03-06 | Negative / Business Rule | Disabled account | Clear error state indicating the account cannot sign in currently | SRS-FR-2, SDS-ERR-1 |
| UC-SCR03-07 | Error / System Failure | Firebase Authentication service failure | Non-technical error banner; retry available | SDS-ERR-1, SDS-ERR-3 |
| UC-SCR03-08 | Offline | No connectivity at submit | "You're offline" state, distinct from wrong-credentials error | BR-NFR-020, SDS-ERR-3 |

---

### SCR-04 — Forgot Password
**Purpose:** Request a password-reset email.
**Traces to:** SRS-FR-5 · SDS-COMP-2, SDS-IF-3, SDS-ERR-4
**Entry points:** SCR-03
**Exit points:** SCR-05 (success) · SCR-03 (back)
**Key content:** Email field, submit action
**Auth requirement:** None

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR04-01 | Empty / Default | Screen first opened | Empty email field | SRS-FR-5 |
| UC-SCR04-02 | Negative / Validation | Malformed email | Inline field error | SRS-FR-5, SDS-COMP-12 |
| UC-SCR04-03 | Loading | Valid email submitted | Submit shows loading state | SDS-IF-3 |
| UC-SCR04-04 | Success | Reset request accepted by provider | Route to SCR-05 | SRS-FR-5, SDS-IF-3 |
| UC-SCR04-05 | Error / System Failure | Reset request fails at provider | Non-technical error banner; retry available; implementation detail not exposed | SDS-ERR-4 |
| UC-SCR04-06 | Offline | No connectivity at submit | "You're offline" state | BR-NFR-020, SDS-ERR-4 |

---

### SCR-05 — Password Reset Email Sent (Confirmation)
**Purpose:** Confirm the reset email was sent; reset itself happens outside the app (Firebase-hosted page) per the Authentication Module decision (D-05).
**Traces to:** SRS-FR-5 · SDS-IF-3
**Entry points:** SCR-04
**Exit points:** SCR-03 (manual return, "Back to Login")
**Auth requirement:** None

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR05-01 | Success | Screen reached after successful request | Static confirmation message with the submitted email address and instructions to check inbox, then return to Login | SRS-FR-5, SDS-IF-3 |

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
| UC-SCR06-05 | Offline | Connectivity lost while on Home | Persistent offline banner; data-dependent widgets show stale/unavailable state, not silently blank | BR-NFR-020, SDS-COMP-13 |

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
| UC-SCR07-07 | Offline | No connectivity | Offline state; catalogue not cached locally per architecture (no local DB) | BR-NFR-020, Appendix C (SDS) |

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
| UC-SCR08-05 | Offline | No connectivity | Offline state | BR-NFR-020 |

---

### SCR-09 — Create / Edit Workout Plan
**Traces to:** SRS-FR-9–SRS-FR-14, SRS-FR-48 · SDS-COMP-5, SDS-COMP-12, SDS-IF-4, SDS-DATA-4, SDS-DATA-8, SDS-ERR-7
**Entry points:** SCR-08 ("New plan" / edit action) · SCR-10 (edit action)
**Exit points:** SCR-10 (on save) · SCR-08 (on cancel/back)
**Key content:** Plan name field, exercise list (add via SCR-07), per-exercise target sets/reps/weight/duration/rest
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR09-01 | Empty / Default | New plan, create mode | Blank name field, empty exercise list, "Add exercise" action | SRS-FR-9 |
| UC-SCR09-02 | Populated | Edit mode, existing plan loaded | Fields pre-filled with current plan data | SRS-FR-13, SDS-DATA-4 |
| UC-SCR09-03 | Negative / Validation | Blank/whitespace-only plan name on save | Inline error, save blocked | SRS-FR-10 (BR-FR-004), SDS-DATA-8 |
| UC-SCR09-04 | Negative / Validation | Invalid exercise reference | Item flagged/rejected, cannot be saved | SRS-FR-48, SDS-DATA-8 |
| UC-SCR09-05 | Negative / Validation | Non-positive sets/reps entered where required | Inline field error | SRS-FR-49, SDS-ERR-7 |
| UC-SCR09-06 | Negative / Validation | Negative weight entered | Inline field error | SRS-FR-50 (BR-FR-044), SDS-ERR-7 |
| UC-SCR09-07 | Negative / Validation | Negative duration entered | Inline field error | SRS-FR-51 (BR-FR-045), SDS-ERR-7 |
| UC-SCR09-08 | Loading | Save submitted | Save action shows loading state | SDS-IF-4 |
| UC-SCR09-09 | Success | Plan saved (create or edit) | Route to SCR-10 with updated data | SRS-FR-9, SRS-FR-13, SDS-COMP-5 |
| UC-SCR09-10 | Error / System Failure | Firestore write fails | Error state; plan not represented as saved; retry available; no duplicate record created | SDS-ERR-6 |
| UC-SCR09-11 | Offline | No connectivity at save | "You're offline" state; in-progress edits preserved in memory only | BR-NFR-020, SDS-ERR-6 |
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
| UC-SCR10-04 | Offline | No connectivity | Offline state | BR-NFR-020 |

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
| UC-SCR11-05 | Offline | No connectivity | "You're offline" state | BR-NFR-020 |

---

## 7. FLOW-05 — Basic Scheduling

### SCR-12 — Weekly Schedule View
**Traces to:** SRS-FR-15, SRS-FR-18, SRS-FR-24 · SDS-COMP-6, SDS-IF-5, SDS-DATA-5
**Entry points:** SCR-06 (Schedule tab)
**Exit points:** SCR-13 (assign/edit) · SCR-15 (start a scheduled workout)
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR12-01 | Loading | Schedule being fetched | Skeleton weekly grid | SDS-IF-14 |
| UC-SCR12-02 | Empty | No plans scheduled on any day | Empty state per day, or overall empty state with "Schedule a plan" CTA | SRS-FR-15 |
| UC-SCR12-03 | Populated | Plans scheduled | Weekly view showing which plan(s) fall on which day(s), including recurring assignments | SRS-FR-16, SRS-FR-17, SDS-DATA-5 |
| UC-SCR12-04 | Success | Scheduled day reached (today) | "Start" action surfaced for today's scheduled workout | SRS-FR-24, BR-FR-015 |
| UC-SCR12-05 | Error / System Failure | Schedule fails to load | Error state with retry | SDS-ERR-5 |
| UC-SCR12-06 | Offline | No connectivity | Offline state | BR-NFR-020 |

---

### SCR-13 — Assign / Edit Schedule for a Plan
**Traces to:** SRS-FR-15–SRS-FR-23 · SDS-COMP-6, SDS-COMP-12, SDS-IF-5, SDS-DATA-5
**Entry points:** SCR-10 ("Schedule" action) · SCR-12 (add/edit action)
**Exit points:** SCR-12 (on save/cancel)
**Key content:** Plan selector (if not pre-selected), day-of-week selection, recurrence toggle
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR13-01 | Empty / Default | New assignment | No days selected, save disabled until at least one valid day chosen | SRS-FR-15 |
| UC-SCR13-02 | Populated | Editing existing schedule entry | Pre-filled with current day(s)/recurrence | SRS-FR-19 (BR-FR-012), SDS-DATA-5 |
| UC-SCR13-03 | Negative / Validation | Referenced plan is invalid/unavailable | Selection blocked, explanatory message | SRS-FR-21 (BR-FR-017), SDS-COMP-12 |
| UC-SCR13-04 | Negative / Validation | Invalid scheduling configuration (e.g., conflicting/duplicate rule) | Inline error, save blocked | SRS-FR-22 (BR-FR-018), SDS-DATA-8 |
| UC-SCR13-05 | Loading | Save submitted | Loading state | SDS-IF-5 |
| UC-SCR13-06 | Success | Schedule saved | Route to SCR-12 with updated week view; confirmed that existing history is unaffected | SRS-FR-16, SRS-FR-23 (BR-FR-016) |
| UC-SCR13-07 | Error / System Failure | Save fails | Error state, retry available | SDS-ERR-6 |
| UC-SCR13-08 | Offline | No connectivity | "You're offline" state | BR-NFR-020 |

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
| UC-SCR14-05 | Offline | No connectivity | "You're offline" state | BR-NFR-020 |

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
| UC-SCR15-05 | Offline | No connectivity | Offline state; workout cannot begin without connectivity per architecture | BR-NFR-020, Appendix C (SDS) |

---

### SCR-16 — Active Workout — Exercise & Set Logging
**Purpose:** Core execution screen — record actual performance against the plan.
**Traces to:** SRS-FR-27–SRS-FR-31 · SDS-COMP-7, SDS-COMP-12, SDS-IF-6, SDS-DATA-8, SDS-ERR-7, SDS-ERR-8
**Entry points:** SCR-15
**Exit points:** SCR-17 (rest timer, inline) · SCR-18 (cancel) · SCR-19 (finish)
**Key content:** Current exercise, target vs. actual entry fields (reps/weight/duration), set progress, pause/skip/complete actions
**Auth requirement:** Required
**Design note (from SDS):** Timer/execution state is held in local application memory, not persisted per action — see SDS-COMP-7, SDS-NFR-2/3.

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR16-01 | Success / Positive | Workout begins | First exercise/set shown, state = ACTIVE | SRS-FR-25, SDS-COMP-7 |
| UC-SCR16-02 | Negative / Validation | Non-positive reps/sets entered | Inline error, cannot mark set complete | SRS-FR-49 (BR-FR-043), SDS-ERR-7 |
| UC-SCR16-03 | Negative / Validation | Negative weight entered | Inline error | SRS-FR-50 (BR-FR-044), SDS-ERR-7 |
| UC-SCR16-04 | Negative / Validation | Negative duration entered | Inline error | SRS-FR-51 (BR-FR-045), SDS-ERR-7 |
| UC-SCR16-05 | Success | Set/exercise marked complete | Progress advances to next set/exercise | SRS-FR-28 (BR-FR-024) |
| UC-SCR16-06 | Other (Skip) | User skips an applicable item | Item marked skipped; excluded appropriately from completion/valid-record logic | SRS-FR-29 (BR-FR-025), SDS-COMP-7 |
| UC-SCR16-07 | Other (Pause) | User pauses applicable activity | Execution state = PAUSED; timer state held locally | SRS-FR-29, SDS-COMP-7 |
| UC-SCR16-08 | Interrupted | App is backgrounded/killed or crashes mid-workout | On relaunch, in-progress session is not treated as a completed historical record; previously completed sessions remain unaffected | SRS-NFR-6 (BR-NFR-006), SDS-ERR-8 |
| UC-SCR16-09 | Offline | Connectivity lost mid-workout | Timer/local logging continues to function (local state), but completion/finish action requires connectivity to persist — surfaced clearly at finish, not silently | BR-NFR-020, SDS-COMP-7 |
| UC-SCR16-10 | Confirmation | User taps Cancel | Routes to SCR-18 | SDS-COMP-7 |
| UC-SCR16-11 | Success | Last item completed | Routes to SCR-19 | SRS-FR-32 (BR-FR-026) |

---

### SCR-17 — Rest Timer
**Purpose:** Work/rest timing between sets — presented inline or as an overlay on SCR-16.
**Traces to:** SRS-FR-29, SRS-NFR-2 · SDS-COMP-7, SDS-NFR-2
**Entry points:** SCR-16 (automatically, per set configuration)
**Exit points:** SCR-16 (on timer end or skip-rest)
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR17-01 | Success / Positive | Rest period begins | Countdown shown; runs independently of any network call | SRS-NFR-2 (BR-NFR-002), SDS-NFR-2 |
| UC-SCR17-02 | Other | User skips remaining rest | Returns immediately to SCR-16 | SRS-FR-29 |
| UC-SCR17-03 | Success | Timer reaches zero | Auto-advances to next set/exercise on SCR-16 without requiring confirmation | SRS-NFR-14 (BR-NFR-014), SDS-NFR-16 |

---

### SCR-18 — Cancel Workout Confirmation
**Traces to:** SRS-FR-29 · SDS-COMP-7
**Entry points:** SCR-16
**Exit points:** SCR-16 (resume) · SCR-06 (confirm cancel)
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR18-01 | Confirmation | User taps Cancel during active workout | Modal warning that progress will not be saved as a completed workout | SRS-FR-29, SDS-ERR-8 |
| UC-SCR18-02 | Success | Cancel confirmed | Session discarded (not persisted as completed); route to SCR-06 | SRS-FR-29, SDS-COMP-7 |

---

### SCR-19 — Workout Summary (Complete)
**Traces to:** SRS-FR-33–SRS-FR-35 · SDS-COMP-8, SDS-DATA-6
**Entry points:** SCR-16 (finish)
**Exit points:** SCR-06 · SCR-20 (view in history)
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR19-01 | Loading | Finish tapped, session being persisted | Loading state on finish action | SDS-COMP-8 |
| UC-SCR19-02 | Success | Session persists successfully | Summary of completed workout (date/time, duration, sets/reps/weight actuals) | SRS-FR-33–35, SDS-DATA-6 |
| UC-SCR19-03 | Negative / Business Rule | Workout does not meet completion criteria | Session is recorded/labeled as incomplete and excluded from progress/statistics; summary communicates this clearly | SRS-FR-30 (BR-FR-025), SDS-DATA-8 |
| UC-SCR19-04 | Error / System Failure | Firestore write fails at finish | Error state — workout is **not** shown as saved; retry available; no duplicate record created on retry | SDS-ERR-6 |
| UC-SCR19-05 | Offline | No connectivity at finish | "You're offline — your workout can't be saved until you reconnect" state with retry; in-memory session data preserved for the retry attempt | BR-NFR-020, SDS-ERR-6 |

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
| UC-SCR20-05 | Offline | No connectivity | Offline state | BR-NFR-020 |

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
| UC-SCR21-05 | Offline | No connectivity | Offline state | BR-NFR-020 |

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
| UC-SCR22-04 | Success (data integrity) | An incomplete/invalid session exists in the underlying history | That session is silently excluded from the comparison, not shown as a gap or error | SRS-FR-41 (BR-FR-035), SDS-COMP-10 |
| UC-SCR22-05 | Error / System Failure | Progress data fails to load/calculate | Error state with retry | SDS-ERR-5, SDS-ERR-9 |
| UC-SCR22-06 | Offline | No connectivity | Offline state | BR-NFR-020 |

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
| UC-SCR23-06 | Offline | No connectivity | Offline state | BR-NFR-020 |

---

### SCR-24 — Personal Bests
**Traces to:** SRS-FR-46 · SDS-COMP-11, SDS-DATA-7
**Entry points:** SCR-23
**Exit points:** back to SCR-23
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR24-01 | Loading | PB data being calculated | Skeleton | SDS-IF-12 |
| UC-SCR24-02 | Empty | No valid completed workouts yet | Empty state | SRS-FR-46 |
| UC-SCR24-03 | Populated | PBs exist | List of personal bests per exercise metric, from valid completed records only | SRS-FR-46, SDS-DATA-7 |
| UC-SCR24-04 | Error / System Failure | PB calculation/load fails | Error state with retry | SDS-ERR-5, SDS-ERR-9 |
| UC-SCR24-05 | Offline | No connectivity | Offline state | BR-NFR-020 |

---

## 12. FLOW-10 — Account

### SCR-25 — Profile / Account **[ASSUMPTION]**
**Purpose:** View basic account/profile information created at registration.
**Traces to:** SRS-FR-1, SRS-FR-2 · SDS-COMP-3, SDS-DATA-2
**Assumption flag:** The SDS data model (`users/{uid}`: displayName, dateOfBirth, heightCm, weightKg, fitnessGoal, experienceLevel) implies profile *data exists*, but no SRS-FR explicitly defines a screen for **viewing or editing** this data post-registration, nor does the Authentication Module's registration flow (AUTH-001) collect these fields at sign-up. **Confirm with the SRS/PRD owner before treating this as an editable screen** — as scoped today, this should be built as a minimal, mostly read-only account screen limited to what's demonstrably required (email display, logout).
**Entry points:** SCR-06
**Exit points:** SCR-26
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR25-01 | Loading | Profile being fetched | Skeleton | SDS-IF-14 |
| UC-SCR25-02 | Populated | Profile loaded | Registered email displayed; Logout action | SRS-FR-1, SDS-DATA-2 |
| UC-SCR25-03 | Error / System Failure | Profile fails to load | Error state with retry | SDS-ERR-5 |
| UC-SCR25-04 | Offline | No connectivity | Offline state | BR-NFR-020 |

---

### SCR-26 — Logout Confirmation
**Traces to:** SRS-FR-4 · SDS-COMP-2, SDS-IF-9
**Entry points:** SCR-25
**Exit points:** SCR-01 (confirm) · SCR-25 (cancel)
**Auth requirement:** Required

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR26-01 | Confirmation | User taps Logout | Confirmation modal | SRS-FR-4 |
| UC-SCR26-02 | Success | Logout confirmed | Firebase session terminated; route to SCR-01/SCR-03; Firestore data untouched | SRS-FR-4 (BR-FR-050 boundary note), SDS-COMP-2 |

---

## 13. FLOW-11 — Cross-Cutting / Global States

These are not a single screen but a set of states any authenticated screen must support, since the architecture has no offline mode or local cache (SDS §2.4, Appendix C).

| UC ID | Type | Trigger / Condition | Behavior | Traces to |
|---|---|---|---|---|
| UC-SCR27-01 | Offline (Global) | Connectivity drops while anywhere in the authenticated app | Global, consistent "No connection" indicator/banner across all screens; write actions are blocked/queued-with-warning rather than silently failing | BR-NFR-020, SDS-ERR-5, SDS-ERR-6 |
| UC-SCR27-02 | Error (Global) | Any Firestore read fails, uncategorized | Generic recoverable error state with retry, distinguished from validation errors | SDS-ERR-5 |
| UC-SCR27-03 | Error (Global) | Any Firestore write fails, uncategorized | Write is never represented as successful; retry offered; no duplicate persisted record on retry | SDS-ERR-6 |
| UC-SCR27-04 | Security (Global) | Session becomes invalid mid-use (e.g., token expired, account disabled elsewhere) | User is routed back to SCR-03 with an explanatory message rather than being shown broken/partial protected data | SRS-NFR-8, SDS-COMP-14 |
| UC-SCR27-05 | Boundary (Global) | Any attempt (defensive/edge case) to access another user's data via a malformed request | Rejected at the security-rule boundary; UI never renders another user's data | SRS-NFR-8–10 (BR-NFR-008/010), SDS-COMP-14 |

---

## 14. Traceability Coverage Check

Every SRS-FR-1 through SRS-FR-52 and every SRS-NFR-1 through SRS-NFR-18 is referenced by at least one UC above via its parent screen. Before moving into Figma or user-story authoring, confirm:

1. **SCR-25 (Profile/Account)** is either descoped to the minimal read-only version shown, or the missing profile-editing requirement is added upstream to the SRS/BRD first — do not let a screen silently expand scope beyond what's traceable.
2. Every screen's **Offline** and **Error** rows above should become their own user story or acceptance criteria line — these are currently the states most likely to be skipped by teams moving fast from wireframe to build, and they are explicit, locked architectural decisions (SDS §2.3, Appendix C), not incidental edge cases.
3. The **Loading/Skeleton** state is listed per screen for completeness but may be intentionally lightweight in v1 designs — treat as lower priority than Empty/Error/Offline states, which carry actual requirement traceability (BR-NFR-020 in particular).

---

## 15. Next Steps

- This document is now ready to drive **Figma frame creation**: one frame group per Screen ID, one frame variant per Use Case row.
- It is also ready to drive **user story authoring**: each UC row is close to a "Given/When/Then" acceptance criterion already — the Trigger/Condition column is your "Given/When," the Behavior column is your "Then."
- Recommended story-writing pattern per UC: `As an authenticated user, when [Trigger/Condition] on [Screen], the system shall [Behavior] (traces to [SRS/SDS IDs]).`
